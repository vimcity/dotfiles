return {
  {
    "nvim-orgmode/orgmode",
    event = "VeryLazy",
    ft = { "org" },
    config = function()
      -- Setup orgmode
      require("orgmode").setup({
        org_agenda_files = "~/Documents/zorg/**/*",
        org_default_notes_file = "~/Documents/zorg/refile.org",
        org_highlight_latex_and_related = "entities",
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
        org_startup_folded = "showeverything", -- Don't fold on startup (faster)
        org_log_done = false, -- Disable logging for performance
      })

      -- Set up proper highlights for org-mode after colorscheme loads
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          -- Get Catppuccin colors
          local colors = require("catppuccin.palettes").get_palette()

          -- Define org-specific highlights
          vim.api.nvim_set_hl(0, "@org.headline.level1", { fg = colors.blue, bold = true })
          vim.api.nvim_set_hl(0, "@org.headline.level2", { fg = colors.sapphire, bold = true })
          vim.api.nvim_set_hl(0, "@org.headline.level3", { fg = colors.sky, bold = true })
          vim.api.nvim_set_hl(0, "@org.headline.level4", { fg = colors.teal, bold = true })
          vim.api.nvim_set_hl(0, "@org.headline.level5", { fg = colors.lavender, bold = true })
          vim.api.nvim_set_hl(0, "@org.headline.level6", { fg = colors.mauve, bold = true })

          vim.api.nvim_set_hl(0, "OrgTODO", { fg = colors.red, bold = true })
          vim.api.nvim_set_hl(0, "OrgDONE", { fg = colors.green, bold = true })
          vim.api.nvim_set_hl(0, "@org.keyword.todo", { fg = colors.red, bold = true })
          vim.api.nvim_set_hl(0, "@org.keyword.done", { fg = colors.green, bold = true })

          vim.api.nvim_set_hl(0, "Headline", { bg = colors.surface0 })
          vim.api.nvim_set_hl(0, "CodeBlock", { bg = colors.mantle })
          vim.api.nvim_set_hl(0, "Dash", { fg = colors.overlay0 })
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
    event = "VeryLazy",
    ft = { "org" },
    config = function()
      require("org-bullets").setup()
    end,
  },
  {
    "lukas-reineke/headlines.nvim",
    event = "VeryLazy",
    ft = { "org" },
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true,
  },
  {
    "hamidi-dev/org-super-agenda.nvim",
    event = "VeryLazy",
    ft = { "org" },
    config = function()
      require("org-super-agenda").setup({
        org_super_agenda_groups = {
          -- Urgent/Overdue (Red)
          {
            name = "   Overdue",
            overdue = true,
          },
          {
            name = "   Due Today",
            due = "today",
          },

          -- Critical Priority (Red/Urgent)
          {
            name = "   Critical [#A]",
            priority = "A",
          },

          -- Important Priority (Yellow/Important)
          {
            name = "   Important [#B]",
            priority = "B",
          },

          -- Work This Week (Blue)
          {
            name = "   Work (This Week)",
            file = "work.org",
            due = "week",
          },

          -- Life This Week (Green)
          {
            name = "   Life (This Week)",
            file = "life.org",
            due = "week",
          },

          -- Health Tasks (Purple)
          {
            name = "   Health",
            tag = "health",
          },

          -- Finance Tasks (Cyan)
          {
            name = "   Finance",
            tag = "finance",
          },

          -- Learning/Development (Magenta)
          {
            name = "   Learning",
            tag = "learning",
          },

          -- Hobbies/Personal (Pink)
          {
            name = "   Hobbies",
            tag = "hobbies",
          },

          -- Someday Tasks (Gray)
          {
            name = "   Someday",
            tag = "someday",
          },

          -- Catch-all for everything else
          {
            name = "   Everything Else",
            any = {},
          },
        },
      })
    end,
  },
  {
    "nvim-orgmode/telescope-orgmode.nvim",
    event = "VeryLazy",
    ft = { "org" },
    config = function()
      require("telescope").load_extension("orgmode")
    end,
  },
}
