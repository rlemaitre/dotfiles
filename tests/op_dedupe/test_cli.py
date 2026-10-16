import contextlib
import io
import unittest

from op_dedupe.cli import build_plan, main
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


if __name__ == "__main__":
    unittest.main()
