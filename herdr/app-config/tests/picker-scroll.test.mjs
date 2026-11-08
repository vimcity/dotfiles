import fs from "node:fs";
import assert from "node:assert/strict";

const path = new URL("../mods/minimal-picker/", import.meta.url);
const navigation = fs.readFileSync(new URL("navigation.js", path));
const { rowLayout, revealOffset, pageIndex } = await import(`data:text/javascript;base64,${navigation.toString("base64")}`);
const sizes = Array.from({ length: 70 }, (_, index) => index % 6 === 0 ? 20 : 30);
for (const height of [120, 240, 400]) {
  let offset = 0;
  for (const index of [...sizes.keys(), ...[...sizes.keys()].reverse()]) {
    offset = revealOffset(sizes, index, height, offset);
    const { tops } = rowLayout(sizes);
    assert(tops[index] >= offset && tops[index] + sizes[index] <= offset + height);
  }
}
assert.equal(revealOffset([30, 30, 30, 30], 1, 90, 0), 0);
assert.equal(pageIndex([26, 20, 30, 30, 20, 30, 30, 30], [2, 3, 5, 6, 7], 0, 80, 1), 2);
assert.equal(pageIndex([26, 20, 30, 30, 20, 30, 30, 30], [2, 3, 5, 6, 7], 3, 80, -1), 1);

const handlers = new Map();
const nodes = new Map();
function element() {
  const state = {};
  const proxy = new Proxy({}, { get: (_target, name) => (...args) => {
    if (name === "id") { state.id = args[0]; nodes.set(state.id, state); }
    if (["top", "h", "bottom"].includes(name)) state[name] = args[0];
    if (name.startsWith("on_")) handlers.set(`${state.id}:${name}`, args.at(-1));
    if (name === "when" && args[0]) return args[1](proxy);
    return proxy;
  } });
  return proxy;
}
const helperSource = fs.readFileSync(new URL("menu-ui.js", path), "utf8").replace(/^import .*;\n/gm, "").replaceAll("export ", "");
const menuScrollbar = new Function("div", `${helperSource}\nreturn menuScrollbar;`)(element);
const cx = { notify() {}, stop_propagation() {} };
const taskCx = { notify() {}, stop_propagation() { throw new Error("navigation commands must not use event-only APIs"); } };
const source = fs.readFileSync(new URL("main.js", path), "utf8")
  .replace(/^import .*;\n/gm, "").replace("export default class Picker", "return class Picker");
let spaces = [];
const inputEvents = {};
const inputState = { text: "", value() { return this.text; }, focus() {},
  on(event, callback) { inputEvents[event] = callback; } };
const Picker = new Function("View", "div", "v_flex", "h_flex", "theme", "settings", "Input", "window", "rowLayout", "revealOffset", "pageIndex", "spaces", "agents", "panes", "machines", "sessionLabel", "svg", "home", "InputState", "fadedLabel", "programIcon", "MENU_CHROME", "MenuMotion", "menuFrame", "menuSearch", "menuScrollbar", source)(
  class {}, element, element, element, () => ({}), () => ({ zoom: 1 }),
  { new: element }, { viewport_size: () => ({ height: 600 }) }, rowLayout, revealOffset, pageIndex,
  () => spaces, () => [], () => [], () => [], () => ({ name: "Terminal", isAgent: false }), element, () => "/home/test", { new: () => inputState }, element, element, 92, class { start() {} wrap(frame) { return frame; } dismiss(_cx, done) { done(); } }, element, element, menuScrollbar);
const picker = new Picker();
Object.assign(picker, { at: null, selectedKey: null, revealPending: true, scroll: null, input: {}, handle: {} });
let rows = Array.from({ length: 80 }, (_, index) => ({ kind: "ctx", ctx: { id: `t${index}` }, w: {},
  current: { pane: `p${index}`, focused: index === 3 }, label: { name: `Session ${index}`, isAgent: true }, status: "idle" }));
picker.rows = () => rows;
const render = () => { handlers.clear(); nodes.clear(); picker.render(cx); };
const visibleSelection = () => {
  const node = nodes.get(picker.selectedKey);
  assert(node, `selected row ${picker.selectedKey} was not rendered`);
  assert(node.top >= 0 && node.top + node.h <= picker.listHeight, "selected row must be fully inside the actual drawn viewport");
};
render(); visibleSelection();
for (const command of ["end", ...Array(90).fill("up"), ...Array(90).fill("down"), "home", "pagedown", "pagedown", "pageup", "pageup"]) {
  picker.navigate(command, taskCx);
  render(); visibleSelection();
}
picker.navigate("home", taskCx); render();
const before = picker.scroll;
picker.navigate("down", taskCx); render();
assert.equal(picker.scroll, before, "visible-row movement must not recenter the list");
picker.setScroll(300, cx); render();
const selected = picker.selectedKey;
rows = rows.map(row => ({ ...row, status: "working" }));
render();
assert.equal(picker.scroll, 300, "live updates must not override manual scrolling");
assert.equal(picker.selectedKey, selected);
handlers.get("pk-viewport:on_scroll_wheel")({ delta: { y: -100 }, bounds: { height: picker.listHeight * 2 } }, cx);
assert.equal(picker.scroll, 350, "wheel movement must account for rendered scale");
render();
picker.navigate("down", taskCx); render(); visibleSelection();
handlers.get("pk-scrollbar:on_mouse_down")({ local_position: { y: picker.listHeight / 2 }, bounds: { height: picker.listHeight }, position: { y: 100 } }, cx);
handlers.get("picker:on_mouse_move")({ position: { y: 10000 } }, cx);
assert.equal(picker.scroll, picker.maxScroll, "dragging the scrollbar must reach the bottom");
handlers.get("picker:on_mouse_up")();
assert.equal(picker.drag, null);
render();
handlers.get("pk-scrollbar:on_mouse_down")({ local_position: { y: 0 }, bounds: { height: picker.listHeight }, position: { y: 100 } }, cx);
handlers.get("picker:on_mouse_move")({ position: { y: -10000 } }, cx);
assert.equal(picker.scroll, 0, "dragging the scrollbar must reach the top");
handlers.get("picker:on_mouse_up")();
rows = [{ ...rows[0], current: { pane: "inserted" } }, ...rows];
render();
assert.equal(picker.selectedKey, "ctx-p2", "selection must follow the pane identity when rows are inserted");
picker.navigate("end", taskCx); render();
picker.navigate("down", taskCx); render();
assert.equal(picker.selectedKey, "ctx-p79", "Down must stop at the end");

const ordering = new Picker();
ordering.filter = "";
spaces = [{ id: "a", name: "a", status: "idle", tabs: [{ id: "ta" }] },
  { id: "b", name: "b", status: "working", tabs: [{ id: "tb" }] }];
assert.deepEqual(ordering.rows().filter(row => row.kind === "head").map(row => row.w.id), ["a", "b"]);
spaces[0].status = "blocked";
spaces[1].status = null;
assert.deepEqual(ordering.rows().filter(row => row.kind === "head").map(row => row.w.id), ["a", "b"]);
spaces = [
  { id: "local", name: "rice", machine: null, tabs: [{ id: "local-tab" }] },
  { id: "work-a", name: "project", machine: "work", tabs: [{ id: "work-tab-a" }] },
  { id: "work-b", name: "other", machine: "work", tabs: [{ id: "work-tab-b" }] },
];
assert.deepEqual(ordering.rows().filter(row => row.kind === "machine").map(row => row.machine), [null, "work"]);
let dismissed = false;
ordering.dismiss = () => { dismissed = true; };
ordering.go({ kind: "machine", machine: "work" });
assert.equal(dismissed, false);
const keys = JSON.parse(fs.readFileSync(new URL("../keys.json", import.meta.url), "utf8"));
for (const key of ["up", "down", "pageup", "pagedown", "home", "end"]) assert.equal(keys["mod:minimal-picker"][key], `minimal-picker.${key}`);
const filtered = new Picker();
filtered.init({}, { ...cx, focus_handle: () => ({}), spawn() {}, timer: { after: (_delay, callback) => callback(cx) } });
const matches = rows.slice(0, 1);
filtered.rows = () => filtered.filter ? matches : rows;
filtered.render(cx);
filtered.navigate("end", taskCx);
filtered.render(cx);
inputState.text = "needle";
inputEvents.change({}, cx);
filtered.render(cx);
assert.equal(filtered.scroll, 0, "filtering must reset the viewport to matching rows");
let opened;
filtered.go = row => { opened = row; };
inputEvents.submit();
assert.equal(opened, matches[0], "Enter must open the selected filtered result");
ordering.filter = "work";
assert.deepEqual(ordering.rows().filter(row => row.kind === "machine").map(row => row.machine), ["work"]);
console.log("PASS: drawn selection visibility, arrows/pages, wheel scaling, scrollbar dragging, filtering/Enter, stable order and input bindings");
