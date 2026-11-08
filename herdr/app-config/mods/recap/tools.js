import { exec } from "herdr";

// The herdr-recap this mod is part of (its release; the repo's tests hold it
// to herdr-plugin.toml's version). It does the work on each machine with
// agents: their sessions, recaps and titles, with the TUI plugin's cache.
export const RECAP_VERSION = "0.12.11";

// Puts that release on a machine, once: into a folder of its own version, so
// it never touches a herdr-recap installed for the TUI. The archive for the
// machine's system is checked against the release's checksums before it's
// used. Prints the binary's path.
const PROVISION = String.raw`
v=$1
dest="$HOME/.local/share/herdr-recap/app/$v"
bin="$dest/herdr-recap"
[ -x "$bin" ] && { printf '%s' "$bin"; exit 0; }
case "$(uname -s)" in Darwin) os=darwin ;; Linux) os=linux ;; *) echo "no herdr-recap for $(uname -s)" >&2; exit 1 ;; esac
case "$(uname -m)" in x86_64|amd64) arch=amd64 ;; arm64|aarch64) arch=arm64 ;; *) echo "no herdr-recap for $(uname -m)" >&2; exit 1 ;; esac
name="herdr-recap_$v""_$os""_$arch.tar.gz"
url="https://github.com/mrolafsson/herdr-recap/releases/download/v$v"
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "$url/$name" -o "$tmp/$name" && curl -fsSL "$url/checksums.txt" -o "$tmp/sums" || { echo "couldn't download herdr-recap $v" >&2; exit 1; }
want=$(grep " $name\$" "$tmp/sums" | cut -d' ' -f1)
if command -v sha256sum >/dev/null 2>&1; then have=$(sha256sum "$tmp/$name" | cut -d' ' -f1); else have=$(shasum -a 256 "$tmp/$name" | cut -d' ' -f1); fi
[ -n "$want" ] && [ "$want" = "$have" ] || { echo "herdr-recap $v didn't match its checksum" >&2; exit 1; }
tar -xzf "$tmp/$name" -C "$tmp" herdr-recap || exit 1
mkdir -p "$dest" && mv "$tmp/herdr-recap" "$bin.new" && chmod 755 "$bin.new" && mv "$bin.new" "$bin" || exit 1
printf '%s' "$bin"
`;

// The path of herdr-recap on a machine (null: this one), put there first if
// it isn't: asked once per machine while the mod runs.
const binaries = new Map();
export function recapBinary(machine) {
  const key = machine ?? "";
  if (!binaries.has(key)) {
    const p = exec("sh", ["-c", PROVISION, "sh", RECAP_VERSION], { on: machine }).then((r) => {
      if (r.code !== 0 || !r.stdout.trim()) throw new Error(r.stderr.trim().split("\n").pop() || `herdr-recap: exit ${r.code}`);
      return r.stdout.trim();
    });
    // A failure is tried again next time (offline, say), not remembered.
    p.catch(() => binaries.delete(key));
    binaries.set(key, p);
  }
  return binaries.get(key);
}

// Runs a program on a machine (null: this one): herdr-recap, the mod's own;
// herdr-github and herdr-linear, where they're installed.
export async function tool(name, args, machine) {
  if (name === "herdr-recap") {
    const path = await recapBinary(machine);
    const r = await exec("sh", ["-c", 'exec "$0" "$@"', path, ...args], { on: machine });
    if (r.code !== 0) throw new Error(r.stderr.trim().split("\n").pop() || `${name}: exit ${r.code}`);
    return JSON.parse(r.stdout);
  }
  // herdr-github and herdr-linear: the copy their app mod fetched (the newest),
  // else the one installed for the TUI.
  const find = `for b in $(ls -d "$HOME/.local/share/${name}/app/"*/${name} 2>/dev/null | sort -V -r) "$HOME/.local/bin/${name}"; do [ -x "$b" ] && exec "$b" "$@"; done; echo "${name} isn't installed" >&2; exit 127`;
  const r = await exec("sh", ["-c", find, "sh", ...args], { on: machine });
  if (r.code !== 0) throw new Error(r.stderr.trim().split("\n").pop() || `${name}: exit ${r.code}`);
  return JSON.parse(r.stdout);
}

