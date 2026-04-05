return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      local palette = require("catppuccin.palettes").get_palette("frappe")

      opts.options = opts.options or {}
      opts.options.theme = {
        normal = {
          a = { bg = palette.mauve, fg = palette.base, gui = "bold" },
          b = { bg = palette.surface0, fg = palette.text },
          c = { bg = "NONE", fg = palette.text },
        },
        insert = {
          a = { bg = "#81c8be", fg = palette.base, gui = "bold" },
          b = { bg = palette.surface0, fg = palette.text },
          c = { bg = "NONE", fg = palette.text },
        },
        visual = {
          a = { bg = palette.blue, fg = palette.base, gui = "bold" },
          b = { bg = palette.surface0, fg = palette.text },
          c = { bg = "NONE", fg = palette.text },
        },
        replace = {
          a = { bg = palette.red, fg = palette.base, gui = "bold" },
          b = { bg = palette.surface0, fg = palette.text },
          c = { bg = "NONE", fg = palette.text },
        },
        command = {
          a = { bg = palette.yellow, fg = palette.base, gui = "bold" },
          b = { bg = palette.surface0, fg = palette.text },
          c = { bg = "NONE", fg = palette.text },
        },
        inactive = {
          a = { bg = "NONE", fg = palette.overlay0, gui = "bold" },
          b = { bg = "NONE", fg = palette.overlay0 },
          c = { bg = "NONE", fg = palette.overlay0 },
        },
      }
    end,
  },
}
