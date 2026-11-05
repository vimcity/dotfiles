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
profile setup. Login mode has not been disabled by this configuration.

Regular tool launchers create a full-size tab and request that Rex select it.
Popup launchers create a floating terminal. Foreground selection has been reported
as unreliable and still needs confirmation. Also inspect the launchers' explicit
login-shell wrappers for repeated initialization; ordinary split shortcuts call
Rex's built-in split action directly.

The scrollback helper resolves the current bundled Rex CLI instead of pinning a
specific app version, with a CLI-on-PATH fallback. Preserve this when updating it.

Use the community MCP to look for matching reports and release fixes. Record the
Rex version and distinguish measured startup costs from unmeasured GUI effects
before attributing the delay to shell configuration or Rex itself. Validate edits
with `rex config check`, reload the configuration, and inspect `rex keymap --json`
using the intended Rex CLI.
