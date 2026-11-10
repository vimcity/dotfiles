import fs from "node:fs";
import assert from "node:assert/strict";

const root = new URL("../mods/", import.meta.url);
const load = file => import(`data:text/javascript;base64,${Buffer.from(fs.readFileSync(new URL(file, root))).toString("base64")}`);
const { bindingKey, terminalArgs } = await load("command-prefix/keys.js");
const { default: bindings } = await load("command-prefix/bindings.js");
assert.equal(bindings["ctrl-j"].shell, 'exec "$HOME/.config/jira-tui/jira-tui.sh"');
assert.equal(bindings["ctrl-j"].popup, false, "Jira uses the zoomed tool-pane launch path");
for (const key of Object.keys(bindings)) {
  assert.equal(bindingKey({ keystroke: key }, bindings), key);
  const parts = key === "-" ? ["-"] : key.split("-");
  const letter = parts.at(-1);
  const modifiers = { shift: parts.includes("shift"), control: parts.includes("ctrl"), alt: parts.includes("alt") };
  assert.equal(bindingKey({ key: modifiers.shift ? letter.toUpperCase() : letter, modifiers }, bindings), key);
}
assert.equal(bindingKey({ key: "R", key_char: "R", modifiers: { shift: true } }, bindings), "shift-r");
assert.equal(bindingKey({ key: "!", key_char: "!", modifiers: { shift: true } }, bindings), "shift-1");
assert.equal(bindingKey({ key: "z", key_char: "z", modifiers: { control: true } }, bindings), null);
assert.deepEqual(terminalArgs({ shell: "exec btop" }, { cwd: "/tmp" }, "work"),
  ["run", "--bg", "--json", "--no-parent", "--no-notify", "--on", "work", "--cwd", "/tmp", "--",
    "/bin/zsh", "-c",
    'export PATH="$HOME/.local/bin:$HOME/dotfiles/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"'
    + ' ORG_PATH="${ORG_PATH:-$HOME/Documents/org}" EDITOR="${EDITOR:-nvim}"; exec btop']);
const launched = terminalArgs({ shell: "exec btop" }, {}, null);
assert(!launched.includes("--on"));
assert(!launched.some(part => part === "-lic" || part === "-lc"), "popups must not pay for a login shell");
assert(launched.at(-1).includes("ORG_PATH="), "ORG_PATH must be exported or orgmode misresolves its vault");
assert(launched.at(-1).includes("PATH="), "tool PATH must be supplied because hc hands over a bare launchd PATH");
const { collectMatches } = await load("terminal-hints/matches.js");
const { default: rules } = await load("terminal-hints/rules.js");
const text = "Email a+b@example.com; UUID 12345678-abcd-abcd-abcd-123456789abc account 123456789012 path ~/src/demo.js url https://example.com/foo.\nagain a+b@example.com";
const matches = collectMatches(text, rules);
assert.deepEqual(matches.map(match => match.kind), ["email", "uuid", "account", "path", "url"]);
assert.equal(matches.at(-1).value, "https://example.com/foo");
assert.equal(new Set(matches.map(match => match.label)).size, matches.length);
const many = collectMatches(Array.from({ length: 1000 }, (_, n) => `https://example.com/${n}`).join("\n"), rules);
assert.equal(many.length, 1000);
assert.equal(new Set(many.map(match => match.label)).size, 1000);
assert(many.every(match => match.label.length === 3));
assert.deepEqual(collectMatches("nothing here", rules), []);
assert.equal(collectMatches("ticket ABC-123", [{name:"ticket",pattern:"ABC-\\d+"}])[0].value, "ABC-123");
console.log(`PASS: ${Object.keys(bindings).length} prefix bindings, launch args, regex extraction, custom rules, deduplication and 1000 unique hints`);

const { sessionLabel } = await load("minimal-picker/session-label.js");
const agentProgram = { key: "codex", name: "Codex", agent: true };
const pane = { program: agentProgram, title: "Codex", cwd: "/repo", app: "codex" };
assert.deepEqual(sessionLabel({}, pane, { title: "Review login flow" }),
  { name: "Review login flow", detail: "", isAgent: true, hasTitle: true });
assert.equal(sessionLabel({}, { ...pane, title: "π - Fix scrollbars" }).name, "Fix scrollbars");
assert.equal(sessionLabel({ named: true, name: "release prep" }, pane).name, "release prep");
assert.equal(sessionLabel({}, pane).name, "/repo");
assert.equal(sessionLabel({}, { ...pane, title: "~/repo" }).name, "/repo");
assert.equal(sessionLabel({}, { ...pane, title: "C:\\repo" }).name, "/repo");
assert.equal(sessionLabel({}, { ...pane, title: "Codex - " }).name, "/repo");
assert.equal(sessionLabel({}, { ...pane, title: "Review auth" }).detail, "");
assert.equal(sessionLabel({}, { ...pane, title: "Codex" }, null, () => "~/repo").name, "~/repo");
assert.equal(sessionLabel({}, { program: { name: "btop", agent: false }, cwd: "/repo" }).name, "btop");
assert.equal(sessionLabel({}, { program: { name: "btop", agent: false }, cwd: "/repo" }).detail, "/repo");
assert.equal(sessionLabel({}, { program: { name: "Terminal", agent: false } }, { title: "Agent title" }).name, "Agent title");
console.log("PASS: agent session titles, harness-prefix cleanup, unnamed/path fallback and normal app labels");
