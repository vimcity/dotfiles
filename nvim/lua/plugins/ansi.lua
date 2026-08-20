return {
  {
    "0xferrous/ansi.nvim",
    lazy = false,
    config = function()
      require("ansi").setup({
        auto_enable = false,
        auto_enable_stdin = true,
        filetypes = { "log", "ansi" },
        theme = "catppuccin-frappe",
      })
    end,
  },
}
