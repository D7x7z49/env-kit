<!-- @path[.agent/rule/dev/shell/script-layout.rule.md] -->
<!-- header, safety, and shape rules for shell scripts in this repo -->

HEADER
- start with `#!/usr/bin/env bash` on the first line
- follow with a comment block for name, purpose, usage, and supported targets
- write usage lines as runnable commands
- state directory layout when the script manages paths

RELIABILITY
- put `set -euo pipefail` after the header
- quote every variable in a path or command
- fail with a message on stderr and a non-zero exit
- check a required argument before acting on it

SHAPE
- declare fixed values with `readonly`
- keep one style helper block with `log`, `proc`, `inter`, `warn`, and `err`
- keep one indented prefix for every helper message
- separate sections with a banner comment
- keep a helper function one line when it fits

ISOLATION
- keep a script self-contained so it runs alone from a clone or a download
- do not source a sibling file
- duplicate a small helper block instead of creating a shared include
- put a one-off probe in `tmp/scripts/` and keep it re-runnable

---
