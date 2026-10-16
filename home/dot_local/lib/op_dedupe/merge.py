"""Write a plan's additions into the kept copy's JSON, and check afterwards that they arrived."""

import copy
import secrets

from op_dedupe.model import Field, Item
from op_dedupe.planner import Additions, field_name, norm_value, otp_key, url_key


def _new_id(prefix: str) -> str:
    return f"{prefix}{secrets.token_hex(8)}"


def _section_ref(sections: list[dict], label: str) -> dict | None:
    """The section with this label, created when missing. None for fields outside any section."""
    if not label:
        return None
    existing = next((s for s in sections if s.get("label") == label), None)
    if existing is None:
        existing = {"id": _new_id("Section_"), "label": label}
        sections.append(existing)
    return {"id": existing["id"], "label": label}


def _field_json(f: Field, sections: list[dict], prefix: str) -> dict:
    out: dict = {"id": _new_id(prefix), "type": f.type or "STRING", "label": f.label, "value": f.value}
    section = _section_ref(sections, f.section)
    if section:
        out["section"] = section
    return out


def apply_additions(raw: dict, additions: Additions) -> dict:
    item = copy.deepcopy(raw)
    fields = item.setdefault("fields", [])
    sections = item.setdefault("sections", [])
    if additions.notes:
        notes = next((f for f in fields if f.get("purpose") == "NOTES"), None)
        if notes is None:
            notes = {"id": "notesPlain", "type": "STRING", "purpose": "NOTES", "label": "notesPlain"}
            fields.append(notes)
        notes["value"] = additions.notes
    fields.extend(_field_json(f, sections, "TOTP_") for f in additions.otps)
    fields.extend(_field_json(f, sections, "dedupe") for f in additions.custom)
    item.setdefault("urls", []).extend({"label": "website", "primary": False, "href": u} for u in additions.urls)
    if additions.tags:
        item["tags"] = [*item.get("tags", []), *additions.tags]
    return item


def missing_after_merge(fresh: Item, additions: Additions) -> tuple[str, ...]:
    missing: list[str] = []
    if additions.notes and norm_value(fresh.notes) != norm_value(additions.notes):
        missing.append("notes")
    otp_keys = {otp_key(f.value) for f in fresh.otps}
    missing += ["2FA code" for f in additions.otps if otp_key(f.value) not in otp_keys]
    urls = {url_key(u) for u in fresh.urls}
    missing += [f"URL {u}" for u in additions.urls if url_key(u) not in urls]
    tags = {norm_value(t) for t in fresh.tags}
    missing += [f"tag {t}" for t in additions.tags if norm_value(t) not in tags]
    custom = {(f.section, f.label, norm_value(f.value)) for f in fresh.custom}
    missing += [field_name(f) for f in additions.custom if (f.section, f.label, norm_value(f.value)) not in custom]
    return tuple(missing)
