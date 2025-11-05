-- Fix for snacks.nvim picker and terminal errors
return {
  "folke/snacks.nvim",
  opts = function()
    local ascii = require("ascii")
    -- Convert ascii table to string
    local header = table.concat(ascii.art.text.neovim.sharp, "\n")

    -- Other options to try:
    -- local header = table.concat(ascii.get_random_global(), "\n")
    -- local header = table.concat(ascii.get_random("text", "neovim"), "\n")
    -- local header = table.concat(ascii.art.animals.dogs.lucky, "\n")

    return {
      dashboard = {
        preset = {
          header = header,
        },
      },
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
    }
  end,
}
