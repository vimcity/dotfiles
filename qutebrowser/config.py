# ruff: noqa: F821, F822
# pyright: reportUndefinedVariable=false, reportGeneralTypeIssues=false

import os

config.load_autoconfig()
config.source(os.path.join(os.path.dirname(__file__), "main.py"))
config.source(os.path.join(os.path.dirname(__file__), "local.py"))
