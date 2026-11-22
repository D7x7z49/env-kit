<!-- @path[.agent/rule/git/precheck/precheck-gate.rule.md] -->
<!-- tree, gate, and scope checks before a commit is created -->

TREE
- run `git status --short` and account for every untracked file
- track a file or add its pattern to `.gitignore`
- keep a scratch file in `tmp/`, which stays untracked
- compare `git ls-files` against the ignore patterns
- drop a wrongly tracked file from the index with `git rm --cached <path>`
- confirm a new pattern with `git check-ignore -v <path>`

GATE
- run `make check`, which runs every hook and the agent file check
- treat a warning as a failure when the project sets zero warnings
- fix a finding by its intent, never by weakening the rule
- add a disable comment only with a stated reason
- keep a failed check visible instead of hiding it

SCOPE
- read `git diff --cached --stat` and match the staged set to the message
- keep one topic per commit and no unrelated cleanup
- cite the rule or the experience that a commit changes, so the change stays traceable
- stage nothing generated and nothing from `tmp/`
- commit only after the checks pass and a human authorizes the commit

---
