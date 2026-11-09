import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import tempfile


SOURCE = Path(__file__).resolve().parent
GENERATED = {"gpui-kit.d.ts", "herdr.d.ts", "jsconfig.json"}


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else None


def files(source):
    manifest = json.loads((source / "deploy.json").read_text())
    entries = {name: "link" for name in manifest["linked"]}
    for mod in manifest["mods"]:
        for path in sorted((source / "mods" / mod).rglob("*")):
            if path.is_file() and path.name not in GENERATED and not any(part.startswith(".") for part in path.relative_to(source / "mods" / mod).parts):
                entries[str(path.relative_to(source))] = "copy"
    return entries, manifest["retired"]


def write_state(path, value):
    with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as file:
        temporary = Path(file.name)
        try:
            json.dump(value, file, indent=2)
            file.close()
            temporary.replace(path)
        finally:
            temporary.unlink(missing_ok=True)


def deploy(source, home, backups, check=False):
    entries, retired = files(source)
    state_path = home / "data/dotfiles-deploy.json"
    state = json.loads(state_path.read_text()) if state_path.exists() else {}
    changes, conflicts = [], []
    for name, mode in entries.items():
        src, dst = source / name, home / name
        correct = (dst.is_symlink() and dst.resolve() == src.resolve()) if mode == "link" else (
            dst.is_file() and not dst.is_symlink() and digest(dst) == digest(src))
        if correct:
            continue
        changes.append(name)
        previous = state.get(name)
        # Managed copies may be refreshed only if nobody edited the deployed file.
        if previous and previous["mode"] == "copy" and dst.exists() and digest(dst) != previous["sha256"]:
            conflicts.append(name)
    stale = [name for name in state if name not in entries and (home / name).exists()]
    for name in stale:
        if digest(home / name) != state[name]["sha256"]:
            conflicts.append(name)
    old_mods = [f"mods/{name}" for name in retired if (home / "mods" / name).exists()]
    if check:
        for name in changes + stale + old_mods:
            print(f"DRIFT {name}")
        return not (changes or stale or old_mods)
    if conflicts:
        raise ValueError("Live edits need reconciliation before deployment: " + ", ".join(conflicts))
    # Preflight completes before any live file is changed. Every replacement is retained.
    backups.mkdir(parents=True, exist_ok=True)
    batch = None

    def backup(name):
        nonlocal batch
        target = home / name
        if not target.exists() and not target.is_symlink():
            return
        if batch is None:
            batch = Path(tempfile.mkdtemp(prefix="deploy-", dir=backups))
        saved = batch / name
        saved.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(target), saved)

    for name in changes:
        src, dst = source / name, home / name
        dst.parent.mkdir(parents=True, exist_ok=True)
        if entries[name] == "link":
            backup(name)
            dst.symlink_to(src)
        else:
            with tempfile.NamedTemporaryFile(dir=dst.parent, delete=False) as file:
                temporary = Path(file.name)
            try:
                shutil.copy2(src, temporary)
                backup(name)
                temporary.replace(dst)
            finally:
                temporary.unlink(missing_ok=True)
        print(f"Updated {name}")
    for name in stale + old_mods:
        backup(name)
        print(f"Retired {name}")
    state_path.parent.mkdir(parents=True, exist_ok=True)
    write_state(state_path, {name: {"mode": mode, "sha256": digest(source / name)} for name, mode in entries.items()})
    if batch:
        print(f"Previous files: {batch}")
    return True


def main():
    parser = argparse.ArgumentParser(description="Deploy Herdr customizations; --check reports drift without writing.")
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    config = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
    home = Path(os.environ.get("HERDR_APP_HOME", config / "herdr-app"))
    backups = Path(os.environ.get("HERDR_BACKUP_HOME", str(home) + "-backups"))
    try:
        return 0 if deploy(SOURCE, home, backups, args.check) else 1
    except ValueError as error:
        parser.exit(1, f"{error}\n")


if __name__ == "__main__":
    raise SystemExit(main())
