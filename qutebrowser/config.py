# ruff: noqa: F821, F822
# pyright: reportUndefinedVariable=false, reportGeneralTypeIssues=false
config.load_autoconfig()

c.scrolling.smooth = True
# Minimal session-first workflow
c.auto_save.session = True
c.session.default_name = "main"
c.session.lazy_restore = True
c.window.hide_decoration = True
c.tabs.last_close = "close"

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
c.content.autoplay = False
c.content.headers.do_not_track = True
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

c.colors.statusbar.progress.bg = "#8caaee"

c.colors.hints.bg = "#e5c890"
c.colors.hints.fg = "#232634"
c.colors.hints.match.fg = "#e78284"

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
    "DEFAULT": "https://www.google.com/search?q={}",
    "gh": "https://github.com/search?q={}",
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

# Bitwarden userscript shortcuts
config.bind(",bu", "spawn --userscript bw-copy username")
config.bind(",bp", "spawn --userscript bw-copy password")

# Tab close/reopen ergonomics
config.bind("x", "tab-close")
config.bind("d", "cmd-run-with-count 10 scroll down")
config.bind("u", "cmd-run-with-count 10 scroll up")
config.bind("X", "undo")
config.bind(",r", "config-source")
# config.bind("X", "tab-close -o")

# Quickmark helper keybinds (prefill command line).
config.bind(",m", "cmd-set-text -s :quickmark-load ")
config.bind(",M", "cmd-set-text -s :quickmark-load -t ")

# Launch YouTube in mpv (yt-dlp backend) instead of in-browser playback
config.bind(
    ",ym",
    "spawn --detach /opt/homebrew/bin/mpv --ytdl=yes {url}",
)
config.bind(
    ",yl",
    "spawn --detach /opt/homebrew/bin/mpv --ytdl=yes --loop-file=inf --keep-open=yes {url}",
)
config.bind(
    ",yM",
    "hint links spawn --detach /opt/homebrew/bin/mpv --ytdl=yes {hint-url}",
)
config.bind(
    ",yl",
    "spawn --detach /opt/homebrew/bin/mpv --ytdl=yes --loop-file=inf {url}",
)
config.bind(",h", "config-cycle tabs.show never multiple")

# Allow clicking links with custom URI schemes (e.g. slack://) to open in macOS default app
c.content.unknown_url_scheme_policy = "allow-all"

# Spoof Chrome user agent for Microsoft Teams so it allows launching the desktop app
config.set(
    "content.headers.user_agent",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
    "https://teams.microsoft.com/*",
)

# Pass Shift-Tab through to the page in both normal and insert mode
config.bind("<Shift-Tab>", "fake-key <Shift-Tab>", mode="normal")
config.bind("<Shift-Tab>", "fake-key <Shift-Tab>", mode="insert")
