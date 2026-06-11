-- Reuse core Vim mappings/options from vimrc.
vim.cmd.source(vim.fn.expand("~/dotfiles/vimrc"))

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
-- let g:loaded_perl_provider = 0
-- let g:loaded_ruby_provider = 0
