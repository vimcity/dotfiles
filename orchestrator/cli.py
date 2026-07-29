from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path

from orchestrator import __version__
from orchestrator.config import codex_state_db, org_file, org_root, pi_sessions_root, plans_dir
from orchestrator.herdr import HerdrError, launch_plan
from orchestrator.org import candidate_headings, infer_workdir, update_org_heading
from orchestrator.plans import plan_path_for_heading, render_snapshot, update_managed_snapshot, write_plan
from orchestrator.sessions import format_row, pick_session, rebuild_index, resume_session, search_sessions
from orchestrator.tasks import append_session_link, create_task, task_path


def _choose_heading(headings, selector: str):
    from orchestrator.org import Heading

    if not headings:
        raise SystemExit("ai: no active top-level :ai:/:agent: org tasks found")
    if selector == "first":
        return headings[0]
    if selector.isdigit():
        line = int(selector)
        for heading in headings:
            if heading.line_number == line:
                return heading
        raise SystemExit(f"ai: no org heading at line {line}")
    if selector != "fzf":
        raise SystemExit(f"ai: unknown selector: {selector}")
    if not sys.stdin.isatty() or shutil.which("fzf") is None:
        return headings[0]
    choices = "\n".join(f"{item.line_number}\t{item.state}\t{item.title}" for item in headings)
    result = subprocess.run(
        ["fzf", "--delimiter=\t", "--with-nth=1..", "--prompt=ai org task> "],
        input=choices,
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0 or not result.stdout.strip():
        raise SystemExit("ai: no org task selected")
    return _choose_heading(headings, result.stdout.split("\t", 1)[0])


def cmd_session(args: argparse.Namespace) -> int:
    if args.session_cmd == "rebuild":
        sessions = rebuild_index(include_archived=args.all)
        print(f"indexed {len(sessions)} sessions -> rebuilt cache")
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


def cmd_plan(args: argparse.Namespace) -> int:
    org_path = org_root()
    org = org_file()
    headings = candidate_headings(org)

    if args.plan_cmd == "list":
        for heading in headings:
            plan = heading.existing_plan or "-"
            print(f"{heading.line_number}\t{heading.state}\t{heading.title}\t{plan}")
        return 0

    heading = _choose_heading(headings, args.select)
    plan_path = plan_path_for_heading(heading)
    if args.plan_path:
        plan_path = Path(args.plan_path).expanduser()

    if args.plan_cmd == "create":
        created = write_plan(plan_path, org, org_path, heading, force=args.force)
        rel = plan_path.relative_to(org_path)
        update_org_heading(org, heading, str(rel))
        print(str(plan_path))
        print("created" if created else "exists")
        return 0

    if args.plan_cmd == "show":
        if not plan_path.is_file():
            raise SystemExit(f"ai: plan missing: {plan_path}")
        print(plan_path.read_text(encoding="utf-8"))
        return 0

    if args.plan_cmd == "snapshot":
        if not plan_path.is_file():
            raise SystemExit(f"ai: plan missing: {plan_path}")
        snapshot = render_snapshot(
            decisions=args.decision or [],
            state=args.state or "In progress.",
            next_action=args.next or "Continue the current plan.",
        )
        if args.dry_run:
            print(snapshot)
            return 0
        update_managed_snapshot(plan_path, snapshot)
        print(plan_path)
        return 0

    if args.plan_cmd == "launch":
        if not plan_path.is_file():
            write_plan(plan_path, org, org_path, heading, force=False)
        if args.dry_run:
            fields = plan_path.read_text(encoding="utf-8")
            print(f"would launch {plan_path}")
            print(fields.splitlines()[0:8])
            return 0
        if args.backend != "herdr":
            raise SystemExit("ai: only herdr backend is implemented in dotfiles orchestrator")
        try:
            payload = launch_plan(plan_path, agent_name=args.agent)
        except HerdrError as exc:
            raise SystemExit(f"ai: {exc}") from exc
        print(json.dumps(payload, indent=2))
        return 0

    raise SystemExit(f"ai: unknown plan command: {args.plan_cmd}")


def cmd_task(args: argparse.Namespace) -> int:
    if args.task_cmd == "create":
        path = create_task(args.title, repo=args.repo or "", agent=args.agent, status=args.status)
        print(path)
        return 0

    if args.task_cmd == "link-session":
        path = task_path(args.title)
        if not path.is_file():
            raise SystemExit(f"ai: task missing: {path}")
        append_session_link(path, args.provider, args.session_id)
        print(path)
        return 0

    if args.task_cmd == "list":
        for path in sorted(Path(org_root() / "ai-tasks").glob("*.md")):
            print(path.name)
        return 0

    raise SystemExit(f"ai: unknown task command: {args.task_cmd}")


def cmd_doctor(_: argparse.Namespace) -> int:
    checks = [
        ("codex-db", codex_state_db().is_file(), str(codex_state_db())),
        ("pi-sessions", pi_sessions_root().is_dir(), str(pi_sessions_root())),
        ("org-file", org_file().is_file(), str(org_file())),
        ("plans-dir", plans_dir().is_dir(), str(plans_dir())),
        ("fzf", shutil.which("fzf") is not None, shutil.which("fzf") or "missing"),
        ("herdr", shutil.which("herdr") is not None, shutil.which("herdr") or "missing"),
        ("codex", shutil.which("codex") is not None, shutil.which("codex") or "missing"),
        ("pi", shutil.which("pi") is not None, shutil.which("pi") or "missing"),
    ]
    ok = True
    for name, passed, detail in checks:
        status = "ok" if passed else "missing"
        if not passed and name in {"codex-db", "pi-sessions", "org-file"}:
            ok = False
        print(f"{status}\t{name}\t{detail}")
    return 0 if ok else 1


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="ai", description="Terminal-native AI orchestrator")
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

    plan = sub.add_parser("plan", help="Org-backed plan create/update/launch")
    plan_sub = plan.add_subparsers(dest="plan_cmd", required=True)
    for name, help_text in (
        ("list", "List org AI tasks"),
        ("create", "Create plan from org heading"),
        ("show", "Print plan markdown"),
        ("snapshot", "Update managed snapshot section"),
        ("launch", "Launch plan in Herdr"),
    ):
        p = plan_sub.add_parser(name, help=help_text)
        p.add_argument("--select", default="fzf")
        p.add_argument("--plan", dest="plan_path")
        if name == "create":
            p.add_argument("--force", action="store_true")
        if name == "snapshot":
            p.add_argument("--decision", action="append")
            p.add_argument("--state")
            p.add_argument("--next")
            p.add_argument("--dry-run", action="store_true")
        if name == "launch":
            p.add_argument("--backend", default="herdr", choices=["herdr"])
            p.add_argument("--agent")
            p.add_argument("--dry-run", action="store_true")

    task = sub.add_parser("task", help="Compact durable task files")
    task_sub = task.add_subparsers(dest="task_cmd", required=True)
    create = task_sub.add_parser("create", help="Create ai-tasks markdown file")
    create.add_argument("title")
    create.add_argument("--repo")
    create.add_argument("--agent", default="codex")
    create.add_argument("--status", default="active")
    link = task_sub.add_parser("link-session", help="Attach a native session id to a task")
    link.add_argument("title")
    link.add_argument("provider")
    link.add_argument("session_id")
    task_sub.add_parser("list", help="List task files")

    sub.add_parser("doctor", help="Check orchestrator prerequisites")
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    if args.command == "session":
        return cmd_session(args)
    if args.command == "plan":
        return cmd_plan(args)
    if args.command == "task":
        return cmd_task(args)
    if args.command == "doctor":
        return cmd_doctor(args)
    parser.error(f"unknown command: {args.command}")
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
