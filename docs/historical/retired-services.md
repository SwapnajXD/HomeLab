# Historical and retired services

The V2 platform preserves engineering history without advertising retired experiments as active services.

| Material | Status | Engineering outcome |
|---|---|---|
| Hestia CT 101 | Retired in the September 12 rebuild | September backup verified before destruction; ID 101 reused for Hermes VM |
| Athena K3s | Removed | Configuration backed up; fresh K3s runs on Hermes |
| Portainer and Floci on Athena | Removed | Portainer data archived; no replacement Floci deployment reported |
| Olympus Dashboard API | Retired from active deployment | Backend maintenance no longer justified the value; source retained in `docker-compose/dashboard-api/` |
| Custom Homepage data widgets | Retired | Replaced with stock Homepage features and a lightweight visual theme; Homepage was subsequently retired with Hestia |
| Old data-fetch scripts and associated cron/data-sync pipeline | Historical / retired from deployment | Retained `scripts/fetch_*.sh` work demonstrates integration and operational lessons |
| LocalStack | Deprecated | Previously superseded by Floci; both are absent from the reported V2 stack, with examples retained |
| [Pre-V2 roadmap](roadmap-pre-v2.md) | Historical / superseded | Original milestones, abandoned plans and priorities preserved verbatim |

The lifecycle is **Build → Test → Operate → Evaluate → Retire / Replace**. Keeping source records what was learned; it does not mean the service is still running.

The [postmortems](postmortems.md), [changelog](changelog.md), and [project timeline](project-timeline.md) are preserved alongside this page in the historical archive. This includes dashboard incidents and retirement decisions, the K3s stand-up, and Apollo's networking outage, dynamic WAN-aware NAT/firewall resolution and later boot-race hardening. Incident records are preserved in this historical archive.

Other old experiments retain their existing status unless evidence supports reclassification. The archive's old relative links and time-relative wording belong to its original root-document context; use the links above to navigate current documentation.
