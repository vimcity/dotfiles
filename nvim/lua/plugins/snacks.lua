-- Fix for snacks.nvim picker and terminal errors
return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>n",
      function()
        Snacks.notifier.show_history()
      end,
      desc = "Notification History",
    },
    {
      "<leader>gb",
      function()
        Snacks.git.blame_line()
      end,
      desc = "Git Blame Line",
    },
    {
      "<leader>gB",
      function()
        Snacks.gitbrowse()
      end,
      desc = "Git Browse",
    },
  },
  opts = function(_, opts)
    opts.scroll.enabled = false
    local ascii = require("ascii")
    local header = table.concat(ascii.art.text.neovim.sharp, "\n")

    -- Set custom header
    opts.dashboard.preset = opts.dashboard.preset or {}
    opts.dashboard.preset.header = header

    -- Picker configuration
    opts.picker = vim.tbl_deep_extend("force", opts.picker or {}, {
      show_delay = 0,
      sources = {
        explorer = {
          hidden = true, -- Show hidden files (dotfiles)
          ignored = true, -- Respect gitignore, fd-ignore, and rg-ignore files
        },
        -- Exclude TS-compiled JS artifacts from file and grep pickers.
        -- Only targets application/ where TS compilation outputs live;
        -- intentional JS files (webpack configs, assets/lib, etc.) are unaffected.
        files = {
          exclude = {
            "application/**/*.js",
            "application/**/*.js.map",
          },
        },
        grep = {
          exclude = {
            "application/**/*.js",
            "application/**/*.js.map",
          },
        },
      },
    })

    -- Image rendering
    opts.image = vim.tbl_deep_extend("force", opts.image or {}, {
      enabled = false,
    })

    -- Override dashboard header ASCII art color to match prompt dir color
    vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = "#7287fd" })
    vim.api.nvim_set_hl(0, "SnacksDashboardKey", { fg = "#9ccfd8" })
    vim.api.nvim_set_hl(0, "SnacksDashboardDesc", { fg = "#ca9ee6" })
    vim.api.nvim_set_hl(0, "SnacksDashboardIcon", { fg = "#7287fd" })
    return opts
  end,
}
