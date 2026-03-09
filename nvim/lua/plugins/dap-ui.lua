return {
  {
    "rcarriga/nvim-dap-ui",
    opts = function(_, opts)
      opts.force_close = false -- Keep DAP UI open after debug ends

      if opts.layouts and opts.layouts[2] and opts.layouts[2].position == "bottom" then
        opts.layouts[2].elements = {
          { id = "repl", size = 1.0 },
        }
      end

      local dap = require("dap")
      local dapui = require("dapui")

      dap.listeners.after.event_initialized["dapui_console_float"] = function()
        vim.schedule(function()
          dapui.float_element("console", {
            border = "single",
            enter = false,
            width = math.floor(vim.o.columns * 0.7),
            height = math.floor(vim.o.lines * 0.35),
          })
        end)
      end
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
  },
}
