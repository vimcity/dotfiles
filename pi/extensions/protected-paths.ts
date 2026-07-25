/** Blocks accidental writes to secrets, Git internals, and installed dependencies. */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	const protectedPaths = [".env", ".git/", "node_modules/", ".ssh/", ".aws/", ".gnupg/"];

	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName !== "write" && event.toolName !== "edit") return undefined;

		const path = event.input.path as string;
		if (!protectedPaths.some((protectedPath) => path.includes(protectedPath))) return undefined;

		if (ctx.hasUI) ctx.ui.notify(`Blocked write to protected path: ${path}`, "warning");
		return { block: true, reason: `Path \"${path}\" is protected` };
	});
}
