---
name: write-docs
description: Guidance for adding to or updating a project's documentation. Load when the user asks to document something, or when you've just rediscovered a non-obvious pattern worth saving for the next session.
user-invocable: true
allowed-tools:
  - Read
  - Edit
  - Write
  - Grep
  - Glob
---

# Writing project documentation

A project's docs are its long-lived knowledge layer — the place where what
*this* session learned becomes findable by the next one, whether that's you, a
teammate, or an AI agent. This skill captures when to write something down,
where it goes, and how to write it so it stays useful.

## When to write something down

Ask: **"would the next session save time if it could find this?"**

Yes → write it down. Common triggers:

- A non-obvious pattern you had to reverse-engineer from existing code.
- A gotcha that just cost you 20 minutes — an undocumented flag, a platform
  difference, a build step that wasn't where you expected.
- A convention that isn't enforced by tooling and isn't obvious from one file
  alone (cross-file conventions, naming patterns, layout rules).
- A workaround whose *why* is non-obvious (e.g. "we wrap this in an extra
  container on platform X because the native control doesn't expose Y in our
  version").

No → keep it out of the docs. Examples:

- One-off bug fixes — the commit message is the right home.
- Anything derivable by reading the code or running `git log`.
- Conversation-only context ("we tried X, it didn't work, picked Y").
- A description of what the code *does* — names and tests express that.

The rule of thumb: **docs cover *why* and *how-to-use*, not *what*.**

## Where to put it

Match the granularity of the knowledge to the location:

- **One file per pattern, module, or concept** — a focused page for a single
  reusable idea. Link it from the docs index so it's discoverable.
- **A cross-cutting topic doc** — for things that span the codebase
  (installation, testing, coding style, release process). Update the relevant
  section of an existing doc rather than starting a new file when one already
  covers the topic.
- **A source-file comment** — only the *local* why: a hidden constraint, a
  workaround for a specific bug, a non-obvious invariant.

The seam to remember: **architectural narrative goes in the docs, not in
source headers.** If a comment runs more than a couple of lines explaining
*why this pattern exists* or *how this module fits the design*, it belongs in a
doc. Leave a one-line pointer in the source:

```js
// see docs/<topic>.md "<section>"
```

Reasons: code-level comments rot when the design moves; long blocks bury the
actual code; and the same explanation usually applies to several files, so a
doc lets it live in one place.

## How to write it

**Short and specific beats long and generic.** A one-liner with a code example
is almost always the right length. If you're writing more than a screen, you're
probably capturing too much in one page — split it.

Structure each page:

1. **One-sentence purpose** at the top. The reader should know within 10
   seconds whether this page is what they need.
2. **The smallest concrete example.** A five-line snippet, an actual file path,
   a real command. Abstract prose can't pin a pattern down.
3. **The why.** One paragraph, max. If it needs more, you're documenting
   architecture, not a pattern — split, or move it to a dedicated design doc.
4. **Cross-links.** Link to neighbouring docs and to the real source files that
   demonstrate the pattern.

Voice: present-tense, second-person, declarative. *"Pass `--verbose` to see the
full output."* — not *"You may wish to consider passing the `--verbose` flag,
which has the effect of showing the full output."*

## Keep the index thin

Most projects have one file that's loaded or read first — a top-level `README`,
a `CLAUDE.md`, a docs `index`. Its job is to be a **thin set of pointers**, not
to carry the prose:

- New top-level topic → add a one-line link from the index.
- New page under an existing section (e.g. a patterns folder) → link it from
  that section's own index, not the top-level one. The section index is the
  right entry point.
- Expanding an existing doc → no index change needed.

Keep each index entry to one line: the path plus a ~10-word description of
what's inside.

## What NOT to create

- **No README files scattered through subdirectories.** The top-level README
  and any deliberate section index are the only ones. Don't sprinkle a
  `README.md` into every folder.
- **No process logs, decision diaries, or roadmaps in the docs.** Those belong
  in your issue tracker, commit messages, or PR descriptions, where they have a
  natural decay path.
- **No private or opaque identifiers** (ticket numbers, internal URLs) in docs
  that outlive the task or that outside readers might see. They're meaningless
  to later readers and rot silently. Describe the change or constraint itself;
  leave tracking to commits and PRs.
- **No long-form architecture in source files.** Source comments are for the
  local *why* only.

## See also

- [tdd](../tdd/SKILL.md), [troubleshooting](../troubleshooting/SKILL.md),
  [fast-iteration](../fast-iteration/SKILL.md) — the sibling skills; document
  the non-obvious patterns those surface.
