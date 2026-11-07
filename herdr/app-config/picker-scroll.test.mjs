import fs from "node:fs";
import assert from "node:assert/strict";

const path = new URL("./mods/minimal-picker/", import.meta.url);
const navigation = fs.readFileSync(new URL("navigation.js", path));
const { revealTarget } = await import(`data:text/javascript;base64,${navigation.toString("base64")}`);
const sizes = Array.from({ length: 70 }, (_, index) => index % 6 === 0 ? 28 : 44);
for (const height of [120, 240, 400]) {
  let offset = 0;
  for (const index of [...sizes.keys(), ...[...sizes.keys()].reverse()]) {
    const target = revealTarget(sizes, index, height, offset);
    if (target) offset = target.offset;
    const top = sizes.slice(0, index).reduce((sum, size) => sum + size, 0);
    assert(top >= offset && top + sizes[index] <= offset + height);
  }
}
assert.equal(revealTarget([44, 44, 44, 44], 1, 132, 0), null);

const handlers = {};
const element = new Proxy({}, { get: (_target, name) => (...args) => {
  if (name === "on_key_down") handlers.key = args[0];
  return element;
} });
const timers = [];
const cx = {
  timer: { after: (_delay, callback) => {
    const task = { callback, cancelled: false, cancel() { this.cancelled = true; } };
    timers.push(task);
    return task;
  } },
  notify() {}, stop_propagation() {},
};
const flush = () => { for (const task of timers.splice(0)) if (!task.cancelled) task.callback(); };
const source = fs.readFileSync(new URL("main.js", path), "utf8")
  .replace(/^import .*;\n/gm, "").replace("export default class Picker", "return class Picker");
let spaces = [];
const Picker = new Function("View", "div", "v_flex", "h_flex", "theme", "settings", "v_virtual_list", "Input", "window", "revealTarget", "spaces", "agents", "panes", "machines", "sessionLabel", "svg", source)(
  class {}, () => element, () => element, () => element, () => ({}), () => ({ zoom: 1 }),
  () => element, { new: () => element }, { viewport_size: () => ({ height: 600 }) }, revealTarget,
  () => spaces, () => [], () => [], () => [], () => ({ name: "Terminal", isAgent: false }), () => element);
const scrolls = [];
const picker = new Picker();
Object.assign(picker, { at: null, selectedKey: null, revealPending: true, scrollOffset: null,
  input: {}, handle: {}, scrollHandle: { scroll_to_item: (...args) => scrolls.push(args) } });
let rows = Array.from({ length: 30 }, (_, index) => ({ kind: "ctx", ctx: { id: `t${index}` }, w: {},
  current: { pane: `p${index}`, focused: index === 3 }, label: { isAgent: true }, status: "idle" }));
picker.rows = () => rows;
picker.render(cx); flush();
assert.equal(scrolls.length, 1);
rows = rows.map(row => ({ ...row, status: "working" }));
picker.render(cx); flush();
assert.equal(scrolls.length, 1, "live status updates must not move the scroll position");
picker.manualScroll();
picker.render(cx); flush();
assert.equal(scrolls.length, 1, "manual scrolling must not snap back on the next render");
handlers.key({ key: "down" }, cx);
picker.render(cx); flush();
const afterManual = scrolls.length;
handlers.key({ key: "down" }, cx);
picker.render(cx); flush();
assert.equal(scrolls.length, afterManual, "moving to an already visible row must not re-center");
const selected = picker.selectedKey;
rows = [{ ...rows[0], ctx: { id: "inserted" }, current: { pane: "inserted" } }, ...rows];
picker.render(cx); flush();
assert.equal(picker.selectedKey, selected, "selection must follow the pane identity, not its old index");
assert.equal(scrolls.length, afterManual);
picker.at = rows.length - 1;
picker.selectedKey = "ctx-p29";
picker.render(cx);
handlers.key({ key: "down" }, cx);
picker.render(cx); flush();
assert.equal(picker.selectedKey, "ctx-p29", "Down must stop at the end, not wrap");

const ordering = new Picker();
ordering.filter = "";
spaces = [{ id: "a", name: "a", status: "idle", tabs: [{ id: "ta" }] },
  { id: "b", name: "b", status: "working", tabs: [{ id: "tb" }] }];
assert.deepEqual(ordering.rows().filter(row => row.kind === "head").map(row => row.w.id), ["a", "b"]);
spaces[0].status = "blocked";
spaces[1].status = null;
assert.deepEqual(ordering.rows().filter(row => row.kind === "head").map(row => row.w.id), ["a", "b"]);
console.log("PASS: viewport-edge navigation, manual-scroll ownership, stable selection/order, no wrapping or live-update jumps");

spaces = [
  { id: "local", name: "rice", machine: null, tabs: [{ id: "local-tab" }] },
  { id: "work-a", name: "project", machine: "work", tabs: [{ id: "work-tab-a" }] },
  { id: "work-b", name: "other", machine: "work", tabs: [{ id: "work-tab-b" }] },
  { id: "build", name: "jobs", machine: "build", tabs: [{ id: "build-tab" }] },
];
assert.deepEqual(ordering.rows().filter(row => row.kind === "machine").map(row => row.machine), [null, "work", "build"]);
let dismissed = false;
ordering.dismiss = () => { dismissed = true; };
ordering.go({ kind: "machine", machine: "work" });
assert.equal(dismissed, false, "machine headers must not act as selectable sessions");
console.log("PASS: one header per machine; machine headers are not selectable");
