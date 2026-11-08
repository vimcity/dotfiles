import { View, div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { appHome, exec, hc, home, layout, nextCommand, notify, panes, props, run, settings, spaces, theme, terminals, window as appWindow } from "herdr";

import { programIcon, sidebarButton } from "./ui.js";
import { navigateSidebar } from "./sidebar-navigation.js";

// Editors that own ctrl+h/j/k/l for their own splits. The app would otherwise
// swallow those keys, so they are handed to the program and only move pane
// focus when the program is not one of these. Same idea as the vim-herdr-
// navigation plugin on the TUI: the decision is made outside the editor.
const SPLIT_KEY = { left: "ctrl+h", down: "ctrl+j", up: "ctrl+k", right: "ctrl+l" };
const EDITOR_RE = /^(g?(view|l?n?vim?x?)(diff)?)$/;

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

export default class CompactPane extends View {
  init(_props, cx) {
    this.hovered = false;
    this.navigating = false;
    this.textZoomQueue = [];
    this.textZoomBusy = false;
    cx.spawn(async (cx) => {
      for (;;) this.handleCommand(await nextCommand(), cx);
    });
  }

  handleCommand(command, cx) {
    const pane = this.pane();
    if (!pane?.focused) return;
    if (["text-zoom-in", "text-zoom-out", "text-zoom-reset"].includes(command)) {
      this.zoomText(command.slice("text-zoom-".length), cx);
      return;
    }
    if (command === "sidebar-next" || command === "sidebar-prev") {
      navigateSidebar(command === "sidebar-next" ? 1 : -1, spaces(), run);
      return;
    }
    const direction = command.startsWith("go-") ? command.slice(3) : null;
    if (!["left", "right", "up", "down"].includes(direction) || this.navigating) return;
    if (this.forwardToEditor(pane, direction, cx)) return;
    if (!pane.zoomed) {
      run("pane.go", { direction });
      return;
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
        if (target?.tab === tab && !target.zoomed) run("pane.zoom", { pane: target.pane });
        this.navigating = false;
      });
    });
  }

  zoomText(action, cx) {
    this.textZoomQueue.push(action);
    if (this.textZoomBusy) return;
    this.textZoomBusy = true;
    cx.spawn(async (_cx) => {
      try {
        while (this.textZoomQueue.length) {
          const result = await exec("python3", [`${appHome()}/mods/minimal-pane/terminal-zoom.py`, appHome(), this.textZoomQueue.shift()]);
          if (result.code !== 0) throw new Error(result.stderr || "Could not change terminal font size");
        }
      } catch (error) {
        this.textZoomQueue = [];
        notify({ title: "Terminal text zoom failed", body: String(error), level: "error" });
      } finally {
        this.textZoomBusy = false;
      }
    });
  }

  pane() {
    return panes().find((pane) => pane.pane === props()?.pane);
  }

  // True when the key was handed to the program in this pane instead of moving
  // pane focus. Only the focused pane answers, and only while its program is an
  // editor that handles split navigation itself.
  forwardToEditor(pane, direction, cx) {
    if (!pane.focused || !pane.terminal) return false;
    const info = terminals().find((item) => item.address === pane.terminal);
    const name = String(info?.foreground?.name ?? "").toLowerCase().split("/").pop() ?? "";
    if (!EDITOR_RE.test(name)) return false;
    cx.spawn(async () => {
      try {
        const result = await hc(["keys", pane.terminal, SPLIT_KEY[direction]]);
        if (result.code !== 0) throw new Error(result.stderr || "Could not send the key");
      } catch (error) {
        notify({ title: "Could not reach the editor", body: String(error), level: "error" });
      }
    });
    return true;
  }

  render(cx) {
    const t = theme();
    const pane = this.pane();
    if (!pane) return div();

    const root = layout();
    const frame = find(root, "main")?.content?.pane;
    const borderWidth = (pane.focused ? frame?.focus?.width : null) ?? frame?.border?.width ?? 0;
    const headerRadius = Math.max(0, (frame?.radius ?? 0) - borderWidth);
    const sidebar = find(root, "sidebar");
    const win = appWindow();
    const firstPane = panes().find(item => item.tab === pane.tab);
    const needsTrafficLightSpace = pane.zoomed || firstPane?.pane === pane.pane;
    const sidebarVisible = Boolean(sidebar) && !sidebar.hidden;
    const zoom = Number(settings().zoom) || 1;
    const padding = find(root, "work-body")?.padding ?? 0;
    const inset = Array.isArray(padding) ? padding[1] : padding;
    const topInset = Array.isArray(padding) ? padding[0] : padding;
    const controlLeft = (win?.platform === "macos" && root?.traffic_lights ? root.traffic_lights[0] + 72 : 12) / zoom;
    const showSidebarButton = !sidebarVisible && needsTrafficLightSpace;
    const buttonLeft = Math.max(0, controlLeft - inset - borderWidth);
    const lightsPadding = showSidebarButton ? Math.max(12, buttonLeft + 34 / zoom) : 12;
    const path = pane.cwd || (pane.mod ? `Panel · ${pane.mod}` : "Directory unavailable");
    const homePath = home().replace(/\/$/, "");
    const label = path === homePath ? "~" : path.startsWith(`${homePath}/`) ? `~${path.slice(homePath.length)}` : path;
    const titleColor = t.foreground;
    const action = (id, asset, tooltip, command, args) => div().id(`${id}-${pane.pane}`)
      .size(23).flex_none().flex().items_center().justify_center().rounded(5).cursor_pointer()
      .text_color(t.dim).hover(el => el.bg(t.raised).text_color(t.foreground)).tooltip(tooltip)
      .on_mouse_down("left", (_event, cx) => cx.stop_propagation())
      .on_click((_event, cx) => { cx.stop_propagation(); run(command, { pane: pane.pane, ...args }); })
      .child(svg(`mods/minimal-pane/${asset}.svg`).size(13));

    return div().size_full().rounded_t(headerRadius).overflow_hidden().bg(t.background)
      .child(h_flex().id(`pane-head-${pane.pane}`).relative().size_full().rounded_t(headerRadius).pl(lightsPadding).pr(8).gap(8).items_center()
      .text_size(13.5).line_height(1).overflow_hidden()
      .on_hover((hovered, cx) => { this.hovered = hovered; cx.notify(); })
      .on_click(() => run("pane.focus", { pane: pane.pane }))
      .when(showSidebarButton, el => el.child(sidebarButton(t, zoom, () => run("layout.toggle", { id: "sidebar" }))
        .absolute().left(buttonLeft).top(Math.max(0, 5 / zoom - topInset - borderWidth))))
      .child(h_flex().min_w(0).flex_1().items_center()
        .child(h_flex().id(`pane-path-pill-${pane.pane}`).min_w(0).max_w_full().h(26).px(8).gap(5).items_center().rounded(13)
          .bg(pane.focused ? t.selected : "#ffffff00").border(0.5).border_color(pane.focused ? "#ffffff0b" : "#ffffff00")
          .child(programIcon(pane.program, titleColor, 15).id(`pane-program-${pane.pane}`))
          .child(div().id(`pane-path-${pane.pane}`).min_w(0).flex_1().whitespace_nowrap().overflow_x_scroll()
            .font_medium().when(pane.focused, el => el.font_semibold()).text_color(titleColor).tooltip(path).child(label))))
      .when(pane.status === "working", el => el.child(svg("mods/workspace-chrome/spinner.svg").size(11).flex_none().text_color(t.dim).spin(900)))
      .when(pane.status === "blocked", el => el.child(div().flex_none().px(6).py(3).rounded(4).bg(t.blocked + "18").text_size(10).text_color(t.blocked).child("Needs you")))
      .when(pane.status === "done", el => el.child(div().size(5).flex_none().rounded(3).bg(t.done)))
      .when(this.hovered, el => el.child(action("split", "split-right", "Split right", "pane.split", { direction: "right" })))
      .when(this.hovered || pane.zoomed, el => el.child(action("zoom", pane.zoomed ? "unzoom" : "zoom", pane.zoomed ? "Restore splits" : "Zoom pane", "pane.zoom"))));
  }
}
