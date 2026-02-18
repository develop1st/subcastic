# Subcastic

Subcastic is a modular, containerized self-hosted radio platform built on Icecast and Liquidsoap.

Subcastic (substream + broadcast + fantastic) is evolving into a programmable, AI-native broadcast system.

The project begins as a minimal continuous music stream and evolves toward an AI‑driven, programmable broadcast system with:

- Procedural AI-generated segments
- Segment sharing and syndication
- Listener call-in style participation
- Monetization modules

This repository is structured for phased development and AI-assisted implementation using GPT‑5.3‑Codex / Copilot.

---

## Current Phase

**Phase 1 – Minimal Continuous Radio Feed**

Goal: Stand up a Dockerized Icecast + Liquidsoap stack that streams music from a local media folder.

No AI generation.
No scheduling.
No federation.

Just a stable, always-on stream.

---

## Quick Start (Phase 1)

1. Clone the repository.
2. Place MP3 files in:

   `media/music/`

3. Start the stack:

   ```bash
   docker compose up -d
   ```

4. Open the stream:

   ```
   http://localhost:8000/radio.mp3
   ```

You should hear continuous playback.

---

## Repository Structure

```
.
├── docker-compose.yml
├── icecast/
├── liquidsoap/
├── media/
├── state/
├── docs/
│   ├── prd/
│   ├── architecture/
│   └── adr/
└── .github/
```

### Key Directories

- `icecast/` – Icecast configuration
- `liquidsoap/` – Liquidsoap playout scripts
- `media/` – Music and generated audio
- `docs/prd/` – Product requirements
- `.github/copilot-instructions.md` – AI agent guardrails

---

## Development Workflow

This project is designed for structured AI-assisted development.

When implementing changes:

1. Update or reference the appropriate PRD in `docs/prd/`.
2. Use planning mode before coding.
3. Keep changes scoped to the active phase.

---

## Roadmap

- Phase 1: Continuous folder-based music stream
- Phase 2: Scheduling + jingles
- Phase 3: AI-generated segments
- Phase 4: Segment feeds + syndication
- Phase 5: Listener interaction
- Phase 6: Monetization

---

## License

TBD

