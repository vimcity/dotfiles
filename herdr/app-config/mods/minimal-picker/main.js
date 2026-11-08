import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, InputState } from "gpui-base";
import { agents, spaces, panes, machines, home, run, theme, props, closeOverlay, settings, nextCommand } from "herdr";
import { sessionLabel } from "./session-label.js";
import { rowLayout, revealOffset, pageIndex } from "./navigation.js";
import { fadedLabel, programIcon } from "./ui.js";
import { MENU_CHROME, MenuMotion, menuFrame, menuSearch, menuScrollbar } from "./menu-ui.js";

function folder(cwd) {
  const h = home();
  return cwd === h ? "~" : cwd?.startsWith(h + "/") ? "~" + cwd.slice(h.length) : cwd ?? "";
}

function machineColor(machine, t) {
  if (!machine) return "#8caaee";
  const remotes = machines().filter(item => item.name && !item.temporary).map(item => item.name).sort();
  const palette = ["#ca9ee6", t.ansi5];
  return palette[Math.max(0, remotes.indexOf(machine)) % palette.length];
}

const FILTERS = [
  { status: "all", label: "All", key: ":a" },
  { status: "blocked", label: "Waiting", key: ":w" },
  { status: "done", label: "Done", key: ":d" },
  { status: "working", label: "Running", key: ":r" },
  { status: "idle", label: "Idle", key: ":i" },
];
const STATUS_ALIASES = {
  a: "all", all: "all", w: "blocked", b: "blocked", waiting: "blocked", blocked: "blocked",
  d: "done", done: "done", r: "working", running: "working", working: "working", i: "idle", idle: "idle",
};

const pickable = row => ["ctx", "new", "space"].includes(row.kind);
const rowKey = row => !row ? null : row.kind === "machine" ? `machine-${row.machine ?? "local"}` : row.kind === "head" ? `head-${row.w.id}`
  : row.kind === "tab" ? `tab-head-${row.ctx.id}`
  : row.kind === "ctx" ? `ctx-${row.current?.pane ?? row.ctx.id}`
  : row.kind === "space" ? `space-${row.machine ?? "local"}` : "new";
const rowHeight = row => row.kind === "machine" ? 32 : row.kind === "head" ? 32 : row.kind === "ctx" ? row.label.isAgent ? 38 : 50 : row.kind === "tab" ? 28 : 36;

export default class Picker extends View {
  init(_props, cx) {
    this.motion = new MenuMotion();
    this.motion.start(cx);
    this.filter = "";
    this.statusFilter = "all";
    this.at = null;
    this.selectedKey = null;
    this.revealPending = true;
    this.scroll = null;
    this.input = InputState.new({ placeholder: "Search sessions…" });
    this.input.on("change", (_event, cx) => {
      this.filter = this.input.value();
      this.at = 0;
      this.selectedKey = null;
      this.scroll = null;
      this.revealPending = true;
      cx.notify();
    });
    this.input.on("submit", (_event, cx) => this.go(this.rows().find(row => rowKey(row) === this.selectedKey), cx));
    cx.timer.after(0, () => this.input.focus());
    this.handle = cx.focus_handle();
    cx.spawn(async cx => {
      for (;;) this.navigate(await nextCommand(), cx);
    });
  }

  dismiss(cx, after) {
    const done = () => { closeOverlay(props().overlay); after?.(); };
    if (this.motion && cx) this.motion.dismiss(cx, done);
    else done();
  }

  setScroll(offset, cx) {
    this.scroll = Math.max(0, Math.min(offset, this.maxScroll ?? 0));
    this.revealPending = false;
    cx.notify();
  }

  filterQuery() {
    const text = (this.filter ?? "").trim();
    const [first] = text.split(/\s+/);
    const token = first.toLowerCase();
    const alias = STATUS_ALIASES[token.replace(/^:/, "")];
    const isStatus = alias && (token.startsWith(":") || token.length > 1);
    return { status: isStatus ? alias : this.statusFilter ?? "all", query: isStatus ? text.slice(first.length).trim() : text };
  }

  setStatus(status, cx) {
    const { query } = this.filterQuery();
    this.statusFilter = status;
    this.filter = query;
    this.input.set_value(query);
    this.at = 0;
    this.selectedKey = null;
    this.scroll = 0;
    this.revealPending = true;
    this.input.focus();
    cx.notify();
  }

  rows() {
    const { query: text, status } = this.filterQuery();
    const query = text.toLowerCase();
    const all = agents();
    const agentsByPane = new Map(all.filter(agent => agent.pane).map(agent => [agent.pane, agent]));
    const agentsByAddress = new Map(all.map(agent => [agent.address, agent]));
    const allPanes = panes();
    const panesByTab = new Map();
    for (const pane of allPanes) {
      if (!panesByTab.has(pane.tab)) panesByTab.set(pane.tab, []);
      panesByTab.get(pane.tab).push(pane);
    }
    const groups = spaces().map(w => {
      const ctxs = w.tabs.flatMap(ctx => {
        const items = (panesByTab.get(ctx.id) ?? []);
        return (items.length ? items : [null]).map((current, index) => {
          const agent = current && (agentsByPane.get(current.pane) ?? agentsByAddress.get(current.terminal));
          return { w, ctx, current, index, count: items.length, agent,
            tabTitle: ctx.named ? ctx.name : folder(items[0]?.cwd) || ctx.name || "—",
            label: sessionLabel(ctx, current, agent, folder), status: current?.status ?? agent?.status ?? null };
        });
      }).filter(row => (status === "all" || row.status === status) && (!query || [w.name, row.ctx.name, row.label.name, row.current?.cwd, folder(row.current?.cwd),
        w.machine ?? "local", row.current?.title, row.current?.branch, row.current?.program?.name, row.agent?.title, row.agent?.program?.name]
        .join(" ").toLowerCase().includes(query)));
      return { w, ctxs };
    });
    const rows = [];
    let previousMachine;
    for (const group of groups.filter(group => group.ctxs.length)) {
      const machine = group.w.machine ?? null;
      if (machine !== previousMachine) rows.push({ kind: "machine", machine });
      previousMachine = machine;
      rows.push({ kind: "head", w: group.w, agents: all.filter(agent => agent.space === group.w.id) });
      const tabs = [...new Set(group.ctxs.map(row => row.ctx.id))];
      for (const [tabIndex, tab] of tabs.entries()) {
        const members = group.ctxs.filter(row => row.ctx.id === tab);
        const lastTab = tabIndex === tabs.length - 1;
        if (members[0].count > 1) rows.push({ kind: "tab", ...members[0], lastTab });
        rows.push(...members.map((row, index) => ({ kind: "ctx", ...row, lastTab, lastPane: index === members.length - 1 })));
      }
    }
    if (status === "all") {
      rows.push({ kind: "new" }, { kind: "space", machine: null });
      rows.push(...machines().filter(machine => machine.name && machine.layout === "ready").map(machine => ({ kind: "space", machine: machine.name })));
    }
    if (!rows.length) rows.push({ kind: "empty", status });
    return rows;
  }

  go(row, cx) {
    if (!row || !pickable(row)) return;
    this.dismiss(cx, () => {
      if (row.kind === "ctx") {
        if (!row.w.active) run("space.select", { id: row.w.id });
        run("tab.select", { id: row.ctx.id });
        if (row.current) {
          const zoomed = panes().find(pane => pane.tab === row.ctx.id && pane.zoomed);
          const transferZoom = zoomed && zoomed.pane !== row.current.pane;
          if (transferZoom) run("pane.zoom", { pane: zoomed.pane });
          run("pane.focus", { pane: row.current.pane });
          if (transferZoom) run("pane.zoom", { pane: row.current.pane });
        }
      } else if (row.kind === "new") run("tab.new");
      else run("space.new", { machine: row.machine ?? "" });
    });
  }

  navigate(command, cx) {
    if (command === "zoom") {
      this.revealPending = true;
      this.motion.toggleZoom(cx);
      return;
    }
    const rows = this.rows();
    const choices = rows.filter(pickable);
    const current = choices.findIndex(row => rowKey(row) === this.selectedKey);
    this.at = Math.max(0, current >= 0 ? current : this.at ?? 0);
    const selected = choices[this.at];
    if (command === "escape") return this.dismiss(cx);
    if (!choices.length) return;
    if (command === "down") this.at = Math.min(this.at + 1, choices.length - 1);
    else if (command === "up") this.at = Math.max(0, this.at - 1);
    else if (command === "pagedown" || command === "pageup") {
      const selectable = rows.flatMap((row, index) => pickable(row) ? [index] : []);
      this.at = pageIndex(rows.map(rowHeight), selectable, this.at, this.listHeight ?? 400, command === "pagedown" ? 1 : -1);
    } else if (command === "home") this.at = 0;
    else if (command === "end") this.at = choices.length - 1;
    else if (command === "close-pane") {
      if (selected.kind === "ctx") {
        this.dismiss(cx, () => {
          if (selected.current) run("pane.close", { pane: selected.current.pane });
          else run("tab.close", { id: selected.ctx.id });
        });
      }
      return;
    } else return;
    this.selectedKey = rowKey(choices[this.at]);
    if (this.at === 0) this.scroll = 0;
    this.revealPending = true;
    cx.notify();
  }

  glyph(t, status) {
    const colors = { working: t.ansi2, blocked: t.ansi1, done: t.ansi3, idle: t.dim };
    return div().size(7).flex_none().flex().items_center().justify_center().tooltip(status)
      .child(div().size(status === "idle" ? 3 : 7).rounded(4).bg(colors[status] ?? t.dim));
  }

  row(row, selected, t) {
    if (row.kind === "empty") return h_flex().h(36).px(10).items_center().text_color(t.dim).child("No matching sessions");
    if (row.kind === "machine") {
      const name = row.machine ? row.machine[0].toUpperCase() + row.machine.slice(1) : "This Mac";
      return h_flex().id(rowKey(row)).h(32).px(10).gap(7).items_center()
        .text_color(machineColor(row.machine, t)).text_size(12).font_medium()
        .child(svg(`mods/workspace-chrome/${row.machine ? "server" : "monitor"}.svg`).size(13).flex_none())
        .child(fadedLabel(name, t.popover));
    }
    if (row.kind === "head") return h_flex().id(rowKey(row)).h(32).px(10).gap(8).items_center()
      .child(fadedLabel(row.w.name, t.popover, true).id(`space-name-${row.w.id}`).text_size(13).font_family("Helvetica Neue").font_weight(700).text_color("#7F86A1"))
      .child(div().text_size(11).font_medium().text_color(t.dim).child(String(row.w.tabs?.length ?? 0)));
    if (row.kind === "tab") return h_flex().h(28).pl(12).pr(10).gap(6).items_center().text_size(11).text_color(t.dim)
      .child(svg("mods/minimal-pane/split-right.svg").size(12).flex_none())
      .child(fadedLabel(row.tabTitle, t.popover));

    const on = rowKey(row) === selected;
    const fill = on ? t.selected : this.hoveredRow === rowKey(row) ? t.hover : t.popover;
    const item = h_flex().id(rowKey(row)).relative().h(rowHeight(row)).px(10).gap(9).items_center()
      .rounded(18).bg(fill).border(0.5).border_color(on ? "#ffffff14" : fill)
      .text_size(14).font_medium().text_color(t.foreground).cursor_pointer()
      .on_click((_event, cx) => this.go(row, cx))
      .on_hover((hovered, cx) => {
        if (hovered) this.hoveredRow = rowKey(row);
        else if (this.hoveredRow === rowKey(row)) this.hoveredRow = null;
        cx.notify();
      });
    if (row.kind !== "ctx") return item
      .child(div().w(16).text_color(machineColor(row.machine, t)).child("+"))
      .child(fadedLabel(row.kind === "new" ? "New tab" : row.machine ? `New space on ${row.machine}` : "New space", fill).text_color(t.muted));

    const pane = row.current;
    const program = pane?.program ?? row.agent?.program;
    const label = row.label;
    const content = v_flex().flex_1().min_w(0).gap(3)
      .child(fadedLabel(label.name, fill).when(on, el => el.font_semibold()));
    if (label.detail) content.child(fadedLabel(label.detail, fill).text_size(11).text_color(t.dim));
    const tool = program?.name || pane?.app || row.agent?.app;
    return item
      .when(row.count > 1, el => el.pl(24))
      .tooltip([row.w.machine || "This Mac", row.w.name, label.name, pane?.cwd, tool, row.status].filter(Boolean).join(" · "))
      .child(programIcon(program, t.ansi6, 16))
      .child(content)
      .child(this.glyph(t, row.status || "idle"));
  }

  render(cx) {
    const t = theme();
    const zoom = Number(settings().zoom) || 1;
    const viewport = window.viewport_size();
    const filterColors = { all: "#8caaee", blocked: t.ansi1, done: t.ansi3, working: t.ansi2, idle: t.muted };
    const rows = this.rows();
    const choices = rows.filter(pickable);
    if (this.selectedKey) {
      const index = choices.findIndex(row => rowKey(row) === this.selectedKey);
      if (index >= 0) this.at = index;
    }
    if (this.at === null) {
      const focused = choices.findIndex(row => row.current?.focused);
      const active = choices.findIndex(row => row.w?.active && row.ctx?.active);
      this.at = Math.max(0, focused >= 0 ? focused : active);
    }
    this.at = Math.max(0, Math.min(this.at, choices.length - 1));
    const selected = choices[this.at];
    const selectedKey = rowKey(selected);
    this.selectedKey = selectedKey;
    const sizes = rows.map(rowHeight);
    const { tops, total } = rowLayout(sizes);
    const height = this.motion?.heightLimit?.(viewport.height / zoom)
      ?? Math.min(total, Math.max(120, Math.min(700, viewport.height * 0.86 / zoom - MENU_CHROME)));
    this.listHeight = height;
    this.maxScroll = Math.max(0, total - height);
    if (this.revealPending) {
      this.revealPending = false;
      this.scroll = selected ? revealOffset(sizes, rows.indexOf(selected), height, this.scroll) : 0;
    }
    this.scroll = Math.max(0, Math.min(this.scroll ?? 0, this.maxScroll));
    const visibleRows = rows.flatMap((row, index) => tops[index] + sizes[index] > this.scroll && tops[index] < this.scroll + height
      ? [this.row(row, selectedKey, t).absolute().left(0).right(10).top(tops[index] - this.scroll)
        .bottom(height - (tops[index] + sizes[index] - this.scroll))] : []);

    const frame = menuFrame(t).id("picker").track_focus(this.handle).h(height + MENU_CHROME)
      .on_mouse_move((event, cx) => {
        if (this.drag) this.setScroll(this.drag.offset + (event.position.y - this.drag.y) * this.drag.factor, cx);
      })
      .on_mouse_up("left", () => { this.drag = null; })
      .on_hover(hovered => { if (!hovered) this.drag = null; })
      .on_key_down((event, cx) => {
        const command = event.key === "d" && event.modifiers.control ? "close-pane" : event.key;
        if (["up", "down", "pageup", "pagedown", "home", "end", "escape", "close-pane"].includes(command)) {
          cx.stop_propagation();
          this.navigate(command, cx);
        }
      })
      .child(menuSearch(this.input, "mods/workspace-chrome/search.svg", t))
      .child(h_flex().h(28).flex_none().px(2).gap(6).items_center()
        .children(FILTERS.map(filter => div().id(`filter-${filter.status}`).h(24).px(8).flex().items_center().rounded(12).cursor_pointer()
          .bg(this.filterQuery().status === filter.status ? filterColors[filter.status] + "18" : "#ffffff00")
          .text_size(11).font_medium().text_color(filterColors[filter.status])
          .opacity(this.filterQuery().status === filter.status ? 1 : 0.8)
          .when(this.filterQuery().status === filter.status, el => el.font_semibold())
          .tooltip(filter.status === "blocked" ? "Blocked / needs you · type :w or waiting" : `Type ${filter.key} or ${filter.label.toLowerCase()}`)
          .on_click((_event, cx) => this.setStatus(filter.status, cx))
          .child(filter.label))))
      .child(div().id("pk-viewport").relative().h(height).flex_none().overflow_hidden()
        .on_scroll_wheel((event, cx) => {
          cx.stop_propagation();
          const scale = height / (event.bounds?.height || height);
          this.setScroll(this.scroll - event.delta.y * scale, cx);
        })
        .children(visibleRows)
        .when(this.maxScroll > 0, el => el.child(menuScrollbar("pk-scrollbar", height, total, this.scroll, t,
          (offset, cx) => this.setScroll(offset, cx), drag => { this.drag = drag; }))));
    return this.motion ? this.motion.wrap(frame, "picker", cx => this.dismiss(cx), { ...viewport, zoom }) : frame;
  }
}
