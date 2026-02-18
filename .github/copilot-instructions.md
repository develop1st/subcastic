# Copilot Instructions (Repository-Level)

## Purpose
This repository implements a modular, containerized radio platform that begins as a simple self-hosted stream (Icecast + Liquidsoap) and evolves in phases toward AI-generated procedural segments, segment sharing, and listener interaction.

This document defines how AI coding agents (Copilot/Codex) should behave when planning and making changes.

## Source of Truth
1) Product requirements live in `docs/prd/`.
- Always treat the current PRD phase as the authoritative scope boundary.

2) Architecture notes and technical design live in `docs/architecture/`.

3) This file governs agent behavior, repo conventions, and guardrails.

Never invent scope beyond the active PRD phase unless the user explicitly asks.

## Repo Structure
Keep this structure stable unless explicitly instructed to refactor.

- `docker-compose.yml` : Service orchestration
- `icecast/` : Icecast configuration (e.g., `icecast.xml`)
- `liquidsoap/` : Liquidsoap scripts (e.g., `radio.liq`)
- `media/` : Mounted media directories (e.g., `media/music`, `media/jingles`, `media/generated`)
- `state/` : Writable runtime state/logs (mounted volumes)
- `docs/` : Documentation
  - `docs/prd/` : Product requirements (phase definitions)
  - `docs/architecture/` : Architecture and system design
  - `docs/adr/` : Architecture Decision Records (optional, as added)
- `.github/` : GitHub automation + agent instructions (this file)

Do NOT place product documentation inside `.github/`.
Do NOT create or modify files in `.vscode/`.

## Development Philosophy
The project evolves in phases. Implement only what is required to satisfy the current phase’s acceptance criteria.

- Phase 1: Minimal continuous radio feed (folder-based music playback)
- Phase 2: Scheduling + jingles + insert queue foundation
- Phase 3: AI-generated segments and dynamic insertion
- Phase 4: Segment feeds + syndication
- Phase 5: Listener interaction (call-in style submissions)
- Phase 6: Monetization modules

Avoid pre-implementing future phases or adding speculative abstractions.

## Planning Mode Requirements
When asked to plan:
- Read the relevant PRD in `docs/prd/`.
- Propose a step-by-step implementation plan.
- Explicitly list files to create/modify.
- Call out assumptions and risks.
- Do not write implementation until the plan is approved.

## Implementation Constraints
### Containers
- Prefer pinned image versions (avoid `latest` unless explicitly requested).
- Use `restart: unless-stopped`.
- Expose the minimum required ports.
- Use environment variables for secrets/config where practical.
- Mount configs as files and runtime logs/state as volumes.

### Liquidsoap
- Keep Liquidsoap focused on playout and stream output.
- Prefer simple, stable scripts.
- Do not embed heavy feed ingestion logic inside Liquidsoap; instead, introduce a separate sidecar/service when needed.

### Icecast
- Keep config minimal and explicit.
- Do not enable public listing or internet exposure by default.
- LAN-first by default; reverse proxy support comes later.

## Change Discipline
When making changes:
- Prefer minimal viable implementation.
- Avoid unnecessary dependencies.
- Update `README.md` when behavior or setup changes.
- Keep diffs small and logically grouped.
- Add comments only when they clarify non-obvious intent.

If uncertain, ask the user rather than inventing architecture.

## Non-Goals (Unless Explicitly Requested)
Do not implement:
- Authentication/SSO
- Monetization/ads
- Federation/discovery network
- Real-time UI dashboards
- Complex observability stacks

## Logging and Observability
- Ensure services log to stdout/stderr for `docker logs`.
- Fail loudly and clearly on misconfiguration.
- Prefer simple health checks when helpful.

## Security Hygiene
- Never commit real secrets.
- Use placeholder credentials in example configs.
- Prefer `.env` for local overrides if introduced.

## Definition of Done Mindset
For each phase, work backward from acceptance criteria in the PRD.
The goal is an operationally stable foundation before adding intelligence and network features.
