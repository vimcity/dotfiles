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

-- Use system clipboard by default so plain y/yank also writes to + register
vim.opt.clipboard = "unnamedplus"

-- Clipboard provider overrides for different environments
local personal = os.getenv("PERSONAL")
local is_personal = personal == "1"
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
-- macOS: use pbcopy/pbpaste (default for local usage)
elseif is_personal and not vim.env.SSH_TTY and not vim.env.SSH_CONNECTION then
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
-- SSH/Tmux remote: use OSC 52 (for remote sessions)
elseif is_personal and (vim.env.SSH_TTY or vim.env.SSH_CONNECTION or vim.env.TMUX) then
  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if ok then
    vim.g.clipboard = {
      name = "OSC52",
      copy = {
        ["+"] = osc52.copy("+"),
        ["*"] = osc52.copy("*"),
      },
      paste = {
        ["+"] = osc52.paste("+"),
        ["*"] = osc52.paste("*"),
      },
    }
  end
end

vim.g.autoformat = true 
