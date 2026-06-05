# Scripts

## Purpose

This directory contains operational helper scripts used for administration, validation, maintenance, troubleshooting, and recovery activities.

Scripts are intended to automate common tasks and reduce repetitive manual operations.

---

## Contents

Typical scripts may include:

* Health checks
* Service restart automation
* Validation routines
* Backup verification
* Recovery procedures

Examples:

* `healthcheck.sh`
* `restart-telemetry.sh`

---

## Usage

Execute scripts directly from the command line:

```bash
./script-name.sh
```

If required, make scripts executable:

```bash
chmod +x script-name.sh
```

---

## Dependencies

* Bash shell
* Standard Linux utilities
* Docker CLI (where applicable)
* Tailscale CLI (where applicable)

---

## Maintenance

* Keep scripts documented and version-controlled.
* Validate scripts after infrastructure changes.
* Remove deprecated automation when services are retired.
* Ensure scripts remain aligned with procedures documented in `docs/runbook.md`.

---

## Status

**Automation Framework:** Active

**Operational Use:** Supported

**Documentation Status:** Current
