import { View, div } from "gpui-kit";
import { appHome, focused, props, hc, openOverlay, closeOverlay, theme, run, terminals } from "herdr";

export default class TerminalCopy extends View {
  init(_props, cx) {
    if (props()?.header) return;
    const terminal = props()?.terminal ?? focused()?.terminal;
    this.message = terminal ? "Opening frozen scrollback…" : "Focus a terminal first.";
    if (!terminal) return;
    cx.spawn(async cx => {
      try {
        const result = await hc(["run", "--bg", "--json", "--no-parent", "--no-notify", "--",
          "/bin/zsh", "-lic", 'exec /bin/bash "$1" "$2"', "herdr-copy", `${appHome()}/mods/terminal-copy/copy-mode.sh`, terminal]);
        if (result.code !== 0) throw new Error(result.stderr || "Could not open copy mode");
        const { address } = JSON.parse(result.stdout);
        if (!address) throw new Error("Core returned no terminal address");
        openOverlay({ kind: "dialog", width: 0.9, height: 0.85, layout: { type: "column", children: [
          { type: "block", size: { px: 32 }, content: { mod: "terminal-copy", props: { terminal: address, header: true } } },
          { type: "block", content: { terminal: address } },
        ] } });
        closeOverlay(props().overlay);
      } catch (error) {
        this.message = String(error);
        cx.notify();
      }
    });
  }

  close() {
    if (props()?.header && terminals().some(terminal => terminal.address === props().terminal && terminal.state === "live")) {
      run("terminal.kill", { terminal: props().terminal });
    }
  }

  render() {
    const t = theme();
    if (props()?.header) return div().size_full().flex().items_center().justify_between().px(12).bg(t.surface)
      .text_size(12).text_color(t.muted).child("Frozen copy mode · v/V select · y copy · / search · q close")
      .child(div().id("close-copy").px(8).on_click(() => closeOverlay(props().overlay)).child("Close"));
    return div().p(16).text_color(t.foreground).child(this.message);
  }
}
