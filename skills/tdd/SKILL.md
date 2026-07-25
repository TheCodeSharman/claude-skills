---
name: tdd
description: Test-driven development discipline — every behavioural change starts with a failing test at the cheapest layer that meaningfully exercises it, followed by a real refactor pass. Load for any development work. Skip only for non-behavioural edits like typos, formatting, or comment-only changes.
user-invocable: true
allowed-tools:
  - Read
  - Edit
  - Write
  - Bash
  - Grep
  - Glob
---

# Test-first development

Every behavioural change starts with a failing test.

## TDD rhythm

1. Pick the smallest behavioural change you can make next.
2. Write a *single* failing test that pins that behaviour (**RED**). Run it; confirm it fails for the *right reason*.
3. Write the minimal production code to pass (**GREEN**).
4. Refactor with the test as a safety net (**REFACTOR**) — see [tidy](../tidy/SKILL.md) for what to look for. Refactor the test too if its structure has decayed. **Don't skip this step.** Green means the test passes, not that you're done — pause and look at the shape critically before moving on.
5. Repeat.

One observable behaviour per test. Multiple assertions in one test hide which behaviour broke.

## Test behaviour, not implementation

Assert on what an outside observer sees — returned values, rendered output, persisted state, what a downstream caller receives. Don't reach past the public surface.

```js
// Good — outcome the user / next caller sees
expect(result.status).to.equal("complete");
expect(viewModel.percent).to.equal(45);
expect(await repo.query({ kind: "sync" })).to.have.length(2);

// Bad — implementation details
expect(spy.calledWith(...))                 // a *call* happened, not an outcome
expect(obj._privateField).to.equal(...)     // private state
```

If a test breaks every time you rename or reorganise, it's coupled to structure, not behaviour. The same rule at higher layers reads: assert on visible output/state, not which method fired.

## Real collaborators, not mocks

Default to running real collaborators end-to-end. Mock only when the real thing is genuinely impractical:

- **Mock**: slow networks, third-party services, hardware/side effects, the system clock when timing actually matters.
- **Don't mock**: pure utilities, in-memory stores you can swap for a test instance (e.g. an isolated on-disk or in-memory database), other components under test.

If you reach for a stub, first check: can you swap in a real lightweight version? Can you inject a small in-memory *fake*? Only if both answers are no — and then keep the mock at the IO boundary, not in the middle of the domain.

## No hardcoded delays — poll for the actual state

A fixed `sleep(400)` (or `setTimeout(..., 400)`) is almost always wrong: it flakes on slow machines and wastes time when the state was ready in 20ms. Poll the actual condition instead, with a sane ceiling.

```js
// Wrong — arbitrary delay
await sleep(400);
expect(view.scrollOffset).to.be.greaterThan(0);

// Right — polls the actual condition (e.g. a waitFor(predicate, {timeout}) helper)
await waitFor(() => view.scrollOffset > 0);
expect(view.scrollOffset).to.be.greaterThan(0);
```

For events, prefer event-driven waits (wait-for-event / wait-for-selector helpers) over polling. If your test framework or codebase lacks a `waitFor`, write a small one — poll every ~50ms up to a ~5s ceiling and reject with a clear error.

## Hard-to-test code is a refactor signal

If a test needs a huge setup block, five mocks, exposed private fields, or a magic delay because there's no observable signal of "done" — **stop and refactor the production code first.** Pain in the test mirrors structural problems: tangled dependencies, hidden state, missing seams.

Moves that usually help:

- Constructor / dependency injection so the test can swap a collaborator.
- Extract a pure function from a method that mixes IO and logic.
- Return a value from a side-effecting method so the assertion is on the return, not internal state.
- Emit a domain event when "done" so the test can `await` it instead of polling.

If it's still hard *after* a sincere refactor attempt, flag it to the user before plastering over it with mocks.

## Don't skip refactor — especially on "small" tasks

The refactor phase needs a human-judgment beat: *"would this code surprise a reader in six months?"* The risk: when a task is framed as *quick / small / no biggy / just a…*, both sides silently treat tests-pass as done and skip the refactor pass. Structural debt bakes in.

A representative failure: a ~150-line parser written "in one shot, no biggy" — RED and GREEN followed, tests passed, shipped, refactor silently skipped. It mixed parsing and domain concerns, leaked low-level details into the domain layer, swallowed missing inputs with silent fallbacks, and tested no error states. Days later it took ~25 cleanup commits to bring up to standard — short enough that the rewrite was still cheap, long enough that "should we tidy this now?" had stopped being asked.

When you hear *"quick" / "no biggy" / "just a"* framing on non-trivial code, treat it as a stop sign:

- Name it back: *"the 'quick' framing usually means refactor gets skipped — want to start with one failing test and stop after green to look at the shape?"*
- Suggest the minimum first step rather than the whole shape.
- After each green, prompt explicitly to look at the code shape *before* moving to the next test.

## Which test layer

Use the cheapest layer that meaningfully exercises the change:

- **Unit** — pure logic, no framework/runtime/IO dependency. Sub-second feedback. Most defects belong here.
- **Integration / component** — needs the framework, a real store, or wired-up collaborators. Slower; use when the behaviour only exists once things are connected.
- **Acceptance / end-to-end** — cross-cutting flows that map to a *business requirement*; keep them readable as behaviour, not mechanism. Slowest; use sparingly for the flows that matter most.

Prefer the lowest layer over a heavier one whenever it can genuinely observe the behaviour — never drop to a slower layer just to dodge wiring up the fast one. When in doubt, the lowest layer that can observe the bug.

## See also

- [troubleshooting](../troubleshooting/SKILL.md) — reproducing a defect as a failing test before fixing.
- [fast-iteration](../fast-iteration/SKILL.md) — running these tests in a tight feedback loop.
