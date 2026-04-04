return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.pyright = vim.tbl_deep_extend("force", opts.servers.pyright or {}, {
        settings = {
          pyright = {
            disableOrganizeImports = true,
          },
          python = {
            analysis = {
              autoImportCompletions = false,
              diagnosticMode = "openFilesOnly",
            },
          },
        },
      })
    end,
  },
  {
    "linux-cultist/venv-selector.nvim",
    ft = nil,
    cmd = { "VenvSelect", "VenvSelectCached" },
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" },
    },
  },
}
