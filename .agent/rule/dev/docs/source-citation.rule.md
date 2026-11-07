<!-- @path[.agent/rule/dev/docs/source-citation.rule.md] -->
<!-- citation rules for external facts in code comments and rules -->

WHEN
- cite when a path, default, or limit comes from an external standard or manual
- cite when the code ignores part of a standard, such as a relative xdg path
- keep one citation next to the claim it supports
- skip a citation for an obvious local choice

FORM
- cite a manual page as `man <section> <name>`, for example `man 7 environ`
- cite a cached document by source and route, for example `xdg-basedir/basedir-spec.xml`
- cite a web source as an angle-bracket link
- prefer the primary standard or the upstream manual over a blog post
- keep the citation on the claim line or the line above
- keep the comment lowercase like the rest of the code

CACHE
- add a source with `apiscope add`, then load it with `apiscope sync`
- inspect a source with `apiscope view <source> --depth 1`
- confirm the wording with `apiscope read <source>/<route>`
- state the spec version or the page date when the wording matters
- recheck a citation after a cache sync

SOURCES
- read `xdg-basedir/basedir-spec.xml` for base directory rules
- read `fhs/fhs.xml` for the filesystem hierarchy
- read `systemd-man/file-hierarchy.xml` for the systemd view of the hierarchy
- read `man-pages/man7/environ.7` for the process environment
- read `man-pages/man7/standards.7` for the standards a page follows
- read `systemd-man/environment.d.xml` for user environment files
- read `tmux/tmux.1` for tmux commands and formats
- read `neovim/options.txt` for neovim options

---
