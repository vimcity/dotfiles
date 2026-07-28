return {
  "lmilojevicc/herdr-splits.nvim",
  cond = vim.env.HERDR_ENV == "1" and (vim.env.TMUX == nil or vim.env.TMUX == ""),
  lazy = false,
  config = function()
    require("herdr-splits").setup()
  end,
}
