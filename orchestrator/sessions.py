from __future__ import annotations

import json
import shutil
import subprocess
from datetime import datetime, timezone

from orchestrator.config import codex_state_db, pi_sessions_root, session_index_path
from orchestrator.models import SessionRecord
from orchestrator.providers import discover_codex, discover_pi


def rebuild_index(include_archived: bool = False) -> list[SessionRecord]:
    sessions = discover_codex(codex_state_db()) + discover_pi(pi_sessions_root())
    if not include_archived:
        sessions = [item for item in sessions if not item.archived]
    sessions.sort(key=lambda item: item.updated_at, reverse=True)
    payload = {
        "schema": "ai-orchestrator.session-index.v1",
        "built_at": datetime.now(timezone.utc).isoformat(),
        "sessions": [item.to_dict() for item in sessions],
    }
    session_index_path().write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    return sessions


def load_index(rebuild: bool = False) -> list[SessionRecord]:
    path = session_index_path()
    if rebuild or not path.is_file():
        return rebuild_index()
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
        return [SessionRecord.from_dict(item) for item in payload.get("sessions", [])]
    except (OSError, json.JSONDecodeError, TypeError):
        return rebuild_index()


def search_sessions(query: str, *, rebuild: bool = False, include_archived: bool = False) -> list[SessionRecord]:
    sessions = load_index(rebuild=rebuild)
    if not include_archived:
        sessions = [item for item in sessions if not item.archived]
    if not query:
        return sessions

    needle = query.lower()
    matches: list[SessionRecord] = []
    for item in sessions:
        haystack = " ".join(
            [
                item.provider,
                item.session_id,
                item.title,
                item.preview,
                item.cwd,
                item.model,
                item.branch,
            ]
        ).lower()
        if needle in haystack:
            matches.append(item)
    return matches


def format_row(item: SessionRecord) -> str:
    when = datetime.fromtimestamp(item.updated_at, tz=timezone.utc).strftime("%Y-%m-%d %H:%M")
    return f"{item.provider}\t{item.session_id}\t{when}\t{item.cwd}\t{item.title}"


def pick_session(sessions: list[SessionRecord], prompt: str = "ai session> ") -> SessionRecord | None:
    if not sessions:
        return None
    if len(sessions) == 1:
        return sessions[0]
    if not shutil.which("fzf") or not __import__("sys").stdin.isatty():
        return sessions[0]

    lines = "\n".join(format_row(item) for item in sessions)
    result = subprocess.run(
        [
            "fzf",
            "--delimiter=\t",
            "--with-nth=1..",
            f"--prompt={prompt}",
            "--preview=echo {4}",
            "--preview-window=wrap",
        ],
        input=lines,
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0 or not result.stdout.strip():
        return None
    session_id = result.stdout.strip().split("\t", 2)[1]
    for item in sessions:
        if item.session_id == session_id:
            return item
    return None


def resume_session(item: SessionRecord, *, dry_run: bool = False) -> int:
    cmd = item.resume_cmd
    print(cmd)
    if dry_run:
        return 0
    return subprocess.call(cmd, shell=True, cwd=item.cwd or None)
