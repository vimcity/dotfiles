// rex-resume — record agent session state when Rex panes start.
// Calls `rex-resume record` on session_start and session_switch so that
// coding agents survive a Rex server restart or reboot.
//
// Only active when running inside a Rex pane (REX_SESSION + REX_BLOCK set).

import { execFile } from "node:child_process";
import { promisify } from "node:util";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const execFileAsync = promisify(execFile);
const REX_RESUME_BIN = process.env.HOME + "/.local/bin/rex-resume";
const rexSession = process.env.REX_SESSION;
const rexBlock = process.env.REX_BLOCK;

function inRex(): boolean {
  return typeof rexSession === "string" && rexSession.length > 0;
}

function recordSession(ctx: any): void {
  if (!inRex()) return;

  const sessionFile = ctx?.sessionManager?.getSessionFile?.();
  const env: Record<string, string> = {
    REX_SESSION: rexSession!,
    REX_BLOCK: rexBlock ?? "",
    REX_RESUME_AGENT: "pi",
  };

  if (typeof sessionFile === "string" && sessionFile.length > 0) {
    env.PI_SESSION_FILE = sessionFile;
  }

  void execFileAsync(REX_RESUME_BIN, ["record"], { env }, (err) => {
    if (err) {
      // Silently fail — rex-resume is best-effort.
    }
  });
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    recordSession(ctx);
  });

  pi.on("session_switch", async (_event, ctx) => {
    recordSession(ctx);
  });
}
