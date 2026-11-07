<!-- @path[.agent/AGENTS.md] -->
<!-- NOTE: reading map for the rules and experience in `.agent`. -->

PURPOSE
- this file is the reading map for `.agent`
- it explains layout, reading order, and category boundaries
- it does not replace the rule files

LAYOUT
- `.agent` has two directories, `experience` and `rule`
- `AGENTS.md` is the only root file
- place an entry at target, then aspect
- name an experience file `<name>.exp.md`
- name a prose rule `<name>.rule.md` and a shape rule `<name>.ebnf`
- describe an entry in the header of its file

READING
- read this map first
- read the format rule before writing a rule or an experience
- read the central agent rule before a domain rule
- read a domain rule before experience
- read experience only when context matters
- read grammar only when shape or format matters

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

GRAMMAR
- treat grammar as structure, not behavior
- use `rule/ebnf/syntax/` for the notation
- use `rule/core/format/` for document shape

CONFLICT
- let rule win when rule and experience conflict
- let a closer rule win over a general rule
- report a conflict instead of inventing a third rule

REFERENCES
- `rule/core/agent/` for chat, writing, and repository behavior
- `rule/core/format/` for experience and rule formats
- `rule/ebnf/syntax/` for the grammar notation
- `rule/dev/` for script, install, and citation conventions
- `rule/tmux/` and `rule/neovim/` for component conventions
- `rule/git/` for commit shape

---
