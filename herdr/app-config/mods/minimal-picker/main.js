import { View, div, svg, image } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { agents, spaces, panes, machines, home, run, theme, props, closeOverlay } from "herdr";

function folder(cwd) {
  const h = home();
  return cwd === h ? "~" : cwd?.startsWith(h + "/") ? "~" + cwd.slice(h.length) : cwd ?? "";
}

function programIcon(program, color) {
  if (!program?.icon) return svg("mods/workspace-chrome/terminal.svg").size(14).flex_none().text_color(color);
  return program.tint
    ? svg(program.icon).size(14).flex_none().text_color(color)
    : image(program.icon).w(14).h(14).flex_none();
}

export default class Picker extends View {
  init(_props, cx) {
    this.filter = "";
    this.input = InputState.new({ placeholder: "Go to a tab, space or agent…" });
    this.input.on("change", (_e, cx) => { this.filter = this.input.value(); this.at = 0; cx.notify(); });
    this.input.on("submit", () => this.go(this.rows().filter(r => r.kind === "ctx" || r.kind === "new" || r.kind === "space")[this.at]));
    this.input.focus();
    cx.timer.after(600, () => this.input.focus());
    this.at = null;
    this.scroll = 0;

    this.handle = cx.focus_handle();
  }

  close() {
    closeOverlay(props().overlay);
  }

  rows() {
    const f = this.filter.toLowerCase();
    const all = agents();
    const allPanes = panes();
    const groups = spaces().map((w) => {
      const ctxs = w.tabs.flatMap((ctx) => {
        const items = allPanes.filter((p) => p.tab === ctx.id);
        return (items.length ? items : [null]).map((current, index) => {
          const agent = all.find((a) => current && (a.pane === current.pane || a.address === current.terminal));
          return { w, ctx, current, index, count: items.length, agent, status: current?.status ?? agent?.status ?? null };
        });
      }).filter((r) => !f || [w.name, r.ctx.name, r.current?.cwd, folder(r.current?.cwd),
        r.current?.title, r.current?.branch, r.current?.program?.name, r.agent?.title, r.agent?.program?.name]
        .join(" ").toLowerCase().includes(f));
      return { w, ctxs };
    });
    const busy = groups.filter((p) => p.w.status && p.ctxs.length);
    const quiet = groups.filter((p) => !p.w.status && p.ctxs.length);
    busy.sort((a, b) => (b.w.status === "blocked") - (a.w.status === "blocked"));
    const out = [];
    const add = (p) => {
      out.push({ kind: "head", w: p.w });
      for (const c of p.ctxs) out.push({ kind: "ctx", ...c });
    };
    busy.forEach(add);
    quiet.forEach(add);
    out.push({ kind: "new" });
    out.push({ kind: "space", machine: null });
    for (const m of machines().filter((m) => m.name && m.layout === "ready")) out.push({ kind: "space", machine: m.name });
    return out;
  }

  go(r) {
    if (!r) return;
    this.close();
    if (r.kind === "ctx") {
      if (!r.w.active) run("space.select", { id: r.w.id });
      run("tab.select", { id: r.ctx.id });
      if (r.current) run("pane.focus", { pane: r.current.pane });
    }
    else if (r.kind === "new") run("tab.new");
    else if (r.kind === "space") run("space.new", { machine: r.machine ?? "" });
  }

  glyph(t, st) {
    if (st === "working") return svg("mods/workspace-chrome/spinner.svg").size(12).flex_none().text_color(t.working).spin(900);
    return div().w(12).flex_none().text_color(t[st] ?? t.dim).child(st === "idle" ? "○" : st ? "●" : "·");
  }

  render() {
    const t = theme();
    const rows = this.rows();
    const pickable = rows.filter((r) => r.kind === "ctx" || r.kind === "new" || r.kind === "space");
    // Opens on where you are.
    if (this.at === null) {
      const focused = pickable.findIndex((r) => r.kind === "ctx" && r.current?.focused);
      const active = pickable.findIndex((r) => r.kind === "ctx" && r.w.active && r.ctx.active);
      this.at = Math.max(0, focused >= 0 ? focused : active);
    }
    this.at = Math.min(this.at, pickable.length - 1);
    const sel = pickable[this.at];
    // One continuous strip: each row (and the group title before it) at a fixed
    // y. Scrolling moves the strip only as far as it takes to keep the selected
    // row in view, so the arrows can't run the selection off the list.
    const H = { head: 28, new: 30, ctx: 48, space: 30 };
    const tops = [];
    let y = 0;
    rows.forEach((r) => { tops.push(y); y += H[r.kind] ?? 32; });
    const total = y;
    const height = Math.min(320, this.listHeight ?? 320);
    const fixed = total > height;
    const maxScroll = Math.max(0, total - height);
    this.scroll = Math.max(0, Math.min(this.scroll, maxScroll));
    const si = rows.indexOf(sel);
    if (si >= 0) {
      if (tops[si] < this.scroll) this.scroll = tops[si];
      if (tops[si] + (H[sel.kind] ?? 32) > this.scroll + height) this.scroll = tops[si] + (H[sel.kind] ?? 32) - height;
    }
    const place = (el, i) =>
      fixed
        ? el.absolute().left(0).right(0).top(tops[i] - this.scroll).bottom(height - (tops[i] + (H[rows[i].kind] ?? 32) - this.scroll))
        : el;
    const visible = (i) => !fixed || (tops[i] + (H[rows[i].kind] ?? 32) > this.scroll && tops[i] < this.scroll + height);

    const row = (r) => {
      if (r.kind === "head") {
        return h_flex().h(28).flex_none().px(10).gap(8).items_center().text_size(10.5)
          .text_color(t.muted)
          .child(div().font_semibold().child(r.w.name))
          .when(Boolean(r.w.machine), el => el.child(div().text_color(t.dim).child(r.w.machine)));
      }
      const on = r === sel;
      if (r.kind === "new" || r.kind === "space") {
        const label = r.kind === "new" ? "new tab" : r.machine ? `new space on ${r.machine}` : "new space";
        return h_flex()
          .id(r.kind === "new" ? "pk-new" : `pk-space-${r.machine ?? "here"}`)
          .px(10)
          .h(30).flex_none()
          .items_center()
          .rounded(0)
          .gap(8)
          .text_color(t.muted)
          .cursor_pointer()
          .when(on, (el) => el.bg(t.hover))
          .hover((s) => s.bg(t.hover))
          .on_click(() => this.go(r))
          .child(div().w(12).child("+"))
          .child(label);
      }
      const p = r.current;
      const program = p?.program ?? r.agent?.program;
      const name = program?.name ?? p?.title ?? "Terminal";
      const title = (r.agent?.title || p?.title || "").replace(/^[^\p{L}\p{N}~/]+/u, "").trim();
      const session = program?.agent && title && title !== name && title.toLowerCase() !== p?.app
        && !/^[~/]/.test(title) ? title : "";
      const detail = folder(p?.cwd || r.w.folder);
      return h_flex().id(`pk-${p?.pane ?? r.ctx.id}`).h(48).flex_none().px(10).gap(10).items_center()
        .border_l(2).border_color(on ? t.accent : t.popover)
        .cursor_pointer().when(on, el => el.bg(t.selected)).hover(s => s.bg(t.hover))
        .on_click(() => this.go(r))
        .child(programIcon(program, t.muted))
        .child(v_flex().flex_1().min_w(0).gap(2)
          .child(h_flex().gap(8).items_center()
            .child(div().truncate().font_medium().text_color(t.foreground).child(name))
            .when(Boolean(session), el => el.child(div().min_w(0).truncate().text_color(t.muted).child(session)))
            .child(div().flex_none().text_size(10).text_color(t.dim).child(`tab ${r.ctx.name}${r.count > 1 ? ` · pane ${r.index + 1}` : ""}`))
            .when(p?.zoomed, el => el.child(div().text_size(10).text_color(t.accent).child("ZOOM"))))
          .child(h_flex().gap(10).text_size(11).items_center()
            .child(div().min_w(0).truncate().text_color(t.ansi4).child(detail))
            .when(Boolean(p?.branch), el => el.child(div().truncate().text_color(t.ansi5).child(`⑂ ${p.branch}`)))))
        .when(Boolean(r.status), el => el.child(this.glyph(t, r.status)))
        .when(Boolean(r.status), el => el.child(div().flex_none().text_size(10)
          .text_color(["working", "blocked", "done"].includes(r.status) ? t[r.status] : t.dim)
          .child(({ working: "working", blocked: "needs you", done: "finished", idle: "ready", unknown: "unknown" })[r.status] ?? r.status)));


    };

    return v_flex()
      .id("picker")
      .track_focus(this.handle)
      .w_full()
      .min_h(0)
      .p(10)
      .gap(8)
      .border_1().border_color(t.border)
      .bg(t.popover)
      .text_size(12).line_height(1.2)
      .on_key_down((e, cx) => {
        const k = e.key;
        if (k === "escape") return this.close();
        if (k === "down") this.at = (this.at + 1) % pickable.length;
        else if (k === "up") this.at = (this.at + pickable.length - 1) % pickable.length;
        else if (k === "d" && e.modifiers.control) {
          if (sel?.kind === "ctx") {
            this.close();
            if (sel.current) run("pane.close", { pane: sel.current.pane });
            else run("tab.close", { id: sel.ctx.id });
          }
        } else return;
        cx.stop_propagation();
        cx.notify();
      })
      .child(h_flex().items_center().child(div().flex_1().text_size(11).font_semibold().text_color(t.foreground).child("GO TO")).child(div().text_size(11).text_color(t.dim).child("Esc")))
      .child(
        h_flex().h(36).flex_none().px(10).gap(8).items_center().rounded(0).border_1().border_color(t.border).bg(t.background)
          .child(svg("mods/workspace-chrome/search.svg").size(15).text_color(t.dim))
          .child(Input.new(this.input).flex_1().h_full().text_size(12.8).text_color(t.foreground)),
      )
      .child(
        v_flex()
          .id("pk-list").relative()
          .on_size_change((size, cx) => {
            this.listHeight = size.height;
            cx.notify();
          })
          .h(Math.min(320, total))
          .min_h(0)
          .mb(6)
          .when(fixed, (el) =>
            el.overflow_hidden().on_scroll_wheel((e, cx) => {
              this.scroll = Math.max(0, Math.min(this.scroll - e.delta.y, maxScroll));
              // The selection follows the wheel, so the next frame doesn't scroll back to it.
              while (this.at < pickable.length - 1 && tops[rows.indexOf(pickable[this.at])] < this.scroll) this.at++;
              while (this.at > 0 && tops[rows.indexOf(pickable[this.at])] + (H[pickable[this.at].kind] ?? 32) > this.scroll + height) this.at--;
              cx.notify();
            }))
          .children(rows.map((r, i) => (visible(i) ? place(row(r), i) : null)).filter(Boolean)),
      );
  }
}
