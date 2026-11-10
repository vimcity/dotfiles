import os
import stat
import subprocess
import sys

pid, key = sys.argv[1:]
processes = subprocess.run(
    ["ps", "-axo", "pid=,ppid=,comm="], capture_output=True, text=True, check=True,
)
pids = {int(pid)}
rows = [line.split(None, 2) for line in processes.stdout.splitlines()]
while True:
    children = {
        int(row[0]) for row in rows
        if len(row) == 3 and int(row[1]) in pids and os.path.basename(row[2]) == "nvim"
    }
    if children <= pids:
        break
    pids.update(children)
result = subprocess.run(
    ["/usr/sbin/lsof", "-a", "-p", ",".join(str(value) for value in sorted(pids)), "-U", "-Fn"],
    capture_output=True, text=True, check=True,
)
sockets = []
for line in result.stdout.splitlines():
    if not line.startswith("n/"):
        continue
    path = line[1:]
    try:
        if stat.S_ISSOCK(os.stat(path).st_mode) and path not in sockets:
            sockets.append(path)
    except FileNotFoundError:
        continue
if not sockets:
    sys.exit("Neovim has no listening socket; reopen this Neovim instance")
socket = next((path for path in sockets if "nvim" in path), sockets[0])
result = subprocess.run(
    ["nvim", "--server", socket, "--remote-expr", f"nvim_input('{key}')"],
    capture_output=True, text=True,
)
if result.returncode:
    sys.exit(result.stderr or "Neovim input failed")
print(socket)
