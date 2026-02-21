# Subcastic

Subcastic is a segment-based personalized audio platform, not a broadcast station engine.

The platform assembles a continuous listening experience per user over HTTP by ordering pre-rendered audio segments from followed feeds.

## Migration Status

The legacy broadcast runtime (Icecast + Liquidsoap) has been removed from this branch because it is preserved in `legacy/liquidsoap-master`.

Active implementation on this branch is now a JavaScript monorepo focused on the segment-first HTTP architecture.

## Monorepo Layout

```text
apps/
  api/      # Node HTTP API stub (`GET /health`, `GET /stream/:user_id`)
  web/      # React app stub for playback UX
docs/       # Product and architecture references
packages/
  shared/   # Cross-app shared constants and types (stub)
```

## Getting Started

### Prerequisites

- Node.js 20+
- npm 10+

### Install

```bash
npm install
```

### Run API

```bash
npm run dev:api
```

API defaults to `http://localhost:3001`.

### Run Web App

```bash
npm run dev:web
```

Web app defaults to `http://localhost:5173` (Vite dev server).

Web app fetches and renders the API queue directly from the browser. Default demo users:
- `user_123` (multi-feed round-robin queue)
- `user_news_only` (single-feed queue)

## API Stub Contract

### `GET /health`

Returns:

```json
{ "status": "ok" }
```

### `GET /stream/:user_id`

Optional query params:
- `limit` (1-50, default 10)

Returns a deterministic stub queue shaped like the migration target contract:

```json
{
  "user_id": "user_123",
  "generated_at": "2026-01-01T00:00:00.000Z",
  "queue": [
    {
      "segment_id": "seg_001",
      "feed_id": "feed_news",
      "publisher_id": "pub_daily",
      "audio_url": "https://cdn.example.com/audio/seg_001.mp3",
      "duration": 42,
      "created_at": "2026-01-01T00:00:00.000Z",
      "metadata": {
        "title": "Morning Brief",
        "description": "Stub segment for stream API bootstrapping.",
        "tags": ["news", "mvp"]
      }
    }
  ]
}
```

## Reference Docs

- `docs/migration.md`
- `docs/architecture/segment-native-architecture.md`
- `docs/architecture/domain-models.md`
- `docs/prd/ai-radio-mvp-prd.md`
