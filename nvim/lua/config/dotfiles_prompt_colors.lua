---Hex colors aligned with `prompt-themes.zsh` (keep both in sync when you edit themes).
---When Neovim is launched from zsh, `vim.env.PROMPT_THEME` selects the same theme.
local M = {}

local themes = {
  ["catppuccin-rose"] = {
    git_icon = "#a6da95",
    git_fg = "#bd93f9",
    git_bg = "#302e4b",
    dir_accent = "#7287fd", -- dir segment fill in zsh; here used as project text accent on dark status bar
    sep = "#737994", -- between branch and project (overlay2-ish)
  },
  ["catppuccin"] = {
    git_icon = "#a6e3a1",
    git_fg = "#89b4fa",
    git_bg = "#313244",
    dir_accent = "#89b4fa",
    sep = "#6c7086",
  },
}

function M.get()
  local name = vim.env.PROMPT_THEME
  if name and themes[name] then
    return themes[name], name
  end
  return themes["catppuccin-rose"], "catppuccin-rose"
end

return M
