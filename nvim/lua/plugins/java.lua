-- Java customizations for LazyVim
-- LazyVim's Java extras already provides jdtls, nvim-dap, and debugging out of the box
-- Debug configurations are in .vscode/launch.json (auto-discovered by jdtls)

return {
  -- Configure nvim-jdtls to disable jdtls test runner in favor of NeoTest
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      -- Disable jdtls test runner - we're using NeoTest instead
      opts.test = false
      
      -- jdtls requires Java 21+ to run, but project uses Java 17
      -- Set JAVA_HOME to Java 21 for jdtls wrapper script
      local original_jdtls = opts.jdtls
      opts.jdtls = function(jdtls_opts, root_dir)
        if type(original_jdtls) == "function" then
          jdtls_opts = original_jdtls(jdtls_opts, root_dir)
        end
        
        -- Set environment variable for jdtls wrapper to find Java 21
        jdtls_opts.cmd_env = jdtls_opts.cmd_env or {}
        jdtls_opts.cmd_env.JAVA_HOME = "/Library/Java/JavaVirtualMachines/amazon-corretto-21.jdk/Contents/Home"
        
        -- Download source jars for dependencies so breakpoints work in library code
        jdtls_opts.settings = vim.tbl_deep_extend("force", jdtls_opts.settings or {}, {
          java = {
            eclipse = {
              downloadSources = true,
            },
            maven = {
              downloadSources = true,
            },
          },
        })
        
        return jdtls_opts
      end
      
      opts.dap = {
        hotcodereplace = "auto",
      }

      -- Enable debug support on decompiled sources (breakpoints in dependency classes).
      -- java-debug has this feature built-in but OFF by default.
      -- VS Code enables it via vscode.java.updateDebugSettings; nvim-jdtls doesn't.
      -- NOTE: updateSettings() replaces the ENTIRE DebugSettings singleton via Gson,
      -- so we must send ALL defaults to avoid nulling out fields (logLevel=null causes NPE).
      local function send_debug_settings()
        local ok, util = pcall(require, "jdtls.util")
        if not ok then return end
        util.execute_command({
          command = "vscode.java.updateDebugSettings",
          arguments = { vim.fn.json_encode({
            logLevel = "",
            maxStringLength = 0,
            numericPrecision = 0,
            showStaticVariables = false,
            showQualifiedNames = false,
            showHex = false,
            showLogicalStructure = true,
            showToString = true,
            hotCodeReplace = "auto",
            limitOfVariablesPerJdwpRequest = 100,
            jdwpRequestTimeout = 3000,
            asyncJDWP = "off",
            debugSupportOnDecompiledSource = "on",
          }) },
        }, function(err, result)
          if err then
            vim.notify("[java-debug] updateDebugSettings error: " .. vim.inspect(err), vim.log.levels.WARN)
          end
        end)
      end

      vim.api.nvim_create_user_command("JdtUpdateDebugSettings", send_debug_settings, {})

      -- Auto-send after jdtls is fully ready
      local debug_settings_sent = false
      local original_on_attach = opts.on_attach
      opts.on_attach = function(args)
        if type(original_on_attach) == "function" then
          original_on_attach(args)
        end
        if debug_settings_sent then return end
        debug_settings_sent = true
        vim.defer_fn(send_debug_settings, 15000)
      end

      return opts
    end,
  },
}
