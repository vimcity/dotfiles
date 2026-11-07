import { View, div } from "gpui-kit";
import { h_flex, v_flex, Input, InputState } from "gpui-base";
import { closeOverlay, focused, props, run, spaces, theme } from "herdr";

export default class MinimalRename extends View {
  init(_props, cx) {
    const current = focused();
    this.tabId = current?.tab ?? null;
    const tab = spaces().flatMap((space) => space.tabs).find((item) => item.id === this.tabId);
    this.name = tab?.named ? tab.name : "";
    this.overlay = props()?.overlay;
    this.error = "";
    this.input = InputState.new({ value: this.name, placeholder: "Tab name" });
    this.input.on("change", (_event, cx) => {
      this.name = this.input.value();
      this.error = "";
      cx.notify();
    });
    this.input.on("submit", (_event, cx) => this.submit(cx));
    this.input.on("focus", (_event, cx) => { this.inputFocused = true; cx.notify(); });
    this.input.on("blur", (_event, cx) => { this.inputFocused = false; cx.notify(); });
    if (this.name) this.input.set_selected_range({ start: 0, end: this.name.length });
    this.inputFocused = true;
    this.input.focus();
    cx.timer.after(600, () => this.input.focus());
    this.handle = cx.focus_handle();
  }

  cancel() {
    closeOverlay(this.overlay);
  }

  submit(cx) {
    const name = this.input.value().trim();
    if (!this.tabId) {
      this.error = "No active tab to rename";
      cx?.notify();
      return;
    }
    if (!name) {
      this.error = "Enter a tab name";
      cx?.notify();
      return;
    }
    closeOverlay(this.overlay);
    run("tab.rename", { id: this.tabId, name });
  }

  render() {
    const t = theme();
    const button = (id, label, primary, action) => h_flex()
      .id(id)
      .h(30)
      .px(10)
      .items_center()
      .justify_center()
      .rounded(0)
      .border_1()
      .border_color(primary ? t.solid : t.border)
      .bg(primary ? t.solid : t.popover)
      .text_color(primary ? t.solid_foreground : t.muted)
      .text_size(11.5)
      .font_medium()
      .cursor_pointer()
      .hover((style) => style.opacity(0.88))
      .on_click(action)
      .child(label);

    return v_flex()
      .id("minimal-rename")
      .track_focus(this.handle)
      .on_key_down((event, cx) => {
        if (event.key === "escape") {
          cx.stop_propagation();
          this.cancel();
        }
      })
      .w_full()
      .min_h(0)
      .p(14)
      .gap(9)
      .bg(t.popover)
      .text_color(t.foreground)
      .child(h_flex()
        .items_center()
        .child(div().flex_1().text_size(10).font_semibold().text_color(t.dim).child("TAB NAME"))
        .child(div().text_size(10).text_color(t.dim).child("Esc")))
      .child(div().text_size(14).font_semibold().child("Rename tab"))
      .child(Input.new(this.input)
        .h(34)
        .px(9)
        .rounded(0)
        .border_1()
        .border_color(this.inputFocused ? t.accent : t.border)
        .bg(t.background)
        .text_size(12)
        .text_color(t.foreground))
      .when(Boolean(this.error), (element) => element.child(
        div().text_size(11).text_color(t.blocked).child(this.error),
      ))
      .child(h_flex()
        .pt(2)
        .gap(6)
        .justify_end()
        .child(button("rename-cancel", "Cancel", false, () => this.cancel()))
        .child(button("rename-save", "Save  ↵", true, (_event, cx) => this.submit(cx))));
  }
}
