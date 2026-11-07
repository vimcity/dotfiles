import { View, div, image, svg } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { home, panes, run, spaces, theme } from "herdr";

function paneLabel(tab, pane) {
  const name = tab.named ? tab.name : pane?.program?.name ?? pane?.title ?? "Terminal";
  const cwd = pane?.cwd?.replace(`${home()}/`, "~/");
  return [name, cwd].filter(Boolean).join("  ");
}

function paneIcon(program, color, size = 14) {
  if (!program?.icon) return svg("mods/workspace-chrome/terminal.svg").size(size).flex_none().text_color(color);
  return program.tint
    ? svg(program.icon).size(size).flex_none().text_color(color)
    : image(program.icon).w(size).h(size).flex_none();
}

function paneIndicator(items, current, t) {
  return div().relative().w(items.length > 1 ? 25 : 18).h(22).flex_none()
    .child(div().absolute().left(0).top(4)
      .child(paneIcon(current?.program, t.foreground, 15)))
    .when(items.length > 1, el => el.child(div().absolute().left(16).top(0)
      .text_size(9).font_medium().text_color(t.muted).child(String(items.length))));
}

export default class MinimalSidebar extends View {
  render() {
    const t = theme();
    const allPanes = panes();
    return v_flex().size_full().min_h(0).bg(t.chrome).px(10).pt(0).gap(10)
      .overflow_y_scrollbar().mode("always")
      .children(spaces().map((space) =>
        v_flex().id(`space-${space.id}`).gap(5).flex_none()
          .when(!space.active, (el) => el.child(div().h(25).px(10).flex().items_center().text_size(13).font_semibold()
            .text_color(t.muted).truncate().on_click(() => run("space.select", { id: space.id })).child(space.name)))
          .children((space.tabs ?? []).map((tab) => {
            const tabPanes = allPanes.filter((pane) => pane.tab === tab.id);
            const current = tabPanes.find((pane) => pane.focused) ?? tabPanes[0];
            return h_flex().id(`tab-${tab.id}`).h(30).px(8).rounded(8).flex_none().items_center()
              .gap(7).text_size(12.5).truncate()
              .bg(tab.active ? t.selected : t.chrome)
              .text_color(tab.active ? t.foreground : t.muted)
              .hover((s) => s.bg(t.hover).text_color(t.foreground))
              .on_click(() => {
                if (!space.active) run("space.select", { id: space.id });
                run("tab.select", { id: tab.id });
                if (current) run("pane.focus", { pane: current.pane });
              })
              .child(paneIndicator(tabPanes, current, t))
              .child(div().min_w(0).truncate().child(paneLabel(tab, current)));
          })),
      ));
  }
}
