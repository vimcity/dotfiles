import fs from "node:fs";
import assert from "node:assert/strict";

const root = new URL("../", import.meta.url);
const read = path => fs.readFileSync(new URL(path, root), "utf8");
const source = read("mods/minimal-pane/main.js").replace(/^import .*;\n/gm, "")
  .replace("export default class CompactPane", "return class CompactPane");
const calls = [];
const notices = [];
let focused = true;
let result = { code: 0 };
const Pane = new Function("View", "props", "panes", "appHome", "exec", "notify", source)(
  class {}, () => ({ pane: "p1" }), () => [{ pane: "p1", focused }], () => "/app",
  async (command, args) => { calls.push([command, args]); return result; }, notice => notices.push(notice));
const header = new Pane();
header.init({}, { spawn() {} });
const tasks = [];
const cx = { spawn: task => tasks.push(task({})) };
for (const command of ["text-zoom-in", "text-zoom-in", "text-zoom-out", "text-zoom-reset"]) header.handleCommand(command, cx);
await Promise.all(tasks);
assert.deepEqual(calls.map(([, args]) => args.at(-1)), ["in", "in", "out", "reset"]);
assert(calls.every(([command, args]) => command === "python3" && args[0] === "/app/mods/minimal-pane/terminal-zoom.py" && args[1] === "/app"));
assert.equal(header.textZoomBusy, false);
assert.equal(notices.length, 0);
focused = false;
header.handleCommand("text-zoom-in", cx);
assert.equal(calls.length, 4, "unfocused header copies do not apply duplicate font changes");
focused = true;
result = { code: 1, stderr: "test write failure" };
header.handleCommand("text-zoom-in", cx);
header.handleCommand("text-zoom-in", cx);
await Promise.all(tasks);
assert.equal(calls.length, 5, "a failed change clears queued commands without automatic retries");
assert.equal(notices.length, 1);
assert.equal(notices[0].level, "error");
assert.equal(header.textZoomBusy, false);
const keys = JSON.parse(read("keys.json"));
const bindings = keys["layout:minimal-frappe"];
assert.equal(bindings["cmd-="], "minimal-pane.text-zoom-in");
assert.equal(bindings["cmd-+"], "minimal-pane.text-zoom-in");
assert.equal(bindings["cmd--"], "minimal-pane.text-zoom-out");
assert.equal(bindings["cmd-0"], "minimal-pane.text-zoom-reset");
assert.equal(keys.global["cmd-="], "app.zoom_in", "other layouts retain their existing zoom shortcuts");
console.log("PASS: terminal-only zoom routing, serialized rapid shortcuts, focused ownership, error reporting and layout-scoped keys");
