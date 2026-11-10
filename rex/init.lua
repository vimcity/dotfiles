rex.mode("resize", { exclusive = true })
rex.bind("resize/enter", "client.mode.exit")
rex.bind("resize/escape", "client.mode.exit")
rex.bind("ctrl+space>ctrl+,", "client.settings")
rex.bind("ctrl+space>,", "client.config.reload")
rex.bind("alt+e", "client.sidebar.toggle")
rex.bind("ctrl+space>q", "session.switch")
rex.bind("ctrl+f", "session.switch")
rex.bind("ctrl+space>ctrl+z", "client.mode.enter", { name = "resize" })
rex.bind("resize/left", "pane.resize", { direction = "left" })
rex.bind("resize/down", "pane.resize", { direction = "down" })
rex.bind("resize/up", "pane.resize", { direction = "up" })
rex.bind("resize/right", "pane.resize", { direction = "right" })
rex.bind("ctrl+space>c", "client.tab.new")
rex.bind("alt+h", "session.previous")
rex.bind("alt+l", "session.next")
rex.bind("ctrl+space>1", "client.tab.goto", { index = 1 })
rex.bind("ctrl+space>2", "client.tab.goto", { index = 2 })
rex.bind("ctrl+space>3", "client.tab.goto", { index = 3 })
rex.bind("ctrl+space>4", "client.tab.goto", { index = 4 })
rex.bind("ctrl+space>5", "client.tab.goto", { index = 5 })
rex.bind("ctrl+space>6", "client.tab.goto", { index = 6 })
rex.bind("ctrl+space>7", "client.tab.goto", { index = 7 })
rex.bind("ctrl+space>8", "client.tab.goto", { index = 8 })
rex.bind("ctrl+space>9", "client.tab.goto", { index = 9 })
rex.bind("alt+1", "client.tab.goto", { index = 1 })
rex.bind("alt+2", "client.tab.goto", { index = 2 })
rex.bind("alt+3", "client.tab.goto", { index = 3 })
rex.bind("alt+4", "client.tab.goto", { index = 4 })
rex.bind("alt+5", "client.tab.goto", { index = 5 })
rex.bind("alt+6", "client.tab.goto", { index = 6 })
rex.bind("alt+7", "client.tab.goto", { index = 7 })
rex.bind("alt+8", "client.tab.goto", { index = 8 })
rex.bind("alt+9", "client.tab.goto", { index = 9 })
rex.bind("ctrl+space>r", "client.tab.rename")
rex.bind("ctrl+space>w", "client.tab.close")
rex.bind("ctrl+space>v", "split_shell_right")
rex.bind("ctrl+space>s", "split_shell_down")
rex.bind("cmd+s", "split_shell_down")
rex.bind("ctrl+space>-", "split_shell_down")
rex.bind("ctrl+space>x", "pane.close")
rex.bind("alt+z", "pane.zoom")
rex.bind("ctrl+space>shift+h", "client.tab.move", { direction = "backward" })
rex.bind("ctrl+space>shift+l", "client.tab.move", { direction = "forward" })
rex.bind("ctrl+space>n", "session.new")
rex.bind("ctrl+space>.", "session.rename")
rex.bind("alt+k", "client.tab.previous")
rex.bind("alt+j", "client.tab.next")
rex.bind("ctrl+space>ctrl+space", "pane.send_key", { key = "ctrl+space" })

rex.action{
  name = "ignore_split_shortcut",
  title = "Disable Shift Command D Split",
  run = function() end,
}
rex.bind("shift+cmd+d", "ignore_split_shortcut")
rex.bind("ctrl+space>z", "pane.zoom")
rex.bind("ctrl+space>f", "pane.float")
rex.bind("ctrl+h", "pane.focus", { direction = "left" })
rex.bind("ctrl+space>h", "pane.focus", { direction = "left" })
rex.bind("resize/h", "pane.resize", { direction = "left" })
rex.bind("ctrl+j", "pane.focus", { direction = "down" })
rex.bind("ctrl+space>j", "pane.focus", { direction = "down" })
rex.bind("resize/j", "pane.resize", { direction = "down" })
rex.bind("ctrl+k", "pane.focus", { direction = "up" })
rex.bind("ctrl+space>k", "pane.focus", { direction = "up" })
rex.bind("resize/k", "pane.resize", { direction = "up" })
rex.bind("ctrl+l", "pane.focus", { direction = "right" })
rex.bind("ctrl+space>l", "pane.focus", { direction = "right" })
rex.bind("resize/l", "pane.resize", { direction = "right" })

local terminal = "com.superlogical.terminal"

local function checked(result, err)
  if not result then error(err, 0) end
  return result
end

local function pane_cwd(ctx)
  local reported = rex.block.call(terminal, "pwd", { block_id = ctx.block_id })
  local cwd = reported and reported.pwd
  if not cwd or cwd == "" then
    local process = rex.block.call(terminal, "process", { block_id = ctx.block_id })
    cwd = process and ((process.foreground and process.foreground.cwd)
      or (process.child and process.child.cwd))
  end
  if cwd and cwd:match("^file://") then
    cwd = cwd:gsub("^file://[^/]*", ""):gsub("%%(%x%x)", function(hex)
      return string.char(tonumber(hex, 16))
    end)
  end
  return cwd
end

-- Bypass slow macOS login descriptor cleanup; zsh still loads login profiles.
for _, item in ipairs({
  { name = "split_shell_right", title = "Split shell right", direction = "horizontal" },
  { name = "split_shell_down", title = "Split shell down", direction = "vertical" },
}) do
  local split = item
  rex.action{
    name = split.name,
    title = split.title,
    run = function(ctx) return checked(rex.session.new_split{
      session_id = ctx.session_id,
      anchor_id = ctx.block_id,
      direction = split.direction,
      side = "after",
      focus = true,
      layout = rex.layout.block{
        flavor = terminal .. ".shell",
        options = {
          shell = "none",
          login = false,
          command = { "/bin/zsh", "-il" },
          cwd = pane_cwd(ctx),
        },
      },
    }) end,
  }
end
rex.bind("cmd+d", "split_shell_right")

local function launch(ctx, item)
  local cwd = pane_cwd(ctx)
  local home = os.getenv("HOME")
  local options = {
    shell = "none",
    login = false,
    command = item.command or {
      "/bin/zsh", item.interactive_shell and "-lc" or "-c", item.shell_command,
    },
    cwd = cwd,
  }
  if not item.interactive_shell then
    options.path_prepend = {
      home .. "/.local/bin", home .. "/dotfiles/bin",
      "/opt/homebrew/bin", "/opt/homebrew/sbin", "/usr/local/bin",
    }
  end
  if item.scrollback then
    options.command = {
      "/bin/zsh", "-c", 'exec /bin/bash "$@"', "rex-scrollback",
      os.getenv("HOME") .. "/.config/rex/scripts/scrollback-nvim.sh", ctx.session_id, ctx.block_id,
    }
  end
  local layout = rex.layout.block{ flavor = terminal .. ".shell", options = options }
  if item.popup or item.temporary then
    local width, height = item.width or 0.75, item.height or 0.75
    return checked(rex.session.new_layer{
      session_id = ctx.session_id,
      bounds = { (1 - width) / 2, (1 - height) / 2, width, height },
      layout = layout,
      focus = true,
    })
  end
  local window = checked(rex.session.new_window{
    session_id = ctx.session_id,
    window_label = item.title,
    layout = layout,
    focus = true,
  })
  rex.client.queue("session.select", {
    session_id = ctx.session_id,
    window_id = window.window_id,
  })
  rex.client.queue("client.tab.goto", { index = -1 })
  return window
end

local launchers = {
  { name = "launch_scrollback", key = "ctrl+space>/", title = "scrollback in nvim with tailspin highlighting", scrollback = true },
  { name = "launch_popup_shell", interactive_shell = true, key = "ctrl+space>ctrl+p", title = "open floating shell", shell_command = "exec \"${SHELL:-/bin/zsh}\" -l", popup = true, width = 0.75, height = 0.75 },
  { name = "launch_shell_tab", interactive_shell = true, key = "ctrl+space>ctrl+c", title = "open floating shell", shell_command = "exec \"${SHELL:-/bin/zsh}\" -l" },
  { name = "launch_projects_editor", key = "ctrl+space>ctrl+n", title = "open Neovim in a Projects tab", shell_command = "cd \"${PROJECTS_DIR:-$HOME/Projects}\" && exec nvim" },
  { name = "launch_splunk", key = "ctrl+space>shift+s", title = "start lazy splunk tui", shell_command = "exec ~/.local/bin/lzk", temporary = true, width = 0.85, height = 0.8 },
  { name = "launch_review_prs", key = "ctrl+space>shift+g", title = "review PRs", shell_command = "exec $HOME/.local/bin/gh-pr-dash", temporary = true, width = 0.85, height = 0.8 },
  { name = "launch_popup_prs", key = "ctrl+space>shift+m", title = "review PRs in a floating popup", shell_command = "cd \"${PROJECTS_DIR:-$HOME/Projects}\" && exec \"$HOME/dotfiles/bin/ghprs\" mine", popup = true, width = 0.72, height = 0.65 },
  { name = "launch_lazygit", key = "ctrl+space>ctrl+g", title = "open lazyzgit", shell_command = "exec lazygit", temporary = true, width = 0.85, height = 0.8 },
  { name = "launch_org_task", key = "ctrl+space>ctrl+a", title = "open or create an org todo", shell_command = "exec $HOME/dotfiles/herdr/scripts/quick-org-task.sh", popup = true, width = 0.55, height = 0.5 },
  { name = "launch_confluence", key = "ctrl+space>shift+c", title = "open confluence docs", shell_command = "exec fluence pick", temporary = true, width = 0.75, height = 0.75 },
  { name = "launch_directory_picker", interactive_shell = true, key = "ctrl+space>ctrl+f", title = "pick a directory with g", shell_command = "cd \"${PROJECTS_DIR:-$HOME/Projects}\" && \"${SHELL:-/bin/zsh}\" -lic 'g; exec \"${SHELL:-/bin/zsh}\" -l'", temporary = true, width = 0.75, height = 0.75 },
  { name = "launch_stash", key = "ctrl+space>ctrl+s", title = "checkout stash", shell_command = "/opt/homebrew/bin/nvim ~/Documents/org/stash.md", popup = true, width = 0.65, height = 0.6 },
  { name = "launch_agenda", key = "ctrl+space>ctrl+o", title = "open today's org agenda", shell_command = "exec $HOME/dotfiles/herdr/scripts/agenda-today.sh", popup = true, width = 0.75, height = 0.75 },
  { name = "launch_org_plans", key = "ctrl+space>shift+o", title = "create new org plans", shell_command = "exec $HOME/dotfiles/herdr/scripts/org-plans.sh", popup = true, width = 0.85, height = 0.8 },
  { name = "launch_posting", key = "ctrl+space>p", title = "open Posting", shell_command = "exec posting --env \"$HOME/.local/share/posting/default/posting.env\"", temporary = true, width = 0.8, height = 0.8 },
  { name = "launch_jira", key = "ctrl+space>ctrl+j", title = "open Jira TUI", shell_command = "cd \"${JIRA_TUI_ROOT:-$HOME/Projects/jira-tui/bin}\" && exec \"${JIRA_TUI_BIN:-$HOME/.local/bin/jira-tui}\"", temporary = true, width = 0.85, height = 0.8 },
  { name = "launch_btop", key = "ctrl+space>ctrl+b", title = "open btop", shell_command = "exec \"${BTOP_BIN:-/opt/homebrew/bin/btop}\"", temporary = true, width = 0.8, height = 0.8 },
  { name = "launch_yazi", key = "ctrl+space>ctrl+y", title = "open yazi", shell_command = "exec \"${YAZI_BIN:-yazi}\"", temporary = true, width = 0.85, height = 0.8 },
  { name = "launch_lazydocker", key = "ctrl+space>ctrl+d", title = "open lazydocker", shell_command = "exec /opt/homebrew/bin/lazydocker", temporary = true, width = 0.85, height = 0.8 },
  { name = "launch_lmstat", key = "ctrl+space>ctrl+l", title = "open lmstat", shell_command = "exec $HOME/.local/bin/lmstat", temporary = true, width = 0.75, height = 0.75 },
}

for _, item in ipairs(launchers) do
  local launcher = item
  rex.action{
    name = launcher.name,
    title = launcher.title,
    run = function(ctx) return launch(ctx, launcher) end,
  }
  rex.bind(launcher.key, launcher.name)
end
