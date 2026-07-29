from __future__ import annotations

import json
from datetime import datetime
from pathlib import Path

from orchestrator.models import SessionRecord


def _decode_cwd(dirname: str) -> str:
    if not dirname.startswith("--") or not dirname.endswith("--"):
        return dirname
    body = dirname[2:-2]
    return "/" + body.replace("-", "/")


def _parse_timestamp(name: str) -> int:
    prefix = name.split("_", 1)[0]
    try:
        dt = datetime.strptime(prefix, "%Y-%m-%dT%H-%M-%S-%fZ")
        return int(dt.timestamp())
    except ValueError:
        return 0


def _first_user_text(path: Path) -> str:
    try:
        with path.open(encoding="utf-8") as handle:
            for line in handle:
                line = line.strip()
                if not line:
                    continue
                payload = json.loads(line)
                if payload.get("type") == "session":
                    continue
                message = payload.get("message")
                if isinstance(message, dict) and message.get("role") == "user":
                    content = message.get("content")
                    if isinstance(content, list):
                        for part in content:
                            if isinstance(part, dict) and part.get("type") == "text":
                                return str(part.get("text", "")).strip()
                    if isinstance(content, str):
                        return content.strip()
    except (OSError, json.JSONDecodeError):
        return ""
    return ""


def discover(root: Path) -> list[SessionRecord]:
    if not root.is_dir():
        return []

    sessions: list[SessionRecord] = []
    for cwd_dir in sorted(root.iterdir()):
        if not cwd_dir.is_dir():
            continue
        cwd = _decode_cwd(cwd_dir.name)
        for path in cwd_dir.glob("*.jsonl"):
            session_id = path.stem.split("_", 1)[-1]
            updated_at = _parse_timestamp(path.name)
            if updated_at == 0:
                updated_at = int(path.stat().st_mtime)
            preview = _first_user_text(path)
            title = preview or session_id
            sessions.append(
                SessionRecord(
                    provider="pi",
                    session_id=session_id,
                    title=title[:120],
                    cwd=cwd,
                    updated_at=updated_at,
                    preview=preview[:200],
                    resume_cmd=f'pi -C "{cwd}" --session-id {session_id}',
                )
            )
    sessions.sort(key=lambda item: item.updated_at, reverse=True)
    return sessions
