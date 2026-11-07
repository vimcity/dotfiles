import { View, div } from "gpui-kit";
import { closeOverlay, props, run, focused, openOverlay, notify, hc, layout } from "herdr";

import bindings from "./bindings.js";

function find(node, id) {
    if (node?.id === id) return node;
    for (const child of node?.children ?? []) {
        const found = find(child, id);
        if (found) return found;
    }
    return null;
}

export default class LegacyPrefix extends View {
    init(_props, cx) {
        this.bindings = bindings;
        this.handle = cx.focus_handle();
        this.handle.focus();
    }

    async launch(action, context) {
        if (!action.popup) {
            run("terminal.open", { argv: ["/bin/zsh", "-lc", action.shell], name: action.name, folder: context?.cwd });
            return;
        }
        try {
            const args = ["run", "--bg", "--json", "--no-parent", "--no-notify"];
            if (context?.cwd) args.push("--cwd", context.cwd);
            const result = await hc([...args, "--", "/bin/zsh", "-lc", action.shell]);
            if (result.code !== 0) throw new Error(result.stderr || "Could not start tool");
            const { address } = JSON.parse(result.stdout);
            if (!address) throw new Error("Core returned no terminal address");
            openOverlay({
                kind: "dialog", width: 1000, height: 650,
                layout: { type: "column", children: [
                    { type: "block", size: { px: 32 }, content: { mod: "peek", props: { terminal: address } } },
                    { type: "block", content: { terminal: address } },
                ] },
            });
        } catch (error) {
            notify({ title: "Could not open tool", body: String(error), level: "error" });
        }
    }

    render() {
        return div().id("legacy-prefix").size(1)
            .track_focus(this.handle)
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
                    this.launch(action, context);
                } else if (action?.worktree) {
                    openOverlay({ mod: "worktree", kind: "dialog", width: 600, props: { space: context?.space, action: action.worktree } });
                } else if (action?.panel) {
                    const root = layout();
                    const panel = find(root, "panel"), body = find(root, "panel-body");
                    if (panel && !panel.hidden && body?.active === action.panel) {
                        run("layout.hide", { id: "panel" });
                    } else {
                        run("layout.select", { stack: "panel-body", child: action.panel });
                        run("layout.show", { id: "panel" });
                    }
                }
            });
    }
}
