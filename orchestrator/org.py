from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Heading:
    line_number: int
    level: int
    state: str
    title: str
    tags: frozenset[str]
    body_lines: tuple[str, ...]
    existing_plan: str | None = None

    @property
    def has_ai_tag(self) -> bool:
        return bool(self.tags & {"ai", "agent", "workbench"})


def slugify(value: str) -> str:
    slug = re.sub(r"[^a-zA-Z0-9]+", "-", value.strip().lower()).strip("-")
    return slug or "task"


def parse_headings(lines: list[str]) -> list[Heading]:
    headings: list[Heading] = []
    current: Heading | None = None
    for index, raw in enumerate(lines, start=1):
        match = re.match(r"^(\*+)\s+(TODO|PROGRESS|DONE|WAITING|SCHEDULED|CANCELLED)\s+(.+)$", raw)
        if match:
            stars, state, rest = match.groups()
            title, _, tag_blob = rest.partition(":")
            tags = frozenset(re.findall(r":([a-zA-Z0-9_-]+):", f":{tag_blob}:"))
            plan_match = re.search(r"\[\[file:([^\]]+\.md)\]\[plan\]\]", rest)
            existing_plan = plan_match.group(1) if plan_match else None
            current = Heading(
                line_number=index,
                level=len(stars),
                state=state,
                title=title.strip(),
                tags=tags,
                body_lines=(),
                existing_plan=existing_plan,
            )
            headings.append(current)
            continue
        if current and raw.startswith("- "):
            current = Heading(
                line_number=current.line_number,
                level=current.level,
                state=current.state,
                title=current.title,
                tags=current.tags,
                body_lines=current.body_lines + (raw,),
                existing_plan=current.existing_plan,
            )
            headings[-1] = current
    return headings


def candidate_headings(org_file: Path) -> list[Heading]:
    if not org_file.is_file():
        return []
    lines = org_file.read_text(encoding="utf-8").splitlines()
    return [item for item in parse_headings(lines) if item.level == 1 and item.has_ai_tag and item.state in {"TODO", "PROGRESS"}]


def infer_workdir(heading: Heading, org_root: Path) -> str:
    for line in heading.body_lines:
        match = re.search(r"(~/[^\s]+|/Users/[^\s]+)", line)
        if match:
            return str(Path(match.group(1)).expanduser())
    title = heading.title.lower()
    if "dotfiles" in title:
        return str(org_root.parent / "dotfiles")
    return str(Path.home() / "Projects")


def update_org_heading(org_file: Path, heading: Heading, plan_rel: str) -> None:
    lines = org_file.read_text(encoding="utf-8").splitlines()
    index = heading.line_number - 1
    if index >= len(lines):
        raise ValueError(f"heading line out of range: {heading.line_number}")
    line = lines[index]
    if "[[file:" in line and "[plan]" in line:
        lines[index] = re.sub(r"\[\[file:[^\]]+\]\[plan\]\]", f"[[file:{plan_rel}][plan]]", line)
    else:
        lines[index] = f"{line} [[file:{plan_rel}][plan]]"
    org_file.write_text("\n".join(lines) + "\n", encoding="utf-8")
