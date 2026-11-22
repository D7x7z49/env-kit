<!-- @path[.agent/AGENTS.md] -->
<!-- NOTE: reading map for the rules, experience, and skills in `.agent`. -->

PURPOSE
- this file is the reading map for `.agent`
- it explains layout, reading order, and category boundaries
- it does not replace the rule files

LAYOUT
- `.agent` has three directories, `experience`, `rule`, and `skill`
- `AGENTS.md` is the only root file
- place an entry at target, then aspect
- name an experience file `<name>.exp.md`
- name a prose rule `<name>.rule.md` and a shape rule `<name>.ebnf`
- place a skill at target, aspect, then skill name, and hold `SKILL.md` there
- load the skill directory from `.pi/settings.json`
- describe an entry in the header of its file

READING
- read this map first
- read the format rule before writing a rule or an experience
- read the central agent rule before a domain rule
- read a domain rule before experience
- read experience only when context matters
- read grammar only when shape or format matters
- read a skill only when its description matches the task

RULE
- treat rule as normative, abstract, and stateless
- use it for action and validation
- keep one rule per file and one topic per section
- keep the rule short enough to hold in one reading

EXPERIENCE
- treat experience as episodic, contextual, and stateful
- use it for evidence, precedent, and background
- do not treat it as normative
- record what happened, not what should happen

SKILL
- treat skill as procedural and situational, not normative
- use it for the task at hand, not for general policy
- keep the deterministic part in `scripts/` and detail in `references/`
- let a rule win when a skill and a rule conflict

GRAMMAR
- treat grammar as structure, not behavior
- use `rule/ebnf/syntax/` for the notation
- use `rule/core/format/` for document shape

BUDGET
- keep a rule file within 48 lines and an experience file within 48 lines
- keep a skill file within 80 lines and a payload file within 300 lines
- keep this file within 128 lines
- let `scripts/ci/check-agent-files.py` report a breach

CONFLICT
- let rule win when rule and experience conflict
- let a closer rule win over a general rule
- report a conflict instead of inventing a third rule

REFERENCES
- `rule/core/agent/` for chat, writing, and rule form
- `rule/core/format/` for rule, experience, and skill formats
- `rule/ebnf/syntax/` for the grammar notation
- `rule/dev/` for script, install, citation, cli, and refactor conventions
- `rule/git/` for commit, branch, and precheck shape
- `rule/gh/` for pull request shape
- `rule/tmux/` and `rule/neovim/` for component conventions
- `skill/` for a task procedure that ships its own script
