return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = true,
    opts = {},
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    ft = "markdown",
  },
  {
    "tpope/vim-markdown",
    ft = "markdown",
    config = function()
      vim.g.vim_markdown_follow_link = 1
      vim.g.vim_markdown_edit_link_in = "current_window"
    end,
  },
}
