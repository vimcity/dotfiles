import { View, div } from "gpui-kit";
import { props, run, theme, closeOverlay, terminals } from "herdr";

export default class ToolPopup extends View {
  close() {
    const terminal = terminals().find(item => item.address === props().terminal);
    if (terminal?.state === "live") run("terminal.kill", { terminal: terminal.address });
  }

  render() {
    const t = theme();
    return div().id("tool-header").size_full().flex().items_center().justify_between().px(12).bg(t.surface)
      .text_size(13).text_color(t.muted)
      .child(props()?.title ?? "Tool")
      .child(div().id("close-tool").px(8).cursor_pointer().hover(el => el.text_color(t.foreground))
        .on_click((_event, cx) => {
          cx.stop_propagation();
          closeOverlay(props().overlay);
        }).child("Close"));
  }
}
