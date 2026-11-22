<!-- @path[.agent/rule/core/agent/rule-writing.rule.md] -->
<!-- form, placement, and budget for a rule and an experience in `.agent` -->

FORM
- name the universe, then state the target set the rule allows
- treat the complement of the target set as forbidden
- mark an unclear target set as `[pending]`, then confirm it with a human
- carry one concept in one rule, and one item on one line
- write an imperative sentence in simple words
- expand an abbreviation at its first use

PLACEMENT
- keep a general rule in `rule/core` and a domain rule in `rule/<target>`
- keep an example, a state, and an instance out of a rule
- keep a pointer in a rule and the substance in its own file
- let a later rule override an earlier one, and a closer rule win

BUDGET
- keep a section within seven plus or minus two items
- keep a rule file within 48 lines, and one aspect within seven plus or minus two files
- split a file when a section grows its own sections
- record a change outside the rule set

---
