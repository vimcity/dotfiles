const ALPHABET = "asdfghjklqwertyuiopzxcvbnm";

export function collectMatches(text, rules) {
  const candidates = [];
  for (const rule of rules) {
    const regex = new RegExp(rule.pattern, [...new Set(`g${rule.flags ?? ""}`)].join(""));
    for (const match of text.matchAll(regex)) {
      if (!match[0].length) continue;
      const value = match[0].replace(/[).:!?]+$/, "");
      if (!value) continue;
      candidates.push({ value, kind: rule.name, start: match.index, end: match.index + value.length });
    }
  }
  candidates.sort((a, b) => a.start - b.start || b.end - a.end);
  const unique = [];
  const seen = new Set();
  let end = -1;
  for (const match of candidates) {
    if (match.start < end) continue;
    end = match.end;
    if (seen.has(match.value)) continue;
    seen.add(match.value);
    const lineStart = text.lastIndexOf("\n", match.start - 1) + 1;
    const lineEnd = text.indexOf("\n", match.end);
    unique.push({ ...match, context: text.slice(lineStart, lineEnd < 0 ? text.length : lineEnd).trim() });
  }
  const width = Math.max(1, Math.ceil(Math.log(Math.max(1, unique.length)) / Math.log(ALPHABET.length)));
  return unique.map((match, index) => {
    let label = "";
    for (let i = 0, n = index; i < width; i++, n = Math.floor(n / ALPHABET.length)) label = ALPHABET[n % ALPHABET.length] + label;
    return { ...match, label };
  });
}
