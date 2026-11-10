import fs from "node:fs";
import assert from "node:assert/strict";

const root = new URL("../", import.meta.url);
const source = path => fs.readFileSync(new URL(path, root), "utf8");
const { navigateSidebar } = await import(`data:text/javascript;base64,${Buffer.from(source("mods/minimal-pane/sidebar-navigation.js")).toString("base64")}`);
const { SidebarPresence, SIDEBAR_HEIGHT, SIDEBAR_FADE } = await import(`data:text/javascript;base64,${Buffer.from(source("mods/minimal-sidebar/sidebar-motion.js")).toString("base64")}`);
const nodes = [];
function element() {
  const state = { children: [], transitions: [] };
  nodes.push(state);
  const proxy = new Proxy({}, { get: (_target, name) => (...args) => {
    if (name === "when") return args[0] ? args[1](proxy) : proxy;
    if (name === "child") state.children.push(args[0]);
    if (name === "transition") state.transitions.push(args);
    else state[name] = args;
    return proxy;
  } });
  return proxy;
}
function load(path, name, bindings) {
  const code = source(path).replace(/^import .*;\n/gm, "").replace(`export default class ${name}`, `return class ${name}`);
  return new Function(...Object.keys(bindings), code)(...Object.values(bindings));
}
const t = {
  chrome: "#292d3e", background: "#303446", foreground: "#c6d0f5", muted: "#a5adce", dim: "#838ba7",
  selected: "#454c64", hover: "#353b50", input: "#59617d", border: "#42475b", accent: "#babbf1",
  working: "#a6d189", blocked: "#e78284", done: "#e5c890",
};
const commands = [];
const sharedValues = {};
let items = [
  { id: "local", name: "rice", machine: null, active: true, tabs: [
    { id: "a", active: true, status: "working" }, { id: "b", active: false, status: "idle" },
  ] },
  { id: "remote", name: "project", machine: "work", active: false, tabs: [{ id: "c", active: true }] },
];
let allPanes = [
  { pane: "p1", tab: "a", terminal: "t1", focused: true, title: "A long session title", cwd: "/home/test/project", program: {} },
  { pane: "p2", tab: "a", terminal: "t2", focused: false, title: "Other split", program: {} },
  { pane: "p3", tab: "b", terminal: "t3", focused: false, title: "Background tab", program: {} },
];
const uiSource = source("mods/minimal-sidebar/ui.js").replace(/^import .*;\n/gm, "").replaceAll("export function", "function");
const sidebarButton = new Function("div", "svg", `${uiSource}\nreturn sidebarButton;`)(element, element);
const cx = { notify() {}, spawn() {}, timer: { every() {} } };
const labels = [];
const shared = {
  View: class {}, div: element, svg: element, v_flex: element, h_flex: element, navigateSidebar, sidebarButton, SidebarPresence, SIDEBAR_HEIGHT, SIDEBAR_FADE,
  settings: () => ({ zoom: 1 }),
  shared: key => key === "minimal.machine-usage.local" ? { cpu: 42, memory: 58 } : sharedValues[key],
  setShared: (key, value) => { sharedValues[key] = value; },
  theme: () => t, home: () => "/home/test", spaces: () => items, panes: () => allPanes, agents: () => [],
  sessionLabel: (_tab, pane) => ({ name: pane?.title || "Terminal", isAgent: true }),
  fadedLabel: (text, fill) => { labels.push([text, fill]); return element(); }, programIcon: element,
  run: (name, args) => commands.push([name, args]),
};
const Sidebar = load("mods/minimal-sidebar/main.js", "MinimalSidebar", {
  ...shared, machines: () => [{ name: null, layout: "ready" }, { name: "work", layout: "unavailable" }],
});
const sidebar = new Sidebar();
sidebar.init({}, cx);
const node = id => nodes.findLast(node => node.id?.[0] === id);
sidebar.render(cx);
assert(sidebar.expanded.has("local"), "the active space starts expanded");
assert.deepEqual(node("tab-a").bg, [t.selected]);
assert.deepEqual(node("tab-b").bg, [t.chrome]);
assert.deepEqual(node("tab-a").rounded, [18]);
assert.deepEqual(node("tab-slot-a").h, [39]);
assert(node("tab-slot-a").transitions.some(([property, policy]) => property === "height" && policy.duration === 160));
assert.deepEqual(node("sidebar-list").pl, [12]);
assert.deepEqual(node("sidebar-list").pr, [4]);
assert.deepEqual(node("tab-a").px, [7]);
assert.deepEqual(node("tab-a").border, [0.5]);
assert.deepEqual(node("tab-a").border_color, ["#ffffff0b"]);
assert.deepEqual(node("tab-a").text_size, [14]);
assert.deepEqual(node("tab-b").font_medium, []);
let wheelStopped = false;
node("sidebar-list").on_scroll_wheel[0]({ delta: { y: 1 } }, { stop_propagation() { wheelStopped = true; } });
assert(wheelStopped, "scroll navigation consumes the sidebar wheel event");
assert.deepEqual(commands.splice(0), [["tab.select", { id: "b" }]], "scrolling down navigates forward through tabs");
node("sidebar-list").on_scroll_wheel[0]({ delta: { y: -1 } }, { stop_propagation() {} });
assert.deepEqual(commands.splice(0), [["space.select", { id: "remote" }]], "scrolling up navigates backward through tabs");
sidebar.expanded.delete("remote");
sidebar.navigate(-1);
assert(sidebar.expanded.has("remote"), "keyboard navigation expands the destination workspace");
commands.splice(0);
node("sidebar-list").on_scroll_wheel[0]({ delta: { y: 72 } }, { stop_propagation() {} });
assert.deepEqual(commands.splice(0), [["space.select", { id: "remote" }]], "larger wheel gestures advance multiple entries");
sidebar.expanded.delete("remote");
node("sidebar-list").on_scroll_wheel[0]({ delta: { y: -1 } }, { stop_propagation() {} });
assert(sidebar.expanded.has("remote"), "wheel navigation expands the destination workspace");
commands.splice(0);
assert.deepEqual(node("machine-local").text_size, [12]);
assert(node("machine-metric-cpu").children.includes("42%"));
assert(node("machine-metric-memory").children.includes("58%"));
assert.deepEqual(node("space-name-local").font_weight, [700]);
assert.deepEqual(node("space-name-local").text_color, ["#7F86A1"]);
assert(labels.some(([label]) => label === "This Mac"));
assert(labels.some(([label]) => label === "Work"));
node("tab-b").on_hover[0](true, cx);
sidebar.render(cx);
assert.deepEqual(node("tab-b").bg, [t.hover]);
node("tab-b").on_click[0]();
assert.deepEqual(commands.splice(0), [["tab.select", { id: "b" }], ["pane.focus", { pane: "p3" }]]);
sidebar.navigate(1);
assert.deepEqual(commands.splice(0), [["tab.select", { id: "b" }]]);
sidebar.navigate(-1);
assert.deepEqual(commands.splice(0), [["space.select", { id: "remote" }]]);
assert(sidebar.expanded.has("remote"), "keyboard navigation expands its destination");
sidebar.render(cx);
assert.deepEqual(node("space-tabs-remote").h, [39]);
assert(node("space-tabs-remote").transitions.some(([property, policy]) => property === "height" && policy.easing === "ease-out"));
assert(sidebar.expanded.has("remote"), "live updates preserve manually opened spaces");
node("sidebar-list").on_size_change[0]({ width: 76, height: 600 }, cx);
sidebar.render(cx);
assert.deepEqual(node("space-tabs-local").h, [0]);
assert.deepEqual(node("space-heading-local").bg, [t.selected], "compact rail retains active-space selection");
node("sidebar-list").on_size_change[0]({ width: 275, height: 600 }, cx);
sidebar.render(cx);
sidebar.expanded.delete("remote");
node("space-heading-remote").on_click[0]({}, cx);
assert.deepEqual(commands.splice(0), [["space.select", { id: "remote" }], ["tab.select", { id: "c" }]]);
items = items.map(item => ({ ...item, active: item.id === "remote" }));
sidebar.render(cx);
assert.deepEqual([...sidebar.expanded], ["local", "remote"], "keyboard navigation opens the destination space");
items = items.map(item => ({ ...item, active: item.id === "local" }));
sidebar.render(cx);
node("space-heading-remote").on_click[0]({}, cx);
assert(!sidebar.expanded.has("remote"), "clicking expanded workspace collapses it");
items = items.map(item => ({ ...item, active: item.id === "remote" }));
sidebar.render(cx);
assert(sidebar.expanded.has("remote"), "the newly active space expands after selection changes");

sharedValues["command-prefix.tool-tabs"] = [{ terminal: "tool-terminal", previousTab: "a", name: "open lazygit", cwd: "/home/test/project", phase: "waiting" }];
allPanes.push({ pane: "tool-pane", terminal: "tool-terminal", tab: "tool-tab", program: { name: "lazygit" } });
sidebar.reconcileToolTabs(cx);
assert.deepEqual(commands.splice(0), [["pane.zoom", { pane: "tool-pane" }], ["tab.rename", { id: "tool-tab", name: "lazygit · project" }]]);
assert.equal(sharedValues["command-prefix.tool-tabs"][0].phase, "attached");
allPanes = allPanes.filter(pane => pane.terminal !== "tool-terminal");
sidebar.reconcileToolTabs(cx);
assert.deepEqual(commands.splice(0), [["tab.select", { id: "a" }]]);
assert.deepEqual(sharedValues["command-prefix.tool-tabs"], []);
sharedValues["command-prefix.tool-tabs"] = [{ terminal: "tool-pane-terminal", previousTab: "a", previousPane: "p1", name: "open lazygit", cwd: "/home/test/project", phase: "waiting" }];
allPanes.push({ pane: "tool-pane-2", terminal: "tool-pane-terminal", tab: "a", program: { name: "lazygit" } });
sidebar.reconcileToolTabs(cx);
assert.deepEqual(commands.splice(0), [["pane.zoom", { pane: "tool-pane-2" }]], "tools kept beside the current pane are zoomed without renaming the tab");
allPanes = allPanes.filter(pane => pane.terminal !== "tool-pane-terminal");
sidebar.reconcileToolTabs(cx);
assert.deepEqual(commands.splice(0), [["pane.focus", { pane: "p1" }]], "closing a tool pane restores focus to the pane that launched it");

let paneProps = { pane: "p1" };
const frame = { radius: 10, border: { width: 0.5 }, focus: { width: 0.5 } };
const headerLayout = { children: [{ id: "sidebar" }, { id: "main", content: { pane: frame } }] };
const paneIcons = [];
const Pane = load("mods/minimal-pane/main.js", "CompactPane", {
  ...shared, props: () => paneProps, layout: () => headerLayout,
  programIcon: () => { const icon = element(); paneIcons.push(icon); return icon; },
  appWindow: () => ({ platform: "macos", titlebar: "none", fullscreen: false }), settings: () => ({ zoom: 1 }),
});
const header = new Pane();
header.init({}, cx);
header.render(cx);
assert.equal(node("pane-head-p1").bg, undefined, "focus does not fill the header");
assert.equal(node("pane-focus-line-p1"), undefined, "focus adds no decorative line");
assert.deepEqual(node("pane-path-p1").font_semibold, []);
assert.deepEqual(node("pane-path-p1").text_color, [t.foreground]);
assert.deepEqual(node("pane-head-p1").text_size, [13.5]);
assert(node("pane-path-pill-p1").children.includes(paneIcons.at(-1)), "the focus pill includes the program icon");
assert.deepEqual(node("pane-path-pill-p1").gap, [5], "icon and path are tightly grouped");
assert.deepEqual(node("pane-path-pill-p1").bg, [t.selected], "focused pane and selected sidebar row share the selection color");
assert.deepEqual(node("pane-path-pill-p1").border_color, ["#ffffff0b"]);
assert.deepEqual(node("pane-path-p1").text_color, [t.foreground]);
assert.deepEqual(node("pane-path-pill-p1").rounded, [13]);
assert.equal(node("pane-path-pill-p1").flex_1, undefined, "pill hugs its content rather than filling the header");
assert.deepEqual(node("pane-head-p1").pl, [12]);
assert.deepEqual(node("pane-head-p1").rounded_t, [9.5]);
frame.radius = 12;
header.render(cx);
assert.deepEqual(node("pane-head-p1").rounded_t, [11.5], "header corners track the frame radius rather than an independent constant");
frame.radius = 10;
headerLayout.traffic_lights = [12, 11];
headerLayout.children[0].hidden = true;
headerLayout.children.push({ id: "work-body", padding: [0, 8] });
header.render(cx);
assert.deepEqual(node("pane-head-p1").pl, [109.5], "a hidden sidebar reserves the window-control region within the first header");
assert.deepEqual(node("fixed-sidebar-toggle").left, [75.5]);
assert.deepEqual(node("fixed-sidebar-toggle").top, [4.5], "sidebar icon aligns vertically with the native traffic-light row");
headerLayout.children.find(node => node.id === "work-body").padding = [6, 8];
header.render(cx);
assert.deepEqual(node("fixed-sidebar-toggle").top, [0], "control clearance accounts for the pane inset");
headerLayout.children[0].hidden = false;
header.render(cx);
assert(node("pane-path-p1").children.includes("~/project"), "header abbreviates the home directory");
assert.deepEqual(node("pane-path-p1").tooltip, ["/home/test/project"], "the tooltip retains the absolute path");
assert.deepEqual(node("pane-path-p1").overflow_x_scroll, []);
assert.equal(node("pane-path-p1").truncate, undefined);
commands.splice(0);
node("pane-head-p1").on_hover[0](true, cx);
header.render(cx);
let stopped = false;
node("split-p1").on_click[0]({}, { stop_propagation() { stopped = true; } });
assert(stopped);
assert.deepEqual(commands.splice(0), [["pane.split", { pane: "p1", direction: "right" }]]);
paneProps = { pane: "p2" };
header.render(cx);
assert.equal(node("pane-head-p2").bg, undefined, "inactive headers use the unchanged pane background");
assert.equal(node("pane-focus-line-p2"), undefined, "inactive headers have no focus line");
assert.deepEqual(node("pane-path-p2").text_color, [t.foreground], "inactive paths retain the sidebar's bright text color");
assert.deepEqual(node("pane-path-pill-p2").bg, ["#ffffff00"]);
assert.deepEqual(node("pane-head-p2").pl, node("pane-head-p1").pl, "selection changes no header geometry");
allPanes[0].focused = false;
allPanes[1].focused = true;
allPanes[1].cwd = "/very/long/path/" + "nested-directory/".repeat(30);
header.render(cx);
assert.equal(node("pane-focus-line-p2"), undefined);
assert.deepEqual(node("pane-path-p2").font_semibold, []);
assert(node("pane-path-p2").children.includes(allPanes[1].cwd), "long paths stay intact and scroll instead of truncating");
allPanes[1].cwd = "C:\\Users\\test\\Projects\\example";
header.render(cx);
assert(node("pane-path-p2").children.includes(allPanes[1].cwd), "remote Windows paths are preserved verbatim");
allPanes[1].cwd = "/home/test";
header.render(cx);
assert(node("pane-path-p2").children.includes("~"), "home itself is abbreviated");
allPanes[1].cwd = "/home/test-other/project";
header.render(cx);
assert(node("pane-path-p2").children.includes(allPanes[1].cwd), "similar directory prefixes are not abbreviated");
allPanes[1].zoomed = true;
header.hovered = false;
header.render(cx);
assert(node("zoom-p2"), "restore stays available when a zoomed header is not hovered");

const Metrics = load("mods/minimal-metrics/main.js", "MinimalMetrics", shared);
const metrics = new Metrics();
metrics.render();
assert.deepEqual(node("metrics-controller").size, [0], "metrics collection consumes no layout space");
assert(!source("mods/minimal-metrics/main.js").includes("openOverlay"), "the collector must not create floating controls or panels");
let stoppedToggle = false;
node("fixed-sidebar-toggle").on_click[0]({}, { stop_propagation() { stoppedToggle = true; } });
assert(stoppedToggle);
assert.deepEqual(commands.splice(0), [["layout.toggle", { id: "sidebar" }]]);

const gradients = [];
const geometry = new Proxy({}, { get: () => () => geometry });
const helpers = source("mods/minimal-sidebar/ui.js").replace(/^import .*;\n/gm, "").replaceAll("export function", "function");
const { fadedLabel } = new Function("div", "image", "svg", "PathBuilder", "Background", "window", `${helpers}\nreturn { fadedLabel };`)(
  element, element, element, { fill: () => geometry }, { linear_gradient: (...args) => { gradients.push(args); return {}; } }, { paint_path: element });
const start = nodes.length;
fadedLabel("Long title", t.chrome);
assert.deepEqual(gradients, [[90, "#292d3e00", t.chrome]]);
assert(nodes.slice(start).some(node => node.overflow_hidden));
assert(!nodes.slice(start).some(node => node.truncate), "fades clip text without introducing ellipses");
const boldStart = nodes.length;
fadedLabel("Workspace", t.chrome, true);
assert(nodes.slice(boldStart).some(node => node.children.includes("Workspace") && node.font_weight?.[0] === 700 && node.font_family?.[0] === "Helvetica Neue"), "bold applies to the text itself, not only the fade wrapper");
assert.equal(source("mods/minimal-sidebar/ui.js"), source("mods/minimal-pane/ui.js"), "sandbox copies share identical UI helpers");
const layout = JSON.parse(source("layouts/minimal-frappe.json"));
const findLayout = (id, node = layout) => node.id === id ? node : (node.children ?? []).map(child => findLayout(id, child)).find(Boolean);
const pane = findLayout("main").content.pane;
assert.equal(pane.radius, 10);
assert.equal(layout.type, "row");
assert.equal(layout.children[0].id, "metrics-controller");
assert.equal(layout.children[0].size.px, 0, "there is no global top strip");
assert(!JSON.stringify(layout).includes("minimal-sidebar-toggle"), "the accidental control panel must not return");
assert.equal(findLayout("work-body").padding[0], 6, "panes have a small breathing gap, not a toolbar row");
assert(!findLayout("sidebar").children.some(node => node.id === "brand"));
assert.equal(findLayout("sidebar").shadow, undefined, "no shadow seam between sidebar and gutter");
assert.equal(node("sidebar-list").pl[0], node("sidebar-list").pr[0] + findLayout("work-body").padding[1], "visible left/right gutters account for the workspace inset");
assert.equal(findLayout("work").background, "chrome", "workspace gutter matches the sidebar");
assert.equal(findLayout("work-body").background, "chrome");
assert.equal(findLayout("sidebar").background, "chrome");
assert.equal(pane.lone, true);
assert.equal(pane.gap, 8, "focus contrast changes do not alter pane spacing");
assert.deepEqual(pane.border, { width: 0.5, color: "#ffffff0a" });
assert.deepEqual(pane.focus, { width: 0.5, color: "#ffffff28" });
console.log("PASS: sidebar selection, hover, expansion, remote navigation, compact rail, pane focus, controls, fading labels and frames");
