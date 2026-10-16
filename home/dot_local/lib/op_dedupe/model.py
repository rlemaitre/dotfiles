"""Immutable view of one 1Password login, parsed from `op item get --format json --reveal`.

Secret attributes are left out of repr(), so a traceback or a debug print never shows them.
"""

from dataclasses import dataclass, field
from datetime import datetime

BUILT_IN_PURPOSES = ("USERNAME", "PASSWORD", "NOTES")


@dataclass(frozen=True)
class Field:
    section: str  # section label, "" when the field has none
    label: str
    type: str
    value: str = field(repr=False)


@dataclass(frozen=True)
class Item:
    id: str
    vault_id: str
    vault: str
    title: str
    username: str
    updated_at: datetime
    password: str = field(repr=False)
    notes: str = field(repr=False)
    otps: tuple[Field, ...] = field(repr=False)
    urls: tuple[str, ...]
    primary_url: str
    tags: tuple[str, ...]
    custom: tuple[Field, ...] = field(repr=False)
    has_files: bool
    has_passkey: bool
    has_sign_in_link: bool  # "sign in with" fields: type UNKNOWN, no value, so they cannot be merged
    raw: dict = field(repr=False, compare=False)


def _builtin(fields: list[dict], purpose: str) -> str:
    return next((f.get("value") or "" for f in fields if f.get("purpose") == purpose), "")


def _field(raw_field: dict) -> Field:
    section = raw_field.get("section") or {}
    return Field(
        section=section.get("label") or "",
        label=raw_field.get("label") or "",
        type=raw_field.get("type") or "",
        value=raw_field.get("value") or "",
    )


def is_passkey(raw: dict) -> bool:
    """Whether the item holds a passkey. Marker settled by Task 1 of the plan."""
    return False


def parse_item(raw: dict) -> Item:
    fields = raw.get("fields") or []
    urls = tuple(u["href"] for u in raw.get("urls") or [] if u.get("href"))
    primary = next((u["href"] for u in raw.get("urls") or [] if u.get("primary") and u.get("href")), "")
    return Item(
        id=raw["id"],
        vault_id=raw["vault"]["id"],
        vault=raw["vault"].get("name") or "",
        title=raw.get("title") or "",
        username=_builtin(fields, "USERNAME"),
        updated_at=datetime.fromisoformat(raw["updated_at"]),
        password=_builtin(fields, "PASSWORD"),
        notes=_builtin(fields, "NOTES"),
        otps=tuple(_field(f) for f in fields if f.get("type") == "OTP"),
        urls=urls,
        primary_url=primary or (urls[0] if urls else ""),
        tags=tuple(raw.get("tags") or ()),
        custom=tuple(
            _field(f)
            for f in fields
            if f.get("purpose") not in BUILT_IN_PURPOSES and f.get("type") != "OTP" and f.get("value")
        ),
        has_files=bool(raw.get("files")),
        has_passkey=is_passkey(raw),
        has_sign_in_link=any(f.get("type") == "UNKNOWN" for f in fields),
        raw=raw,
    )
