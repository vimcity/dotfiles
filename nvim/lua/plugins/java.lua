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
        
        return jdtls_opts
      end
      
      opts.dap = {
        hotcodereplace = "auto",
      }
      
      return opts
    end,
  },
}
