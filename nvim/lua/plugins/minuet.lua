return {
  {
    "milanglacier/minuet-ai.nvim",
    enabled = false,
    event = "InsertEnter",
    cmd = { "Minuet", "MinuetStatus", "MinuetDebug" },
    opts = {
      provider = "openai_compatible",
      request_timeout = 20,
      throttle = 1000,
      debounce = 500,
      notify = "warn",
      n_completions = 1,
      context_window = 4096,
      provider_options = {
        openai_compatible = {
          api_key = "TERM",
          end_point = "http://localhost:8000/v1/chat/completions",
          model = "gemma-4-12B-it-OptiQ-4bit",
          name = "Omlx",
          optional = {
            num_ctx = 8192,
            max_tokens = 512,
            top_p = 0.9,
            thinking = { type = "disabled" },
          },
        },
      },
      virtualtext = {
        auto_trigger_ft = { "*" },
        auto_trigger_ignore_ft = {
          "alpha",
          "dashboard",
          "fugitive",
          "gitcommit",
          "gitrebase",
          "help",
          "lazy",
          "markdown",
          "mason",
          "neo-tree",
          "oil",
          "snacks_input",
          "snacks_notif",
          "TelescopePrompt",
        },
        -- Show ghost text even when blink's LSP popup is open.
        show_on_completion_menu = true,
        keymap = {
          accept = nil,
          accept_line = nil,
          accept_n_lines = nil,
          next = nil,
          prev = nil,
          dismiss = nil,
        },
      },
    },
    config = function(_, opts)
      require("minuet").setup(opts)

      local vt = require("minuet.virtualtext")
      local debug_enabled = false
      local last_event = "idle"

      local function hide_completion_menus()
        if vim.fn.pumvisible() == 1 then
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-e>", true, true, true), "n", false)
        end

        local ok, blink = pcall(require, "blink.cmp")
        if ok and blink.is_visible() then
          blink.hide()
        end
      end

      local function run_trigger()
        hide_completion_menus()
        vt.action.dismiss()
        vt.action.next()
      end

      local function trigger_minuet()
        if vim.fn.mode():match("^[iR]") then
          run_trigger()
          return
        end

        vim.cmd.startinsert()
        vim.defer_fn(function()
          if vim.fn.mode() ~= "i" then
            vim.notify("Minuet: could not enter insert mode", vim.log.levels.WARN)
            return
          end
          run_trigger()
        end, 20)
      end

      vim.api.nvim_create_user_command("MinuetStatus", function()
        local blink_visible = false
        local ok, blink = pcall(require, "blink.cmp")
        if ok then
          blink_visible = blink.is_visible()
        end

        vim.notify(
          table.concat({
            "Minuet status",
            "  mode: " .. vim.fn.mode(),
            "  last event: " .. last_event,
            "  ghost visible: " .. tostring(vt.action.is_visible()),
            "  auto trigger: " .. tostring(vim.b.minuet_virtual_text_auto_trigger),
            "  blink visible: " .. tostring(blink_visible),
            "  pum visible: " .. tostring(vim.fn.pumvisible() == 1),
            "  filetype: " .. vim.bo.filetype,
          }, "\n"),
          vim.log.levels.INFO
        )
      end, { desc = "Show Minuet virtualtext status" })

      vim.api.nvim_create_user_command("MinuetDebug", function(opts)
        local action = opts.args ~= "" and opts.args or "toggle"
        if action == "on" then
          debug_enabled = true
        elseif action == "off" then
          debug_enabled = false
        else
          debug_enabled = not debug_enabled
        end

        require("minuet").config.notify = debug_enabled and "debug" or "warn"
        vim.notify("Minuet debug " .. (debug_enabled and "enabled" or "disabled"), vim.log.levels.INFO)
      end, {
        desc = "Toggle Minuet debug notifications",
        nargs = "?",
        complete = function()
          return { "on", "off", "toggle" }
        end,
      })

      for _, event in ipairs({ "MinuetRequestStartedPre", "MinuetRequestStarted", "MinuetRequestFinished" }) do
        vim.api.nvim_create_autocmd("User", {
          pattern = event,
          callback = function(ev)
            last_event = event
            if debug_enabled then
              vim.notify(("[Minuet] %s %s"):format(event, vim.inspect(ev.data)), vim.log.levels.INFO)
            end
          end,
        })
      end

      -- Insert: Alt chords (fast, no leader timeout). Normal: leader>as (AI group, matches CodeCompanion).
      vim.keymap.set("i", "<A-y>", trigger_minuet, { desc = "AI completion invoke" })
      vim.keymap.set("i", "<A-CR>", function()
        vt.action.accept()
      end, { desc = "AI completion accept" })
      vim.keymap.set("i", "<A-.>", vt.action.accept_line, { desc = "AI completion accept line" })
      vim.keymap.set("i", "<A-e>", vt.action.dismiss, { desc = "AI completion dismiss" })
      vim.keymap.set("i", "<A-n>", vt.action.next, { desc = "AI completion next" })
      vim.keymap.set("i", "<A-p>", vt.action.prev, { desc = "AI completion prev" })

      vim.keymap.set("n", "<leader>as", trigger_minuet, { desc = "AI completion invoke" })
      vim.keymap.set({ "n", "i" }, "<leader>ct", vt.action.toggle_auto_trigger, { desc = "AI completion toggle auto" })
    end,
  },
}
