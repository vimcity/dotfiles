import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, InputState } from "gpui-base";
import { commands, layouts, keys, run, settings, nextCommand, theme, props, closeOverlay, openOverlay, shared, window as win } from "herdr";

import { MENU_CHROME, MenuMotion, menuFrame, menuSearch, menuScrollbar } from "./menu-ui.js";

// Fixed row geometry keeps keyboard selection aligned with the drawn viewport.
const SHOWN = 10;
const ROW_H = 38;
const HEAD_H = 32;
const LIST_H = SHOWN * ROW_H;
const GROUPS = ["Recent", "Tab", "Pane", "Space", "Layout", "Terminal", "Agent", "Window", "App"];

// The palette's names for commands: [command, args, group, title, keywords].
const NAMED = [
  ["tab.new", {}, "Tab", "New tab", "tab agent new task"],
  ["mod.open", { name: "minimal-picker" }, "Tab", "Go to space or tab…", "switch jump find"],
  ["mod.open", { name: "minimal-rename" }, "Tab", "Rename tab", "tab name"],
  ["tab.close", {}, "Tab", "Close tab", "tab kill"],
  ["tab.next", {}, "Tab", "Next tab", "tab"],
  ["tab.prev", {}, "Tab", "Previous tab", "tab"],
  ["pane.split", { direction: "right" }, "Pane", "Split right", "vertical"],
  ["pane.split", { direction: "down" }, "Pane", "Split down", "horizontal"],
  ["pane.close", {}, "Pane", "Close pane", "kill"],
  ["pane.zoom", {}, "Pane", "Zoom pane", "maximize fullscreen"],
  ...["left", "right", "up", "down"].map((d) => ["pane.go", { direction: d }, "Pane", `Focus pane ${d}`, "move go"]),
  ...["left", "right", "up", "down"].map((d) => ["pane.swap", { direction: d }, "Pane", `Swap pane ${d}`, "move"]),
  ["space.new", {}, "Space", "New space", "workspace"],
  ["space.rename", {}, "Space", "Rename space", "workspace"],
  ["space.close", {}, "Space", "Close space", "workspace kill"],
  ["space.next", {}, "Space", "Next space", "workspace"],
  ["space.prev", {}, "Space", "Previous space", "workspace"],
  ["layout.switch", {}, "Layout", "Next layout", "look switch"],
  ["layout.reset", {}, "Layout", "Reset layout", "new version default restore herdr's"],
  ["layout.clone", {}, "Layout", "Duplicate layout", "clone copy customize"],
  ["mod.clone", {}, "Layout", "Duplicate mod", "clone copy customize"],
  ["terminal.open", {}, "Terminal", "New terminal", "shell"],
  ["terminal.copy", {}, "Terminal", "Copy", "clipboard"],
  ["mod.open", { name: "terminal-hints" }, "Terminal", "Copy text with hints", "thumbs fingers regex path uuid email account"],
  ["mod.open", { name: "recap" }, "Agent", "Agent recaps", "summary recap reply"],
  ["terminal.paste", {}, "Terminal", "Paste", "clipboard"],
  ["agent.next", {}, "Agent", "Next agent", ""],
  ["agent.prev", {}, "Agent", "Previous agent", ""],
  ["window.minimize", {}, "Window", "Minimize window", ""],
  ["window.maximize", {}, "Window", "Maximize window", "restore"],
  ["window.close", {}, "Window", "Close window", "quit"],
  ["app.settings", {}, "App", "Settings", "preferences options config look font theme sound"],
  ["app.help", {}, "App", "Keys", "keybindings shortcuts help"],
  ["app.welcome", {}, "App", "Welcome", "intro start onboarding"],
  ["app.whats_new", {}, "App", "What's new", "release changes news update"],
  ["app.reset", {}, "App", "Reset to the default screen", "escape hatch broken restore"],
  ["app.zoom_in", {}, "App", "Zoom whole interface in", "bigger interface"],
  ["app.zoom_out", {}, "App", "Zoom whole interface out", "smaller interface"],
  ["app.zoom_reset", {}, "App", "Reset interface zoom", "interface size"],
  ["app.quit", {}, "App", "Quit Herdr", "exit"],
  ...["graphite", "ink", "moss", "atom-one-dark"].map((n) => ["app.theme", { name: n }, "App", `Theme: ${n.replace(/-/g, " ")}`, "colors look"]),
];

// Commands that act on something you point at (ids, terminals): not for a list.
const HIDDEN = new Set([
  "space.move", "tab.move", "space.select", "tab.select", "pane.focus", "terminal.keep",
  "terminal.park", "terminal.kill", "terminal.show", "agent.focus", "layout.set", "layout.toggle",
  "layout.show", "layout.hide", "layout.resize", "layout.select", "mod.open", "overlay.close",
  "tab.settle", "tab.unsettle",
  "app.palette", "app.hide", "app.hide_others", "app.show_all", "app.theme", "app.settings",
]);

function titleOf(name) {
  const [noun, verb] = name.split(".");
  return { group: noun.charAt(0).toUpperCase() + noun.slice(1), title: `${verb.replace(/_/g, " ")} ${noun}`.replace(/^./, (c) => c.toUpperCase()) };
}

// Every entry for the state we're in now.
function entries() {
  const known = new Set(commands().map((c) => c.name));
  const mac = win()?.platform === "macos";
  const list = NAMED.filter(([n]) => known.has(n))
    .filter(([n]) => !(mac && n.startsWith("window.")))
    .map(([name, args, group, title, words]) => ({ name, args, group, title, words }));
  if (shared("layout") === "minimal-frappe") {
    for (const [action, title] of [["in", "Larger terminal text"], ["out", "Smaller terminal text"], ["reset", "Reset terminal text size"]]) {
      list.push({ name: `minimal-pane.text-zoom-${action}`, args: {}, group: "Terminal", title, words: "font zoom text size" });
    }
  }
  for (const l of layouts()) {
    const t = { main: "Herdr", terminals: "Terminals", win98: "Herdr 98" }[l] ?? l.charAt(0).toUpperCase() + l.slice(1);
    list.push({ name: "layout.switch", args: { name: l }, group: "Layout", title: `Layout: ${t}`, words: `look ${l}` });
  }
  // Anything new in the app shows up too, until it gets a better name here.
  const named = new Set(NAMED.map(([n]) => n));
  for (const c of commands()) {
    if (named.has(c.name) || HIDDEN.has(c.name) || c.args.some((a) => a.required && a.name !== "name")) continue;
    list.push({ name: c.name, args: {}, ...titleOf(c.name), words: c.about });
  }
  return list.map((e) => ({ ...e, id: `${e.name}:${JSON.stringify(e.args)}` }));
}

// The key bound to an entry: `name` or `name:value` in keys.json.
function keyOf(e, bound) {
  const v = Object.values(e.args)[0];
  const want = v === undefined ? e.name : `${e.name}:${v}`;
  const effective = new Map();
  for (const section of ["global", `layout:${shared("layout")}`]) {
    for (const binding of bound.filter(binding => binding.section === section)) effective.set(binding.keys, binding);
  }
  return [...effective.values()].find(binding => binding.action === want)?.keys ?? null;
}

// "ctrl-shift-p" -> ["ctrl", "shift", "p"]; "ctrl--" -> ["ctrl", "-"].
function keyParts(k) {
  return k.endsWith("--") ? [...k.slice(0, -2).split("-"), "-"] : k.split("-");
}

// Fuzzy score of `q` in `text`, with the matched positions; null: no match.
function fuzzy(q, text) {
  const t = text.toLowerCase();
  let score = 0;
  let at = 0;
  let run = 0;
  const hits = [];
  for (const ch of q) {
    const i = t.indexOf(ch, at);
    if (i < 0) return null;
    const start = i === 0 || /[\s:.\-_/]/.test(t[i - 1]);
    run = i === at && hits.length ? run + 1 : 0;
    score += 1 + (start ? 6 : 0) + run * 3 - Math.min(i - at, 6) * 0.3;
    hits.push(i);
    at = i + 1;
  }
  return { score: score - text.length * 0.02, hits };
}

export default class Palette extends View {
  init(_props, cx) {
    this.motion = new MenuMotion();
    this.motion.start(cx);
    this.query = "";
    this.input = InputState.new({ placeholder: "Type a command…" });
    this.input.on("change", (_e, cx) => { this.query = this.input.value(); this.at = 0; this.revealPending = true; cx.notify(); });
    this.input.on("submit", (_event, cx) => this.go(this.rows()[this.at]?.e, cx));
    cx.timer.after(0, () => this.input.focus());
    this.at = 0;
    // How far the list is scrolled, px.
    this.scroll = 0;
    this.revealPending = true;
    this.recent = JSON.parse(localStorage.getItem("recent") ?? "[]");
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

  go(e, cx) {
    if (!e || this.motion?.phase === "closing") return;
    this.recent = [e.id, ...this.recent.filter(r => r !== e.id)].slice(0, 20);
    localStorage.setItem("recent", JSON.stringify(this.recent));
    this.dismiss(cx, () => {
      if (e.name === "mod.clone") {
        openOverlay({ mod: "prompt", kind: "dialog", width: 380, props: {
          title: "Duplicate mod", hint: "Mod to copy; creates <name>-copy",
          command: { name: "mod.clone", args: {} },
        } });
      } else run(e.name, e.name === "layout.clone" ? { name: shared("layout") ?? "main" } : e.args);
    });
  }

  setScroll(offset, cx) {
    this.scroll = Math.max(0, Math.min(offset, this.maxScroll ?? 0));
    this.revealPending = false;
    cx.notify();
  }

  navigate(command, cx) {
    if (command === "zoom") {
      this.revealPending = true;
      this.motion.toggleZoom(cx);
      return;
    }
    if (command === "escape") return this.dismiss(cx);
    const count = this.rows().length;
    if (!count) return;
    if (command === "down") this.at = Math.min(this.at + 1, count - 1);
    else if (command === "up") this.at = Math.max(this.at - 1, 0);
    else if (command === "pagedown") this.at = Math.min(this.at + SHOWN, count - 1);
    else if (command === "pageup") this.at = Math.max(this.at - SHOWN, 0);
    else if (command === "home") this.at = 0;
    else if (command === "end") this.at = count - 1;
    else return;
    this.revealPending = true;
    cx.notify();
  }

  // The rows to show: grouped when empty, ranked while typing.
  rows() {
    const all = entries();
    const q = this.query.trim().toLowerCase().replace(/\s+/g, "");
    if (!q) {
      const recent = this.recent.map((id) => all.find((e) => e.id === id)).filter(Boolean).slice(0, 5);
      const rest = GROUPS.slice(1).flatMap((g) => all.filter((e) => e.group === g && !recent.includes(e)));
      const others = all.filter((e) => !GROUPS.includes(e.group) && !recent.includes(e));
      return [...recent.map((e) => ({ e, head: "Recent" })), ...[...rest, ...others].map((e) => ({ e, head: e.group }))];
    }
    const rank = (e) => this.recent.indexOf(e.id);
    return all
      .map((e) => {
        const title = fuzzy(q, e.title);
        const more = fuzzy(q, `${e.group} ${e.title} ${e.name} ${e.words}`);
        const best = title ?? (more && { score: more.score - 4, hits: [] });
        return best && { e, score: best.score, hits: best.hits };
      })
      .filter(Boolean)
      .sort((a, b) => b.score - a.score || (rank(a.e) < 0 ? 99 : rank(a.e)) - (rank(b.e) < 0 ? 99 : rank(b.e)));
  }

  title(t, text, hits, on) {
    if (!hits?.length) return div().text_color(t.foreground).font_medium().when(on, el => el.font_semibold()).child(text);
    const parts = [];
    let cur = "";
    let lit = false;
    [...text].forEach((ch, i) => {
      const h = hits.includes(i);
      if (h !== lit && cur) {
        parts.push([cur, lit]);
        cur = "";
      }
      lit = h;
      cur += ch;
    });
    if (cur) parts.push([cur, lit]);
    return h_flex().children(parts.map(([s, h]) => div().text_color(h ? t.ansi4 : t.foreground).when(h, (d) => d.font_semibold()).child(s.replace(/ /g, "\u00a0"))));
  }

  render(cx) {
    const t = theme();
    const zoom = Number(settings().zoom) || 1;
    const viewport = window.viewport_size();
    const rows = this.rows();
    const bound = keys();
    this.at = Math.min(this.at, Math.max(0, rows.length - 1));
    const tops = [];
    let total = 0;
    rows.forEach((row, index) => {
      const head = !this.query && (index === 0 || row.head !== rows[index - 1].head);
      tops.push({ head, title: total, row: total + (head ? HEAD_H : 0) });
      total += (head ? HEAD_H : 0) + ROW_H;
    });
    const limit = Math.max(120, Math.min(LIST_H, viewport.height * 0.86 / zoom - MENU_CHROME));
    const height = this.motion?.heightLimit?.(viewport.height / zoom)
      ?? (rows.length ? Math.min(total, limit) : 48);
    const fixed = total > height;
    this.maxScroll = Math.max(0, total - height);
    const selected = tops[this.at];
    if (selected && this.revealPending) {
      const from = selected.head ? selected.title : selected.row;
      if (from < this.scroll) this.scroll = from;
      if (selected.row + ROW_H > this.scroll + height) this.scroll = selected.row + ROW_H - height;
    }
    this.revealPending = false;
    this.scroll = Math.max(0, Math.min(this.scroll, this.maxScroll));
    const keycap = key => h_flex().flex_none().gap(3).children(keyParts(key).map(part =>
      div().px(5).py(2).rounded(4).border(0.5).border_color("#ffffff0b").bg(t.chrome).text_size(10).text_color(t.muted).child(part)));
    const place = (element, start, end) => fixed
      ? element.absolute().left(0).right(10).top(start - this.scroll).bottom(height - (end - this.scroll))
      : element.flex_none().h(end - start);
    const visible = (start, end) => !fixed || (end > this.scroll && start < this.scroll + height);
    const icons = { Tab: "layers", Pane: "panel-right", Space: "folder", Layout: "sidebar", Terminal: "terminal", Agent: "terminal", Window: "monitor", App: "settings" };
    const colors = { Tab: t.ansi4, Pane: t.ansi4, Space: t.ansi5, Layout: t.ansi5, Terminal: t.ansi6, Agent: t.ansi6 };
    const list = [];
    rows.forEach((row, index) => {
      const position = tops[index];
      if (position.head && visible(position.title, position.row)) list.push(
        place(h_flex(), position.title, position.row).px(10).items_center().text_size(13).font_bold().text_color(t.muted).child(row.head));
      if (!visible(position.row, position.row + ROW_H)) return;
      const on = index === this.at;
      const fill = on ? t.selected : this.hoveredRow === row.e.id ? t.hover : t.popover;
      const key = keyOf(row.e, bound);
      list.push(place(h_flex(), position.row, position.row + ROW_H).id(`pl-${index}`).px(10).gap(9).items_center()
        .rounded(18).bg(fill).border(0.5).border_color(on ? "#ffffff14" : fill)
        .cursor_pointer().text_size(14).font_medium()
        .on_hover((hovered, cx) => { this.hoveredRow = hovered ? row.e.id : null; cx.notify(); })
        .on_click((_event, cx) => this.go(row.e, cx))
        .child(svg(`mods/workspace-chrome/${icons[row.e.group] || "square"}.svg`).size(15).flex_none().text_color(colors[row.e.group] || t.muted))
        .child(div().flex_1().min_w(0).overflow_hidden().whitespace_nowrap().child(this.title(t, row.e.title, row.hits, on)))
        .when(Boolean(key), el => el.child(keycap(key))));
    });
    const frame = menuFrame(t).id("palette").track_focus(this.handle).h(height + MENU_CHROME)
      .on_mouse_move((event, cx) => {
        if (this.drag) this.setScroll(this.drag.offset + (event.position.y - this.drag.y) * this.drag.factor, cx);
      })
      .on_mouse_up("left", () => { this.drag = null; })
      .on_hover(hovered => { if (!hovered) this.drag = null; })
      .on_key_down((event, cx) => {
        if (["up", "down", "pageup", "pagedown", "home", "end", "escape"].includes(event.key)) {
          cx.stop_propagation();
          this.navigate(event.key, cx);
        }
      })
      .child(menuSearch(this.input, "mods/minimal-palette/command.svg", t))
      .child(h_flex().h(28).flex_none().px(8).items_center().justify_between()
        .child(div().text_size(12).font_bold().text_color(t.muted).child("Commands"))
        .child(div().text_size(11).text_color(t.dim).child("Enter to run · Esc to close")))
      .child(div().id("palette-rows").relative().h(height).flex_none().overflow_hidden()
        .on_scroll_wheel((event, cx) => {
          cx.stop_propagation();
          const scale = height / (event.bounds?.height || height);
          this.setScroll(this.scroll - event.delta.y * scale, cx);
        })
        .children(rows.length ? fixed ? list : [v_flex().children(list)] : [div().px(10).py(14).text_size(13).text_color(t.dim).child(`Nothing matches "${this.query}".`)])
        .when(this.maxScroll > 0, el => el.child(menuScrollbar("palette-scrollbar", height, total, this.scroll, t,
          (offset, cx) => this.setScroll(offset, cx), drag => { this.drag = drag; }))));
    return this.motion ? this.motion.wrap(frame, "palette", cx => this.dismiss(cx), { ...viewport, zoom }) : frame;
  }
}
