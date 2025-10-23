return {
  "rest-nvim/rest.nvim",
  ft = "http", -- Only load when opening .http files
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, "http")
      end,
    },
  },
  config = function()
    require("rest-nvim").setup({
      result_split_horizontal = false,
      result_split_in_place = false,
      skip_ssl_verification = false,
      encode_url = true,
      highlight = {
        enabled = true,
        timeout = 150,
      },
      -- Environment variables
      env_file = ".env",
      env_pattern = ".*%.env.*",
      env_edit_command = "tabedit",
      -- Custom dynamic variables for automatic OAuth tokens
      custom_dynamic_variables = {
        ["$token_pacman"] = function()
          local handle = io.popen("cd ~/Projects/http-collections && ./.rest-nvim/token-manager.sh pacman 2>&1")
          if not handle then return "" end
          local token = handle:read("*a")
          handle:close()
          return token:gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
        end,
        ["$token_reps"] = function()
          local handle = io.popen("cd ~/Projects/http-collections && ./.rest-nvim/token-manager.sh reps 2>&1")
          if not handle then return "" end
          local token = handle:read("*a")
          handle:close()
          return token:gsub("^%s*(.-)%s*$", "%1")
        end,
        ["$token_csapi"] = function()
          local handle = io.popen("cd ~/Projects/http-collections && ./.rest-nvim/token-manager.sh csapi 2>&1")
          if not handle then return "" end
          local token = handle:read("*a")
          handle:close()
          return token:gsub("^%s*(.-)%s*$", "%1")
        end,
        ["$token_order"] = function()
          local handle = io.popen("cd ~/Projects/http-collections && ./.rest-nvim/token-manager.sh order 2>&1")
          if not handle then return "" end
          local token = handle:read("*a")
          handle:close()
          return token:gsub("^%s*(.-)%s*$", "%1")
        end,
        ["$token_notifications"] = function()
          local handle = io.popen("cd ~/Projects/http-collections && ./.rest-nvim/token-manager.sh notifications 2>&1")
          if not handle then return "" end
          local token = handle:read("*a")
          handle:close()
          return token:gsub("^%s*(.-)%s*$", "%1")
        end,
      },
    })
  end,
  keys = {
    { "<leader>rr", "<cmd>Rest run<cr>", desc = "Run request under cursor" },
    { "<leader>rl", "<cmd>Rest run last<cr>", desc = "Run last request" },
  },
}
