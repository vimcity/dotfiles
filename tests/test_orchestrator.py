from __future__ import annotations

import unittest

from orchestrator.models import SessionRecord
from orchestrator.providers.pi import _decode_cwd
from orchestrator.sessions import search_sessions


class ProviderTests(unittest.TestCase):
    def test_decode_pi_cwd(self) -> None:
        self.assertEqual(_decode_cwd("--Users-rgaur-dotfiles--"), "/Users/rgaur/dotfiles")


class SessionIndexTests(unittest.TestCase):
    def test_search_filters(self) -> None:
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

        import orchestrator.sessions as sessions_mod

        original = sessions_mod.load_index
        sessions_mod.load_index = lambda rebuild=False: items
        try:
            matches = search_sessions("refund")
            self.assertEqual(len(matches), 1)
            self.assertEqual(matches[0].session_id, "abc")
        finally:
            sessions_mod.load_index = original


if __name__ == "__main__":
    unittest.main()
