export function parseUsage(cpuOutput, vmOutput, totalOutput) {
  const idle = [...cpuOutput.matchAll(/CPU usage:.*?([\d.]+)% idle/g)].pop();
  const pageSize = vmOutput.match(/page size of (\d+) bytes/);
  const active = vmOutput.match(/^Pages active:\s+(\d+)/m);
  const wired = vmOutput.match(/^Pages wired down:\s+(\d+)/m);
  const total = Number(totalOutput.trim());
  if (!idle || !pageSize || !active || !wired || !Number.isFinite(total) || total <= 0) {
    throw new Error("CPU/memory counters unavailable");
  }
  // Match btop's macOS system RAM metric: active + wired pages, excluding cache.
  const used = (Number(active[1]) + Number(wired[1])) * Number(pageSize[1]);
  const percent = value => Math.max(0, Math.min(100, Math.round(value)));
  return { cpu: percent(100 - Number(idle[1])), memory: percent(100 * used / total) };
}
