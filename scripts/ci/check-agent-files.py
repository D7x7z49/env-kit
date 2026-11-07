#!/usr/bin/env python3
# @path[scripts/ci/check-agent-files.py]
# check `.agent` rule, experience, and ebnf files against the local formats.
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
SCOPE = re.compile(r"^[A-Z][A-Z ]*$")
LINE_BUDGET = 128


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


def check_file(path: Path) -> None:
    lines = load(path)
    if path.name.endswith(".rule.md"):
        check_header(lines, "rule")
        check_rule(lines)
    elif path.name.endswith(".exp.md"):
        check_header(lines, "experience")
        check_experience(lines)
    elif path.suffix == ".ebnf":
        check_ebnf(lines)


def main() -> int:
    failures = 0

    for path in sorted(AGENT.rglob("*")):
        if path.is_dir():
            continue
        rel = path.relative_to(ROOT)
        try:
            check_file(path)
            print(f"ok   {rel}")
        except ValueError as exc:
            failures += 1
            print(f"fail {rel}: {exc}")

    report = ROOT / "AGENTS.md"
    count = len(report.read_text(encoding="utf-8").splitlines())
    print(f"{'ok  ' if count <= LINE_BUDGET else 'fail'} AGENTS.md lines: {count}")
    if count > LINE_BUDGET:
        failures += 1

    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
