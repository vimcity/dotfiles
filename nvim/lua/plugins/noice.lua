-- Add borders to LSP hover docs and signature help
return {
  "folke/noice.nvim",
  opts = {
    lsp = {
      progress = { enabled = false },
      message = { enabled = false },
    },
    routes = {
      { filter = { find = "Repository registry initialization" }, opts = { skip = true } },
      { filter = { find = "Initialize Workspace" }, opts = { skip = true } },
      { filter = { find = "Importing Maven project" }, opts = { skip = true } },
      { filter = { find = "Building" }, opts = { skip = true } },
      { filter = { find = "Searching" }, opts = { skip = true } },
      { filter = { find = "Validate documents" }, opts = { skip = true } },
      { filter = { find = "Publish Diagnostics" }, opts = { skip = true } },
      { filter = { find = "ServiceReady" }, opts = { skip = true } },
    },
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
