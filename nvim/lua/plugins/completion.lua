return {
  {
    "saghen/blink.cmp",
    opts = {
      -- Disable completion entirely in prose buffers, even if another plugin
      -- adds a source later.
      enabled = function()
        return not vim.tbl_contains({
          "markdown",
          "md",
          "text",
          "txt",
          "org",
          "rst",
          "asciidoc",
          "gitcommit",
        }, vim.bo.filetype)
      end,
      -- For code buffers, only show completions supplied by an attached LSP.
      sources = {
        default = { "lsp" },
      },
    },
  },
}
