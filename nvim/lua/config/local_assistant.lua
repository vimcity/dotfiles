local M = {}

local function ask_path()
  return vim.fn.expand("~/dotfiles/bin/ask")
end

local function show_result(content)
  local width = math.max(60, math.floor(vim.o.columns * 0.78))
  local height = math.max(16, math.floor(vim.o.lines * 0.72))
  width = math.min(width, vim.o.columns - 4)
  height = math.min(height, vim.o.lines - 4)

  local buffer = vim.api.nvim_create_buf(false, true)
  vim.bo[buffer].buftype = "nofile"
  vim.bo[buffer].bufhidden = "wipe"
  vim.bo[buffer].filetype = "markdown"
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(content, "\n", { plain = true }))
  vim.bo[buffer].modifiable = false

  local window = vim.api.nvim_open_win(buffer, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " Local Assistant ",
    title_pos = "center",
  })
  vim.wo[window].wrap = true
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buffer, silent = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buffer, silent = true })
end

local function selected_text()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.api.nvim_buf_get_text(
    0,
    start_pos[2] - 1,
    math.max(start_pos[3] - 1, 0),
    end_pos[2] - 1,
    end_pos[3],
    {}
  )
  return table.concat(lines, "\n")
end

local function run(prompt, context)
  if vim.fn.executable(ask_path()) ~= 1 then
    vim.notify("Local assistant unavailable: " .. ask_path(), vim.log.levels.ERROR)
    return
  end

  local args = { ask_path() }
  local options = { text = true }
  if context and context ~= "" then
    table.insert(args, "--stdin")
    options.stdin = context
  end
  table.insert(args, prompt)

  vim.notify("Asking local assistant...", vim.log.levels.INFO)
  vim.system(args, options, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        local message = result.stderr ~= "" and result.stderr or "Local assistant failed"
        vim.notify(vim.trim(message), vim.log.levels.ERROR)
        return
      end
      show_result(vim.trim(result.stdout))
    end)
  end)
end

function M.ask()
  vim.ui.input({ prompt = "Ask local assistant: " }, function(prompt)
    if prompt and prompt ~= "" then
      run(prompt)
    end
  end)
end

function M.ask_selection()
  local context = selected_text()
  vim.ui.input({ prompt = "Ask about selection: ", default = "Explain this clearly and concisely." }, function(prompt)
    if prompt and prompt ~= "" then
      run(prompt, context)
    end
  end)
end

return M
