<!-- @path[.agent/rule/dev/refactor/duplicate-extraction.rule.md] -->
<!-- when a duplicate set may move into one shared file, and who judges it -->

WHEN
- judge one duplicate set per run, inside one package root
- read `.agent/experience/dev/decision/function-purpose.exp.md` first
- require two or more source files that carry the same knowledge
- skip the judgment when the copies differ in intent

JUDGE
- run `.agent/skill/code/refactor/check-duplicate-extraction/scripts/check.py <task>.json` from the project root
- pass the root, the target path, and the source paths as json
- read one line, `true` or `false`, from stdout
- treat a non-empty stderr as a failed run

RESULT
- consolidate into the target path when the answer is `true`
- keep the copies separate when the answer is `false`
- keep the shared file free of behavior flags and mode parameters
- leave the edit to the caller and report the answer with its evidence

---
