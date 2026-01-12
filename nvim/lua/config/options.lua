-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Tab and indentation settings
vim.opt.tabstop = 4        -- Number of spaces that a <Tab> in the file counts for
vim.opt.shiftwidth = 4     -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = true   -- Use spaces instead of tabs
vim.opt.softtabstop = 4    -- Number of spaces that a <Tab> counts for while performing editing operations
vim.opt.smartindent = true -- Do smart autoindenting when starting a new line
vim.opt.autoindent = true  -- Copy indent from current line when starting a new line
-- Disable auto-formatting on save
vim.g.autoformat = false
