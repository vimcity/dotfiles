return {
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    cmd = { "Copilot" },
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = false,
        hide_during_completion = true,
        debounce = 25,
        trigger_on_accept = true,
        keymap = {
          accept = "<A-CR>",
          accept_word = false,
          accept_line = "<A-.>",
          next = "<A-n>",
          prev = "<A-p>",
          dismiss = "<A-e>",
          toggle_auto_trigger = false,
        },
      },
      panel = {
        enabled = false,
      },
      filetypes = {
        org = true,
        markdown = true,
        gitcommit = false,
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuOpen",
        callback = function()
          vim.b.copilot_suggestion_hidden = true
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuClose",
        callback = function()
          vim.b.copilot_suggestion_hidden = false
        end,
      })

      local suggestion = require("copilot.suggestion")

      local function trigger_copilot()
        if vim.fn.mode():match("^[iR]") then
          suggestion.next()
          return
        end

        vim.cmd.startinsert()
        vim.defer_fn(function()
          if vim.fn.mode() ~= "i" then
            vim.notify("Copilot: could not enter insert mode", vim.log.levels.WARN)
            return
          end
          suggestion.next()
        end, 20)
      end

      vim.keymap.set("i", "<A-y>", trigger_copilot, { desc = "Copilot: trigger suggestion" })
      vim.keymap.set("n", "<leader>cp", trigger_copilot, { desc = "Copilot: trigger suggestion" })
    end,
  },
}

