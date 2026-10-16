"""Plain-text plan. It names vaults, titles, sites, usernames and field labels, never a field value."""

from collections import Counter

from op_dedupe.grouping import Key
from op_dedupe.model import Item
from op_dedupe.planner import Flag, Plan


def _group_line(key: Key | None) -> str:
    if key is None:
        return "(unknown group)"
    kind, name, user = key
    return f"{name}  {user}" if kind == "url" else f'"{name}" (no URL)  {user}'


def _copy(item: Item) -> str:
    return f"{item.vault}, {item.title}, last edit {item.updated_at:%Y-%m-%d}"


def _counts(plans: list[Plan], flags: list[Flag]) -> list[str]:
    lines = [
        f"Groups: {len(plans) + len(flags)}",
        f"  To merge and archive: {len(plans)} ({sum(len(p.archive) for p in plans)} items)",
        f"  Flagged, left untouched: {len(flags)}",
    ]
    lines += [f"    {reason}: {n}" for reason, n in sorted(Counter(f.reason for f in flags).items())]
    return lines


def _plan(plan: Plan, keys: dict[str, Key]) -> list[str]:
    received = ", ".join(plan.additions.names()) or "nothing"
    return (
        [_group_line(keys.get(plan.keeper.id)), f"  keep     {_copy(plan.keeper)}", f"  receives {received}"]
        + [f"  archive  {_copy(i)}" for i in plan.archive]
        + [""]
    )


def _flag(flag: Flag, keys: dict[str, Key]) -> list[str]:
    first = flag.items[0].id if flag.items else ""
    return [f"{_group_line(keys.get(first))}: {flag.reason}"] + [f"  {_copy(i)}" for i in flag.items] + [""]


def render(plans: list[Plan], flags: list[Flag], keys: dict[str, Key]) -> str:
    lines = _counts(plans, flags) + ["", "== To merge and archive", ""]
    for plan in plans:
        lines += _plan(plan, keys)
    lines += ["== Flagged, fix by hand", ""]
    for flag in flags:
        lines += _flag(flag, keys)
    return "\n".join(lines)
