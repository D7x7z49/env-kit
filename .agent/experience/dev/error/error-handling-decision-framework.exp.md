<!-- @path[.agent/experience/dev/error/error-handling-decision-framework.exp.md] -->
<!-- NOTE: choose the right time to catch, wrap, clean up, or propagate an error -->

STEP.
- evaluate recovery, translation, cleanup, and the user boundary in this order for every fallible step
- catch and correct an error when the current function can recover safely and completely
- catch and wrap an error when it crosses a module or domain boundary and the wrapper adds context
- use `try/finally` or a context manager when cleanup must run on both success and failure
- catch an expected domain error at the interaction boundary when the program must report it and stop
- let the error propagate when none of these conditions holds
- let a low-level module raise or re-raise without user output or process exit
- translate an error only when the receiving layer uses a different vocabulary
- keep the original cause with `raise ... from ...` when wrapping an error
- fail fast when an invalid state could produce a corrupted, partial, or misleading result

NOTE.
- do not catch an error only to rethrow it unchanged
- do not catch an error only to replace it with a less specific message
- do not catch before the layer that owns the recovery or the report decision
- do not catch the same failure at several layers unless each layer makes a new decision
- avoid nested wrappers that repeat the same context and bury the root cause
- do not catch `Exception` broadly unless the boundary has a deliberate policy for it
- keep reusable logic free of user output and process termination
- report an expected failure with a short and actionable message at the user boundary
- keep an unexpected programming error visible for debugging
- name the operation, the object, and the safe correction in a message
- never expose a credential, private data, or a sensitive response body in a message
- use `finally` or a context manager for a file, a lock, a connection, and a temporary resource
- never discard a cleanup failure or the original failure silently, and chain both when both matter
- never return an empty success value, an unrelated default, or a partial result after a failure
- verify that error handling leaves no silent failure, zombie state, or hidden data corruption

---
