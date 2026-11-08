import { View, div, svg } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { agents, home, machines, nextCommand, panes, run, settings, shared, spaces, theme } from "herdr";
import { sessionLabel } from "./session-label.js";
import { fadedLabel, programIcon, sidebarButton } from "./ui.js";
import { navigateSidebar } from "./sidebar-navigation.js";
import { SidebarPresence, SIDEBAR_HEIGHT, SIDEBAR_FADE } from "./sidebar-motion.js";

function shortPath(cwd) {
  const path = cwd?.replace(`${home()}/`, "~/") ?? "";
  const parts = path.split("/");
  return parts.length > 3 ? `…/${parts.slice(-2).join("/")}` : path;
}

function statusMark(status, t) {
  const color = { working: t.working, blocked: t.blocked, done: t.done }[status];
  return div().size(6).flex_none().rounded(3).when(Boolean(color), el => el.bg(color).tooltip(status));
}

function machineMetrics(t) {
  const usage = shared("minimal.machine-usage.local");
  const metric = (icon, value) => h_flex().id(`machine-metric-${icon}`).flex_none().gap(4).items_center().text_color(t.muted)
    .child(svg(`mods/minimal-metrics/${icon}.svg`).size(12).flex_none())
    .child(value == null ? "—" : `${value}%`);
  return h_flex().gap(8).items_center().flex_none().text_size(12).font_semibold()
    .child(metric("cpu", usage?.cpu)).child(metric("memory", usage?.memory));
}

export default class MinimalSidebar extends View {
  init(_props, cx) {
    this.presence = new SidebarPresence();
    this.expanded = new Set();
    this.activeSpace = null;
    this.width = 275;
    this.hoveredTab = null;
    cx.spawn(async (cx) => {
      for (;;) {
        const command = await nextCommand();
        if (command === "next" || command === "prev") this.navigate(command === "next" ? 1 : -1);
        cx.notify();
      }
    });
  }

  navigate(direction) {
    navigateSidebar(direction, spaces(), run);
  }

  select(space, tab, pane) {
    if (!space.active) run("space.select", { id: space.id });
    if (tab) run("tab.select", { id: tab.id });
    if (pane) run("pane.focus", { pane: pane.pane });
  }

  tabRow(space, entry, t, ready) {
    const { tab, current, label, count } = entry.value;
    const open = entry.phase === "open";
    const selected = space.active && tab.active;
    const fill = selected ? t.selected : this.hoveredTab === tab.id ? t.hover : t.chrome;
    return v_flex().id(`tab-slot-${tab.id}`).h(open ? 39 : 0).min_h(0).flex_none().overflow_hidden()
      .opacity(open ? 1 : 0).transition("height", SIDEBAR_HEIGHT).transition("opacity", SIDEBAR_FADE)
      .child(h_flex().id(`tab-${tab.id}`).relative().w_full().h(36).px(7).gap(9).flex_none().items_center()
        .rounded(18).bg(fill).border(0.5).border_color(selected ? "#ffffff0b" : fill).cursor_pointer()
        .text_size(14).font_medium().text_color(selected ? t.foreground : t.muted)
        .on_hover((hovered, cx) => {
          if (!open && hovered) return;
          this.hoveredTab = hovered ? tab.id : this.hoveredTab === tab.id ? null : this.hoveredTab;
          cx.notify();
        })
        .tooltip([space.machine || "This Mac", space.name, label.name, current?.cwd].filter(Boolean).join(" · "))
        .on_click(() => { if (open && ready) this.select(space, tab, current); })
        .child(programIcon(current?.program, selected ? t.foreground : t.muted, 15))
        .child(fadedLabel(label.name, fill).when(selected, el => el.font_semibold()))
        .when(count > 1, el => el.child(div().text_size(11).font_medium().text_color(t.dim).tooltip(`${count} panes`).child(String(count))))
        .child(statusMark(tab.status, t)));
  }

  render(cx) {
    const t = theme();
    const zoom = Number(settings().zoom) || 1;
    const allPanes = panes();
    const panesByTab = new Map();
    for (const pane of allPanes) {
      if (!panesByTab.has(pane.tab)) panesByTab.set(pane.tab, []);
      panesByTab.get(pane.tab).push(pane);
    }
    const allAgents = new Map(agents().map(agent => [agent.address, agent]));
    const machineList = machines();
    const items = spaces();
    const activeSpace = items.find(space => space.active)?.id;
    const compact = this.width < 110;
    if (activeSpace !== this.activeSpace) {
      this.activeSpace = activeSpace;
      this.expanded = new Set(activeSpace ? [activeSpace] : []);
    }
    const groups = this.presence.sync(items.map(space => ({ id: space.id, value: space,
      rows: (space.tabs ?? []).map(tab => {
        const tabPanes = (panesByTab.get(tab.id) ?? []);
        const current = tabPanes.find(pane => pane.focused) ?? tabPanes.find(pane => pane.program?.agent) ?? tabPanes[0];
        return { id: tab.id, value: { tab, current, count: tabPanes.length,
          label: sessionLabel(tab, current, allAgents.get(current?.terminal), shortPath) } };
      }),
    })), cx);
    const content = [];
    const spacer = (id, height) => div().id(id).h(height).flex_none().transition("height", SIDEBAR_HEIGHT);
    groups.forEach((group, index) => {
      const space = group.value;
      const ready = group.phase === "open";
      const expanded = ready && this.expanded.has(space.id) && !compact;
      const rows = this.presence.rows(group);
      if (index === 0 || groups[index - 1].value.machine !== space.machine) {
        const machine = machineList.find(item => item.name === space.machine);
        const machineName = space.machine ? space.machine[0].toUpperCase() + space.machine.slice(1) : "This Mac";
        const key = space.machine || "local";
        const visible = groups.some(item => item.value.machine === space.machine && item.phase === "open");
        const top = index ? 12 : 0;
        content.push(div().id(`machine-slot-${key}`).h(visible ? 30 + top : 0).min_h(0).flex_none().overflow_hidden()
          .opacity(visible ? 1 : 0).transition("height", SIDEBAR_HEIGHT).transition("opacity", SIDEBAR_FADE)
          .child(h_flex().id(`machine-${key}`).relative().top(top).w_full().h(28).px(7).gap(7).items_center()
            .transition("top", SIDEBAR_HEIGHT)
            .text_size(12).font_medium().text_color(t.dim).tooltip(`${machineName}${machine?.layout && machine.layout !== "ready" ? ` · ${machine.layout}` : ""}`)
            .child(svg(`mods/workspace-chrome/${space.machine ? "server" : "monitor"}.svg`).size(13).flex_none())
            .when(!compact, el => el.child(fadedLabel(machineName, t.chrome)))
            .when(!space.machine && !compact, el => el.child(machineMetrics(t)))
            .when(Boolean(machine && machine.layout !== "ready"), el => el.child(statusMark("blocked", t)))));
        content.push(spacer(`machine-gap-${key}`, visible ? 3 : 0));
      }
      content.push(v_flex().id(`space-${space.id}`).flex_none().min_h(0)
        .child(h_flex().id(`space-heading-${space.id}`).h(ready ? 32 : 0).min_h(0).overflow_hidden().flex_none().px(7).gap(7).items_center().rounded(7).cursor_pointer()
          .opacity(ready ? 1 : 0).transition("height", SIDEBAR_HEIGHT).transition("opacity", SIDEBAR_FADE)
          .text_color(t.muted).hover(el => el.text_color(t.foreground))
          .when(compact && space.active, el => el.bg(t.selected).rounded(16))
          .tooltip(`${space.name} · ${space.tabs?.length ?? 0} sessions`)
          .on_click((_event, cx) => {
            if (!ready) return;
            if (compact) this.select(space, space.tabs?.find(tab => tab.active) ?? space.tabs?.[0]);
            else this.expanded.has(space.id) ? this.expanded.delete(space.id) : this.expanded.add(space.id);
            cx.notify();
          })
          .when(compact, el => el.justify_center().child(div().text_size(14).font_family("Helvetica Neue").font_bold().text_color("#7F86A1").child(space.name.slice(0, 2))))
          .when(!compact, el => el
            .child(svg(`mods/minimal-sidebar/chevron-${expanded ? "down" : "right"}.svg`).size(10).flex_none().text_color(t.dim))
            .child(fadedLabel(space.name, t.chrome, true).id(`space-name-${space.id}`).text_size(13).font_family("Helvetica Neue").font_weight(700).text_color("#7F86A1"))
            .child(div().text_size(11).font_medium().text_color(t.dim).child(String(space.tabs?.length ?? 0))))
          .child(statusMark(expanded ? null : space.status, t)))
        .child(spacer(`heading-gap-${space.id}`, ready ? 3 : 0))
        .child(v_flex().id(`space-tabs-${space.id}`).overflow_hidden().min_h(0).flex_none()
          .h(expanded ? rows.filter(row => row.phase === "open").length * 39 : 0).opacity(expanded ? 1 : 0)
          .transition("height", SIDEBAR_HEIGHT).transition("opacity", SIDEBAR_FADE)
          .children(rows.map(row => this.tabRow(space, row, t, ready))))
        .child(spacer(`space-gap-${space.id}`, ready ? index === groups.length - 1 ? 6 : 12 : 0)));
    });
    return v_flex().id("sidebar-list").relative().size_full().min_h(0).bg(t.chrome).pl(12).pr(4).pt(34)
      .on_size_change((size, cx) => {
        if (this.width !== size.width) { this.width = size.width; cx.notify(); }
      })
      .overflow_y_scrollbar()
      .when(!compact, el => el.child(sidebarButton(t, zoom, () => run("layout.toggle", { id: "sidebar" }))
        .absolute().left(84 / zoom).top(5 / zoom)))
      .children(content);
  }
}
