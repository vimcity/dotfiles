from __future__ import annotations

import json
import subprocess
from pathlib import Path

from orchestrator.org import slugify
from orchestrator.plans import parse_plan_fields


class HerdrError(RuntimeError):
    pass


def _require_herdr() -> None:
    if subprocess.run(["herdr", "--help"], capture_output=True, check=False).returncode != 0:
        raise HerdrError("herdr CLI not available")


def _run_json(args: list[str]) -> dict:
    result = subprocess.run(["herdr", *args], capture_output=True, text=True, check=False)
    if result.returncode != 0:
        message = result.stderr.strip() or result.stdout.strip() or "herdr command failed"
        raise HerdrError(message)
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as exc:
        raise HerdrError(f"invalid herdr JSON output: {exc}") from exc


def split_pane(workdir: str, direction: str = "right") -> str:
    payload = _run_json(
        [
            "pane",
            "split",
            "--current",
            "--direction",
            direction,
            "--cwd",
            workdir,
            "--no-focus",
        ]
    )
    return payload["result"]["pane"]["pane_id"]


def start_agent(name: str, kind: str, pane_id: str, extra_args: list[str] | None = None) -> None:
    args = ["agent", "start", name, "--kind", kind, "--pane", pane_id]
    if extra_args:
        args.extend(["--", *extra_args])
    _run_json(args)


def prompt_agent(name: str, prompt: str, *, wait: bool = True, timeout_ms: int = 120000) -> dict:
    args = ["agent", "prompt", name, prompt]
    if wait:
        args.extend(["--wait", "--timeout", str(timeout_ms)])
    return _run_json(args)


def launch_plan(plan_path: Path, *, agent_name: str | None = None) -> dict:
    _require_herdr()
    fields = parse_plan_fields(plan_path.read_text(encoding="utf-8"))
    workdir = fields.get("workdir", str(Path.home()))
    tool = fields.get("tool", "codex").lower()
    name = agent_name or slugify(plan_path.stem)[:32]
    kind = "pi" if tool == "pi" else "codex"
    extra: list[str] = []
    if kind == "codex" and fields.get("backend", "herdr") == "herdr":
        extra = ["--profile", "local"]

    pane_id = split_pane(workdir)
    start_agent(name, kind, pane_id, extra_args=extra or None)
    prompt = f"Read and execute the plan at {plan_path}. Start with the smallest useful step and keep notes in the plan managed snapshot when milestones land."
    result = prompt_agent(name, prompt, wait=False)
    return {
        "agent": name,
        "kind": kind,
        "pane_id": pane_id,
        "workdir": workdir,
        "prompt_result": result,
    }
