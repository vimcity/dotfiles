import { readdirSync, readFileSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const cwd = fileURLToPath(new URL("./", import.meta.url));
const tests = readdirSync(new URL("./tests/", import.meta.url)).filter(name => name.endsWith(".test.mjs")).sort();
const commands = [
  [process.execPath, ["--test", ...tests.map(name => `tests/${name}`)]],
  ...readdirSync(new URL("./tests/", import.meta.url)).filter(name => name.endsWith(".test.py")).sort()
    .map(name => ["python3", ["-B", `tests/${name}`]]),
];
if (process.argv.includes("--live")) {
  commands.push(["./install.sh", ["--check"]]);
  const { mods } = JSON.parse(readFileSync(new URL("./deploy.json", import.meta.url), "utf8"));
  const home = process.env.HERDR_APP_HOME || `${process.env.XDG_CONFIG_HOME || `${process.env.HOME}/.config`}/herdr-app`;
  for (const mod of mods) commands.push(["herdr-app", ["check", `${home}/mods/${mod}`]]);
}
for (const [command, args] of commands) {
  const result = spawnSync(command, args, { cwd, stdio: "inherit" });
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status ?? 1);
}
