import fs from "node:fs";
import assert from "node:assert/strict";

const root = new URL("../", import.meta.url);
const read = path => fs.readFileSync(new URL(path, root), "utf8");
const { navigateSidebar } = await import(`data:text/javascript;base64,${Buffer.from(read("mods/minimal-pane/sidebar-navigation.js")).toString("base64")}`);
assert.equal(read("mods/minimal-pane/sidebar-navigation.js"), read("mods/minimal-sidebar/sidebar-navigation.js"));
const calls = [];
const run = (name, args) => calls.push([name, args]);
const spaces = [
  { id: "local", active: true, tabs: [{ id: "a", active: true }, { id: "b", active: false }] },
  { id: "work/remote", active: false, tabs: [{ id: "work/c", active: true }] },
];
navigateSidebar(1, spaces, run);
assert.deepEqual(calls.splice(0), [["tab.select", { id: "b" }]]);
navigateSidebar(-1, spaces, run);
assert.deepEqual(calls.splice(0), [["space.select", { id: "work/remote" }]]);
spaces[0].tabs[0].active = false;
spaces[0].tabs[1].active = true;
navigateSidebar(1, spaces, run);
assert.deepEqual(calls.splice(0), [["space.select", { id: "work/remote" }]]);
spaces[0].active = false;
spaces[1].active = true;
navigateSidebar(1, spaces, run);
assert.deepEqual(calls.splice(0), [["space.select", { id: "local" }], ["tab.select", { id: "a" }]]);
navigateSidebar(1, [], run);
navigateSidebar(1, [{ id: "only", active: true, tabs: [{ id: "only-tab", active: true }] }], run);
assert.deepEqual(calls, []);
navigateSidebar(1, spaces.map(space => ({ ...space, active: false })), run);
assert.deepEqual(calls.splice(0), [["space.select", { id: "local" }], ["tab.select", { id: "a" }]]);
navigateSidebar(-1, spaces.map(space => ({ ...space, active: false })), run);
assert.deepEqual(calls.splice(0), [["space.select", { id: "work/remote" }]]);

spaces[0].active = true;
spaces[1].active = false;
spaces[0].tabs[0].active = true;
spaces[0].tabs[1].active = false;
let props = { pane: "focused" };
const panes = [
  { pane: "focused", tab: "a", focused: true, zoomed: false },
  { pane: "other", tab: "a", focused: false, zoomed: false },
];
const source = read("mods/minimal-pane/main.js").replace(/^import .*;\n/gm, "")
  .replace("export default class CompactPane", "return class CompactPane");
const Pane = new Function("View", "props", "panes", "spaces", "navigateSidebar", "run", source)(
  class {}, () => props, () => panes, () => spaces, navigateSidebar, run);
const header = new Pane();
header.init({}, { spawn() {} });
header.handleCommand("sidebar-next", {});
assert.deepEqual(calls.splice(0), [["tab.select", { id: "b" }]], "tab navigation does not depend on layout/sidebar visibility");
props = { pane: "other" };
header.handleCommand("sidebar-next", {});
assert.deepEqual(calls, [], "unfocused header copies must not handle broadcast navigation");
props = { pane: "focused" };
panes[0].zoomed = true;
header.handleCommand("sidebar-prev", {});
assert.deepEqual(calls.splice(0), [["space.select", { id: "work/remote" }]], "tab navigation preserves per-tab zoom");
panes[0].zoomed = false;
header.handleCommand("go-down", {});
assert.deepEqual(calls.splice(0), [["pane.go", { direction: "down" }]]);
header.handleCommand("unknown", {});
assert.deepEqual(calls, []);
const timers = [];
const cx = { timer: { after: (_ms, callback) => timers.push(callback) } };
panes[0].zoomed = true;
header.handleCommand("go-right", cx);
assert.deepEqual(calls.splice(0), [["pane.zoom", { pane: "focused" }]]);
panes[0].zoomed = false;
timers.shift()(cx);
assert.deepEqual(calls.splice(0), [["pane.go", { direction: "right" }]]);
panes[0].focused = false;
panes[1].focused = true;
timers.shift()(cx);
assert.deepEqual(calls.splice(0), [["pane.zoom", { pane: "other" }]]);
assert.equal(header.navigating, false);
const keys = JSON.parse(read("keys.json"));
assert.equal(keys.global["alt-j"], "minimal-pane.sidebar-next");
assert.equal(keys.global["alt-k"], "minimal-pane.sidebar-prev");
console.log("PASS: hidden-sidebar routing, single focused handler, tab/space order, wrapping, remote IDs and zoom navigation");
