<!-- @path[.agent/experience/dev/decision/agent-knowledge-port.exp.md] -->
<!-- NOTE: which earlier agent layer each part of `.agent` came from -->

STEP.
- treat `yggdrasil/.agent` as the source of the three core directories and the formats
- treat `llm-api-scope/.pi` as the source of the experience entries written before the split
- treat `game/.pi` and `lint-editor` as the source of the precheck gate and the fence rule
- treat `yggdrasil/.agent/skill` as the source of the duplicate-extraction skill
- keep the form rules of the `rule-writing` skill as `rule/core/agent/rule-writing.rule.md`
- drop the `config/root.list` wrapper, because this repo has no package roots
- keep one copy of every entry, and name its source in this file

NOTE.
- evidence: this repo copied the yggdrasil layout on 2026-11-07 and trimmed seven entries
- evidence: `rule-writing` was removed on 2026-11-10 for mixing form, layout, lint, and process
- the trimmed entries were `fractal-scope-design`, `comment-scope`, `error-handling`, and `commit-draft`
- the trimmed shapes were `gh/pull-request`, `git/branch`, and the skill directory
- all seven returned on 2026-11-20, with the rule-writing form rules added as a rule
- a skill carries the script, so a judgment with a deterministic part belongs in `skill/`
- the source repos keep their own copy, so this repo ports a decision and not a link
- read this file before porting again, so one entry does not arrive twice

---
