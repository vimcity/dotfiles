from __future__ import annotations

import datetime as dt
import re
from pathlib import Path

from orchestrator.config import MANAGED_END, MANAGED_START, plans_dir
from orchestrator.org import Heading, infer_workdir, slugify


def default_plan_template(heading: Heading, org_file: Path, org_root: Path) -> str:
    today = dt.date.today().isoformat()
    try:
        relative_org = org_file.relative_to(org_root)
    except ValueError:
        relative_org = org_file
    workdir = infer_workdir(heading, org_root)
    body = "\n".join(heading.body_lines) or heading.title
    tool = "pi" if "dotfiles" in workdir or "org" in heading.title.lower() else "codex"
    return f"""# {heading.title}

Title: {heading.title}
Status: planned
Created: {today}
Source: `{relative_org}:{heading.line_number}`
Workdir: {workdir}
Tool: {tool}
Backend: herdr

## Objective

{heading.title}

## Org Context

```org
{body}
```

## Scope

- Clarify the smallest useful outcome.
- Identify the files, repos, or commands needed.
- Keep implementation notes here as work progresses.

## Plan

1. Inspect the current state.
2. Implement or document the smallest complete v1.
3. Validate the result.
4. Record outcome and next action.

{MANAGED_START}
## Snapshot

Updated: {today}

### Decisions

- Plan created from org headline.

### Current state

- Not started.

### Next action

- Launch a focused session from this plan.
{MANAGED_END}

## Progress

- {today}: Plan created from org headline.

## Next Action

- Run `ai plan launch --plan {plans_dir().name}/{slugify(heading.title)}.md`.
"""


def write_plan(plan_path: Path, org_file: Path, org_root: Path, heading: Heading, *, force: bool = False) -> bool:
    if plan_path.exists() and not force:
        return False
    plan_path.parent.mkdir(parents=True, exist_ok=True)
    plan_path.write_text(default_plan_template(heading, org_file, org_root), encoding="utf-8")
    return True


def plan_path_for_heading(heading: Heading) -> Path:
    return plans_dir() / f"{slugify(heading.title)}.md"


def parse_plan_fields(text: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    for key in ("Title", "Status", "Workdir", "Tool", "Backend", "Source"):
        match = re.search(rf"^{key}:\s*(.+)$", text, flags=re.MULTILINE)
        if match:
            fields[key.lower()] = match.group(1).strip()
    return fields


def update_managed_snapshot(plan_path: Path, snapshot_md: str) -> None:
    text = plan_path.read_text(encoding="utf-8")
    block = f"{MANAGED_START}\n{snapshot_md.strip()}\n{MANAGED_END}"
    if MANAGED_START in text and MANAGED_END in text:
        pattern = re.compile(re.escape(MANAGED_START) + r".*?" + re.escape(MANAGED_END), re.DOTALL)
        text = pattern.sub(block, text, count=1)
    else:
        text = text.rstrip() + "\n\n" + block + "\n"
    plan_path.write_text(text, encoding="utf-8")


def render_snapshot(*, decisions: list[str], state: str, next_action: str) -> str:
    today = dt.date.today().isoformat()
    decisions_md = "\n".join(f"- {item}" for item in decisions) or "- None recorded."
    return f"""## Snapshot

Updated: {today}

### Decisions

{decisions_md}

### Current state

{state.strip()}

### Next action

{next_action.strip()}"""
