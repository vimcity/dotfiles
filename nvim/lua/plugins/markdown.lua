return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    -- Do not lazy-load on ft: FileType already fired before attach runs.
    event = "VeryLazy",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      file_types = { "markdown", "markdown.mdx" },
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      heading = {
        sign = false,
        width = "full",
        position = "overlay",
      },
      checkbox = {
        enabled = true,
      },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)

      -- Session restore can open markdown before VeryLazy; attach those buffers.
      local manager = require("render-markdown.core.manager")
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "markdown" then
          manager.attach(buf)
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_render_markdown", { clear = true }),
        pattern = { "markdown", "markdown.mdx" },
        callback = function(args)
          vim.schedule(function()
            manager.attach(args.buf)
          end)
        end,
      })

      vim.schedule(function()
        local ok, snacks = pcall(require, "snacks")
        if ok and snacks.toggle then
          snacks.toggle({
            name = "Render Markdown",
            get = require("render-markdown").get,
            set = require("render-markdown").set,
          }):map("<leader>um")
        end
      end)
    end,
  },
  {
    "cavanaug/render-markdown-mermaid.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "MeanderingProgrammer/render-markdown.nvim",
    },
    opts = {
      mode = "unicode",
      placement = "above",
      auto_setup_render_markdown = false,
      render_markdown = {
        file_types = { "markdown", "markdown.mdx" },
      },
    },
    config = function(_, opts)
      require("render-markdown-mermaid").setup(opts)
    end,
  },
  {
    "preservim/vim-markdown",
    ft = "markdown",
    init = function()
      vim.g.vim_markdown_follow_link = 1
      vim.g.vim_markdown_edit_url_in = "current_window"
      vim.g.vim_markdown_folding_disabled = 1

      local function open_markdown_link()
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2] + 1

        local url = line:match("%[.*%]%(([^)]+)%)")
        if not url then
          url = line:match("<([^>]+)>")
        end

        if not url then
          return
        end

        if url:match("^http") then
          vim.fn.system("open " .. url)
        else
          local current_dir = vim.fn.expand("%:p:h")
          local full_path = current_dir .. "/" .. url
          vim.api.nvim_command("edit " .. vim.fn.fnameescape(full_path))
        end
      end

      vim.keymap.set({ "n", "v" }, "gL", open_markdown_link)
      vim.keymap.set({ "n", "v" }, "gW", "<Plug>Markdown_OpenUrlUnderCursor")
    end,
  },
}