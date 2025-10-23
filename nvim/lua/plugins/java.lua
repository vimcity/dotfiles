-- Java customizations for LazyVim
-- LazyVim's Java extras already provides jdtls, nvim-dap, and debugging out of the box
-- Debug configurations are in .vscode/launch.json (auto-discovered by jdtls)

return {
  -- Enable hot code replace
  {
    "mfussenegger/nvim-jdtls",
    opts = {
      dap = {
        hotcodereplace = "auto",
      },
    },
  },

  -- Uncomment to add Maven keybindings
  -- {
  --   "nvim-telescope/telescope.nvim",
  --   optional = true,
  --   keys = {
  --     {
  --       "<leader>mm",
  --       function()
  --         vim.ui.select({
  --           "clean",
  --           "compile",
  --           "test",
  --           "package",
  --           "install",
  --           "verify",
  --           "clean install",
  --           "clean package",
  --           "spring-boot:run",
  --           "dependency:tree",
  --         }, {
  --           prompt = "Maven Command:",
  --         }, function(choice)
  --           if choice then
  --             vim.cmd("terminal mvn " .. choice)
  --           end
  --         end)
  --       end,
  --       desc = "Maven Commands",
  --     },
  --     {
  --       "<leader>mr",
  --       function()
  --         vim.cmd("terminal mvn spring-boot:run")
  --       end,
  --       desc = "Maven Run (Spring Boot)",
  --     },
  --     {
  --       "<leader>mt",
  --       function()
  --         vim.cmd("terminal mvn test")
  --       end,
  --       desc = "Maven Test",
  --     },
  --     {
  --       "<leader>mc",
  --       function()
  --         vim.cmd("terminal mvn clean install")
  --       end,
  --       desc = "Maven Clean Install",
  --     },
  --   },
  -- },
}
