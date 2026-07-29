from __future__ import annotations

import datetime as dt
from pathlib import Path

from orchestrator.config import tasks_dir
from orchestrator.org import slugify


def task_path(title: str) -> Path:
    return tasks_dir() / f"{slugify(title)}.md"


def create_task(title: str, *, repo: str = "", agent: str = "codex", status: str = "active") -> Path:
    path = task_path(title)
    if path.exists():
        return path
    today = dt.date.today().isoformat()
    path.write_text(
        f"""# {title}

Status: {status}
Created: {today}
Agent: {agent}
Repo: {repo or "-"}

## Goal

{title}

## Linked sessions

- none

## Notes

- Created by `ai task create`.
""",
        encoding="utf-8",
    )
    return path


def append_session_link(path: Path, provider: str, session_id: str) -> None:
    text = path.read_text(encoding="utf-8")
    line = f"- {provider}:{session_id}"
    if line in text:
        return
    if "## Linked sessions" not in text:
        text = text.rstrip() + "\n\n## Linked sessions\n\n- none\n"
    text = text.replace("- none\n", f"- none\n{line}\n", 1)
    path.write_text(text, encoding="utf-8")
