import { View, div } from "gpui-kit";
import { props, run, terminals, panes } from "herdr";

export default class ToolPopup extends View {
  close() {
    const terminal = props().terminal;
    if (panes().some(pane => pane.terminal === terminal)) return;
    if (terminals().some(item => item.address === terminal && item.state === "live")) {
      run("terminal.kill", { terminal });
    }
  }

  render() {
    return div().size(0);
  }
}
