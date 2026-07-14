#!/usr/bin/env bash
#
# distro — Neovim distribution manager
#
# Manage Neovim distribution configs via NVIM_APPNAME.
# Aliases are written to ~/.bash_aliases.
#
# Usage:
#   distro.sh install   <key>    install a distribution
#   distro.sh uninstall <key>    remove a distribution
#   distro.sh list                list installed distributions
#
# Keys:
#   lv  LazyVim        nvim-lazyvim
#   as  AstroNvim      nvim-astronvim
#   nc  NvChad         nvim-nvchad
#   ks  kickstart      nvim-kickstart

set -euo pipefail
IFS=$'\n\t'
source "$(dirname "$0")/lib/log.sh"

# ========================================
# Constants
# ========================================
readonly ALIAS_FILE="${HOME}/.bash_aliases"
readonly ALIAS_PREFIX="nv-"
readonly XDG_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly XDG_DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
readonly XDG_STATE="${XDG_STATE_HOME:-$HOME/.local/state}"
readonly XDG_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}"

# ========================================
# Distro registry
# ========================================
declare -A DISTRO_REPO DISTRO_NAME DISTRO_APPNAME

register() {
  DISTRO_REPO[$1]="$2"
  DISTRO_NAME[$1]="$3"
  DISTRO_APPNAME[$1]="$4"
}

register lv "LazyVim/starter"         "LazyVim"        "nvim-lazyvim"
register as "AstroNvim/template"      "AstroNvim"      "nvim-astronvim"
register nc "NvChad/starter"          "NvChad"         "nvim-nvchad"
register ks "nvim-lua/kickstart.nvim" "kickstart.nvim" "nvim-kickstart"

# iterate over registered keys (order not guaranteed — by design)
keys() { printf '%s\n' "${!DISTRO_REPO[@]}"; }



# ========================================
# Derived helpers
# ========================================
alias_name() { echo "${ALIAS_PREFIX}$1"; }
appname()    { echo "${DISTRO_APPNAME[$1]}"; }

xdg_dir() {
  local type="$1" key="$2"
  local base
  case "$type" in
    config) base="$XDG_CONFIG" ;;
    data)   base="$XDG_DATA"   ;;
    state)  base="$XDG_STATE"  ;;
    cache)  base="$XDG_CACHE"  ;;
  esac
  echo "${base}/$(appname "$key")"
}

has_alias() {
  grep -qF "alias $1=" "$ALIAS_FILE" 2>/dev/null
}

# ========================================
# Validation
# ========================================
require_key() {
  local key="$1"
  [[ -n "${DISTRO_REPO[$key]:-}" ]] || err "unknown key: $key  — valid: $(printf '%s ' $(keys))"
}

# ========================================
# Alias management
# ========================================
write_alias() {
  local key="$1"
  local an; an="$(alias_name "$key")"

  if has_alias "$an"; then
    proc "alias already exists: ${an}"
    return
  fi

  mkdir -p "$(dirname "$ALIAS_FILE")"
  {
    echo "# ${DISTRO_NAME[$key]} (${an})"
    echo "alias ${an}='NVIM_APPNAME=$(appname "$key") nvim'"
  } >> "$ALIAS_FILE"
  log "alias ${an} added"
}

remove_alias() {
  local key="$1"
  local an; an="$(alias_name "$key")"

  if ! has_alias "$an"; then
    proc "no alias found: ${an}"
    return
  fi

  sed -i "/^# ${DISTRO_NAME[$key]} (${an})$/,/^alias ${an}=/d" "$ALIAS_FILE"
  log "alias ${an} removed"
}

# ========================================
# Install
# ========================================
cmd_install() {
  local key="$1"
  require_key "$key"

  local dn; dn="${DISTRO_NAME[$key]}"
  local repo; repo="https://github.com/${DISTRO_REPO[$key]}"
  local cdir; cdir="$(xdg_dir config "$key")"

  if [[ -d "$cdir" ]]; then
    warn "directory already exists: ${cdir}"
    local bak; bak="${cdir}.bak.$(date +%s)"
    mv "$cdir" "$bak"
    log "backup: ${bak}"
  fi

  inter "cloning ${repo}..."
  git clone --depth 1 "$repo" "$cdir"
  log "cloned to ${cdir}"

  proc "removing .git"
  rm -rf "${cdir}/.git"

  write_alias "$key"
}

# ========================================
# Uninstall
# ========================================
cmd_uninstall() {
  local key="$1"
  require_key "$key"
  local dn; dn="${DISTRO_NAME[$key]}"

  local removed=false
  for t in config data state cache; do
    local d; d="$(xdg_dir "$t" "$key")"
    if [[ -d "$d" ]]; then
      proc "removing ${d}"
      rm -rf "$d"
      removed=true
    fi
  done

  if [[ "$removed" == false ]]; then
    warn "nothing to remove for ${dn}"
  fi

  remove_alias "$key"
}

# ========================================
# List
# ========================================
cmd_list() {
  local any=false
  for key in $(keys); do
    local cdir; cdir="$(xdg_dir config "$key")"
    [[ -d "$cdir" ]] || continue

    any=true
    local an; an="$(alias_name "$key")"
    local mark=" "
    has_alias "$an" && mark="*"

    printf "  %s %-5s %s\n" "$mark" "$an" "${DISTRO_NAME[$key]}"
  done

  if [[ "$any" == false ]]; then
    echo "  (none)"
  fi
}

# ========================================
# Main dispatch
# ========================================
main() {
  local cmd="${1:-help}"
  shift 2>/dev/null || true

  case "$cmd" in
    help|--help|-h|'')
      cat <<EOF
usage: distro.sh <command> [<key>]

commands:
  install   <key>   install distribution
  uninstall <key>   remove distribution
  list              list installed distributions
---
keys:
  lv  LazyVim
  as  AstroNvim
  nc  NvChad
  ks  kickstart.nvim
EOF
      ;;
    install)
      [[ $# -ge 1 ]] || err "usage: distro.sh install <key>"
      cmd_install "$1"
      ;;
    uninstall)
      [[ $# -ge 1 ]] || err "usage: distro.sh uninstall <key>"
      cmd_uninstall "$1"
      ;;
    list)
      cmd_list
      ;;
    *)
      err "unknown command: $cmd  (try help)"
      ;;
  esac
}

main "$@"
