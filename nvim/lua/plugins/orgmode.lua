return {
  {
    "nvim-orgmode/orgmode",
    event = "VeryLazy",
    ft = { "org" },
    config = function()
      -- Get org path from environment variable
      local org_path = vim.fn.expand(os.getenv("ORG_PATH") or "~/Documents")

      -- Check if this is a personal machine (default to personal if not set or set to 1)
      local personal_env = os.getenv("PERSONAL")
      local is_personal = personal_env == nil or personal_env == "1"

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
          template = "*** [%<%Y-%m-%d>] %<%A>\n** Reflections\n%?\n\n** Feelings\n\n** Events\n\n** Dreams",
          target = "~/Documents/zorg/journal/journal.org",
        },
      }
      -- Setup orgmode
      require("orgmode").setup({
        org_agenda_files = org_path .. "/**/*",
        org_default_notes_file = org_path .. "/refile.org",
        org_highlight_latex_and_related = "entities",
        org_todo_keyword_faces = {
          TODO = ":foreground:#8CAAEE :weight:bold", -- blue
          PROGRESS = ":foreground:#F1A7F1 :weight:bold", -- pink
          WAITING = ":foreground:#CA9EE6 :weight:bold", -- mauve
          DONE = ":foreground:#A6D854 :weight:bold", -- green
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
          local colors = require("catppuccin.palettes").get_palette()

          -- Headline levels (8 levels with gradient of colors)
          vim.api.nvim_set_hl(0, "@org.headline.level1", { fg = colors.blue, bold = true })
          vim.api.nvim_set_hl(0, "@org.headline.level2", { fg = colors.sapphire, bold = true })
          vim.api.nvim_set_hl(0, "@org.headline.level3", { fg = colors.sky, bold = true })
          vim.api.nvim_set_hl(0, "@org.headline.level4", { fg = colors.teal, bold = true })
          vim.api.nvim_set_hl(0, "@org.headline.level5", { fg = colors.lavender, bold = true })
          vim.api.nvim_set_hl(0, "@org.headline.level6", { fg = colors.mauve, bold = true })
          vim.api.nvim_set_hl(0, "@org.headline.level7", { fg = colors.pink, bold = true })
          vim.api.nvim_set_hl(0, "@org.headline.level8", { fg = colors.peach, bold = true })

          -- Priority markers
          vim.api.nvim_set_hl(0, "@org.priority.highest", { fg = colors.red, bold = true })
          vim.api.nvim_set_hl(0, "@org.priority.high", { fg = colors.yellow, bold = true })
          vim.api.nvim_set_hl(0, "@org.priority.default", { fg = colors.sapphire })
          vim.api.nvim_set_hl(0, "@org.priority.low", { fg = colors.text })

          -- Timestamps
          vim.api.nvim_set_hl(0, "@org.timestamp.active", { fg = colors.pink, italic = true })
          vim.api.nvim_set_hl(0, "@org.timestamp.inactive", { fg = colors.overlay0, italic = true })

          -- Agenda styling
          vim.api.nvim_set_hl(0, "@org.agenda.scheduled", { fg = colors.sapphire })
          vim.api.nvim_set_hl(0, "@org.agenda.deadline", { fg = colors.red })

          -- Markup
          vim.api.nvim_set_hl(0, "@org.bold", { bold = true })
          vim.api.nvim_set_hl(0, "@org.italic", { italic = true })
          vim.api.nvim_set_hl(0, "@org.strikethrough", { strikethrough = true })
          vim.api.nvim_set_hl(0, "@org.code", { fg = colors.peach, bg = colors.mantle })

          -- Blocks and dividers
          vim.api.nvim_set_hl(0, "Headline", { bg = colors.surface0 })
          vim.api.nvim_set_hl(0, "CodeBlock", { bg = colors.mantle })
          vim.api.nvim_set_hl(0, "Dash", { fg = colors.overlay0 })

          -- Tag-specific colors
          vim.api.nvim_set_hl(0, "@org.tag.work", { fg = colors.red, bold = true })
          vim.api.nvim_set_hl(0, "@org.tag.personal", { fg = colors.green, bold = true })
          vim.api.nvim_set_hl(0, "@org.tag.study", { fg = colors.blue, bold = true })
          vim.api.nvim_set_hl(0, "@org.tag.health", { fg = colors.peach, bold = true })
          vim.api.nvim_set_hl(0, "@org.tag.family", { fg = colors.pink, bold = true })
          vim.api.nvim_set_hl(0, "@org.tag.delimiter", { fg = colors.overlay0 })
        end,
      })

      -- Apply highlights immediately
      vim.cmd("doautocmd ColorScheme")
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
  -- {
  --   "lukas-reineke/headlines.nvim",
  --   -- event = "VeryLazy",
  --   ft = { "org" },
  --   dependencies = "nvim-treesitter/nvim-treesitter",
  --   config = true,
  -- },
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
            color = "#8CAAEE",
            strike_through = false,
            fields = { "filename", "todo", "headline", "priority", "date", "tags" },
          }, -- blue
          {
            name = "PROGRESS",
            keymap = "op",
            color = "#F1A7F1",
            strike_through = false,
            fields = { "filename", "todo", "headline", "priority", "date", "tags" },
          }, -- pink (active)
          {
            name = "DONE",
            keymap = "od",
            color = "#A6D854",
            strike_through = true,
            fields = { "filename", "todo", "headline", "priority", "date", "tags" },
          }, -- green
        },
        groups = {
          {
            name = "⏳ Overdue",
            matcher = function(i)
              return i.todo_state ~= "DONE"
                and ((i.deadline and i.deadline:is_past()) or (i.scheduled and i.scheduled:is_past()))
            end,
            sort = { by = "date_nearest", order = "asc" },
            header = { fg = colors.red, bold = true },
          },
          {
            name = "✅ TODO",
            matcher = function(i)
              return i.todo_state == "TODO"
            end,
            header = { fg = colors.blue, bold = true },
          },
          {
            name = "📆 Upcoming",
            matcher = function(i)
              local days = require("org-super-agenda.config").get().upcoming_days or 10
              local d1 = i.deadline and i.deadline:days_from_today()
              local d2 = i.scheduled and i.scheduled:days_from_today()
              return (d1 and d1 >= 0 and d1 <= days) or (d2 and d2 >= 0 and d2 <= days)
            end,
            sort = { by = "date_nearest", order = "asc" },
            header = { fg = colors.green, bold = true },
          },
          {
            name = "💼 Work",
            matcher = function(i)
              return i:has_tag("work")
            end,
            header = { fg = colors.red, bold = true },
          },
        },
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
