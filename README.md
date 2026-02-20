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

**Phase 2 – Scheduling + Jingles + Insert Queue Foundation**

Goal: Keep continuous playback while adding lightweight structure for jingles and insert/commercial playback.

No AI generation.
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

   Optional for Phase 2:
   - `media/jingles/` for jingle tracks
   - `media/inserts/` for commercials/inserts

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

### Configuration Notes (Phase 2)

- Pinned images are used (no `latest`):
   - `libretime/icecast:2.4.4`
  - `savonet/liquidsoap:14b6d14`
- Icecast config is mounted from `icecast/icecast.xml`.
- Liquidsoap playout script is mounted from `liquidsoap/radio.liq`.
- Music folder is mounted from `media/music/`.
- Jingles folder is mounted from `media/jingles/`.
- Inserts/commercials folder is mounted from `media/inserts/`.
- MP3 encoding uses Liquidsoap FFmpeg encoder path on the official `savonet/liquidsoap` image.
- Insert queue foundation is provided via Liquidsoap `request.queue`.

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

### Development Test Media (10–15s snippets)

For faster iteration on transitions/rotation, generate short clips into a local ignored folder:

```powershell
./scripts/generate-test-media.ps1 -SnippetSeconds 15
```

By default, the helper now generates multiple snippets per source track (`-SnippetsPerSource 3`) with varied start offsets across each file.

This creates snippet sources under:

- `./.local/test-media/music`
- `./.local/test-media/jingles`
- `./.local/test-media/inserts`

Then run the stack with test-media source overrides:

```bash
docker compose -f docker-compose.test-media.yml up -d
```

Notes:
- `./.local/test-media/**` is git-ignored.
- The helper uses local `ffmpeg` if installed; otherwise it falls back to Dockerized ffmpeg.
- Default snippet length is `15` seconds; you can adjust with `-SnippetSeconds` (allowed range: 10-15).
- Tune output density with `-SnippetsPerSource`, `-MaxMusicFiles`, `-MaxJingleFiles`, and `-MaxInsertFiles`.
- Docker fallback reads source media from `docker-compose.yml` + `docker-compose.local.yml` by default (override with `-SourceComposeFiles`).

### Dynamic Insert Queue

Inserts are now driven by a Liquidsoap request queue (`insert_queue`) instead of a random insert playlist lane.

Queue command server access:
- Liquidsoap exposes a local-only command port on `127.0.0.1:${LIQ_SERVER_PORT}` (default `1234`).

Enqueue an insert item:

```powershell
./scripts/enqueue-insert.ps1 -Uri /media/inserts/0001-rsi-spacewear-s01.mp3
```

Notes:
- URIs are resolved inside the Liquidsoap container context.
- For test media mode, use paths under `/media/inserts`.
- For local/NAS mode, use paths visible at the configured `LIQ_INSERTS_DIR` mount.

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
- With no jingles/inserts available, stream continues with music-only fallback.

### Phase 2 Acceptance Checks

Run these checks after startup:

```bash
docker compose ps
docker compose logs --tail=120 icecast
docker compose logs --tail=120 liquidsoap
curl -v http://localhost:8000/radio.mp3 --max-time 10 -o /dev/null
```

Pass criteria:
- `icecast` and `liquidsoap` containers are `Up`.
- Liquidsoap logs show successful connection to Icecast mount `/radio.mp3`.
- Stream request returns `HTTP 200` and `Content-Type: audio/mpeg`.
- Audio is audible from at least one client (browser or VLC).
- When jingles/inserts are present, metadata/logs show lane rotation without stream drop.

### Phase 2 Closeout Checklist

- [ ] `docker compose up -d` bootstraps a working stream without manual edits.
- [ ] Music in `media/music` (or configured host/NFS mount) plays continuously.
- [ ] Jingles in `media/jingles` are inserted during normal playback.
- [ ] Inserts/commercials in `media/inserts` are eligible for insertion.
- [ ] Stream is reachable on LAN via `http://<host-ip>:8000/radio.mp3`.
- [ ] Container restarts recover stream automatically (`restart: unless-stopped`).
- [ ] Logs are available through `docker compose logs` for both services.
- [ ] 24-hour soak test completes without stream drop or container crash.

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

