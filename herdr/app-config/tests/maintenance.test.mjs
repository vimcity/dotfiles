import fs from "node:fs";
import assert from "node:assert/strict";

const root = new URL("../", import.meta.url);
const read = path => fs.readFileSync(new URL(path, root), "utf8");
const pure = path => import(`data:text/javascript;base64,${Buffer.from(read(path)).toString("base64")}`);
const load = (path, name, bindings) => new Function(...Object.keys(bindings), read(path)
  .replace(/^import .*;\n/gm, "").replace(`export default class ${name}`, `return class ${name}`))(...Object.values(bindings));
const { parseUsage } = await pure("mods/minimal-metrics/usage.js");
let visible = true;
const calls = [], updates = [], tasks = [];
let fail = false;
const Metrics = load("mods/minimal-metrics/main.js", "MinimalMetrics", {
  View: class {}, parseUsage, console: { log() {} },
  layout: () => ({ children: [{ id: "sidebar", hidden: !visible }] }),
  setShared: (key, value) => updates.push([key, value]),
  exec: async (command) => {
    calls.push(command);
    if (fail) return { code: 1, stderr: "sample failed" };
    const stdout = command.endsWith("sysctl") ? "10000" : command.endsWith("vm_stat")
      ? "page size of 100 bytes\nPages active: 20.\nPages wired down: 10."
      : "CPU usage: 1% user, 2% sys, 97% idle";
    return { code: 0, stdout };
  },
});
let interval;
const cx = { spawn: fn => tasks.push(fn(cx)), timer: { every: ms => { interval = ms; } } };
const metrics = new Metrics();
metrics.init({}, cx);
metrics.refresh(cx);
assert.equal(tasks.length, 1, "samples cannot overlap");
await tasks.at(-1);
assert.equal(interval, 10000);
assert.deepEqual(updates[0][1], { cpu: 3, memory: 30 });
metrics.refresh(cx);
await tasks.at(-1);
assert.equal(calls.filter(path => path.endsWith("sysctl")).length, 1, "total RAM is cached");
assert.equal(updates.length, 1, "unchanged counters do not redraw every mod");
visible = false;
const before = calls.length;
metrics.refresh(cx);
assert.equal(calls.length, before, "hidden sidebar does not sample");
visible = true;
fail = true;
metrics.refresh(cx);
await tasks.at(-1);
assert.equal(updates.at(-1)[1], null);
const failed = calls.length;
metrics.refresh(cx);
assert.equal(calls.length, failed, "failed service is not retried automatically");

const { fileTreeRows, diffRows, splitDiffRows } = await pure("mods/changes-close/diff-model.js");
const lines = ["@@ -2,2 +3,3 @@", " unchanged", "-before", "+after", "+extra"];
assert.deepEqual(diffRows(lines).map(row => row.number), [undefined, 3, 3, 4, 5]);
const split = splitDiffRows(lines);
assert.equal(split[2].oldText, "before");
assert.equal(split[2].newText, "after");
assert.equal(split[3].oldText, "");
assert.equal(split[3].newText, "extra");
assert.deepEqual(fileTreeRows([{ path: "src/z.js" }, { path: "a.js" }], new Set(["src"])).map(row => row.path), ["src", "a.js"]);
const syntax = read("mods/changes-close/syntax.js").replace(/^import .*;\n/gm, "").replaceAll("export function", "function");
const { languageFor, codeSegments } = new Function(`${syntax}\nreturn { languageFor, codeSegments };`)();
assert.equal(languageFor("folder/app.tsx"), "js");
assert.equal(languageFor(".zshrc"), "sh");
assert.equal(languageFor("unknown.ext"), "plain");
const code = "const value = 42; // note";
assert.equal(codeSegments(code, "js", {}).map(segment => segment.text).join(""), code);

const policy = await pure("mods/recap/session-policy.js");
assert.equal(policy.ticketKey("fix ABC-123 auth"), "ABC-123");
assert.equal(policy.ticketKey("phase-123"), null);
assert.equal(policy.machineOf("server/t1"), "server");
assert.equal(policy.clean("π - Login fix"), "π - Login fix");
let resolveCore, resolveRecap;
const pollTasks = [], helperCalls = [];
const agent = { address: "t1", app: "claude-code", status: "idle" };
const Recap = load("mods/recap/main.js", "Recap", {
  View: class {}, ...policy, appHome: () => "/tmp", agents: () => [agent],
  hc: () => new Promise(resolve => { resolveCore = resolve; }),
  tool: (...args) => { helperCalls.push(args); return new Promise(resolve => { resolveRecap = resolve; }); },
});
const recap = new Recap();
Object.assign(recap, { info: {}, unasked: {}, lookedUp: Date.now(), giveTitles() {}, keep: () => false });
const pollCx = { spawn: fn => pollTasks.push(fn(pollCx)), notify() {} };
recap.ask(pollCx, true);
recap.ask(pollCx, false);
assert.equal(pollTasks.length, 1, "core reads cannot overlap");
resolveCore({ code: 0, stdout: JSON.stringify({ foreground: { pid: 42 }, status_ms: 1 }) });
await new Promise(resolve => setImmediate(resolve));
recap.ask(pollCx, false);
assert.equal(pollTasks.length, 1, "guard covers machine helpers, not only core reads");
assert(helperCalls[0][1].includes("--write"));
resolveRecap([{ pid: 42, title: "Updated" }]);
await pollTasks[0];
assert.equal(recap.asking, false);
assert.equal(recap.info.t1.title, "Updated");
recap.askEach = async () => { throw new Error("test failure"); };
recap.ask(pollCx, false);
resolveCore({ code: 0, stdout: "{}" });
await assert.rejects(pollTasks[1], /test failure/);
assert.equal(recap.asking, false, "failed polls release the overlap guard");
const integration = new Recap();
const pendingLookups = new Map(), lookupTasks = [];
Object.assign(integration, {
  info: { t1: { remote: "repo", branch: "feature", ticket: "ABC-123" } },
  prs: {}, issues: {}, unasked: {}, keep: () => false,
  where: name => new Promise((resolve, reject) => pendingLookups.set(name, { resolve, reject })),
});
const lookupCx = { spawn: fn => lookupTasks.push(fn(lookupCx)), notify() {} };
integration.lookUp(lookupCx);
integration.lookUp(lookupCx);
assert.equal(lookupTasks.length, 2, "each integration has its own in-flight guard");
pendingLookups.get("herdr-github").resolve([{ remote: "repo", branch: "feature", pr: { number: 1 } }]);
pendingLookups.get("herdr-linear").reject(new Error("test failure"));
await Promise.all(lookupTasks);
assert.equal(integration.prPending, false);
assert.equal(integration.issuePending, false);
assert.equal(Object.values(integration.prs)[0].number, 1);
assert.match(integration.unasked.linear, /test failure/);
console.log("PASS: metrics sampling, hidden/unchanged work, diff models, syntax, session policy and complete poll/lookup lifetime");
