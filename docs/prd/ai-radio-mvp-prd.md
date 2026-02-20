# Product Requirements Document (PRD)

## Product Name
Subcastic MVP – Segment-Native Personalized Continuous Audio

## Objective
Deliver a minimal, reproducible, segment-first platform that assembles a continuous listening queue per user over HTTP.

The MVP establishes the core architecture for:
- segment publishing
- feed composition
- user follows
- deterministic personal stream assembly

The immediate goal is reliability and clarity of architecture, not advanced generation intelligence.

---

## Scope (Migration MVP)

The system must:
1. Treat pre-rendered segments as the atomic unit.
2. Organize segments into feeds.
3. Allow users to follow feeds.
4. Compute an ordered queue of segments per user.
5. Expose playback data over HTTP via `GET /stream/:user_id`.

The system must function without Icecast/Liquidsoap in the critical path.

The system does NOT yet need:
- procedural/TTS segment generation
- advanced reputation or trust systems
- monetization logic
- complex social/discovery features
- real-time server-side audio mixing as a required core feature

---

## Functional Requirements

### 1. Segment Model

A segment must include:
- `segment_id`
- `feed_id`
- `publisher_id`
- `audio_url`
- `duration`
- `created_at`
- `metadata` (`title`, `description`, `tags`)

Optional provenance fields:
- `hash`
- `signature`
- `license`

### 2. Feed Model

A feed must include:
- `feed_id`
- `publisher_id`
- ordered list of `segment_ids`
- feed metadata (`name`, `description`, `type`)

`type` values for MVP:
- `creator`
- `curator`
- `programmatic`

### 3. Follow System

Follow data must include:
- `user_id`
- `followed_feed_ids`

Optional:
- per-feed weight/priority

### 4. Personal Stream Engine

Input:
- `user_id`

Processing requirements:
1. Fetch user followed feeds.
2. Retrieve recent/unplayed segments from those feeds.
3. Apply deterministic ordering rules for freshness, diversity, and fairness.
4. Return an ordered queue of segment objects.

Output:
- JSON-serializable segment queue

### 5. Playback API

Required endpoint:
- `GET /stream/:user_id`

Response:
- JSON payload containing ordered segment queue

Optional extension (not required for MVP completion):
- server-side per-user HLS playlist generation

---

## Non-Functional Requirements

### Reliability
- Queue assembly is deterministic for identical inputs.
- API fails clearly on invalid user/feed/segment references.

### Scalability
- Stream assembly is stateless compute.
- Audio delivery is static object delivery and CDN-friendly.

### Simplicity
- Keep implementation modular with clear seams:
  - content storage
  - stream assembly logic
  - playback delivery API

### Observability
- Core services log to stdout/stderr.
- Misconfiguration and missing data fail loudly and clearly.

---

## System Architecture (MVP)

Primary flow:
Publisher Segments → Feed Ordering → User Follows → Personal Stream Engine → `/stream/:user_id` JSON Queue → Client Playback via Segment URLs

Infrastructure shape:
- stateless HTTP API tier
- segment metadata store
- object storage for audio files
- optional CDN for segment assets

Legacy broadcast runtimes (Icecast/Liquidsoap) may remain only as optional export adapters.

---

## Success Criteria

The migration MVP is complete when:

1. Segment, feed, and follow models are formalized in-repo.
2. Personal stream engine algorithm is documented and deterministic.
3. `GET /stream/:user_id` contract is defined and testable.
4. Documentation clearly states Icecast/Liquidsoap are not required core runtime.
5. Architecture explicitly separates storage, assembly, and delivery.

---

## Future Phases (Not In Scope Yet)

Phase 2 – Runtime Hardening
- caching strategies
- queue pagination and replay state

Phase 3 – AI Segment Creation
- procedural/TTS generation pipelines
- moderation and provenance controls

Phase 4 – Syndication
- feed sharing and external ingestion/export

Phase 5 – Listener Interaction
- submission flows and moderation queues

Phase 6 – Monetization
- sponsor placement and revenue modules

---

## Risks

- Overfitting stream ordering rules too early
- Coupling queue assembly with storage specifics
- Leaving legacy broadcast assumptions in core docs/code

Mitigation:
- deterministic, minimal queue policy first
- strict separation of interfaces between modules
- explicit deprecation/compatibility boundaries for legacy runtime

---

## Deliverables

Repository artifacts must include:
- updated architecture docs and diagram
- migration notes for contributors
- formal domain models for segment/feed/follow/stream
- explicit legacy runtime deprecation posture

---

## Definition of Done

Subcastic is unambiguously presented and implemented as a segment-first personalized HTTP playback platform.

Legacy broadcast tooling is isolated as optional compatibility infrastructure, not core runtime.

