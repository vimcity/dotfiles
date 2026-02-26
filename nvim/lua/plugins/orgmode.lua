return {
  {
    "nvim-orgmode/orgmode",
    event = "VeryLazy",
    ft = { "org" },
    config = function()
      -- Get org path from environment variable
      local org_path = vim.fn.expand(os.getenv("ORG_PATH") or "~/Documents")
      local colors = require("catppuccin.palettes").get_palette()

      -- Setup org capture templates
      local capture_templates
      capture_templates = {
        t = {
          description = "Todo",
          template = "* TODO %?\n  SCHEDULED: %^t",
          target = org_path .. "/todos.org",
        },
        i = {
          description = "Idea",
          template = "* %?\n  %U",
          target = org_path .. "/ideas-organized.org",
        },
        j = {
          description = "Journal",
          template = "* [%<%Y-%m-%d>] %<%A>\n** Reflections\n%?\n\n** Feelings\n\n** Events\n\n",
          target = org_path .. "/journal/journal.org",
        },
      }
      -- Setup orgmode
      require("orgmode").setup({
        org_agenda_files = org_path .. "/**/*",
        org_default_notes_file = org_path .. "/todos.org",
        org_highlight_latex_and_related = "entities",
        org_agenda_span = "day",
        org_todo_keywords = { "TODO", "PROGRESS", "|", "DONE" },
        org_todo_keyword_faces = {
          PROGRESS = ":foreground " .. colors.yellow .. ":weight bold", -- pink
        },
        org_capture_templates = capture_templates,
        mappings = {
          org_return_uses_meta_return = true,
          org = {
            org_toggle_checkbox = "<C-y>",
          },
        },
        ui = {
          fold = {
            enable = true,
          },
        },
        -- Performance optimizations
        org_startup_folded = "showeverything",
        org_log_done = true,
        org_log_done_repeat_create_time = true,
      })

      -- Set up proper highlights for org-mode after colorscheme loads
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          -- Get Catppuccin colors

          -- Headline levels (8 levels with gradient of colors)
          vim.api.nvim_set_hl(0, "@org.headline.level1", { fg = colors.blue, bold = true })
          vim.api.nvim_set_hl(0, "@org.headline.level2", { fg = colors.sapphire, bold = true })
          vim.api.nvim_set_hl(0, "@org.headline.level3", { fg = colors.lavender, bold = true })
          vim.api.nvim_set_hl(0, "@org.headline.level4", { fg = colors.pink, bold = true })

          --
          -- -- Priority markers
          -- vim.api.nvim_set_hl(0, "@org.priority.highest", { fg = colors.red, bold = true })
          vim.api.nvim_set_hl(0, "@org.priority.default", { fg = colors.base, bg = colors.yellow })
          vim.api.nvim_set_hl(0, "@org.priority.lowest", { fg = colors.base, bg = colors.blue })
          --
          -- -- Timestamps
          -- vim.api.nvim_set_hl(0, "@org.timestamp.active", { fg = colors.pink, italic = true })
          -- vim.api.nvim_set_hl(0, "@org.timestamp.inactive", { fg = colors.overlay0, italic = true })
          --
          -- -- Agenda styling
          vim.api.nvim_set_hl(0, "@org.agenda.scheduled", { fg = colors.blue })
          -- vim.api.nvim_set_hl(0, "@org.agenda.scheduled_past", { fg = colors.blue, bold = true })
          vim.api.nvim_set_hl(0, "@org.agenda.deadline", { fg = colors.red, bold = true })
          --
          -- -- Markup
          vim.api.nvim_set_hl(0, "@org.bold", { fg = colors.maroon, bold = true })
          vim.api.nvim_set_hl(0, "@org.italic", { fg = colors.mauve, italic = true })
          -- vim.api.nvim_set_hl(0, "@org.strikethrough", { strikethrough = true })
          -- vim.api.nvim_set_hl(0, "@org.code", { fg = colors.peach, bg = colors.mantle })
          -- Org buffer default text color
          -- vim.api.nvim_set_hl(0, "OrgNormal", { fg = , bg = colors.base })
          vim.api.nvim_set_hl(0, "OrgQuoteText", { fg = colors.subtext1, italic = true })
          --
          -- -- Blocks and dividers
          -- vim.api.nvim_set_hl(0, "Headline", { bg = colors.surface0 })
          -- vim.api.nvim_set_hl(0, "CodeBlock", { bg = colors.mantle })
          -- vim.api.nvim_set_hl(0, "Dash", { fg = colors.overlay0 })
          --
          -- -- Tag-specific colors (all purple/mauve)
          vim.api.nvim_set_hl(0, "@org.tag", { fg = colors.teal, bold = true })
        end,
      })

      -- Apply highlights immediately
      vim.cmd("doautocmd ColorScheme")

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "org",
        callback = function()
          -- vim.opt_local.winhighlight:append("Normal:OrgNormal")
          vim.cmd([[syntax match OrgQuoteText /"[^"\r\n]\+"/]])
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Add org to the list of installed parsers
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "org" })
      end
    end,
  },
  {
    "akinsho/org-bullets.nvim",
    -- event = "VeryLazy",
    ft = { "org" },
    config = function()
      require("org-bullets").setup()
    end,
  },
  {
    "hamidi-dev/org-super-agenda.nvim",
    -- event = "VeryLazy",
    ft = { "org" },
    config = function()
      -- Get org path from environment variable
      local org_path = vim.fn.expand(os.getenv("ORG_PATH") or "~/Documents")

      -- Get Catppuccin colors
      local colors = require("catppuccin.palettes").get_palette()

      require("org-super-agenda").setup({
        org_directories = { org_path },
        exclude_directories = {
          org_path .. "/deep-stash/",
          org_path .. "/stocks/",
          org_path .. "/projects/",
        },
        todo_states = {
          {
            name = "TODO",
            keymap = "ot",
            color = "#E78284",
            strike_through = false,
          }, -- red
          {
            name = "PROGRESS",
            keymap = "op",
            color = "#F1A7F1",
            strike_through = false,
          }, -- pink
          {
            name = "DONE",
            keymap = "od",
            color = "#A6D854",
            strike_through = true,
          }, -- green
        },
        groups = {
          {
            name = "📋 Unscheduled",
            matcher = function(i)
              return i.todo_state ~= "DONE" and not i.scheduled and not i.deadline
            end,
            sort = { by = "headline", order = "asc" },
            header = { fg = colors.yellow, bold = true },
          },
        },
        view_mode = "compact",
      })

      -- Set up keybinding for org-super-agenda
      vim.keymap.set("n", "<leader>os", "<cmd>OrgSuperAgenda<cr>", { desc = "open org super agenda" })
    end,
  },
  {
    "nvim-orgmode/telescope-orgmode.nvim",
    dependencies = "nvim-telescope/telescope.nvim",
  },
}
