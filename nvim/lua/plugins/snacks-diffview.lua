-- snacks-diffview.nvim integration
-- Bridge plugin combining Snacks.gh PR workflow with DiffView.nvim layout

return {
  dir = "$HOME/Projects/snacks-diffview-integration/snacks-diffview",
  name = "snacks-diffview",
  dependencies = {
    "folke/snacks.nvim",
    "sindrets/diffview.nvim",
  },
  opts = {
    -- Toggle between DiffView and default Snacks.gh view
    use_diffview = true, -- true = DiffView layout, false = default Snacks.gh picker

    -- Automatically override Snacks.gh gh_diff action
    auto_open = true,

    -- Keymaps for DiffView buffers
    keymaps = {
      add_comment = "a", -- Add inline comment
      show_actions = "<cr>", -- Show PR actions menu
      close_diffview = "q", -- Close DiffView
    },

    -- Behavior
    checkout_pr = true, -- Checkout PR branch before opening DiffView
    restore_branch = true, -- Restore original branch on close

    -- Visual
    show_notifications = false, -- Show status notifications
  },
}
