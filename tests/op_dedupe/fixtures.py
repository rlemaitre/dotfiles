"""Made-up 1Password item JSON for the op-dedupe tests. No real data."""


def summary(
    id="item-1",
    title="Example",
    vault="Private",
    vault_id="v-private",
    username="me@example.com",
    urls=(("https://example.com", True),),
    updated_at="2024-01-01T00:00:00Z",
):
    """One entry of `op item list --format json`. urls: (href, primary) pairs."""
    return {
        "id": id,
        "title": title,
        "vault": {"id": vault_id, "name": vault},
        "category": "LOGIN",
        "additional_information": username,
        "urls": [{"label": "website", "primary": p, "href": h} for h, p in urls],
        "updated_at": updated_at,
    }


def login(
    id="item-1",
    title="Example",
    vault="Private",
    vault_id="v-private",
    username="me@example.com",
    password="pw-1",
    notes="",
    urls=(("https://example.com", True),),
    otps=(),
    custom=(),
    tags=(),
    files=(),
    extra_fields=(),
    updated_at="2024-01-01T00:00:00Z",
):
    """One item of `op item get --format json --reveal`.

    otps: OTP values, in the default "add more" section. custom: (section label, field label, value) triples.
    files: file names. extra_fields: raw field dicts appended as they are.
    """
    sections: list[dict] = [{"id": "add more"}]
    fields: list[dict] = [
        {"id": "username", "type": "STRING", "purpose": "USERNAME", "label": "username", "value": username},
        {"id": "password", "type": "CONCEALED", "purpose": "PASSWORD", "label": "password", "value": password},
        {"id": "notesPlain", "type": "STRING", "purpose": "NOTES", "label": "notesPlain", "value": notes},
    ]
    for n, value in enumerate(otps):
        fields.append(
            {"id": f"TOTP_{n}", "section": {"id": "add more"}, "type": "OTP", "label": "one-time password",
             "value": value, "totp": "123456"}
        )
    for n, (section, label, value) in enumerate(custom):
        section_id = f"section-{section}"
        if section and not any(s["id"] == section_id for s in sections):
            sections.append({"id": section_id, "label": section})
        field = {"id": f"custom-{n}", "type": "STRING", "label": label, "value": value}
        if section:
            field["section"] = {"id": section_id, "label": section}
        fields.append(field)
    fields.extend(extra_fields)
    item = {
        "id": id,
        "title": title,
        "version": 1,
        "vault": {"id": vault_id, "name": vault},
        "category": "LOGIN",
        "created_at": "2020-01-01T00:00:00Z",
        "updated_at": updated_at,
        "additional_information": username,
        "urls": [{"label": "website", "primary": p, "href": h} for h, p in urls],
        "sections": sections,
        "fields": fields,
    }
    if tags:
        item["tags"] = list(tags)
    if files:
        item["files"] = [{"id": f"file-{n}", "name": name, "size": 10} for n, name in enumerate(files)]
    return item
