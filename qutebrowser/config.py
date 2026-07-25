# ruff: noqa: F821, F822
# pyright: reportUndefinedVariable=false, reportGeneralTypeIssues=false

import os

config_dir = os.path.dirname(os.path.realpath(__file__))

config.load_autoconfig()
config.source(os.path.join(config_dir, "main.py"))
config.source(os.path.join(config_dir, "local.py"))
