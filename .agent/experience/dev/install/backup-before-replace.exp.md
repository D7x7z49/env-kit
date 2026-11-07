<!-- @path[.agent/experience/dev/install/backup-before-replace.exp.md] -->
<!-- NOTE: how a rerun stays safe when the target already exists -->

STEP.
- check whether the target exists before any write
- stop when the target exists but is not a directory
- build a backup name from the target name and a time stamp
- stop when the backup path already exists, instead of merging two backups
- copy the tree to the backup, or move the tree aside, before the install
- write a generated file to `<name>.tmp`, then replace the target with it
- copy part files with a merge mode so a rerun adds nothing twice
- print the backup path and the install path, and keep exit code `0`
- return exit code `1` with one message when a step fails

NOTE.
- evidence: `tmux/install.py` copies the config dir to `tmux.bak-<stamp>`
- evidence: it replaces `tmux.conf` through a temporary file
- evidence: `neovim/distro.sh` moves an existing config dir to `<dir>.bak.<epoch>` before a clone
- the python stamp carries microseconds, so two runs cannot collide
- the shell stamp uses epoch seconds and stays readable when sorted
- a backup is cheap because the target is small and text based
- a failed backup must stop the install, because the next write would destroy the previous state
- an install that reports its paths can be reversed by hand without reading the script

---
