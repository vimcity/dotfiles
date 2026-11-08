import { div, svg } from "gpui-kit";
import { h_flex, v_flex, Input } from "gpui-base";

export const MENU_CHROME = 92;

export function menuFrame(t) {
  return v_flex().w_full().min_h(0).p(8).gap(6).rounded(12).shadow_xl()
    .border(0.5).border_color("#ffffff12").bg(t.popover).text_size(14).line_height(1.25);
}

export function menuSearch(input, icon, t) {
  return h_flex().h(36).flex_none().px(10).gap(8).items_center().rounded(8)
    .border(0.5).border_color("#ffffff0a").bg(t.chrome)
    .child(svg(icon).size(15).flex_none().text_color(t.dim))
    .child(Input.new(input).min_w(0).flex_1().h_full().text_size(15).font_medium().text_color(t.foreground));
}

export function menuScrollbar(id, height, total, offset, t, setScroll, beginDrag) {
  const maxScroll = Math.max(0, total - height);
  const thumbHeight = Math.min(height, Math.max(28, height * height / total));
  const thumbTop = maxScroll ? offset / maxScroll * (height - thumbHeight) : 0;
  return div().id(id).absolute().right(0).top(0).bottom(0).w(10).cursor_pointer()
    .on_mouse_down("left", (event, cx) => {
      cx.stop_propagation();
      if (!event.local_position || !event.bounds) return;
      const scale = height / event.bounds.height;
      const y = event.local_position.y * scale;
      const inside = y >= thumbTop && y <= thumbTop + thumbHeight;
      const position = inside ? offset : (y - thumbHeight / 2) / (height - thumbHeight) * maxScroll;
      setScroll(position, cx);
      beginDrag({ y: event.position.y, offset: Math.max(0, Math.min(position, maxScroll)),
        factor: maxScroll / (event.bounds.height - thumbHeight / scale) });
    })
    .child(div().absolute().right(2).top(thumbTop).w(4).h(thumbHeight).rounded(2).bg(t.dim));
}

export class MenuMotion {
  constructor() {
    this.phase = "enter";
    this.expanded = false;
    this.bounds = null;
  }

  start(cx) {
    cx.timer.after(16, cx => {
      if (this.phase !== "enter") return;
      this.phase = "open";
      cx.notify();
    });
  }

  toggleZoom(cx) {
    if (this.phase === "closing") return;
    this.expanded = !this.expanded;
    cx.notify();
  }

  heightLimit(fallback) {
    return this.expanded ? Math.max(120, fallback - 32 - MENU_CHROME) : null;
  }

  wrap(frame, id, dismiss, viewport = {}) {
    const zoom = viewport.zoom || 1;
    const viewportHeight = viewport.height ? viewport.height / zoom : null;
    if (viewport.width && viewport.height) {
      this.bounds = { width: Math.max(0, viewport.width / zoom - 32), height: Math.max(0, viewportHeight - 32) };
    }
    const width = this.expanded ? this.bounds?.width ?? 600 : Math.min(600, this.bounds?.width ?? 600);
    const surface = this.decorate(frame).w(width).overflow_hidden()
      .transition("width", { duration: 220, easing: "ease-out" })
      .transition("height", { duration: 220, easing: "ease-out" })
      .on_click((_event, cx) => cx.stop_propagation());
    return v_flex().id(`${id}-host`).w_full().h(viewportHeight ?? "100%").p(16).items_center()
      .on_size_change((size, cx) => {
        const bounds = { width: Math.max(0, size.width / zoom - 32), height: Math.max(0, size.height / zoom - 32) };
        const entering = this.phase === "enter";
        if (!entering && bounds.width === this.bounds?.width && bounds.height === this.bounds?.height) return;
        this.bounds = bounds;
        if (entering) this.phase = "open";
        cx.notify();
      })
      .on_click((_event, cx) => dismiss(cx))
      .child(surface);
  }

  decorate(element) {
    const closing = this.phase === "closing";
    return element.relative().top(this.phase === "enter" ? -6 : closing ? -3 : 0)
      .opacity(this.phase === "open" ? 1 : this.phase === "enter" ? 0.01 : 0)
      .transition("top", { duration: closing ? 110 : 160, easing: closing ? "ease-in" : "ease-out" })
      .transition("opacity", { duration: closing ? 110 : 140, easing: closing ? "ease-in" : "ease-out" });
  }

  dismiss(cx, done) {
    if (this.phase === "closing") return;
    this.phase = "closing";
    cx.notify();
    cx.timer.after(110, () => done());
  }
}
