local M = {}

function M.setup()
  if vim.env.REX_SESSION and vim.env.REX_BLOCK then
    for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
      vim.keymap.set("n", "<C-" .. key .. ">", function()
        require("smart-splits")["move_cursor_" .. direction]()
      end, { silent = true, desc = "Navigate " .. direction .. " (Rex)" })
    end
    return
  end

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
