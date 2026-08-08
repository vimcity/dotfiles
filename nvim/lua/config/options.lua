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

local is_mac = vim.fn.has("mac") == 1
local is_linux = vim.fn.has("linux") == 1
local is_ssh_session = vim.env.SSH_TTY or vim.env.SSH_CONNECTION
local is_tmux_session = vim.env.TMUX
local is_herdr_session = vim.env.HERDR_ENV == "1"
local is_personal = vim.env.PERSONAL == "1"
local is_homelab = is_linux and (is_ssh_session or is_tmux_session)

vim.g.is_homelab = is_homelab

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
-- macOS: use pbcopy/pbpaste only outside remote multiplexers.
elseif is_mac and not is_ssh_session and not is_herdr_session then
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
-- Remote multiplexer: update tmux's buffer when present and use OSC 52 for the client clipboard.
-- Herdr panes may not inherit SSH_* from a persistent server process, so HERDR_ENV
-- must independently select this provider.
elseif is_ssh_session and is_herdr_session then
  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  local function tmux_osc52_copy(reg)
    return function(lines, regtype)
      if is_tmux_session then
        vim.fn.system("tmux load-buffer -", table.concat(lines, "\n"))
      end
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
      ["+"] = is_tmux_session and { "tmux", "show-buffer" } or osc52.paste("+"),
      ["*"] = is_tmux_session and { "tmux", "show-buffer" } or osc52.paste("*"),
    },
  }
end

-- -- Neovide: provide a solid background color (no terminal behind the window)
-- if vim.g.neovide then
--   vim.g.neovide_normal_opacity = 1.0
--   vim.g.neovide_theme = "bg_color"
--
--   -- After the colorscheme loads (which sets transparent bg), set the solid base color
--   vim.api.nvim_create_autocmd("UIEnter", {
--     group = vim.api.nvim_create_augroup("NeovideBg", { clear = true }),
--     once = true,
--     callback = function()
--       local bg = "#29273f" -- Frappe base from catppuccin-rose
--       vim.api.nvim_set_hl(0, "Normal", { bg = bg })
--       vim.api.nvim_set_hl(0, "NormalNC", { bg = bg })
--       vim.api.nvim_set_hl(0, "SignColumn", { bg = bg })
--     end,
--   })
-- end
--
vim.g.autoformat = false

-- Class/symbol breadcrumbs in the statusline (trouble.nvim); prefer full file path instead.
vim.g.trouble_lualine = false
