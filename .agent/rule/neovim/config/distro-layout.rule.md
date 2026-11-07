<!-- @path[.agent/rule/neovim/config/distro-layout.rule.md] -->
<!-- isolation, registry, and install rules for the neovim distributions -->

ISOLATION
- give each distribution its own `NVIM_APPNAME`
- resolve its config directory from the xdg config home and the app name
- resolve data, state, and cache from the same app name
- keep no shared init file between distributions

REGISTRY
- register key, repo, display name, and app name in one table
- derive the alias from the key with the `nv-` prefix
- expose the alias through `NVIM_APPNAME=<app> nvim`
- keep the alias in `~/.bash_aliases` and skip it when present

INSTALL
- back up an existing config directory before a clone
- remove `.git` from a cloned starter config
- remove a directory only when it belongs to a registered app name
- report a missing distribution instead of creating one

SCOPE
- state the supported platform in the header
- keep a script self-contained for remote use
- keep the registry order free, and derive the listing from it

REFERENCES
- read `neovim/starting.txt` for `NVIM_APPNAME` and the xdg directories
- read `neovim/options.txt` for an option default or limit

---
