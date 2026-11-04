import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

function isEnvPath(path: string): boolean {
  const segments = path.replace(/\\/g, "/").split("/");
  const isEnvSegment = (segment: string) => /\.env(?:\.|$)/i.test(segment);
  const fileName = segments.at(-1)?.toLowerCase();

  if (fileName === "node.env" && !segments.slice(0, -1).some(isEnvSegment)) return false;
  return segments.some(isEnvSegment);
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "read") return undefined;

    const path = (event.input as { path?: unknown }).path;
    if (typeof path !== "string" || !isEnvPath(path)) return undefined;

    const reason = "Reading .env files is blocked; node.env is allowed.";
    if (ctx.hasUI) ctx.ui.notify(reason, "warning");
    return { block: true, reason };
  });
}
