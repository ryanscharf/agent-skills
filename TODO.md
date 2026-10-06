# TODO

## Upstream skills to add to sources.tsv
- [ ] `github-actions-hardening` (github/awesome-copilot, `skills/github-actions-hardening`): security review of the GHCR docker-build workflows
- [ ] `github-actions-templates` (wshobson/agents, `plugins/cicd-automation/skills/github-actions-templates`): test-before-build, layer caching
- [ ] `postgres-ops` (0xdarkmatter/claude-mods, `skills/postgres-ops`): self-hosted admin: backups/PITR, vacuum, pooling, LISTEN/NOTIFY

## Skills to write (nothing suitable upstream)
- [ ] `r-docker-service`: rocker/r-ver + pak, sysdeps, Chrome for webshot2, cron in container, .env, GHCR workflow (usl-gplus-bot, tb_sun, Scratchoff, mirai-docker)
- [ ] `r-extendr`: rextendr::document(), Makevars/MSRV, vendoring for CRAN, wrapper sync (rookier)
- [ ] `r-scraping-httr2`: httr2 retries/throttling, user agent, rookier cookies, caching, detecting layout changes before bad writes (tb_sun, Scratchoff, stats-dumpy; Rust side in madi-bot)
- [ ] `gt-social-cards`: gt → PNG via webshot2 for Bluesky, sizing, fonts in headless Chrome, alt text (usl-gplus-bot)
- [ ] `r-torch-simulation` (optional): vectorized Monte Carlo, device handling, CPU/GPU reproducibility (tb_sun playoff model)

## Per-repo AGENTS.md (project context, not skills)
- [ ] tb_sun: build from roster_change_detection_postgres_discord.md
- [ ] madi-bot: how it consumes the roster_events NOTIFY pipeline; pick sqlx or tokio-postgres; remove committed .vs/
- [ ] mirai-docker: rename CLAUDE.md -> AGENTS.md so Copilot reads it too

## Pruning to consider
- [ ] Comment out skills unlikely to fit this work: event-study, r-analyst, Posit open-source maintainer skills
