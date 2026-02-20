# External References

This document lists authoritative external documentation that AI agents and contributors should consult when implementing or extending Subcastic.

These references are intentionally minimal and version-scoped to avoid ambiguity and outdated examples.

---

## Liquidsoap (Pinned Image: savonet/liquidsoap:14b6d14)

Subcastic currently runs Liquidsoap from image `savonet/liquidsoap:14b6d14`
(runtime reports `2.4.3+git@14b6d1432`).

Target syntax/behavior for scripting should remain in the Liquidsoap 2.4 family.

Always prefer documentation from the `doc-dev` section for 2.4.x and avoid mixing examples from older 1.x or early 2.x versions unless explicitly requested.

### Core Documentation

Quick Start (Icecast + output basics)
https://www.liquidsoap.info/doc-dev/quick_start.html

Language Overview
https://www.liquidsoap.info/doc-dev/language.html

Full Reference
https://www.liquidsoap.info/doc-dev/reference.html

Request Sources (queues, dynamic inserts)
https://www.liquidsoap.info/doc-dev/request_sources.html

Scheduling (cron, time-based triggers)
https://www.liquidsoap.info/doc-dev/scheduling.html

### Optional Offline Reference

Liquidsoap Book (PDF)
https://www.liquidsoap.info/book/book.pdf

Use this if a stable offline snapshot of the documentation is required.

---

## Icecast (Pinned Image: libretime/icecast:2.4.4)

Subcastic currently runs Icecast image `libretime/icecast:2.4.4`.

Icecast configuration reference:
https://icecast.org/docs/icecast-2.4.1/config-file.html

Relaying documentation:
https://www.icecast.org/docs/icecast-trunk/relaying/

---

## Usage Guidelines for Agents

When generating or modifying Liquidsoap scripts:

1. Confirm syntax aligns with Liquidsoap 2.4.x.
2. Prefer documented operators over inferred patterns.
3. Avoid deprecated constructs unless explicitly required.
4. If uncertain about operator behavior, consult the Reference page first.

When modifying Icecast configuration:

1. Keep configuration minimal and explicit.
2. Avoid enabling public directory listing by default.
3. Preserve LAN-first assumptions unless instructed otherwise.

---

This file is intentionally concise. Expand only if a new external system becomes part of the core stack.

