<!-- @path[.agent/rule/dev/install/install-safety.rule.md] -->
<!-- target, backup, and report rules for install scripts -->

TARGET
- resolve `XDG_CONFIG_HOME` first, then fall back to `~/.config`
- accept an override only when it is an absolute path
- keep the target path visible in the success message

BACKUP
- back up an existing target before replacing it
- stamp the backup with a unique time value
- keep the backup next to the target, as `<name>.bak-<stamp>`
- refuse to continue when the backup path already exists
- report the backup path after the install

WRITE
- write a generated file to `<name>.tmp`, then replace the target
- copy an existing tree with a merge mode so a rerun stays safe
- create parent directories when missing

IDEMPOTENCY
- make a second run safe and quiet
- skip work that is already present, such as an existing alias
- keep the same result for the same input

REPORT
- document usage and exit codes in the file header
- return `0` on success and `1` on failure
- write a failure message to stderr, prefixed with the failing item
- keep every message in one table when the script is python
- reload the target tool only when it is installed and running
- treat a failed optional reload as a failure, not as a silent skip

REFERENCES
- read `xdg-basedir/basedir-spec.xml` for the base directory rules
- read `man-pages/man7/environ.7` for the process environment

---
