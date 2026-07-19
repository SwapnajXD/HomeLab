# Postmortems & Build History

## Purpose

This document is the single, dated record of what was built, what broke, and how it was fixed across the Olympus HomeLab. It consolidates a large number of raw session notes and incident write-ups (Olympus Dashboard build, Athena network outage, K3s lab, media-pipeline incidents, network bring-up, and observability logging) into one deduplicated, chronological reference.

Each entry follows the same shape: **Date → What happened → What broke → Root cause → Fix → Status**.

---

# Timeline Summary

| Date(s) | Event | Status |
|---|---|---|
| 2026-06-11 → 06-22 | Olympus Dashboard: Hestia → Athena migration, FastAPI backend | ✅ Shipped (later reworked, see 06-18→27) |
| 2026-06-17 | Decision: Athena becomes backend, Hestia becomes presentation-only | ✅ Adopted |
| 2026-06-21 | K3s cluster stood up on Athena | ✅ Complete — still in use, no Traefik deployed |
| 2026-06-21 → 06-22 | Athena network/Tailscale outage | ✅ Resolved (transient, no config change) |
| 2026-06-21 | Olympus V2 build (wallpaper engine, LastFM, cron automation, MAL) | ⚠️ Complete at the time — decommissioned from deployment 2026-07-10, code retained in repo |
| 2026-06-18 → 06-27 | Full Olympus Command Center build **and rollback** of the custom Homepage widget | ✅ Widget code emptied; backend kept running (for now) |
| 2026-06-26 | LastFM + media pipeline incident (cron overlap, jq crashes, GitHub rate limiting) | ✅ Resolved (moot since 2026-07-10 — pipeline decommissioned from deployment) |
| 2026-06-30 | Apollo network bring-up: NAT, port forwarding, Vaultwarden TLS mismatch | ✅ Resolved |
| 2026-07-05 | Loki + Grafana Alloy centralized logging | ⚠️ Partially working at the time — Docker log discovery gap, resolved by 2026-07-18 |
| 2026-07-10 | Dashboard API decommissioned from deployment; Homepage reverted to stock+theme config | ✅ Complete — code retained in repo |
| 2026-07-18 | Apollo networking/firewall rework — root-caused interface bug, evaluated and declined `nftables`, shipped a dynamic firewall script | ✅ Complete |
| 2026-07-18 | Live infrastructure audit — reconciled documentation against real running systems on all three hosts | ✅ Complete |

**Note on the Dashboard's final status:** the raw notes originally contained two different endings for the Olympus Dashboard, since resolved. The custom Homepage widget's `custom.js` was emptied out on 2026-06-27 for being too fragile and tightly coupled to Homepage's internals (a separate, unrelated `custom.css` visual theme was later added/kept — purely cosmetic, no data logic). The FastAPI backend behind the original widget survived that round and stayed in use for a while — but as of **2026-07-10**, it was decommissioned from active deployment as well: the container was stopped and its fetch scripts/cron jobs were disabled. **The code itself was intentionally kept in the repository** (`docker-compose/dashboard-api/`, `scripts/fetch_*.sh`) rather than deleted — it's real, working engineering worth having visible, even though it's not part of the live deployment. Hestia's Homepage now runs stock (plus that unrelated theme), with no runtime backend dependency. K3s is unaffected and remains in active use. See the 2026-07-10 entry below and `changelog.md` (Phase 11) for details.

---

# 2026-06-11 → 2026-06-22 — Olympus Dashboard: Hestia → Athena Migration

**What happened:** The dashboard originally lived entirely on Hestia — local fetch scripts wrote JSON files that Homepage read directly. This tied data collection to the frontend machine, duplicated logic, and had no API layer.

**Decision (2026-06-17):** Athena becomes the backend/source of truth; Hestia becomes presentation-only.

**Built:** A FastAPI service (`athena/homelab/docker-compose/dashboard-api`) exposing `/pokemon`, `/lastfm`, `/library`, `/prices`, `/weather`, `/mal`, and an aggregate `/olympus` endpoint that became the frontend contract.

## What broke and how it was fixed

- **Prices schema mismatch** — `fetch_prices.sh` originally returned `{"goldbees": 122.12}` but the frontend expected `{"goldbees": {"name": ..., "price": ...}}`. Rewrote the script to emit the nested schema (`{"goldbees": {"name": "Nippon Gold BeES", "price": 119.83}, ...}`). **Fixed.**
- **Pokémon JSON parse errors** — after enriching the Pokémon payload with PokéAPI flavor text, the script began failing with `control characters must be escaped`. Root cause: flavor text contains raw newlines/tabs that break naive JSON construction. Fixed by sanitizing the text (`tr`/`sed`/`jq` escaping) before writing JSON. **Fixed.**
- **MAL (MyAnimeList) API lookup** — `curl` against `api.myanimelist.net/v2/users/StarLordXD` returned `not_found` even though the public profile page worked; likely a username/API mismatch. No fix applied yet — flagged as future work (Jikan API, scraping, or OAuth). **Open.**
- **Library data** — still placeholder/manually-edited JSON; automation not yet built. **Open.**

**Design pivot:** After seeing the layout, Pokémon was demoted from "the whole point of the dashboard" to just one possible media source. Olympus was reframed as a general **Personal Command Center** with a dynamic center panel (Pokémon, anime art, wallpaper, album art, movie poster, video loop).

**Status as of 2026-06-22:** Backend (Athena/FastAPI/`/olympus`) stable; Hestia cleaned of duplicate data-generation logic; single source of truth established.

---

# 2026-06-21 → 2026-06-22 — Athena Network / Tailscale Outage (Postmortem)

**Impact:** Athena appeared offline on the Tailnet from Artemis's perspective; Grafana, Prometheus, Loki, and the Dashboard API all looked unreachable.

## Investigation

1. **Console access via Proxmox** confirmed the Athena VM itself was running — ruled out crash/kernel panic/power failure.
2. **Local networking checked and healthy:** `ip addr` (10.10.10.10/24 on `ens18`), `ip route` (default via 10.10.10.1), netplan config all correct.
3. **LAN reachability confirmed:** ping to router (10.10.10.1) and Apollo (10.10.10.2) both succeeded — ruled out local networking/Proxmox bridge issues.
4. **Internet reachability failed:** `ping 8.8.8.8` and `curl https://1.1.1.1` / `https://google.com` all timed out.
5. **Tailscale reported:** "Unable to connect to the Tailscale coordination server" / "you are logged out" — this looked like a Tailscale failure but was reclassified as a **downstream symptom of the Internet outage**, not the root cause.
6. **Firewall (ufw) confirmed inactive** — not a local block.
7. **Recovery:** SSH to Athena over Tailscale eventually succeeded on its own; `tailscale status` showed all peers active again; `ping 8.8.8.8` returned 0% loss (~31ms); `curl -I https://google.com` returned HTTP/2 301.

## Root cause

Most likely a **transient upstream/ISP interruption** (Airtel WAN) or a temporary router forwarding/ARP-cache hiccup — everything recovered without any configuration change on Athena, Apollo, or Tailscale.

## What did *not* break

Apollo, Proxmox, the Athena VM, `vmbr0`, `ens18`, netplan config, routing, the firewall state, Docker networking, and the Tailscale configuration were all confirmed healthy throughout.

## Lesson learned — Connectivity troubleshooting ladder

When a node looks "offline," check in this order rather than assuming Tailscale is broken first:

1. Gateway — `ping 10.10.10.1`
2. Internet — `ping 8.8.8.8`
3. HTTPS — `curl -I https://google.com`
4. Tailscale — `tailscale status`
5. Peer reachability — `tailscale ping <peer>`

This isolates LAN vs. Internet vs. DNS vs. Tailscale failures quickly instead of chasing the wrong layer.

**Side note:** During the outage, Floci was evaluated as a LocalStack alternative (MIT-licensed, no auth tokens, Docker-backed Lambda/ECS/EKS/RDS/etc., lighter footprint) — it was later adopted (see `changelog.md` Phase 7).

**Status:** Resolved. No recurrence noted in later logs.

---

# 2026-06-21 — K3s Kubernetes Lab Stand-up

**Goal:** Run a K3s cluster on Athena, managed remotely from Artemis via `kubectl`.

## What broke and how it was fixed

- **Pods stuck in `ContainerCreating`** (coredns, local-path-provisioner, helm-install-traefik). Root cause: Ubuntu was still on **cgroup v1**; modern K3s/containerd expects **cgroup v2**. Fixed by adding `systemd.unified_cgroup_hierarchy=1` to `/etc/default/grub`, running `update-grub`, and rebooting. Verified via `stat -fc %T /sys/fs/cgroup` → `cgroup2fs`. **Fixed.**
- **Clean rebuild:** stopped k3s, removed `/var/lib/rancher/k3s`, restarted — cluster came back healthy with `local-path` as the default storage class.
- **Remote kubectl from Artemis — TLS certificate failure.** Kubeconfig was pointed at the Tailscale IP (`100.117.35.70`), but the API server certificate's SANs only covered `10.10.10.10`, `127.0.0.1`, and `10.43.0.1`. Fixed by pointing the kubeconfig at Athena's **LAN IP** (`10.10.10.10`) instead of the Tailscale IP, since that address is in the certificate. **Fixed** (no certificate regeneration needed).
- **`kubectl` not installed on Artemis** — installed it on the Arch laptop.
- **Kubeconfig permission denied** (`/etc/rancher/k3s/k3s.yaml` root-owned) — `chmod 644` as a workaround (later, `sudo kubectl` used where appropriate).
- **Namespace confusion** — a deployment created from Athena landed in `default`, while Artemis's context was `artemis-lab`, so `kubectl get all` on Artemis showed nothing. Fixed by confirming with `kubectl get deployments -A` and recreating the workload inside `artemis-lab`.
- **NodePort service `AlreadyExists`** — an old ClusterIP service already existed for the same deployment; deleted it and re-created as NodePort (`80:30246/TCP`), verified via `curl http://100.117.35.70:30246`.
- **Portainer/Kubernetes integration** — no need for a second Portainer install; the existing Portainer container on Apollo/Athena just needed the **Portainer Agent** installed inside K3s. Initial connection attempt failed because the endpoint field included `http://` — Portainer expects host:port only, without the protocol prefix. **Fixed.**

## Concepts validated along the way

- Self-healing: deleting pods under a Deployment/ReplicaSet triggers automatic recreation (desired-state reconciliation).
- Scaling: `kubectl scale --replicas=3` and deletion tests both worked as expected.
- Namespaces are genuinely isolated views of the same cluster (`default` vs `artemis-lab`).
- Portainer and `kubectl` operate on the same API — changes in one are immediately visible in the other.

## Final state (end of session)

- Ubuntu 20.04 + K3s + containerd + cgroup v2 on Athena.
- Running: CoreDNS, Local Path Provisioner, Metrics Server, Traefik (kept — useful for learning Ingress), Portainer Agent.
- `artemis-lab` namespace created and cleaned of test workloads, reserved for ongoing practice.
- Remote management from Artemis via `kubectl` fully functional, no SSH required for day-to-day cluster work.

**Status:** Complete and stable; K3s remains listed as operational in current architecture/inventory docs.

---

# 2026-06-21 — Olympus V2 Build Log (Wallpaper Engine, LastFM, Cron, MAL)

## Dynamic wallpaper engine

Built `fetch_media.sh` (curl/jq/shuf) to pull a random image from the `SwapnajXD/Walls` GitHub repo into `media.json` for the hero panel.

- **404s on wallpapers** — script built raw.githubusercontent URLs using `/main/`, but the repo's default branch was actually `master`. Fixed by correcting the branch name in the URL template. **Fixed.**

## LastFM integration

`fetch_lastfm.sh` pulls now-playing track/artist/album/cover into `lastfm.json`.

- **JSON corruption from quoted song titles** — a track title like `Aap Jaisa Koi - From "Qurbani"` broke a hand-built `cat <<EOF ... EOF` JSON heredoc. Fixed by replacing manual JSON construction with `jq -n --arg track "$TRACK" '{track:$track}'`, which escapes correctly. **Fixed.**

## Media priority logic

`fetch_media.sh` was updated so that when LastFM reports a currently-playing cover, the hero panel shows the album art (`mode: album`); otherwise it falls back to a random wallpaper (`mode: wallpaper`).

- **"Album cover not updating" bug** — the Now Playing widget updated but the hero image stayed on wallpaper. Root cause: `fetch_lastfm.sh` was being run manually without also running `fetch_media.sh`, so `media.json` went stale relative to `lastfm.json`. Fixed by creating `update_olympus.sh` to run all fetch scripts together. **Fixed.**

## Cron automation

- Discovered there was **no crontab at all** (`crontab -l` → "no crontab for ubuntu").
- First pass ran everything every 5 minutes; refined into per-source schedules:

  ```
  */1  * * * *  fetch_lastfm.sh
  */1  * * * *  fetch_media.sh
  */15 * * * *  fetch_weather.sh
  */30 * * * *  fetch_prices.sh
  0 */6 * * *   fetch_pokemon.sh
  0 */3 * * *   fetch_library.sh
  ```

## MyAnimeList (MAL) widget

- Added `anime.json` and a `/mal` FastAPI endpoint.
- **Docker cache confusion** — after editing the `/mal` endpoint code, the API kept returning the old static response. `docker restart` alone doesn't rebuild the image; needed `docker compose down && docker compose up -d --build`. **Fixed.**
- **Broken anime widget markup** — duplicate/unclosed `<div class="olympus-widget">` tags in the frontend template caused rendering failures. Rewrote the block with correct nesting. **Fixed.**

**Status:** All listed components (media hero, LastFM, weather, investments, Pokémon, library, anime, Dashboard API) working and scheduled as of this build.

---

# 2026-06-18 → 2026-06-27 — Homelab Development Log: Olympus Command Center (Build → Abandon Custom Widget → Cleanup)

This is the fullest end-to-end narrative and it ends differently from the two threads above — worth reading as its own record.

**Goal:** Turn Homepage into a live "Olympus" command center (music, weather, anime, reading, investments, dynamic hero media, homelab health) via a large custom `custom.js`/`custom.css` widget, backed by the Athena FastAPI aggregator.

## What broke and how it was fixed

- **Homelab health widget couldn't reach Hestia directly** — Hestia is an LXC and isn't a Tailscale node itself, so `ping hestia` from Athena failed with a DNS resolution error. Fixed by having Athena check **Apollo → Homepage** reachability instead of trying to reach Hestia directly (`curl http://apollo:3000`), which better reflected real service availability.
- **Widget rendered on desktop but was blank on mobile.** Debug logging showed `custom.js` loaded fine on both, but only desktop actually built the widget. Root cause: Homepage finished its own page setup before the custom script ran, and the widget assumed panels existed that weren't ready yet on faster mobile load timing. Fixed with an idempotent start-guard:

  ```javascript
  let olympusStarted = false;
  function startOlympus() {
    if (olympusStarted) return;
    olympusStarted = true;
    buildOlympus();
    setInterval(buildOlympus, 10000);
  }
  if (document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", startOlympus);
  else startOlympus();
  ```

- **Repository sync from Hestia (LXC) failed** — direct `rsync`/`scp` to the LXC didn't work. Worked around it via Apollo: `pct exec 101` into the container, `tar czf` an archive, copy it out through Apollo, then extract locally.
- **`scp` wildcard expansion failed on Artemis's fish shell** — switched to `rsync` entirely instead of `scp` with globs.

## Decision: abandon the custom Homepage widget

After the mobile-timing fix, the widget still accumulated hundreds of lines of DOM-manipulation JS with duplicated/conflicting CSS generations (old grid styles, old tile styles, new hero styles). The team judged this **too fragile and too tightly coupled to Homepage's internals** to maintain safely across Homepage updates. Decision: tear it out.

**Cleanup performed (by 2026-06-27):**
- Athena: stopped and removed the Dashboard API container; disabled the fetch scripts and their cron jobs. (The `dashboard-api/` source directory itself was **not** deleted from the repo at this stage.) Kept: Telemetry stack (Prometheus/Loki/Alloy), LocalStack, Floci.
- Hestia: emptied `custom.js`; Homepage restored to a stock-plus-minimal-theme configuration (Homepage, Vaultwarden, Portainer Agent, plus Alloy/Node Exporter for observability — see `inventory.md`).
- Apollo: removed temporary transfer files and any staged widget files.
- Everything was captured in Git before deletion, so the repository remains the canonical rollback point.

## Lessons learned

1. Homepage is best treated as a dashboard, not an application framework — deep DOM/CSS hacking creates ongoing maintenance and cross-device risk.
2. Only keep an aggregation backend *deployed* if it's still earning its complexity — the Dashboard API was solid engineering, but its value as a *running service* dropped once the widget consuming it was gone. (The code itself was still worth keeping around — see the 2026-07-10 entry.)
3. Test on multiple clients (desktop + mobile) early; timing bugs don't always show up on one device.
4. Sync live configs to Git *before* tearing anything down.
5. Prefer the simplest solution that meets the actual need.

**Reconciling with later docs (resolved 2026-07-10):** This cleanup emptied out the fragile *frontend widget code*; the backend Dashboard API and K3s cluster were kept running afterward through a more maintainable integration path (Phase 9 in `changelog.md`). That backend has since been decommissioned from active deployment too — the whole Dashboard API concept (FastAPI service, fetch scripts, cron jobs) stopped running on 2026-07-10, and Hestia now runs Homepage in a stock-plus-theme configuration with no backend dependency at all. **The Dashboard API's source code remains in the repository** as a deliberate portfolio decision — see `changelog.md` (Phase 11) and `architecture.md` for the current state.

---

# 2026-06-26 — LastFM + Media Pipeline Incident

**Window:** 09:48–10:45 UTC.

## What broke

1. **Overlapping cron executions** — no concurrency control; `fetch_lastfm.sh` was triggering `fetch_media.sh`, and jobs began overlapping every minute, spamming logs (`LASTFM UPDATED` repeated) and causing general system load.
2. **`jq` crash in the media pipeline** — `jq: error: Cannot index string with string "name"`. The GitHub API sometimes returned an error/rate-limit JSON object instead of an array of files, and the script assumed `.[]` was always valid.
3. **Broken `media.json` output** — `$WALLPAPER` came back empty when the GitHub API was rate-limited, with no fallback, producing a hero panel pointing at a broken URL.
4. **GitHub API rate limiting** — unauthenticated API calls, polled every minute from cron with no caching, hit `API rate limit exceeded`.

## Fixes applied (~10:20–10:30 UTC)

- Added `flock -n /tmp/fetch_lastfm.lock` / `flock -n /tmp/fetch_media.lock` to every cron entry to prevent overlapping runs.
- Added JSON validation (`jq empty "$TMP"`) and safe/optional accessors (`.track[0]?.name`) to the LastFM script so malformed responses no longer crash it.
- Split the media script's logic cleanly into LastFM-priority mode vs. wallpaper-fallback mode, added safe parsing of the GitHub response, and added a `default.jpg` fallback so a rate-limited API call never produces a broken image.
- **Decision:** treated GitHub rate limiting as an accepted external constraint rather than building a caching layer immediately — the fallback logic means the UI degrades gracefully instead of breaking.

## Lessons learned

- Cron without locking causes silent race conditions.
- Never assume an external API's JSON shape — validate before indexing into it.
- High-frequency polling against an unauthenticated third-party API will eventually get rate-limited; build the fallback path up front.

**Status:** Resolved — pipeline stable with locking, validation, and fallback logic in place.

---

# 2026-06-30 — Apollo Network Bring-up & Port Forwarding

**Goal:** Give the isolated `10.10.10.0/24` VM network internet access through Apollo's Wi-Fi uplink, and forward external connections to services on Hestia.

## What broke and how it was fixed

- **VMs had no internet access** at all (`apt`, Docker pulls, etc. failing) despite correct default routes.
  - Confirmed IPv4 forwarding was already enabled (`/proc/sys/net/ipv4/ip_forward` = `1`).
  - Fixed by adding a **MASQUERADE** rule: `iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o <wifi-iface> -j MASQUERADE`. Verified via increasing packet counters in `iptables -t nat -L -n -v`. **Fixed.**
- **Homepage forwarding (Apollo:3000 → Hestia:3000)** — added a DNAT rule; worked immediately, verified with `curl http://10.10.10.2:3000`.
- **Vaultwarden forwarding (Apollo:8080 → Hestia:8080) — connected but broken.** DNAT packet counters were increasing (proof packets reached Hestia), ping and Docker port mapping were all fine, yet `curl http://10.10.10.2:8080` returned `Received HTTP/0.9 when not allowed`.
  - **Root cause:** Vaultwarden's container logs showed `Rocket has launched from https://0.0.0.0:80` — it was serving **HTTPS**, not HTTP, on port 80 internally (`ROCKET_TLS` configured). The client was sending plain HTTP to a TLS listener, producing a TLS handshake failure, not a networking fault.
  - **Fix:** use `https://` when connecting (`curl -k https://10.10.10.2:8080` or `https://apollo:8080`) — no networking change required at all.

## Lessons learned

1. Increasing DNAT packet counters prove packets are arriving — don't assume NAT is broken if the counters are moving.
2. A successful TCP connection doesn't guarantee the application protocol matches (HTTP vs. HTTPS).
3. Application logs are often the fastest way to the real root cause — the Vaultwarden log line identified the protocol mismatch immediately.
4. Validate each layer independently: routing → forwarding → NAT → Docker port publishing → application protocol.
5. Don't assume a service on port 80 speaks plain HTTP.

**Final state:** IPv4 forwarding + outbound NAT active; Homepage reachable over HTTP on `:3000`; Vaultwarden reachable over HTTPS on `:8080`; Athena's internet access restored through Apollo's NAT.

---

# 2026-07-05 — Observability: Loki + Grafana Alloy Centralized Logging

**Goal:** Extend the existing Prometheus/Grafana metrics stack with centralized log aggregation across all Docker containers.

## What was completed

- Deployed **Loki 3.0** (local filesystem storage, TSDB index, single-binary mode, persistent volume). Health/labels endpoints responding. ✅
- Deployed **Grafana Alloy** in place of Promtail (Promtail is in maintenance mode; Alloy is Grafana Labs' recommended collector going forward) to discover Docker containers, read their logs, push into Loki, and label them (`host`, `container`, `service_name`, `level`). ✅
- Connected Grafana to Loki as a datasource; Explore and `{host="athena"}` queries both work end-to-end (Docker → Alloy → Loki → Grafana). ✅

## What's still broken (open as of 2026-07-05)

- **Only `grafana` and `loki` containers show up in Loki**, even though Athena is running `cadvisor`, `floci_aws`, `prometheus`, `alloy`, `node-exporter`, `proxmox-exporter`, and `portainer` as well — none of those are being ingested.
- The Docker socket is correctly mounted into the Alloy container (`/var/run/docker.sock`, permissions `srw-rw----`), but `ss -lx | grep docker` inside Alloy showed nothing, suggesting Alloy may not actually be talking to the Docker daemon despite the mount.
- Attempts to inspect Alloy's running config/discovery block/logs directly weren't conclusive in this session — investigation paused due to output size, not resolved.

**Suspected root cause (unconfirmed):** either the `discovery.docker` block isn't configured correctly, `loki.source.docker` is only subscribed to two containers, or Alloy genuinely can't reach the Docker daemon despite the socket mount.

## Status

Logging pipeline is **functionally working but not production-complete**. High-priority follow-up: verify `discovery.docker`/`loki.source.docker` targets, test Docker API connectivity from inside the Alloy container, and inspect Alloy's runtime logs for Docker-related errors, so every current and future container gets picked up automatically.

Metrics (Prometheus, Node Exporter, Proxmox Exporter, Grafana dashboards, alerting, Telegram notifications) were all confirmed still fully healthy throughout this work.

> **Update (2026-07-18):** this gap is resolved. A live audit confirmed all 12 running containers across both Athena and Hestia are being ingested into Loki correctly. See the 2026-07-18 entry near the end of this document for the full audit findings.

---

# Open Items Carried Forward

- ~~Loki/Alloy Docker log discovery~~ — **resolved**, confirmed via live audit 2026-07-18 (see below).
- ~~MAL (MyAnimeList) API integration~~ / ~~Library tracking automation~~ — both moot as of 2026-07-10: the Dashboard API that would have consumed them was decommissioned from deployment (code retained — see below).
- ~~`nftables` migration on Apollo~~ — **resolved**: evaluated, found Apollo runs `iptables-legacy` independently from `nftables`, and explicitly decided to stay on `iptables` rather than risk conflicting with Tailscale/Docker/K3s's self-managed rules. Replaced with a dynamic, idempotent firewall script instead (see 2026-07-18 entry below).
- ~~Port 3000 return-path NAT rule defined in config but not present in the live table~~ — **resolved** as a side effect of the firewall rework; the new script configures hairpin NAT symmetrically for both forwarded ports.
- Orphaned `core-services` Compose project (Portainer, on Athena) — needs a real compose file written and committed.
- `k3s.yaml` permissions reset on every `k3s` restart — workaround exists (`sudo kubectl` or reapply `chmod`), not yet automated.
- Recurring `dockerd` DNS resolver errors on Athena (`127.0.0.53`) — informational, not yet investigated.

---

# 2026-07-10 — Dashboard API Fully Decommissioned

**What happened:** The entire Olympus Dashboard API concept was decommissioned from active deployment — the FastAPI backend container on Athena was stopped, and every fetch script (LastFM, weather, prices, Pokémon, library, MyAnimeList, media/wallpaper) and its cron job was disabled. **None of the code was deleted** — `docker-compose/dashboard-api/` and the `scripts/fetch_*.sh` files remain in the repository, intentionally, as a portfolio artifact showing real working engineering, separate from what's actually deployed. Hestia's Homepage now runs standalone in a stock-plus-theme configuration.

**Why:** Consistent with the lesson from the 2026-06-27 widget rollback — the frontend widget had already proven too fragile to justify its maintenance cost, and once it was gone, the backend serving it stopped earning its *deployment* keep either. Decommissioning it from active use eliminates the last piece of custom, higher-maintenance surface area actually running in the stack, while the code itself stays visible in the repo as a deliberate portfolio decision — a recruiter looking at the repository can see a real, working FastAPI service that was built, and the judgment call to retire it from production once it stopped earning its complexity.

**Status:** Complete. This closes out the "reconcile the abandoned-vs-active dashboard" open item from the previous version of this document — the widget's logic is gone, the backend isn't deployed, and the code for both remains in the repo. Current architecture docs reflect this.

---

# 2026-07-18 — Live Infrastructure Audit & Documentation Reconciliation

**What happened:** A full audit was run directly against Apollo, Athena, and Hestia — `docker ps -a`, `kubectl get pods -A`, `tailscale status`, live NAT rules, hardware specs (`lscpu`, `free -h`, `lsblk`, `pvesm status`), and a check for `.env` files — specifically to catch drift between what the documentation claimed and what was actually running.

**Findings:**

- **Hestia runs more than previously documented.** Beyond Homepage and Vaultwarden, it also runs its own Grafana Alloy, Node Exporter, and Portainer Agent — a per-host exporter/agent pattern reporting up to the centralized stack on Athena. Confirmed via a Loki query that Hestia's logs are actually flowing into the central Loki correctly.
- **Athena runs more than previously documented too.** cAdvisor (per-container metrics) and Glances (system monitor) were both running but not listed anywhere in prior docs.
- **Traefik is not deployed.** Earlier documentation (2026-06-21 entry above) noted it was "kept — useful for learning Ingress." It isn't in the cluster now, whether removed later or never actually deployed as stated.
- **Floci is on-demand, not always-running.** `docker ps -a` showed no active Floci container — only a leftover, exited EC2-emulation container from a previous session. This matches actual usage pattern (started only for AWS-emulation work) rather than a fault.
- **The Grafana Alloy Docker log discovery gap (open since 2026-07-05) is resolved.** A live Loki query returned all 12 running containers across both hosts. The exact fix/timing wasn't captured — it was simply found resolved during this audit.
- **Tailscale mesh has a 4th member** not previously documented: a personal Android device, typically offline, not part of routine infrastructure operations.
- **No `.env` files exist anywhere** across all three hosts — confirmed all configuration is inline in Compose files, no secrets-externalization layer currently in place.
- **An orphaned Compose project was found:** the central Portainer container reports project `core-services`, but no matching `docker-compose.yml` exists anywhere on Athena. Portainer itself is fine; recreating it from scratch currently has no compose file to work from.
- **Real hardware specs captured for the first time:** Apollo is an AMD Ryzen 7 3700X (8c/16t) with 16GB DDR4-3200 (1 of 4 DIMM slots populated), a 238.5GB NVMe drive (Proxmox LVM-thin pool) plus a 232.9GB SATA drive (secondary storage pool), and an idle NVIDIA GTX 1660 Super with no passthrough configured — a legitimate future PCIe passthrough candidate (transcoding, local ML experimentation) sitting unused.

**Why this mattered:** several of these gaps would have been immediately visible to anyone actually cloning the repo and poking around — an inventory doc that undercounts running services on the exact hosts it claims to document is a credibility problem for a project explicitly built to go on a resume.

**Status:** Complete. `inventory.md`, `architecture.md`, `network.md`, `troubleshooting.md`, `disaster-recovery.md`, `health-checks.md`, and `validation-report.md` were all updated to reflect these findings.

---

# 2026-07-18 — Apollo Networking & Firewall Rework (Root-Caused, nftables Evaluated and Declined)

**What happened:** Athena lost internet access — it could reach Apollo and the rest of the LAN (`ping 10.10.10.1` succeeded) but not the outside world (`ping 8.8.8.8` failed). DNS wasn't the issue and the default route was correct; the problem was packet forwarding/NAT.

## Root Cause

Apollo had previously been using **USB tethering** as its uplink, and the outbound MASQUERADE rule was bound to that interface (`enx4a7f6c52f9f5`). After switching back to Wi-Fi (`wlx002e2df0393b`), the MASQUERADE rule was never updated — it kept pointing at the old, no-longer-active interface, so outbound packets from Athena were never actually NAT'd. This confirms and closes out the interface-mismatch pattern flagged in earlier audits (2026-07-18 live audit, and the `enx.../wlx...` cleanup from the same day).

**Fix:** re-added the MASQUERADE rule against the correct interface — internet access was restored immediately.

```bash
iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o wlx002e2df0393b -j MASQUERADE
```

## Red Herring: SSH Access Broke Too

While testing NAT changes, SSH access to Athena also stopped working. This looked like a separate SSH problem — it wasn't. It was caused by the same broken/in-flux NAT rules from the troubleshooting process itself. Once NAT was cleaned up, SSH worked again with **no SSH-side configuration changes** at all. Worth remembering: a "service is unreachable" symptom during active firewall work is not automatically a service-layer problem.

## nftables Migration: Evaluated, Then Declined

Since Proxmox 9 ships with `nftables`, a migration was attempted: `/etc/nftables.conf` was created, rules were written, loaded, and tested against the working `iptables` configuration.

**What killed the migration:** Apollo's `iptables` binary reported `iptables v1.8.11 (legacy)` — meaning it's running the **legacy** backend, not the `nft` backend. Legacy `iptables` and `nftables` rules on this system are **completely independent rule sets**, not two views of the same thing. The entire time the `nftables` rules were being tested, the actually-working NAT was still coming from the legacy `iptables` configuration — the `nftables` rules were inert.

**Decision: stay on `iptables` (legacy).** Reasons:

- Tailscale already manages its own `iptables` chains.
- Docker creates its own `iptables` rules.
- K3s (Flannel/CNI) creates additional `iptables`-based networking rules.
- The existing `iptables` configuration, once the interface bug was fixed, was already working reliably.
- Migrating would mean either running two independent, conflicting firewall backends simultaneously, or also migrating Tailscale/Docker/K3s's self-managed rules — well outside the scope of what was actually broken.

The real bug was never `iptables` itself — it was one hardcoded, stale interface name.

## New Firewall Architecture

Rather than leaving firewall logic embedded in `/etc/network/interfaces` (where it had already caused problems), it was extracted into a dedicated, idempotent script:

- **`/usr/local/sbin/apollo-firewall.sh`** — configures outbound NAT, Homepage/Vaultwarden port forwarding, and hairpin NAT (so LAN clients can reach forwarded services via Apollo's own address, not just external clients). Checks for existing rules before adding them, so it's safe to re-run.
- **Dynamic WAN detection** — instead of hardcoding an interface name, the script determines the current uplink at runtime:

  ```bash
  WAN_IF=$(ip route | awk '/^default/ {print $5; exit}')
  ```

  This is the actual fix for the root cause: the script now adapts automatically whether the uplink is Wi-Fi, USB tethering, or Ethernet, instead of silently going stale the next time the connection type changes.
- **`/etc/systemd/system/apollo-firewall.service`** — runs the script once at boot, after networking is up. Enabled via `systemctl enable apollo-firewall.service`; verified `Active: active (exited)`.
- **`/etc/network/interfaces`** was cleaned up to only configure networking — no more `post-up`/`post-down` firewall rules embedded in it.

**Explicitly left untouched:** Tailscale's chains, Docker's rules, K3s/Flannel's rules, and Proxmox's own networking — the script only manages Apollo's own outbound NAT, port forwarding, and hairpin NAT, to avoid conflicting with tooling that already manages its own `iptables` state.

## Also Resolved As a Side Effect

The port 3000 return-path NAT asymmetry flagged in the 2026-07-18 audit (Vaultwarden's port 8080 had an explicit return-path rule; Homepage's port 3000 didn't) is resolved by this rework — the new script configures hairpin NAT for both forwarded ports symmetrically, rather than relying on rules that had drifted apart over time.

## Lessons Learned

1. A correct default route does not guarantee internet access — NAT must also be bound to the correct outbound interface, and that binding needs to survive uplink changes.
2. Hardcoded interface names in MASQUERADE rules are a real, recurring failure mode on a host that switches between Wi-Fi/Ethernet/USB — this happened more than once during this project.
3. A "service unreachable" symptom appearing *during* active firewall changes should be suspected as a side effect of that work before being treated as an unrelated fault.
4. Firewall logic doesn't belong inside `/etc/network/interfaces` — a dedicated, idempotent script with its own systemd unit is easier to reason about, test, and re-run safely.
5. Evaluating a migration (`nftables`) and then explicitly declining it, for concrete reasons, is a legitimate engineering outcome — not every modernization is worth doing just because it's available, especially when three other systems (Tailscale, Docker, K3s) already have working state tied to the alternative.

## Status

**Complete.** Internet access, SSH, Homepage forwarding, and Vaultwarden forwarding are all confirmed working. This closes out the `iptables` → `nftables` migration item from the 2026-07-18 audit — the final decision was to **stay on `iptables`**, not migrate. `network.md`, `inventory.md`, `architecture.md`, and `disaster-recovery.md` have all been updated to describe the new firewall-script architecture in place of the old inline rules.

---
