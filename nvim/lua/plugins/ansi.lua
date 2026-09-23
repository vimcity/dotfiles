return {
  {
    "0xferrous/ansi.nvim",
    ft = { "log", "ansi" },
    config = function()
      require("ansi").setup({
        auto_enable = false,
        auto_enable_stdin = true,
        filetypes = { "log", "ansi" },
        -- ansi.nvim cannot read Ghostty's palette reliably from a Neovim buffer.
        -- Use the soft Catppuccin ANSI palette instead of its harsh modern fallback.
        theme = "catppuccin",
      })
    end,
  },
}
