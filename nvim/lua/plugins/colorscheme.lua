return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
      style = "moon",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      on_highlights = function(hl, colors)
        hl.NormalFloat = { bg = "NONE" }
        hl.FloatBorder = { fg = colors.border_highlight, bg = "NONE" }
        hl.SnacksPickerNormal = { bg = "NONE" }
      end,
    },
  },

  {
    "sainnhe/everforest",
    priority = 1000,
  },

  {
    "navarasu/onedark.nvim",
    priority = 1000,
  },

  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    opts = {
      styles = {
        transparency = true,
      },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "rose-frappe",
    },
  },
}
