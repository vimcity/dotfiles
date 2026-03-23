return {
  -- Install catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "frappe", -- latte, frappe, macchiato, mocha
      -- local colors = require("catppuccin.palettes").get_palette("frappe") for name, hex in pairs(colors) do
      --     print(name .. ": " .. hex)
      -- end
      transparent_background = true,
      show_end_of_buffer = false,
      term_colors = true,
      custom_highlights = function(colors)
        return {
          NormalFloat = { bg = "NONE" },
          FloatBorder = { fg = colors.surface1, bg = "NONE" },
          -- CursorLine = { bg = colors., blend = 50 },
          -- CursorColumn = { bg = colors.surface1, blend = 100 },
          -- Snacks picker highlights
          SnacksPickerNormal = { bg = "NONE" },
          -- SnacksPickerCursorLine = { bg = colors.lavender, blend = 30 },
          -- SnacksPickerSelected = { bg = colors.lavender, blend = 30 },
        }
      end,
      dim_inactive = {
        enabled = false,
        shade = "dark",
        percentage = 0.15,
      },
      styles = {
        comments = {},
        conditionals = {},
      },
      integrations = {
        cmp = true,
        nvimtree = true,
        treesitter = true,
        mason = true,
        dap = true,
        dap_ui = true,
        which_key = true,
        neotree = true,
        -- telescope = {
        --   enabled = true,
        -- },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
        },
      },
    },
  },

  -- Configure LazyVim to load catppuccin
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}

