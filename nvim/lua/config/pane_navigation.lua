local M = {}

function M.setup()
  if vim.fn.executable("herdr-app") ~= 1 then
    return
  end

  local directions = {
    h = { name = "left", window = "h" },
    j = { name = "down", window = "j" },
    k = { name = "up", window = "k" },
    l = { name = "right", window = "l" },
  }

  for key, direction in pairs(directions) do
    vim.keymap.set("n", "<C-" .. key .. ">", function()
      local before = vim.api.nvim_get_current_win()
      vim.cmd("noautocmd wincmd " .. direction.window)
      if vim.api.nvim_get_current_win() == before then
        vim.fn.jobstart({ "herdr-app", "do", "pane.go", "--direction", direction.name }, { detach = true })
      end
    end, { silent = true, desc = "Navigate " .. direction.name .. " (Herdr app)" })
  end
end

return M
