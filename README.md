# Subcastic

Subcastic is a segment-based personalized audio platform, not a broadcast station engine.

The platform assembles a continuous listening experience per user over HTTP by ordering pre-rendered audio segments from followed feeds.

## Architecture Status

Subcastic is migrating from a broadcast-first runtime (Icecast + Liquidsoap) to a segment-native, HTTP-based model.

- Core runtime target: segment storage + feed graph + personal stream assembly + playback API.
- Deprecated as required runtime: mount-centric always-on broadcast chain.
- Optional compatibility: export adapters that can render a feed to legacy broadcast surfaces.

The migration baseline has been preserved on branch `legacy/liquidsoap-master`.
All forward architecture work proceeds on the segment-native branch lineage.

## Core Concepts

### Segment

A segment is a pre-rendered audio object (for MVP, typically MP3) plus metadata.

Required fields:
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

### Feed

A feed is an ordered collection of segment references with publisher-level metadata.

Required fields:
- `feed_id`
- `publisher_id`
- ordered list of `segment_ids`
- feed metadata (`name`, `description`, `type`)

### Follow Graph

Users subscribe to feeds. The follow graph is the subscription boundary for stream assembly.

Required fields:
- `user_id`
- `followed_feed_ids`

Optional fields:
- per-feed weight/priority

### Personal Stream Engine

The stream engine computes ordered segment queues per user.

Input:
- `user_id`

Processing:
- fetch followed feeds
- retrieve recent/unplayed segments
- apply deterministic ordering rules (freshness, diversity, fairness)

Output:
- ordered queue of segment objects

### Playback API (v1)

- `GET /stream/:user_id`
  - returns a JSON queue of segment objects
  - no global mount required

Optional extension:
- server-side HLS playlist generation per user

## Infrastructure Direction

Core assumptions for migration:
- stateless HTTP API for stream assembly and playback responses
- object storage for segment audio (`audio_url`), S3-compatible where practical
- CDN-friendly static audio delivery
- horizontal scaling by separating compute (assembly) from media transfer (static object serving)

## MVP Constraints (Migration)

- Pre-rendered segments only
- No procedural/TTS generation in this migration
- No advanced reputation or trust scoring
- Prioritize deterministic queue assembly and reliable playback

## Repository Focus During Migration

- `docs/` defines product and architecture source of truth
- legacy Icecast/Liquidsoap assets remain isolated for compatibility and reference
- new work should center on segment/feed/stream abstractions

## Migration Notes

See `docs/migration.md` for contributor guidance on deprecations, boundaries, and implementation sequence.

## Legacy Runtime (Deprecated Core)

Legacy files remain in-repo for compatibility and controlled transition:
- `docker-compose.yml`
- `icecast/`
- `liquidsoap/`

These are no longer the required critical path for the product architecture.

## Development Workflow

When implementing changes:
1. Align with the active PRD in `docs/prd/`.
2. Keep architecture segment-first and user-assembled.
3. Preserve clear separation between storage, assembly, and delivery.

## License

TBD

