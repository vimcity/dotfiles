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

export function terminalArgs(action, context, machine) {
  const args = ["run", "--bg", "--json", "--no-parent", "--no-notify"];
  if (machine) args.push("--on", machine);
  if (context?.cwd) args.push("--cwd", context.cwd);
  return [...args, "--", "/bin/zsh", "-lic", action.shell];
}
