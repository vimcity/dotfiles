return {
  {
    "nvim-orgmode/orgmode",
    event = "VeryLazy",
    ft = { "org" },
    config = function()
      local colors = {
        -- Base from Rose Pine Moon
        bg = "#232136",
        surface = "#2a273f",
        text = "#d0cbe0",
        -- Rose/Pink accents (matching rose-frappe theme)
        rose_light = "#f38ba8", -- saturated rose pink
        teal = "#85c1dc", -- soft rose
        salmon = "#f6a192", -- salmon
        rose_dark = "#eb6f92", -- darker rose
        lavender = "#c4a7e7", -- lavender
        mauve = "#ca9ee6",
        -- Utilities
        yellow = "#f6c177", -- modified, warnings
        green = "#a6da95", -- additions
        cyan = "#9ccfd8", -- types
        blue = "#89b4fa", -- comments
      }

      -- Get org path from environment variable
      local org_path = vim.fn.expand(os.getenv("ORG_PATH") or "~/Documents")

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
          TODO = ":foreground " .. colors.rose_dark .. ":weight bold",
          PROGRESS = ":foreground " .. colors.yellow .. ":weight bold",
          DONE = ":foreground " .. colors.green .. ":weight bold",
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
          -- Headline levels with rose/pink gradient
          vim.api.nvim_set_hl(0, "@org.headline.level1", { fg = colors.blue, bold = true })
          vim.api.nvim_set_hl(0, "@org.headline.level2", { fg = colors.lavender, bold = true })
          vim.api.nvim_set_hl(0, "@org.headline.level3", { fg = colors.cyan, bold = false })
          vim.api.nvim_set_hl(0, "@org.headline.level4", { fg = colors.rose_pink, bold = false })

          -- Priority markers
          vim.api.nvim_set_hl(0, "@org.priority.highest", { fg = colors.bg, bg = colors.rose_dark, bold = true })
          vim.api.nvim_set_hl(0, "@org.priority.default", { fg = colors.bg, bg = colors.yellow })
          vim.api.nvim_set_hl(0, "@org.priority.lowest", { fg = colors.bg, bg = colors.cyan })

          -- Timestamps
          vim.api.nvim_set_hl(0, "@org.timestamp.active", { fg = colors.mauve, italic = true })
          vim.api.nvim_set_hl(0, "@org.timestamp.inactive", { fg = colors.blue, italic = true })

          -- Agenda styling
          vim.api.nvim_set_hl(0, "@org.keyword.todo", { fg = colors.rose_dark, bold = true })
          vim.api.nvim_set_hl(0, "@org.keyword.done", { fg = colors.green, bold = true })
          vim.api.nvim_set_hl(0, "@org.agenda.header", { fg = colors.rose, bold = true })
          vim.api.nvim_set_hl(0, "@org.agenda.today", { fg = colors.lavender, bold = true })
          vim.api.nvim_set_hl(0, "@org.agenda.weekend", { fg = colors.blue, bold = true })
          vim.api.nvim_set_hl(0, "@org.agenda.scheduled", { fg = colors.rose_pink })
          vim.api.nvim_set_hl(0, "@org.agenda.scheduled_past", { fg = colors.blue })
          vim.api.nvim_set_hl(0, "@org.agenda.deadline", { fg = colors.rose_dark, bold = true })
          vim.api.nvim_set_hl(0, "@org.agenda.time_grid", { fg = colors.surface })
          vim.api.nvim_set_hl(0, "@org.agenda.separator", { fg = colors.surface })
          vim.api.nvim_set_hl(0, "@org.agenda.tag", { fg = colors.rose_pink, italic = true })

          -- Markup
          vim.api.nvim_set_hl(0, "@org.bold", { fg = colors.rose_light, bold = true })
          vim.api.nvim_set_hl(0, "@org.italic", { fg = colors.lavender, italic = true })

          -- Tag-specific colors
          vim.api.nvim_set_hl(0, "@org.tag", { fg = colors.cyan, bold = true })

          -- Super agenda text colors
          vim.api.nvim_set_hl(0, "OrgSuperAgendaText", { fg = colors.text })
          vim.api.nvim_set_hl(0, "OrgSuperAgendaTodo", { fg = colors.lavender, bold = true })
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
      local colors = {
        yellow = "#e99b97",
        green = "#a6da95",
        rose_dark = "#eb6f92",
      }

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
            color = colors.rose_dark,
            strike_through = false,
          },
          {
            name = "PROGRESS",
            keymap = "op",
            color = colors.yellow,
            strike_through = false,
          },
          {
            name = "DONE",
            keymap = "od",
            color = colors.green,
            strike_through = true,
          },
        },
        groups = {
          {
            name = "📋 Unscheduled",
            matcher = function(i)
              return i.todo_state ~= "DONE" and not i.scheduled and not i.deadline
            end,
            sort = { by = "headline", order = "asc" },
            header = { fg = colors.rose, bold = true },
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
