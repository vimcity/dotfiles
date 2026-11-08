import fs from "node:fs";
import assert from "node:assert/strict";

function loadClass(mod, name, bindings) {
  const source = fs.readFileSync(new URL(`../mods/${mod}/main.js`, import.meta.url), "utf8")
    .replace(/^import .*;\n/gm, "").replace(`export default class ${name}`, `return class ${name}`);
  return new Function(...Object.keys(bindings), source)(...Object.values(bindings));
}

const nodes = [];
function element() {
  const state = {};
  nodes.push(state);
  const proxy = new Proxy({}, { get: (_target, name) => (...args) => {
    if (name === "when") return args[0] ? args[1](proxy) : proxy;
    if (name === "child") state.childCount = (state.childCount ?? 0) + 1;
    state[name] = args;
    return proxy;
  } });
  return proxy;
}
const commands = [];
let allPanes = [];
let allAgents = [];
let allSpaces = [];
const theme = () => ({ foreground: "#c6d0f5", muted: "#a5adce", dim: "#838ba7", selected: "#454c64", hover: "#353b50", popover: "#303446", ansi6: "#81c8be", ansi5: "#ca9ee6" });
const labels = [];
const Picker = loadClass("minimal-picker", "Picker", {
  View: class {}, div: element, svg: element, v_flex: element, h_flex: element,
  agents: () => allAgents, panes: () => allPanes, spaces: () => allSpaces, machines: () => [],
  home: () => "/home/test", sessionLabel: (_tab, pane) => ({ name: pane?.title || "Terminal", isAgent: true }),
  run: (name, args) => commands.push([name, args]), theme,
  fadedLabel: text => { labels.push(text); return element(); }, programIcon: element,
});
const picker = new Picker();
picker.glyph(theme(), "idle");
assert.deepEqual(nodes.at(-1).size, [3]);
assert.deepEqual(nodes.at(-1).bg, [theme().dim]);
picker.glyph(theme(), "working");
assert.deepEqual(nodes.at(-1).size, [7]);
picker.filter = "";
picker.statusFilter = "all";
for (const [query, status, text] of [
  [":w login", "blocked", "login"], [":b", "blocked", ""], ["waiting", "blocked", ""],
  ["blocked auth", "blocked", "auth"], [":d", "done", ""], ["done", "done", ""],
  [":r", "working", ""], ["working build", "working", "build"], [":i", "idle", ""],
  [":a login", "all", "login"], ["w", "all", "w"], ["dialog", "all", "dialog"],
]) {
  picker.filter = query;
  assert.deepEqual(picker.filterQuery(), { status, query: text });
}
allSpaces = [{ id: "space", name: "project", machine: null, tabs: [{ id: "tab" }] }];
allPanes = ["blocked", "done", "working", "idle"].map((status, index) => ({
  pane: `p${index}`, tab: "tab", terminal: `t${index}`, title: `${status} login`, status,
}));
allAgents = allPanes.map(pane => ({ address: pane.terminal, space: "space", status: pane.status }));
picker.filter = ":w login";
assert.deepEqual(picker.rows().filter(row => row.kind === "ctx").map(row => row.current.pane), ["p0"]);
picker.filter = ":d nothing-matches";
assert.deepEqual(picker.rows(), [{ kind: "empty", status: "done" }]);
assert.doesNotThrow(() => picker.navigate("down", { notify() {} }));
assert.doesNotThrow(() => picker.go(undefined));
picker.filter = ":w login";
let value;
picker.input = { set_value(text) { value = text; }, focus() {} };
picker.setStatus("done", { notify() {} });
assert.equal(value, "login");
assert.equal(picker.filterQuery().status, "done");
assert.deepEqual(picker.rows().filter(row => row.kind === "ctx").map(row => row.current.pane), ["p1"]);
assert.equal(picker.rows().filter(row => row.kind === "tab").length, 1, "filtered split panes retain one tab parent");
assert.equal(picker.rows().find(row => row.kind === "tab").tabTitle, "—");
assert.doesNotThrow(() => picker.go(picker.rows().find(row => row.kind === "tab")));
picker.filter = "";
picker.statusFilter = "all";
assert.deepEqual(picker.rows().map(row => row.kind).slice(0, 7), ["machine", "head", "tab", "ctx", "ctx", "ctx", "ctx"]);
const splitPanes = allPanes;
allPanes = [allPanes[0]];
assert.equal(picker.rows().filter(row => row.kind === "tab").length, 0, "single-pane tabs need no duplicate parent row");
allPanes = splitPanes;
const paneRow = picker.rows().find(row => row.kind === "ctx");
picker.row(paneRow, null, theme());
const rowNode = () => nodes.findLast(node => node.id?.[0] === "ctx-p0");
assert.deepEqual(rowNode().bg, [theme().popover]);
assert.deepEqual(rowNode().rounded, [18]);
assert.deepEqual(rowNode().text_size, [14]);
picker.row({ ...paneRow, current: { ...paneRow.current, program: { name: "Pi", agent: true } } }, null, theme());
assert.equal(rowNode().childCount, 3, "session rows contain only the program icon, label and status—not a duplicate agent-name badge");
assert(rowNode().tooltip[0].includes("Pi"), "tool names remain available in the tooltip");
picker.row(paneRow, "ctx-p0", theme());
assert.deepEqual(rowNode().bg, [theme().selected]);
assert.deepEqual(rowNode().border, [0.5]);
rowNode().on_hover[0](true, { notify() {} });
picker.row(paneRow, null, theme());
assert.deepEqual(rowNode().bg, [theme().hover]);
picker.row({ kind: "head", w: { id: "space", name: "project", tabs: [] } }, null, theme());
const heading = nodes.findLast(node => node.id?.[0] === "space-name-space");
assert.deepEqual(heading.font_weight, [700]);
assert.deepEqual(heading.text_color, ["#7F86A1"]);
picker.row({ kind: "machine", machine: "work" }, null, theme());
assert(labels.includes("Work"), "machine labels use normal case without protocol banners");

picker.dismiss = (_cx, after) => { commands.push(["dismiss"]); after?.(); };
allPanes = [{ pane: "p1", tab: "tab", zoomed: true }, { pane: "p2", tab: "tab", zoomed: false }];
const selection = { kind: "ctx", w: { id: "space", active: false }, ctx: { id: "tab" }, current: allPanes[1] };
picker.go(selection);
assert.deepEqual(commands.splice(0), [
  ["dismiss"], ["space.select", { id: "space" }], ["tab.select", { id: "tab" }],
  ["pane.zoom", { pane: "p1" }], ["pane.focus", { pane: "p2" }], ["pane.zoom", { pane: "p2" }],
]);
picker.go({ ...selection, w: { active: true }, current: allPanes[0] });
assert.deepEqual(commands.splice(0), [["dismiss"], ["tab.select", { id: "tab" }], ["pane.focus", { pane: "p1" }]]);
allPanes = [{ pane: "p2", tab: "tab", zoomed: false }];
picker.go({ ...selection, w: { active: true } });
assert(!commands.splice(0).some(([command]) => command === "pane.zoom"));
console.log("PASS: status aliases, combined search, empty results, clickable filters and zoom transfer");

let popupProps = { terminal: "test-terminal", overlay: "old" };
let liveTerminals = [{ address: "test-terminal", state: "live" }];
const ToolPopup = loadClass("tool-popup", "ToolPopup", {
  View: class {}, div: element,
  props: () => popupProps, panes: () => allPanes, terminals: () => liveTerminals,
  run: (name, args) => commands.push([name, args]),
});
allPanes = [];
const popup = new ToolPopup();
popup.render();
assert.deepEqual(nodes.at(-1).size, [0], "popup lifecycle mod must reserve no header space");
popup.close();
assert.deepEqual(commands.splice(0), [["terminal.kill", { terminal: "test-terminal" }]]);
allPanes = [{ terminal: "test-terminal" }];
popup.close();
assert.equal(commands.length, 0, "adopted terminals survive popup close");
const opened = [];
const CommandPrefix = loadClass("command-prefix", "CommandPrefix", {
  View: class {}, run: (name, args) => commands.push([name, args]),
  openOverlay: spec => opened.push(spec),
  window: { viewport_size: () => ({ width: 1200, height: 800 }) }, settings: () => ({ zoom: 1 }),
});
new CommandPrefix().show("test-terminal", { popup: true });
assert.equal(opened[0].kind, "popup", "terminal popup must take focus instead of opening a passive window");
assert.deepEqual(opened[0].at, { x: 192, y: 128 });
assert.equal(opened[0].width, 0.68);
assert.equal(opened[0].height, 0.68);
assert.equal(opened[0].frame, "none");
assert.equal(opened[0].layout.shadow, "lg");
assert.equal(opened[0].layout.radius, 12);
assert.equal(opened[0].layout.children[0].size.px, 0);
assert.equal(opened[0].layout.children[0].content.props.title, undefined);
assert.deepEqual(opened[0].layout.children[1].content, { terminal: "test-terminal" });
console.log("PASS: borderless popup content, zero-height lifecycle slot, no title and cleanup ownership");
