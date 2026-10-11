#!/usr/bin/env bash
# Link the mise-installed docker-compose and buildx binaries into ~/.docker/cli-plugins
# so `docker compose` and `docker buildx` work. Runs on every apply and follows mise
# upgrades: the binary name inside the mise install dir can change between versions.
# ~/.docker/config.json is not managed (it can hold registry credentials).
set -euo pipefail

command -v mise >/dev/null || {
  echo "mise not found, skipping docker plugins" >&2
  exit 0
}

readonly PLUGIN_DIR="${HOME}/.docker/cli-plugins"
mkdir -p "${PLUGIN_DIR}"

link_plugin() {
  local tool="$1" name="$2" dir bin
  dir="$(mise where "${tool}" 2>/dev/null)" || return 0
  bin="$(find "${dir}" -type f -perm -u+x \( -name 'docker-*' -o -name 'buildx*' \) | head -n 1)"
  [[ -n "${bin}" ]] || {
    echo "no ${name} binary found in ${dir}" >&2
    return 0
  }
  ln -sfn "${bin}" "${PLUGIN_DIR}/${name}"
}

link_plugin "github:docker/compose" docker-compose
link_plugin "github:docker/buildx" docker-buildx
