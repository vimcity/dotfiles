import { appendFile } from "node:fs/promises";
import { homedir } from "node:os";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const orgFile = process.env.AI_TASK_ORG_FILE ?? `${homedir()}/Documents/org/todos.org`;

export default function (pi: ExtensionAPI) {
  pi.registerCommand("park", {
    description: "Add this Pi session to Org with its resume command",
    handler: async (args, ctx) => {
      const title = (args.trim() || (await ctx.ui.input("Task name", "What should you resume later?")) || "").trim();
      if (!title) {
        ctx.ui.notify("Session not parked", "warning");
        return;
      }

      const cleanTitle = title.replace(/[\r\n]+/g, " ");
      const sessionId = ctx.sessionManager.getSessionId();
      const entry = `\n* TODO ${cleanTitle}\n  :RESUME: pi --session ${sessionId}\n`;
      await appendFile(orgFile, entry);
      ctx.ui.notify(`Parked: ${cleanTitle}`, "info");
    },
  });
}
