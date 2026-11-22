#!/usr/bin/env python3
# @path[scripts/ci/check-agent-files.py]
# check `.agent` layout, names, line budgets, and file formats.
#
# usage:
#   uv run --no-env-file --locked python scripts/ci/check-agent-files.py
#
# exit codes:
#   0 all files pass
#   1 one or more files fail

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
AGENT = ROOT / ".agent"
MAP = AGENT / "AGENTS.md"

ROOT_ENTRIES = {"AGENTS.md", "experience", "rule", "skill"}
CORE_DIRS = ("experience", "rule", "skill")
SKILL_DIRS = ("references", "scripts")
SKILL_ENTRY = "SKILL.md"

EXPERIENCE_SUFFIXES = (".exp.md",)
RULE_SUFFIXES = (".rule.md", ".ebnf")

SCOPE = re.compile(r"^[A-Z][A-Z ]*$")
KEBAB = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")

DIR_WORDS = (1, 3)
FILE_WORDS = (2, 5)

BUDGETS = {
    "rule": (8, 48),
    "experience": (8, 48),
    "grammar": (0, 300),
    "skill": (20, 80),
    "payload": (0, 300),
}

MAP_BUDGET = 128

PROBLEMS: list[str] = []
WARNINGS: list[str] = []
CHECKED: list[Path] = []
FAILED: set[Path] = set()


# ==============================================================================
# REPORTING
# ==============================================================================


def relative(path: Path) -> Path:
    try:
        return path.relative_to(ROOT)
    except ValueError:
        return path


def fail(path: Path, text: str) -> None:
    FAILED.add(path)
    PROBLEMS.append(f"fail {relative(path)}: {text}")


def warn(path: Path, text: str) -> None:
    WARNINGS.append(f"warn {relative(path)}: {text}")


# ==============================================================================
# FORMAT
# ==============================================================================


def load(path: Path) -> list[str]:
    text = path.read_text(encoding="utf-8")
    if not text.endswith("\n") or text.endswith("\n\n"):
        raise ValueError("file must end with exactly one newline")
    if "\t" in text:
        raise ValueError("file must not contain a tab")
    return text.splitlines()


def check_header(lines: list[str], kind: str) -> None:
    if not lines:
        raise ValueError("file is empty")
    if not lines[0].startswith("<!-- @path[") or not lines[0].endswith("] -->"):
        raise ValueError("line 1 must be a path comment")
    if kind == "rule" and (len(lines) < 2 or not lines[1].startswith("<!--")):
        raise ValueError("line 2 must be a description comment")


def check_rule(lines: list[str]) -> None:
    if lines[-1] != "---":
        raise ValueError("last line must be `---`")
    if len(lines) < 3 or lines[2] != "":
        raise ValueError("expected a blank line after the header")

    index = 3
    seen = 0
    while index < len(lines) - 1:
        if lines[index] == "":
            index += 1
            continue
        if not SCOPE.match(lines[index]):
            raise ValueError(f"line {index + 1}: bad scope label")
        seen += 1
        index += 1
        while index < len(lines) and lines[index].startswith("- "):
            index += 1
        if index < len(lines) and lines[index] != "":
            raise ValueError(f"line {index + 1}: a list item must start with `- `")
    if seen == 0:
        raise ValueError("file has no scope")


def check_experience(lines: list[str]) -> None:
    if lines[-1] != "---":
        raise ValueError("last line must be `---`")
    if lines.count("STEP.") != 1:
        raise ValueError("experience must have exactly one `STEP.` section")
    steps = lines.index("STEP.")
    if steps + 1 >= len(lines) or not lines[steps + 1].startswith("- "):
        raise ValueError("`STEP.` must be followed by a list")


def check_ebnf(lines: list[str]) -> None:
    if not lines or not lines[0].startswith("(*") or not lines[0].endswith("*)"):
        raise ValueError("line 1 must be a path comment")
    if not any("ebnf subset version: 1" in line for line in lines):
        raise ValueError("missing `ebnf subset version: 1`")


def check_budget(kind: str, path: Path, count: int) -> None:
    low, high = BUDGETS[kind]
    if count < low or count > high:
        warn(path, f"{kind} file must have {low} to {high} lines, got {count}")


def check_file(path: Path, kind: str) -> None:
    CHECKED.append(path)
    try:
        lines = load(path)
        if kind == "experience":
            check_header(lines, "experience")
            check_experience(lines)
        elif kind == "rule":
            check_header(lines, "rule")
            check_rule(lines)
        elif kind == "grammar":
            check_ebnf(lines)
    except ValueError as exc:
        fail(path, str(exc))
        return
    check_budget(kind, path, len(lines))


# ==============================================================================
# LAYOUT
# ==============================================================================


def check_name(path: Path, stem: str, words: tuple[int, int], what: str) -> bool:
    if not KEBAB.fullmatch(stem):
        fail(path, f"{what} name must use lower-case kebab-case")
        return False
    low, high = words
    count = len(stem.split("-"))
    if not low <= count <= high:
        fail(path, f"{what} name must have {low} to {high} words, got {count}")
        return False
    return True


def check_payload(base: Path) -> None:
    for path in sorted(base.rglob("*")):
        if path.is_symlink():
            fail(path, "symlink is not allowed")
        elif path.is_file():
            check_file(path, "payload")


def check_skill(directory: Path) -> None:
    if not check_name(directory, directory.name, FILE_WORDS, "skill"):
        return
    entry = directory / SKILL_ENTRY
    if entry.is_symlink() or not entry.is_file():
        fail(directory, f"skill directory must hold {SKILL_ENTRY}")
    else:
        check_file(entry, "skill")
    for path in sorted(directory.iterdir()):
        if path.name == SKILL_ENTRY:
            continue
        if path.is_symlink():
            fail(path, "symlink is not allowed")
        elif path.is_dir() and path.name in SKILL_DIRS:
            check_payload(path)
        else:
            fail(path, f"a skill holds only {SKILL_ENTRY}, scripts, and references")


def check_flat(core: str, aspect: Path) -> None:
    suffixes = EXPERIENCE_SUFFIXES if core == "experience" else RULE_SUFFIXES
    for path in sorted(aspect.iterdir()):
        if path.is_symlink():
            fail(path, "symlink is not allowed")
            continue
        if path.is_dir():
            fail(path, "subdirectories are not allowed at the aspect level")
            continue

        suffix = next((item for item in suffixes if path.name.endswith(item)), None)
        if suffix is None:
            allowed = " or ".join(suffixes)
            fail(path, f"{core} file must end with {allowed}")
            continue

        kind = "experience" if core == "experience" else "rule"
        if suffix == ".ebnf":
            kind = "grammar"
        stem = path.name.removesuffix(suffix)
        if check_name(path, stem, FILE_WORDS, f"{core} file"):
            check_file(path, kind)


def check_aspect(core: str, aspect: Path) -> None:
    if not check_name(aspect, aspect.name, DIR_WORDS, "directory"):
        return
    if core != "skill":
        check_flat(core, aspect)
        return
    for path in sorted(aspect.iterdir()):
        if path.is_symlink():
            fail(path, "symlink is not allowed")
        elif path.is_dir():
            check_skill(path)
        else:
            fail(path, "only a skill directory is allowed at the aspect level")


def check_target(core: str, target: Path) -> None:
    if not check_name(target, target.name, DIR_WORDS, "directory"):
        return
    for aspect in sorted(target.iterdir()):
        if aspect.is_symlink():
            fail(aspect, "symlink is not allowed")
        elif aspect.is_dir():
            check_aspect(core, aspect)
        else:
            fail(aspect, "only an aspect directory is allowed at the target level")


def check_tree() -> None:
    for entry in sorted(AGENT.iterdir()):
        if entry.name not in ROOT_ENTRIES:
            fail(entry, "unexpected root entry")
    for core in CORE_DIRS:
        base = AGENT / core
        if base.is_symlink() or not base.is_dir():
            fail(base, "core directory is missing")
            continue
        for target in sorted(base.iterdir()):
            if target.is_symlink():
                fail(target, "symlink is not allowed")
            elif target.is_dir():
                check_target(core, target)
            else:
                fail(target, "only a target directory is allowed at the core level")


def check_map() -> None:
    CHECKED.append(MAP)
    if not MAP.is_file():
        fail(MAP, "map file is missing")
        return
    try:
        count = len(load(MAP))
    except ValueError as exc:
        fail(MAP, str(exc))
        return
    if count > MAP_BUDGET:
        fail(MAP, f"file must have at most {MAP_BUDGET} lines, got {count}")
    print(f"ok   {relative(MAP)} lines: {count}")


# ==============================================================================
# COMMAND LINE
# ==============================================================================


def main() -> int:
    check_tree()
    check_map()

    for path in CHECKED:
        if path not in FAILED and path != MAP:
            print(f"ok   {relative(path)}")
    for line in WARNINGS:
        print(line)
    for line in PROBLEMS:
        print(line)

    if PROBLEMS:
        print(f"{len(PROBLEMS)} problem(s) in `.agent`")
        return 1
    print(f"{len(CHECKED)} file(s) checked in `.agent`")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
