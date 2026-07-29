from __future__ import annotations

import os
from pathlib import Path


def home() -> Path:
    return Path(os.environ.get("HOME", "~")).expanduser()


def dotfiles_root() -> Path:
    env = os.environ.get("DOTFILES_DIR")
    if env:
        return Path(env).expanduser()
    return home() / "dotfiles"


def cache_dir() -> Path:
    path = Path(os.environ.get("AI_ORCH_CACHE", home() / ".cache/ai-orchestrator")).expanduser()
    path.mkdir(parents=True, exist_ok=True)
    return path


def session_index_path() -> Path:
    return cache_dir() / "session-index.json"


def codex_state_db() -> Path:
    return home() / ".codex/state_5.sqlite"


def pi_sessions_root() -> Path:
    return home() / ".pi/agent/sessions"
