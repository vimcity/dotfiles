return {
  {
    "olimorris/codecompanion.nvim",
    cmd = {
      "CodeCompanion",
      "CodeCompanionActions",
      "CodeCompanionChat",
    },
    keys = {
      { "<leader>aa", "<cmd>CodeCompanionActions<CR>", desc = "AI Actions" },
      { "<leader>ac", "<cmd>CodeCompanionChat Toggle<CR>", desc = "AI Chat" },
      { "<leader>ap", ":CodeCompanion ", desc = "AI Prompt" },
      { "<leader>ai", ":CodeCompanion ", mode = "v", desc = "AI Inline Prompt" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = function()
      return {
        adapters = {
          http = {
            ollama = function()
              return require("codecompanion.adapters").extend("ollama", {
                env = {
                  url = "http://localhost:11434",
                },
                schema = {
                  model = {
                    default = "gemma4:e4b",
                  },
                },
              })
            end,
          },
        },
        strategies = {
          chat = {
            adapter = {
              name = "ollama",
              model = "gemma4:e4b",
            },
          },
          inline = {
            adapter = {
              name = "ollama",
              model = "gemma4:e4b",
            },
          },
          cmd = {
            adapter = {
              name = "ollama",
              model = "gemma4:e4b",
            },
          },
        },
        display = {
          chat = {
            show_header_separator = false,
            auto_scroll = true,
          },
        },
        opts = {
          log_level = "ERROR",
        },
      }
    end,
  },
}
