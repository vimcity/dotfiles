# ruff: noqa: F821, F822
# pyright: reportUndefinedVariable=false, reportGeneralTypeIssues=false
config.load_autoconfig()

# Minimal session-first workflow
c.auto_save.session = True
c.session.default_name = "main"
c.session.lazy_restore = True
c.window.hide_decoration = True
c.tabs.last_close = "close"

# Prevent videos from auto-playing when loading many tabs.
c.content.autoplay = False

# Open PDF files inside qutebrowser (PDF.js) instead of download prompt when possible.
c.content.pdfjs = True

# Use Neovim for :edit-url / :edit-text.
c.editor.command = ["/opt/homebrew/bin/nvim", "{file}"]

# UI sizing
c.fonts.default_size = "14pt"
c.fonts.default_family = "CommitMono"
c.fonts.completion.entry = "15pt CommitMono"
c.fonts.completion.category = "bold 15pt CommitMono"
c.fonts.tabs.selected = "bold 14pt CommitMono"
c.fonts.tabs.unselected = "14pt CommitMono"
c.fonts.statusbar = "14pt CommitMono"
c.fonts.keyhint = "14pt CommitMono"
c.fonts.hints = "bold 14pt CommitMono"
c.fonts.prompts = "14pt CommitMono"
c.completion.height = "45%"
c.tabs.padding = {"top": 6, "bottom": 6, "left": 10, "right": 10}
c.tabs.indicator.width = 3
c.tabs.min_width = 180

# Catppuccin Frappe theme (browser UI)
c.colors.completion.fg = "#c6d0f5"
c.colors.completion.odd.bg = "#303446"
c.colors.completion.even.bg = "#292c3c"
c.colors.completion.category.bg = "#232634"
c.colors.completion.category.fg = "#8caaee"
c.colors.completion.item.selected.bg = "#414559"
c.colors.completion.item.selected.fg = "#c6d0f5"
c.colors.completion.match.fg = "#a6d189"
c.colors.completion.item.selected.match.fg = "#a6d189"
c.colors.completion.scrollbar.bg = "#232634"
c.colors.completion.scrollbar.fg = "#626880"

c.colors.statusbar.normal.bg = "#232634"
c.colors.statusbar.normal.fg = "#c6d0f5"
c.colors.statusbar.command.bg = "#232634"
c.colors.statusbar.command.fg = "#8caaee"
c.colors.statusbar.insert.bg = "#232634"
c.colors.statusbar.insert.fg = "#a6d189"
c.colors.statusbar.passthrough.bg = "#232634"
c.colors.statusbar.passthrough.fg = "#ef9f76"
c.colors.statusbar.url.fg = "#c6d0f5"
c.colors.statusbar.url.success.https.fg = "#a6d189"
c.colors.statusbar.url.success.http.fg = "#e5c890"
c.colors.statusbar.url.warn.fg = "#ef9f76"
c.colors.statusbar.url.error.fg = "#e78284"

c.colors.tabs.bar.bg = "#232634"
c.colors.tabs.odd.bg = "#303446"
c.colors.tabs.even.bg = "#303446"
c.colors.tabs.odd.fg = "#b5bfe2"
c.colors.tabs.even.fg = "#b5bfe2"
c.colors.tabs.selected.odd.bg = "#8caaee"
c.colors.tabs.selected.even.bg = "#8caaee"
c.colors.tabs.selected.odd.fg = "#232634"
c.colors.tabs.selected.even.fg = "#232634"
c.colors.tabs.indicator.start = "#8caaee"
c.colors.tabs.indicator.stop = "#a6d189"
c.colors.tabs.indicator.error = "#e78284"

c.colors.messages.info.bg = "#232634"
c.colors.messages.info.fg = "#8caaee"
c.colors.messages.warning.bg = "#232634"
c.colors.messages.warning.fg = "#ef9f76"
c.colors.messages.error.bg = "#232634"
c.colors.messages.error.fg = "#e78284"

c.colors.prompts.bg = "#232634"
c.colors.prompts.fg = "#c6d0f5"

c.colors.hints.bg = "#e5c890"
c.colors.hints.fg = "#232634"
c.colors.hints.match.fg = "#e78284"

# Make hinting pick up more form controls (checkbox/radio/labels).
c.hints.selectors["all"].append("input[type='checkbox']")
c.hints.selectors["all"].append("input[type='radio']")
c.hints.selectors["all"].append("label")
c.hints.selectors["all"].append("[role='checkbox']")
c.hints.selectors["all"].append("[role='radio']")
c.hints.uppercase = True

# Command aliases for faster command-line usage.
c.aliases["qm"] = "quickmark-load"
c.aliases["qmt"] = "quickmark-load -t"
c.aliases["qma"] = "quickmark-add"
c.aliases["ss"] = "session-save"
c.aliases["sl"] = "session-load"

# Bitwarden userscript shortcuts
config.bind(",bu", "spawn --userscript bw-copy username")
config.bind(",bp", "spawn --userscript bw-copy password")

# Tab close/reopen ergonomics
config.bind("x", "tab-close")
config.unbind("d")

# Quickmark helper keybinds (prefill command line).
config.bind(",m", "cmd-set-text -s :quickmark-load ")
config.bind(",M", "cmd-set-text -s :quickmark-load -t ")
