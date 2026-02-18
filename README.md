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
2. Copy environment defaults:

   ```bash
   cp .env.example .env
   ```

   If your music lives outside the repo, set `HOST_MUSIC_DIR` in `.env`
   (example on Windows: `HOST_MUSIC_DIR=Z:/subcastic/music`).

   Optional: for NAS setups, you can use the NFS override
   (`docker-compose.nfs.yml`) instead of mapped drives.

3. Place MP3 files in:

   `media/music/`

4. Start the stack:

   ```bash
   docker compose up -d
   ```

5. Open the stream:

   ```
   http://localhost:8000/radio.mp3
   ```

   LAN devices can use:

   ```
   http://<host-ip>:8000/radio.mp3
   ```

You should hear continuous playback.

### Configuration Notes (Phase 1)

- Pinned images are used (no `latest`):
   - `libretime/icecast:2.4.4`
  - `savonet/liquidsoap:14b6d14`
- Icecast config is mounted from `icecast/icecast.xml`.
- Liquidsoap playout script is mounted from `liquidsoap/radio.liq`.
- Music folder is mounted from `media/music/`.
- MP3 encoding uses Liquidsoap FFmpeg encoder path on the official `savonet/liquidsoap` image.

If you change passwords in `.env`, update `icecast/icecast.xml` to match source/admin/relay credentials.

### Optional: NAS via NFS

Docker Desktop on Windows may not reliably expose mapped network drives to containers.
Use the NFS override so Docker mounts the NAS export directly:

1. Set these in `.env`:
   - `NFS_SERVER_IP` (NAS IP)
   - `NFS_EXPORT_PATH` (NFS export path, e.g. `/volume1/music`)
   - `NFS_VERSION` (`4` by default)
2. Start with the NFS override:

```bash
docker compose -f docker-compose.yml -f docker-compose.nfs.yml up -d
```

3. Verify files are visible inside the container:

```bash
docker compose exec liquidsoap ls -la /media/music
```

On Synology, ensure NFS is enabled and the Docker host IP is allowed on the export.

### Shared Defaults vs Local Overrides

- Commit shared, portable defaults (`docker-compose.yml`, `.env.example`).
- Keep user/machine-specific values in `.env` (already ignored by git).
- For personal runtime tweaks, use local compose override files such as:
   - `docker-compose.local.yml`
   - `docker-compose.override.yml`
- Those local override filenames are git-ignored to prevent accidental commits.

### Minimal Verification

```bash
docker compose ps
docker compose logs -f icecast
docker compose logs -f liquidsoap
```

Expected behavior:
- Liquidsoap connects to Icecast and starts mount `/radio.mp3`.
- If `media/music` is empty, stream stays up and plays silence until files are added.

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

