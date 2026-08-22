#!/usr/bin/env python3
"""Analyse cache performance from a Pi session log.

Usage:
  pi-cache-debug.py [session-id-or-path]
  pi-cache-debug.py  # list recent sessions
"""

import glob
import json
import os
import sys


def find_session(query):
    """Find a session file by ID or path."""
    if os.path.isfile(query):
        return query
    base = os.path.expanduser("~/.pi/agent/sessions")
    for root, dirs, files in os.walk(base):
        for f in files:
            if query in f and f.endswith(".jsonl"):
                return os.path.join(root, f)
    return None


def list_sessions():
    """List recent sessions."""
    base = os.path.expanduser("~/.pi/agent/sessions")
    files = sorted(glob.glob(f"{base}/**/*.jsonl", recursive=True), reverse=True)[:10]
    print("Recent sessions:")
    for f in files:
        name = os.path.basename(f).replace(".jsonl", "")
        size = os.path.getsize(f)
        print(f"  {name}  ({size / 1024:.0f} KB)")
    print()
    print("Usage: pi-cache-debug.py <session-id>")
    print("   or: pi-cache-debug.py /path/to/session.jsonl")


def analyse(filepath):
    """Analyse a session log file."""
    with open(filepath) as f:
        lines = [json.loads(l) for l in f if l.strip()]

    # Session info
    for l in lines:
        if l.get("type") == "session":
            print(f"Session: {l['id']}")
            print(f"Started: {l['timestamp']}")
            break
    for l in lines:
        if l.get("type") == "model_change":
            print(f"Provider: {l.get('provider', '?')}")
            print(f"Model: {l.get('modelId', '?')}")
            break

    print()
    print(
        f"{'Turn':<8} {'Gap':<12} {'cacheRead':>10} {'input':>8} {'output':>6} {'status':<12}"
    )
    print("-" * 65)

    prev_ts = None
    first_assistant = True
    misses = []

    for l in lines:
        if l.get("type") == "message" and l["message"].get("role") == "assistant":
            raw_ts = l.get("timestamp", 0)
            ts = 0
            if isinstance(raw_ts, (int, float)):
                ts = raw_ts
            elif isinstance(raw_ts, str):
                try:
                    from datetime import datetime

                    dt = datetime.fromisoformat(raw_ts.replace("Z", "+00:00"))
                    ts = dt.timestamp() * 1000
                except:
                    pass

            usage = l["message"].get("usage", {})
            read = usage.get("cacheRead", 0)
            inp = usage.get("input", 0)
            out = usage.get("output", 0)
            reason = l["message"].get("stopReason", "?")
            msg_id = l["id"][:8]

            gap = ""
            if prev_ts and ts:
                delta = (ts - prev_ts) / 1000
                if delta > 60:
                    gap = f"{int(delta // 60)}m{int(delta % 60)}s"
                else:
                    gap = f"{int(delta)}s"
            prev_ts = ts

            is_miss = False
            if not first_assistant and read == 0:
                is_miss = True
                misses.append((msg_id, gap, read, inp))
            first_assistant = False

            marker = " 󰔄" if is_miss else "  "
            print(
                f"{msg_id:<8} {gap:<12} {read:>10} {inp:>8} {out:>6} {reason:<12}{marker}"
            )

    if misses:
        print()
        n = len(misses)
        print(f"󰀪 {n} cache miss(es) detected")
        for m in misses:
            print(f"  Turn {m[0]} (gap={m[1]}) — cacheRead={m[2]}, input={m[3]}")
        print()
        print("Causes:")
        print(
            "  1. Extension before_agent_start hook → check if it modifies systemPrompt"
        )
        print(
            "  2. Extension injects custom messages → changes messages prefix, busts cache"
        )
        print("  3. Idle gap > 5-10 min → provider cache may have expired")
        print("  4. Model/provider change mid-session")
        print("  5. Normal — first turn of a session is always cold")
    else:
        print()
        print("󰄬 Cache warm — no misses")


if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] in ("-h", "--help", "help"):
        list_sessions()
        sys.exit(0)

    query = sys.argv[1]
    fp = find_session(query)
    if not fp:
        print(f"Session not found: {query}")
        sys.exit(1)
    analyse(fp)
