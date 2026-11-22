<!-- @path[.agent/experience/git/commit/commit-draft.exp.md] -->
<!-- NOTE: where a commit message is drafted and reviewed -->

STEP.
- read the message shape in `.agent/rule/git/commit/conventional-commits.ebnf`
- run `git --no-pager diff --staged` to review the staged change
- write the message block in `tmp/drafts/commit.tmp`

NOTE.
- review the staged diff, not the working tree diff
- exclude a lock file and a generated artifact from the message scope
- keep the draft in `tmp/`, which stays untracked
- hand the block to the commit only after `.agent/rule/git/precheck/precheck-gate.rule.md` passes

---
