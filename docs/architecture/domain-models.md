# Domain Models (Segment-First Core)

## Purpose

This document formalizes Subcastic core entities for the migration MVP.

## Segment

```json
{
  "segment_id": "seg_01J...",
  "feed_id": "feed_01J...",
  "publisher_id": "pub_01J...",
  "audio_url": "https://cdn.example.com/audio/seg_01J.mp3",
  "duration": 42.5,
  "created_at": "2026-02-20T18:30:00Z",
  "metadata": {
    "title": "Daily Science Brief",
    "description": "3-minute roundup of science headlines.",
    "tags": ["science", "news"]
  },
  "provenance": {
    "hash": "sha256:...",
    "signature": "ed25519:...",
    "license": "CC-BY-4.0"
  }
}
```

### Required
- `segment_id`
- `feed_id`
- `publisher_id`
- `audio_url`
- `duration`
- `created_at`
- `metadata.title`

### Optional
- `metadata.description`
- `metadata.tags`
- `provenance.hash`
- `provenance.signature`
- `provenance.license`

## Feed

```json
{
  "feed_id": "feed_01J...",
  "publisher_id": "pub_01J...",
  "name": "Science Daily",
  "description": "Short daily science updates.",
  "type": "creator",
  "segment_ids": ["seg_01J...", "seg_01K..."]
}
```

### Required
- `feed_id`
- `publisher_id`
- `name`
- `type`
- ordered `segment_ids`

### Allowed `type`
- `creator`
- `curator`
- `programmatic`

## Follow

```json
{
  "user_id": "user_01J...",
  "followed_feed_ids": ["feed_01J...", "feed_01K..."],
  "weights": {
    "feed_01J...": 1.0,
    "feed_01K...": 0.7
  }
}
```

### Required
- `user_id`
- `followed_feed_ids`

### Optional
- per-feed `weights`

## Personal Stream Request/Response

### Request

`GET /stream/:user_id`

### Response (v1)

```json
{
  "user_id": "user_01J...",
  "generated_at": "2026-02-20T18:31:00Z",
  "queue": [
    {
      "segment_id": "seg_01J...",
      "feed_id": "feed_01J...",
      "audio_url": "https://cdn.example.com/audio/seg_01J.mp3",
      "duration": 42.5,
      "metadata": {
        "title": "Daily Science Brief",
        "description": "3-minute roundup of science headlines.",
        "tags": ["science", "news"]
      }
    }
  ]
}
```

## Ordering Policy (MVP)

The stream engine must apply deterministic ordering from followed feeds based on:
1. freshness (newer segments first within feed windows)
2. diversity (avoid long runs from same feed)
3. fairness (ensure all followed feeds can appear)

No personalization beyond follows and optional weights is required for MVP.
