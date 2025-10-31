-- Fix for snacks.nvim picker and terminal errors
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      show_delay = 0, -- Fix: add missing show_delay config
      sources = {
        explorer = {
          hidden = true,  -- Show hidden files (dotfiles)
          ignored = true, -- Show gitignored files
        },
      },
    },
    -- Enable image rendering
    image = {
      enabled = true,
    },
  },
}
