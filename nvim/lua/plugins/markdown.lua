return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    -- Disabled on macOS due to treesitter code signing issues
    -- Enable on other systems (Linux, Windows) for better markdown rendering
    enabled = vim.fn.has("mac") == 0,
    opts = {},
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    ft = "markdown",
  },
}
