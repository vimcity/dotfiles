import { View, div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { exec, layout, run, settings, theme, window } from "herdr";

import { parseUsage } from "./usage.js";

export default class MinimalMetrics extends View {
  init(_props, cx) {
    this.usage = null;
    this.failed = false;
    this.refresh(cx);
    cx.timer.every(3000, cx => this.refresh(cx));
  }

  refresh(cx) {
    if (this.pending || this.failed) return;
    this.pending = true;
    cx.spawn(async cx => {
      try {
        const results = await Promise.all([
          exec("/usr/bin/top", ["-l", "2", "-s", "1", "-n", "0"]),
          exec("/usr/bin/vm_stat"),
          exec("/usr/sbin/sysctl", ["-n", "hw.memsize"]),
        ]);
        for (const result of results) {
          if (result.code !== 0) throw new Error(result.stderr);
        }
        this.usage = parseUsage(...results.map(result => result.stdout));
      } catch (error) {
        this.failed = true;
        this.usage = null;
        console.log(`System metrics stopped: ${error}`);
      } finally {
        this.pending = false;
        cx.notify();
      }
    });
  }

  render(cx) {
    const t = theme();
    const win = window();
    const lights = layout()?.traffic_lights;
    const zoom = Number(settings().zoom) || 1;
    if (this.zoom !== zoom) {
      this.zoom = zoom;
      cx.timer.after(0, () => run("layout.resize", { id: "brand", px: 36 / zoom }));
    }
    const left = win?.platform === "macos" && !win.fullscreen && lights
      ? (lights[0] + 72) / zoom
      : 12 / zoom;
    const metric = (icon, value, color) => h_flex().gap(4).flex_none().items_center().text_color(color)
      .child(svg(`mods/minimal-metrics/${icon}.svg`).size(12))
      .child(value == null ? "—" : value + "%");
    return h_flex().size_full().bg(t.chrome).pl(left).pr(8).pt(8 / zoom).gap(12 / zoom).items_start().text_size(10.5)
      .child(metric("cpu", this.usage?.cpu, t.ansi4))
      .child(metric("memory", this.usage?.memory, t.ansi5));
  }
}
