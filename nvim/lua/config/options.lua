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
local is_ssh_session = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
local is_herdr_session = vim.env.HERDR_ENV == "1"
local is_personal = vim.env.PERSONAL == "1"

vim.g.is_homelab = is_linux and is_ssh_session

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
-- Remote sessions use OSC 52 → the host terminal clipboard.
elseif is_ssh_session or (is_linux and is_herdr_session) then
  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if ok then
    vim.g.clipboard = {
      name = "osc52",
      copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
      paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
    }
  end
-- Local macOS uses the native clipboard.
elseif is_mac then
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
