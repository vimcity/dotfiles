return {
  "luckasRanarison/nvim-devdocs",
  -- Lazy-load: only initialize when you actually use a command
  lazy = true,
  cmd = {
    "DevdocsFetch",
    "DevdocsInstall",
    "DevdocsUninstall",
    "DevdocsOpen",
    "DevdocsOpenFloat",
    "DevdocsOpenCurrent",
    "DevdocsOpenCurrentFloat",
    "DevdocsToggle",
    "DevdocsUpdate",
    "DevdocsUpdateAll",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    -- Don't auto-install docs on startup (prevents notification spam)
    ensure_installed = {},
    after_open = function(bufnr)
      local keymap_opts = { noremap = true, silent = true, buffer = bufnr }
      -- Scroll down with 'j' or 'd'
      vim.keymap.set("n", "j", "<C-d>", keymap_opts)
      vim.keymap.set("n", "d", "<C-d>", keymap_opts)
      -- Scroll up with 'k' or 'u'
      vim.keymap.set("n", "k", "<C-u>", keymap_opts)
      vim.keymap.set("n", "u", "<C-u>", keymap_opts)
      -- Close with 'q' or 'Esc'
      vim.keymap.set("n", "q", ":close<CR>", keymap_opts)
      vim.keymap.set("n", "<Esc>", ":close<CR>", keymap_opts)
      
      -- Auto-focus the floating window after it renders
      vim.schedule(function()
        local win_id = vim.fn.bufwinid(bufnr)
        if win_id ~= -1 then
          vim.api.nvim_set_current_win(win_id)
        end
      end)
    end,
  },
  config = function(_, opts)
    require("nvim-devdocs").setup(opts)
  end,
}
