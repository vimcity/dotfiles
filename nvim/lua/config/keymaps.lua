-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Move to start/end of line
vim.keymap.set({ "n", "v" }, "gh", "^", { desc = "Go to start of line" })
vim.keymap.set({ "n", "v" }, "gl", "$", { desc = "Go to end of line" })

-- Oil.nvim file explorer (floating window by default)
vim.keymap.set("n", "-", function()
  require("oil").toggle_float()
end, { desc = "Open parent directory (Oil float)" })
vim.keymap.set("n", "<leader>e", function()
  require("oil").toggle_float()
end, { desc = "Open file explorer (Oil float)" })
vim.keymap.set("n", "<leader>E", "<cmd>Oil<cr>", { desc = "Open Oil in split" })

-- Project management
vim.keymap.set("n", "<leader>fp", function()
  -- Expand the path before passing to the async finder
  local projects_dir = vim.fn.expand("~/Projects")
  
  Snacks.picker.projects({
    dev = { projects_dir },
    recent = false, -- Show all projects, not just recently visited
    -- Simple finder: just list all directories in Projects
    finder = function(opts, ctx)
      local dev_dirs = type(opts.dev) == "string" and { opts.dev } or opts.dev or {}
      
      return function(cb)
        for _, dev_dir in ipairs(dev_dirs) do
          local handle = vim.loop.fs_scandir(dev_dir)
          if handle then
            while true do
              local name, type_name = vim.loop.fs_scandir_next(handle)
              if not name then break end
              if type_name == "directory" then
                local project_path = dev_dir .. "/" .. name
                cb({ file = project_path, text = name, dir = true })
              end
            end
          end
        end
      end
    end,
  })
end, { desc = "Find Projects" })

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

-- Delete/change/cut to black hole register (don't pollute clipboard).
-- Keep this out of operator-pending mode: mapping `o` mode for `d`/`c`
-- breaks doubled operators like `dd` and `cc`.
vim.keymap.set("n", "d", '"_d', { noremap = true })
vim.keymap.set("n", "D", '"_D', { noremap = true })
vim.keymap.set("n", "c", '"_c', { noremap = true })
vim.keymap.set("n", "C", '"_C', { noremap = true })
vim.keymap.set("n", "x", '"_x', { noremap = true })
vim.keymap.set("n", "X", '"_X', { noremap = true })

vim.keymap.set("v", "d", '"_d', { noremap = true })
vim.keymap.set("v", "D", '"_D', { noremap = true })
vim.keymap.set("v", "c", '"_c', { noremap = true })
vim.keymap.set("v", "C", '"_C', { noremap = true })
vim.keymap.set("v", "x", '"_x', { noremap = true })
vim.keymap.set("v", "X", '"_X', { noremap = true })

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
