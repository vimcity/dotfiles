-- Fix for snacks.nvim picker and terminal errors
return {
  "folke/snacks.nvim",
  keys = {
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
    opts.dashboard = opts.dashboard or {}
    opts.dashboard.preset = opts.dashboard.preset or {}
    opts.dashboard.preset.header = header

    -- Remove the "Projects (util.project)" key that uses Shift+P
    if opts.dashboard.preset.keys then
      opts.dashboard.preset.keys = vim.tbl_filter(function(key)
        return not (key.key == "P" and key.desc and key.desc:match("util%.project"))
      end, opts.dashboard.preset.keys)
    end

    -- Picker configuration
    opts.picker = vim.tbl_deep_extend("force", opts.picker or {}, {
      show_delay = 0,
      sources = {
        explorer = {
          hidden = true, -- Show hidden files (dotfiles)
          ignored = true, -- Show gitignored files
        },
      },
    })

    -- Image rendering
    opts.image = vim.tbl_deep_extend("force", opts.image or {}, {
      enabled = true,
    })

    return opts
  end,
}
