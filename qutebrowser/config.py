# ruff: noqa: F821
# pyright: reportUndefinedVariable=false, reportGeneralTypeIssues=false

import os

config_dir = os.path.dirname(os.path.realpath(__file__))

config.load_autoconfig()
config.source(os.path.join(config_dir, "main.py"))
local_config = os.path.join(config_dir, "local.py")
if os.path.isfile(local_config):
    config.source(local_config)
