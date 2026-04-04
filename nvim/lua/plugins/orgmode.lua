return {
  {
    "nvim-orgmode/orgmode",
    event = "VeryLazy",
    ft = { "org" },
    config = function()
      local colors = {
        base = "#191724",
        surface = "#1f1d2e",
        overlay = "#6e6a86",
        muted = "#908caa",
        subtle = "#e0def4",
        love = "#eb6f92",
        gold = "#f6c177",
        leaf = "#a6d189",
        rose = "#ebbcba",
        pine = "#31748f",
        foam = "#9ccfd8",
        iris = "#c4a7e7",
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
          PROGRESS = ":foreground " .. colors.gold .. ":weight bold",
          DONE = ":foreground " .. colors.leaf .. ":weight bold",
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
          local omarchy_blue = "#8CA0E8"
          -- Headline levels (8 levels with gradient of colors)
          vim.api.nvim_set_hl(0, "@org.headline.level1", { fg = omarchy_blue, bold = true })
          vim.api.nvim_set_hl(0, "@org.headline.level2", { fg = colors.iris, bold = true })
          vim.api.nvim_set_hl(0, "@org.headline.level3", { fg = colors.foam, bold = false })
          vim.api.nvim_set_hl(0, "@org.headline.level4", { fg = colors.rose, bold = false })
          --
          -- -- Priority markers
          -- vim.api.nvim_set_hl(0, "@org.priority.highest", { fg = colors.love, bold = true })
          vim.api.nvim_set_hl(0, "@org.priority.default", { fg = colors.base, bg = colors.gold })
          vim.api.nvim_set_hl(0, "@org.priority.lowest", { fg = colors.base, bg = colors.pine })
          --
          -- -- Timestamps
          vim.api.nvim_set_hl(0, "@org.timestamp.active", { fg = colors.foam, italic = true })
          vim.api.nvim_set_hl(0, "@org.timestamp.inactive", { fg = colors.overlay, italic = true })
          --
          -- -- Agenda styling
          vim.api.nvim_set_hl(0, "@org.agenda.scheduled", { fg = colors.rose })
          -- vim.api.nvim_set_hl(0, "@org.agenda.scheduled_past", { fg = colors.rose, bold = true })
          vim.api.nvim_set_hl(0, "@org.agenda.deadline", { fg = colors.love, bold = true })
          --
          -- -- Markup
          vim.api.nvim_set_hl(0, "@org.bold", { fg = colors.rose, bold = true })
          vim.api.nvim_set_hl(0, "@org.italic", { fg = colors.iris, italic = true })
          -- vim.api.nvim_set_hl(0, "@org.strikethrough", { strikethrough = true })
          -- vim.api.nvim_set_hl(0, "@org.code", { fg = colors.gold, bg = colors.surface })
          --
          -- -- Blocks and dividers
          -- vim.api.nvim_set_hl(0, "Headline", { bg = colors.surface })
          -- vim.api.nvim_set_hl(0, "CodeBlock", { bg = colors.surface })
          -- vim.api.nvim_set_hl(0, "Dash", { fg = colors.overlay })
          --
          -- -- Tag-specific colors
          vim.api.nvim_set_hl(0, "@org.tag", { fg = colors.foam, bold = true })
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
        gold = "#f6c177",
        leaf = "#a6d189",
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
            color = "#eb6f92",
            strike_through = false,
          },
          {
            name = "PROGRESS",
            keymap = "op",
            color = "#f6c177",
            strike_through = false,
          },
          {
            name = "DONE",
            keymap = "od",
            color = colors.leaf,
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
