import fs from "node:fs";
import assert from "node:assert/strict";

const source = fs.readFileSync(new URL("../mods/minimal-pane/main.js", import.meta.url), "utf8")
  .replace(/^import .*;\n/gm, "")
  .replace("export default class CompactPane", "return class CompactPane");
const calls = [];
const pane = { pane: "pane", terminal: "t1", tab: "tab", focused: true };
const foreground = { name: "nvim", pid: 123, argv: ["nvim"] };
const Pane = new Function("View", "props", "panes", "terminals", "spaces", "exec", "run", "notify", "appHome", source)(
  class {}, () => ({ pane: "pane" }), () => [pane], () => [{ address: "t1", foreground }],
  () => [{ machine: null, tabs: [{ id: "tab" }] }],
  async (...args) => { calls.push(args); return { code: 0, stdout: "/tmp/discovered.sock\n" }; },
  (...args) => calls.push(args),
  error => { throw new Error(JSON.stringify(error)); }, () => "/app",
);
const tasks = [];
const cx = { spawn: callback => tasks.push(callback()) };
const header = new Pane();
header.handleCommand("go-down", cx);
await Promise.all(tasks.splice(0));
assert.deepEqual(calls.splice(0), [["python3", ["/app/mods/minimal-pane/nvim-input.py", "123", "<C-j>"], { on: null }]]);
header.handleCommand("go-down", cx);
await Promise.all(tasks.splice(0));
assert.equal(calls[0][0], "nvim", "subsequent navigation bypasses socket discovery");
assert.equal(calls[0][1][1], "/tmp/discovered.sock");
calls.length = 0;
foreground.argv = ["nvim", "--server", "/tmp/persistent.sock", "--remote-ui"];
header.handleCommand("go-up", cx);
await Promise.all(tasks.splice(0));
assert.equal(calls[0][1][1], "/tmp/persistent.sock");
calls.length = 0;
foreground.name = "zsh";
header.handleCommand("go-left", cx);
assert.deepEqual(calls.splice(0), [["pane.go", { direction: "left" }]]);
console.log("PASS: direct Neovim RPC, persistent remote UI, and non-editor pane navigation");
