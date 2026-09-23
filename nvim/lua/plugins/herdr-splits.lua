return {
  "lmilojevicc/herdr-splits.nvim",
  cond = vim.env.HERDR_ENV == "1" and (vim.env.TMUX == nil or vim.env.TMUX == ""),
  lazy = false,
  init = function()
    local config_dir = vim.fn.expand("~/.config/herdr/plugins/config")
    if vim.fn.isdirectory(config_dir) == 1 then
      vim.env.HERDR_PLUGIN_CONFIG_DIR = config_dir
    end
  end,
  config = function()
    require("herdr-splits").setup()
  end,
}
