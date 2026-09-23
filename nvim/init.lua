-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.schedule(function()
  vim.keymap.set("n", "<leader>e", function()
    require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
  end, { desc = "Open file explorer" })
end)
-- let g:loaded_perl_provider = 0
-- let g:loaded_ruby_provider = 0
