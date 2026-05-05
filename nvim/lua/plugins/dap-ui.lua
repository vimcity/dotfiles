return {
  {
    "rcarriga/nvim-dap-ui",
    cmd = { "DapContinue", "DapUiToggle" },
    opts = {
      force_close = false, -- Keeps the DAP UI open after debug ends
    },
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    cmd = { "DapContinue" },
  },
}

