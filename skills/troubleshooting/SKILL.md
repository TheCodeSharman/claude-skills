---
name: troubleshooting
description: Diagnose a defect — a user-reported bug, a failing or hanging test, unexpected runtime behaviour, or a production crash. Enforces diagnostics-first discipline (gather logs, state, and reproduction before forming a hypothesis) and the habit of reproducing a bug as a failing test before fixing it. Load whenever the next move is "figure out what's wrong" rather than "build the next thing".
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
---

# Troubleshooting

## The discipline: collect before you guess

The biggest failure mode is hypothesising before the evidence is in hand. A premature guess narrows the search: you head down one branch while a single log line would have pointed at the answer, and confirmation bias then pulls every new observation toward the guess and away from the truth.

**Always, in this order:**

1. **Capture the actual report verbatim** — the failing assertion, stack trace, and stderr; or, for a user report, their exact words plus environment (version, platform, device), plus the steps that reproduce it.
2. **Pull the runtime evidence** that matches the layer that's broken — application logs, server logs, browser console, network traces, a crash dump, a screenshot of the broken state.
3. **If the failure is visual, layout, or timing related, capture that state directly** — a screenshot, a DOM/UI-tree dump, a recording.
4. **Only now form hypotheses** — aim for **2–3 distinct candidates ranked by likelihood**, not one. One hypothesis is how the rabbit-hole starts. (Escape valve: if steps 1–3 already make a single cause unambiguous, skip to the fix.)
5. **Design a discriminating experiment** — a single check whose result tells you *which* candidate is right, or that none are. Prefer reading specific code or making one targeted observation over an edit-and-see-what-happens loop.

If you catch yourself typing "I bet the issue is…" before step 3 is done, stop and finish the diagnostics. If you have only one hypothesis at step 4, generate the next two before testing.

## Snapshots are not tapes

A persisted artefact captured *after* the fact — a diagnostic dump, an exported state file, a "download logs" bundle — is a **snapshot at the moment it was taken**, not a recording of everything that happened. It will routinely miss transient, in-flight corruption that lives in the seconds between one action and the next.

Two complementary paths when a snapshot doesn't cover the window you care about:

1. **Find a continuous/eager capture for the same window** — anything that records events as they happen regardless of when the user asked for a dump (server-side request logs, an APM/observability backend, a network capture). These are usually **time-bound** — free tiers and rolling buffers expire — so act while the window is still retained.
2. **Ask for a re-capture with controlled timing** — when you suspect a *specific* moment (e.g. "between save and the next sync"), ask the reporter to capture diagnostics *at that exact instant*. The original dump's timing was driven by the reporter's mental model of where the bug is; if that model was off, the dump's coverage is off too.

Both beat guessing. Before settling on any hypothesis, ask: **"What moment does this evidence actually cover?"**

## When the bug is user-reported (no failing test yet)

1. Capture the report verbatim and pull all available evidence.
2. **Reproduce it as a failing test first, before fixing.** Write the failing test at the smallest layer that exhibits the bug. A useful move: write a handful of RED tests spanning the layers you suspect, run them, and watch *which* fails — the failing one names the layer.
3. The RED test becomes the lock against regression and the artefact you ship. See [tdd](../tdd/SKILL.md).
4. *Then* fix. Re-run; the test goes green. Commit the RED test and the fix as separate commits for a clean red→green history (or together if the scope is tiny).

## When the bug surfaces as a test failure

- **Read the full failing assertion and stack trace verbatim.** File paths and line numbers point at real code — most defects need no extra logging.
- **Passes in isolation but fails in the suite** → shared-state leak. Re-run the failing test alone, then inspect global/module state that earlier tests mutated.
- **Hangs** → the previous test or setup likely left the system in a state this one doesn't expect. Look at the prior test's teardown and this test's setup. Stale connections, un-reset singletons, and partially-completed background work are common culprits.
- **The build/tooling fails before any test runs** → get the *real* error first. Force a clean rebuild (drop any incremental/cache/reuse flags) so the underlying failure surfaces instead of a stale-cache symptom.

## Common red herrings

- **"It worked yesterday"** → first suspect: stale build or cached artefacts serving old code. Force one clean rebuild before going deeper.
- **`Connection refused` / port already in use** → a zombie dev server holding the port but no longer responding. Kill it and restart fresh; don't trust "something is listening" as "it's healthy."
- **Random intermittent failures** → almost always a race or a hardcoded delay. Replace fixed sleeps with polling on the actual condition (see [tdd](../tdd/SKILL.md), "No hardcoded delays").
- **"The assertion is right but the test shouldn't fail"** → re-read the assertion. You've probably misremembered what the code under test does. Re-derive the expected value from the source, not from intent.
- **The reporter's evidence shows the "wrong" state** → their mental model steered the capture. The bug may live in a window the snapshot doesn't cover — fall back to a continuous capture or a timed re-capture.

## When diagnostics don't show the cause

After steps 1–3, if the cause still isn't obvious:

- **Re-read the test setup.** The bug is more often in the fixture, mock, or seed data than in the code under test.
- **Look at what's *missing* from the logs.** A milestone you expect but don't see means the code never got there — that gap localises the fault.
- **Diff against a passing run** of an adjacent, similar case. The difference is usually the cause.
- **Diagnose from both ends of every state transition, not just the suspected one.** A bug that looks like it's on the read/download side is often really on the write/save side. Checking both ends prevents anchoring on the first piece of evidence in hand.
- **Then escalate.** Tell the user what you've checked and what you found *before* going on a long expedition.

## See also

- [tdd](../tdd/SKILL.md) — turning a reproduction into a regression-locking test.
- [fast-iteration](../fast-iteration/SKILL.md) — running that test in a tight loop while you diagnose.
