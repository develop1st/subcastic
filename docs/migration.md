You are updating the Subcastic repository to reflect a major architectural migration.

Context:

Subcastic is no longer built around Icecast + Liquidsoap as the primary runtime model. Historically, we treated the system as a broadcast-style continuous audio stream, where Liquidsoap orchestrated audio and Icecast exposed mount points. That paradigm is being deprecated as the default architecture.

We are migrating to a segment-native, HTTP-based, per-user stream assembly model aligned with the “Personalized Continuous Audio” vision described in Overview.md :contentReference[oaicite:0]{index=0}.

This is not a minor refactor. It is a paradigm shift.

The new paradigm:

1) Segments are the atomic unit.
   - A segment is a pre-rendered audio file (e.g., MP3) plus metadata.
   - Feeds are ordered collections of segments.
   - Users follow feeds.
   - A personal stream is computed per user by assembling segments from followed feeds.

2) Playback is HTTP-based, not mount-based.
   - No global broadcast mount as the core experience.
   - No per-station Liquidsoap mixing as the primary mechanism.
   - The client consumes a dynamically assembled queue of segment URLs (HLS or progressive HTTP).
   - The server is responsible for queue assembly, ordering, and metadata.

3) Icecast/Liquidsoap are no longer core dependencies.
   - Remove them from the critical path.
   - If retained, they become optional compatibility/export layers (e.g., rendering a curator feed as a public 24/7 stream).
   - The system must function fully without them.

Repository changes required:

A) Remove or deprecate:
   - Liquidsoap scripts as required runtime components.
   - Icecast configuration as required infrastructure.
   - Any “station” abstraction that assumes a shared broadcast mount as the primary product.
   - Tight coupling between content generation and real-time audio mixing.

B) Introduce or formalize:

   1. Segment model
      - segment_id
      - feed_id
      - publisher_id
      - audio_url
      - duration
      - created_at
      - metadata (title, description, tags)
      - optional provenance fields (hash, signature, license)

   2. Feed model
      - feed_id
      - publisher_id
      - ordered list of segment_ids
      - feed metadata (name, description, type: creator/curator/programmatic)

   3. Follow system
      - user_id
      - followed_feed_ids
      - optional weight or priority

   4. Personal Stream Engine (core service)
      - Input: user_id
      - Fetch followed feeds
      - Retrieve recent/unplayed segments
      - Apply ordering rules (freshness, diversity, fairness)
      - Output: ordered queue of segment objects

   5. Playback API
      - GET /stream/:user_id
        Returns JSON queue of segments (v1).
      - Optional: server-side HLS playlist generation per user.
      - No continuous mount required.

C) Update documentation:

   - Rewrite README to describe the new architecture:
     “Subcastic is a segment-based personalized audio platform, not a broadcast station engine.”
   - Add a section explaining the migration away from Icecast/Liquidsoap.
   - Clearly separate:
       - Core: segments, feeds, personal stream engine.
       - Optional: broadcast export adapters.

D) Infrastructure:

   - Remove infrastructure assumptions that require:
       - persistent streaming daemon
       - mount-based distribution
   - Replace with:
       - stateless HTTP API
       - object storage for audio (e.g., S3-compatible)
       - CDN-friendly delivery
   - Ensure the system is horizontally scalable:
       - Stream assembly is compute.
       - Audio delivery is static object serving.

E) MVP Constraints:

   - Only support pre-rendered segments initially.
   - Do not implement procedural/TTS rendering in this migration.
   - Do not implement advanced reputation logic yet.
   - Focus on deterministic queue assembly and reliable playback.

F) Codebase goals:

   - Make “segment” the central abstraction.
   - Make “feed” the subscription boundary.
   - Make “personal stream assembly” the core differentiator.
   - Remove station-centric language where it conflicts with the new model.
   - Keep architecture modular so a broadcast adapter can be layered later.

Deliverables from this update:

1. Updated architecture diagram (in docs).
2. Refactored domain models reflecting segment/feed/stream.
3. Removal or deprecation of Liquidsoap/Icecast from required runtime.
4. Clear migration notes for contributors.
5. Clean separation between:
   - Content storage
   - Stream assembly logic
   - Playback delivery

Important:

Do not simply delete old code blindly. Mark deprecated modules clearly and isolate them. The goal is to evolve the system from “broadcast-first” to “segment-first, user-assembled streaming.”

The resulting repository should make it obvious that Subcastic’s core innovation is per-user continuous audio assembled from segments over HTTP, not real-time server-side mixing.

Prioritize clarity of architecture over feature completeness.