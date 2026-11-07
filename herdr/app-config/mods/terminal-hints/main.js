import { View, div } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { focused, props, hc, theme, closeOverlay, settings } from "herdr";
import rules from "./rules.js";
import { collectMatches } from "./matches.js";

export default class TerminalHints extends View {
  init(_props, cx) {
    this.handle = cx.focus_handle();
    cx.timer.after(0, () => this.handle.focus());
    this.typed = "";
    this.matches = [];
    this.message = "Reading visible text…";
    const terminal = props()?.terminal ?? focused()?.terminal;
    if (!terminal) {
      this.message = "Focus a terminal first.";
      return;
    }
    cx.spawn(async cx => {
      try {
        const result = await hc(["read", terminal, "--json", "--lines", "0"]);
        if (result.code !== 0) throw new Error(result.stderr || "Could not read terminal");
        this.matches = collectMatches(JSON.parse(result.stdout).text, rules);
        this.message = this.matches.length ? "" : "No matching text in the visible screen.";
      } catch (error) {
        this.message = String(error);
      }
      cx.notify();
    });
  }

  copy(match, cx) {
    cx.write_to_clipboard(match.value);
    closeOverlay(props().overlay);
  }

  render() {
    const t = theme();
    const matches = this.matches.filter(match => match.label.startsWith(this.typed));
    return v_flex().id("terminal-hints").w_full().h(Math.min(window.viewport_size().height * 0.75 / (Number(settings().zoom) || 1), Math.max(100, matches.length * 64 + 56))).min_h(0).px(12).pt(6).pb(12).gap(10).bg(t.popover)
      .text_color(t.foreground).track_focus(this.handle)
      .on_key_down((event, cx) => {
        cx.stop_propagation();
        if (event.key === "escape") return closeOverlay(props().overlay);
        if (event.key === "backspace") this.typed = this.typed.slice(0, -1);
        else if (!event.modifiers.control && !event.modifiers.alt && !event.modifiers.platform && /^[a-z]$/.test(event.key_char ?? event.key)) {
          const next = this.typed + (event.key_char ?? event.key);
          if (this.matches.some(match => match.label.startsWith(next))) this.typed = next;
        } else return;
        const selected = this.matches.find(match => match.label === this.typed);
        if (selected) return this.copy(selected, cx);
        cx.notify();
      })
      .child(h_flex().gap(12).items_center()
        .child(div().flex_1().text_size(12).child(`Copy hints · ${this.matches.length} matches`))
        .child(div().text_size(11).text_color(t.muted).child(this.typed || "type label · Esc cancels")))
      .when(Boolean(this.message), el => el.child(div().text_size(12).text_color(t.muted).child(this.message)))
      .child(v_flex().id("hint-list").flex_1().min_h(0).gap(3).overflow_y_scrollbar()
        .children(matches.map(match => h_flex().id(`hint-${match.label}`).px(8).py(7).gap(12).items_center()
          .hover(el => el.bg(t.hover)).on_click((_event, cx) => this.copy(match, cx))
          .child(div().w(32).flex_none().text_size(12).font_semibold().text_color(t.accent).child(match.label))
          .child(v_flex().flex_1().min_w(0).gap(3)
            .child(div().text_size(12).text_color(t.foreground).child(match.value))
            .child(div().truncate().text_size(10).text_color(t.muted).child(match.context)))
          .child(div().text_size(10).text_color(t.dim).child(match.kind)))));
  }
}
