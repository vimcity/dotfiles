-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Enable word wrapping for org files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "org",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true        -- Break at word boundaries, not mid-word
    vim.opt_local.breakindent = true      -- Indent wrapped lines to match indentation
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "md" },
  callback = function()
    vim.opt_local.spell = false
  end,
})

-- Auto-save for files in ORG_PATH only
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  callback = function()
    local org_path = os.getenv("ORG_PATH")
    if not org_path then
      return
    end

    local filepath = vim.fn.expand("%:p")
    if filepath:find(vim.fn.expand(org_path), 1, true) == 1 then
      if vim.bo.modified and not vim.bo.readonly and filepath ~= "" and vim.bo.buftype == "" then
        vim.api.nvim_command("silent! write")
      end
    end
  end,
})
