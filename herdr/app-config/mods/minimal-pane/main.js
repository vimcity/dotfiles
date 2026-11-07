import { View, div, image, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { agents, home, layout, nextCommand, panes, props, run, settings, spaces, theme, window } from "herdr";

import { sessionLabel } from "./session-label.js";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

function folder(cwd) {
  if (!cwd) return "";
  const h = home();
  return cwd === h ? "~" : cwd.startsWith(h + "/") ? "~" + cwd.slice(h.length) : cwd;
}

function icon(program, color) {
  if (!program?.icon) return null;
  return program.tint
    ? svg(program.icon).size(13).flex_none().text_color(color)
    : image(program.icon).w(13).h(13).flex_none();
}

export default class CompactPane extends View {
  init(_props, cx) {
    this.lastFocused = false;
    this.flashTask = null;
    this.highlighted = false;
    this.navigating = false;
    cx.spawn(async (cx) => {
      for (;;) {
        const command = await nextCommand();
        const direction = command.startsWith("go-") ? command.slice(3) : null;
        const pane = this.pane();
        if (!["left", "right", "up", "down"].includes(direction)
          || !pane?.focused || this.navigating) continue;
        if (!pane.zoomed) {
          run("pane.go", { direction });
          continue;
        }
        this.navigating = true;
        const tab = pane.tab;
        run("pane.zoom", { pane: pane.pane });
        cx.timer.after(40, (cx) => {
          const current = panes().find(item => item.focused);
          if (current?.pane !== pane.pane || current.zoomed) {
            this.navigating = false;
            return;
          }
          run("pane.go", { direction });
          cx.timer.after(40, () => {
            const target = panes().find(item => item.focused);
            if (target?.tab === tab && !target.zoomed) {
              run("pane.zoom", { pane: target.pane });
            }
            this.navigating = false;
          });
        });
      }
    });
  }

  flash(cx) {
    this.flashTask?.cancel();
    this.highlighted = true;
    this.flashTask = cx.timer.after(700, (cx) => {
      this.highlighted = false;
      this.flashTask = null;
      cx.notify();
    });
  }

  pane() {
    return panes().find((pane) => pane.pane === props()?.pane);
  }

  render(cx) {
    const t = theme();
    const pane = this.pane();
    if (!pane) return div();

    if (pane.focused && !this.lastFocused) this.flash(cx);
    if (!pane.focused && this.lastFocused) {
      this.flashTask?.cancel();
      this.flashTask = null;
      this.highlighted = false;
    }
    this.lastFocused = pane.focused;

    const root = layout();
    const sidebar = find(root, "sidebar");
    const win = window();
    const firstPane = panes().find(item => item.tab === pane.tab);
    const needsTrafficLightSpace = pane.zoomed || firstPane?.pane === pane.pane;
    const sidebarVisible = Boolean(sidebar) && !sidebar.hidden;
    const trafficLights = needsTrafficLightSpace && !sidebarVisible
      && win?.platform === "macos" && win.titlebar === "none" && !win.fullscreen && root?.traffic_lights;
    // Reserve titlebar space only when the sidebar is not already holding the traffic lights.
    const lightsPadding = trafficLights ? Math.max(10, (root.traffic_lights[0] + 64) / settings().zoom) : 10;
    const rowHeight = trafficLights ? 2 * (root.traffic_lights[1] + 6) / settings().zoom : "100%";
    const tab = spaces().flatMap(space => space.tabs).find(tab => tab.id === pane.tab);
    const label = sessionLabel(tab, pane, agents().find(agent => agent.address === pane.terminal), folder);
    const name = label.name;
    const gold = "#EFAB65";
    const highlight = pane.focused && this.highlighted;
    const programIcon = icon(pane.program, t.foreground);
    const goldIcon = icon(pane.program, gold);

    return div().size_full().bg(t.background)
      .child(h_flex().id(`pane-head-${pane.pane}`).w_full().h(rowHeight).pl(lightsPadding).pr(10).gap(8).items_center()
      .text_size(12).line_height(1)
      .on_click(() => run("pane.focus", { pane: pane.pane }))
      .child(h_flex().id(`pane-focus-mark-${pane.pane}`).relative().min_w(0).px(10).py(5).gap(6).items_center().rounded(16)
        .bg(pane.focused ? t.selected : t.background)
        .when(Boolean(programIcon), el => el.child(programIcon))
        .child(div().flex_none().truncate().max_w(label.isAgent ? 500 : 220).font_medium().text_color(t.foreground).child(name))
        .when(Boolean(label.detail), el => el.child(div().min_w(0).max_w(340).truncate().text_color(t.muted).child(label.detail)))
        .when(pane.focused, el => el.child(div().size(5).flex_none().rounded(3).bg(gold)))
        .child(h_flex().id(`pane-gold-fade-${pane.pane}`).absolute().inset_0()
          .px(10).py(5).gap(6).items_center().rounded(16).bg("#EFAB6526")
          .opacity(highlight ? 1 : 0)
          .transition("opacity", { duration: highlight ? 0 : 150, easing: "ease-out" })
          .when(Boolean(goldIcon), el => el.child(goldIcon))
          .child(div().flex_none().truncate().max_w(label.isAgent ? 500 : 220).font_medium().text_color(gold).child(name))
          .when(Boolean(label.detail), el => el.child(div().min_w(0).max_w(340).truncate().text_color(gold).child(label.detail)))))
      .when(Boolean(pane.branch), el => el.child(h_flex().min_w(0).gap(5).items_center().text_color(t.ansi5)
        .child(svg("mods/workspace-chrome/git-branch.svg").size(14).flex_none())
        .child(div().min_w(0).truncate().child(pane.branch))))
      .when(pane.status === "working", el => el.child(svg("mods/workspace-chrome/spinner.svg").size(12).flex_none().text_color(t.working).spin(900)))
      .child(div().flex_1())
      .when(pane.status === "blocked", el => el.child(div().flex_none().px(6).h(18).flex().items_center().rounded(0).bg(t.blocked + "26").text_size(10.5).font_semibold().text_color(t.blocked).child("Needs you")))
      .when(pane.status === "done", el => el.child(div().size(7).flex_none().rounded(4).bg(t.done)))
      .when(pane.zoomed, el => el.child(h_flex().id(`pane-restore-${pane.pane}`)
        .flex_none().h(20).px(6).gap(5).items_center().cursor_pointer()
        .text_color(t.accent).hover(s => s.bg(t.hover))
        .on_mouse_down("left", (_event, cx) => cx.stop_propagation())
        .on_click((_event, cx) => {
          cx.stop_propagation();
          run("pane.zoom", { pane: pane.pane });
        })
        .child(svg("mods/minimal-pane/unzoom.svg").size(12).flex_none()))));

  }
}
