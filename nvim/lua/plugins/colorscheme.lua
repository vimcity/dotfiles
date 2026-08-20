local function use_flat_frappe_floats()
  local palette = require("catppuccin.palettes").get_palette("frappe")
  local float_groups = {
    "NormalFloat",
    "FloatTitle",
    "Pmenu",
    "PmenuSel",
    "SnacksPickerInput",
    "SnacksPickerList",
    "SnacksPickerPreview",
    "WhichKey",
    "WhichKeyFloat",
    "BufferLineFill",
    "TabLineFill",
    "DiffviewNormal",
    "DiffviewFilePanel",
  }
  local border_groups = {
    "FloatBorder",
    "SnacksPickerInputBorder",
    "SnacksPickerListBorder",
    "SnacksPickerPreviewBorder",
    "SnacksPickerBorder",
    "WhichKeyBorder",
  }

  for _, group in ipairs(float_groups) do
    vim.api.nvim_set_hl(0, group, { bg = palette.base })
  end
  for _, group in ipairs(border_groups) do
    vim.api.nvim_set_hl(0, group, { bg = palette.base, fg = palette.blue })
  end
  vim.api.nvim_set_hl(0, "PmenuSel", { bg = palette.surface0, fg = palette.text, bold = true })
end

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    init = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "catppuccin-frappe",
        callback = use_flat_frappe_floats,
        group = vim.api.nvim_create_augroup("DotfilesFrappeFloats", { clear = true }),
      })
    end,
    opts = {
      flavour = "frappe",
      transparent_background = false,
      background = { light = "latte", dark = "frappe" },
      integrations = {
        blink_cmp = true,
        gitsigns = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
            ok = { "underline" },
          },
        },
        noice = true,
        notify = true,
        snacks = true,
        telescope = true,
        treesitter = true,
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-frappe",
    },
  },
}
