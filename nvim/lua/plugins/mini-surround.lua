-- Custom mini.surround config for LazyVim dotfiles
return {
  "nvim-mini/mini.surround",
  opts = {
    mappings = {
      add = "gza",        -- Add surrounding in Normal and Visual modes
      delete = "gzd",     -- Delete surrounding
      find = "gzf",       -- Find surrounding (to the right)
      find_left = "gzF",  -- Find surrounding (to the left)
      highlight = "gzh",  -- Highlight surrounding
      replace = "gzr",    -- Replace surrounding
      update_n_lines = "gzn", -- Update n_lines
      suffix_last = "l",      -- Suffix for searching with 'prev' method
      suffix_next = "n",      -- Suffix for searching with 'next' method
    },
  },
}
