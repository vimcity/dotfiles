import { View, div } from "gpui-kit";
import { closeOverlay, props, run, focused, openOverlay, notify, hc, layout, spaces, terminals, nextCommand, settings, shared, setShared } from "herdr";
import bindings from "./bindings.js";
import { bindingKey, terminalArgs } from "./keys.js";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

export default class CommandPrefix extends View {
  init(_props, cx) {
    this.context = focused();
    this.handle = cx.focus_handle();
    this.handle.focus();
    cx.spawn(async cx => {
      for (;;) {
        const command = await nextCommand();
        if (command.startsWith("key-")) this.dispatch(command.slice(4), cx);
      }
    });
  }

  async launch(action) {
    const context = this.context;
    const machine = spaces().find(space => space.id === context?.space)?.machine;
    const result = await hc(terminalArgs(action, context, machine));
    if (result.code !== 0) throw new Error(result.stderr || "Could not start tool");
    const { address } = JSON.parse(result.stdout);
    if (!address) throw new Error("Core returned no terminal address");
    return address;
  }

  show(address, action) {
    if (!action.popup) {
      setShared("command-prefix.tool-tabs", [
        ...(shared("command-prefix.tool-tabs") ?? []),
        { terminal: address, previousTab: this.context?.tab, previousPane: this.context?.pane, name: action.name, cwd: this.context?.cwd, phase: "waiting" },
      ]);
      run("terminal.keep", { terminal: address, place: "right" });
      return;
    }
    const viewport = window.viewport_size();
    const zoom = Number(settings().zoom) || 1;
    openOverlay({
      kind: "popup", frame: "none", width: 0.68, height: 0.68,
      at: { x: viewport.width * 0.16 / zoom, y: viewport.height * 0.16 / zoom },
      layout: { type: "column", radius: 12, shadow: "lg", background: "background", border: { width: 0.5, color: "#ffffff18" }, children: [
        { type: "block", size: { px: 0 }, content: { mod: "tool-popup", props: { terminal: address } } },
        { type: "block", content: { terminal: address } },
      ] },
    });
  }

  dispatch(key, cx) {
    if (this.pending) return;
    const action = bindings[key];
    if (action?.shell) {
      this.pending = true;
      cx.spawn(async cx => {
        try {
          this.launching = { address: await this.launch(action), action };
          cx.notify();
        } catch (error) {
          notify({ title: "Could not open tool", body: String(error), level: "error" });
          closeOverlay(props().overlay);
        }
      });
      return;
    }
    closeOverlay(props().overlay);
    if (typeof action === "string") {
      const [name, value] = action.split(":");
      const arg = name === "layout.toggle" ? "id" : name === "mod.open" ? "name" : name === "pane.split" ? "direction" : "index";
      if (name === "mod.open" && value === "terminal-hints") {
        openOverlay({ mod: value, kind: "dialog", width: 0.9, height: 0.85, props: { terminal: this.context?.terminal } });
      } else {
        run(name, value === undefined ? {} : { [arg]: arg === "index" ? Number(value) : value });
      }
    } else if (action?.worktree) {
      openOverlay({ mod: "worktree", kind: "dialog", width: 600, props: { space: this.context?.space, action: action.worktree } });
    } else if (action?.panel) {
      const root = layout();
      const panel = find(root, "panel"), body = find(root, "panel-body");
      if (panel && !panel.hidden && body?.active === action.panel) run("layout.hide", { id: "panel" });
      else {
        run("layout.select", { stack: "panel-body", child: action.panel });
        run("layout.show", { id: "panel" });
      }
    }
  }

  render(cx) {
    const terminal = this.launching && terminals().find(item => item.address === this.launching.address);
    if (terminal) {
      const { address, action } = this.launching;
      this.launching = null;
      cx.timer.after(0, () => {
        closeOverlay(props().overlay);
        if (terminal.state === "live") this.show(address, action);
        else notify({ title: "Tool exited before opening", body: action.name, level: "error" });
      });
    }
    return div().id("command-prefix").size(1).track_focus(this.handle)
      .on_key_down((event, cx) => {
        cx.stop_propagation();
        this.dispatch(bindingKey(event, bindings), cx);
      });
  }
}
