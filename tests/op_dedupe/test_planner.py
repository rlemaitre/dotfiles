import unittest
from dataclasses import replace

from op_dedupe.model import parse_item
from op_dedupe.planner import (
    ATTACHMENT_ON_KEEPER,
    ATTACHMENT_OR_PASSKEY,
    CONFLICT_FIELD,
    CONFLICT_NOTES,
    CONFLICT_OTP,
    DIFFERENT_PASSWORDS,
    PASSKEY_ON_KEEPER,
    SEVERAL_SHARED_VAULTS,
    SIGN_IN_LINK,
    UNNAMED_FIELD,
    Flag,
    Plan,
    plan_group,
)
from tests.op_dedupe.fixtures import login

OLD = "2023-01-01T00:00:00Z"
NEW = "2024-01-01T00:00:00Z"


def item(**overrides):
    return parse_item(login(**overrides))


SIGN_IN = {"id": "sso", "section": {"id": "s", "label": "Saved on example.com"}, "type": "UNKNOWN",
           "label": "sign in with"}


def shared(**overrides):
    return item(vault="Shared", vault_id="v-shared", **overrides)


class PlannerTest(unittest.TestCase):
    def plan(self, *items):
        result = plan_group(tuple(items), "v-private")
        self.assertIsInstance(result, Plan, getattr(result, "reason", None))
        return result

    def flag(self, *items):
        result = plan_group(tuple(items), "v-private")
        self.assertIsInstance(result, Flag)
        return result

    def test_several_shared_vaults_flagged(self):
        a = shared(id="a")
        b = item(id="b", vault="Family", vault_id="v-family")
        self.assertEqual(self.flag(a, b, item(id="c")).reason, SEVERAL_SHARED_VAULTS)

    def test_shared_vaults_with_the_same_name_are_different_vaults(self):
        a = item(id="a", vault="Shared", vault_id="v-shared-1")
        b = item(id="b", vault="Shared", vault_id="v-shared-2")
        self.assertEqual(self.flag(a, b).reason, SEVERAL_SHARED_VAULTS)

    def test_shared_vault_named_private_is_still_shared(self):
        p = self.plan(item(id="a", updated_at=NEW), item(id="b", vault="Private", vault_id="v-other", updated_at=OLD))
        self.assertEqual(p.keeper.id, "b")

    def test_different_passwords_flagged(self):
        self.assertEqual(self.flag(item(id="a", password="x"), item(id="b", password="y")).reason, DIFFERENT_PASSWORDS)

    def test_empty_password_differs_from_a_password(self):
        self.assertEqual(self.flag(item(id="a", password=""), item(id="b", password="y")).reason, DIFFERENT_PASSWORDS)

    def test_shared_copy_is_kept(self):
        p = self.plan(item(id="a", updated_at=NEW), shared(id="b", updated_at=OLD))
        self.assertEqual(p.keeper.id, "b")
        self.assertEqual([i.id for i in p.archive], ["a"])

    def test_latest_edit_is_kept(self):
        p = self.plan(item(id="a", updated_at=OLD), item(id="b", updated_at=NEW))
        self.assertEqual(p.keeper.id, "b")

    def test_tie_goes_to_lowest_id(self):
        self.assertEqual(self.plan(item(id="b"), item(id="a")).keeper.id, "a")

    def test_attachment_on_archived_copy_flagged(self):
        flag = self.flag(item(id="a", updated_at=NEW), item(id="b", updated_at=OLD, files=("scan.pdf",)))
        self.assertEqual(flag.reason, ATTACHMENT_OR_PASSKEY)

    def test_attachment_on_keeper_with_additions_flagged(self):
        flag = self.flag(item(id="a", updated_at=NEW, files=("scan.pdf",)), item(id="b", updated_at=OLD, notes="hint"))
        self.assertEqual(flag.reason, ATTACHMENT_ON_KEEPER)

    def test_attachment_on_keeper_is_fine(self):
        self.plan(item(id="a", updated_at=NEW, files=("scan.pdf",)), item(id="b", updated_at=OLD))

    def test_passkey_on_archived_copy_flagged(self):
        b = replace(item(id="b", updated_at=OLD), has_passkey=True)
        self.assertEqual(self.flag(item(id="a", updated_at=NEW), b).reason, ATTACHMENT_OR_PASSKEY)

    def test_sign_in_link_on_archived_copy_flagged(self):
        flag = self.flag(item(id="a", updated_at=NEW), item(id="b", updated_at=OLD, extra_fields=(SIGN_IN,)))
        self.assertEqual(flag.reason, SIGN_IN_LINK)

    def test_sign_in_link_on_keeper_with_additions_flagged(self):
        flag = self.flag(item(id="a", updated_at=NEW, extra_fields=(SIGN_IN,)), item(id="b", updated_at=OLD, notes="hint"))
        self.assertEqual(flag.reason, SIGN_IN_LINK)

    def test_unnamed_field_with_a_value_on_keeper_needing_a_merge_flagged(self):
        unnamed = {"id": "", "type": "STRING", "value": "kept"}
        flag = self.flag(item(id="a", updated_at=NEW, extra_fields=(unnamed,)), item(id="b", updated_at=OLD, notes="hint"))
        self.assertEqual(flag.reason, UNNAMED_FIELD)

    def test_empty_unnamed_field_on_keeper_is_fine(self):
        empty = {"id": "", "type": "STRING"}
        self.plan(item(id="a", updated_at=NEW, extra_fields=(empty,)), item(id="b", updated_at=OLD, notes="hint"))

    def test_sign_in_link_on_keeper_without_additions_is_fine(self):
        self.plan(item(id="a", updated_at=NEW, extra_fields=(SIGN_IN,)), item(id="b", updated_at=OLD))

    def test_notes_copied_when_keeper_empty(self):
        p = self.plan(item(id="a", updated_at=NEW), item(id="b", updated_at=OLD, notes="  hint  "))
        self.assertEqual(p.additions.notes, "hint")
        self.assertIn("notes", p.additions.names())

    def test_conflicting_notes_flagged(self):
        flag = self.flag(item(id="a", notes="one"), item(id="b", notes="two"))
        self.assertEqual(flag.reason, CONFLICT_NOTES)

    def test_same_notes_with_spaces_are_not_a_conflict(self):
        p = self.plan(item(id="a", updated_at=NEW, notes="hint"), item(id="b", updated_at=OLD, notes=" hint\n"))
        self.assertIsNone(p.additions.notes)

    def test_same_otp_written_two_ways_is_not_a_conflict(self):
        uri = "otpauth://totp/Example:me?secret=JBSWY3DPEHPK3PXP&issuer=Example"
        p = self.plan(item(id="a", updated_at=NEW, otps=(uri,)), item(id="b", updated_at=OLD, otps=("jbsw y3dp ehpk 3pxp",)))
        self.assertEqual(p.additions.otps, ())

    def test_conflicting_otp_flagged(self):
        flag = self.flag(item(id="a", otps=("AAAA",)), item(id="b", otps=("BBBB",)))
        self.assertEqual(flag.reason, CONFLICT_OTP)

    def test_otp_copied_when_keeper_has_none(self):
        p = self.plan(item(id="a", updated_at=NEW), item(id="b", updated_at=OLD, otps=("AAAA",)))
        self.assertEqual([f.value for f in p.additions.otps], ["AAAA"])
        self.assertIn("2FA code", p.additions.names())

    def test_empty_otp_on_keeper_does_not_hide_a_secret(self):
        p = self.plan(item(id="a", updated_at=NEW, otps=("",)), item(id="b", updated_at=OLD, otps=("AAAA",)))
        self.assertEqual([f.value for f in p.additions.otps], ["AAAA"])

    def test_urls_and_tags_merged(self):
        p = self.plan(
            item(id="a", updated_at=NEW, tags=("x",)),
            item(id="b", updated_at=OLD, tags=("x", "y"),
                 urls=(("https://example.com", True), ("https://login.example.com", False))),
        )
        self.assertEqual(p.additions.urls, ("https://login.example.com",))
        self.assertEqual(p.additions.tags, ("y",))

    def test_url_differing_only_by_slash_or_case_is_not_added(self):
        p = self.plan(
            item(id="a", updated_at=NEW, urls=(("https://example.com/Login", True),)),
            item(id="b", updated_at=OLD, urls=(("HTTPS://Example.com/Login/", True),)),
        )
        self.assertEqual(p.additions.urls, ())

    def test_same_label_different_sections_are_different_fields(self):
        p = self.plan(
            item(id="a", updated_at=NEW, custom=(("Bank", "pin", "1111"),)),
            item(id="b", updated_at=OLD, custom=(("Card", "pin", "2222"),)),
        )
        self.assertEqual([(f.section, f.label, f.value) for f in p.additions.custom], [("Card", "pin", "2222")])
        self.assertIn("field Card/pin", p.additions.names())

    def test_conflicting_custom_field_flagged(self):
        flag = self.flag(
            item(id="a", custom=(("Bank", "pin", "1111"),)),
            item(id="b", custom=(("Bank", "pin", "2222"),)),
        )
        self.assertEqual(flag.reason, CONFLICT_FIELD)

    def test_passkey_on_keeper_with_additions_flagged(self):
        a = replace(item(id="a", updated_at=NEW), has_passkey=True)
        flag = self.flag(a, item(id="b", updated_at=OLD, notes="hint"))
        self.assertEqual(flag.reason, PASSKEY_ON_KEEPER)

    def test_passkey_on_keeper_without_additions_is_fine(self):
        a = replace(item(id="a", updated_at=NEW), has_passkey=True)
        self.assertEqual(self.plan(a, item(id="b", updated_at=OLD)).keeper.id, "a")

    def test_already_merged_group_has_no_additions(self):
        keeper = item(id="a", updated_at=NEW, notes="hint", otps=("AAAA",), custom=(("", "k", "v"),))
        other = item(id="b", updated_at=OLD, notes="hint", otps=("AAAA",), custom=(("", "k", "v"),))
        p = self.plan(keeper, other)
        self.assertTrue(p.additions.is_empty())
        self.assertEqual([i.id for i in p.archive], ["b"])

    def test_additions_repr_has_no_secrets(self):
        p = self.plan(item(id="a", updated_at=NEW), item(id="b", updated_at=OLD, notes="s3cret-note", otps=("S3CRET",)))
        self.assertNotIn("s3cret-note", repr(p))
        self.assertNotIn("S3CRET", repr(p))


if __name__ == "__main__":
    unittest.main()
