from __future__ import annotations

from dataclasses import asdict, dataclass


@dataclass(frozen=True)
class SessionRecord:
    provider: str
    session_id: str
    title: str
    cwd: str
    updated_at: int
    preview: str = ""
    model: str = ""
    branch: str = ""
    resume_cmd: str = ""
    archived: bool = False

    def to_dict(self) -> dict:
        return asdict(self)

    @classmethod
    def from_dict(cls, data: dict) -> SessionRecord:
        return cls(**data)
