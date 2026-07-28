#!/usr/bin/env python3
import json
import math
import os
import re
import shutil
import signal
import socket
import subprocess
import sys
import time
from datetime import datetime


RUNNING = True


def handle_signal(_signum, _frame):
    global RUNNING
    RUNNING = False


for sig in (signal.SIGINT, signal.SIGTERM):
    signal.signal(sig, handle_signal)


def run(cmd):
    try:
        return subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL)
    except Exception:
        return ""


def cpu_percent():
    output = run(["top", "-l", "1", "-n", "0"])
    match = re.search(r"CPU usage:\s+([0-9.]+)% user,\s+([0-9.]+)% sys", output)
    if not match:
        return None
    return float(match.group(1)) + float(match.group(2))


def memory_stats():
    total_bytes_raw = run(["sysctl", "-n", "hw.memsize"]).strip()
    vm_stat = run(["vm_stat"])
    if not total_bytes_raw or not vm_stat:
        return None

    total_bytes = int(total_bytes_raw)
    page_size_match = re.search(r"page size of (\d+) bytes", vm_stat)
    if not page_size_match:
        return None
    page_size = int(page_size_match.group(1))

    values = {}
    for line in vm_stat.splitlines():
        match = re.match(r"([^:]+):\s+([0-9.]+)", line)
        if match:
            values[match.group(1)] = int(float(match.group(2)))

    free_pages = values.get("Pages free", 0) + values.get("Pages speculative", 0)
    used_bytes = max(total_bytes - (free_pages * page_size), 0)
    used_pct = (used_bytes / total_bytes) * 100 if total_bytes else 0
    return {
        "total_gb": total_bytes / (1024 ** 3),
        "used_gb": used_bytes / (1024 ** 3),
        "used_pct": used_pct,
    }


def mpv_status():
    sock_path = "/tmp/mpv.sock"
    if not os.path.exists(sock_path):
        return None
    try:
        conn = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        conn.settimeout(0.5)
        conn.connect(sock_path)
    except OSError:
        return None

    def query(prop):
        payload = json.dumps({"command": ["get_property", prop]}).encode() + b"\n"
        conn.sendall(payload)
        data = b""
        while not data.endswith(b"\n"):
            chunk = conn.recv(4096)
            if not chunk:
                break
            data += chunk
        if not data:
            return None
        try:
            return json.loads(data.decode()).get("data")
        except Exception:
            return None

    try:
        title = query("media-title") or query("filename")
        paused = query("pause")
        position = query("time-pos") or 0
        duration = query("duration") or 0
        volume = query("volume")
        return {
            "title": title,
            "paused": bool(paused),
            "position": float(position or 0),
            "duration": float(duration or 0),
            "volume": volume,
        }
    finally:
        conn.close()


def bar(label, pct, width, color):
    pct = max(0.0, min(100.0, pct))
    filled = int((pct / 100.0) * width)
    empty = max(width - filled, 0)
    return f"{label:<6} {color}{'█' * filled}\033[0m{'░' * empty} {pct:5.1f}%"


def format_time(seconds):
    seconds = int(seconds)
    return f"{seconds // 60}:{seconds % 60:02d}"


def equalizer_frame(tick, paused):
    if paused:
        heights = [2, 3, 4, 3, 2, 2, 3, 4]
    else:
        heights = [
            1 + int((math.sin((tick / 2.0) + idx) + 1) * 3)
            for idx in range(8)
        ]
    blocks = "▁▂▃▄▅▆▇█"
    return "".join(blocks[min(h, len(blocks) - 1)] for h in heights)


def terminal_size():
    size = shutil.get_terminal_size((100, 28))
    return size.columns, size.lines


def clear():
    sys.stdout.write("\033[2J\033[H")


def render():
    tick = 0
    while RUNNING:
        columns, _ = terminal_size()
        cpu = cpu_percent()
        mem = memory_stats()
        mpv = mpv_status()
        now = datetime.now().strftime("%H:%M:%S")

        clear()
        print(f"\033[1;38;5;111m󰆍  Herdr Dashboard\033[0m    \033[38;5;245m{now}\033[0m")
        print("\033[38;5;240m" + ("─" * min(columns, 100)) + "\033[0m")

        if cpu is not None:
            print(bar("CPU", cpu, 32, "\033[38;5;117m"))
        else:
            print("CPU    unavailable")

        if mem is not None:
            print(bar("MEM", mem["used_pct"], 32, "\033[38;5;183m"))
            print(
                f"       \033[38;5;245m{mem['used_gb']:.1f} GiB / {mem['total_gb']:.1f} GiB used\033[0m"
            )
        else:
            print("MEM    unavailable")

        print("")
        print("\033[1;38;5;229m󰎆  Media\033[0m")
        if mpv is None:
            print("\033[38;5;245mNo mpv IPC at /tmp/mpv.sock\033[0m")
        else:
            state_icon = "" if mpv["paused"] else ""
            title = mpv["title"] or "unknown"
            print(f"{state_icon}  {title}")
            if mpv["duration"] > 0:
                pct = (mpv["position"] / mpv["duration"]) * 100
                print(bar("POS", pct, 32, "\033[38;5;151m"))
                print(
                    f"       \033[38;5;245m{format_time(mpv['position'])} / {format_time(mpv['duration'])}\033[0m"
                )
            if mpv["volume"] is not None:
                print(f"VOL    {mpv['volume']:>5.1f}%")
            print(f"EQ     \033[38;5;213m{equalizer_frame(tick, mpv['paused'])}\033[0m")

        print("")
        print("\033[38;5;245mClose the pane to dismiss. Popup shell uses the same plugin.\033[0m")

        sys.stdout.flush()
        tick += 1
        time.sleep(1.0)


if __name__ == "__main__":
    try:
        render()
    finally:
        sys.stdout.write("\033[0m")
