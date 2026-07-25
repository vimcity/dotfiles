import type { EditToolDetails, ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";
import { createEditTool, getLanguageFromPath, highlightCode } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";

type EditArgs = { path?: string; file_path?: string };

type ParsedLine = { prefix: "+" | "-" | " "; lineNumber: string; content: string };

function parseLine(line: string): ParsedLine | undefined {
  const match = line.match(/^([+\- ])(\s*\d*)\s(.*)$/);
  if (!match) return undefined;
  return { prefix: match[1] as ParsedLine["prefix"], lineNumber: match[2], content: match[3] };
}

function renderLine(line: string, language: string | undefined, theme: Theme): string {
  const parsed = parseLine(line);
  if (!parsed) return theme.fg("dim", line);

  const diffColor = parsed.prefix === "+" ? "success" : parsed.prefix === "-" ? "error" : "muted";
  const code = parsed.content.replace(/\t/g, "   ");
  const highlighted = language ? (highlightCode(code, language)[0] ?? code) : theme.fg(diffColor, code);
  return theme.fg(diffColor, `${parsed.prefix}${parsed.lineNumber} `) + highlighted;
}

export default function (pi: ExtensionAPI) {
  const originalEdit = createEditTool(process.cwd());

  pi.registerTool({
    name: "edit",
    label: "edit",
    description: originalEdit.description,
    parameters: originalEdit.parameters,
    renderShell: "self",

    async execute(toolCallId, params, signal, onUpdate) {
      return originalEdit.execute(toolCallId, params, signal, onUpdate);
    },

    renderCall(args: EditArgs, theme) {
      const path = args.path ?? args.file_path ?? "file";
      const badge = theme.bg("accent", theme.fg("userMessageBg", theme.bold(" 󰏫 edit ")));
      return new Text(badge + theme.fg("accent", ` ${path}`), 0, 0);
    },

    renderResult(result, { expanded, isPartial }, theme, context) {
      if (isPartial) return new Text(theme.fg("warning", "Editing..."), 0, 0);

      const details = result.details as EditToolDetails | undefined;
      if (!details?.diff) {
        const message = result.content.find((item) => item.type === "text")?.text ?? "Applied";
        return new Text(theme.fg(message.startsWith("Error") ? "error" : "success", message.split("\n")[0]), 0, 0);
      }

      const lines = details.diff.split("\n");
      const additions = lines.filter((line) => line.startsWith("+")).length;
      const removals = lines.filter((line) => line.startsWith("-")).length;
      let text = theme.fg("success", `󰄬 +${additions}`) + theme.fg("dim", "  ") + theme.fg("error", `󰄭 -${removals}`);
      if (!expanded) return new Text(text, 0, 0);

      const args = context.args as EditArgs;
      const path = args.path ?? args.file_path;
      const language = path ? getLanguageFromPath(path) : undefined;
      for (const line of lines) text += `\n${renderLine(line, language, theme)}`;
      return new Text(text, 0, 0);
    },
  });
}
