<!-- @path[.agent/experience/dev/docs/doc-sources.exp.md] -->
<!-- NOTE: which upstream documents this repo trusts, and why -->

STEP.
- list the facts this repo depends on outside its own code
- map each fact to the upstream manual or standard that owns it
- register that document as an apiscope source in the tracked project config
- sync a source before the first read
- cite the cached route next to the code or rule that depends on it
- refresh a source when a citation no longer matches the cache
- keep local settings, such as a proxy, in `.apiscope/local.json`

NOTE.
- evidence: `tmux/install.py` resolves xdg paths and ignores a relative override, as the base directory spec requires
- evidence: `neovim/distro.sh` and `neovim/nvim-vm.sh` place config, data, state, and cache under xdg base directories
- the xdg base directory spec owns the xdg behavior, and the fhs owns the fixed system directories
- the linux man-pages own the process and file conventions, and `environ.7` and `standards.7` are the usual entry points
- the systemd manuals own `environment.d`, `systemd.exec`, `systemd.service`, and `tmpfiles.d`
- the neovim runtime docs and the four distribution docs cover the installed editor setup
- the tmux manual and wiki cover the installed terminal setup
- `.apiscope/config.json` is the single source list, so a new machine gets it from the repo
- a spec changes slowly, so it carries a longer ttl than a project doc

---
