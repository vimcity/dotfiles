-- Add borders to LSP hover docs and signature help
return {
  "folke/noice.nvim",
  opts = {
    presets = {
      lsp_doc_border = true,
    },
  },
  config = function(_, opts)
    require("noice").setup(opts)

    vim.api.nvim_set_hl(0, "NoicePopupBorder", { fg = "#c4a7e7" })
    vim.api.nvim_set_hl(0, "NoicePopupmenuBorder", { fg = "#c4a7e7" })
  end,
}
