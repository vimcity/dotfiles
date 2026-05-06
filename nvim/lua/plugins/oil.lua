return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    keymaps = {
      ["<CR>"] = {
        callback = function()
          local oil = require("oil")
          local actions = require("oil.actions")
          local util = require("oil.util")

          local entry = oil.get_cursor_entry()
          if not entry then
            return
          end

          if util.is_directory(entry) then
            actions.select.callback()
            return
          end

          local oil_bufnr = vim.api.nvim_get_current_buf()
          local oil_win = vim.api.nvim_get_current_win()
          local target_win = vim.g.oil_sidebar_target_win
          util.get_edit_path(oil_bufnr, entry, function(path)
            if target_win and vim.api.nvim_win_is_valid(target_win) then
              vim.api.nvim_set_current_win(target_win)
            end
            vim.cmd.edit(vim.fn.fnameescape(path))
            if vim.api.nvim_win_is_valid(oil_win) then
              vim.api.nvim_win_close(oil_win, true)
            end
          end)
        end,
        desc = "Open entry in previous window",
        mode = "n",
      },
      ["q"] = {
        callback = function()
          vim.api.nvim_win_close(0, true)
        end,
        desc = "Close oil sidebar",
        mode = "n",
      },
    },
    view_options = {
      show_hidden = true,
    },
    confirmation = {
      border = "rounded",
    },
    progress = {
      border = "rounded",
    },
    ssh = {
      border = "rounded",
    },
    keymaps_help = {
      border = "rounded",
    },
  },
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  lazy = false,
}
