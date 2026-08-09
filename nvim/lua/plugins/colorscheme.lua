local colorscheme = vim.env.PROMPT_THEME == "catppuccin" and "catppuccin" or "catppuccin-rose"

return {
  require("plugins.catppuccin-rose"),

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = colorscheme,
    },
  },
}
