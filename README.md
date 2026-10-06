# agent-skills

Personal [Agent Skills](https://agentskills.io) for Claude (home) and GitHub Copilot (work):
R (from [awesome-rstats-skills](https://github.com/christopherkenny/awesome-rstats-skills)), Rust, PostgreSQL, SQL Server, and Docker.

## Layout

| Path | What |
|---|---|
| `sources.tsv` | Every upstream skill: repo, pinned commit, path, local name, flags. Edit this, not `skills/`. |
| `skills/` | Synced upstream skills plus skills maintained here (`tsql-conventions`). |
| `scripts/sync.sh` | Pulls `sources.tsv` into `skills/`. `--update` moves all pins to upstream HEAD. |
| `scripts/install.sh` | Symlinks `skills/*` into `~/.claude/skills` and `~/.agents/skills` (or dirs you pass). |
| `SKILLS.md` | Generated index: every skill, where it came from (pinned link), license, description. |
| `TODO.md` | Planned additions and custom skills to write. |
| `scripts/validate.sh` | Checks frontmatter, names, duplicates. Runs in CI. |
| `.claude-plugin/marketplace.json` | Generated; lets Claude Code install this repo as a plugin marketplace. |

Each synced skill has `UPSTREAM.md` (source + commit) and `LICENSE.upstream`.

## New machine

```bash
git clone https://github.com/<you>/agent-skills && cd agent-skills
./scripts/sync.sh        # restores the local-only skills too
./scripts/install.sh
```

Update: `git pull && ./scripts/sync.sh && ./scripts/install.sh`
Bump upstream versions: `./scripts/sync.sh --update`, review the diff, commit.

### Other install routes
- Claude Code: `/plugin marketplace add <you>/agent-skills`, then install `all-skills`.
- GitHub CLI: `gh skill install <you>/agent-skills --all --agent claude-code --scope user`
- VS Code / Copilot (work): clone anywhere, then add the clone's `skills` folder to the
  `chat.agentSkillsLocations` setting. No symlinks needed, works on Windows.
- claude.ai: publish a GitHub release; CI attaches one zip per skill to upload.

## Local-only skills
`cran-submit` (CoryMcCartan) has no license file, so `sync.sh` fetches it onto each machine
but `.gitignore` keeps it out of this repo. The `jeremy-allen/claude-skills` also have no license
file but are committed with the author's OK.
Routes that read only from GitHub (marketplace, `gh skill install`) won't include it.

## Notes on the R list
- `review-r` is patched on sync to bundle the reviewer protocol and conventions it expects
  from its home repo.
- `event-studies` is synced as `event-study` (upstream uses lowercase `skill.md`).
- ab604's `r-package-development` is renamed `r-package-development-ab604` to avoid clashing with Posit's.
- Not included: `api2r/pkgskills` is a per-package R installer (use `pkgskills` inside each R
  package project instead); `blankuzr/R-Skills` is no longer public.
