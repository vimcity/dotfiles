-- Fix for snacks.nvim picker and terminal errors
return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>e",
      function()
        vim.cmd("NvimTreeFindFile")
      end,
      desc = "Open file explorer at current file",
    },
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
    local org_header = table.concat({
      " ██████╗ ██████╗  ██████╗ ",
      "██╔═══██╗██╔══██╗██╔════╝ ",
      "██║   ██║██████╔╝██║  ███╗",
      "██║   ██║██╔══██╗██║   ██║",
      "╚██████╔╝██║  ██║╚██████╔╝",
      " ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ",
    }, "\n")

    -- Set custom header
    if vim.env.NVIM_ORG_POPUP == "1" then
      opts.dashboard.preset = opts.dashboard.preset or {}
      opts.dashboard.preset.header = org_header
      opts.dashboard.preset.keys = {}
      opts.dashboard.sections = {
        { section = "header" },
      }
      return opts
    end

    if vim.env.NVIM_NO_DASHBOARD == "1" then
      opts.dashboard.enabled = false
      return opts
    end
    opts.dashboard.preset = opts.dashboard.preset or {}
    opts.dashboard.preset.header = header

    -- Picker configuration (primary navigation tool)
    opts.picker = vim.tbl_deep_extend("force", opts.picker or {}, {
      show_delay = 0,
      win = {
        input = {
          keys = {
            ["H"] = { "toggle_hidden", mode = { "n" } },
          },
        },
        list = {
          keys = {
            ["H"] = "toggle_hidden",
          },
        },
      },
      sources = {
        explorer = {
          win = {
            list = {
              keys = {
                ["H"] = "toggle_hidden",
              },
            },
          },
        },
        files = {
          exclude = {
            "application/**/*.js",
            "application/**/*.js.map",
          },
          win = {
            input = {
              keys = {
                ["H"] = { "toggle_hidden", mode = { "n" } },
              },
            },
          },
        },
        grep = {
          exclude = {
            "application/**/*.js",
            "application/**/*.js.map",
          },
        },
        -- Case-insensitive todo pattern: matches TODO, todo, Todo etc. with or without colon
        todo = {
          pattern = "[Tt][Oo][Dd][Oo]:?",
        },
      },
    })

    -- Image rendering
    opts.image = vim.tbl_deep_extend("force", opts.image or {}, {
      enabled = false,
    })

    return opts
  end,
}

