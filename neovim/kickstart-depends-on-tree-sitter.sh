#!/usr/bin/env bash
#
# kickstart-depends-on-tree-sitter.sh
#
# kickstart.nvim (nv-ks) requires tree-sitter-cli >= 0.26.1 to compile
# nvim-treesitter language parsers. Most distribution package managers
# ship older versions that no longer satisfy this requirement.
#
# This helper downloads the latest pre-built tree-sitter-cli binary
# from the official GitHub release page and installs it to ~/.local/bin/.
# It is a one-shot fix: after installation, run nv-ks and parsers will
# compile correctly.
#
# Background:
#   nvim-treesitter switched to requiring an external tree-sitter-cli
#   for parser compilation. The apt/brew/etc. versions are often too old.
#   This is not a kickstart.nvim bug — it affects any config using
#   nvim-treesitter with a system tree-sitter older than 0.26.1.
#
# References:
#   https://github.com/nvim-lua/kickstart.nvim/issues/2021
#   https://github.com/nvim-lua/kickstart.nvim/issues/1894
#   https://github.com/nvim-treesitter/nvim-treesitter/discussions/8402
#
# Usage:
#   ./kickstart-depends-on-tree-sitter.sh
#   PROXY=http://proxy:port  ./kickstart-depends-on-tree-sitter.sh

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
readonly MIN_VERSION="0.26.1"
readonly BIN_DIR="${HOME}/.local/bin"
readonly GH_REPO="tree-sitter/tree-sitter"
readonly GH_API="https://api.github.com/repos/${GH_REPO}/releases/latest"
readonly KS_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim-kickstart"

# ========================================
# Helpers
# ========================================

valid_semver() {
  # compare two semver strings (x.y.z). Returns 0 if a >= b.
  printf '%s\n%s\n' "$2" "$1" | sort -V | head -1 | grep -qF "$2"
}

# ========================================
# Pre-flight checks
# ========================================
if [[ ! -d "$KS_CONFIG_DIR" ]]; then
  err "kickstart.nvim config not found at ${KS_CONFIG_DIR}

install it first: distro.sh install ks

then re-run this helper."
fi

# ========================================
# Check existing installation
# ========================================
if command -v tree-sitter &>/dev/null; then
  existing=$(tree-sitter --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1 || true)
  if [[ -n "$existing" ]] && valid_semver "$existing" "$MIN_VERSION"; then
    log "tree-sitter-cli ${existing} already installed at $(command -v tree-sitter)"
    log "version meets minimum (>= ${MIN_VERSION}). nothing to do."
    exit 0
  else
    warn "found tree-sitter-cli ${existing:-(unknown version)}, need >= ${MIN_VERSION}. upgrading..."
  fi
fi

# ========================================
# Detect architecture
# ========================================
arch=$(uname -m)
case "$arch" in
  x86_64)  asset_tag="linux-x64"    ;;
  aarch64|arm64) asset_tag="linux-arm64" ;;
  *)
    err "unsupported architecture: ${arch}. only x86_64 and arm64 are available as pre-built binaries."
    ;;
esac

# ========================================
# Fetch download URL
# ========================================
inter "fetching latest release info from ${GH_REPO}..."

if [[ -n "${PROXY:-}" ]]; then
  curl_opts=("--proxy" "$PROXY")
else
  curl_opts=()
fi

release_data=$(curl "${curl_opts[@]}" -sL "$GH_API")

download_url=$(echo "$release_data" | \
  grep -oP '"browser_download_url":\s*"[^"]*tree-sitter-cli-[^"]*'"${asset_tag}"'[^"]*"' | \
  head -1 | sed 's/.*"\(.*\)".*/\1/')

if [[ -z "$download_url" ]]; then
  err "could not find download URL for tree-sitter-cli (${asset_tag}) in the latest release."
fi

# ========================================
# Download and install
# ========================================
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

inter "downloading tree-sitter-cli..."
curl "${curl_opts[@]}" -sL "$download_url" -o "${tmpdir}/tree-sitter.zip"

mkdir -p "$BIN_DIR"
unzip -o "${tmpdir}/tree-sitter.zip" -d "$BIN_DIR"
chmod +x "${BIN_DIR}/tree-sitter"

# ========================================
# Verify
# ========================================
if ! command -v tree-sitter &>/dev/null; then
  err "installation succeeded but tree-sitter is not in PATH.

add ${BIN_DIR} to your PATH, or run:
  export PATH=\"\$PATH:${BIN_DIR}\""
fi

version=$(tree-sitter --version 2>/dev/null | head -1)
log "tree-sitter-cli installed: ${BIN_DIR}/tree-sitter"
log "version: ${version}"

# ========================================
# Quick health check
# ========================================
echo ""
proc "running kickstart.nvim checkhealth for nvim-treesitter..."
if NVIM_APPNAME=nvim-kickstart nvim --headless \
  -c "checkhealth nvim-treesitter" \
  -c "qa" 2>&1; then
  echo ""
  log "done. start kickstart.nvim with: nv-ks"
fi
