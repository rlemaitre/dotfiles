import contextlib
import io
import json
import unittest

from op_dedupe.cli import build_plan, main
from op_dedupe.model import parse_item
from op_dedupe.opcli import OpError
from op_dedupe.planner import FETCH_FAILED
from tests.op_dedupe.fixtures import login, summary

VAULTS = [{"id": "v-private", "name": "Private"}, {"id": "v-shared", "name": "Shared"}]


def fake_get(items, failing=()):
    """op item get stand-in; ids in failing raise OpError."""
    by_id = {i["id"]: i for i in items}
    by_id.update({i: OpError(f"op item get {i}: exit 1") for i in failing})

    def get(item_id, _vault_id):
        found = by_id[item_id]
        if isinstance(found, Exception):
            raise found
        return found

    return get


def copies():
    """Two identical copies in Private and one in Shared, same site and username."""
    raws = [
        login(id="p1", updated_at="2024-03-01T00:00:00Z"),
        login(id="p2", updated_at="2024-02-01T00:00:00Z"),
        login(id="s1", vault="Shared", vault_id="v-shared", updated_at="2020-01-01T00:00:00Z"),
    ]
    summaries = [summary(id=r["id"], vault=r["vault"]["name"], vault_id=r["vault"]["id"]) for r in raws]
    return raws, summaries


class CliTest(unittest.TestCase):
    def test_missing_private_vault_stops(self):
        _, summaries = copies()
        with self.assertRaises(SystemExit):
            build_plan([{"id": "v-shared", "name": "Shared"}], summaries, get=fake_get([]))

    def test_two_private_vaults_stop(self):
        _, summaries = copies()
        vaults = VAULTS + [{"id": "v-private-2", "name": "Private"}]
        with self.assertRaises(SystemExit):
            build_plan(vaults, summaries, get=fake_get([]))

    def test_fetch_failure_flags_group(self):
        raws, summaries = copies()
        plans, flags, _ = build_plan(VAULTS, summaries, get=fake_get(raws, failing=("p2",)))
        self.assertEqual(plans, [])
        self.assertEqual([f.reason for f in flags], [FETCH_FAILED])
        self.assertEqual(sorted(i.id for i in flags[0].items), ["p1", "s1"])

    def test_dry_run_end_to_end(self):
        raws, summaries = copies()
        plans, flags, _ = build_plan(VAULTS, summaries, get=fake_get(raws))
        self.assertEqual(flags, [])
        self.assertEqual([p.keeper.id for p in plans], ["s1"])
        self.assertEqual(sorted(i.id for i in plans[0].archive), ["p1", "p2"])

    def test_main_prints_the_plan(self):
        raws, summaries = copies()
        out = io.StringIO()
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(io.StringIO()):
            code = main([], vaults=VAULTS, summaries=summaries, get=fake_get(raws))
        self.assertEqual(code, 0)
        self.assertIn("To merge and archive: 1 (2 items)", out.getvalue())
        self.assertNotIn("pw-1", out.getvalue())

    def test_main_counts_passkey_tags(self):
        raws, summaries = copies()
        summaries.append(summary(id="solo", urls=(("https://solo.example", True),), tags=("passkey",)))
        out = io.StringIO()
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(io.StringIO()):
            main([], vaults=VAULTS, summaries=summaries, get=fake_get(raws))
        self.assertIn("Logins tagged passkey: 1", out.getvalue())


if __name__ == "__main__":
    unittest.main()


class ApplyTest(unittest.TestCase):
    """--apply with fake op calls. Two groups: one needs a merge (notes), one does not."""

    def setUp(self):
        self.raws = {
            r["id"]: r
            for r in (
                login(id="a1", updated_at="2024-02-01T00:00:00Z"),
                login(id="a2", notes="hint", updated_at="2024-01-01T00:00:00Z"),
                login(id="b1", urls=(("https://b.example", True),), updated_at="2024-02-01T00:00:00Z"),
                login(id="b2", urls=(("https://b.example", True),), updated_at="2024-01-01T00:00:00Z"),
            )
        }
        self.summaries = [
            summary(id=i, urls=((r["urls"][0]["href"], True),)) for i, r in self.raws.items()
        ] + [summary(id="pk", urls=(("https://pk.example", True),), tags=("passkey",))]
        self.archived = []
        self.edited = []

    def get(self, item_id, _vault_id):
        return copy_json(self.raws[item_id])

    def edit(self, item_id, _vault_id, item):
        self.edited.append(item_id)
        self.raws[item_id] = {**item, "version": item.get("version", 1) + 1}

    def archive(self, item_id, _vault_id):
        self.archived.append(item_id)

    def run_main(self, argv, answer="yes", edit=None, summaries=None):
        out = io.StringIO()
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(out):
            code = main(
                ["--apply", *argv], vaults=VAULTS, summaries=summaries or self.summaries, get=self.get,
                edit=edit or self.edit, archive=self.archive, read_line=lambda _prompt="": answer,
            )
        return code, out.getvalue()

    def test_apply_merges_then_archives(self):
        code, _ = self.run_main([])
        self.assertEqual(code, 0)
        self.assertEqual(self.edited, ["a1"])
        self.assertEqual(parse_item(self.raws["a1"]).notes, "hint")
        self.assertEqual(sorted(self.archived), ["a2", "b2"])

    def test_apply_needs_yes(self):
        code, out = self.run_main([], answer="y")
        self.assertEqual((self.edited, self.archived), ([], []))
        self.assertIn("Nothing changed", out)

    def test_apply_stops_when_merge_missing(self):
        code, out = self.run_main([], edit=lambda *_args: None)
        self.assertEqual(code, 1)
        self.assertNotIn("a2", self.archived)
        self.assertIn("notes", out)

    def test_limit(self):
        self.run_main(["--limit", "1"])
        self.assertEqual(len(self.archived), 1)

    def test_apply_refuses_without_passkey_tags(self):
        untagged = [s for s in self.summaries if s["id"] != "pk"]
        code, out = self.run_main([], summaries=untagged)
        self.assertEqual(code, 2)
        self.assertEqual((self.edited, self.archived), ([], []))
        self.assertIn("passkey", out)

    def test_only_handles_the_named_site(self):
        self.fetched = []
        get = self.get

        def counting_get(item_id, vault_id):
            self.fetched.append(item_id)
            return get(item_id, vault_id)

        self.get = counting_get
        code, _ = self.run_main(["--only", "https://www.B.example/login"])
        self.assertEqual(code, 0)
        self.assertEqual(self.archived, ["b2"])
        self.assertEqual(set(self.fetched), {"b1", "b2"})

    def test_only_matches_a_title_for_logins_without_url(self):
        raws = {
            "t1": login(id="t1", title="My  Bank", urls=(), updated_at="2024-02-01T00:00:00Z"),
            "t2": login(id="t2", title="my bank", urls=(), updated_at="2024-01-01T00:00:00Z"),
        }
        self.raws.update(raws)
        summaries = self.summaries + [summary(id=i, title=r["title"], urls=()) for i, r in raws.items()]
        code, _ = self.run_main(["--only", "My Bank"], summaries=summaries)
        self.assertEqual(code, 0)
        self.assertEqual(self.archived, ["t2"])

    def test_only_without_a_match_changes_nothing(self):
        code, out = self.run_main(["--only", "nothing.example"])
        self.assertEqual((self.edited, self.archived), ([], []))
        self.assertIn("0 groups to merge", out)

    def test_limit_must_be_positive(self):
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            self.run_main(["--limit", "0"])
        self.assertEqual(self.archived, [])

    def test_copy_changed_since_the_plan_is_not_archived(self):
        def get(item_id, _vault_id):
            raw = copy_json(self.raws[item_id])
            if item_id == "b2" and self.fetches.get(item_id, 0) > 0:
                raw["version"] = 99
            self.fetches[item_id] = self.fetches.get(item_id, 0) + 1
            return raw

        self.fetches = {}
        self.get = get
        code, out = self.run_main([])
        self.assertEqual(code, 0)
        self.assertNotIn("b2", self.archived)
        self.assertIn("a2", self.archived)
        self.assertIn("changed since", out)

    def test_apply_stops_when_merge_drops_existing_data(self):
        def dropping_edit(item_id, vault_id, item):
            fields = [f for f in item["fields"] if f.get("purpose") != "PASSWORD"]
            self.edit(item_id, vault_id, {**item, "fields": fields})

        code, out = self.run_main([], edit=dropping_edit)
        self.assertEqual(code, 1)
        self.assertNotIn("a2", self.archived)
        self.assertIn("lost password", out)

    def test_keeper_changed_since_the_plan_is_skipped(self):
        def get(item_id, vault_id):
            raw = copy_json(self.raws[item_id])
            if item_id == "a1" and self.fetches.setdefault(item_id, 0) > 0:
                raw["version"] = 99
            self.fetches[item_id] = self.fetches.get(item_id, 0) + 1
            return raw

        self.fetches = {}
        self.get = get
        code, out = self.run_main([])
        self.assertEqual(code, 0)
        self.assertEqual(self.edited, [])
        self.assertNotIn("a2", self.archived)
        self.assertIn("changed since", out)


def copy_json(raw):
    return json.loads(json.dumps(raw))
