import fcntl
import json
import os
from pathlib import Path
import sys
import tempfile


MIN_SIZE = 8
MAX_SIZE = 40


def write_json(path, value):
    permissions = path.stat().st_mode & 0o777 if path.exists() else 0o600
    with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as file:
        temporary = Path(file.name)
        try:
            json.dump(value, file, indent=2)
            file.write("\n")
            file.flush()
            os.chmod(temporary, permissions)
            os.replace(temporary, path)
        finally:
            temporary.unlink(missing_ok=True)


def change_font(app_home, action):
    if action not in {"in", "out", "reset"}:
        raise ValueError("Expected in, out or reset")
    app_home = Path(app_home)
    data = app_home / "data"
    data.mkdir(exist_ok=True)
    with (data / "terminal-zoom.lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        settings_file = app_home / "settings.json"
        target = settings_file.resolve(strict=True)
        settings = json.loads(target.read_text())
        current = float(settings.get("font_size", 14))
        state_file = data / "terminal-zoom.json"
        state = json.loads(state_file.read_text()) if state_file.exists() else {"base_font_size": current}
        size = float(state["base_font_size"]) if action == "reset" else current + (1 if action == "in" else -1)
        size = max(MIN_SIZE, min(MAX_SIZE, size))
        if not state_file.exists():
            write_json(state_file, state)
        if size == current:
            return size
        settings["font_size"] = size
        write_json(target, settings)
        if settings_file.is_symlink():
            temporary = app_home / f".settings-zoom-{os.getpid()}"
            try:
                temporary.symlink_to(os.readlink(settings_file))
                os.replace(temporary, settings_file)
            finally:
                temporary.unlink(missing_ok=True)
        return size


if __name__ == "__main__":
    print(change_font(sys.argv[1], sys.argv[2]))
