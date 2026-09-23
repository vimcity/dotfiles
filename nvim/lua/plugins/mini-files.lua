return {
  {
    "nvim-mini/mini.files",
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        once = true,
        callback = function()
          vim.keymap.set("n", "<leader>e", function()
            require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
          end, { desc = "Open file explorer" })
        end,
      })
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    enabled = false,
  },
}
