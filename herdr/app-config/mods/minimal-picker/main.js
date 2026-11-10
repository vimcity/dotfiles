import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, InputState } from "gpui-base";
import { agents, spaces, panes, machines, home, run, theme, props, closeOverlay, settings, nextCommand } from "herdr";
import { sessionLabel } from "./session-label.js";
import { rowLayout, revealOffset, pageIndex } from "./navigation.js";
import { fadedLabel } from "./ui.js";
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

const pickable = row => row.kind === "ctx";
const rowKey = row => row ? `workspace-${row.w?.id ?? row.current?.pane ?? row.ctx.id}` : null;
const rowHeight = row => row.kind === "ctx" ? 52 : 36;

export default class Picker extends View {
  init(_props, cx) {
    this.motion = new MenuMotion();
    this.motion.start(cx);
    this.filter = "";
    this.at = null;
    this.selectedKey = null;
    this.revealPending = true;
    this.scroll = null;
    this.input = InputState.new({ placeholder: "Find a workspace or session…" });
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
    return { query: (this.filter ?? "").trim() };
  }

  rows() {
    const { query: text } = this.filterQuery();
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
    const rows = spaces().flatMap(w => {
      const sessions = w.tabs.flatMap(ctx => {
        const items = panesByTab.get(ctx.id) ?? [];
        return (items.length ? items : [null]).map(current => {
          const agent = current && (agentsByPane.get(current.pane) ?? agentsByAddress.get(current.terminal));
          return { w, ctx, current, agent,
            label: sessionLabel(ctx, current, agent, folder), status: current?.status ?? agent?.status ?? null };
        });
      });
      const matches = query ? sessions.filter(row => [row.ctx.name, row.label.name, row.current?.cwd, folder(row.current?.cwd),
        row.current?.title, row.current?.branch, row.current?.program?.name, row.agent?.title, row.agent?.program?.name]
        .join(" ").toLowerCase().includes(query)) : sessions;
      const workspaceMatch = query && [w.name, w.machine ?? "local"].join(" ").toLowerCase().includes(query);
      if (!matches.length && !workspaceMatch) return [];
      const active = sessions.find(row => row.ctx.active && row.current?.focused)
        ?? sessions.find(row => row.ctx.active)
        ?? sessions[0];
      const target = workspaceMatch ? active : matches.find(row => row.ctx.active && row.current?.focused)
        ?? matches.find(row => row.ctx.active)
        ?? matches[0];
      return target ? [{ ...target, kind: "ctx", match: query && !workspaceMatch ? target.label.name : "" }] : [];
    });
    if (!rows.length) rows.push({ kind: "empty" });
    return rows;
  }

  go(row, cx) {
    if (!row || !pickable(row)) return;
    this.dismiss(cx, () => {
      if (!row.w.active) run("space.select", { id: row.w.id });
      run("tab.select", { id: row.ctx.id });
      if (row.current) {
        const zoomed = panes().find(pane => pane.tab === row.ctx.id && pane.zoomed);
        const transferZoom = zoomed && zoomed.pane !== row.current.pane;
        if (transferZoom) run("pane.zoom", { pane: zoomed.pane });
        run("pane.focus", { pane: row.current.pane });
        if (transferZoom) run("pane.zoom", { pane: row.current.pane });
      }
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
    if (row.kind === "empty") return h_flex().h(36).px(10).items_center().text_color(t.dim).child("No matching workspaces");
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
    const machine = row.w.machine;
    const detail = row.match || (machine ? `On ${machine}` : "This Mac");
    return item
      .tooltip([row.w.name, detail, row.status].filter(Boolean).join(" · "))
      .child(svg(`mods/workspace-chrome/${machine ? "server" : "monitor"}.svg`).size(16).flex_none().text_color(machineColor(machine, t)))
      .child(v_flex().flex_1().min_w(0).gap(3)
        .child(fadedLabel(row.w.name, fill).when(on, el => el.font_semibold()))
        .child(fadedLabel(detail, fill).text_size(11).text_color(t.dim)))
      .child(this.glyph(t, row.status || "idle"));
  }

  render(cx) {
    const t = theme();
    const zoom = Number(settings().zoom) || 1;
    const viewport = window.viewport_size();
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
