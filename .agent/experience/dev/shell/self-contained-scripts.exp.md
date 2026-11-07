<!-- @path[.agent/experience/dev/shell/self-contained-scripts.exp.md] -->
<!-- NOTE: why each script carries its own helpers instead of a shared file -->

STEP.
- run each script from a clone or from a downloaded copy
- avoid `source` of a sibling file, so the script has one file to fetch
- repeat the small style helper block in each script
- keep `set -euo pipefail` in every script, not in a shared include
- put a one-off probe under `tmp/scripts/` so it can be rerun later
- keep a script that changes state in the tracked tree, not in `tmp/`
- state the platform and the expected tools in the header

NOTE.
- evidence: the `neovim` scripts repeat the `log`, `proc`, `warn`, and `err` helpers
- evidence: commit `aedd29a` made the scripts self-contained for remote curl use
- evidence: `tmp/README.md` keeps probes and drafts for audit, outside the tracked tree
- the helper block is small and stable, so the duplication cost stays low
- a shared include would add a download, a path assumption, and one more failure mode
- revisit this choice when a helper grows, becomes stateful, or starts to drift between scripts

---
