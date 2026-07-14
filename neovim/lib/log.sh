#!/usr/bin/env bash
#
# log — LogLight logging helpers
#
# Source this from other scripts:
#   source "$(dirname "$0")/lib/log.sh"
#
# Markers:
#   log    [+]  status: positive result, found item
#   proc   [-]  process: action step
#   inter  [*]  interaction: ongoing work, downloading
#   warn   [?]  warning: non-critical
#   err    [!]  error: fatal, exits with code 1
#   sep    ---  visual block divider

# Indentation
readonly I="  "

# status: positive result, found item, created thing
log()    { echo "${I}[+] $*"; }

# process: action step being performed
proc()   { echo "${I}[-] $*"; }

# interaction: ongoing work, downloading, waiting
inter()  { echo "${I}[*] $*"; }

# warning: non-critical, script continues
warn()   { echo "${I}[?] $*"; }

# error: fatal, prints to stderr and exits
err()    { echo "${I}[!] $*" >&2; exit 1; }

# separator: visual block divider
sep()    { echo "---"; }
