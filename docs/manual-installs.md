# Manual installs

Apps installed by hand on athena because Homebrew cannot install them. They are not in `packages.yaml`;
install them yourself on a new Mac.

| App | Why not Homebrew | Install | On athena |
|---|---|---|---|
| LibreCAD | cask `librecad` disabled on 2026-09-01: it fails the macOS Gatekeeper check | download from <https://librecad.org/> | 2.2.1 |
| Send to Kindle | cask `send-to-kindle` fails: Amazon's installer URL answers HTTP 403 (checked 2026-10-11) | download from <https://www.amazon.com/gp/sendtokindle/mac> | 1.1 |

To see whether a cask works again: `brew info --cask librecad send-to-kindle` (a disabled cask says so), then
`brew install --cask --adopt <cask>` brings an app that is already installed under Homebrew's management.
If you do, add the cask to `home/.chezmoidata/packages.yaml` and remove its row here.
