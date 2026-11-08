export function bindingKey(event, bindings) {
  if (bindings[event.keystroke]) return event.keystroke;
  const modifiers = event.modifiers ?? {};
  const raw = (event.key ?? event.key_char ?? "").toLowerCase();
  const shiftedDigits = { "!": "1", "@": "2", "#": "3", "$": "4", "%": "5", "^": "6", "&": "7", "*": "8", "(": "9" };
  const key = modifiers.shift ? shiftedDigits[raw] ?? raw : raw;
  const chord = [modifiers.platform && "cmd", modifiers.control && "ctrl",
    modifiers.alt && "alt", modifiers.shift && "shift", key].filter(Boolean).join("-");
  if (bindings[chord]) return chord;
  if (!modifiers.control && !modifiers.alt && !modifiers.platform && bindings[event.key_char]) return event.key_char;
  return null;
}

// hc hands children a bare launchd PATH (/usr/bin:/bin:/usr/sbin:/sbin), and a
// login shell rebuilds the rest from .zprofile/.zshrc at 25-80ms per popup.
// Supply the env explicitly instead, like the rex launcher does.
// Bindings must resolve through this PATH or use an absolute path, and are
// responsible for starting a login shell themselves if they need one.
const PATH_PREPEND = [
  "$HOME/.local/bin",
  "$HOME/dotfiles/bin",
  "/opt/homebrew/bin",
  "/opt/homebrew/sbin",
  "/usr/local/bin",
].join(":");

// ORG_PATH is required: orgmode falls back to ~/Documents without it, not
// ~/Documents/org, which silently misdirects capture and the agenda.
const TOOL_ENV = [
  `PATH="${PATH_PREPEND}:$PATH"`,
  'ORG_PATH="${ORG_PATH:-$HOME/Documents/org}"',
  'EDITOR="${EDITOR:-nvim}"',
].join(" ");

export function terminalArgs(action, context, machine) {
  const args = ["run", "--bg", "--json", "--no-parent", "--no-notify"];
  if (machine) args.push("--on", machine);
  if (context?.cwd) args.push("--cwd", context.cwd);
  return [...args, "--", "/bin/zsh", "-c", `export ${TOOL_ENV}; ${action.shell}`];
}
