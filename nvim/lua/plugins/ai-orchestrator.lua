return {
  {
    event = "VeryLazy",
    config = function()
      vim.api.nvim_create_user_command("AiSessionPick", function(opts)
        local query = vim.fn.shellescape(opts.args or "")
        vim.fn.jobstart({ "bash", "-lc", "ai session pick --resume " .. query }, { detach = 1 })
      end, { nargs = "?", complete = "file" })

      vim.api.nvim_create_user_command("AiPlanCreate", function()
        vim.fn.jobstart({ "bash", "-lc", "ai plan create" }, { detach = 1 })
      end, {})

      vim.api.nvim_create_user_command("AiPlanLaunch", function()
        vim.fn.jobstart({ "bash", "-lc", "ai plan launch" }, { detach = 1 })
      end, {})

      vim.keymap.set("n", "<leader>as", "<cmd>AiSessionPick<cr>", { desc = "AI session pick" })
      vim.keymap.set("n", "<leader>ap", "<cmd>AiPlanCreate<cr>", { desc = "AI plan create" })
      vim.keymap.set("n", "<leader>aP", "<cmd>AiPlanLaunch<cr>", { desc = "AI plan launch" })
    end,
  },
}
