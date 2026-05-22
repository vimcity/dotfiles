return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      local palette = require("catppuccin.palettes").get_palette("frappe")

      ---Match `prompt-themes.zsh`: green git icon, violet branch, blue project accent (see `config/dotfiles_prompt_colors.lua`).
      local function define_lualine_accent_highlights()
        local t = require("config.dotfiles_prompt_colors").get()
        vim.api.nvim_set_hl(0, "DotfilesLualineGitIcon", { fg = t.git_icon })
        vim.api.nvim_set_hl(0, "DotfilesLualineGitBranch", { fg = t.git_fg, bold = true })
        vim.api.nvim_set_hl(0, "DotfilesLualineProjLine", { fg = t.dir_accent, italic = true })
        vim.api.nvim_set_hl(0, "DotfilesLualineBranchProjSep", { fg = t.sep })
      end

      define_lualine_accent_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = define_lualine_accent_highlights,
        group = vim.api.nvim_create_augroup("DotfilesLualineAccents", { clear = true }),
      })

      opts.options = opts.options or {}

      opts.options.theme = {
        normal = {
          a = { bg = palette.mauve, fg = palette.base, gui = "bold" },
          b = { bg = palette.surface0, fg = palette.text },
          c = { bg = "NONE", fg = palette.text },
        },
        insert = {
          a = { bg = "#81c8be", fg = palette.base, gui = "bold" },
          b = { bg = palette.surface0, fg = palette.text },
          c = { bg = "NONE", fg = palette.text },
        },
        visual = {
          a = { bg = palette.blue, fg = palette.base, gui = "bold" },
          b = { bg = palette.surface0, fg = palette.text },
          c = { bg = "NONE", fg = palette.text },
        },
        replace = {
          a = { bg = palette.red, fg = palette.base, gui = "bold" },
          b = { bg = palette.surface0, fg = palette.text },
          c = { bg = "NONE", fg = palette.text },
        },
        command = {
          a = { bg = palette.yellow, fg = palette.base, gui = "bold" },
          b = { bg = palette.surface0, fg = palette.text },
          c = { bg = "NONE", fg = palette.text },
        },
        inactive = {
          a = { bg = "NONE", fg = palette.overlay0, gui = "bold" },
          b = { bg = "NONE", fg = palette.overlay0 },
          c = { bg = "NONE", fg = palette.overlay0 },
        },
      }

      -- Replace default `branch`. Do NOT call git_branch.init() here: it uses
      -- augroup `lualine`, which exists only after lualine's config/setup runs.

      local git_icon = " " -- nf-oct-git_branch
      local root_icon = "󱉭 " -- LazyVim lualine root_dir glyph (mdi folder-root)

      opts.sections = opts.sections or {}
      opts.sections.lualine_b = {
        {
          function()
            local git_branch_mod = require("lualine.components.branch.git_branch")
            local utils = require("lualine.utils.utils")
            local raw_branch = vim.b.gitsigns_head
            if raw_branch == nil or raw_branch == "" then
              git_branch_mod.find_git_dir(nil)
              raw_branch = git_branch_mod.get_branch() or ""
            end
            local branch = utils.stl_escape(raw_branch)
            local ok, root = pcall(function()
              return LazyVim.root.get({ normalize = true })
            end)
            local proj = ok and vim.fs.basename(root) or ""
            proj = utils.stl_escape(proj)

            local git_seg = "%#DotfilesLualineGitIcon#"
              .. git_icon
              .. "%#DotfilesLualineGitBranch#"
              .. branch
              .. "%*"
            local proj_seg = "%#DotfilesLualineProjLine#" .. root_icon .. proj .. "%*"
            local sep_seg = "%#DotfilesLualineBranchProjSep# · %*"

            if branch ~= "" and proj ~= "" then
              return git_seg .. sep_seg .. proj_seg
            end
            if branch ~= "" then
              return git_seg
            end
            if proj ~= "" then
              return proj_seg
            end
            return ""
          end,
        },
      }
    end,
  },
}
