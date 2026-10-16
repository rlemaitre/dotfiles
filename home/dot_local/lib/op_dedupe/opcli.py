"""Thin wrapper around the 1Password CLI. Arguments are lists (no shell); values only ever travel on stdin."""

import json
import subprocess

OP = "op"


class OpError(Exception):
    """An `op` call failed. The message names the command and op's first stderr line, never a field value."""


def _run(args: list[str], stdin: str | None = None) -> str:
    try:
        proc = subprocess.run([OP, *args], input=stdin, capture_output=True, text=True, check=False)
    except FileNotFoundError as e:
        raise OpError("op not found on PATH (it is installed by mise)") from e
    if proc.returncode != 0:
        first = (proc.stderr.strip().splitlines() or [""])[0]
        raise OpError(f"op {' '.join(args)}: exit {proc.returncode}: {first}")
    return proc.stdout


def _json(args: list[str]):
    return json.loads(_run([*args, "--format", "json"]))


def list_vaults() -> list[dict]:
    return _json(["vault", "list"])


def list_logins() -> list[dict]:
    return _json(["item", "list", "--categories", "Login"])


def get_item(item_id: str, vault_id: str) -> dict:
    return _json(["item", "get", item_id, "--vault", vault_id, "--reveal"])


def edit_item(item_id: str, vault_id: str, item: dict) -> None:
    """Replace the item with this JSON. It goes on stdin, so values never appear in process arguments."""
    _run(["item", "edit", item_id, "--vault", vault_id], stdin=json.dumps(item))


def archive_item(item_id: str, vault_id: str) -> None:
    _run(["item", "delete", item_id, "--vault", vault_id, "--archive"])
