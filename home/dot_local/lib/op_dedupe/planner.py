"""Decide, for one group of duplicate logins, which copy stays, what it receives, and which copies go.

Anything that cannot be decided safely becomes a Flag and the group is left untouched.
"""

from dataclasses import dataclass, field
from urllib.parse import parse_qs, urlparse, urlsplit, urlunsplit

from op_dedupe.model import Field, Item

# Flag reasons double as the labels the report prints.
DIFFERENT_PASSWORDS = "different passwords"
CONFLICT_NOTES = "different notes"
CONFLICT_OTP = "different 2FA codes"
CONFLICT_FIELD = "different values in a custom field"
SEVERAL_SHARED_VAULTS = "copies in several shared vaults"
ATTACHMENT_OR_PASSKEY = "attachment or passkey on a copy to archive"
PASSKEY_ON_KEEPER = "passkey on the kept copy, which needs a merge"
SIGN_IN_LINK = "sign-in link (\"sign in with\") that cannot be merged"
FETCH_FAILED = "an item could not be fetched"


@dataclass(frozen=True)
class Additions:
    notes: str | None = field(default=None, repr=False)
    otps: tuple[Field, ...] = ()
    urls: tuple[str, ...] = ()
    tags: tuple[str, ...] = ()
    custom: tuple[Field, ...] = ()

    def is_empty(self) -> bool:
        return not (self.notes or self.otps or self.urls or self.tags or self.custom)

    def names(self) -> tuple[str, ...]:
        return (
            (("notes",) if self.notes else ())
            + tuple("2FA code" for _ in self.otps)
            + tuple(f"URL {u}" for u in self.urls)
            + tuple(f"tag {t}" for t in self.tags)
            + tuple(field_name(f) for f in self.custom)
        )


@dataclass(frozen=True)
class Plan:
    keeper: Item
    additions: Additions
    archive: tuple[Item, ...]


@dataclass(frozen=True)
class Flag:
    reason: str
    items: tuple[Item, ...]


def field_name(f: Field) -> str:
    return f"field {f.section}/{f.label}" if f.section else f"field {f.label}"


def norm_value(value: str) -> str:
    return (value or "").strip()


def otp_key(value: str) -> str:
    """The secret behind a 2FA value, whether written as an otpauth:// URI or as a bare secret."""
    value = norm_value(value)
    if value.lower().startswith("otpauth://"):
        value = (parse_qs(urlparse(value).query).get("secret") or [""])[0]
    return value.replace(" ", "").upper()


def url_key(href: str) -> str:
    """A URL for comparison: scheme and host lowercased, no trailing slash."""
    parts = urlsplit(norm_value(href))
    return urlunsplit(
        (parts.scheme.lower(), parts.netloc.lower(), parts.path.rstrip("/"), parts.query, parts.fragment)
    )


def _choose_keeper(items: tuple[Item, ...], personal_vault: str) -> Item:
    candidates = [i for i in items if i.vault != personal_vault] or list(items)
    return min(candidates, key=lambda i: (-i.updated_at.timestamp(), i.id))


def _notes(keeper: Item, items: tuple[Item, ...]) -> str | None | Flag:
    values = {norm_value(i.notes) for i in items} - {""}
    if len(values) > 1:
        return Flag(CONFLICT_NOTES, items)
    return None if norm_value(keeper.notes) or not values else values.pop()


def _otps(keeper: Item, others: tuple[Item, ...], items: tuple[Item, ...]) -> tuple[Field, ...] | Flag:
    keys = {otp_key(f.value) for i in items for f in i.otps} - {""}
    if len(keys) > 1:
        return Flag(CONFLICT_OTP, items)
    if keeper.otps or not keys:
        return ()
    return (next(f for i in others for f in i.otps if otp_key(f.value)),)


def _custom(keeper: Item, others: tuple[Item, ...], items: tuple[Item, ...]) -> tuple[Field, ...] | Flag:
    values: dict[tuple[str, str], set[str]] = {}
    for f in (f for i in items for f in i.custom):
        values.setdefault((f.section, f.label), set()).add(norm_value(f.value))
    if any(len(v) > 1 for v in values.values()):
        return Flag(CONFLICT_FIELD, items)
    present = {(f.section, f.label) for f in keeper.custom}
    added: dict[tuple[str, str], Field] = {}
    for f in (f for i in others for f in i.custom):
        if (f.section, f.label) not in present:
            added.setdefault((f.section, f.label), f)
    return tuple(added.values())


def _missing(keeper_values: tuple[str, ...], other_values, key=norm_value) -> tuple[str, ...]:
    """Values the other copies have and the keeper lacks, compared by key; the first spelling seen is kept."""
    seen = {key(v) for v in keeper_values}
    added: dict[str, str] = {}
    for v in other_values:
        if key(v) not in seen:
            added.setdefault(key(v), norm_value(v))
    return tuple(added.values())


def plan_group(items: tuple[Item, ...], personal_vault: str = "Private") -> Plan | Flag:
    if len({i.vault for i in items if i.vault != personal_vault}) > 1:
        return Flag(SEVERAL_SHARED_VAULTS, items)
    if len({i.password for i in items}) > 1:
        return Flag(DIFFERENT_PASSWORDS, items)
    keeper = _choose_keeper(items, personal_vault)
    others = tuple(i for i in items if i is not keeper)
    if any(i.has_files or i.has_passkey for i in others):
        return Flag(ATTACHMENT_OR_PASSKEY, items)
    if any(i.has_sign_in_link for i in others):
        return Flag(SIGN_IN_LINK, items)
    notes = _notes(keeper, items)
    if isinstance(notes, Flag):
        return notes
    otps = _otps(keeper, others, items)
    if isinstance(otps, Flag):
        return otps
    custom = _custom(keeper, others, items)
    if isinstance(custom, Flag):
        return custom
    additions = Additions(
        notes=notes,
        otps=otps,
        urls=_missing(keeper.urls, (u for i in others for u in i.urls), key=url_key),
        tags=_missing(keeper.tags, (t for i in others for t in i.tags)),
        custom=custom,
    )
    if keeper.has_passkey and not additions.is_empty():
        return Flag(PASSKEY_ON_KEEPER, items)
    if keeper.has_sign_in_link and not additions.is_empty():
        return Flag(SIGN_IN_LINK, items)
    return Plan(keeper=keeper, additions=additions, archive=others)
