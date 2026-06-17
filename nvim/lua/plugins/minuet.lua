return {
  {
    "milanglacier/minuet-ai.nvim",
    event = "InsertEnter",
    cmd = { "Minuet" },
    dependencies = {
      "Saghen/blink.cmp",
    },
    opts = {
      provider = "openai_compatible",
      request_timeout = 12,
      throttle = 1500,
      debounce = 900,
      notify = "warn",
      n_completions = 1,
      context_window = 900,
      provider_options = {
        openai_compatible = {
          api_key = "TERM",
          end_point = "http://localhost:11434/v1/chat/completions",
          model = "qwen2.5-coder:1.5b",
          name = "Ollama",
          optional = {
            num_ctx = 8192,
            max_tokens = 48,
            top_p = 0.9,
            thinking = { type = "disabled" },
          },
        },
      },
      blink = {
        enable_auto_complete = false,
      },
      virtualtext = {
        auto_trigger_ft = {},
        keymap = {
          accept = "<M-A>",
          accept_line = "<M-a>",
          accept_n_lines = "<M-z>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<M-e>",
        },
      },
    },
    config = function(_, opts)
      require("minuet").setup(opts)

      local trigger_minuet = function()
        require("blink.cmp").show({ providers = { "minuet" } })
      end

      vim.api.nvim_create_user_command("MinuetBlink", function()
        trigger_minuet()
      end, { desc = "Trigger Minuet Blink completion" })

      vim.keymap.set("i", "<C-g>y", function()
        trigger_minuet()
      end, { desc = "Trigger Minuet completion" })

      vim.keymap.set("i", "<M-y>", function()
        trigger_minuet()
      end, { desc = "Trigger Minuet completion" })
    end,
  },
  {
    "Saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.default = opts.sources.default or { "lazydev", "lsp", "path", "snippets", "buffer" }

      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.minuet = {
        name = "minuet",
        module = "minuet.blink",
        async = true,
        timeout_ms = 3000,
        score_offset = 45,
      }

      opts.completion = opts.completion or {}
      opts.completion.trigger = vim.tbl_deep_extend("force", opts.completion.trigger or {}, {
        prefetch_on_insert = false,
      })
    end,
  },
}
