from __future__ import annotations

import argparse
import json
import shutil
import sys

from orchestrator import __version__
from orchestrator.config import codex_state_db, pi_sessions_root
from orchestrator.sessions import format_row, pick_session, rebuild_index, resume_session, search_sessions


def cmd_session(args: argparse.Namespace) -> int:
    if args.session_cmd == "rebuild":
        sessions = rebuild_index(include_archived=args.all)
        print(f"indexed {len(sessions)} sessions")
        return 0

    sessions = search_sessions(args.query or "", rebuild=args.rebuild, include_archived=args.all)
    if args.repo:
        sessions = [item for item in sessions if args.repo.rstrip("/") in item.cwd.rstrip("/")]

    if args.session_cmd in {"list", "search"}:
        for item in sessions[: args.limit]:
            print(format_row(item))
        return 0

    if args.session_cmd == "pick":
        selected = pick_session(sessions)
        if selected is None:
            return 1
        print(format_row(selected))
        if args.resume:
            return resume_session(selected, dry_run=args.dry_run)
        return 0

    if args.session_cmd == "resume":
        target = args.session_id
        if not target:
            selected = pick_session(sessions)
            if selected is None:
                return 1
            return resume_session(selected, dry_run=args.dry_run)
        for item in sessions:
            if item.session_id == target or item.session_id.startswith(target):
                return resume_session(item, dry_run=args.dry_run)
        raise SystemExit(f"ai: session not found: {target}")

    if args.session_cmd == "show":
        target = args.session_id
        for item in sessions:
            if item.session_id == target or item.session_id.startswith(target):
                print(json.dumps(item.to_dict(), indent=2))
                return 0
        raise SystemExit(f"ai: session not found: {target}")

    raise SystemExit(f"ai: unknown session command: {args.session_cmd}")


def cmd_doctor(_: argparse.Namespace) -> int:
    checks = [
        ("codex-db", codex_state_db().is_file(), str(codex_state_db())),
        ("pi-sessions", pi_sessions_root().is_dir(), str(pi_sessions_root())),
        ("fzf", shutil.which("fzf") is not None, shutil.which("fzf") or "missing"),
        ("codex", shutil.which("codex") is not None, shutil.which("codex") or "missing"),
        ("pi", shutil.which("pi") is not None, shutil.which("pi") or "missing"),
        ("org-pi", shutil.which("org-pi") is not None, shutil.which("org-pi") or "missing"),
    ]
    ok = True
    for name, passed, detail in checks:
        status = "ok" if passed else "missing"
        if not passed and name in {"codex-db", "pi-sessions"}:
            ok = False
        print(f"{status}\t{name}\t{detail}")
    return 0 if ok else 1


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="ai",
        description="Cross-provider session finder for Codex and Pi native stores",
    )
    parser.add_argument("--version", action="version", version=f"ai {__version__}")
    sub = parser.add_subparsers(dest="command", required=True)

    session = sub.add_parser("session", help="Search and resume native agent sessions")
    session_sub = session.add_subparsers(dest="session_cmd", required=True)
    for name in ("list", "search"):
        p = session_sub.add_parser(name, help=f"{name} indexed sessions")
        p.add_argument("query", nargs="?", default="")
        p.add_argument("--repo")
        p.add_argument("--rebuild", action="store_true")
        p.add_argument("--all", action="store_true")
        p.add_argument("--limit", type=int, default=50)
        p.set_defaults(session_cmd=name)

    pick = session_sub.add_parser("pick", help="fzf pick a session")
    pick.add_argument("query", nargs="?", default="")
    pick.add_argument("--repo")
    pick.add_argument("--rebuild", action="store_true")
    pick.add_argument("--resume", action="store_true")
    pick.add_argument("--dry-run", action="store_true")
    pick.add_argument("--all", action="store_true")

    resume = session_sub.add_parser("resume", help="Resume a session by id or picker")
    resume.add_argument("session_id", nargs="?")
    resume.add_argument("--dry-run", action="store_true")
    resume.add_argument("--rebuild", action="store_true")

    show = session_sub.add_parser("show", help="Show one session as JSON")
    show.add_argument("session_id")

    rebuild = session_sub.add_parser("rebuild", help="Rebuild the session index cache")
    rebuild.add_argument("--all", action="store_true")

    sub.add_parser("doctor", help="Check session finder prerequisites")
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    if args.command == "session":
        return cmd_session(args)
    if args.command == "doctor":
        return cmd_doctor(args)
    parser.error(f"unknown command: {args.command}")
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
