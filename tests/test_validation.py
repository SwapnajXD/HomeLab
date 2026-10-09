"""Check that validation rejects the documentation/configuration faults it targets."""
import importlib.util
from pathlib import Path
import tempfile
import unittest
import yaml

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('validator', ROOT / 'scripts/validate-repo.py')
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)


class ValidationTests(unittest.TestCase):
    def test_links_and_fences(self):
        with tempfile.TemporaryDirectory(dir=ROOT / 'tests') as folder:
            path = Path(folder) / 'test.md'
            target = Path(folder) / 'target.md'
            target.write_text('# Target\n')
            path.write_text('[ok](target.md#heading)\n```text\n[example](absent.md)\n```\n')
            self.assertEqual(validator.check_markdown(path), [])
            path.write_text('[broken](absent.md)\n```text\n')
            errors = validator.check_markdown(path)
            self.assertEqual(len(errors), 2)

    def test_duplicate_yaml_keys_rejected(self):
        with self.assertRaises(ValueError):
            yaml.load('services:\n  app: {}\n  app: {}\n', Loader=validator.UniqueKeyLoader)

    def test_distinct_yaml_keys_accepted(self):
        config = yaml.load('services:\n  app: {}\n  db: {}\n', Loader=validator.UniqueKeyLoader)
        self.assertEqual(set(config['services']), {'app', 'db'})


if __name__ == '__main__':
    unittest.main()
