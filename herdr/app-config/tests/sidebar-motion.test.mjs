import fs from "node:fs";
import assert from "node:assert/strict";

const source = fs.readFileSync(new URL("../mods/minimal-sidebar/sidebar-motion.js", import.meta.url), "utf8");
const { SidebarPresence, SIDEBAR_HEIGHT, SIDEBAR_FADE } = await import(`data:text/javascript;base64,${Buffer.from(source).toString("base64")}`);
assert.deepEqual(SIDEBAR_HEIGHT, { duration: 160, easing: "ease-out" });
assert.deepEqual(SIDEBAR_FADE, { duration: 110, easing: "ease-out" });
assert(!source.includes("timer.every") && !source.includes("setInterval"), "motion must not use scripted frame loops");
function clock() {
  let now = 0;
  const pending = [];
  const cx = { notifications: 0, notify() { this.notifications++; }, timer: {
    after(ms, callback) { pending.push({ at: now + ms, callback }); },
  } };
  return { cx, pending, advance(ms) {
    const end = now + ms;
    for (;;) {
      pending.sort((a, b) => a.at - b.at);
      if (!pending.length || pending[0].at > end) break;
      const task = pending.shift(); now = task.at; task.callback(cx);
    }
    now = end;
  } };
}
const group = ids => ({ id: "work/project", value: { name: "Project" }, rows: ids.map(id => ({ id, value: { label: `Session ${id}` } })) });
const timer = clock();
const presence = new SidebarPresence();
let groups = presence.sync([group(["a", "b"])], timer.cx);
assert.equal(timer.pending.length, 0, "initial content does not replay an entrance on load");
assert(groups.every(group => group.phase === "open"));
assert(presence.rows(groups[0]).every(row => row.phase === "open"));
groups = presence.sync([group(["a", "c", "b"])], timer.cx);
assert.deepEqual(groups[0].rowOrder, ["a", "c", "b"]);
assert.equal(groups[0].rows.get("c").phase, "enter");
assert.equal(groups[0].rows.get("a").phase, "open");
timer.advance(16);
assert.equal(groups[0].rows.get("c").phase, "open");
assert.equal(timer.cx.notifications, 1);
presence.sync([group(["a", "b"])], timer.cx);
assert.deepEqual(groups[0].rowOrder, ["a", "c", "b"], "exiting rows retain their position until their native transition completes");
assert.equal(groups[0].rows.get("c").phase, "exit");
assert.equal(groups[0].rows.get("c").value.label, "Session c", "closing rows keep their last display data");
timer.advance(160);
assert(groups[0].rows.has("c"));
timer.advance(20);
assert.deepEqual(groups[0].rowOrder, ["a", "b"]);
assert(!groups[0].rows.has("c"));
const notifications = timer.cx.notifications;
presence.sync([group(["a", "b"])], timer.cx);
assert.equal(timer.pending.length, 0, "ordinary live updates do not schedule animation timers");
assert.equal(timer.cx.notifications, notifications);

const fast = clock();
const changing = new SidebarPresence();
changing.sync([group(["a", "b"])], fast.cx);
changing.sync([group(["a"])], fast.cx);
fast.advance(50);
changing.sync([group(["a", "b"])], fast.cx);
assert.equal(changing.groups.get("work/project").rows.get("b").phase, "open");
changing.sync([group(["a"])], fast.cx);
fast.advance(130);
assert(changing.groups.get("work/project").rows.has("b"), "an old cleanup deadline must not remove a newer exit");
fast.advance(50);
assert(!changing.groups.get("work/project").rows.has("b"));
changing.sync([group(["a", "new"])], fast.cx);
changing.sync([group(["a"])], fast.cx);
fast.advance(16);
assert.equal(changing.groups.get("work/project").rows.get("new").phase, "exit", "a tab closed during its entrance must not reopen");
fast.advance(164);
assert(!changing.groups.get("work/project").rows.has("new"));

const whole = clock();
const spaces = new SidebarPresence();
spaces.sync([group(["last"])], whole.cx);
let closing = spaces.sync([], whole.cx);
assert.equal(closing[0].phase, "exit");
assert.equal(closing[0].rows.get("last").phase, "exit");
whole.advance(180);
assert.deepEqual(spaces.sync([], whole.cx), [], "last-tab space removal also retains and then removes its display snapshot");
spaces.sync([group(["again"])], whole.cx);
assert.equal(spaces.groups.get("work/project").phase, "enter");
whole.advance(16);
assert.equal(spaces.groups.get("work/project").phase, "open");
assert.equal(spaces.groups.get("work/project").rows.get("again").phase, "open");
spaces.sync([], whole.cx);
whole.advance(50);
spaces.sync([group(["again"])], whole.cx);
whole.advance(130);
assert.equal(spaces.groups.get("work/project").phase, "open", "revived spaces survive stale cleanup callbacks");
console.log("PASS: native sidebar timing, stable snapshots/order, rapid creation/closure, last-tab removal and stale timer guards");
