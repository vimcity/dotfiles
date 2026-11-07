export function sessionLabel(tab, pane, agent, formatPath = value => value ?? "") {
  const program = pane?.program ?? agent?.program;
  const path = formatPath(pane?.cwd);
  const isAgent = Boolean(program?.agent || agent);
  if (!isAgent) return { name: tab?.named ? tab.name : program?.name || pane?.title || "Terminal", detail: path, isAgent };

  const generic = new Set([program?.name, program?.key, pane?.app, agent?.app,
    "pi", "π", "codex", "claude", "claude code", "terminal", "agent"].filter(Boolean).map(value => value.toLowerCase()));
  const clean = value => {
    const title = (value ?? "").replace(/^[^\p{L}\p{N}~/]+/u, "")
      .replace(/^(?:π|pi|codex|claude(?: code)?|opencode|gemini(?: cli)?|cursor(?: agent)?)\s*[-:|·–—]\s*/i, "").trim();
    return !title || generic.has(title.toLowerCase()) || /^[~/\\]|^[A-Za-z]:[\\/]/.test(title) ? "" : title;
  };
  const title = clean(agent?.title) || clean(pane?.title) || (tab?.named ? clean(tab.name) : "");
  return { name: title || path || "Untitled session", detail: "", isAgent, hasTitle: Boolean(title) };
}
