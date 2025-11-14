-- GitHub-style git diff highlights
return {
  {
    "LazyVim/LazyVim",
    opts = function()
      -- Set up autocmd to apply GitHub-style highlights after colorscheme loads
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          -- GitHub-style colors for dark background
          local colors = {
            -- Added lines: green background
            add_bg = "#1a472a",
            add_fg = "#7ee787",
            -- Removed lines: red background
            delete_bg = "#5a1f1f",
            delete_fg = "#ff7b72",
            -- Changed/modified lines: subtle blue
            change_bg = "#1c3d5a",
            change_fg = "#79c0ff",
            -- Context/neutral: dark gray
            context_bg = "#1c1e26",
            context_fg = "#8b949e",
          }

          -- mini.diff sign highlights
          vim.api.nvim_set_hl(0, "MiniDiffSignAdd", { fg = colors.add_fg, bg = "NONE" })
          vim.api.nvim_set_hl(0, "MiniDiffSignChange", { fg = colors.change_fg, bg = "NONE" })
          vim.api.nvim_set_hl(0, "MiniDiffSignDelete", { fg = colors.delete_fg, bg = "NONE" })

          -- mini.diff overlay highlights (for toggle overlay view)
          vim.api.nvim_set_hl(0, "MiniDiffOverAdd", { bg = colors.add_bg })
          vim.api.nvim_set_hl(0, "MiniDiffOverChange", { bg = "NONE" })
          vim.api.nvim_set_hl(0, "MiniDiffOverDelete", { bg = colors.delete_bg })
          vim.api.nvim_set_hl(0, "MiniDiffOverContext", { bg = "NONE" })

          -- Standard vim diff highlights
          vim.api.nvim_set_hl(0, "DiffAdd", { bg = colors.add_bg, fg = "NONE" })
          vim.api.nvim_set_hl(0, "DiffDelete", { bg = colors.delete_bg, fg = colors.delete_fg })
          vim.api.nvim_set_hl(0, "DiffChange", { bg = "NONE", fg = "NONE" })
          vim.api.nvim_set_hl(0, "DiffText", { bg = "#2d4f67", fg = colors.change_fg, bold = true })

          -- Diffview highlights (if using diffview.nvim)
          vim.api.nvim_set_hl(0, "DiffviewDiffAdd", { bg = colors.add_bg })
          vim.api.nvim_set_hl(0, "DiffviewDiffDelete", { bg = colors.delete_bg, fg = colors.delete_fg })
          vim.api.nvim_set_hl(0, "DiffviewDiffChange", { bg = "NONE" })
          vim.api.nvim_set_hl(0, "DiffviewDiffText", { bg = "#2d4f67", fg = colors.change_fg })

          -- Added/removed text in diffview
          vim.api.nvim_set_hl(0, "DiffviewDiffAddAsDelete", { bg = colors.delete_bg, fg = colors.delete_fg })
          vim.api.nvim_set_hl(0, "DiffviewDiffDeleteText", { bg = "#7a2626", fg = colors.delete_fg })

          -- Conflict markers
          vim.api.nvim_set_hl(0, "DiffviewDim1", { fg = colors.context_fg })
        end,
      })

      -- Trigger the autocmd for the current colorscheme
      vim.schedule(function()
        vim.cmd("doautocmd ColorScheme")
      end)
    end,
  },
}
