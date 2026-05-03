-- gh-review.nvim
-- Inline PR review inside DiffView. No Snacks dependency.

return {
  dir = "~/Projects/gh-review.nvim",
  name = "gh-review",
  dependencies = { "sindrets/diffview.nvim" },
  event = "VeryLazy",
  opts = {
    gh_host = "$GH_HOST",
    keymaps = {
      add_comment = "pa",
      reply = "pr",
      edit_comment = "pe",
      toggle_resolve = "pR",
      toggle_expand = "pt",
      next_thread = "]c",
      prev_thread = "[c",
      open_popup = "pv",
      submit_review = "ps",
      open_threads = "pl",
      close = "q",
    },
  },
  config = function(_, opts)
    require("gh-review").setup(opts)
  end,
  keys = {
    {
      "<leader>gp",
      function()
        local url = vim.fn.input("PR URL or number: ")
        if url == "" then
          return
        end
        if url:match("^%d+$") then
          require("gh-review").open_number(tonumber(url))
        else
          require("gh-review").open(url)
        end
      end,
      desc = "Open PR in DiffView",
    },
    { "<leader>gt", "<cmd>GhReviewThreads<cr>", desc = "Toggle PR thread list" },
    { "<leader>gs", "<cmd>GhReviewSubmit<cr>", desc = "Submit PR review" },
  },
}
