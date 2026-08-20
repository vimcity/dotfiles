return {
  "akinsho/bufferline.nvim",
  opts = {
    options = {
      always_show_bufferline = false,
    },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)
    local base = require("catppuccin.palettes").get_palette("frappe").base
    local fill = vim.api.nvim_get_hl(0, { name = "BufferLineFill", link = false })
    vim.api.nvim_set_hl(0, "BufferLineFill", { bg = base, fg = fill.fg })
  end,
}
