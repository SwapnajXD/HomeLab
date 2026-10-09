"""Exercise exit status and failure isolation without contacting real services."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'scripts/healthcheck.sh'


class HealthcheckTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.bin = Path(self.temp.name)
        self.env = dict(os.environ, PATH=f'{self.bin}:/usr/bin:/bin', HEALTHCHECK_TIMEOUT='2')
        for name in ('uptime', 'free', 'df'):
            self.stub(name, 'exit 0')
        self.stub('docker', '''
if [[ $1 == ps ]]; then
  [[ ${MOCK_DOCKER_FAIL:-0} == 1 ]] && exit 1
  [[ ${MOCK_EMPTY:-0} == 1 ]] || echo abc123
  exit 0
fi
[[ ${MOCK_INSPECT_FAIL:-0} == 1 ]] && exit 1
echo "/telemetry ${MOCK_HEALTH:-healthy}"
''')
        self.stub('tailscale', '''
[[ ${MOCK_TAILSCALE_FAIL:-0} == 1 ]] && exit 1
printf '{"BackendState":"%s"}' "${MOCK_BACKEND:-Running}"
''')

    def stub(self, name, body):
        path = self.bin / name
        path.write_text('#!/bin/bash\n' + body + '\n')
        path.chmod(0o755)

    def run_check(self, *args, **env):
        return subprocess.run(['bash', str(SCRIPT), *args], env=self.env | env,
                              capture_output=True, text=True, timeout=8)

    def test_healthy(self):
        result = self.run_check()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('0 failed checks', result.stdout)

    def test_docker_failure_does_not_mask_or_skip_tailscale(self):
        result = self.run_check(MOCK_DOCKER_FAIL='1')
        self.assertEqual(result.returncode, 1)
        self.assertIn('PASS: Tailscale', result.stdout)

    def test_unhealthy_starting_and_inspection_failure(self):
        for env in ({'MOCK_HEALTH': 'unhealthy'}, {'MOCK_HEALTH': 'starting'}, {'MOCK_INSPECT_FAIL': '1'}, {'MOCK_EMPTY': '1'}):
            with self.subTest(env=env):
                self.assertEqual(self.run_check(**env).returncode, 1)

    def test_no_container_healthcheck_is_explicit(self):
        result = self.run_check(MOCK_HEALTH='unconfigured')
        self.assertEqual(result.returncode, 0)
        self.assertIn('application health is unverified', result.stdout)

    def test_tailscale_stopped_and_command_failure(self):
        for env in ({'MOCK_BACKEND': 'Stopped'}, {'MOCK_TAILSCALE_FAIL': '1'}):
            with self.subTest(env=env):
                self.assertEqual(self.run_check(**env).returncode, 1)

    def test_skips_are_explicit(self):
        result = self.run_check('--skip-docker', '--skip-tailscale', MOCK_DOCKER_FAIL='1', MOCK_TAILSCALE_FAIL='1')
        self.assertEqual(result.returncode, 0)
        self.assertIn('SKIP: Docker', result.stdout)

    def test_timeout_and_system_command_failure(self):
        self.stub('uptime', 'sleep 5')
        result = self.run_check(HEALTHCHECK_TIMEOUT='1')
        self.assertEqual(result.returncode, 1)
        self.assertIn('PASS: Tailscale', result.stdout)

    def test_usage_errors(self):
        self.assertEqual(self.run_check('--unknown').returncode, 2)
        self.assertEqual(self.run_check(HEALTHCHECK_TIMEOUT='0').returncode, 2)


if __name__ == '__main__':
    unittest.main()
