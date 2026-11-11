local M = {}

function M.setup()
  if not (vim.env.REX_SESSION and vim.env.REX_BLOCK) then
    return
  end

  for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
    vim.keymap.set("n", "<C-" .. key .. ">", function()
      require("smart-splits")["move_cursor_" .. direction]()
    end, { silent = true, desc = "Navigate " .. direction .. " (Rex)" })
  end
end

return M
