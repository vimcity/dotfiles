import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, InputState, Input, Scrollbar, v_virtual_list, VirtualListScrollHandle } from "gpui-base";
import { spaces, panes, focused, exec, readTextFile, watchFolder, theme, settings, run, shared, layout, window } from "herdr";

function location() {
  const reviewContext = shared("review.return")?.context;
  if (reviewContext) return reviewContext;
  const space = spaces().find((s) => s.active), f = focused();
  const pane = f?.pane ? panes().find(p => p.pane === f.pane) : null;
  const on = f?.pane === null ? (f.terminal?.includes("/") ? f.terminal.split("/")[0] : null) : space?.machine ?? null;
  return { cwd: pane?.cwd || f?.cwd || space?.folder, on };
}
const key = () => JSON.stringify(location());
// Reads write nothing under .git (no index refresh or lock, no fsmonitor cookie):
// the folder watch would see it, and every refresh would start the next one.
const READ = ["--no-optional-locks", "-c", "core.fsmonitor=false", "-c", "diff.autoRefreshIndex=false"];
const countLines = (text) => text ? text.split("\n").length - Number(text.endsWith("\n")) : 0;

import { languageFor, codeText } from "./syntax.js";
import { fileTreeRows, diffRows, splitDiffRows } from "./diff-model.js";

// File-tree row height, in px. Shared by the list, the page size and the wheel.
const ROW_H = 30;

export default class Changes extends View {
  init(_props, cx) {
    this.files = []; this.rows = []; this.rawLines = []; this.diffWidth = 0; this.message = ""; this.viewMode = localStorage.getItem("changes-view") ?? "unified"; this.handle = cx.focus_handle();
    this.navScroll = VirtualListScrollHandle.new();
    this.collapsedDirs = new Set(); this.navCursor = 0; this.navStart = 0; this.navHeight = 0; this.diffCursor = 0; this.diffHeight = 0; this.reviewFocus = "files";
    this.navigatorVisible = true; this.splitSide = "new"; this.showKeys = false; this.composingNote = false;
    this.diffScroll = VirtualListScrollHandle.new();
    this.notes = JSON.parse(localStorage.getItem("review-notes") ?? "[]");
    this.noteInput = InputState.new({ placeholder: "Add a note on this file…" });
    this.pendingNoteKind = "Comment";
    this.noteInput.on("submit", (_e, cx) => this.addNote(this.pendingNoteKind, cx));
    this.noteInput.on("focus", () => { this.noteTyping = true; });
    this.noteInput.on("blur", () => { this.noteTyping = false; });
    this.input = InputState.new({ placeholder: "Commit message" });
    this.input.on("change", (_e, cx) => {
      const hadMessage = Boolean(this.message.trim());
      this.message = this.input.value();
      if (hadMessage !== Boolean(this.message.trim())) cx.notify();
    });
    this.input.on("submit", (_e, cx) => this.commit(cx));
    this.input.on("focus", (_e, cx) => { this.typing = true; cx.notify(); });
    this.input.on("blur", (_e, cx) => { this.typing = false; cx.notify(); });
    this.refresh(cx);
    cx.timer.every(10000, (cx) => this.refresh(cx));
  }

  watch(root, cx) {
    if (this.on || this.watched === root) return;
    this.watched = root;
    cx.spawn(async (cx) => {
      try {
        while (this.watched === root) {
          await watchFolder(root);
          if (this.watched === root) this.refresh(cx);
        }
      } catch { this.watched = null; }
    });
  }

  refresh(cx) {
    if (this.loading || this.busy) return;
    const { cwd, on } = location(), context = key();
    if (context !== this.context) {
      this.context = context; this.root = null; this.files = []; this.open = null;
      this.setLines([]); this.message = ""; this.input.set_value(""); this.error = null; this.note = null; this.watched = null; this.closed = false; this.limited = false;
    }
    if (!cwd) return;
    this.loading = true;
    cx.spawn(async (cx) => {
      try {
        const top = await exec("git", ["rev-parse", "--show-toplevel"], { cwd, on });
        if (key() !== context) return;
        if (top.code !== 0) { this.root = null; this.files = []; this.setLines([]); this.open = null; this.error = "Not a git repository"; return; }
        const root = top.stdout.trim(), git = (args) => exec("git", [...READ, ...args], { cwd: root, on });
        const status = await git(["status", "--porcelain=v1", "-z", "--no-renames", "--untracked-files=all"]);
        if (status.code !== 0) throw new Error(status.stderr);
        const head = await git(["rev-parse", "--verify", "HEAD"]);
        const stats = {};
        const results = head.code === 0 ? [await git(["diff", "HEAD", "--numstat", "-z", "--no-renames"])] : [await git(["diff", "--cached", "--numstat", "-z", "--no-renames"]), await git(["diff", "--numstat", "-z", "--no-renames"])];
        for (const result of results) {
          if (result.code !== 0) throw new Error(result.stderr);
          for (const entry of result.stdout.split("\0")) {
            const [a, d, ...parts] = entry.split("\t");
            if (!parts.length) continue;
            const path = parts.join("\t"), old = stats[path] ?? { add: 0, del: 0 };
            stats[path] = { add: old.add + (Number(a) || 0), del: old.del + (Number(d) || 0), binary: a === "-" };
          }
        }
        const files = [];
        const entries = status.stdout.split("\0").filter(Boolean);
        for (const entry of entries.slice(0, 1000)) {
          const xy = entry.slice(0, 2), path = entry.slice(3), fresh = xy === "??";
          const conflict = xy.includes("U") || xy === "AA" || xy === "DD";
          const s = conflict ? "U" : xy.includes("D") ? "D" : fresh || xy.includes("A") ? "A" : "M";
          const stat = stats[path] ?? { add: 0, del: 0 };
          files.push({ path, status: s, fresh, ...stat });
        }
        if (key() !== context) return;
        this.root = root; this.on = on; this.hasHead = head.code === 0; this.files = files; this.limited = entries.length > 1000; this.error = null;
        this.watch(root, cx);
        if (this.open && !files.some((f) => f.path === this.open)) { this.open = null; this.setLines([]); }
        // The first file's diff shows until you pick another.
        if (!this.open && !this.closed && files.length) this.open = files[0].path;
        if (this.open) {
          try { await this.load(this.open, context); }
          catch { if (key() === context) this.setLines(["Cannot preview this diff (too large or unreadable)"]); }
        }
      } catch (e) { if (key() === context) this.error = String(e); }
      finally { this.loading = false; cx.notify(); }
    });
  }

  async load(path, context) {
    this.language = languageFor(path);
    const file = this.files.find((f) => f.path === path), root = this.root, on = this.on;
    if (!file) return;
    let lines;
    if (file.fresh || (!this.hasHead && file.status === "A")) {
      const text = await readTextFile(`${root}/${path}`, { on }).catch(() => null);
      if (text === null) lines = ["Cannot preview this file (binary, too large, or unreadable)"];
      else if (text.includes("\0")) lines = ["Binary file · no text diff"];
      else {
        file.add = countLines(text);
        lines = [`@@ -0,0 +1,${file.add} @@`, ...text.slice(0, 400000).replace(/\n$/, "").split("\n").slice(0, 1500).map(l => `+${l}`)];
      }
    } else {
      const r = await exec("git", [...READ, "diff", ...(this.hasHead ? ["HEAD"] : []), "--no-ext-diff", "--no-textconv", "--no-color", "--", path], { cwd: root, on });
      if (r.code !== 0) throw new Error(r.stderr);
      const all = r.stdout.replace(/\n$/, "").split("\n"), first = all.findIndex((l) => l.startsWith("@@"));
      lines = first < 0 ? [file.binary ? "Binary file changed" : "No text diff available"] : all.slice(first);
    }
    if (key() === context && this.open === path) this.setLines(lines.slice(0, 1500).map(line => line.length > 4000 ? line.slice(0, 4000) + "… (line truncated)" : line));
  }

  setLines(lines) {
    this.rawLines = lines;
    this.rows = this.viewMode === "split" ? splitDiffRows(lines) : diffRows(lines);
    this.diffWidth = Math.max(this.viewMode === "split" ? 640 : 300, ...lines.map(line => line.length * 7 * (this.viewMode === "split" ? 2 : 1) + 50));
  }

  setViewMode(mode, cx) {
    this.viewMode = mode;
    localStorage.setItem("changes-view", mode);
    this.setLines(this.rawLines);
    cx.notify();
  }

  pick(path, cx) {
    this.openFile(path, cx);
  }

  openFile(path, cx) {
    if (this.open === path) return;
    this.open = path; this.closed = false; this.setLines([]); this.diffCursor = 0; this.note = null;
    const context = this.context;
    cx.spawn(async (cx) => {
      try { await this.load(path, context); }
      catch (e) { if (key() === context && this.open === path) this.note = `Cannot preview this diff (too large or unreadable): ${e}`; }
      this.diffScroll.scroll_to_item(0, "top");
      cx.notify();
    });
    cx.notify();
  }

  moveNavigator(delta, cx) {
    const rows = fileTreeRows(this.files, this.collapsedDirs);
    if (!rows.length) return;
    this.navCursor = Math.max(0, Math.min(rows.length - 1, this.navCursor + delta));
    this.keepNavigatorCursorVisible(rows.length);
    const row = rows[this.navCursor];
    if (row.type === "file") this.openFile(row.path, cx);
  }

  moveDiff(delta, cx) {
    this.diffCursor = Math.max(0, Math.min(this.rows.length - 1, this.diffCursor + delta));
    const item = this.displayDiffRows?.findIndex(row => row.type === "diff" && row.index === this.diffCursor) ?? this.diffCursor;
    this.diffScroll.scroll_to_item(item, "center");
    cx.notify();
  }

  pageMove(delta, half, cx) {
    const page = this.reviewFocus === "files"
      ? Math.max(1, Math.floor((this.navHeight || 560) / ROW_H))
      : Math.max(1, Math.floor((this.diffHeight || 560) / 20));
    const step = Math.max(1, Math.floor(page * (half ? 0.5 : 1)));
    if (this.reviewFocus === "files") this.moveNavigator(delta * step, cx);
    else this.moveDiff(delta * step, cx);
  }

  startCompose(kind) {
    if (!this.open || !this.rows.length) return;
    this.pendingNoteKind = kind;
    this.editingNoteId = null;
    this.composingNote = true;
    this.noteInput.set_value("");
    const item = this.displayDiffRows?.findIndex(row => row.type === "diff" && row.index === this.diffCursor) ?? this.diffCursor;
    this.diffScroll.scroll_to_item(item, "center");
    this.noteInput.focus();
  }

  actOnLineNote(cx) {
    const row = this.rows[this.diffCursor];
    const line = row?.newNumber ?? row?.number ?? row?.oldNumber;
    const note = this.notes.find(item => item.root === this.root && item.path === this.open && item.line === line);
    if (!note) return false;
    if (note.kind === "TODO") this.toggleNote(note.id, cx);
    else this.removeNote(note.id, cx);
    return true;
  }

  jumpFile(delta, cx) {
    const rows = fileTreeRows(this.files, this.collapsedDirs);
    const files = rows.map((row, index) => ({ row, index })).filter(item => item.row.type === "file");
    if (!files.length) return;
    const current = files.findIndex(item => item.row.path === this.open);
    const next = Math.max(0, Math.min(files.length - 1, current + delta));
    this.navCursor = files[next].index;
    this.keepNavigatorCursorVisible(rows.length);
    this.openFile(files[next].row.path, cx);
  }

  keepNavigatorCursorVisible() {
    this.navScroll.scroll_to_item(this.navCursor, "center");
  }

  toggleDirectory(path, cx) {
    if (this.collapsedDirs.has(path)) this.collapsedDirs.delete(path);
    else this.collapsedDirs.add(path);
    cx.notify();
  }

  addNote(kind, cx) {
    const text = this.noteInput.value().trim();
    if (!text || !this.root || !this.open) return;
    const row = this.rows[this.diffCursor];
    const line = row?.newNumber ?? row?.number ?? row?.oldNumber ?? null;
    const side = row?.kind === "-" || (row?.kind === "split" && !row.newText) ? "old" : "new";
    this.notes.push({ id: `${Date.now()}-${Math.random()}`, root: this.root, path: this.open, line, side, kind, text, done: false });
    localStorage.setItem("review-notes", JSON.stringify(this.notes));
    this.composingNote = false;
    this.noteInput.set_value("");
    this.handle.focus();
    cx.notify();
  }

  toggleNote(id, cx) {
    const note = this.notes.find(item => item.id === id);
    if (!note) return;
    note.done = !note.done;
    localStorage.setItem("review-notes", JSON.stringify(this.notes));
    cx.notify();
  }

  removeNote(id, cx) {
    this.notes = this.notes.filter(item => item.id !== id);
    localStorage.setItem("review-notes", JSON.stringify(this.notes));
    cx.notify();
  }

  commit(cx) {
    if (!this.message.trim() || !this.root || this.busy || this.loading || this.context !== key()) return;
    const root = this.root, on = this.on, context = this.context, message = this.message.trim();
    this.busy = true; this.note = null;
    cx.spawn(async (cx) => {
      try {
        for (const args of [["add", "-A"], ["commit", "-m", message]]) {
          const r = await exec("git", args, { cwd: root, on });
          if (r.code !== 0) throw new Error((r.stderr || r.stdout).trim());
        }
        if (key() === context) { this.message = ""; this.input.set_value(""); }
      } catch (e) { if (key() === context) this.note = `Commit failed: ${e}`; }
      finally { this.busy = false; this.refresh(cx); cx.notify(); }
    });
    cx.notify();
  }

  diffRow(row, t, index, focusedReview) {
    const selected = index === this.diffCursor && focusedReview;
    if (row.kind === "@") return div().w_full().px(12).h(20).flex_none().truncate().bg(selected ? t.selected : t.raised).text_color(t.dim).child(row.text);
    if (row.kind === "split") {
      const cell = (number, text, kind, side) => h_flex().flex_1().min_w(0).h(20).gap(6).items_center()
        .border_l(3).border_color(selected ? t.accent : this.reviewFocus === "diff" && side === this.splitSide ? t.muted : t.background)
        .when(kind === "+", el => el.bg(t.ansi2 + "33")).when(kind === "-", el => el.bg(t.ansi1 + "33"))
        .child(div().w(34).flex_none().text_right().text_color(t.dim).child(number === undefined ? "" : String(number)))
        .child(codeText(text, this.language, t));
      return h_flex().w_full().h(20).flex_none().gap(2)
        .child(cell(row.oldNumber, row.oldText, row.oldKind, "old"))
        .child(cell(row.newNumber, row.newText, row.newKind, "new"));
    }
    return h_flex().w_full().h(20).flex_none().gap(10)
      .when(row.kind === "+", e => e.bg(t.ansi2 + "33")).when(row.kind === "-", e => e.bg(t.ansi1 + "33"))
      .child(div().w(3).h_full().flex_none().bg(selected ? t.accent : t.background))
      .child(div().w(30).flex_none().text_right().text_color(t.dim).child(row.number === undefined ? "" : String(row.number)))
      .child(codeText(row.text, this.language, t));
  }

  render(cx) {
    if (key() !== this.context) this.refresh(cx);
    const t = theme(), add = this.files.reduce((n, f) => n + f.add, 0), del = this.files.reduce((n, f) => n + f.del, 0);
    const enabled = Boolean(this.message.trim() && this.root && !this.busy && !this.loading);
    const focusedReview = Boolean(shared("review.return"));
    const rootLayout = layout(), appWindow = window();
    const headerLeft = focusedReview && appWindow?.platform === "macos" && appWindow.titlebar === "none" && !appWindow.fullscreen && rootLayout?.traffic_lights
      ? Math.max(10, (rootLayout.traffic_lights[0] + 64) / settings().zoom)
      : 10;
    if (focusedReview && !this.inReview) {
      this.inReview = true; this.reviewFocus = "files";
      // Showing the panel hands focus to the pane it just hid, so take it once
      // the layout change has settled. Recap does the same for its input.
      cx.spawn(async () => this.handle.focus());
      cx.timer.after(60, () => this.handle.focus());
      cx.timer.after(600, () => this.handle.focus());
    }
    if (!focusedReview) this.inReview = false;
    const notes = this.notes.filter(note => note.root === this.root && note.path === this.open);
    const displayDiffRows = [];
    this.rows.forEach((row, index) => {
      displayDiffRows.push({ type: "diff", index, key: `diff-${index}`, size: 20 });
      const line = row.newNumber ?? row.number ?? row.oldNumber;
      if (line !== undefined && line !== null) for (const note of notes.filter(item => item.line === line)) displayDiffRows.push({ type: "note", note, key: `note-${note.id}`, size: 30 });
    });
    this.displayDiffRows = displayDiffRows;
    const modeButton = (mode, label, key) => div().h(24).px(7).flex().items_center().rounded(0)
      .bg(this.viewMode === mode ? t.selected : t.background).text_color(this.viewMode === mode ? t.foreground : t.muted)
      .cursor_pointer().on_click((_e, cx) => this.setViewMode(mode, cx)).child(`${label} ${key}`);
    const treeRows = fileTreeRows(this.files, this.collapsedDirs);
    this.navCursor = Math.max(0, Math.min(this.navCursor, Math.max(0, treeRows.length - 1)));
    if (this.open && this.navPath !== this.open) {
      const index = treeRows.findIndex(row => row.type === "file" && row.path === this.open);
      if (index >= 0) { this.navCursor = index; this.navPath = this.open; }
    }
    const fileTree = v_flex().id("review-file-tree").w(370).h_full().flex_none().min_h(0).gap(6)
      .child(h_flex().h(ROW_H).flex_none().px(8).items_center().text_size(13).font_semibold().text_color(t.dim).child("CHANGED FILES"))
      .child(v_flex().id("review-file-rows-x").flex_1().min_h(0).relative().overflow_hidden()
        .on_size_change((size, cx) => { this.navHeight = size.height; cx.notify(); })
        .on_scroll_wheel((e, cx) => this.moveNavigator(Math.sign(e.delta.y) * Math.max(1, Math.round(Math.abs(e.delta.y) / ROW_H)), cx))
        .child(v_virtual_list("review-file-rows", treeRows.length, treeRows.map(() => ROW_H), index => `review-row-${index}`, range =>
          treeRows.slice(range.start, range.end).map((row, offset) => {
            const i = range.start + offset, selected = i === this.navCursor && this.reviewFocus === "files";
            const base = h_flex().id(`review-row-${i}`).w_full().h(ROW_H).flex_none().px(6).gap(6).items_center().rounded(0)
              .bg(selected ? t.selected : t.background).hover(el => el.bg(t.hover)).cursor_pointer()
              .on_click((_e, cx) => {
                this.reviewFocus = "files"; this.navCursor = i; this.handle.focus();
                if (row.type === "directory") this.toggleDirectory(row.path, cx);
                else this.openFile(row.path, cx);
              })
              .child(div().w(row.depth * 12).flex_none());
            if (row.type === "directory") return base.child(div().w(14).flex_none().text_size(12).text_color(t.dim).child(row.expanded ? "▾" : "▸"))
              .child(div().flex_1().min_w(0).truncate().text_size(15).text_color(t.muted).child(row.name));
            return base.child(div().w(14).flex_none().text_size(12).text_color(row.status === "A" ? t.ansi2 : row.status === "D" ? t.ansi1 : row.status === "U" ? t.ansi1 : t.blocked).child(row.status))
              .child(div().flex_1().min_w(0).truncate().text_size(15).text_color(t.foreground).child(row.name))
              .when(row.add > 0, el => el.child(div().text_size(12).text_color(t.ansi2).child(`+${row.add}`)))
              .when(row.del > 0, el => el.child(div().text_size(12).text_color(t.ansi1).child(`−${row.del}`)));
          })).track_scroll(this.navScroll).size_full())
        .child(Scrollbar.vertical("review-file-rows").viewport_from_layout().absolute().inset_0()));
    const diffPane = v_flex().id("review-diff").h_full().flex_1().min_w(0).min_h(0).relative().font_family(settings().font_family ?? "JetBrains Mono").text_size(13)
      .on_mouse_down("left", (_e, cx) => { this.reviewFocus = "diff"; this.handle.focus(); })
      .on_size_change(size => { this.diffHeight = size.height; })
      .child(div().id("changes-diff-x").size_full().overflow_x_scrollbar()
        .on_scroll_wheel((e, cx) => this.moveDiff(Math.sign(e.delta.y) * Math.max(1, Math.round(Math.abs(e.delta.y) / 20)), cx))
        .child(div().w_full().min_w(this.diffWidth).h_full().child(v_virtual_list("changes-diff", displayDiffRows.length, displayDiffRows.map(item => item.size), item => item.key, range =>
          displayDiffRows.slice(range.start, range.end).map(item => item.type === "diff"
            ? this.diffRow(this.rows[item.index], t, item.index, focusedReview)
            : h_flex().w_full().h(30).flex_none().pl(42).pr(10).gap(8).items_center().bg(t.chrome)
              .child(div().w(90).flex_none().text_size(10).font_semibold().text_color(item.note.kind === "TODO" ? t.ansi3 : t.ansi4).child(`${item.note.done ? "DONE" : item.note.kind}${item.note.line ? ` · ${item.note.line}` : ""}`))
              .child(div().flex_1().min_w(0).truncate().text_color(item.note.done ? t.dim : t.foreground).child(item.note.text))))
          .track_scroll(this.diffScroll).size_full())))
      .child(Scrollbar.vertical("changes-diff").viewport_from_layout().absolute().inset_0())
      .when(!this.open && this.files.length > 0, el => el.child(div().absolute().top(6).px(12).text_color(t.dim).child("Select a file to view its changes")))
      .when(focusedReview && this.composingNote, el => {
        const row = this.rows[this.diffCursor];
        const line = row?.newNumber ?? row?.number ?? row?.oldNumber;
        return el.child(v_flex().id("inline-review-note").absolute().left(60).right(24).top(Math.max(34, Math.floor((this.diffHeight || 560) / 2) + 18)).gap(6).p(8).bg(t.chrome).border_1().border_color(t.accent)
          .child(h_flex().gap(6).items_center().text_size(11).font_semibold().text_color(this.pendingNoteKind === "TODO" ? t.ansi3 : t.ansi4).child(`${this.pendingNoteKind} · ${this.open}:${line ?? "file"}`))
          .child(h_flex().h(34).gap(6).items_center()
            .child(div().flex_1().min_w(0).h(32).px(8).flex().items_center().bg(t.background).on_mouse_down("left", (_e, cx) => cx.stop_propagation()).child(Input.new(this.noteInput).h_full().text_size(12).text_color(t.foreground)))
            .child(div().h(30).px(8).flex().items_center().bg(t.raised).cursor_pointer().on_click((_e, cx) => { this.composingNote = false; this.noteInput.set_value(""); this.handle.focus(); cx.notify(); }).child("Cancel"))
            .child(div().h(30).px(8).flex().items_center().bg(t.solid).text_color(t.solid_foreground).cursor_pointer().on_click((_e, cx) => this.addNote(this.pendingNoteKind, cx)).child("Save"))));
      });
    return v_flex().id("changes").size_full().min_h(0).relative().overflow_hidden().bg(t.background).text_color(t.foreground).text_size(13).track_focus(this.handle)
      .on_key_down((e, cx) => {
        if (this.typing || this.noteTyping) {
          if (e.key === "escape") { this.typing = false; this.noteTyping = false; this.composingNote = false; this.handle.focus(); cx.stop_propagation(); cx.notify(); }
          return;
        }
        if (!focusedReview) return;
        const key = e.key;
        if (this.showKeys) {
          if (key === "escape" || key === "?") this.showKeys = false;
          else return;
        } else if (key === "q" || key === "escape") run("mod.open", { name: "review-toggle" });
        else if (key === "?") this.showKeys = true;
        else if (e.modifiers.control && key === "d") this.pageMove(1, false, cx);
        else if (e.modifiers.control && key === "u") this.pageMove(-1, false, cx);
        else if (key === "tab") this.reviewFocus = this.navigatorVisible && this.reviewFocus !== "files" ? "files" : "diff";
        else if (key === "f") {
          this.navigatorVisible = !this.navigatorVisible;
          this.reviewFocus = this.navigatorVisible ? "files" : "diff";
        } else if (key === "j" || key === "down") this.reviewFocus === "files" ? this.moveNavigator(1, cx) : this.moveDiff(1, cx);
        else if (key === "k" || key === "up") this.reviewFocus === "files" ? this.moveNavigator(-1, cx) : this.moveDiff(-1, cx);
        else if (key === "page_down" || key === "pagedown") this.pageMove(1, false, cx);
        else if (key === "page_up" || key === "pageup") this.pageMove(-1, false, cx);
        else if ((key === "right" || key === "l") && this.reviewFocus === "files") {
          const row = fileTreeRows(this.files, this.collapsedDirs)[this.navCursor];
          if (row?.type === "directory" && !row.expanded) this.toggleDirectory(row.path, cx);
          else if (key === "l") this.reviewFocus = "diff";
          else return;
        } else if ((key === "left" || key === "h") && this.reviewFocus === "files") {
          const row = fileTreeRows(this.files, this.collapsedDirs)[this.navCursor];
          if (row?.type === "directory" && row.expanded) this.toggleDirectory(row.path, cx);
          else if (key === "h") return;
          else return;
        } else if ((key === "h" || key === "l") && this.reviewFocus === "diff" && this.navigatorVisible) {
          if (this.viewMode === "split") this.splitSide = key === "h" ? "old" : "new";
          else if (key === "h") this.reviewFocus = "files";
        } else if ((key === "h" || key === "l") && this.reviewFocus === "diff" && this.viewMode === "split") this.splitSide = key === "h" ? "old" : "new";
        else if (key === "[") this.jumpFile(-1, cx);
        else if (key === "]") this.jumpFile(1, cx);
        else if (key === "u") this.setViewMode("unified", cx);
        else if (key === "s") this.setViewMode("split", cx);
        else if (key === "c" && this.reviewFocus === "diff") this.startCompose("Comment");
        else if (key === "t" && this.reviewFocus === "diff") this.startCompose("TODO");
        else if (key === "d" && this.reviewFocus === "diff") this.actOnLineNote(cx);
        else return;
        cx.stop_propagation();
        cx.notify();
      })
      .child(h_flex().h(36).flex_none().pl(headerLeft).pr(10).gap(8).items_center()
        .when(focusedReview, el => el.child(svg("mods/changes-close/diff.svg").size(14).flex_none().text_color(t.muted)))
        .when(!focusedReview, el => el.child(div().font_semibold().child("Changes")))
        .child(div().px(5).py(1).rounded(0).bg(t.raised).text_size(10).text_color(t.muted).child(`${this.files.length} files`))
        .when(focusedReview, el => el.child(div().flex_1().min_w(0).truncate().text_color(t.muted).child(this.open ?? "")))
        .when(!focusedReview, el => el.child(div().flex_1()))
        .child(div().text_size(11).text_color(t.ansi2).child(`+${add}`)).child(div().text_size(11).text_color(t.ansi1).child(`−${del}`))
        .when(focusedReview, el => el.child(div().text_size(10).text_color(t.dim).child(this.reviewFocus === "files" ? "j/k files · Tab diff" : `j/k lines · ${this.viewMode === "split" ? `${this.splitSide} side` : "unified"} · c comment · t TODO`)))
        .when(focusedReview, el => el.child(div().h(24).px(7).flex().items_center().cursor_pointer().text_color(this.navigatorVisible ? t.muted : t.accent).on_click((_e, cx) => {
          this.navigatorVisible = !this.navigatorVisible;
          this.reviewFocus = this.navigatorVisible ? "files" : "diff";
          cx.notify();
        }).child(this.navigatorVisible ? "Hide files · f" : "Files · f")))
        .when(focusedReview, el => el.child(h_flex().gap(2).child(modeButton("unified", "Unified", "u")).child(modeButton("split", "Split", "s"))))
        .child(div().id("changes-close").size(24).flex_none().flex().items_center().justify_center().rounded(0).text_color(t.dim).hover((s) => s.bg(t.hover).text_color(t.foreground)).on_click((_e, cx) => {
          cx.stop_propagation();
          if (focusedReview) run("mod.open", { name: "review-toggle" });
          else run("layout.hide", { id: "panel" });
        }).child(svg("mods/pane/close.svg").size(12))))
      .when(focusedReview, el => el.child(h_flex().id("review-workspace").flex_1().min_h(0).gap(12).px(10).pb(8)
        .when(this.navigatorVisible, row => row.child(fileTree)).child(diffPane)))
      .when(!focusedReview, el => el.child(v_flex().id("changes-list").flex_none().h(Math.min(200, Math.max(44, this.files.length * 28 + 12))).overflow_y_scrollbar().p(6).children(this.files.map((f) => {
        const parts = f.path.split("/"), name = parts.pop();
        return h_flex().id(`change-${f.path}`).h(28).flex_none().px(8).gap(8).items_center().rounded(0).cursor_pointer().when(this.open === f.path, (e) => e.bg(t.selected)).hover((s) => s.bg(t.hover)).on_click((_e, cx) => this.pick(f.path, cx))
          .child(div().w(14).text_size(11).text_color(f.status === "A" ? t.ansi2 : f.status === "D" ? t.ansi1 : f.status === "U" ? t.ansi1 : t.blocked).child(f.status))
          .child(h_flex().flex_1().min_w(0).child(div().text_color(t.dim).truncate().child(parts.length ? parts.join("/") + "/" : "")).child(div().max_w(260).min_w(0).truncate().child(name)))
          .when(f.add > 0, (e) => e.child(div().text_size(11).text_color(t.ansi2).child(`+${f.add}`))).when(f.del > 0, (e) => e.child(div().text_size(11).text_color(t.ansi1).child(`−${f.del}`)));
      })).when(!this.files.length, (e) => e.child(div().p(8).text_color(t.dim).child(this.error || (this.loading ? "Loading changes…" : this.root ? "No uncommitted changes" : "No folder")))))
      .when(this.limited, el => el.child(div().px(12).py(4).text_size(11).text_color(t.dim).child("Showing the first 1,000 changed files"))))
      .when(!focusedReview, el => el.child(diffPane))
      .when(Boolean(this.note), (e) => e.child(div().px(10).pb(8).text_size(11).text_color(t.ansi1).child(this.note)))
      .when(focusedReview && this.showKeys, el => el.child(v_flex().absolute().inset_0().items_center().justify_center().bg(t.background + "dd")
        .on_click((_e, cx) => { this.showKeys = false; cx.notify(); })
        .child(v_flex().w(440).max_w_full().p(16).gap(8).bg(t.chrome).text_size(12)
          .child(div().font_semibold().text_color(t.foreground).child("Review keys"))
          .child(div().text_color(t.muted).child("j/k move · Ctrl+D/U page · Tab focus · f files"))
          .child(div().text_color(t.muted).child("h/l switch focus or split side · [/] previous/next file"))
          .child(div().text_color(t.muted).child("u unified · s split · c comment · t TODO · d resolve/delete"))
          .child(div().text_color(t.muted).child("q or Esc close · ? hide this help")))))
      .when(!focusedReview, el => el.child(h_flex().flex_none().p(10).gap(8)
        .child(div().id("commit-message").flex_1().min_w(0).h(32).px(10).flex().items_center().rounded(0).border_1().border_color(this.typing ? t.accent : t.border).cursor_text().on_mouse_down("left", (_e, cx) => cx.stop_propagation()).child(Input.new(this.input).h_full().text_size(12).text_color(t.foreground)))
        .child(div().id("commit").h(32).px(14).flex().items_center().rounded(0).bg(enabled ? t.solid : t.raised).text_color(enabled ? t.solid_foreground : t.dim).text_size(12).when(enabled, (e) => e.cursor_pointer()).on_click((_e, cx) => this.commit(cx)).child(this.busy ? "Committing…" : "Commit"))));
  }
}
