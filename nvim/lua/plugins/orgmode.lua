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
      })

      -- NOTE: If you are using nvim-treesitter with ~ensure_installed = "all"~ option
      -- add ~org~ to ignore_install
      -- require('nvim-treesitter.configs').setup({
      --   ensure_installed = 'all',
      --   ignore_install = { 'org' },
      -- })
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
      require("org-bullets").setup({
        concealcursor = false,
        symbols = {
          headlines = { "◉", "○", "✸", "✿" },
          checkboxes = {
            half = { "◐", "@org.checkbox.halfchecked" },
            done = { "✓", "@org.keyword.done" },
            todo = { "◯", "@org.keyword.todo" },
          },
        },
      })
    end,
  },
  {
    "lukas-reineke/headlines.nvim",
    event = "VeryLazy",
    ft = { "org" },
    config = function()
      require("headlines").setup({
        org = {
          headline_highlights = { "Headline1", "Headline2", "Headline3", "Headline4", "Headline5", "Headline6" },
          codeblock_highlight = "CodeBlock",
          dash_highlight = "Dash",
          quote_highlight = "Quote",
          fat_headlines = true,
          fat_headline_upper_string = "▃",
          fat_headline_lower_string = "▂",
        },
      })
    end,
  },
  {
    "hamidi-dev/org-super-agenda.nvim",
    event = "VeryLazy",
    ft = { "org" },
    config = function()
      require("org-super-agenda").setup({
        -- Default settings
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
