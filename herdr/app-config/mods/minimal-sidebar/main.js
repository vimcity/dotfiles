import { View, div, image, svg } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { home, nextCommand, panes, run, spaces, theme } from "herdr";

function spaceStatus(status, t) {
  if (status === "working") return svg("mods/workspace-chrome/spinner.svg")
    .size(12).flex_none().text_color(t.working).spin(900);
  if (status === "blocked") return div().w(12).flex_none().text_center()
    .text_size(12).text_color(t.blocked).child("!");
  if (status === "done") return div().w(12).flex_none().text_size(11)
    .text_color(t.done).child("✓").tooltip("Done");
  return div().w(12).flex_none();
}

function paneLabel(tab, pane) {
  return {
    name: tab.named ? tab.name : pane?.program?.name ?? pane?.title ?? "Terminal",
    cwd: pane?.cwd?.replace(`${home()}/`, "~/"),
  };
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
  init(_props, cx) {
    cx.spawn(async (cx) => {
      for (;;) {
        const command = await nextCommand();
        if (command === "next" || command === "prev") this.navigate(command === "next" ? 1 : -1);
        cx.notify();
      }
    });
  }

  navigate(direction) {
    const items = spaces().flatMap((space) => (space.tabs ?? []).map((tab) => ({ space, tab })));
    if (!items.length) return;
    const current = items.findIndex(({ space, tab }) => space.active && tab.active);
    const next = items[(current + direction + items.length) % items.length];
    if (!next.space.active) run("space.select", { id: next.space.id });
    if (!next.tab.active) run("tab.select", { id: next.tab.id });
  }

  render() {
    const t = theme();
    const allPanes = panes();
    const items = spaces();
    return v_flex().size_full().min_h(0).bg(t.chrome).px(10).pt(0).gap(4)
      .overflow_y_scrollbar().mode("always")
      .children(items.map((space) =>
        v_flex().id(`space-${space.id}`).gap(2).pb(4).flex_none()
          .child(h_flex().id(`space-heading-${space.id}`).h(28).px(8).gap(7).items_center()
            .on_click(() => run("space.select", { id: space.id }))
            .child(div().flex_1().min_w(0).text_size(13).font_semibold().text_color(space.active ? "#8CAAEE" : t.muted).truncate().child(space.name))
            .when(space.status && space.status !== "idle", el => el.child(spaceStatus(space.status, t))))
          .child(v_flex().ml(4).gap(2)
          .children((space.tabs ?? []).map((tab) => {
            const tabPanes = allPanes.filter((pane) => pane.tab === tab.id);
            const current = tabPanes.find((pane) => pane.focused) ?? tabPanes[0];
            const label = paneLabel(tab, current);
            return h_flex().id(`tab-${tab.id}`).h(28).px(4).flex_none().items_center()
              .gap(1).text_size(12.5).truncate()
              .when(space.active && tab.active, el => el.bg(t.selected))
              .text_color(space.active && tab.active ? t.foreground : t.muted)
              .on_click(() => {
                if (!space.active) run("space.select", { id: space.id });
                run("tab.select", { id: tab.id });
                if (current) run("pane.focus", { pane: current.pane });
              })
              .child(paneIndicator(tabPanes, current, t))
              .child(h_flex().min_w(0).gap(6)
                .child(div().flex_none().truncate().font_family("Geist").font_semibold().text_color(t.ansi5).child(label.name))
                .when(Boolean(label.cwd), el => el.child(div().min_w(0).truncate().font_family("Geist Mono").text_color(t.muted).child(label.cwd))));
          }))),
      ));
  }
}
