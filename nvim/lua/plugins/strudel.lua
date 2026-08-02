return {
  "gruvw/strudel.nvim",
  build = "npm ci",
  opts = {
    ui = {
      maximise_menu_panel = true,
      hide_menu_panel = false,
      hide_top_bar = false,
      hide_code_editor = true, -- hide the embedded editor since we use Neovim
      hide_error_display = false,
    },
    start_on_launch = true,
    update_on_save = true, -- auto-evaluate when you save
    sync_cursor = true,
    report_eval_errors = true,
    -- point to your Chrome installation
    browser_exec_path = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
  },
}