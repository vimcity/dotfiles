return {
  "stevearc/conform.nvim",
  opts = {
    -- Formatters configuration (if you need custom formatters)
    formatters_by_ft = {},
  },
  init = function()
    -- Disable auto-formatting globally
    vim.g.autoformat = false
  end,
}
