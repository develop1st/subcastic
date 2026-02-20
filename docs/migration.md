# Migration Guide: Broadcast-First to Segment-First

## Why This Migration Exists

Subcastic is moving from a shared broadcast mount architecture (Icecast + Liquidsoap) to per-user stream assembly over HTTP.

This migration is a product-level paradigm shift, not a cosmetic refactor.

## Legacy Snapshot

The pre-migration Liquidsoap-first baseline is preserved on branch:
- `legacy/liquidsoap-master`

All migration and forward work should continue from:
- `feat/segment-http-migration` (or descendants)

## Core Architectural Direction

Subcastic core runtime must now be:
1. segment model
2. feed model
3. follow graph
4. personal stream engine
5. playback API (`GET /stream/:user_id`)

Core must function with no required dependency on Icecast/Liquidsoap.

## Explicit Deprecations

Deprecated as required runtime components:
- Liquidsoap scripts as primary playout runtime
- Icecast server config as primary delivery runtime
- station-centric language that assumes a shared global mount
- tight coupling between content generation and real-time mixing

Deprecated does not mean immediate deletion.
Legacy modules are retained and isolated for compatibility/export adapters.

## Required Separation of Concerns

Contributors must keep these boundaries explicit:

1. Content Storage
   - segment metadata and feed/follow data
   - object storage-backed audio URLs

2. Stream Assembly Logic
   - deterministic ordering from followed feeds
   - stateless compute service behavior

3. Playback Delivery
   - HTTP API queue responses
   - optional HLS generation
   - static object/CDN delivery for audio payloads

## MVP Constraints During Migration

In scope:
- pre-rendered segments only
- deterministic queue assembly and ordering
- reliable HTTP playback queue contract

Out of scope:
- procedural/TTS generation
- advanced reputation/trust logic
- monetization features

## Contributor Checklist

Before merging migration-related work:
- [ ] Segment/feed/follow models are explicit and documented.
- [ ] `GET /stream/:user_id` contract is implemented or updated consistently.
- [ ] No new core dependency on mount-based streaming daemons is introduced.
- [ ] Docs describe Icecast/Liquidsoap as optional compatibility layers.
- [ ] Storage, assembly, and delivery responsibilities remain modular.

## Existing Legacy Assets

Legacy runtime assets currently retained in-repo:
- `docker-compose.yml` and overrides
- `icecast/`
- `liquidsoap/`
- related helper scripts

These may be adapted into optional broadcast export tooling, but are no longer the core architecture.

## Documentation Map

- Core architecture diagram: `docs/architecture/segment-native-architecture.md`
- Domain models: `docs/architecture/domain-models.md`
- Product requirements: `docs/prd/ai-radio-mvp-prd.md`
- Repository overview: `README.md`
