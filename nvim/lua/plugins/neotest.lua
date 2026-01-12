-- Neotest - Modern test runner with UI
-- LazyVim provides the base config and keybindings via extras.test.core
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "rcasia/neotest-java",
    },
    opts = {
      adapters = {
        ["neotest-java"] = {},
      },
    },
  },
}
