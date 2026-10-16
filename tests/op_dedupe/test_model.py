import unittest
from datetime import datetime, timezone

from op_dedupe.model import Field, parse_item
from tests.op_dedupe.fixtures import login


class ParseItemTest(unittest.TestCase):
    def test_parse_item_fields(self):
        item = parse_item(
            login(
                password="pw-1",
                notes="a note",
                otps=("otpauth://totp/x?secret=ABC",),
                custom=(("Extra", "pin", "1234"),),
                tags=("imported",),
                urls=(("https://other.example", False), ("https://example.com", True)),
                updated_at="2024-05-06T07:08:09Z",
            )
        )
        self.assertEqual(item.password, "pw-1")
        self.assertEqual(item.notes, "a note")
        self.assertEqual(item.otps, (Field("", "one-time password", "OTP", "otpauth://totp/x?secret=ABC"),))
        self.assertEqual(item.custom, (Field("Extra", "pin", "STRING", "1234"),))
        self.assertEqual(item.urls, ("https://other.example", "https://example.com"))
        self.assertEqual(item.primary_url, "https://example.com")
        self.assertEqual(item.tags, ("imported",))
        self.assertEqual(item.username, "me@example.com")
        self.assertEqual(item.vault, "Private")
        self.assertEqual(item.updated_at, datetime(2024, 5, 6, 7, 8, 9, tzinfo=timezone.utc))
        self.assertFalse(item.has_files)

    def test_empty_custom_fields_are_ignored(self):
        item = parse_item(login(custom=(("", "empty", ""),)))
        self.assertEqual(item.custom, ())

    def test_has_sign_in_link(self):
        sso = {"id": "sso", "type": "UNKNOWN", "label": "sign in with"}
        self.assertTrue(parse_item(login(extra_fields=(sso,))).has_sign_in_link)
        self.assertFalse(parse_item(login()).has_sign_in_link)

    def test_has_files(self):
        self.assertTrue(parse_item(login(files=("scan.pdf",))).has_files)

    def test_repr_has_no_secrets(self):
        item = parse_item(
            login(password="s3cret-pw", notes="s3cret-note", otps=("s3cret-otp",), custom=(("", "k", "s3cret-field"),))
        )
        text = repr(item)
        for secret in ("s3cret-pw", "s3cret-note", "s3cret-otp", "s3cret-field"):
            self.assertNotIn(secret, text)
        self.assertNotIn("s3cret-field", repr(item.custom))


if __name__ == "__main__":
    unittest.main()
