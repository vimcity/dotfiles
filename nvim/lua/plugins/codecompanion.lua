return {
  {
    "olimorris/codecompanion.nvim",
    enabled = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("codecompanion").setup({
        adapters = {
          http = {
            ollama = function()
              return require("codecompanion.adapters").extend("ollama", {
                env = {
                  url = "http://localhost:11434",
                },
              })
            end,
          },
        },
        interactions = {
          chat = {
            adapter = {
              name = "ollama",
              model = "gemma3:1b",
            },
          },
          inline = {
            adapter = {
              name = "ollama",
              model = "gemma3:1b",
            },
          },
        },
      })

      -- Keybindings
      vim.keymap.set("n", "<leader>ac", "<cmd>CodeCompanionChat<CR>", { noremap = true, desc = "AI Chat" })
      vim.keymap.set("n", "<leader>aa", "<cmd>CodeCompanionActions<CR>", { noremap = true, desc = "AI Actions" })
      vim.keymap.set("v", "<leader>aa", "<cmd>CodeCompanionActions<CR>", { noremap = true, desc = "AI Actions" })
    end,
  },
}
