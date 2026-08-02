import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/** Keep session contents off public GitHub Gists, including secret/unlisted ones. */
export default function (pi: ExtensionAPI) {
	pi.on("input", async (event, ctx) => {
		if (!/^\/share(?:\s|$)/.test(event.text)) return { action: "continue" };
		if (ctx.hasUI) ctx.ui.notify("Session sharing is disabled on this machine.", "warning");
		return { action: "handled" };
	});
}
