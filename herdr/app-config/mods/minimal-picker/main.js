import { View, div, svg, image } from "gpui-kit";
import { v_flex, h_flex, InputState, Input, v_virtual_list, Scrollbar, VirtualListScrollHandle } from "gpui-base";
import { agents, spaces, panes, machines, home, run, theme, props, closeOverlay, settings } from "herdr";
import { sessionLabel } from "./session-label.js";
import { revealTarget } from "./navigation.js";

function folder(cwd) {
  const h = home();
  return cwd === h ? "~" : cwd?.startsWith(h + "/") ? "~" + cwd.slice(h.length) : cwd ?? "";
}

function programIcon(program, color) {
  if (!program?.icon) return svg("mods/workspace-chrome/terminal.svg").size(18).flex_none().text_color(color);
  return program.tint
    ? svg(program.icon).size(18).flex_none().text_color(color)
    : image(program.icon).w(18).h(18).flex_none();
}

const pickable = row => ["ctx", "new", "space"].includes(row.kind);
const rowKey = row => row.kind === "machine" ? `machine-${row.machine ?? "local"}` : row.kind === "head" ? `head-${row.w.id}`
  : row.kind === "ctx" ? `ctx-${row.current?.pane ?? row.ctx.id}`
  : row.kind === "space" ? `space-${row.machine ?? "local"}` : "new";
const rowHeight = row => row.kind === "machine" ? 32 : row.kind === "head" ? 24 : row.kind === "ctx" ? row.label.isAgent ? 44 : 56 : 36;

export default class Picker extends View {
  init(_props, cx) {
    this.filter = "";
    this.at = null;
    this.selectedKey = null;
    this.revealPending = true;
    this.scrollOffset = null;
    this.scrollHandle = VirtualListScrollHandle.new();
    this.input = InputState.new({ placeholder: "Search sessions…" });
    this.input.on("change", (_event, cx) => {
      this.filter = this.input.value();
      this.at = 0;
      this.selectedKey = null;
      this.scrollOffset = null;
      this.revealPending = true;
      this.pendingReveal?.cancel();
      cx.notify();
    });
    this.input.on("submit", () => this.go(this.rows().find(row => rowKey(row) === this.selectedKey)));
    cx.timer.after(0, () => this.input.focus());
    this.handle = cx.focus_handle();
  }

  dismiss() {
    closeOverlay(props().overlay);
  }

  close() {
    this.pendingReveal?.cancel();
    this.scrollHandle?.release();
  }

  manualScroll() {
    this.pendingReveal?.cancel();
    this.pendingReveal = null;
    this.revealPending = false;
    this.scrollOffset = null;
  }

  rows() {
    const query = this.filter.toLowerCase();
    const all = agents();
    const allPanes = panes();
    const groups = spaces().map(w => {
      const ctxs = w.tabs.flatMap(ctx => {
        const items = allPanes.filter(pane => pane.tab === ctx.id);
        return (items.length ? items : [null]).map((current, index) => {
          const agent = all.find(agent => current && (agent.pane === current.pane || agent.address === current.terminal));
          return { w, ctx, current, index, count: items.length, agent,
            label: sessionLabel(ctx, current, agent, folder), status: current?.status ?? agent?.status ?? null };
        });
      }).filter(row => !query || [w.name, row.ctx.name, row.label.name, row.current?.cwd, folder(row.current?.cwd),
        w.machine ?? "local", row.current?.title, row.current?.branch, row.current?.program?.name, row.agent?.title, row.agent?.program?.name]
        .join(" ").toLowerCase().includes(query));
      return { w, ctxs };
    });
    const rows = [];
    let previousMachine;
    for (const group of groups.filter(group => group.ctxs.length)) {
      const machine = group.w.machine ?? null;
      if (machine !== previousMachine) rows.push({ kind: "machine", machine });
      previousMachine = machine;
      rows.push({ kind: "head", w: group.w });
      rows.push(...group.ctxs.map(row => ({ kind: "ctx", ...row })));
    }
    rows.push({ kind: "new" }, { kind: "space", machine: null });
    rows.push(...machines().filter(machine => machine.name && machine.layout === "ready").map(machine => ({ kind: "space", machine: machine.name })));
    return rows;
  }

  go(row) {
    if (!row || !pickable(row)) return;
    this.dismiss();
    if (row.kind === "ctx") {
      if (!row.w.active) run("space.select", { id: row.w.id });
      run("tab.select", { id: row.ctx.id });
      if (row.current) run("pane.focus", { pane: row.current.pane });
    } else if (row.kind === "new") run("tab.new");
    else run("space.new", { machine: row.machine ?? "" });
  }

  glyph(t, status) {
    if (status === "working") return svg("mods/workspace-chrome/spinner.svg").size(12).flex_none().text_color(t.working).spin(900);
    return div().w(12).flex_none().text_color(t[status] ?? t.dim).child("●");
  }

  row(row, selected, t) {
    if (row.kind === "machine") return h_flex().h(32).px(12).gap(8).items_center()
      .text_color(row.machine ? t.ansi6 : t.ansi4)
      .child(svg(`mods/workspace-chrome/${row.machine ? "server" : "monitor"}.svg`).size(15).flex_none())
      .child(div().text_size(12).font_semibold().child(row.machine || "This Mac"));
    if (row.kind === "head") return h_flex().h(24).pl(42).pr(24).items_center()
      .child(div().min_w(0).truncate().text_size(12).font_semibold().text_color(t.muted).child(row.w.name));
    const on = rowKey(row) === selected;
    if (row.kind !== "ctx") return h_flex().h(36).px(12).pr(24).gap(8).items_center().text_color(t.muted)
      .cursor_pointer().rounded(4).when(on, el => el.bg(t.selected))
      .child(div().w(18).child("+"))
      .child(row.kind === "new" ? "new tab" : row.machine ? `new space on ${row.machine}` : "new space");
    const pane = row.current;
    const program = pane?.program ?? row.agent?.program;
    const label = row.label;
    return h_flex().h(rowHeight(row)).px(12).pr(24).gap(12).items_center()
      .rounded(4).cursor_pointer().when(on, el => el.bg(t.selected))
      .child(programIcon(program, t.muted))
      .child(v_flex().flex_1().min_w(0).gap(3)
        .child(h_flex().min_w(0).gap(8).items_center()
          .child(div().min_w(0).truncate().font_medium().text_color(t.foreground).child(label.name))
          .when(row.count > 1, el => el.child(div().flex_none().text_size(10.5).text_color(t.dim).child(`· ${row.index + 1}`)))
          .when(["working", "blocked", "done"].includes(row.status), el => el.child(this.glyph(t, row.status))))
        .when(Boolean(label.detail), el => el.child(h_flex().min_w(0).gap(10).text_size(13).items_center()
          .child(div().min_w(0).truncate().text_color(t.ansi4).child(label.detail))
          .when(Boolean(pane?.branch), el => el.child(h_flex().min_w(0).gap(5).items_center().text_color(t.ansi5)
            .child(svg("mods/workspace-chrome/git-branch.svg").size(14).flex_none())
            .child(div().min_w(0).truncate().child(pane.branch)))))));
  }

  render(cx) {
    const t = theme();
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
    const total = sizes.reduce((sum, height) => sum + height, 0);
    const height = Math.min(total, Math.max(120, Math.min(520, window.viewport_size().height * 0.72 / (Number(settings().zoom) || 1) - 70)));
    if (this.revealPending) {
      this.revealPending = false;
      const target = revealTarget(sizes, rows.indexOf(selected), height, this.scrollOffset);
      if (target) {
        this.scrollOffset = target.offset;
        this.pendingReveal?.cancel();
        this.pendingReveal = cx.timer.after(0, () => {
          this.pendingReveal = null;
          this.scrollHandle.scroll_to_item(target.index, "top");
        });
      }
    }

    return v_flex().id("picker").track_focus(this.handle).w_full().h(height + 70).min_h(0)
      .px(10).pt(6).pb(10).gap(8).border_1().border_color(t.border).rounded(8).bg(t.popover).text_size(14.5).line_height(1.25)
      .on_key_down((event, cx) => {
        if (event.key === "escape") return this.dismiss();
        if (event.key === "down") this.at = Math.min(this.at + 1, choices.length - 1);
        else if (event.key === "up") this.at = Math.max(0, this.at - 1);
        else if (event.key === "pagedown") this.at = Math.min(this.at + Math.max(1, Math.floor(height / 48)), choices.length - 1);
        else if (event.key === "pageup") this.at = Math.max(0, this.at - Math.max(1, Math.floor(height / 48)));
        else if (event.key === "d" && event.modifiers.control) {
          if (selected.kind === "ctx") {
            this.dismiss();
            if (selected.current) run("pane.close", { pane: selected.current.pane });
            else run("tab.close", { id: selected.ctx.id });
          }
        } else return;
        this.selectedKey = rowKey(choices[this.at]);
        this.revealPending = true;
        this.pendingReveal?.cancel();
        this.pendingReveal = null;
        cx.stop_propagation();
        cx.notify();
      })
      .child(h_flex().h(40).flex_none().px(10).gap(8).items_center().border_b(1).border_color(t.border).bg(t.popover)
        .child(svg("mods/workspace-chrome/search.svg").size(15).text_color(t.dim))
        .child(Input.new(this.input).flex_1().h_full().text_size(15).text_color(t.foreground)))
      .child(v_flex().relative().h(height).flex_none().mb(6)
        .on_scroll_wheel(() => this.manualScroll())
        .on_mouse_down("left", () => this.manualScroll())
        .child(v_virtual_list("pk-list", rows.length, sizes, index => rowKey(rows[index]),
          range => rows.slice(range.start, range.end).map(row => this.row(row, selectedKey, t)))
          .size_full().track_scroll(this.scrollHandle)
          .on_item_click(key => this.go(this.rows().find(row => rowKey(row) === key))))
        .when(total > height, el => el.child(Scrollbar.vertical("pk-list").absolute().inset_0().mode("always"))));
  }
}
