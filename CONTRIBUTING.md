# Working on HomeLab

Current guides live in `docs/`, current diagrams in `diagrams/`, dated evidence in `docs/history/`, and retired deployment snapshots in `archive/`. Keep reported results separate from new live checks. Update embedded and standalone Mermaid diagrams together.

## Local checks

Requires Python 3.12 or newer and Bash. Install development dependencies in a virtual environment:

```bash
python3 -m venv .venv
. .venv/bin/activate
python -m pip install -r requirements-dev.txt
python scripts/validate-repo.py
shellcheck scripts/*.sh
python -m unittest discover -s tests -v
```

GitHub Actions runs the same checks on pushes and pull requests. Validation checks current Markdown local file links and code fences, six mirrored diagram pairs, Bash syntax, duplicate YAML keys and YAML parsing. ShellCheck covers active shell scripts. Health-check tests use simulated commands, never live infrastructure.

Historical Markdown under `docs/history/` and `archive/` retains old relative links and is excluded from link validation. Remote URLs, heading fragments and Mermaid rendering are not checked. Active Compose files under `docker/` are validated with `docker compose config --quiet` when present; Docker Compose and any documented nonsecret test environment values are required. Missing active Compose exports are reported as a skip, not deployment validation. YAML syntax alone does not validate Prometheus, Loki or Alloy schemas; run their version-matched validators when importing configurations.

## Configuration imports

Follow the [export requirements](docs/configuration-exports.md). Use the current host as the source; do not promote archived Compose or Terraform examples into live configuration without review. Keep actual secrets, private keys, state, database contents and generated telemetry out of Git. Put sanitized `.env.example` files next to configurations that consume them, and document required variables there.

The old root `.env.example` was removed because no active configuration consumed it. It mixed obsolete LocalStack and generic endpoint/token variables.
