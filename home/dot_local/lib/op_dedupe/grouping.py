"""Find duplicate logins from `op item list --format json` metadata (no secrets needed).

Two rules that never mix: logins with a site URL match on site + username, logins without one match on
title + username.
"""

import re
from itertools import groupby

Key = tuple[str, str, str]


def normalize_host(href: str) -> str:
    host = (href or "").strip().lower()
    host = re.sub(r"^[a-z][a-z0-9+.-]*://", "", host)
    host = re.sub(r"^www\.", "", host)
    return re.sub(r"[/:?#].*$", "", host)


def normalize_text(text: str | None) -> str:
    return re.sub(r"\s+", " ", (text or "").strip().lower())


def group_key(summary: dict) -> Key | None:
    user = normalize_text(summary.get("additional_information"))
    urls = [u for u in summary.get("urls") or [] if (u.get("href") or "").strip()]
    if urls:
        href = next((u["href"] for u in urls if u.get("primary")), urls[0]["href"])
        return ("url", normalize_host(href), user)
    if user:
        return ("title", normalize_text(summary.get("title")), user)
    return None


def find_groups(summaries: list[dict]) -> list[list[dict]]:
    keyed = sorted(
        ((key, s) for s in summaries if (key := group_key(s)) is not None and key[1]),
        key=lambda pair: pair[0],
    )
    groups = ([s for _, s in pairs] for _, pairs in groupby(keyed, key=lambda pair: pair[0]))
    return [g for g in groups if len(g) > 1]
