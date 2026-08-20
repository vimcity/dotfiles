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

-- Clipboard: one explicit provider per environment.
-- Never use unnamedplus - it silently fails on remote hosts (no pbcopy).
local is_mac = vim.fn.has("mac") == 1
local is_linux = vim.fn.has("linux") == 1
local is_ssh = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
vim.g.is_homelab = is_linux and is_ssh

-- Termux: tablet SSH usage
if
  vim.env.PERSONAL == "1"
  and vim.fn.executable("termux-clipboard-set") == 1
  and vim.fn.executable("termux-clipboard-get") == 1
then
  vim.g.clipboard = {
    name = "termux",
    copy = { ["+"] = "termux-clipboard-set" },
    paste = { ["+"] = "termux-clipboard-get" },
    cache_enabled = false,
  }

-- SSH/remote: OSC 52 across the tunnel. Copy writes to local terminal
-- (Ghostty -> macOS pbcopy). Paste sends a read request back to local Ghostty.
elseif is_ssh then
  -- Copy: stdin -> base64 -> OSC 52 escape via xargs printf (proven to work)
  local osc_copy = {
    "bash", "-c",
    [[python3 -c 'import sys,base64; sys.stdout.write(base64.b64encode(sys.stdin.read().encode()).decode())' | xargs -I{} printf "\033]52;c;{}\a" ]],
  }

  -- Paste: send OSC 52 read request, decode Ghostty response
  local osc_paste = {
    "bash", "-c",
    [[printf "\033]52;c;?\a" && read -r -t 3 LINE < /dev/tty && echo "${LINE#*c;}" | base64 -d 2>/dev/null]],
  }

  vim.g.clipboard = {
    name = "osc52",
    copy = { ["+"] = osc_copy, ["*"] = osc_copy },
    paste = { ["+"] = osc_paste, ["*"] = osc_paste },
  }

-- Local macOS: native clipboard.
elseif is_mac then
  vim.g.clipboard = {
    name = "macOS",
    copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
    paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
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
--       local bg = "#303446" -- Catppuccin Frappe base
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
