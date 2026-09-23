return {
  {
    "neovim/nvim-lspconfig",
    event = false,
    ft = {
      "bash", "c", "cpp", "css", "go", "html", "java", "javascript",
      "javascriptreact", "json", "kotlin", "lua", "markdown", "python", "sh",
      "tsx", "typescript", "typescriptreact", "vim", "yaml",
    },
    init = function()
      local show_message = vim.lsp.handlers["window/showMessage"]
      vim.lsp.handlers["window/showMessage"] = function(err, result, ctx, config)
        if result and result.type and result.type > vim.lsp.protocol.MessageType.Warning then
          return
        end
        return show_message(err, result, ctx, config)
      end

      vim.lsp.handlers["window/logMessage"] = function() end
    end,
  },
}
