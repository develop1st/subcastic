# Phase 2 Readiness (Scheduling + Jingles)

## Scope Boundary
Phase 2 adds scheduling foundations and jingles only.

In scope:
- Hourly structure foundation in Liquidsoap playout
- Jingle insertion behavior
- Basic insert queue foundation

Out of scope:
- AI-generated segments
- Feed ingestion/syndication
- Listener call-ins
- Monetization

## Implementation Targets
1. Keep `docker-compose.yml` service topology unchanged (Icecast + Liquidsoap only).
2. Extend `liquidsoap/radio.liq` with a minimal, deterministic structure for:
   - music source
   - jingle source
   - queueable inserts
3. Preserve current operational behavior:
   - stream remains continuous
   - empty optional sources fail gracefully
4. Keep configuration externalized through environment variables and mounted assets.

## Proposed Sequence
1. Add `media/jingles/` directory scaffold.
2. Add env vars for jingle source path and insertion cadence.
3. Introduce a simple jingle rotation source in Liquidsoap.
4. Add a minimal insert queue source (file-based or request-based foundation).
5. Define transition behavior so inserts/jingles do not break stream continuity.
6. Update README with Phase 2 runbook and verification steps.

## Acceptance Prep Checklist
- [ ] Music-only stream behavior remains stable.
- [ ] Jingles are audible at expected intervals.
- [ ] Insert queue can accept at least one queued item and play it.
- [ ] Logs clearly show source switches (music/jingle/insert).
- [ ] Restart recovery preserves service availability.

## Risks to Manage
- Overly complex Liquidsoap transitions causing dropouts.
- Queue design that is hard to evolve for Phase 3 dynamic insertion.
- Adding too many knobs and hurting Phase 2 simplicity.

## Design Guardrails
- Prefer straightforward Liquidsoap primitives over custom control logic.
- Keep state local and transparent.
- Do not add new services unless strictly required by Phase 2 acceptance.