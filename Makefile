# @path[Makefile]
# env-kit project tasks
# =====================
#
# common entry points for local work

.DEFAULT_GOAL := help

.PHONY: help install hooks setup lock lock-check fmt agent-check check clean

help:  ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

install:  ## install dependencies from the lockfile
	uv sync --locked

hooks: install  ## install the pre-commit git hooks
	uv run --no-env-file --locked pre-commit install

setup: hooks  ## install dependencies and the git hooks

lock:  ## update uv.lock
	uv lock

lock-check:  ## check that uv.lock is up to date
	uv lock --check

fmt:  ## format python and apply safe lint fixes
	uv run --no-env-file --locked ruff check --fix .
	uv run --no-env-file --locked ruff format .

agent-check:  ## check the .agent file formats
	uv run --no-env-file --locked python scripts/ci/check-agent-files.py

check: lock-check  ## run the full local check
	uv run --no-env-file --locked pre-commit run --all-files --show-diff-on-failure

clean:  ## remove the local virtualenv
	rm -rf .venv
