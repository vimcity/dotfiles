-- SonarQube LSP integration for real-time code analysis
-- Uses sonarlint-language-server installed via Mason
return {
  "iamkarasik/sonarqube.nvim",
  event = "VeryLazy", -- Load after startup
  config = function()
    -- Path to Mason-installed sonarlint-language-server
    local mason_path = vim.fn.stdpath("data") .. "/mason/packages/sonarlint-language-server"
    local extension_path = mason_path .. "/extension"

    require("sonarqube").setup({
      lsp = {
        -- Command to start sonarlint language server
        cmd = {
          vim.fn.exepath("java"), -- Use system Java
          "-jar",
          extension_path .. "/server/sonarlint-ls.jar",
          "-stdio",
          "-analyzers",
          -- Only include analyzers for languages we use
          extension_path .. "/analyzers/sonarjava.jar", -- Java
          extension_path .. "/analyzers/sonarjavasymbolicexecution.jar", -- Java security
          extension_path .. "/analyzers/sonarjs.jar", -- JavaScript/TypeScript
        },

        -- Log level (OFF, ERROR, WARN, INFO, DEBUG)
        log_level = "OFF", -- Change to INFO or DEBUG for troubleshooting

        -- Settings for SonarQube connection
        settings = {
          sonarlint = {
            -- Connected Mode: Sync with your company's SonarQube server
            -- Uncomment and configure to enable:
            connectedMode = {
              connections = {
                sonarqube = {
                  {
                    connectionId = "project-sonar-config",
                    serverUrl = os.getenv("SONAR_URL"), -- Store URL in env var
                    token = os.getenv("SONAR_TOKEN"), -- Store token in env var
                  }
                }
              },
              -- Map projects to connections
              project = {
                projectKey = os.getenv("SONAR_PROJECT_PREFIX") .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t"), -- Prefix + directory name
                connectionId = "project-sonar-config",
              }
            }
          }
        },

        -- Custom handlers
        handlers = {
          -- Open rule description in browser (SonarSource docs)
          ["sonarlint/showRuleDescription"] = function(err, res, ctx, cfg)
            local uri = "https://rules.sonarsource.com/%s/RSPEC-%s"
            local lang = res.languageKey
            local spec = string.match(res.key, "S(%d+)")
            if spec then
              vim.ui.open(string.format(uri, lang, spec))
            end
          end,
          
          -- Suppress IDE Labs warning (optional SonarSource feature)
          ["sonarlint/hasJoinedIdeLabs"] = function()
            return false
          end,
        },
      },

      -- Rule configuration
      rules = {
        enabled = true,

        -- Disable noisy rules (add more as you find them)
        -- These are common false positives for logging/debugging

        -- String literals duplicated (noisy for logging statements)
        ["java:S1192"] = { enabled = false },

        -- Standard outputs (System.out/err) - OK for debugging
        ["java:S106"] = { enabled = false },

        -- TODO comments - team decision on when to fix
        ["java:S1135"] = { enabled = false },

        -- Adjust line length if needed (default: 180)
        -- ["java:S103"] = { enabled = true, parameters = { maximumLineLength = 120 } },
      },

      -- Language analyzers
      java = {
        enabled = true,
        await_jdtls = true, -- Wait for jdtls to start before analyzing
      },

      javascript = {
        enabled = true, -- Also handles TypeScript
        clientNodePath = vim.fn.exepath("node"), -- Auto-detect node
      },

      -- Disabled languages (uncomment if needed)
      go = { enabled = false },
      html = { enabled = false },
      iac = { enabled = false },
      php = { enabled = false },
      python = { enabled = false },
      text = { enabled = false },
      xml = { enabled = false },
      
      -- CRITICAL: Disable C# to prevent path errors
      csharp = { 
        enabled = false  -- We don't use C#, and it's looking in wrong directory
      },
    })
  end,

  -- Optional: Add keymaps for SonarQube commands
  keys = {
    {
      "<leader>cq",
      ":SonarQubeListAllRules<CR>",
      desc = "SonarQube: List all rules",
    },
    {
      "<leader>cQ",
      ":SonarQubeShowConfig<CR>",
      desc = "SonarQube: Show config",
    },
  },
  
  -- Note: Color customization removed for simplicity
  -- SonarQube warnings show in default yellow (same as LSP warnings)
  -- To customize colors in the future, see: ~/dotfiles/nvim/SONARQUBE_NO_DUPLICATES.md
}
