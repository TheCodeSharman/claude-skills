---
name: fast-iteration
description: Run the project's real test / dev loop yourself, in-session, in a tight feedback loop — keeping a watch server or dev process warm to skip full rebuilds, filtering to the test under work at runtime, and doing visual checks where UI is involved. Use when iterating on code that needs the real runtime and you want fast feedback rather than a full cold build each time.
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Monitor
  - TaskStop
---

# Fast iteration loop

**You can run the real test/dev loop yourself, in-session, in a tight loop.** This is not a CI-only or human-only step. If you catch yourself thinking "I can't run this here," check first — a warm watch/dev server usually makes each rerun cheap, and you can drive it directly. Default to running the real thing over reasoning about it in your head.

The core idea: pay the full build cost **once**, then keep a watch mode / dev server / hot-reload process warm so subsequent iterations reload only what changed. Cold builds can take minutes; warm reruns often take seconds.

## When to reach for this

- Any time you write or touch a test and want to actually run it — this is the default loop, not an exceptional one.
- Iterating on code that needs the real runtime (framework, UI, device, browser) and wanting fast feedback.
- Visual/layout checks — "show me how X looks", "verify the new panel", worst-case stress checks ("seed 500 rows and see how it copes").
- Running *just one* test or scenario while iterating.

Skip when:

- The code under test is pure logic with no runtime/framework dependency — a plain unit runner is faster. See [tdd](../tdd/SKILL.md), "Which test layer".
- You need the full suite to gate a merge — run the real, clean build for that (see "Before you call it done").

## Keep the loop warm

Most stacks have a warm-reload path — a `--watch` test runner, a dev server with HMR, a `--reuse-server` / incremental-build flag. Find it once and lean on it:

- **First run** pays the full cost (compile, install, boot).
- **Subsequent runs** reload only the changed source.

Learn the two or three commands your project exposes for this and record them (in `CLAUDE.md` or a project skill) so you don't rediscover them each session.

## Filter at runtime, not by editing source

To run a single test, **filter by name at runtime** rather than editing the source:

- Prefer the runner's name filter (`--grep`, `-t`, `--name`, `-k`, `--filter`, tag selectors) over `it.only(...)`, `describe.only(...)`, `fdescribe`, `@only`, or skip-everything-else edits.
- Source edits to focus a run are an escape hatch, not the default — **they must be reverted before commit**, and it's easy to forget one.

```bash
# Illustrative — use your runner's actual flag
<test-command> --grep "the scenario I'm iterating on"
```

The runner still loads everything; the saving is in skipping non-matching tests at runtime, with zero source churn to undo.

## Visual checks (UI work)

When the change is visual, look at it — don't infer layout from code. Most UI runtimes expose a screenshot or UI-tree dump you can capture in-session:

- Keep a screen open (a manual/interactive mode, or a paused test) and grab a screenshot.
- Watch out for orientation/scale mismatches between how the runtime holds the screen and how the capture saves it — rotate/scale to upright once, then reuse that recipe.

This catches regressions a headless runner can't: clipped widgets, overflow past fixed bounds, and screens that silently broke when a shared style class changed.

## Common failure modes of warm/stateful loops

The price of skipping rebuilds is a long-lived process that can go stale. Recognise these:

- **Stale code running** — the warm server is serving an older build (often from a different platform/target). Force one fresh run *without* the reuse flag.
- **Zombie server holding the port** — a "reuse if present" flag only checks that *something* is listening, not that it's healthy. A stale process bound to the port but not responding makes runs look like they launch, then hang. Kill it (`kill $(lsof -ti:<port>)` or equivalent) and restart fresh.
- **Warm reuse works within a session but not across separate runs** — some servers go stale once their first client session ends; reusing them then leaves the next launch unable to fetch its code. If reruns fail at the *first* step every time, stop reusing: kill and start fresh each run.
- **The runtime accumulates cruft over many runs** — simulators, emulators, and long-lived browsers collect session/permission state. A clean reset (erase/reset the runtime, clear caches) fixes "it passed earlier and now fails at boot for no code reason."
- **Server returns an error page instead of code** — a dev server that hit an internal error may serve HTML where the client expects JS/assets, and the client hangs evaluating it. Request the specific asset directly (`curl` it) to see the real error.

When in doubt with a misbehaving warm loop: kill the server, drop the reuse flag for one run, and read the full fresh output.

## Before you call it done

The warm loop can paper over things a clean build would catch. Before marking work ready:

- Run the relevant suite **without** the dev-time reuse/hot-reload path — a fresh, from-clean build against a real bundle.
- For merge-gating, run the full suite the way CI runs it, not the focused/filtered subset.

## See also

- [tdd](../tdd/SKILL.md) — choosing the cheapest layer and the red/green/refactor rhythm this loop serves.
- [troubleshooting](../troubleshooting/SKILL.md) — diagnosing when a run fails or hangs.
