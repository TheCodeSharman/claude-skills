---
name: open-pr
description: Open a pull request with good hygiene — as a draft early, scoped to one responsibility, with a why-first summary and an honest test plan. Load when the user asks to open a PR, or after the first meaningful commits land on a feature branch.
user-invocable: true
allowed-tools:
  - Bash
  - Read
---

# Opening a pull request

Open as soon as the first *meaningful* commits land on the branch — early review beats a polished one-shot. The PR stays a **draft** while you push more commits, then goes ready-for-review when the checks are green.

## Pre-flight checks

1. **You're on a feature branch, not the default branch.** `git branch --show-current` should not be `main`/`master`. If it is, stop and branch first.
2. **Side-quest scan — one PR = one responsibility.** Run `git diff <base>...HEAD` and ask: *is every change something this task actually needs?* Drive-by fixes, unrelated refactors, and opportunistic cleanups should split onto their own branch **before** opening this PR. Up-front splits cost minutes; after-the-fact splits cost an hour of rebasing. (See [tidy](../tidy/SKILL.md), "in-scope vs drive-by".)
3. **At least one automated check passes** — the minimum bar. Run whatever applies (unit tests, lint, build). See [fast-iteration](../fast-iteration/SKILL.md) for running the real suite quickly.
4. **Staged changes are intentional.** `git status` shouldn't surprise you. Stage files by name; **avoid `git add -A`** — it sweeps in stray files and un-scoped edits.

## Gather inputs

Before calling `gh pr create` you need:

- A **title** that names the change — imperative, under ~70 characters.
- A **one-sentence scope** of *this* PR (which may be narrower than the whole task).
- **Summary bullets that lead with the *why*** — the diff already shows the *what*; the PR body's job is the reasoning and any context a reviewer can't infer.
- Any **linked issue / tracking reference**, if the project uses one.

If a title, scope, or issue link isn't already clear from the conversation, **ask** rather than guessing.

## Create the PR (draft)

```bash
gh pr create --draft --title "<imperative summary>" --body "$(cat <<'EOF'
## Summary
- <one bullet per meaningful change; lead with the why>
- <call out any drive-by changes so reviewers aren't surprised>

<One-sentence scope of this PR. Note any deferred work.>

## Test plan
- [x] <check that passes now, e.g. unit tests>
- [ ] <check still to run before ready-for-review>
- [ ] <manual / visual verification, if relevant>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Open as a **draft** by default — reviewers shouldn't get pinged until the test plan is green. Return the PR URL after creating it so the user can review.

## Marking ready-for-review

When the test plan is fully green:

1. Re-run the checklist honestly — uncheck, re-run, re-check. A stale green checkbox is worse than none.
2. `gh pr ready` — or click "Ready for review" in the GitHub UI.

## Notes

- Only open/push PRs when the user has asked — don't publish work outward on your own initiative.
- If the project has its own PR template or contribution guide, follow it; treat this skill as the baseline discipline, not an override.

## See also

- [tidy](../tidy/SKILL.md) — one-change-one-responsibility, splitting off drive-by cleanups.
- [fast-iteration](../fast-iteration/SKILL.md) — running the suite before you mark ready.
- [tdd](../tdd/SKILL.md) — the tests that back the test plan.
