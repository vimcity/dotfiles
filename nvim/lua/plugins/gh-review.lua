-- gh-review.nvim
-- Inline PR review inside DiffView. No Snacks dependency.

local function is_personal_machine()
  local personal_env = os.getenv("PERSONAL")
  return personal_env == nil or personal_env == "1"
end

local function read_inbox_repos()
  local repo_file = os.getenv("GHPRS_REPOS_FILE") or vim.fn.expand("~/dotfiles/.ghprs-repos.local")
  local lines = vim.fn.filereadable(repo_file) == 1 and vim.fn.readfile(repo_file) or {}
  local repos = {}

  for _, line in ipairs(lines) do
    local repo = line:gsub("%s+#.*$", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if repo ~= "" and not repo:match("^#") then
      table.insert(repos, repo)
    end
  end

  return repos
end

return {
  dir = "~/Projects/gh-review.nvim",
  cond = not is_personal_machine(),
  name = "gh-review",
  dependencies = { "sindrets/diffview.nvim" },
  event = "VeryLazy",
  opts = {
    gh_host = os.getenv("GH_HOST"),
    inbox = {
      repos = read_inbox_repos(),
      limit = 100,
    },
    keymaps = {
      add_comment = "pa",
      reply = "pr",
      edit_comment = "pe",
      toggle_resolve = "pR",
      toggle_expand = "pt",
      next_thread = "]c",
      prev_thread = "[c",
      open_popup = "pv",
      submit_review = "ps",
      open_threads = "pl",
      close = "q",
    },
  },
  config = function(_, opts)
    require("gh-review").setup(opts)
  end,
  keys = {
    {
      "<leader>gp",
      function()
        local url = vim.fn.input("PR URL or number: ")
        if url == "" then
          return
        end
        if url:match("^%d+$") then
          require("gh-review").open_number(tonumber(url))
        else
          require("gh-review").open(url)
        end
      end,
      desc = "Open PR in DiffView",
    },
    { "<leader>gi", "<cmd>GhReviewInbox<cr>", desc = "Open PR inbox" },
    { "<leader>gL", "<cmd>GhReviewCycleLayout<cr>", desc = "Cycle PR diff layout" },
    { "<leader>gF", "<cmd>GhReviewToggleFiles<cr>", desc = "Toggle PR file panel" },
    { "<leader>gt", "<cmd>GhReviewThreads<cr>", desc = "Toggle PR thread list" },
    { "<leader>gs", "<cmd>GhReviewSubmit<cr>", desc = "Submit PR review" },
  },
}
