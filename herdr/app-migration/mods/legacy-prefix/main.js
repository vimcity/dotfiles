import { View, div } from "gpui-kit";
import { closeOverlay, props, run, focused, openOverlay, notify, theme } from "herdr";

import bindings from "./bindings.js";

export default class LegacyPrefix extends View {
    init(_props, cx) {
        this.bindings = bindings;
        this.handle = cx.focus_handle();
        this.handle.focus();
    }

    render() {
        const t = theme();
        return div().id("legacy-prefix").p(16).bg(t.surface).text_color(t.foreground)
            .track_focus(this.handle).child("Ctrl+Space: press a key; Escape cancels")
            .on_key_down((event, cx) => {
                cx.stop_propagation();
                const action = this.bindings[event.keystroke] ?? this.bindings[event.key_char];
                const context = focused();
                closeOverlay(props().overlay);
                if (typeof action === "string") {
                    const [name, value] = action.split(":");
                    const arg = name === "layout.toggle" ? "id" : name === "mod.open" ? "name" : name === "pane.split" ? "direction" : "index";
                    run(name, value === undefined ? {} : { [arg]: arg === "index" ? Number(value) : value });
                } else if (action?.shell) {
                    run("terminal.open", { argv: ["/bin/zsh", "-lc", action.shell], name: action.name, folder: context?.cwd });
                } else if (action?.worktree) {
                    openOverlay({ mod: "worktree", kind: "dialog", width: 600, props: { space: context?.space, action: action.worktree } });
                }
            });
    }
}
