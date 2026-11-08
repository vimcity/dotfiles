import concurrent.futures
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

sys.dont_write_bytecode = True

SCRIPT = Path(__file__).resolve().parents[1] / "mods/minimal-pane/terminal-zoom.py"
spec = importlib.util.spec_from_file_location("terminal_zoom", SCRIPT)
zoom = importlib.util.module_from_spec(spec)
spec.loader.exec_module(zoom)


class TerminalZoomTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.home = self.root / "app"
        self.home.mkdir()
        self.settings = self.home / "settings.json"
        self.original = {"zoom": 1.1, "font_size": 14, "sounds": {"enabled": True}, "theme": "frappe"}
        self.settings.write_text(json.dumps(self.original))

    def test_only_font_size_changes_and_reset_remembers_baseline(self):
        for action, expected in [("in", 15), ("in", 16), ("out", 15), ("reset", 14)]:
            self.assertEqual(zoom.change_font(self.home, action), expected)
            self.assertEqual(json.loads(self.settings.read_text()), {**self.original, "font_size": expected})
        self.assertEqual(json.loads((self.home / "data/terminal-zoom.json").read_text()), {"base_font_size": 14})

    def test_preserves_symlink_target_and_file_permissions(self):
        target = self.root / "portable/settings.json"
        target.parent.mkdir()
        self.settings.rename(target)
        target.chmod(0o644)
        self.settings.symlink_to("../portable/settings.json")
        zoom.change_font(self.home, "in")
        self.assertTrue(self.settings.is_symlink())
        self.assertEqual(str(self.settings.readlink()), "../portable/settings.json")
        self.assertEqual(json.loads(target.read_text())["font_size"], 15)
        self.assertEqual(target.stat().st_mode & 0o777, 0o644)
        self.assertFalse(list(self.home.glob(".settings-zoom-*")))

    def test_bounds_and_default_font(self):
        for current, action, expected in [(40, "in", 40), (8, "out", 8)]:
            self.settings.write_text(json.dumps({**self.original, "font_size": current}))
            self.assertEqual(zoom.change_font(self.home, action), expected)
        self.settings.write_text(json.dumps({"zoom": 1.1}))
        self.assertEqual(zoom.change_font(self.home, "in"), 15)

    def test_parallel_commands_do_not_lose_steps(self):
        def increase(_index):
            subprocess.run([sys.executable, str(SCRIPT), str(self.home), "in"], check=True, capture_output=True)
        with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
            list(pool.map(increase, range(12)))
        self.assertEqual(json.loads(self.settings.read_text())["font_size"], 26)
        self.assertEqual(zoom.change_font(self.home, "reset"), 14)

    def test_invalid_inputs_do_not_write_settings(self):
        before = self.settings.read_bytes()
        with self.assertRaises(ValueError):
            zoom.change_font(self.home, "unknown")
        self.assertEqual(self.settings.read_bytes(), before)
        self.settings.write_text("invalid json")
        with self.assertRaises(json.JSONDecodeError):
            zoom.change_font(self.home, "in")
        self.assertEqual(self.settings.read_text(), "invalid json")


if __name__ == "__main__":
    unittest.main()
