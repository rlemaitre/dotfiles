import unittest

from op_dedupe.model import parse_item
from op_dedupe.planner import DIFFERENT_PASSWORDS, Additions, Flag, Plan
from op_dedupe.report import render
from tests.op_dedupe.fixtures import login

SECRETS = ("SECRET-1", "SECRET-2", "SECRET-3", "SECRET-4")


def item(id, **overrides):
    return parse_item(
        login(id=id, password="SECRET-1", notes="SECRET-2", otps=("SECRET-3",), custom=(("S", "k", "SECRET-4"),),
              **overrides)
    )


class ReportTest(unittest.TestCase):
    def setUp(self):
        a, b, c, d, e, f, g = (item(x) for x in "abcdefg")
        notes_and_otp = Additions(notes="SECRET-2", otps=b.otps, custom=b.custom)
        self.plans = [Plan(a, notes_and_otp, (b,)), Plan(c, Additions(), (d, e))]
        self.flags = [Flag(DIFFERENT_PASSWORDS, (f, g))]
        self.keys = {
            "a": ("url", "example.com", "me@example.com"),
            "c": ("title", "my bank", "me"),
            "f": ("url", "other.example", "me@example.com"),
        }
        self.text = render(self.plans, self.flags, self.keys)

    def test_counts(self):
        self.assertIn("Groups: 3", self.text)
        self.assertIn("To merge and archive: 2 (3 items)", self.text)
        self.assertIn("different passwords: 1", self.text)

    def test_groups_are_listed(self):
        self.assertIn("example.com  me@example.com", self.text)
        self.assertIn('"my bank" (no URL)  me', self.text)
        self.assertIn("receives notes, 2FA code, field S/k", self.text)
        self.assertIn("Private, Example, last edit 2024-01-01", self.text)

    def test_no_values_in_output(self):
        for secret in SECRETS:
            self.assertNotIn(secret, self.text)


if __name__ == "__main__":
    unittest.main()
