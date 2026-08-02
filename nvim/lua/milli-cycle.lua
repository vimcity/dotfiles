-- milli-cycle: cycle through all shaders + splashes to pick one for the dashboard
-- Provides: :MilliNext, :MilliPrev, :MilliShow <n>, :MilliList

local runtime = require("milli.runtime")
local registry = require("milli.registry")

-- Build ordered list: shaders first, then splashes
local ALL = {}
local SHADERS = { "doomfire", "plasma", "rain", "starfield" }
for _, name in ipairs(SHADERS) do
  table.insert(ALL, { type = "shader", name = name })
end

-- Bundled + registry-installed splashes, deduplicated, alpha sorted
local seen = {}
local splash_names = {}
for _, name in ipairs(require("milli").list()) do
  if not seen[name] then
    seen[name] = true
    table.insert(splash_names, name)
  end
end
table.sort(splash_names)
for _, name in ipairs(splash_names) do
  table.insert(ALL, { type = "splash", name = name })
end

local total = #ALL
local current = 1

local function show(idx, buf)
  buf = buf or vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.api.nvim_buf_set_name(buf, string.format("milli://[%d/%d] %s", idx, total, ALL[idx].name))
  vim.cmd("buffer! " .. buf)

  for _, k in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", k, "<cmd>bwipeout<cr>", { buffer = buf, nowait = true, silent = true })
  end

  if ALL[idx].type == "shader" then
    runtime.play_shader(buf, { shader = ALL[idx].name })
  else
    vim.bo[buf].modifiable = true
    local data = runtime.load({ splash = ALL[idx].name })
    if data and data.frames and #data.frames > 0 then
      local frame = data.frames[1]
      local win_w = vim.api.nvim_win_get_width(0)
      local win_h = vim.api.nvim_win_get_height(0)
      local cols = data.cols or 0
      if cols == 0 then
        for _, line in ipairs(frame) do
          if vim.fn.strdisplaywidth(line) > cols then cols = vim.fn.strdisplaywidth(line) end
        end
      end
      local left_pad = math.max(0, math.floor((win_w - cols) / 2))
      local top_pad = math.max(0, math.floor((win_h - #frame) / 2))
      local lines = {}
      for _ = 1, top_pad do table.insert(lines, "") end
      for _, line in ipairs(frame) do
        table.insert(lines, string.rep(" ", left_pad) .. line)
      end
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    end
    vim.bo[buf].modified = false
    vim.bo[buf].modifiable = false
    runtime.play(buf, { splash = ALL[idx].name, loop = true })
  end
end

vim.api.nvim_create_user_command("MilliNext", function()
  current = (current % total) + 1
  show(current)
end, { desc = "Show next milli splash/shader" })

vim.api.nvim_create_user_command("MilliPrev", function()
  current = ((current - 2 + total) % total) + 1
  show(current)
end, { desc = "Show previous milli splash/shader" })

vim.api.nvim_create_user_command("MilliShow", function(params)
  local n = tonumber(params.args)
  if not n or n < 1 or n > total then
    vim.notify(string.format("milli: index 1-%d", total), vim.log.levels.ERROR)
    return
  end
  current = n
  show(current)
end, {
  nargs = 1,
  desc = "Show milli item by index",
})

vim.api.nvim_create_user_command("MilliList", function()
  local lines = {}
  for i, item in ipairs(ALL) do
    local marker = i == current and " >" or "  "
    table.insert(lines, string.format("%s[%3d] %-18s (%s)", marker, i, item.name, item.type))
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end, { desc = "List all milli items with indices" })