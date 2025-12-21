return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = false, -- Disabled due to macOS code signing issues with treesitter parsers
    opts = {},
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    ft = "markdown",
  },
}
