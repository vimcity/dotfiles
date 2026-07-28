local function expand_all_safe()
  require("nvim-tree.api").tree.expand_all(nil, {
    expand_until = function(_, node)
      return node.type ~= "link"
    end,
  })
end

local function on_attach(bufnr)
  local api = require("nvim-tree.api")

  api.map.on_attach.default(bufnr)

  vim.keymap.set("n", "E", expand_all_safe, {
    buffer = bufnr,
    noremap = true,
    silent = true,
    nowait = true,
    desc = "nvim-tree: Expand All (safe)",
  })

end

return {
  "nvim-tree/nvim-tree.lua",
  cmd = { "NvimTreeToggle", "NvimTreeFindFile", "NvimTreeFocus" },
  keys = {
    {
      "<leader>e",
      function()
        vim.cmd("NvimTreeFindFile")
      end,
      desc = "Open file explorer at current file",
    },
    {
      "<leader>E",
      function()
        vim.cmd("NvimTreeFindFile")
      end,
      desc = "Reveal current file",
    },
    {
      "<leader>za",
      expand_all_safe,
      desc = "NvimTree expand all",
    },
    {
      "<leader>zc",
      function()
        require("nvim-tree.api").tree.collapse_all()
      end,
      desc = "NvimTree collapse all",
    },
  },
  opts = {
    disable_netrw = true,
    hijack_netrw = true,
    sync_root_with_cwd = true,
    update_focused_file = {
      enable = true,
      update_root = false,
    },
    on_attach = on_attach,
    view = {
      side = "left",
      width = 40,
    },
    renderer = {
      group_empty = true,
      highlight_git = "name",
      special_files = {},
      indent_markers = {
        enable = false,
      },
      icons = {
        glyphs = {
          git = {
            unstaged = "",
            staged = "",
            unmerged = "",
            renamed = "",
            untracked = "",
            deleted = "",
            ignored = "",
          },
        },
      },
    },
    filters = {
      dotfiles = true,
      git_ignored = true,
    },
  },
  config = function(_, opts)
    require("nvim-tree").setup(opts)

    local function set_highlights()
      vim.api.nvim_set_hl(0, "NvimTreeSpecialFile", { link = "NvimTreeFileName" })
      vim.api.nvim_set_hl(0, "NvimTreeExecFile", { link = "NvimTreeFileName" })
      vim.api.nvim_set_hl(0, "NvimTreeGitFileDirtyHL", { fg = "#f9e2af" })
      vim.api.nvim_set_hl(0, "NvimTreeGitFileStagedHL", { fg = "#a6e3a1" })
      vim.api.nvim_set_hl(0, "NvimTreeGitFileNewHL", { fg = "#89b4fa" })
      vim.api.nvim_set_hl(0, "NvimTreeGitFileDeletedHL", { fg = "#f38ba8" })
      vim.api.nvim_set_hl(0, "NvimTreeGitFileRenamedHL", { fg = "#94e2d5" })
      vim.api.nvim_set_hl(0, "NvimTreeGitFileIgnoredHL", { fg = "#6c7086" })
      vim.api.nvim_set_hl(0, "NvimTreeGitFileMergeHL", { fg = "#f38ba8", bold = true })
    end

    set_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_highlights,
    })
  end,
}
