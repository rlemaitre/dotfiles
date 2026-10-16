"""op-dedupe: find duplicate 1Password logins, print the plan, and with --apply merge and archive them."""

import argparse
import sys
from concurrent.futures import ThreadPoolExecutor

from op_dedupe import opcli
from op_dedupe.grouping import Key, find_groups, group_key
from op_dedupe.merge import apply_additions, lost_after_merge, missing_after_merge
from op_dedupe.model import PASSKEY_TAG, Item, is_passkey, parse_item
from op_dedupe.opcli import OpError
from op_dedupe.planner import FETCH_FAILED, Flag, Plan, plan_group
from op_dedupe.report import render

PERSONAL_VAULT = "Private"
WORKERS = 4
PROGRESS_EVERY = 100


def fetch_items(summaries: list[dict], get=opcli.get_item, workers: int = WORKERS) -> dict[str, Item | OpError]:
    def one(summary: dict) -> tuple[str, Item | OpError]:
        item_id = summary["id"]
        try:
            return item_id, parse_item(get(item_id, summary["vault"]["id"]))
        except OpError as e:
            return item_id, e
        except (KeyError, TypeError, ValueError) as e:
            # Only the exception type: its message could quote item content.
            return item_id, OpError(f"could not read item {item_id}: {type(e).__name__}")

    results: dict[str, Item | OpError] = {}
    with ThreadPoolExecutor(max_workers=workers) as pool:
        for n, (item_id, result) in enumerate(pool.map(one, summaries), start=1):
            results[item_id] = result
            if n % PROGRESS_EVERY == 0 or n == len(summaries):
                print(f"Fetched {n}/{len(summaries)}", file=sys.stderr)
    return results


def build_plan(
    vaults: list[dict], summaries: list[dict], get=opcli.get_item, personal_vault: str = PERSONAL_VAULT
) -> tuple[list[Plan], list[Flag], dict[str, Key | None]]:
    personal = [v for v in vaults if v.get("name") == personal_vault]
    if len(personal) != 1:
        raise SystemExit(
            f"Expected exactly one vault named {personal_vault}, found {len(personal)}: op-dedupe needs it to tell "
            "personal copies from shared ones."
        )
    groups = find_groups(summaries)
    fetched = fetch_items([s for g in groups for s in g], get)
    plans: list[Plan] = []
    flags: list[Flag] = []
    for group in groups:
        results = [fetched[s["id"]] for s in group]
        items = tuple(r for r in results if isinstance(r, Item))
        if len(items) < len(results):
            flags.append(Flag(FETCH_FAILED, items))
            continue
        result = plan_group(items, personal[0]["id"])
        if isinstance(result, Plan):
            plans.append(result)
        else:
            flags.append(result)
    keys = {s["id"]: group_key(s) for g in groups for s in g}
    return plans, flags, keys


def _positive_int(text: str) -> int:
    value = int(text)
    if value < 1:
        raise argparse.ArgumentTypeError("must be 1 or more")
    return value


def _parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="op-dedupe",
        description="Find duplicate 1Password logins. Without --apply, only prints the plan.",
    )
    p.add_argument("--apply", action="store_true", help="merge each group into one copy and archive the others")
    p.add_argument("--limit", type=_positive_int, metavar="N", help="with --apply, handle only the first N groups")
    return p


def _label(key: Key | None) -> str:
    return " ".join(key[1:]) if key else "(unknown group)"


def apply_plan(plan: Plan, label: str, get, edit, archive) -> str | None:
    """Merge one group, then archive its other copies. Returns an error message, or None when done."""
    keeper = plan.keeper
    current = {i.id: get(i.id, i.vault_id) for i in (keeper, *plan.archive)}
    if any(current[i.id].get("version") != i.raw.get("version") for i in (keeper, *plan.archive)):
        print(f"{label}: skipped, a copy changed since the plan was made", file=sys.stderr)
        return None
    if not plan.additions.is_empty():
        edit(keeper.id, keeper.vault_id, apply_additions(current[keeper.id], plan.additions))
        fresh = parse_item(get(keeper.id, keeper.vault_id))
        missing = missing_after_merge(fresh, plan.additions)
        if missing:
            return f"{label}: the kept copy is missing {', '.join(missing)} after the merge; nothing archived"
        lost = lost_after_merge(parse_item(current[keeper.id]), fresh)
        if lost:
            return f"{label}: the kept copy lost {', '.join(lost)} in the merge; nothing archived"
    for item in plan.archive:
        archive(item.id, item.vault_id)
    print(f"{label}: archived {len(plan.archive)}", file=sys.stderr)
    return None


def run_apply(plans: list[Plan], flags: list[Flag], keys, limit, get, edit, archive, read_line) -> int:
    chosen = plans if limit is None else plans[:limit]
    print(
        f"{len(chosen)} groups to merge, {sum(len(p.archive) for p in chosen)} copies to archive; "
        f"{len(flags)} flagged groups are left untouched."
    )
    if read_line("Type yes to apply: ").strip() != "yes":
        print("Nothing changed.")
        return 0
    archived = 0
    try:
        for plan in chosen:
            error = apply_plan(plan, _label(keys.get(plan.keeper.id)), get, edit, archive)
            if error:
                print(f"op-dedupe: {error}", file=sys.stderr)
                return 1
            archived += len(plan.archive)
    except OpError as e:
        print(f"op-dedupe: {e}", file=sys.stderr)
        return 1
    print(f"Done: {len(chosen)} groups, {archived} items archived")
    return 0


def main(argv: list[str], *, vaults=None, summaries=None, get=None, edit=None, archive=None, read_line=input) -> int:
    args = _parser().parse_args(argv)
    get = get or opcli.get_item
    try:
        vaults = opcli.list_vaults() if vaults is None else vaults
        summaries = opcli.list_logins() if summaries is None else summaries
        plans, flags, keys = build_plan(vaults, summaries, get=get)
    except OpError as e:
        print(f"op-dedupe: {e}", file=sys.stderr)
        return 1
    tagged = sum(1 for s in summaries if is_passkey(s))
    print(f"Logins tagged {PASSKEY_TAG}: {tagged} (op cannot see passkeys: tag every login that has one)")
    if not args.apply:
        print(render(plans, flags, keys))
        return 0
    if tagged == 0:
        print(f"op-dedupe: no login is tagged {PASSKEY_TAG}; tag the ones holding a passkey first", file=sys.stderr)
        return 2
    return run_apply(
        plans, flags, keys, args.limit, get, edit or opcli.edit_item, archive or opcli.archive_item, read_line
    )
