from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from orchestrator.org import candidate_headings, parse_headings, slugify
from orchestrator.plans import render_snapshot, update_managed_snapshot, write_plan
from orchestrator.providers.pi import _decode_cwd
from orchestrator.sessions import search_sessions


class ProviderTests(unittest.TestCase):
    def test_decode_pi_cwd(self) -> None:
        self.assertEqual(_decode_cwd("--Users-rgaur-dotfiles--"), "/Users/rgaur/dotfiles")

    def test_slugify(self) -> None:
        self.assertEqual(slugify("Fix SSH copy in Neovim"), "fix-ssh-copy-in-neovim")


class PlanTests(unittest.TestCase):
    def test_managed_snapshot_roundtrip(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "plan.md"
            path.write_text("# Demo\n\nBody\n", encoding="utf-8")
            snapshot = render_snapshot(
                decisions=["Use Herdr backend"],
                state="Plan created.",
                next_action="Launch session.",
            )
            update_managed_snapshot(path, snapshot)
            text = path.read_text(encoding="utf-8")
            self.assertIn("Use Herdr backend", text)
            self.assertIn("<!-- ai-managed:start -->", text)


class SessionIndexTests(unittest.TestCase):
    def test_org_parser(self) -> None:
        lines = [
            "* TODO sync dotfiles :ai:",
            "- work in ~/Projects/demo",
            "* DONE unrelated",
        ]
        headings = parse_headings(lines)
        self.assertEqual(len(headings), 2)
        candidates = [item for item in headings if item.has_ai_tag and item.state == "TODO"]
        self.assertEqual(len(candidates), 1)
        self.assertEqual(candidates[0].title, "sync dotfiles")

    def test_search_filters(self) -> None:
        from orchestrator.models import SessionRecord

        class FakeSessions:
            called = False

        # smoke: empty query returns all when patched through search logic
        items = [
            SessionRecord(
                provider="codex",
                session_id="abc",
                title="refund bug",
                cwd="/tmp/demo",
                updated_at=1,
                preview="fix refund bug",
                resume_cmd="co resume abc",
            )
        ]

        def fake_load(rebuild: bool = False):
            return items

        import orchestrator.sessions as sessions_mod

        original = sessions_mod.load_index
        sessions_mod.load_index = fake_load
        try:
            matches = search_sessions("refund")
            self.assertEqual(len(matches), 1)
            self.assertEqual(matches[0].session_id, "abc")
        finally:
            sessions_mod.load_index = original


if __name__ == "__main__":
    unittest.main()
