#!/usr/bin/env python3
"""Validate current local docs, mirrored diagrams, shell syntax and YAML/Compose.

Historical archives retain their old relative links; remote URLs and heading
fragments are intentionally not checked. No infrastructure services are contacted.
"""
from pathlib import Path
import re
import subprocess
from urllib.parse import unquote, urlsplit

import yaml

ROOT = Path(__file__).resolve().parents[1]


class UniqueKeyLoader(yaml.SafeLoader):
    pass


def mapping(loader, node, deep=False):
    seen = set()
    for key, _ in node.value:
        name = loader.construct_object(key, deep=deep)
        if name in seen:
            raise ValueError(f"Duplicate YAML key: {name}")
        seen.add(name)
    return yaml.SafeLoader.construct_mapping(loader, node, deep=deep)


UniqueKeyLoader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, mapping)


def check_markdown(path):
    errors = []
    lines = []
    fence = None
    for line in path.read_text().splitlines():
        marker = re.match(r"^\s*(`{3,}|~{3,})", line)
        if marker:
            value = marker[1]
            if fence is None:
                fence = value
            elif value[0] == fence[0] and len(value) >= len(fence):
                fence = None
            continue
        if fence is None:
            lines.append(line)
    if fence:
        errors.append(f"{path}: unclosed code fence")
    for target in re.findall(r"!?\[[^\]]*\]\(([^\s)]+)(?:\s+\"[^\"]*\")?\)", "\n".join(lines)):
        parsed = urlsplit(target.strip('<>'))
        if parsed.scheme or parsed.netloc or not parsed.path:
            continue
        relative = unquote(parsed.path)
        resolved = ROOT / relative.lstrip('/') if relative.startswith('/') else path.parent / relative
        if not resolved.exists():
            errors.append(f"{path.relative_to(ROOT)}: missing link target {target}")
    return errors


def main():
    errors = []
    roots = ('docs', 'diagrams', 'docker', 'infrastructure', 'kubernetes', 'scripts', 'terraform', 'screenshots')
    docs = list(ROOT.glob('*.md'))
    for name in roots:
        docs.extend(p for p in (ROOT / name).rglob('*.md') if 'history' not in p.relative_to(ROOT).parts)
    for path in docs:
        errors.extend(check_markdown(path))
    diagrams = {
        'docs/architecture.md': ['architecture.mmd'],
        'docs/networking.md': ['networking.mmd'],
        'docs/observability.md': ['metrics-flow.mmd', 'logging-flow.mmd', 'alerting-flow.mmd'],
        'docs/disaster-recovery.md': ['recovery-flow.mmd'],
    }
    for source, names in diagrams.items():
        blocks = re.findall(r'```mermaid\n(.*?)\n```', (ROOT / source).read_text(), re.S)
        if len(blocks) != len(names):
            errors.append(f'{source}: unexpected Mermaid block count')
        for block, name in zip(blocks, names):
            standalone = (ROOT / 'diagrams' / name).read_text()
            standalone = re.sub(r'^%%[^\n]*\n', '', standalone)
            if block.strip() != standalone.strip():
                errors.append(f'{source}: diagram differs from diagrams/{name}')
    for script in (ROOT / 'scripts').glob('*.sh'):
        if subprocess.run(['bash', '-n', str(script)], check=False).returncode:
            errors.append(f'{script}: Bash syntax error')
    configs = []
    for name in ('.github', 'docker', 'infrastructure', 'kubernetes'):
        configs.extend(p for p in (ROOT / name).rglob('*') if p.suffix in ('.yml', '.yaml'))
    for path in configs:
        try:
            list(yaml.load_all(path.read_text(), Loader=UniqueKeyLoader))
        except (yaml.YAMLError, ValueError) as exc:
            errors.append(f'{path}: invalid YAML: {exc}')
    compose_files = sorted(p for p in (ROOT / 'docker').rglob('*') if p.name in ('compose.yml', 'compose.yaml', 'docker-compose.yml', 'docker-compose.yaml'))
    for path in compose_files:
        try:
            subprocess.run(['docker', 'compose', '-f', str(path), 'config', '--quiet'], check=True, timeout=30)
        except (OSError, subprocess.SubprocessError) as exc:
            errors.append(f'{path}: Compose validation failed: {exc}')
    if not compose_files:
        print('SKIP: active Compose validation; current host export has not been imported.')
    for error in errors:
        print(f'FAIL: {error}')
    print(f'Checked {len(docs)} current Markdown files, 6 diagram pairs, shell syntax and {len(configs)} YAML files; {len(errors)} errors.')
    return bool(errors)


if __name__ == '__main__':
    raise SystemExit(main())
