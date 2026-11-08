import fs from "node:fs";
import assert from "node:assert/strict";

const root = new URL("../", import.meta.url);
const read = path => fs.readFileSync(new URL(path, root), "utf8");
const nodes = [];
function element() {
  const state = { children: [], transitions: [] };
  nodes.push(state);
  const proxy = new Proxy({}, { get: (_target, name) => (...args) => {
    if (name === "when") return args[0] ? args[1](proxy) : proxy;
    if (name === "child") state.children.push(args[0]);
    if (name === "transition") state.transitions.push(args);
    state[name] = args;
    return proxy;
  } });
  return proxy;
}
const node = id => nodes.findLast(node => node.id?.[0] === id);
const helper = read("mods/minimal-picker/menu-ui.js").replace(/^import .*;\n/gm, "").replaceAll("export ", "");
const { MenuMotion, MENU_CHROME, menuFrame, menuSearch, menuScrollbar } = new Function("div", "svg", "h_flex", "v_flex", "Input", `${helper}\nreturn { MenuMotion, MENU_CHROME, menuFrame, menuSearch, menuScrollbar };`)(element, element, element, element, { new: element });
assert.equal(read("mods/minimal-picker/menu-ui.js"), read("mods/minimal-palette/menu-ui.js"));
const timers = [];
let notifications = 0;
const cx = { notify() { notifications++; }, stop_propagation() {}, timer: { after: (ms, callback) => timers.push({ ms, callback }) }, spawn() {} };
const staged = new MenuMotion();
staged.start(cx);
assert.equal(timers[0].ms, 16);
timers.shift().callback(cx);
assert.equal(staged.phase, "open", "entry can start before a host size callback is delivered");
notifications = 0;
const motion = new MenuMotion();
motion.decorate(element().id("motion"));
assert.deepEqual(node("motion").opacity, [0.01], "the first frame must paint so the native first-layout callback can start the entrance");
assert.deepEqual(node("motion").top, [-6]);
assert.deepEqual(node("motion").transitions, [
  ["top", { duration: 160, easing: "ease-out" }], ["opacity", { duration: 140, easing: "ease-out" }],
]);
motion.wrap(element().id("entry-card"), "entry", () => {}, { width: 1200, height: 800, zoom: 1 });
assert.equal(node("entry-card").on_size_change, undefined, "entrance staging belongs to the mod root, not a nested card");
node("entry-host").on_size_change[0]({ width: 1200, height: 800 }, cx);
assert.equal(motion.phase, "open");
assert.equal(notifications, 1);
node("entry-host").on_size_change[0]({ width: 1200, height: 800 }, cx);
assert.equal(notifications, 1, "later size changes must not replay the entrance");
motion.decorate(element().id("motion"));
assert.deepEqual(node("motion").opacity, [1]);
let completed = 0;
motion.dismiss(cx, () => completed++);
motion.dismiss(cx, () => completed++);
assert.equal(timers.length, 1, "closing is idempotent");
assert.equal(timers[0].ms, 110);
assert.equal(completed, 0, "actions wait for the native exit transition");
motion.decorate(element().id("motion"));
assert.deepEqual(node("motion").transitions[0], ["top", { duration: 110, easing: "ease-in" }]);
timers.shift().callback(cx);
assert.equal(completed, 1);
const early = new MenuMotion();
early.dismiss(cx, () => {});
early.wrap(element().id("early-card"), "early", () => {}, { width: 1200, height: 800, zoom: 1 });
node("early-host").on_size_change[0]({ width: 1200, height: 800 }, cx);
assert.equal(early.phase, "closing", "Escape before the first layout must not reopen a menu");
timers.length = 0;

const t = { foreground: "#c6d0f5", muted: "#a5adce", dim: "#838ba7", selected: "#454c64", hover: "#353b50", popover: "#303446", chrome: "#292d3e", ansi4: "#8caaee", ansi5: "#ca9ee6", ansi6: "#81c8be" };
menuFrame(t).id("shared-frame");
assert.deepEqual(node("shared-frame").p, [8]);
assert.deepEqual(node("shared-frame").rounded, [12]);
assert.deepEqual(node("shared-frame").border, [0.5]);
assert.deepEqual(node("shared-frame").shadow_xl, []);
const popup = new MenuMotion();
popup.phase = "open";
let backdropClosed = 0;
popup.wrap(element().id("zoom-surface").h(400), "zoom-test", () => backdropClosed++, { width: 1200, height: 800, zoom: 1 });
node("zoom-test-host").on_size_change[0]({ width: 1200, height: 800 }, cx);
assert.deepEqual(popup.bounds, { width: 1168, height: 768 });
assert.deepEqual(node("zoom-test-host").h, [800], "popup hosts have explicit viewport height rather than shrink-wrapping their card");
popup.toggleZoom(cx);
assert.equal(popup.expanded, true);
assert.equal(popup.phase, "open", "resizing does not replay entrance or dismiss the popup");
assert.equal(popup.heightLimit(800), 676);
popup.wrap(element().id("zoom-surface").h(768), "zoom-test", () => backdropClosed++, { width: 1200, height: 800, zoom: 1 });
assert.deepEqual(node("zoom-surface").w, [1168]);
assert(node("zoom-surface").transitions.some(([property, policy]) => property === "width" && policy.duration === 220));
assert(node("zoom-surface").transitions.some(([property]) => property === "height"));
node("zoom-test-host").on_click[0]({}, cx);
assert.equal(backdropClosed, 1);
popup.toggleZoom(cx);
popup.wrap(element().id("zoom-surface").h(400), "zoom-test", () => {});
assert.deepEqual(node("zoom-surface").w, [600]);
assert.equal(popup.heightLimit(800), null);
const scaledPopup = new MenuMotion();
scaledPopup.wrap(element().id("scaled-card"), "scaled", () => {}, { width: 1320, height: 880, zoom: 1.1 });
node("scaled-host").on_size_change[0]({ width: 1320, height: 880 }, cx);
assert(Math.abs(scaledPopup.bounds.width - 1168) < 0.001);
assert(Math.abs(scaledPopup.bounds.height - 768) < 0.001, "app zoom is removed from measured host bounds before resizing the card");
const allKeys = JSON.parse(read("keys.json"));
const bindings = Object.entries(allKeys).flatMap(([section, keys]) => Object.entries(keys).map(([key, action]) => ({ section, keys: key, action })));
const actions = [];
const inputEvents = {};
const input = { value: () => "", focus() {}, on(name, callback) { inputEvents[name] = callback; } };
const stored = new Map();
const commands = () => ["tab.new", "tab.close", "tab.next", "tab.prev", "space.new", "space.close", "pane.split", "pane.close", "pane.zoom", "app.settings", "app.zoom_in", "app.zoom_out", "app.zoom_reset", "layout.clone", "mod.clone"].map(name => ({ name, args: [] }));
const source = read("mods/minimal-palette/main.js").replace(/^import .*;\n/gm, "").replace("export default class Palette", "class Palette");
const env = {
  View: class {}, div: element, svg: element, h_flex: element, v_flex: element,
  InputState: { new: () => input }, commands, layouts: () => ["minimal-frappe"], keys: () => bindings,
  shared: () => "minimal-frappe", win: () => ({ platform: "macos" }), window: { viewport_size: () => ({ height: 800 }) },
  settings: () => ({ zoom: 1 }), theme: () => t, props: () => ({ overlay: "palette-id" }),
  run: (name, args) => actions.push([name, args]), closeOverlay: id => actions.push(["close", id]), openOverlay: spec => actions.push(["open", spec]),
  localStorage: { getItem: key => stored.get(key), setItem: (key, value) => stored.set(key, value) },
  MenuMotion, MENU_CHROME, menuFrame, menuSearch, menuScrollbar,
};
const { Palette, keyOf } = new Function(...Object.keys(env), `${source}\nreturn { Palette, keyOf };`)(...Object.values(env));
const palette = new Palette();
palette.init({}, { ...cx, focus_handle: () => ({}), timer: { after: (_ms, callback) => callback(cx) } });
palette.render(cx);
assert.deepEqual(node("palette").rounded, [12]);
assert.deepEqual(node("pl-0").rounded, [18]);
assert.deepEqual(node("pl-0").text_size, [14]);
for (const command of ["end", "home", "pagedown", "pageup", ...Array(40).fill("down"), ...Array(40).fill("up")]) {
  palette.navigate(command, cx);
  palette.render(cx);
  const selected = node(`pl-${palette.at}`);
  assert(selected, `palette selection ${palette.at} is rendered`);
  if (selected.top) assert(selected.top[0] >= 0 && selected.bottom[0] >= 0, "palette selection stays within the viewport");
}
palette.navigate("home", cx);
palette.render(cx);
const listHeight = node("palette-rows").h[0];
node("palette-rows").on_scroll_wheel[0]({ delta: { y: -100 }, bounds: { height: listHeight * 2 } }, cx);
assert.equal(palette.scroll, 50, "palette wheel input accounts for the rendered scale");
palette.render(cx);
assert.equal(palette.scroll, 50, "rendering does not undo manual palette scrolling");
node("palette-scrollbar").on_mouse_down.at(-1)({ local_position: { y: listHeight / 2 }, bounds: { height: listHeight }, position: { y: 100 } }, cx);
node("palette").on_mouse_move[0]({ position: { y: 10000 } }, cx);
assert.equal(palette.scroll, palette.maxScroll, "the palette's shared scrollbar reaches the end");
node("palette").on_mouse_up.at(-1)();
assert.equal(palette.drag, null);
assert.equal(keyOf({ name: "app.zoom_in", args: {} }, bindings), null, "palette must not advertise overridden whole-app zoom shortcuts");
assert.equal(keyOf({ name: "minimal-pane.text-zoom-in", args: {} }, bindings), "cmd-=");
palette.query = "newtab";
palette.at = 0;
palette.revealPending = true;
assert.equal(palette.rows()[0].e.name, "tab.new");
palette.query = "nothing-can-match-this-query";
assert.equal(palette.rows().length, 0);
assert.doesNotThrow(() => palette.navigate("end", cx));
palette.query = "newtab";
palette.motion.phase = "open";
palette.go(palette.rows()[0].e, cx);
assert.equal(actions.length, 0);
timers.shift().callback(cx);
assert.deepEqual(actions.splice(0), [["close", "palette-id"], ["tab.new", {}]]);
const pickerSpec = JSON.parse(read("mods/minimal-picker/mod.json"));
const paletteSpec = JSON.parse(read("mods/minimal-palette/mod.json"));
assert.deepEqual(paletteSpec.overlay, pickerSpec.overlay, "menus share width, placement and framing");
assert.equal(pickerSpec.overlay.width, 1, "native popup host covers the window so the card can resize without reopening");
assert.equal(pickerSpec.overlay.height, 1);
assert.equal(pickerSpec.overlay.offset, 0);
for (const name of ["minimal-picker", "minimal-palette"]) {
  assert.equal(allKeys[`mod:${name}`].escape, `${name}.escape`);
  assert.equal(allKeys[`mod:${name}`]["cmd-shift-enter"], `${name}.zoom`);
  assert.equal(allKeys[`mod:${name}`]["alt-z"], `${name}.zoom`);
}
console.log("PASS: native menu motion lifecycle, deferred actions, shared styling, command search/navigation and effective shortcut labels");
