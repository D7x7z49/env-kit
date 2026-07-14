#!/usr/bin/env bash
#
# nvim-vm — Neovim Version Manager (Linux-only)
#
# Manages Neovim pre-built binaries from GitHub releases.
# Designed for Linux x86_64 / aarch64 with bash, curl, jq, tar.
# macOS, Windows, and other Unixes are not supported.
#
# Directory layout:
#   ~/.local/share/nvim-vm/versions/<tag>/nvim-linux-<arch>/
#   ~/.local/bin/nvim -> .../versions/<tag>/nvim-linux-<arch>/bin/nvim

set -euo pipefail

# ========================================
# Style helpers
# ========================================
readonly I="  "
log()    { echo "${I}[+] $*"; }
proc()   { echo "${I}[-] $*"; }
inter()  { echo "${I}[*] $*"; }
warn()   { echo "${I}[?] $*"; }
err()    { echo "${I}[!] $*" >&2; exit 1; }
sep()    { echo "---"; }

# ========================================
# Constants
# ========================================
readonly REPO="neovim/neovim"
readonly API="https://api.github.com/repos/${REPO}"
readonly HOME_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim-vm"
readonly VERSIONS="${HOME_DIR}/versions"
readonly BIN="${HOME}/.local/bin"

# version aliases
readonly STABLE="stable"
readonly NIGHTLY="nightly"

# curl timeout (seconds)
readonly CONNECT_TIMEOUT=30
readonly MAX_TIMEOUT=120
readonly API_TIMEOUT=15

# ========================================
# Dependency check
# ========================================
check_deps() {
  local missing=()
  for cmd in curl jq tar sha256sum; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")
  done
  [[ ${#missing[@]} -eq 0 ]] || err "missing: ${missing[*]}"
}

# ========================================
# Shared utilities
# ========================================
ensure_dirs() {
  mkdir -p "${VERSIONS}" "${BIN}"
}

arch_label() {
  local arch; arch="$(uname -m)"
  case "$arch" in
    x86_64)        echo "x86_64" ;;
    aarch64|arm64) echo "arm64" ;;
    *)             err "unsupported architecture: ${arch}" ;;
  esac
}

normalize_tag() {
  local tag="$1"
  tag="${tag#v}"
  case "$tag" in
    [0-9]*) tag="v${tag}" ;;
  esac
  echo "$tag"
}

curl_api() {
  curl -sL --connect-timeout "$API_TIMEOUT" --max-time "$API_TIMEOUT" "$@"
}

fetch_releases() {
  curl_api "${API}/releases?per_page=30" | \
    jq -r '.[] | [.tag_name, .published_at[:10], if .prerelease then "pre" else "" end] | @tsv'
}

fetch_latest_tag() {
  curl_api "${API}/releases/latest" | jq -r '.tag_name'
}

tag_exists() {
  local tag="$1"
  curl_api -sfL "${API}/releases/tags/${tag}" >/dev/null 2>&1
}

fetch_asset_digest() {
  local tag="$1" asset="$2"
  curl_api "${API}/releases/tags/${tag}" | \
    jq -r --arg a "$asset" '.assets[] | select(.name == $a) | .digest | sub("sha256:"; "")'
}

download_extract() {
  local tag="$1"
  local arch; arch="$(arch_label)"
  local asset="nvim-linux-${arch}.tar.gz"
  local url="https://github.com/${REPO}/releases/download/${tag}/${asset}"
  local tmpdir; tmpdir="$(mktemp -d)"

  inter "downloading ${asset}"
  curl -sL --connect-timeout "$CONNECT_TIMEOUT" --max-time "$MAX_TIMEOUT" \
    "$url" -o "${tmpdir}/${asset}"

  # sha256 verification
  proc "verifying checksum"
  local computed; computed="$(sha256sum "${tmpdir}/${asset}" | cut -d' ' -f1)"
  local expected; expected="$(fetch_asset_digest "$tag" "$asset")"
  if [[ "$computed" != "$expected" ]]; then
    rm -rf "$tmpdir"
    err "sha256 mismatch for ${asset}"
  fi

  proc "extracting to ${VERSIONS}/${tag}/"
  mkdir -p "${VERSIONS}/${tag}"
  tar xzf "${tmpdir}/${asset}" -C "${VERSIONS}/${tag}"
  rm -rf "$tmpdir"
}

set_current() {
  local tag="$1"
  local arch; arch="$(arch_label)"
  local target="${VERSIONS}/${tag}/nvim-linux-${arch}/bin/nvim"

  [[ -f "$target" ]] || err "binary not found: ${target}"
  mkdir -p "${BIN}"
  ln -sfn "$target" "${BIN}/nvim"
}

# ========================================
# Commands
# ========================================
cmd_help() {
  cat <<EOF
usage: nvim-vm <command> [<version>]

commands:
  help                this message
  list                show releases from GitHub
  add [-f] [version]  download and install (default: ${STABLE})
  remove <version>    uninstall
  clean               remove all data and symlink
  info                show local state
  use [version]       activate (default: ${STABLE}, auto-adds if missing)
  upgrade             install latest ${STABLE}

options:
  -f, --force       re-download even if already installed

versions: ${STABLE}, ${NIGHTLY}, or a tag like v0.12.0 (v prefix optional)
EOF
}

cmd_list() {
  while IFS=$'\t' read -r tag date prerelease; do
    if [[ "$prerelease" == "pre" ]]; then
      echo "$(printf "%-18s %s  pre" "$tag" "$date")"
    else
      echo "$(printf "%-18s %s" "$tag" "$date")"
    fi
  done < <(fetch_releases)
}

cmd_add() {
  local force=false
  local tag=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--force) force=true; shift ;;
      -*)         err "unknown flag: $1" ;;
      *)          tag="$1"; shift ;;
    esac
  done

  [[ -n "$tag" ]] || tag="${STABLE}"

  case "$tag" in
    ${STABLE})  tag="$(fetch_latest_tag)" ;;
    ${NIGHTLY}) ;;
    *)          tag="$(normalize_tag "$tag")" ;;
  esac

  if [[ -d "${VERSIONS}/${tag}" ]]; then
    if [[ "$force" == false ]]; then
      log "already installed: ${tag}"
      return
    fi
    inter "reinstalling ${tag}"
  fi

  ensure_dirs
  tag_exists "$tag" || err "tag not found: ${tag}"
  download_extract "$tag"
  log "done"
}

cmd_remove() {
  local tag="${1:-}"
  [[ -n "$tag" ]] || err "usage: nvim-vm remove <version>"

  [[ -d "${VERSIONS}/${tag}" ]] || err "not installed: ${tag}"

  # check if currently active
  local arch; arch="$(arch_label)"
  local target="${VERSIONS}/${tag}/nvim-linux-${arch}/bin/nvim"
  if [[ -L "${BIN}/nvim" ]] && [[ "$(readlink "${BIN}/nvim")" == "$target" ]]; then
    err "active version — use 'use <other>' first"
  fi

  rm -rf "${VERSIONS}/${tag}"
  log "removed ${tag}"
}

cmd_clean() {
  if [[ -L "${BIN}/nvim" ]]; then
    rm "${BIN}/nvim"
    log "removed symlink: ${BIN}/nvim"
  fi
  if [[ -d "${HOME_DIR}" ]]; then
    rm -rf "${HOME_DIR}"
    log "removed data: ${HOME_DIR}"
  fi
}

cmd_info() {
  log "arch:   $(arch_label)"
  log "home:   ${HOME_DIR}"
  log "bin:    ${BIN}"
  echo ""
  log "installed:"
  if [[ -d "${VERSIONS}" ]]; then
    local current=""
    [[ -L "${BIN}/nvim" ]] && current="$(readlink "${BIN}/nvim")"
    local entries=("${VERSIONS}"/*/)
    if [[ -d "${entries[0]}" ]]; then
      for dir in "${entries[@]}"; do
        local ver; ver="$(basename "$dir")"
        local ver_arch; ver_arch="$(arch_label)"
        local bin="${dir}nvim-linux-${ver_arch}/bin/nvim"
        if [[ -n "$current" && "$bin" == "$current" ]]; then
          echo "${I}${I}* ${ver}"
        else
          echo "${I}${I}  ${ver}"
        fi
      done
    else
      echo "${I}${I}(none)"
    fi
  else
    echo "${I}${I}(none)"
  fi
  echo ""
  log "current:"
  if [[ -L "${BIN}/nvim" ]]; then
    local target; target="$(readlink "${BIN}/nvim")"
    echo "${I}${I}${target}"
  else
    echo "${I}${I}not set"
  fi
}

cmd_use() {
  local tag="${1:-}"
  [[ -n "$tag" ]] || tag="${STABLE}"

  case "$tag" in
    ${STABLE})  tag="$(fetch_latest_tag)" ;;
    ${NIGHTLY}) ;;
    *)          tag="$(normalize_tag "$tag")" ;;
  esac

  if [[ ! -d "${VERSIONS}/${tag}" ]]; then
    cmd_add "$tag"
  fi
  set_current "$tag"
  log "active: ${tag}"
}

cmd_upgrade() {
  local latest
  latest="$(fetch_latest_tag)"
  cmd_use "$latest"
}

# ========================================
# Main dispatch
# ========================================
main() {
  check_deps
  local cmd="${1:-help}"
  shift 2>/dev/null || true
  case "$cmd" in
    help|--help|-h|'')   cmd_help ;;
    list)                cmd_list "$@" ;;
    add)                 cmd_add "$@" ;;
    remove)              cmd_remove "$@" ;;
    clean)               cmd_clean "$@" ;;
    info)                cmd_info "$@" ;;
    use)                 cmd_use "$@" ;;
    upgrade)             cmd_upgrade "$@" ;;
    *)                   err "unknown: $cmd" ;;
  esac
}

main "$@"
