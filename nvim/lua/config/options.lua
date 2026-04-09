-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.loaded_python3_provider = 0

-- Tab and indentation settings
vim.opt.tabstop = 4 -- Number of spaces that a <Tab> in the file counts for
vim.opt.shiftwidth = 4 -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.softtabstop = 4 -- Number of spaces that a <Tab> counts for while performing editing operations
vim.opt.smartindent = true -- Do smart autoindenting when starting a new line
vim.opt.autoindent = true -- Copy indent from current line when starting a new line

-- Clipboard provider overrides for different environments
vim.opt.clipboard = "unnamedplus"

local is_ssh_session = vim.env.SSH_TTY or vim.env.SSH_CONNECTION
local is_tmux_session = vim.env.TMUX
local is_personal = vim.env.PERSONAL == "1"

-- Termux: use termux-clipboard-set/get (for tablet SSH usage)
if
  is_personal
  and vim.fn.executable("termux-clipboard-set") == 1
  and vim.fn.executable("termux-clipboard-get") == 1
then
  vim.g.clipboard = {
    name = "termux",
    copy = {
      ["+"] = "termux-clipboard-set",
    },
    paste = {
      ["+"] = "termux-clipboard-get",
    },
    cache_enabled = 0,
  }
-- macOS: use pbcopy/pbpaste for local usage
elseif vim.fn.has("mac") == 1 and not is_ssh_session then
  vim.g.clipboard = {
    copy = {
      ["+"] = "pbcopy",
      ["*"] = "pbcopy",
    },
    paste = {
      ["+"] = "pbpaste",
      ["*"] = "pbpaste",
    },
  }
-- SSH/Tmux remote: write to tmux buffer (cross-pane paste) AND fire OSC 52 (local Mac clipboard)
elseif is_ssh_session or is_tmux_session then
  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  local function tmux_osc52_copy(reg)
    return function(lines, regtype)
      vim.fn.system("tmux load-buffer -", table.concat(lines, "\n"))
      if ok then
        osc52.copy(reg)(lines, regtype)
      end
    end
  end
  vim.g.clipboard = {
    name = "tmux+osc52",
    copy = {
      ["+"] = tmux_osc52_copy("+"),
      ["*"] = tmux_osc52_copy("*"),
    },
    paste = {
      ["+"] = { "tmux", "show-buffer" },
      ["*"] = { "tmux", "show-buffer" },
    },
  }
end

vim.g.autoformat = true
