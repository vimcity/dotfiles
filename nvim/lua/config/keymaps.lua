-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Move to start/end of line
vim.keymap.set({ "n", "v" }, "gh", "^", { desc = "Go to start of line" })
vim.keymap.set({ "n", "v" }, "gl", "$", { desc = "Go to end of line" })

-- Project management
vim.keymap.set("n", "<leader>fp", "<cmd>Telescope projects<cr>", { desc = "Find Projects" })

-- Copy buffer path to clipboard
vim.keymap.set("n", "<leader>yp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Copy buffer path" })
