from contextlib import redirect_stdout
import importlib.util
from io import StringIO
import json
from pathlib import Path
import tempfile
import unittest


spec = importlib.util.spec_from_file_location("deploy", Path(__file__).resolve().parents[1] / "deploy.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class DeployTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.source = self.root / "source"
        self.home = self.root / "live"
        self.backups = self.root / "backups"
        (self.source / "mods/example").mkdir(parents=True)
        (self.source / "lib").mkdir()
        (self.source / "keys.json").write_text("{}")
        (self.source / "mods/example/main.js").write_text("version one")
        (self.source / "lib/helper.js").write_text("helper")
        (self.source / "mods/example/helper.js").symlink_to("../../lib/helper.js")
        (self.source / "deploy.json").write_text(json.dumps({"linked": ["keys.json"], "mods": ["example"], "retired": ["old-name"]}))

    def deploy(self, check=False):
        with redirect_stdout(StringIO()):
            return module.deploy(self.source, self.home, self.backups, check)

    def test_links_settings_but_materializes_sandbox_helpers(self):
        self.deploy()
        self.assertTrue((self.home / "keys.json").is_symlink())
        self.assertFalse((self.home / "mods/example/helper.js").is_symlink())
        self.assertEqual((self.home / "mods/example/helper.js").read_text(), "helper")
        self.assertTrue(self.deploy(check=True))

    def test_repeated_updates_keep_backups_and_unchanged_file_mtimes(self):
        self.deploy()
        target = self.home / "mods/example/main.js"
        before = target.stat().st_mtime_ns
        self.deploy()
        self.assertEqual(target.stat().st_mtime_ns, before)
        for version in ["two", "three"]:
            (self.source / "mods/example/main.js").write_text(version)
            self.assertFalse(self.deploy(check=True))
            self.deploy()
            self.assertEqual(target.read_text(), version)
        self.assertEqual(len(list(self.backups.glob("deploy-*/mods/example/main.js"))), 2)

    def test_live_edits_abort_before_other_files_change(self):
        self.deploy()
        target = self.home / "mods/example/main.js"
        target.write_text("local edit")
        (self.source / "lib/helper.js").write_text("new helper")
        with self.assertRaisesRegex(ValueError, "Live edits"):
            self.deploy()
        self.assertEqual(target.read_text(), "local edit")
        self.assertEqual((self.home / "mods/example/helper.js").read_text(), "helper")

    def test_removed_files_and_renamed_mods_are_backed_up(self):
        old = self.home / "mods/old-name"
        old.mkdir(parents=True)
        (old / "main.js").write_text("old mod")
        self.deploy()
        self.assertFalse(old.exists())
        (self.source / "mods/example/helper.js").unlink()
        self.deploy()
        self.assertFalse((self.home / "mods/example/helper.js").exists())
        self.assertTrue(list(self.backups.glob("deploy-*/mods/old-name/main.js")))
        self.assertTrue(list(self.backups.glob("deploy-*/mods/example/helper.js")))

    def test_check_does_not_write(self):
        self.assertFalse(self.deploy(check=True))
        self.assertFalse(self.home.exists())
        self.assertFalse(self.backups.exists())


if __name__ == "__main__":
    unittest.main()
