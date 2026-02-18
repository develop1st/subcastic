# Product Requirements Document (PRD)

## Product Name
AI Radio MVP – Foundational Broadcast Node

## Objective
Stand up a minimal, reproducible, self-hosted broadcast node capable of streaming a continuous radio feed sourced from a local media folder containing music files.

This MVP establishes the foundational infrastructure required for future expansion into:
- AI-generated segments
- Segment sharing
- Listener call-in automation
- Feed subscription and curation
- Monetization modules

The immediate goal is reliability and simplicity, not intelligence.

---

## Scope (MVP Phase 1)

The system must:
1. Run entirely via Docker.
2. Stream a continuous MP3 audio feed.
3. Source audio from a mounted local media folder.
4. Be accessible on the local network.
5. Require minimal manual configuration to operate.

The system does NOT yet need:
- AI generation
- Scheduling logic
- Feed ingestion
- Authentication
- Monetization
- Reverse proxy configuration
- Analytics

---

## Functional Requirements

### 1. Containerized Deployment

The system must include:
- docker-compose.yml
- Icecast service
- Liquidsoap service

Both services must:
- Restart automatically on failure
- Share a Docker network
- Be configurable via environment variables

---

### 2. Icecast Server

Icecast must:
- Expose port 8000
- Provide a mount point (e.g., /radio.mp3)
- Require source authentication
- Provide basic web status interface

Configuration must:
- Be externalized via mounted config file
- Allow easy password modification

---

### 3. Liquidsoap Playout Engine

Liquidsoap must:
- Read from /media/music
- Randomly rotate tracks
- Continuously loop without stopping
- Crossfade between tracks
- Output MP3 at 128kbps
- Connect to Icecast mount

It must:
- Tolerate empty folder gracefully (log warning)
- Reload playlist if folder contents change

---

### 4. Media Folder

Host machine must expose:
./media/music

Requirements:
- Supports mp3 files
- Can be modified while running
- New files picked up automatically

---

### 5. Network Accessibility

The stream must be playable via:
http://<host-ip>:8000/radio.mp3

It must work with:
- VLC
- Browser audio player
- curl test

---

## Non-Functional Requirements

### Reliability
- Stream must auto-recover from container restart
- No manual steps after docker compose up

### Performance
- Support minimum 50 concurrent LAN listeners

### Simplicity
- Entire system bootstraps with a single command:
  docker compose up -d

### Observability
- Logs must be visible via docker logs
- Liquidsoap log file mounted to host

---

## System Architecture (MVP)

Host Machine
│
├── Docker
│   ├── Icecast Container
│   └── Liquidsoap Container
│
└── /media/music (mounted volume)

Flow:
Music Folder → Liquidsoap → Icecast → Listeners

---

## Success Criteria

The MVP is considered complete when:

1. A user can clone the repo.
2. Place MP3 files in ./media/music.
3. Run docker compose up -d.
4. Visit http://localhost:8000/radio.mp3.
5. Hear continuous music playback.

---

## Future Phases (Not In Scope Yet)

Phase 2 – Scheduling
- Add jingles
- Add hourly structure
- Add request queue

Phase 3 – AI Generation
- Segment generator
- Dynamic insertion

Phase 4 – Feed & Syndication
- Segment feed ingestion
- Shareable segment spec

Phase 5 – Listener Interaction
- Call-in submission endpoint
- Moderation queue

Phase 6 – Monetization
- Ad insertion engine
- Sponsor management

---

## Risks

- Incorrect Icecast credentials blocking stream
- Audio codec mismatch
- Docker networking misconfiguration
- Folder permission issues

Mitigation:
- Provide example config
- Use pinned container versions
- Clear README

---

## Deliverables

Repository containing:
- docker-compose.yml
- icecast.xml
- radio.liq
- README.md
- media/music directory

---

## Definition of Done

The system runs for 24 hours continuously without:
- Stream drop
- Container crash
- Manual intervention

This establishes the foundation for procedural AI radio evolution.

