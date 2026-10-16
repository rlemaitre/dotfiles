import copy
import unittest

from op_dedupe.merge import apply_additions, missing_after_merge
from op_dedupe.model import Field, parse_item
from op_dedupe.planner import Additions
from tests.op_dedupe.fixtures import login

ADDITIONS = Additions(
    notes="hint",
    otps=(Field("", "one-time password", "OTP", "otpauth://totp/x?secret=AAAA"),),
    urls=("https://login.example.com",),
    tags=("imported",),
    custom=(Field("Bank", "pin", "CONCEALED", "1234"),),
)


class MergeTest(unittest.TestCase):
    def test_apply_additions_does_not_mutate(self):
        raw = login()
        before = copy.deepcopy(raw)
        apply_additions(raw, ADDITIONS)
        self.assertEqual(raw, before)

    def test_apply_additions_round_trip(self):
        merged = parse_item(apply_additions(login(), ADDITIONS))
        self.assertEqual(missing_after_merge(merged, ADDITIONS), ())
        self.assertEqual(merged.primary_url, "https://example.com")
        self.assertEqual(merged.custom, (Field("Bank", "pin", "CONCEALED", "1234"),))

    def test_new_fields_get_unique_ids(self):
        merged = apply_additions(login(), ADDITIONS)
        ids = [f["id"] for f in merged["fields"]]
        self.assertEqual(len(ids), len(set(ids)))

    def test_existing_section_is_reused(self):
        merged = apply_additions(login(custom=(("Bank", "account", "x"),)), ADDITIONS)
        self.assertEqual([s.get("label") for s in merged["sections"]].count("Bank"), 1)

    def test_missing_after_merge_names_what_is_missing(self):
        unchanged = parse_item(login())
        self.assertEqual(
            missing_after_merge(unchanged, ADDITIONS),
            ("notes", "2FA code", "URL https://login.example.com", "tag imported", "field Bank/pin"),
        )


if __name__ == "__main__":
    unittest.main()
