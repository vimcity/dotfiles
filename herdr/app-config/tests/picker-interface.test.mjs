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
for (const query of [":w login", ":b", "waiting", "blocked auth", ":d", "done", ":r", "working build", ":i", ":a login", "w", "dialog"]) {
  picker.filter = query;
  assert.deepEqual(picker.filterQuery(), { query }, "search text is treated literally without status-filter syntax");
}
allSpaces = [{ id: "space", name: "project", machine: null, tabs: [{ id: "tab" }] }];
allPanes = ["blocked", "done", "working", "idle"].map((status, index) => ({
  pane: `p${index}`, tab: "tab", terminal: `t${index}`, title: `${status} login`, status,
}));
allAgents = allPanes.map(pane => ({ address: pane.terminal, space: "space", status: pane.status }));
picker.filter = "blocked login";
assert.equal(picker.rows().find(row => row.kind === "ctx").current.pane, "p0");
picker.filter = "nothing-matches";
assert.deepEqual(picker.rows(), [{ kind: "empty" }]);
assert.doesNotThrow(() => picker.navigate("down", { notify() {} }));
assert.doesNotThrow(() => picker.go(undefined));
picker.filter = "done login";
assert.equal(picker.rows().filter(row => row.kind === "ctx").length, 1, "a matching session produces one workspace result");
assert.equal(picker.rows().find(row => row.kind === "ctx").current.pane, "p1", "a session search targets its matching tab");
picker.filter = "";
assert.deepEqual(picker.rows().map(row => row.kind), ["ctx"], "the picker lists workspaces, not tabs or pane trees");
const splitPanes = allPanes;
allPanes = [allPanes[0]];
assert.equal(picker.rows().filter(row => row.kind === "ctx").length, 1, "multiple panes still produce one workspace result");
allPanes = splitPanes;
const paneRow = picker.rows().find(row => row.kind === "ctx");
picker.row(paneRow, null, theme());
const rowNode = () => nodes.findLast(node => node.id?.[0] === "workspace-space");
assert.deepEqual(rowNode().bg, [theme().popover]);
assert.deepEqual(rowNode().rounded, [18]);
assert.deepEqual(rowNode().text_size, [14]);
picker.row({ ...paneRow, current: { ...paneRow.current, program: { name: "Pi", agent: true } } }, null, theme());
assert.equal(rowNode().childCount, 3, "workspace results show one workspace label, concise context and status");
assert(rowNode().tooltip[0].includes("project"), "workspace details remain available in the tooltip");
picker.row(paneRow, "workspace-space", theme());
assert.deepEqual(rowNode().bg, [theme().selected]);
assert.deepEqual(rowNode().border, [0.5]);
rowNode().on_hover[0](true, { notify() {} });
picker.row(paneRow, null, theme());
assert.deepEqual(rowNode().bg, [theme().hover]);
picker.row({ kind: "ctx", w: { id: "space", name: "project", machine: "work" }, ctx: { id: "tab" }, current: null, label: { name: "Session" }, status: "idle" }, null, theme());
assert(nodes.findLast(node => node.id?.[0] === "workspace-space"), "workspace is the selectable unit");

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
console.log("PASS: literal workspace/session search, one workspace result, matching-tab navigation, empty results and zoom transfer");

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
