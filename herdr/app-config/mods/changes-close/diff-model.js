export function fileTreeRows(files, collapsed) {
  const root = { dirs: new Map(), files: [] };
  for (const file of files) {
    const parts = file.path.split("/").filter(Boolean), name = parts.pop();
    let node = root, path = "";
    for (const part of parts) {
      path = path ? `${path}/${part}` : part;
      if (!node.dirs.has(part)) node.dirs.set(part, { path, dirs: new Map(), files: [] });
      node = node.dirs.get(part);
    }
    node.files.push({ ...file, name });
  }
  const rows = [];
  const walk = (node, depth) => {
    for (const [name, dir] of [...node.dirs].sort(([a], [b]) => a.localeCompare(b))) {
      const expanded = !collapsed.has(dir.path);
      rows.push({ type: "directory", name, path: dir.path, depth, expanded });
      if (expanded) walk(dir, depth + 1);
    }
    for (const file of node.files.sort((a, b) => a.name.localeCompare(b.name))) {
      rows.push({ type: "file", ...file, depth });
    }
  };
  walk(root, 0);
  return rows;
}

// Numbers each diff line once, so a frame only draws the rows on screen.
export function diffRows(lines) {
  let old = 0, next = 0;
  return lines.map((line) => {
    const match = /^@@ -(\d+)(?:,\d+)? \+(\d+)/.exec(line);
    if (match) { old = +match[1]; next = +match[2]; return { kind: "@", text: line }; }
    const kind = line[0];
    if (kind === "-") return { kind, number: old++, text: line.slice(1) || " " };
    if (kind === "+") return { kind, number: next++, text: line.slice(1) || " " };
    if (kind === " ") { old++; return { kind, number: next++, text: line.slice(1) || " " }; }
    return { kind: "", text: line };
  });
}

export function splitDiffRows(lines) {
  let old = 0, next = 0, removed = [], added = [];
  const rows = [];
  const flush = () => {
    for (let i = 0; i < Math.max(removed.length, added.length); i++) {
      const before = removed[i], after = added[i];
      rows.push({ kind: "split", oldNumber: before?.number, oldText: before?.text ?? "", oldKind: before ? "-" : "", newNumber: after?.number, newText: after?.text ?? "", newKind: after ? "+" : "" });
    }
    removed = []; added = [];
  };
  for (const line of lines) {
    const match = /^@@ -(\d+)(?:,\d+)? \+(\d+)/.exec(line);
    if (match) {
      flush(); old = +match[1]; next = +match[2]; rows.push({ kind: "@", text: line });
    } else if (line[0] === "-") removed.push({ number: old++, text: line.slice(1) || " " });
    else if (line[0] === "+") added.push({ number: next++, text: line.slice(1) || " " });
    else if (line[0] === " ") {
      flush(); rows.push({ kind: "split", oldNumber: old++, oldText: line.slice(1) || " ", newNumber: next++, newText: line.slice(1) || " " });
    } else {
      flush(); rows.push({ kind: "", text: line });
    }
  }
  flush();
  return rows;
}

