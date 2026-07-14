#!/usr/bin/env bash
#
# clean — remove Neovim config/data/state/cache directories
#
# Usage:
#   clean.sh <name> [name...]
#   clean.sh --help
#
# Examples:
#   clean.sh nvim
#   clean.sh nvim nvim-lazyvim nvim-kickstart

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
readonly XDG_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly XDG_DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
readonly XDG_STATE="${XDG_STATE_HOME:-$HOME/.local/state}"
readonly XDG_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}"

usage() {
  echo "Usage: $(basename "$0") <name> [name...]"
  echo
  echo "Examples:"
  echo "  $(basename "$0") nvim"
  echo "  $(basename "$0") nvim nvim-lazyvim nvim-kickstart"
}

clean() {
  local name dirs=()

  for name in "$@"; do
    for base in "$XDG_CONFIG" "$XDG_DATA" "$XDG_STATE" "$XDG_CACHE"; do
      dirs+=("$base/$name")
    done
  done

  warn "the following directories will be removed:"
  for d in "${dirs[@]}"; do
    if [[ -d "$d" ]]; then
      proc "  $d"
    fi
  done

  echo ""
  read -p "Proceed? [y/N] " answer
  if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    log "aborted."
    exit 0
  fi

  for d in "${dirs[@]}"; do
    if [[ -d "$d" ]]; then
      rm -rf "$d"
      log "removed: $d"
    fi
  done
}

main() {
  # Explicit help flag
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    usage
    exit 0
  fi

  if [[ $# -eq 0 ]]; then
    usage
    exit 1
  fi

  clean "$@"
}

main "$@"
