# op-dedupe: clean up duplicate 1Password logins

## Why

Several imports from several sources left the 1Password account full of duplicate logins: hundreds of accounts saved
two to four times. A read-only count showed that almost every group has the same password in every copy, a few dozen
have copies with different passwords, and a handful have a 2FA code on some copies only. (Exact figures stay out of
this public repo.)

The goal is one item per account, without losing anything a copy holds, and without breaking what is shared with
other people.

## Goals

- One command, `op-dedupe`, on both Macs, installed by chezmoi from this repo.
- Default run is a dry run: it prints the full plan and changes nothing.
- `op-dedupe --apply` carries out the plan: it merges the information only the other copies have into one kept copy,
  then archives the other copies.
- Anything the script cannot decide safely is flagged and left untouched, for the user to fix by hand.

## Non-goals

- Logins without a site URL whose titles differ, even slightly ("Amazon" and "Amazon.fr").
- Fuzzy matching: `accounts.google.com` and `google.com`, or usernames with typos, are different accounts here.
- Item categories other than Login.
- Choosing between two different passwords. The user decides those groups by hand.

## Anti-goals (a failure even if it runs)

- A password, a 2FA secret or any field value appears in the output, in a file, in a log or in a process argument
  list.
- A copy in a shared vault is deleted or archived, so the people it is shared with lose it.
- A copy is archived before its information is confirmed to be in the kept copy.
- A passkey is lost.

## Decided by the user

1. **Duplicate:** logins with the same site and the same username, in any vault. Site: the primary URL (else the first
   URL), lowercased, without the scheme, `www.`, the path, query, fragment and port. Username: the login's username,
   lowercased.
   - **Login without a site URL** (no URL, or only empty ones): same title and same username instead. Title and
     username lowercased, leading and trailing spaces removed, inner runs of spaces collapsed to one. A login without a
     username is never matched this way.
   - The two rules never mix: a login with a URL is only matched by site and username, even when a login without a URL
     has the same title.
2. **Shared vault wins:** when a group has a copy in a shared vault (any vault other than `Private`), that copy is kept
   and the `Private` copies go.
3. **Merge:** the kept copy receives what only the other copies have: the 2FA code, notes, site URLs, custom fields.
4. **Conflicts are flagged:** when two copies hold different values in the same field, the group is flagged and nothing
   in it changes.
5. **Different passwords are flagged** (a consequence of 4, stated because it covers a few dozen groups).
6. **Location:** the public dotfiles repo, as a command on both Macs.

## Decided by Claude (the user can override)

- **Path and language:** `home/dot_local/bin/executable_op-dedupe` (installs as `~/.local/bin/op-dedupe`, already on
  PATH). Python 3, standard library only, calling the `op` CLI (`op@2.41.0` from mise) with `subprocess`. No shell
  string building: argument lists only.
- **Archive, not delete:** other copies are removed with `op item delete --archive`, so each can be restored from the
  Archive. Permanent deletion stays a manual step in the 1Password app.
- **Choosing the kept copy** among the candidates (the shared-vault copies, or all copies when none is shared): the most
  recently edited one (`updated_at`). Other copies in the same shared vault are archived too; the kept copy stays in
  that vault, so sharing is unaffected.
- **Also flagged:**
  - copies in two or more different shared vaults (the script does not decide which vault owns the account);
  - a copy that is to be archived holds a file attachment or a passkey (neither can be merged safely);
  - an item that fails to fetch (the whole group is skipped).
- **Fields compared and merged:**
  - Notes: the kept copy's notes empty, another copy's not: copied. Two different non-empty notes: conflict.
  - 2FA (field type `OTP`): same rule as notes. Two copies with different secrets: conflict.
  - URLs: union, kept copy's primary URL stays primary. No conflict possible.
  - Tags: union. No conflict possible.
  - Custom fields: matched by section label plus field label. Missing in the kept copy: added, in the same section.
    Same label, different value: conflict.
  - Title, username casing, password history: the kept copy's are kept. Password history is not merged; it survives in
    the archived copy.
  - Values are compared after trimming leading and trailing whitespace.
- **Applying a merge:** fetch the kept copy as JSON, add the merged fields, pipe the JSON to
  `op item edit <id> --vault <vault>` on stdin (the `op` help documents this; stdin keeps values out of process
  arguments and off disk). Then fetch the kept copy again and check that every merged value is present. Only then
  archive the others. If the check fails, stop the whole run and report the group.
- **`--apply` recomputes the plan** from a fresh fetch, prints its counts, and asks the user to type `yes` before
  changing anything. `--limit N` applies only the first N groups, to try it on a few first.
- **Output:** plain text on stdout, nothing written to disk. Three sections, values never shown:
  1. counts: groups, groups to merge and archive, flagged groups by reason;
  2. planned groups: site, username, kept copy (vault, title, last edit), what it receives (field names only), copies
     to archive (vault, title, last edit);
  3. flagged groups: site, username, the reason, and each copy (vault, title, last edit).
- **Run again safely:** a second run only finds what is left; cleaned groups no longer match.
- **Speed:** fetch items with a few parallel `op item get` calls (4 in parallel fetch about 150 items a minute).

## Constraints

- The repo is public: no vault names other than `Private`, no sites, usernames or other vault data in the code, tests,
  docs or commit messages.
- `mise run check` must pass before the commit.
- `op` may prompt for Touch ID through the 1Password app; the script just waits.

## Known risk the builder must settle first

The `op item edit` help warns: "JSON item templates do not support passkeys. If you use a JSON template to update an
item that contains a passkey, the passkey will be overwritten." So:

1. Find how a passkey shows up in `op item get --format json` (field type, section, or another key), using one item the
   user knows has a passkey.
2. If a kept copy that needs a merge has a passkey, flag the group instead of editing it.
3. If passkeys cannot be detected in the JSON at all, stop and tell the user before writing the apply step.

## Left to the builder

- Internal structure of the script, and tests for the planning logic with made-up item JSON (no `op` calls, no real
  data), run by `mise run check`.
- How errors from `op` are reported, as long as no value leaks.
- A short entry for the command in the repo docs.
