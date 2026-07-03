# ruff: noqa: F821, F822
# pyright: reportUndefinedVariable=false, reportGeneralTypeIssues=false
#
c.scrolling.smooth = True
# Minimal session-first workflow
c.auto_save.session = True
c.session.default_name = "main"
c.session.lazy_restore = True
c.window.hide_decoration = True
c.tabs.last_close = "close"

config.set("zoom.default", "120%")
# Ad blocking (AdGuard/uBlock lists) to keep YouTube tidy
c.content.blocking.enabled = True
c.content.blocking.adblock.lists = [
    # uBlock Origin core filters
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt",
    # uBlock Origin badware filters (malware/phishing)
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/badware.txt",
    # EasyList (widely-used ad filter list)
    "https://easylist.to/easylist/easylist.txt",
    # EasyList Privacy (tracker blocking)
    "https://easylist.to/easylist/easyprivacy.txt",
]

# Prevent videos from auto-playing when loading many tabs.
c.content.autoplay = True

c.content.headers.do_not_track = True
# Open PDF files inside qutebrowser (PDF.js) instead of download prompt when possible.
c.content.pdfjs = True

# Use Neovim for :edit-url / :edit-text.
c.editor.command = ["/opt/homebrew/bin/nvim", "{file}"]

# UI sizing
c.fonts.default_size = "14pt"
c.fonts.default_family = "JetBrains Mono"
c.fonts.completion.entry = "18pt JetBrains Mono"
c.fonts.completion.category = "bold 18pt JetBrains Mono"
c.fonts.tabs.selected = "bold 14pt JetBrains Mono"
c.fonts.tabs.unselected = "14pt JetBrains Mono"
c.fonts.statusbar = "18pt JetBrains Mono"
c.fonts.keyhint = "18pt JetBrains Mono"
c.fonts.hints = "bold 18pt JetBrains Mono"
c.fonts.prompts = "18pt JetBrains Mono"
c.completion.height = "45%"
c.tabs.padding = {"top": 6, "bottom": 6, "left": 10, "right": 10}
c.tabs.indicator.width = 3
c.tabs.min_width = 180

# Catppuccin Cool Blue Monarchy Theme
# Muted blues, purples, pinks - no grey, no green, cohesive palette

# Tabs
c.colors.tabs.bar.bg = "#16141f"
c.colors.tabs.odd.bg = "#221e35"
c.colors.tabs.even.bg = "#221e35"
c.colors.tabs.odd.fg = "#a896d3"
c.colors.tabs.even.fg = "#a896d3"
# Deep purple selected
c.colors.tabs.selected.odd.bg = "#89b4fa"
c.colors.tabs.selected.even.bg = "#89b4fa"
c.colors.tabs.selected.odd.fg = "#1e1e2e"
c.colors.tabs.selected.even.fg = "#1e1e2e"
# Blue to purple gradient
c.colors.tabs.indicator.start = "#89b4fa"
c.colors.tabs.indicator.stop = "#cba6f7"
c.colors.tabs.indicator.error = "#f5c2e7"

# Status bar
c.colors.statusbar.normal.bg = "#16141f"
c.colors.statusbar.normal.fg = "#cdd6f4"

# Insert mode - muted blue
c.colors.statusbar.insert.bg = "#89b4fa"
c.colors.statusbar.insert.fg = "#1e1e2e"

# Visual/Caret mode - muted purple
c.colors.statusbar.caret.bg = "#cba6f7"
c.colors.statusbar.caret.fg = "#1e1e2e"

# Visual selection - muted pink
c.colors.statusbar.caret.selection.bg = "#f5c2e7"
c.colors.statusbar.caret.selection.fg = "#1e1e2e"

# Command mode - cool blue
c.colors.statusbar.command.bg = "#1e1e2e"
c.colors.statusbar.command.fg = "#cdd6f4"

# Passthrough mode - muted pink
c.colors.statusbar.passthrough.bg = "#1e1e2e"
c.colors.statusbar.passthrough.fg = "#f5c2e7"

# URL colors - black in bright modes, light in normal
c.colors.statusbar.url.fg = "#000000"
c.colors.statusbar.url.success.https.fg = "#89b4fa"
c.colors.statusbar.url.success.http.fg = "#cba6f7"
c.colors.statusbar.url.warn.fg = "#f5c2e7"
c.colors.statusbar.url.error.fg = "#eba0ac"

# Completion menu
c.colors.completion.fg = "#cdd6f4"
c.colors.completion.odd.bg = "#221e35"
c.colors.completion.even.bg = "#16141f"
c.colors.completion.category.bg = "#16141f"
c.colors.completion.category.fg = "#cba6f7"
c.colors.completion.item.selected.bg = "#2d2b5f"
c.colors.completion.item.selected.fg = "#cdd6f4"
c.colors.completion.match.fg = "#89b4fa"
c.colors.completion.item.selected.match.fg = "#89b4fa"
c.colors.completion.scrollbar.bg = "#16141f"
c.colors.completion.scrollbar.fg = "#89b4fa"

# Messages
c.colors.messages.info.bg = "#1e1e2e"
c.colors.messages.info.fg = "#89b4fa"
c.colors.messages.warning.bg = "#1e1e2e"
c.colors.messages.warning.fg = "#f5c2e7"
c.colors.messages.error.bg = "#1e1e2e"
c.colors.messages.error.fg = "#eba0ac"

# Prompts & hints
c.colors.prompts.bg = "#1e1e2e"
c.colors.prompts.fg = "#cdd6f4"
c.colors.hints.bg = "#f5b041"
c.colors.hints.fg = "#1e1e2e"
c.colors.hints.match.fg = "#eba0ac"
c.colors.statusbar.progress.bg = "#89b4fa"

# Make hinting pick up more form controls (checkbox/radio/labels).
c.hints.selectors["all"].append("input[type='checkbox']")
c.hints.selectors["all"].append("input[type='radio']")
c.hints.selectors["all"].append("label")
c.hints.selectors["all"].append("[role='checkbox']")
c.hints.selectors["all"].append("[role='radio']")
# Make hint labels easier to type and more predictable.
c.hints.uppercase = True
c.hints.scatter = True
# Full alphabet for hints: 26 letters = 676 two-letter combinations (26×26)
c.hints.chars = "abcdefghijklmnopqrstuvwxyz"

# Search engine bang commands for quick site searches
c.url.searchengines = {
    "DEFAULT": "https://duckduckgo.com/search?q={}",
    "ytm": "https://music.youtube.com/search?q={}",
    "gh": "https://github.com/search?q={}",
    "yt": "https://www.youtube.com/watch?q={}",
    "blog": "https://www.indiehackers.com/search?q={}",
    "wiki": "https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch={}",
    "reddit": "https://www.reddit.com/search/?q={}",
}

# Command aliases for faster command-line usage.
c.aliases["qm"] = "quickmark-load"
c.aliases["qmt"] = "quickmark-load -t"
c.aliases["qma"] = "quickmark-add"
c.aliases["ss"] = "session-save"
c.aliases["sl"] = "session-load"
c.aliases["sb"] = "session-save --backup"
c.aliases["g"] = "open -t  https://google.com"
c.aliases["t"] = "tab-focus"

# Tab close/reopen ergonomics
config.unbind("<Ctrl-t>")
config.bind("x", "tab-close")
config.bind("d", "cmd-run-with-count 20 scroll down")
config.bind("u", "cmd-run-with-count 20 scroll up")
config.bind("X", "undo")
config.bind(",r", "config-source")

# Quickmark helper keybinds (prefill command line).
config.bind(",m", "cmd-set-text -s :quickmark-load ")
config.bind(",M", "cmd-set-text -s :quickmark-load -t ")

config.bind(",h", "config-cycle tabs.show never multiple")

# Allow clicking links with custom URI schemes (e.g. slack://) to open in macOS default app
c.content.unknown_url_scheme_policy = "allow-all"

# Pass Shift-Tab through to the page in both normal and insert mode
config.bind("<Shift-Tab>", "fake-key <Shift-Tab>", mode="normal")
config.bind("<Shift-Tab>", "fake-key <Shift-Tab>", mode="insert")

c.aliases["gpt"] = "open -t  https://chatgpt.com"
config.set(
    "content.headers.user_agent",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
    "https://teams.microsoft.com/*",
)
