<!-- @path[.agent/rule/tmux/config/part-layout.rule.md] -->
<!-- file split and load order rules for the tmux config -->

PART
- keep one concern per file under `tmux/parts`
- keep terminal keys and the mouse in `options.conf`
- keep every tunable colour in `palette.conf`
- keep the bar layout in `status.conf`
- keep a setting out of a part that does not own its concern
- start a part with its path and a one-line scope note

ORDER
- declare load order in `PART_ORDER` inside `tmux/install.py`
- keep the declaration order equal to the reading order
- do not rely on directory listing order
- add a new part to the table instead of renaming an existing one

OUTPUT
- generate `tmux.conf` from the parts
- never edit the generated `tmux.conf` by hand
- mark the file as generated in its header
- quote a sourced path and escape `\`, `"`, `$`, and `~`
- source a part by absolute path after the parts are copied

COLOUR
- define a colour only as a `@` option in `palette.conf`
- read the option from `status.conf` instead of repeating a literal
- let colour reinforce a state and never carry the state alone

REFERENCES
- read `tmux/tmux.1` for commands, formats, and parsing syntax
- read `tmux-wiki` for the user guide and worked examples

---
