return {
  "christoomey/vim-tmux-navigator",
  cond = not (vim.env.HERDR_ENV == "1" and (vim.env.TMUX == nil or vim.env.TMUX == "")),
  lazy = false,
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
}
