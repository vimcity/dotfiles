return {
  {
    event = "VeryLazy",
    config = function()
      vim.api.nvim_create_user_command("AiSessionPick", function(opts)
        local query = vim.fn.shellescape(opts.args or "")
        vim.fn.jobstart({ "bash", "-lc", "ai session pick --resume " .. query }, { detach = 1 })
      end, { nargs = "?", complete = "file" })

      vim.keymap.set("n", "<leader>as", "<cmd>AiSessionPick<cr>", { desc = "AI session pick" })
    end,
  },
}
