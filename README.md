# claude-skills

Portable, project-agnostic [Claude Code](https://claude.com/claude-code) skills, synced across machines.

Each skill is deliberately decoupled from any single project — no repo-specific
tooling, tickets, or file paths — so it applies to whatever you're working on.

## Skills

| Skill | What it's for |
|---|---|
| [`troubleshooting`](skills/troubleshooting/SKILL.md) | Diagnostics-first debugging: collect evidence before hypothesising, generate multiple candidates, reproduce as a failing test before fixing. |
| [`tdd`](skills/tdd/SKILL.md) | Test-first discipline: red → green → refactor, test behaviour not implementation, real collaborators over mocks, poll instead of sleeping, don't skip refactor. |
| [`fast-iteration`](skills/fast-iteration/SKILL.md) | Run the real test/dev loop yourself in a tight, warm feedback loop; filter at runtime not by editing source; visual checks; failure modes of long-lived dev servers. |

The three cross-reference each other via relative links.

## Install

Symlinks each skill folder into `~/.claude/skills/` (or `$CLAUDE_SKILLS_DIR`).
After install, `git pull` updates the live skills instantly — no re-install needed.

```bash
git clone https://github.com/TheCodeSharman/claude-skills.git
cd claude-skills
./install.sh
```

Machine-local skills placed directly in `~/.claude/skills/` coexist fine; the
installer only touches the folders it manages, and backs up any real directory
that collides with a skill name before symlinking.

## Adding or editing a skill

Edit the `SKILL.md` under `skills/<name>/`, commit, and push. Other machines
pick it up on their next `git pull`. New skills are installed by re-running
`./install.sh`.
