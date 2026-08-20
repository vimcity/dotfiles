return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      local palette = require("catppuccin.palettes").get_palette("frappe")

      local function define_lualine_accent_highlights()
        vim.api.nvim_set_hl(0, "DotfilesLualineGitIcon", { fg = palette.green })
        vim.api.nvim_set_hl(0, "DotfilesLualineGitBranch", { fg = palette.mauve, bold = true })
        vim.api.nvim_set_hl(0, "DotfilesLualineProjLine", { fg = palette.blue, italic = true })
        vim.api.nvim_set_hl(0, "DotfilesLualineBranchProjSep", { fg = palette.overlay0 })
      end

      define_lualine_accent_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = define_lualine_accent_highlights,
        group = vim.api.nvim_create_augroup("DotfilesLualineAccents", { clear = true }),
      })

      opts.options = opts.options or {}

      opts.options.theme = {
        normal = {
          a = { bg = palette.blue, fg = palette.base, gui = "bold" },
          b = { bg = palette.base, fg = palette.text },
          c = { bg = palette.base, fg = palette.text },
        },
        insert = {
          a = { bg = palette.teal, fg = palette.base, gui = "bold" },
          b = { bg = palette.base, fg = palette.text },
          c = { bg = palette.base, fg = palette.text },
        },
        visual = {
          a = { bg = palette.mauve, fg = palette.base, gui = "bold" },
          b = { bg = palette.base, fg = palette.text },
          c = { bg = palette.base, fg = palette.text },
        },
        replace = {
          a = { bg = palette.red, fg = palette.base, gui = "bold" },
          b = { bg = palette.base, fg = palette.text },
          c = { bg = palette.base, fg = palette.text },
        },
        command = {
          a = { bg = palette.yellow, fg = palette.base, gui = "bold" },
          b = { bg = palette.base, fg = palette.text },
          c = { bg = palette.base, fg = palette.text },
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

      local icons = LazyVim.config.icons

      opts.sections = opts.sections or {}

      opts.sections.lualine_c = {
        { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
        {
          function()
            local path = vim.fn.expand("%:p")
            local ok, root = pcall(function()
              return LazyVim.root.get({ normalize = true })
            end)
            if ok and root and vim.startswith(path, root .. "/") then
              return vim.fs.relpath(root, path)
            end
            return vim.fn.fnamemodify(path, ":~")
          end,
          cond = function()
            return vim.fn.expand("%") ~= ""
          end,
          color = { fg = palette.overlay1 },
        },
        {
          "diagnostics",
          symbols = {
            error = icons.diagnostics.Error,
            warn = icons.diagnostics.Warn,
            info = icons.diagnostics.Info,
            hint = icons.diagnostics.Hint,
          },
        },
      }

      opts.sections.lualine_x = {
        {
          require("lazy.status").updates,
          cond = require("lazy.status").has_updates,
          color = function()
            return { fg = Snacks.util.color("Special") }
          end,
        },
        {
          "diff",
          symbols = {
            added = icons.git.added,
            modified = icons.git.modified,
            removed = icons.git.removed,
          },
          source = function()
            local gitsigns = vim.b.gitsigns_status_dict
            if gitsigns then
              return {
                added = gitsigns.added,
                modified = gitsigns.changed,
                removed = gitsigns.removed,
              }
            end
          end,
        },
      }

      opts.sections.lualine_y = {
        { "location", padding = { left = 1, right = 1 } },
      }

      opts.sections.lualine_z = {}

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

