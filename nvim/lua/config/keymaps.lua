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

-- Resize windows with Ctrl + Arrow keys (10 rows/columns per press)
vim.keymap.set("n", "<C-Up>", "<cmd>resize +10<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -10<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -10<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +10<cr>", { desc = "Increase window width" })
-- vim.keymap.set("n", ":", "q:i", { noremap = true, silent = true, desc = "Cmdwin in insert mode" })
-- vim.keymap.set("x", ":", "q:a", { noremap = true, silent = true, desc = "Vidual Cmdwin in insert mode" })
-- Better command-line editing
vim.keymap.set("c", "<M-Left>", "<S-Left>", { noremap = true }) -- back a word
vim.keymap.set("c", "<M-Right>", "<S-Right>", { noremap = true }) -- forward a word

-- Format all Java files in project directory
vim.api.nvim_create_user_command("FormatProject", function()
  local cwd = vim.fn.getcwd()
  local java_files = vim.fn.systemlist("find " .. cwd .. " -type f -name '*.java'")
  
  if #java_files == 0 then
    vim.notify("No Java files found in " .. cwd, vim.log.levels.WARN)
    return
  end
  
  local formatted = 0
  for _, file in ipairs(java_files) do
    vim.cmd("edit " .. file)
    vim.lsp.buf.format({ async = false })
    vim.cmd("write")
    formatted = formatted + 1
  end
  
  vim.notify("Formatted " .. formatted .. " Java files in " .. cwd, vim.log.levels.INFO)
end, { desc = "Format all Java files in project directory" })
