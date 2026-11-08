import { Background, PathBuilder, div, image, svg } from "gpui-kit";

export function fadedLabel(text, background, bold = false) {
  const rect = PathBuilder.fill().move_to("0%", "0%").line_to("100%", "0%")
    .line_to("100%", "100%").line_to("0%", "100%").close().build();
  return div().relative().flex_1().min_w(0).overflow_hidden().whitespace_nowrap()
    .child(div().whitespace_nowrap().when(bold, el => el.font_family("Helvetica Neue").font_weight(700)).child(text))
    .child(window.paint_path(rect, Background.linear_gradient(90, background.slice(0, 7) + "00", background))
      .absolute().right(0).top(0).bottom(0).w(22));
}

export function programIcon(program, color, size = 15) {
  if (!program?.icon) return svg("mods/workspace-chrome/terminal.svg").size(size).flex_none().text_color(color);
  return program.tint
    ? svg(program.icon).size(size).flex_none().text_color(color)
    : image(program.icon).size(size).flex_none();
}

export function sidebarButton(t, zoom, toggle) {
  return div().id("fixed-sidebar-toggle").size(26 / zoom).flex_none().flex().items_center().justify_center()
    .rounded(5 / zoom).cursor_pointer().text_color(t.muted).hover(el => el.bg(t.hover).text_color(t.foreground))
    .tooltip("Toggle sidebar · Cmd-B")
    .on_mouse_down("left", (_event, cx) => cx.stop_propagation())
    .on_click((_event, cx) => { cx.stop_propagation(); toggle(); })
    .child(svg("mods/workspace-chrome/sidebar.svg").size(16 / zoom));
}
