/**
 * Confirmation gate for destructive or privilege-escalating shell commands.
 * Non-interactive Pi runs block these commands by default.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	const dangerousPatterns = [
		/\bsudo\b/i,
		/\b(chmod|chown)\b.*777/i,
		/\bgit\s+(reset\s+--hard|clean\b|push\s+.*--force)/i,
	];

	const homeOrRootRemoval =
		/^\s*rm\s+(?:-[rf]+\s+)+(?:\/|\~(?:\/|\s|$)|\$HOME(?:\/|\s|$)|\/Users\/[^/]+\/?(?:\s|$))/i;

	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName !== "bash") return undefined;

		const command = event.input.command as string;
		if (homeOrRootRemoval.test(command) || dangerousPatterns.some((pattern) => pattern.test(command))) {
			// Continue through the confirmation/block path below.
		} else {
			return undefined;
		}

		if (!ctx.hasUI) {
			return { block: true, reason: "Dangerous command blocked because this Pi run has no confirmation UI" };
		}

		const choice = await ctx.ui.select(`Dangerous command:\n\n  ${command}\n\nAllow?`, ["No", "Yes"]);
		return choice === "Yes" ? undefined : { block: true, reason: "Blocked by user" };
	});
}
