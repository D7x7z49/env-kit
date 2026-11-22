---
name: check-duplicate-extraction
description: >
  judge whether duplicate functions, classes, types, or interfaces belong in
  one shared file. use during a refactor or a reuse extraction, after the
  caller confirms the copies are semantically identical.
---
<!-- @path[.agent/skill/code/refactor/check-duplicate-extraction/SKILL.md] -->
<!-- NOTE: one boolean answer per duplicate set, with a cost model behind it -->

SCOPE
- apply to one duplicate set per run
- apply inside one package root chosen by the caller
- trust the caller's root and the caller's duplicate confirmation
- measure lookup cost, shared change benefit, and traversal cost
- return one boolean and leave the edit to the caller
- read `.agent/rule/dev/refactor/duplicate-extraction.rule.md` for the rule

INPUT
- provide one json object as a file or on stdin

```json
{
  "root": "packages/a",
  "target": { "path": "src/shared/dup.py", "added": true },
  "sources": ["src/x.py", "src/y.py"]
}
```

- `root`: package root, relative to the project root
- `target`: the destination object
  - `path`: the shared file, relative to `root`
  - `added`: true when the file is new
- `sources`: the files holding the copies, relative to `root`
- `root` bounds every path

OUTPUT
- print one line, `true` or `false`
- treat a non-empty stderr as a failed run
- `true` means one shared file at `target.path`
- `false` means the copies stay separate
- a single source file returns `false`

SCRIPT
- run `scripts/check.py task.json` from the project root
- pass the same object on stdin with `scripts/check.py -`

WORKFLOW
- confirm the copies are semantically identical
- choose a package root the project allows
- collect the destination path and the source files
- run the script on the json file
- read the boolean from stdout
- consolidate into `target.path` when the answer is `true`
- keep the copies when the answer is `false`

---
