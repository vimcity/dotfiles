import { View, div } from "gpui-kit";
import { exec, layout, setShared } from "herdr";
import { parseUsage } from "./usage.js";

function sidebarVisible(node) {
  if (!node || node.hidden) return false;
  if (node.id === "sidebar") return true;
  return (node.children ?? []).some(sidebarVisible);
}

export default class MinimalMetrics extends View {
  init(_props, cx) {
    this.usage = null;
    this.failed = false;
    this.refresh(cx);
    cx.timer.every(10000, cx => this.refresh(cx));
  }

  refresh(cx) {
    if (this.pending || this.failed || !sidebarVisible(layout())) return;
    this.pending = true;
    cx.spawn(async () => {
      try {
        const sample = async (command, args = []) => {
          const result = await exec(command, args);
          if (result.code !== 0) throw new Error(result.stderr);
          return result.stdout;
        };
        if (!this.totalMemory) this.totalMemory = await sample("/usr/sbin/sysctl", ["-n", "hw.memsize"]);
        const [cpu, memory] = await Promise.all([
          sample("/usr/bin/top", ["-l", "2", "-s", "1", "-n", "0"]),
          sample("/usr/bin/vm_stat"),
        ]);
        const usage = parseUsage(cpu, memory, this.totalMemory);
        if (usage.cpu !== this.usage?.cpu || usage.memory !== this.usage?.memory) {
          this.usage = usage;
          setShared("minimal.machine-usage.local", usage);
        }
      } catch (error) {
        this.failed = true;
        this.usage = null;
        setShared("minimal.machine-usage.local", null);
        console.log(`System metrics stopped: ${error}`);
      } finally {
        this.pending = false;
      }
    });
  }

  render() {
    return div().id("metrics-controller").size(0);
  }
}
