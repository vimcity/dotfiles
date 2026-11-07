import { View, div, image, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { home, layout, panes, props, run, settings, theme, window } from "herdr";

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
  pane() {
    return panes().find((pane) => pane.pane === props()?.pane);
  }

  render() {
    const t = theme();
    const pane = this.pane();
    if (!pane) return div();

    const root = layout();
    const sidebar = find(root, "sidebar");
    const win = window();
    const firstPane = panes().find(item => item.tab === pane.tab);
    const needsTrafficLightSpace = pane.zoomed || firstPane?.pane === pane.pane;
    const sidebarWidth = pane.zoomed || sidebar?.hidden ? 0 : sidebar?.size?.px ?? 0;
    const lightsPadding = needsTrafficLightSpace && win?.platform === "macos" && win.titlebar === "none" && !win.fullscreen && root?.traffic_lights
      ? Math.max(10, (root.traffic_lights[0] + 64) / settings().zoom - sidebarWidth)
      : 10;
    // Native traffic lights stay in window pixels while header content follows UI zoom.
    const rowHeight = win?.platform === "macos" && win.titlebar === "none" && !win.fullscreen && root?.traffic_lights
      ? 2 * (root.traffic_lights[1] + 6) / settings().zoom
      : "100%";
    const title = (pane.title ?? "").replace(/^[^\p{L}\p{N}~/]+/u, "").trim();
    const sessionTitle = pane.program?.agent && title && title !== pane.program.name
      && title.toLowerCase() !== pane.app && !/^[~/]/.test(title);
    const name = sessionTitle ? title : pane.program?.name || title || "Terminal";
    const programIcon = icon(pane.program, t.muted);

    return div().size_full().bg(t.background).child(h_flex().id(`pane-head-${pane.pane}`).w_full().h(rowHeight).pl(lightsPadding).pr(10).gap(8).items_center()
      .bg(t.background).text_size(12).line_height(1)
      .on_click(() => run("pane.focus", { pane: pane.pane }))
      .when(Boolean(programIcon), el => el.child(programIcon))
      .child(div().flex_none().truncate().max_w(220).font_medium().text_color(t.foreground).child(name))
      .child(div().min_w(0).truncate().text_color(t.ansi4).child(folder(pane.cwd)))
      .when(Boolean(pane.branch), el => el.child(div().min_w(0).truncate().text_color(t.ansi5).child(`⑂ ${pane.branch}`)))
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
