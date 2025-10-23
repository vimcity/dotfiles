-- Fix for snacks.nvim picker and terminal errors
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      show_delay = 0, -- Fix: add missing show_delay config
    },
    -- Enable image rendering
    image = {
      enabled = true,
    },
  },
}
