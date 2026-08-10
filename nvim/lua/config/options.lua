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
-- Detect SSH by env var (portable) or process ancestry (works when SSH doesn't forward env vars)
local function is_ssh_session_by_proc()
  local ok, handle = pcall(vim.loop.new_timer)
  if not ok then
    return false
  end
  handle:close()

  -- Walk up the process tree looking for sshd
  local pid = vim.fn.getpid()
  for _ = 1, 20 do
    local ppid = vim.fn.systemlist("ps -o ppid= -p " .. pid)
    if #ppid == 0 then
      break
    end
    local parent = tonumber(ppid[1])
    if not parent or parent <= 1 then
      break
    end
    local comm = vim.fn.systemlist("ps -o comm= -p " .. parent)
    if #comm > 0 and comm[1]:match("sshd") then
      return true
    end
    pid = parent
  end
  return false
end

local is_ssh_session = vim.env.SSH_TTY or vim.env.SSH_CONNECTION or is_ssh_session_by_proc()
local is_herdr_session = vim.env.HERDR_ENV == "1"
local is_personal = vim.env.PERSONAL == "1"
local is_homelab = is_linux and is_ssh_session

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
-- Local macOS (including Herdr panes on this machine): direct pbcopy.
-- Herdr + nvim on the same Mac can call pbcopy; no OSC 52 hop needed.
elseif is_mac and not is_ssh_session then
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
-- Remote: Linux Herdr panes (`herdr --remote`) or SSH. OSC 52 → Ghostty/host clipboard.
-- Remote Herdr panes often lack SSH_*; HERDR_ENV alone must select this path.
elseif is_herdr_session or is_ssh_session then
  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if ok then
    vim.g.clipboard = {
      name = "osc52",
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
