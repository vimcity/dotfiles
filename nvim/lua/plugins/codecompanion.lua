local function env(name, default)
  local value = os.getenv(name)
  return value ~= nil and value ~= "" and value or default
end

return {
  {
    "olimorris/codecompanion.nvim",
    cond = function()
      return vim.fn.has("mac") == 1 or vim.g.is_homelab == false
    end,
    cmd = {
      "CodeCompanion",
      "CodeCompanionActions",
      "CodeCompanionChat",
    },
    keys = {
      { "<leader>a", "", desc = "+ai", mode = { "n", "x" } },
      { "<leader>aa", "<cmd>CodeCompanionActions<CR>", desc = "CodeCompanion actions" },
      { "<leader>ac", "<cmd>CodeCompanionChat Toggle<CR>", desc = "CodeCompanion chat" },
      { "<leader>ap", ":CodeCompanion ", desc = "CodeCompanion prompt", mode = { "n", "x" } },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = function()
      return {
        adapters = {
          copilot = function()
            return require("codecompanion.adapters").extend("copilot", {
              schema = {
                model = {
                  default = "claude-3.5-sonnet",
                },
              },
            })
          end,
          http = {
            omlx = function()
              return require("codecompanion.adapters").extend("openai_compatible", {
                env = {
                  url = env("OMLX_CODECOMPANION_URL", "http://127.0.0.1:8000"),
                  chat_url = env("OMLX_CODECOMPANION_CHAT_URL", "/v1/chat/completions"),
                  api_key = env("OMLX_CODECOMPANION_API_KEY_ENV", "TERM"),
                },
                schema = {
                  model = {
                    default = env("OMLX_CODECOMPANION_MODEL", "Qwen3.6-35B-A3B-OptiQ-4bit"),
                  },
                },
              })
            end,
          },
        },
        interactions = {
          chat = { adapter = env("USE_COPILOT", "omlx") },
          inline = { adapter = env("USE_COPILOT", "omlx") },
          cmd = { adapter = env("USE_COPILOT", "omlx") },
        },
        display = {
          chat = {
            show_header_separator = false,
            auto_scroll = true,
          },
        },
        prompt_library = {
          ["Org Rewrite"] = {
            strategy = "inline",
            description = "Rewrite selected text into cleaner org-mode structure.",
            prompts = {
              {
                role = "system",
                content = "Rewrite the selected text into concise, actionable org-mode content. Preserve meaning, remove filler, and keep headings and bullets practical.",
              },
            },
          },
          ["Task Shape"] = {
            strategy = "inline",
            description = "Turn rough thoughts into launchable AI workbench task text.",
            prompts = {
              {
                role = "system",
                content = "Turn the selected text into a concise top-level org TODO suitable for later :ai: execution. Include only useful notes and keep the result easy to scan.",
              },
            },
          },
        },
        opts = {
          log_level = "ERROR",
        },
      }
    end,
  },
}

