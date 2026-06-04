# ruff: noqa: F821, F822
# pyright: reportUndefinedVariable=false, reportGeneralTypeIssues=false

from pathlib import Path


def source(filename: str) -> None:
    path = Path(__file__).with_name(filename)
    if path.exists():
        exec(compile(path.read_text(), str(path), "exec"), globals())


config.load_autoconfig()
source("main.py")
source("local.py")
