from __future__ import annotations

import sqlite3
from pathlib import Path

from orchestrator.models import SessionRecord

LOCAL_PROVIDERS = {"omlx", "headroom", "headroom-local"}


def _resume_cmd(session_id: str, model_provider: str) -> str:
    if model_provider in LOCAL_PROVIDERS:
        return f"col resume {session_id}"
    return f"co resume {session_id}"


def discover(db_path: Path) -> list[SessionRecord]:
    if not db_path.is_file():
        return []

    conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    conn.row_factory = sqlite3.Row
    try:
        rows = conn.execute(
            """
            SELECT id, title, cwd, updated_at, archived, model_provider, model,
                   COALESCE(NULLIF(first_user_message, ''), NULLIF(preview, ''), title) AS preview,
                   git_branch
            FROM threads
            ORDER BY updated_at DESC
            """
        ).fetchall()
    finally:
        conn.close()

    sessions: list[SessionRecord] = []
    for row in rows:
        title = (row["title"] or row["preview"] or row["id"]).strip()
        preview = (row["preview"] or "").strip().replace("\n", " ")
        sessions.append(
            SessionRecord(
                provider="codex",
                session_id=row["id"],
                title=title[:120],
                cwd=row["cwd"] or "",
                updated_at=int(row["updated_at"] or 0),
                preview=preview[:200],
                model=(row["model"] or row["model_provider"] or "").strip(),
                branch=(row["git_branch"] or "").strip(),
                resume_cmd=_resume_cmd(row["id"], row["model_provider"] or "openai"),
                archived=bool(row["archived"]),
            )
        )
    return sessions
