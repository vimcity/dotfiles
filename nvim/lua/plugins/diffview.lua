-- Diffview for better git diff viewing
return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    opts = {
      enhanced_diff_hl = true,
      use_icons = true,
    },
    config = function(_, opts)
      require("diffview").setup(opts)

      vim.api.nvim_create_user_command("DiffviewMain", function()
        vim.cmd("DiffviewOpen origin/main...HEAD")
      end, { desc = "Open diff against origin/main" })
    end,
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
      { "<leader>gD", "<cmd>DiffviewMain<cr>", desc = "Diff vs origin/main" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Repo History" },
      { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
    },
  },
}
