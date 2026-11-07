import { View, div, image, svg } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { agents, home, nextCommand, panes, run, settings, spaces, theme } from "herdr";

import { sessionLabel } from "./session-label.js";

function spaceStatus(status, t) {
  if (status === "working") return svg("mods/workspace-chrome/spinner.svg")
    .size(12).flex_none().text_color(t.working).spin(900);
  if (status === "blocked") return div().w(12).flex_none().text_center()
    .text_size(12).text_color(t.blocked).child("!");
  if (status === "done") return div().w(12).flex_none().text_size(11)
    .text_color(t.done).child("✓").tooltip("Done");
  return div().w(12).flex_none();
}

function shortPath(cwd) {
  const path = cwd?.replace(`${home()}/`, "~/") ?? "";
  const parts = path.split("/");
  return parts.length > 3 ? `…/${parts.slice(-2).join("/")}` : path;
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
    const allAgents = new Map(agents().map(agent => [agent.address, agent]));
    const zoom = Number(settings().zoom) || 1;
    const items = spaces();
    return v_flex().size_full().min_h(0).bg(t.chrome).px(10).pt(0).gap(4)
      .overflow_y_scrollbar().mode("always")
      .children(items.map((space, index) =>
        v_flex().id(`space-${space.id}`).gap(2).pb(6).flex_none()
          .when(index === 0 || items[index - 1].machine !== space.machine, el => el.child(
            h_flex().h(28 / zoom).mt(index ? 12 : 0).px(8).gap(8).items_center()
              .text_color(space.machine ? t.ansi6 : t.ansi4)
              .child(svg(`mods/workspace-chrome/${space.machine ? "server" : "monitor"}.svg`).size(14).flex_none())
              .child(div().text_size(11.5).font_semibold().child(space.machine || "This Mac"))))
          .child(h_flex().id(`space-heading-${space.id}`).h(28 / zoom).px(8).gap(7).items_center().cursor_pointer()
            .tooltip(space.name)
            .on_click(() => run("space.select", { id: space.id }))
            .child(div().flex_1().min_w(0).text_size(12).font_semibold().text_color(t.muted).truncate().child(space.name))
            .when(space.status && space.status !== "idle", el => el.child(spaceStatus(space.status, t))))
          .child(v_flex().ml(4).gap(2)
          .children((space.tabs ?? []).map((tab) => {
            const tabPanes = allPanes.filter((pane) => pane.tab === tab.id);
            const current = tabPanes.find((pane) => pane.focused) ?? tabPanes.find(pane => pane.program?.agent) ?? tabPanes[0];
            const label = sessionLabel(tab, current, allAgents.get(current?.terminal), shortPath);
            return h_flex().id(`tab-${tab.id}`).h(28).px(4).flex_none().items_center()
              .gap(6).rounded(4).text_size(12).truncate()
              .tooltip([space.machine || "local", space.name, label.name, current?.cwd].filter(Boolean).join(" · "))
              .when(space.active && tab.active, el => el.bg(t.selected))
              .text_color(space.active && tab.active ? t.foreground : t.muted)
              .on_click(() => {
                if (!space.active) run("space.select", { id: space.id });
                run("tab.select", { id: tab.id });
                if (current) run("pane.focus", { pane: current.pane });
              })
              .child(paneIndicator(tabPanes, current, t))
              .child(h_flex().flex_1().min_w(0).gap(6)
                .child(div().min_w(0).when(label.isAgent, el => el.flex_1()).when(!label.isAgent, el => el.max_w(100)).truncate().font_family("Geist").font_medium().text_color(t.foreground).child(label.name))
                .when(Boolean(label.detail), el => el.child(div().flex_1().min_w(0).truncate().font_family("Geist Mono").text_color(t.muted).child(label.detail))));
          }))),
      ));
  }
}
