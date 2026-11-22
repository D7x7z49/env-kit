<!-- @path[.agent/experience/dev/decision/comment-scope.exp.md] -->
<!-- NOTE: comment only the knowledge that code cannot carry -->

STEP.
- treat a docstring as an interface document, not as a default comment
- prefer a single-line comment when the signature and the body already state the behavior
- comment only non-obvious intent, constraint, side effect, or invariant
- remove a comment that repeats a name, a parameter list, or a branch
- use a header comment for file scope and file rules
- use a block comment for a logical section
- use an inline comment for a local ambiguity
- keep the comment level proportional to the reader's need
- record an experience only when the lesson generalizes beyond one file

NOTE.
- a docstring can duplicate a signature and go stale with the code
- a comment that repeats code adds maintenance cost without adding knowledge
- a function name and a small body are often the clearest documentation
- a project may require a docstring when it exposes a public api or a generated reference
- keep the reason and the constraint near the code they govern
- evidence: `@path[...]` is metadata read by the header hook, so it stays

---
