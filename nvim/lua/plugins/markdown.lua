return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = true,
    opts = {},
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    ft = "markdown",
  },
  {
    "preservim/vim-markdown",
    ft = "markdown",
    init = function()
      vim.g.vim_markdown_follow_link = 1
      vim.g.vim_markdown_edit_url_in = "current_window"

      local function open_markdown_link()
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2] + 1

        local url = line:match('%[.*%]%(([^)]+)%)')
        if not url then
          url = line:match('<([^>]+)>')
        end

        if not url then
          return
        end

        if url:match('^http') then
          vim.fn.system('open ' .. url)
        else
          local current_dir = vim.fn.expand('%:p:h')
          local full_path = current_dir .. '/' .. url
          vim.api.nvim_command('edit ' .. vim.fn.fnameescape(full_path))
        end
      end

      vim.keymap.set({ "n", "v" }, "gL", open_markdown_link)
      vim.keymap.set({ "n", "v" }, "gW", "<Plug>Markdown_OpenUrlUnderCursor")
    end,
  },
}
