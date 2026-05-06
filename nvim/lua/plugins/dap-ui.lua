return {
  {
    "rcarriga/nvim-dap-ui",
    cmd = { "DapContinue", "DapUiToggle" },
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup(opts)
      dap.defaults.fallback.terminal_win_cmd = "tabnew"

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({})
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close({})
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close({})
      end
    end,
    opts = {
      force_close = false, -- Keeps the DAP UI open after debug ends
    },
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    cmd = { "DapContinue" },
  },
}
