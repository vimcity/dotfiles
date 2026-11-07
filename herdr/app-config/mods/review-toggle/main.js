import { View, div } from "gpui-kit";
import { closeOverlay, focused, layout, notify, props, run, setShared, spaces, shared } from "herdr";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

export default class ReviewToggle extends View {
  init() {
    const root = layout();
    const main = find(root, "main"), panel = find(root, "panel"), body = find(root, "panel-body"), sidebar = find(root, "sidebar");
    if (!main || !panel || !body) {
      notify({ title: "Review view unavailable", body: "This layout has no Changes panel.", level: "error" });
      const overlay = props()?.overlay;
      if (overlay) closeOverlay(overlay);
      return;
    }
    const previous = shared("review.return");
    if (main.hidden && previous) {
      run("layout.show", { id: "main" });
      run("layout.resize", { id: "panel", px: previous.panelWidth ?? 368 });
      run("layout.select", { stack: "panel-body", child: previous.panelChild ?? "changes" });
      run(previous.panelHidden ? "layout.hide" : "layout.show", { id: "panel" });
      if (previous.sidebarWidth) run("layout.resize", { id: "sidebar", px: previous.sidebarWidth });
      run(previous.sidebarHidden ? "layout.hide" : "layout.show", { id: "sidebar" });
      if (previous.focus?.pane) run("pane.focus", { pane: previous.focus.pane });
      else if (previous.focus?.terminal) run("pane.focus", { terminal: previous.focus.terminal });
      setShared("review.return", null);
    } else {
      const current = focused();
      const space = spaces().find((item) => item.id === current?.space);
      const on = current?.pane === null
        ? (current.terminal?.includes("/") ? current.terminal.split("/")[0] : null)
        : space?.machine ?? null;
      setShared("review.return", {
        panelWidth: panel.size?.px ?? 368,
        panelHidden: Boolean(panel.hidden),
        panelChild: body.active ?? "changes",
        sidebarWidth: sidebar?.size?.px ?? 240,
        sidebarHidden: Boolean(sidebar?.hidden),
        context: { cwd: current?.cwd ?? space?.folder ?? null, on },
        focus: { pane: current?.pane ?? null, terminal: current?.terminal ?? null },
      });
      run("layout.select", { stack: "panel-body", child: "changes" });
      run("layout.show", { id: "panel" });
      run("layout.resize", { id: "panel", weight: 1 });
      run("layout.hide", { id: "main" });
      run("layout.hide", { id: "sidebar" });
    }
    const overlay = props()?.overlay;
    if (overlay) closeOverlay(overlay);
  }

  render() {
    return div().id("review-toggle").size(1);
  }
}
