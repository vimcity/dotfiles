import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";

function formatTokens(tokens: number): string {
  if (tokens < 1_000) return String(tokens);
  if (tokens < 1_000_000) return `${(tokens / 1_000).toFixed(tokens < 10_000 ? 1 : 0)}k`;
  return `${(tokens / 1_000_000).toFixed(1)}m`;
}

function formatDuration(milliseconds: number): string {
  const minutes = Math.floor(milliseconds / 60_000);
  if (minutes < 60) return `${minutes}m`;
  return `${Math.floor(minutes / 60)}h${String(minutes % 60).padStart(2, "0")}m`;
}

function formatCost(cost: number): string {
  return `$${cost.toFixed(3)}`;
}

export default function (pi: ExtensionAPI) {
  let invalidate: (() => void) | undefined;
  let modelLabel = "no model";
  let thinkingLevel = "off";

  pi.on("session_start", async (_event, ctx) => {
    const startedAt = Date.now();
    modelLabel = ctx.model?.id ?? "no model";
    thinkingLevel = pi.getThinkingLevel();
    ctx.ui.setFooter((tui, theme, footerData) => {
      const unsubscribe = footerData.onBranchChange(() => tui.requestRender());
      invalidate = () => tui.requestRender();

      return {
        dispose: () => {
          invalidate = undefined;
          unsubscribe();
        },
        invalidate() {},
        render(width: number): string[] {
          let input = 0;
          let output = 0;
          let cost = 0;
          for (const entry of ctx.sessionManager.getBranch()) {
            if (entry.type !== "message" || entry.message.role !== "assistant") continue;
            const usage = (entry.message as AssistantMessage).usage;
            input += usage.input + usage.cacheRead + usage.cacheWrite;
            output += usage.output;
            cost += usage.cost.total;
          }

          const context = ctx.getContextUsage();
          const contextText = context?.percent === null || context?.percent === undefined ? "?" : `${Math.round(context.percent)}%`;
          const sessionName = pi.getSessionName() ?? "";
          const sessionId = ctx.sessionManager.getSessionId().slice(0, 8);
          const directory = ctx.cwd.split("/").filter(Boolean).pop() ?? "~";
          const branch = footerData.getGitBranch();
          const parts = [
            theme.fg("accent", "󰧑") + theme.fg("text", ` ${sessionName}`),
            theme.fg("thinkingText", `${modelLabel} ${thinkingLevel}`),
            theme.fg("dim", `#${sessionId}`),
            theme.fg("muted", `󰉋 ${directory}`),
            ...(branch ? [theme.fg("syntaxFunction", ` ${branch}`)] : []),
            theme.fg("muted", `󱦟 ${formatDuration(Date.now() - startedAt)}`),
            theme.fg("thinkingText", `󰆉 ${contextText}`),
            theme.fg("warning", `󰄨 ${formatCost(cost)}`),
            theme.fg("toolTitle", `↓ ${formatTokens(input)}`),
            theme.fg("success", `↑ ${formatTokens(output)}`),
          ];
          return [truncateToWidth(parts.join(theme.fg("dim", " · ")), width)];
        },
      };
    });
  });

  pi.on("model_select", async (event) => {
    modelLabel = event.model.id;
    invalidate?.();
  });
  pi.on("thinking_level_select", async (event) => {
    thinkingLevel = event.level;
    invalidate?.();
  });
  pi.on("session_info_changed", async () => invalidate?.());
  pi.on("turn_end", async () => invalidate?.());
}
