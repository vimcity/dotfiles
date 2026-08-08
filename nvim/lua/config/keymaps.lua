-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Install pane navigation after LazyVim's defaults so there is one final owner.
-- A running tmux server is irrelevant: TMUX is set only inside an attached client.
local direct_herdr = vim.env.HERDR_ENV == "1" and (vim.env.TMUX == nil or vim.env.TMUX == "")
local pane_directions = {
  h = { herdr = "move_cursor_left", tmux = "TmuxNavigateLeft", desc = "Navigate left" },
  j = { herdr = "move_cursor_down", tmux = "TmuxNavigateDown", desc = "Navigate down" },
  k = { herdr = "move_cursor_up", tmux = "TmuxNavigateUp", desc = "Navigate up" },
  l = { herdr = "move_cursor_right", tmux = "TmuxNavigateRight", desc = "Navigate right" },
}

for key, direction in pairs(pane_directions) do
  if direct_herdr then
    vim.keymap.set("n", "<C-" .. key .. ">", function()
      require("herdr-splits")[direction.herdr]()
    end, { silent = true, desc = direction.desc .. " (Herdr/split)" })
  else
    vim.keymap.set(
      "n",
      "<C-" .. key .. ">",
      "<cmd><C-U>" .. direction.tmux .. "<cr>",
      { silent = true, desc = direction.desc .. " (tmux/split)" }
    )
  end
end

if not direct_herdr then
  vim.keymap.set("n", "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", {
    silent = true,
    desc = "Navigate previous (tmux/split)",
  })
end

-- Deletes → register "d" (paste with P), never system clipboard. Yanks still use unnamedplus.
local delete_map_opts = { noremap = true, silent = true }
local delete_maps = {
  { "n", "d", '"_d' },
  { "n", "D", '"_D' },
  { "n", "x", '"_x' },
  { "n", "X", '"_X' },
  { "n", "c", '"_c' },
  { "n", "C", '"_C' },
  { "n", "s", '"_s' },
  { "n", "S", '"_S' },
  { "x", "d", '"_d' },
  { "x", "D", '"_D' },
  { "x", "c", '"_c' },
  { "x", "s", '"_s' },
}
for _, spec in ipairs(delete_maps) do
  vim.keymap.set(spec[1], spec[2], spec[3], delete_map_opts)
end
vim.keymap.set({ "n", "x" }, "P", '"dP', { noremap = true, silent = true, desc = "Paste deleted text" })

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function(event)
    if event.regname ~= "_" then
      return
    end
    if event.operator == "d" or event.operator == "c" then
      vim.fn.setreg("d", event.regcontents, event.regtype)
    end
  end,
})

-- Move to start/end of line
vim.keymap.set({ "n", "v" }, "gh", "^", { desc = "Go to start of line" })
vim.keymap.set({ "n", "v" }, "gl", "$", { desc = "Go to end of line" })

-- File navigation: picker-first workflow with nvim-tree
-- Picker-first workflow keeps navigation focused on fast file and buffer jumps.

-- nvim-tree explorer
vim.keymap.set("n", "<leader>e", function()
  vim.cmd("NvimTreeToggle")
end, { desc = "Toggle file explorer" })

vim.keymap.set("n", "<leader>E", function()
  vim.cmd("NvimTreeFindFile")
end, { desc = "Reveal current file" })

-- Project management
vim.keymap.set("n", "<leader>fp", function()
  -- Expand the path before passing to the async finder
  local projects_dir = vim.fn.expand("~/Projects")
  local dotfiles_dir = vim.fn.expand("~/dotfiles")

  Snacks.picker.projects({
    dev = { projects_dir, dotfiles_dir },
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
              if not name then
                break
              end
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

vim.keymap.set("n", "<leader>fr", function()
  Snacks.picker.recent()
end, { desc = "Recent Files" })

-- Read-only local assistant. File-changing work stays with coding agents.
vim.keymap.set("n", "<leader>al", function()
  require("config.local_assistant").ask()
end, { desc = "Ask local assistant" })
vim.keymap.set("x", "<leader>al", function()
  require("config.local_assistant").ask_selection()
end, { desc = "Ask local assistant about selection" })

-- Picker-first workflow: fast file jumping (primary navigation)
-- Use these for 90% of file navigation; avoid explorer for jumping
local function buffer_dir()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    return vim.fn.getcwd()
  end
  return vim.fn.fnamemodify(name, ":p:h")
end

vim.keymap.set("n", "<leader>ff", function()
  Snacks.picker.files()
end, { desc = "Find Files (project/cwd)" })

vim.keymap.set("n", "<leader>fF", function()
  Snacks.picker.files({ cwd = buffer_dir() })
end, { desc = "Find Files (buffer dir)" })

vim.keymap.set("n", "<leader>fg", function()
  Snacks.picker.grep()
end, { desc = "Grep (project/cwd)" })

vim.keymap.set("n", "<leader>fG", function()
  Snacks.picker.grep({ cwd = buffer_dir() })
end, { desc = "Grep (buffer dir)" })

vim.keymap.set("n", "<leader>/", function()
  Snacks.picker.grep()
end, { desc = "Grep (project/cwd)" })

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
