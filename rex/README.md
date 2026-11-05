# Rex configuration

An experimental Rex setup that carries over a familiar Herdr workflow: prefix
shortcuts, keyboard pane navigation, command launchers, floating shells, and
scrollback viewing. Keep Herdr and Ghostty usable while evaluating Rex.

## Files and setup

- `init.lua`: keybindings, resize mode, and custom command launchers.
- `scripts/scrollback-nvim.sh`: captures a terminal's scrollback and opens it in
  Neovim, with optional tailspin highlighting.

`init.lua` is the main configuration, but the scrollback shortcut also needs the
helper script. The repository installer links both files into Rex's configuration
directory. The files in this directory are the source of truth; the active
configuration should link to them, rather than linking this directory back to an
untracked local configuration.

The launchers depend on the tools and scripts they invoke. Copying these two files
does not install those dependencies or transfer Rex's application settings.

## Documentation and community MCP

Use the official read-only MCP to search Rex documentation, release notes, and
current and archived Rex Beta Discord discussions.

- Server name: `superlogical`, as recommended by Rex to avoid naming conflicts.
- Server URL: `https://www.superlogical.com/rex/community-mcp`
- Authentication: Discord OAuth; membership in the Rex Beta Discord is required.

Add the URL to an MCP-capable agent client, complete its OAuth sign-in, and verify
that the client can search documentation and community discussions. Configure the
connection and credentials in the agent client, not in `init.lua` or this
repository. Connection setup is a separate task; these Rex files do not install
or authenticate the MCP server.

References: [Community MCP](https://www.superlogical.com/rex/docs/beta/community-mcp)
and [documentation index](https://www.superlogical.com/rex/docs/llms.txt).

## Startup and launcher investigation

The main unresolved issue is the blank interval after opening a tab, split, or
popup, before the first shell output appears. A pane initially labeled "Shell"
and later "zsh" is an observation, not proof of the cause.

### Symptom and reproduction

Investigate this only where the symptom occurs; another installation with the
same dotfiles may be unaffected. It has been observed to be slower on a more
powerful computer than on a less powerful one, so hardware capacity alone does
not explain it.

- Open an ordinary split with `cmd+d`. The pane remains blank before even the
  `Last login` message appears, then the prompt loads.
- Press `cmd+d` five or six times quickly, or ten times to make the cadence
  clearer. On an affected installation, shells appear to become ready one by
  one instead of loading promptly while the shortcuts are pressed.
- On an unaffected installation, the same repeated-split test produces prompts
  almost immediately. This is a visual observation, not a measured timing.
- Repeat outside a Git repository to separate the initial blank interval from
  Git prompt work. Record whether the pane layout itself appears immediately
  or whether creation of subsequent splits also waits.

The sequential cadence suggests a possible serialized operation, but does not
establish where it occurs. The change from "Shell" to "zsh" does not prove shell
discovery is slow. `Last login` reports a previous login, not startup duration.
An unused config backup and the scrollback helper do not run on ordinary splits;
the helper runs only when its shortcut is invoked.

### Evidence to collect

- Record Rex and macOS versions, configured shell, login setting, and whether
  the issue survives a fresh app launch. Do not restart sessions with unsaved
  work merely to collect evidence.
- Use Rex Diagnostics to record one split and then a burst of splits. Inspect
  the `pane.split` app event, `session.new_split` request and response, and the
  subsequent terminal data events. A fast request response does not mean the
  shell has printed output or the app has displayed it.
- Measure request start, creation response, first readable terminal output,
  and a known shell-ready marker separately. API polling measures server-side
  output availability, with polling overhead; use a screen recording for the
  visible blank interval. Do not label either measurement as the other.
- Compare a bare command that immediately prints a marker, zsh with user
  startup files skipped, normal non-login interactive zsh, and normal login
  interactive zsh. Keep the directory and command consistent. zsh's `-f` skips
  user startup files but does not bypass the system `/etc/zshenv`.
- Run the equivalent shell cases in Ghostty. Measure rather than assume that
  its visually faster startup uses the same launch path and environment.
- Change one variable at a time and restore temporary changes. Do not remove
  prompt features or globally disable shell setup before isolating their cost.

### Questions for the documentation and community

Use the documentation links and optional community MCP above to search current
docs, changelogs, and Discord reports. MCP setup is not required on every
installation. If the symptom cannot be reproduced on the installation used for
research, use evidence from the affected installation rather than treating a
fast local test as a resolution.

Search for "split startup delay", "blank before Last login", "sequential pane
creation", "login shell latency", and "Shell to zsh title delay". Ask whether
there are known issues involving serialized process launches, login/account
services, terminal integration, first-output delivery, or client rendering.
Network or update checks are hypotheses to verify, not established causes;
local app/server traffic in Diagnostics is not evidence of internet access.

Include the reproduction steps, timing boundaries, version information, and
whether bare shells reproduce the delay in any report. Inspect recordings
before sharing them: their payloads may contain terminal text or other private
data. No matching community report or confirmed upstream cause is established
by this README.

Separate these stages when investigating:

1. Rex receives the request and creates the terminal.
2. The login process and shell start.
3. Shell startup files and integration run.
4. Prompt hooks run, including Git status and stash queries.
5. Rex displays the output and updates the pane title and focus.

Earlier controlled comparisons found substantial overhead in Rex's login startup
path even for a bare command with no interactive shell configuration. This makes
the Git prompt an insufficient explanation for the initial blank interval.
Shell and prompt costs still matter, especially inside large repositories.

Compare default login startup, `login = false`, and a clean shell with user startup
files skipped. Use zsh's `zprof` for function costs and separate wall-clock timing
for external commands, process creation, and first output. Preserve the normal
environment when evaluating non-login startup; do not silently discard login
profile setup. Single-app launchers disable login mode; ordinary tabs and splits
retain Rex's default shell behavior.

Regular tool launchers create a full-size tab and request that Rex select it.
Popup launchers create a floating terminal. Foreground selection has been reported
as unreliable and still needs confirmation. Ordinary split shortcuts call Rex's
built-in split action directly.

Single-app launchers set `login = false` and use a non-login, non-interactive zsh
wrapper for variable expansion and commands that change directory. They skip
`.zprofile` and `.zshrc`; zsh still reads `.zshenv`. Their PATH starts with the
Rex server's inherited environment and prepends the user tool directories and
common Homebrew executable directories. They do not copy environment changes
exported later in another pane, and do not refresh login-profile setup per launch.

Interactive shell launchers and the directory picker retain their login startup
because they need the interactive environment or shell functions. Keep this
distinction when adding launchers.

The scrollback helper resolves the current bundled Rex CLI instead of pinning a
specific app version, with a CLI-on-PATH fallback. Preserve this when updating it.

Use the community MCP to look for matching reports and release fixes. Record the
Rex version and distinguish measured startup costs from unmeasured GUI effects
before attributing the delay to shell configuration or Rex itself. Validate edits
with `rex config check`, reload the configuration, and inspect `rex keymap --json`
using the intended Rex CLI.
