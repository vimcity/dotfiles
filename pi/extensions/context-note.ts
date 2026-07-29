import { appendFile, mkdir, stat } from "node:fs/promises";
import { dirname } from "node:path";
import { homedir } from "node:os";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const notePath = `${homedir()}/Documents/org/notes.md`;

export default function (pi: ExtensionAPI) {
	pi.registerCommand("note", {
		description: "Save a concise durable note",
		handler: async (args, ctx) => {
			const text = args.trim();
			if (!text) return ctx.ui.notify("Usage: /note <text>", "warning");
			await mkdir(dirname(notePath), { recursive: true });
			try { await stat(notePath); } catch {
				await appendFile(notePath, "# Notes\n\nDurable bullets for local agents. Read only when relevant.\n\n");
			}
			await appendFile(notePath, `- ${new Date().toISOString().slice(0, 16).replace("T", " ")} — ${text}\n`);
			ctx.ui.notify(`Saved note to ${notePath}`, "info");
		},
	});
}
