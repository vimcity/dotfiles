# The Ultimate Neovim Primer: From "AI Generated My Config" to Superuser

> This doc is written for someone whose entire Neovim setup is AI-generated. We will fix that. By the end, you will understand every moving part in your config, know how to change anything, and have a roadmap to vim mastery.

---

## Table of Contents

1. [The Core Question: `config` vs `setup`](#1-the-core-question-config-vs-setup)
2. [How Your Config Actually Boots Up](#2-how-your-config-actually-boots-up)
3. [LazyVim Architecture: The Three Layers](#3-lazyvim-architecture-the-three-layers)
4. [The Help System: Your Best Friend](#4-the-help-system-your-best-friend)
5. [Lua 101 for Neovim](#5-lua-101-for-neovim)
6. [The Vim/Neovim API: What You Can Call](#6-the-vimneovim-api-what-you-can-call)
7. [Your Config: File-by-File Walkthrough](#7-your-config-file-by-file-walkthrough)
8. [Vim Motions & Text Objects: Beyond the Basics](#8-vim-motions--text-objects-beyond-the-basics)
9. [Registers, Macros, and Recordings](#9-registers-macros-and-recordings)
10. [Command-Line Mode: The Real Power User Tool](#10-command-line-mode-the-real-power-user-tool)
11. [Changing Keymaps: The Complete Guide](#11-changing-keymaps-the-complete-guide)
12. [How to Make or Modify Plugins](#12-how-to-make-or-modify-plugins)
13. [Learning Neovim *From Inside* Neovim](#13-learning-neovim-from-inside-neovim)
14. [Plugin Recommendations for Leveling Up](#14-plugin-recommendations-for-leveling-up)
15. [Quick Reference Cheat Sheet](#15-quick-reference-cheat-sheet)

---

## 1. The Core Question: `config` vs `setup`

This is the #1 confusion in Neovim plugin configs. Let's kill it permanently.

### `setup()` — The Plugin's Own Function

Almost every modern Lua plugin exposes a `setup()` function. This is **the plugin's own API** for configuring itself.

```lua
-- You call this. The plugin defines it.
require("oil").setup({
  view_options = { show_hidden = true },
})
```

Think of `setup()` as the plugin saying: "Tell me how you want me to behave."

### `config` — Lazy.nvim's Hook

`config` is a key in your **Lazy.nvim plugin spec**. It tells Lazy: "After you download and load this plugin, run this function."

```lua
return {
  "stevearc/oil.nvim",
  config = function()
    -- This runs AFTER the plugin is loaded
    require("oil").setup({ view_options = { show_hidden = true } })
  end,
}
```

### The Four Patterns You'll See

| Pattern | What It Means | Example |
|---------|--------------|---------|
| `opts = {}` | Lazy calls `require("plugin").setup(opts)` for you | `opts = { view_options = {...} }` |
| `opts = function(_, opts)` | Merge with existing opts from another spec | `opts = function(_, opts) opts.foo = "bar" end` |
| `config = function()` | Full manual control; you call `setup()` yourself | `config = function() require("x").setup({...}) end` |
| `init = function()` | Runs **before** the plugin loads | `init = function() vim.g.some_global = true end` |

### Real Examples From Your Config

```lua
-- Pattern 1: Lazy calls setup() for you (opts)
-- File: lua/plugins/oil.lua
return {
  "stevearc/oil.nvim",
  opts = {},  -- Lazy does: require("oil").setup({})
}

-- Pattern 2: You call setup() manually (config)
-- File: lua/plugins/orgmode.lua
return {
  "nvim-orgmode/orgmode",
  config = function()
    require("orgmode").setup({
      org_agenda_files = org_path .. "/**/*",
    })
  end,
}

-- Pattern 3: Merge with existing opts
-- File: lua/plugins/snacks.lua
opts = function(_, opts)
  opts.scroll.enabled = false
  return opts
end

-- Pattern 4: init runs before load
-- File: lua/plugins/markdown.lua
init = function()
  vim.g.vim_markdown_follow_link = 1
end
```

### The Golden Rule

> If a plugin spec has `config`, you are in control. If it has `opts`, Lazy is in control. If it has both, `config` overrides `opts` (Lazy won't auto-call setup).

---

## 2. How Your Config Actually Boots Up

When you type `nvim`, here is the exact sequence of events:

```
1. nvim starts
2. Reads $XDG_CONFIG_HOME/nvim/init.lua  (your init.lua)
3. init.lua requires "config.lazy"
4. config.lazy bootstraps lazy.nvim (downloads it if missing)
5. lazy.nvim scans lua/plugins/ for all *.lua files
6. lazy.nvim resolves dependencies and loads plugins
7. lazy.nvim fires the "VeryLazy" event
8. Your keymaps.lua, autocmds.lua, and options.lua load
```

### Your `init.lua`

```lua
-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
```

That's it. One line. It delegates everything to `lua/config/lazy.lua`.

### Your `lua/config/lazy.lua`

This file does three things:

1. **Bootstrap**: Checks if `lazy.nvim` is installed. If not, clones it from GitHub.
2. **Setup runtime path**: Tells Neovim where to find lazy.nvim.
3. **Call `require("lazy").setup({...})`**: This is where the magic happens.

The `spec` table inside `setup()` controls load order:

```lua
spec = {
  -- Layer 1: LazyVim base (MUST be first)
  { "LazyVim/LazyVim", import = "lazyvim.plugins" },

  -- Layer 2: LazyVim extras (language support, UI, etc.)
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.dap.core" },
  -- ... more extras

  -- Layer 3: YOUR custom plugins
  { import = "plugins" },
}
```

**Load order matters.** LazyVim base sets defaults. Extras add features. Your custom plugins override or extend everything.

---

## 3. LazyVim Architecture: The Three Layers

LazyVim is not just a plugin. It's a **distribution** — a curated set of plugins with pre-configured defaults.

### Layer 1: LazyVim Core (`lazyvim.plugins`)

This imports ~40 plugins with sensible defaults:
- `snacks.nvim` (UI, picker, dashboard, notifications)
- `nvim-treesitter` (syntax highlighting)
- `nvim-lspconfig` + `mason.nvim` (LSP support)
- `blink.cmp` (completion)
- `which-key.nvim` (keymap hints)
- `gitsigns.nvim` (git gutter)
- `mini.nvim` modules (pairs, surround, etc.)

You don't configure these directly. You **override** them.

### Layer 2: LazyVim Extras

Extras are optional feature packs. Your config imports:

| Extra | What It Gives You |
|-------|-------------------|
| `dap.core` | Debugging (breakpoints, stepping, watches) |
| `test.core` | Test running via Neotest |
| `lang.typescript` | TS/JS LSP, treesitter, formatting |
| `lang.json` | JSON LSP + schemas |
| `lang.python` | Python LSP, ruff, debugpy |
| `lang.java` | jdtls, Java debugging |
| `lang.go` | gopls, gofmt |
| `lang.kotlin` | Kotlin LSP |
| `editor.illuminate` | Highlight word under cursor |
| `editor.inc-rename` | Live preview LSP renames |
| `editor.mini-move` | Alt+j/k to move lines |
| `editor.mini-diff` | Inline git diff signs |
| `coding.mini-surround` | Edit surrounding chars |
| `coding.yanky` | Yank history (kill ring) |
| `ui.treesitter-context` | Sticky function name at top |
| `ui.indent-blankline` | Indentation guides |
| `ui.mini-indentscope` | Highlight current indent block |

### Layer 3: Your Custom Plugins (`lua/plugins/`)

Every `.lua` file in `lua/plugins/` is automatically loaded. Each file must return a Lua table (or a list of tables) describing plugins.

**Key insight**: When you return a spec for a plugin that LazyVim already loaded, your spec **merges with** LazyVim's spec. You override/extend, not replace.

```lua
-- LazyVim already loads bufferline. You just tweak it.
-- File: lua/plugins/bufferline.lua
return {
  "akinsho/bufferline.nvim",
  opts = {
    options = {
      always_show_bufferline = true,  -- override LazyVim's default
    },
  },
}
```

---

## 4. The Help System: Your Best Friend

Neovim's built-in documentation is incredible. Most people never use it. You will.

### Essential Help Commands

| Command | What It Does |
|---------|-------------|
| `:help` | Open help window |
| `:help motion.txt` | Specific help file |
| `:help i_CTRL-W` | Help for Ctrl-W in insert mode |
| `:help v_o` | Help for `o` in visual mode |
| `:help 'tabstop'` | Help for the `tabstop` option (note the quotes) |
| `:help vim.keymap.set` | Help for Lua API function |
| `:help lua-guide` | Neovim's Lua guide |
| `:help lazy.nvim` | Lazy.nvim documentation |
| `:help lsp` | LSP documentation |
| `:help treesitter` | Treesitter docs |
| `:K` (with cursor on function) | Show docs for word under cursor |

### Pro Tips

```vim
" Jump to tag under cursor in help (follow links)
<C-]>       " in help window

" Go back
<C-t>       " jump back from tag

" Search help for a pattern
:helpgrep surround
:cnext      " next match
:cprev      " previous match

" Open help in a vertical split
:vert help motion.txt

" Open help in a floating window (if you have a plugin)
:help motion.txt | only
```

### Lua-Specific Help

```vim
:help lua-guide              " The official Lua guide for Neovim
:help api                    " Full Neovim Lua API
:help vim.api.nvim_create_autocmd
:help vim.keymap.set
:help vim.opt
:help vim.fn
```

---

## 5. Lua 101 for Neovim

You don't need to be a Lua expert. You need ~10 concepts.

### Variables and Types

```lua
local x = 10              -- number
local name = "neovim"     -- string
local enabled = true      -- boolean
local list = {1, 2, 3}    -- table (array)
local dict = {a = 1, b = 2} -- table (dictionary/hash)
local nothing = nil       -- nil (null)
```

### Tables: The Only Data Structure

```lua
-- Array-style (1-indexed!)
local fruits = {"apple", "banana", "cherry"}
print(fruits[1])  -- "apple" (NOT 0!)

-- Dictionary-style
local config = {
  width = 80,
  height = 24,
  theme = "dark",
}
print(config.width)  -- 80

-- Mixed (common in Neovim)
local plugin = {
  "folke/snacks.nvim",  -- [1] = string
  opts = {              -- named key
    enabled = true,
  },
}
```

### Functions

```lua
-- Basic function
local function greet(name)
  print("Hello, " .. name)
end

-- Anonymous function (very common in configs)
local callback = function()
  print("Done!")
end

-- Function with multiple returns
local function get_size()
  return 80, 24
end
local w, h = get_size()

-- Variadic function
local function log(...)
  local args = {...}
  for i, v in ipairs(args) do
    print(i, v)
  end
end
```

### String Concatenation

```lua
local name = "nvim"
local version = "0.10"
local full = name .. " v" .. version  -- "nvim v0.10"

-- String interpolation (Neovim 0.10+)
local msg = string.format("Hello %s, you have %d messages", name, 5)
```

### Conditionals

```lua
local mode = "insert"

if mode == "normal" then
  print("Normal mode")
elseif mode == "insert" then
  print("Insert mode")
else
  print("Other mode")
end

-- Ternary-ish
local value = condition and "yes" or "no"
```

### Loops

```lua
-- ipairs: for arrays (preserves order, stops at first nil)
for i, v in ipairs({"a", "b", "c"}) do
  print(i, v)
end

-- pairs: for dictionaries (no order guarantee)
for k, v in pairs({x = 1, y = 2}) do
  print(k, v)
end

-- Numeric for
for i = 1, 10 do
  print(i)
end

-- While
local i = 1
while i <= 5 do
  print(i)
  i = i + 1
end
```

### `pcall`: Safe Function Calls

```lua
-- pcall = "protected call"
-- Returns: success_boolean, result_or_error
local ok, result = pcall(require, "some_optional_plugin")
if not ok then
  print("Plugin not available:", result)
end

-- Common pattern in configs
local ok, module = pcall(require, "catppuccin.palettes")
if ok then
  local palette = module.get_palette("frappe")
  -- use palette...
end
```

### Metatables (Briefly)

You don't need to write these, but you'll see them:

```lua
-- vim.tbl_deep_extend merges tables recursively
local defaults = { a = 1, b = { c = 2 } }
local overrides = { b = { d = 3 } }
local merged = vim.tbl_deep_extend("force", defaults, overrides)
-- merged = { a = 1, b = { c = 2, d = 3 } }
```

---

## 6. The Vim/Neovim API: What You Can Call

Neovim exposes a massive API. Here are the categories you actually need.

### `vim.opt` — Editor Options

```lua
vim.opt.number = true           -- Show line numbers
vim.opt.relativenumber = true   -- Relative line numbers
vim.opt.tabstop = 4             -- Tab width
vim.opt.shiftwidth = 4          -- Indent width
vim.opt.expandtab = true        -- Use spaces for tabs
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.wrap = false            -- Don't wrap lines
vim.opt.ignorecase = true       -- Case-insensitive search
vim.opt.smartcase = true        -- Case-sensitive if uppercase in query

-- Local (buffer/window-specific)
vim.opt_local.wrap = true       -- Wrap for this buffer only
vim.opt_local.spell = false     -- No spellcheck for this buffer
```

### `vim.g` — Global Variables

```lua
vim.g.mapleader = " "           -- Set leader key to space
vim.g.loaded_python3_provider = 0 -- Disable Python provider
vim.g.autoformat = true         -- Your config uses this

-- Check if set
if vim.g.autoformat then
  -- do something
end
```

### `vim.keymap.set` — Keymaps

```lua
-- Basic mapping
vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })

-- Modes: n=normal, i=insert, v=visual, x=visual block, o=operator-pending
--        t=terminal, c=command-line

-- Mapping to a Lua function
vim.keymap.set("n", "<leader>yp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "Copy buffer path" })

-- Buffer-local mapping
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })

-- Remove a mapping
vim.keymap.del("n", "<leader>w")
```

### `vim.api.nvim_create_autocmd` — Autocommands

```lua
-- Run something on an event
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.lua",
  callback = function()
    print("About to save a Lua file!")
  end,
})

-- Multiple events
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  callback = function()
    -- Auto-save logic
  end,
})

-- Filetype-specific
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function(args)
    vim.opt_local.foldmethod = "expr"
  end,
})
```

### `vim.api.nvim_create_user_command` — Custom Commands

```lua
vim.api.nvim_create_user_command("JavaFormatToggle", function()
  vim.g.java_autoformat = not vim.g.java_autoformat
  vim.notify("Java autoformat: " .. (vim.g.java_autoformat and "ON" or "OFF"))
end, { desc = "Toggle Java format on save" })

-- Now type :JavaFormatToggle
```

### `vim.fn` — Vimscript Functions

```lua
-- Call any Vimscript function from Lua
local cwd = vim.fn.getcwd()
local filename = vim.fn.expand("%:t")      -- Just filename
local filepath = vim.fn.expand("%:p")      -- Full path
local line_count = vim.fn.line("$")
local is_mac = vim.fn.has("mac") == 1

-- System calls
local files = vim.fn.systemlist("ls -la")
local output = vim.fn.system("git status")
```

### `vim.notify` — Notifications

```lua
vim.notify("Hello!", vim.log.levels.INFO)
vim.notify("Warning!", vim.log.levels.WARN)
vim.notify("Error!", vim.log.levels.ERROR)
```

### `vim.lsp.buf` — LSP Actions

```lua
vim.lsp.buf.definition()      -- Go to definition
vim.lsp.buf.references()      -- Find references
vim.lsp.buf.hover()           -- Show docs (same as K)
vim.lsp.buf.code_action()     -- Show code actions
vim.lsp.buf.rename()          -- Rename symbol
vim.lsp.buf.format()          -- Format buffer
vim.lsp.buf.implementation()  -- Go to implementation
```

### `vim.diagnostic` — Diagnostics (Errors/Warnings)

```lua
vim.diagnostic.open_float()   -- Show diagnostic under cursor
vim.diagnostic.goto_next()    -- Jump to next diagnostic
vim.diagnostic.goto_prev()    -- Jump to previous diagnostic
vim.diagnostic.setloclist()   -- Send diagnostics to location list
```

### `vim.treesitter` — Treesitter

```lua
-- Get parser for current buffer
local parser = vim.treesitter.get_parser()

-- Query syntax tree
local query = vim.treesitter.query.parse("lua", "(function_declaration) @func")
```

---

## 7. Your Config: File-by-File Walkthrough

Let's walk through YOUR actual config and understand every line.

### `init.lua`

```lua
require("config.lazy")
```

Just bootstraps lazy.nvim. The commented lines disable Perl/Ruby providers (faster startup).

### `lua/config/lazy.lua`

Bootstraps lazy.nvim, then calls `setup()` with three spec layers:

1. **LazyVim base**: `{ "LazyVim/LazyVim", import = "lazyvim.plugins" }`
2. **Extras**: Language support, debugging, testing, UI enhancements
3. **Your plugins**: `{ import = "plugins" }` — loads all files in `lua/plugins/`

Key settings:
- `lazy = false`: Your custom plugins load at startup (not lazy-loaded)
- `checker.enabled = true`: Auto-check for plugin updates
- `performance.rtp.disabled_plugins`: Disables unused built-in plugins for faster startup

### `lua/config/options.lua`

Your editor settings:

```lua
vim.g.loaded_python3_provider = 0     -- Disable Python3 provider (speed)

-- Indentation: 4 spaces
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4

-- Clipboard magic
vim.opt.clipboard = "unnamedplus"
```

**The clipboard section is sophisticated.** It detects:
- Termux (Android tablet SSH): uses `termux-clipboard-set/get`
- macOS local: uses `pbcopy/pbpaste`
- SSH/Tmux remote: uses tmux buffer + OSC 52 escape sequences

This is why copy/paste works everywhere for you.

### `lua/config/keymaps.lua`

Your custom keymaps:

```lua
"gh" / "gl"           -- Go to start/end of line (like ^ and $)
"<leader>fp"          -- Find projects in ~/Projects
"<leader>yp"          -- Copy full file path to clipboard
"<C-Up/Down/Left/Right>" -- Resize windows
"<M-Left/Right>"      -- Word movement in command line

-- CRITICAL: d/c/x go to black hole register
-- This means delete/cut does NOT overwrite your clipboard
vim.keymap.set("n", "d", '"_d', { noremap = true })
-- ... etc for D, c, C, x, X in both normal and visual mode
```

**Why black hole for d/c/x?** Because you set `clipboard = unnamedplus`, everything yanked goes to system clipboard. Without black hole, every `d` or `c` would overwrite your system clipboard. This keeps your clipboard clean — only `y` (yank) puts things there.

### `lua/config/autocmds.lua`

Your autocommands:

```lua
-- Word wrap for org files
-- No spellcheck for markdown
-- Auto-save for files in ORG_PATH
-- Auto-format Java on save (toggleable)
```

### `lua/plugins/catppuccin-rose.lua`

Your custom colorscheme. This is a **massive** override of Catppuccin:

```lua
return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,  -- Load FIRST (before other plugins)
  opts = {
    flavour = "frappe",
    transparent_background = true,
    color_overrides = { ... },  -- Your custom Rose Pine-ish colors
    custom_highlights = function(colors)
      return { ... }  -- Override specific highlight groups
    end,
    integrations = { ... },  -- Tell Catppuccin to theme these plugins
  },
}
```

**Key concept**: `priority = 1000` ensures this loads before plugins that depend on colors being defined. `custom_highlights` lets you override any highlight group (e.g., `Normal`, `CursorLine`, `markdownH1`).

### `lua/plugins/snacks.lua`

`snacks.nvim` is LazyVim's swiss-army knife. Your config:

```lua
opts = function(_, opts)
  opts.scroll.enabled = false        -- Disable scroll animations
  opts.dashboard.preset.header = ... -- Custom ASCII art header
  opts.picker = { ... }              -- File picker settings
  opts.image.enabled = false         -- Disable image rendering
  -- Custom highlight colors for dashboard
end
```

Snacks provides: dashboard, picker (replaces telescope), notifier, git blame, terminal, and more.

### `lua/plugins/mini-surround.lua`

Overrides LazyVim's default surround mappings:

```lua
opts = {
  mappings = {
    add = "gza",      -- Was gsaiw" (more verbose)
    delete = "gzd",
    replace = "gzr",
    -- ...
  },
}
```

### `lua/plugins/orgmode.lua`

Full org-mode setup with:
- Capture templates (todo, idea, journal)
- Custom todo states (TODO, PROGRESS, DONE)
- Custom highlights
- `org-bullets.nvim` for pretty bullets
- `org-super-agenda.nvim` for agenda views

### `lua/plugins/java.lua`

Sophisticated Java configuration:
- Custom fold expression for import blocks
- jdtls configuration (Java 21 for jdtls, Java 17 for project)
- Debug settings for decompiled sources
- Auto-format on save

### `lua/plugins/diffview.lua`

Git diff viewer:
- `<leader>gd` — Open diffview
- `<leader>gh` — File history
- `<leader>gH` — Repo history

### `lua/plugins/neotest.lua`

Test runner with Java adapter.

### `lua/plugins/devdocs.lua`

Offline documentation browser. Commands:
- `:DevdocsOpen` — Browse docs
- `:DevdocsOpenCurrent` — Docs for current filetype

---

## 8. Vim Motions & Text Objects: Beyond the Basics

You know `v`, `V`, `y`, `c`, `d`, `w`, `e`, `b`, `j`, `k`, `h`, `l`. Let's expand.

### Character-Level Motions

| Motion | Meaning |
|--------|---------|
| `f{char}` | Find forward to char (inclusive) |
| `F{char}` | Find backward to char (inclusive) |
| `t{char}` | Till forward (exclusive) |
| `T{char}` | Till backward (exclusive) |
| `;` | Repeat last f/F/t/T |
| `,` | Repeat last f/F/t/T in opposite direction |

```
Example: "hello world"
          ^
fw        -- cursor moves to 'w' (inclusive)
tw        -- cursor moves to space before 'w'
dfw       -- delete from cursor to and including 'w'
dtw       -- delete from cursor to but not including 'w'
```

### Word Motions (With Counts)

| Motion | What It Moves Over |
|--------|-------------------|
| `w` | Start of next word |
| `e` | End of current/next word |
| `b` | Start of previous word |
| `ge` | End of previous word |
| `W` | Same but for WORD (space-separated) |
| `E` | End of WORD |
| `B` | Back WORD |

```
2w    -- forward 2 words
d3w   -- delete 3 words
c2e   -- change to end of 2nd word
```

### Line Motions

| Motion | Meaning |
|--------|---------|
| `0` | Start of line (column 0) |
| `^` | First non-blank character |
| `$` | End of line |
| `g_` | Last non-blank character |
| `+` / `-` | First non-blank of next/previous line |
| `gg` | First line of file |
| `G` | Last line of file |
| `:{n}G` / `:{n}gg` | Go to line n |
| `H` | Top of screen (High) |
| `M` | Middle of screen |
| `L` | Bottom of screen (Low) |

### Screen Scrolling

| Key | Action |
|-----|--------|
| `Ctrl-u` | Up half screen |
| `Ctrl-d` | Down half screen |
| `Ctrl-b` | Up full screen (Back) |
| `Ctrl-f` | Down full screen (Forward) |
| `zz` | Center cursor on screen |
| `zt` | Cursor at top of screen |
| `zb` | Cursor at bottom of screen |

### Text Objects (The Secret Weapon)

Text objects are `i` (inside) or `a` (around) + a delimiter. They work with any operator (`d`, `c`, `y`, `v`, `=`).

#### Built-in Text Objects

| Object | Inside (`i`) | Around (`a`) |
|--------|-------------|--------------|
| `w` | Inner word | A word (with space) |
| `W` | Inner WORD | A WORD (with space) |
| `s` | Inner sentence | A sentence |
| `p` | Inner paragraph | A paragraph |
| `"` | Inside quotes | Including quotes |
| `'` | Inside single quotes | Including quotes |
| `` ` `` | Inside backticks | Including backticks |
| `(` or `b` | Inside parentheses | Including parentheses |
| `)` | Same as `(` | Same |
| `[` | Inside brackets | Including brackets |
| `{` or `B` | Inside braces | Including braces |
| `<` | Inside angle brackets | Including angle brackets |
| `t` | Inside HTML/XML tag | Including tag |

```
vi"     -- select inside quotes
va"     -- select around quotes (includes the quote chars)
di'     -- delete inside single quotes
cat     -- change around HTML tag (includes <tag> and </tag>)
yap     -- yank a paragraph
dip     -- delete inner paragraph
gUiw    -- make inner word UPPERCASE
gUiW    -- make inner WORD UPPERCASE
```

#### Treesitter Text Objects (Your Config Has These!)

LazyVim includes `nvim-treesitter-textobjects`. This adds semantic text objects:

| Object | What It Selects |
|--------|----------------|
| `af` / `if` | Around/inside function |
| `ac` / `ic` | Around/inside class |
| `aa` / `ia` | Around/inside parameter/argument |
| `ao` / `io` | Around/inside loop |
| `ai` / `ii` | Around/inside conditional (if statement) |

```
vaf     -- select around function
vif     -- select inside function body
daf     -- delete entire function
```

**To see all available text objects**: `:help nvim-treesitter-textobjects`

### Operator-Pending Mode

When you type `d`, `c`, `y`, `gU`, etc., Vim enters "operator-pending" mode. It waits for a motion or text object.

| Operator | Action |
|----------|--------|
| `d` | Delete |
| `c` | Change (delete + insert) |
| `y` | Yank (copy) |
| `>` | Indent right |
| `<` | Indent left |
| `=` | Auto-indent |
| `gU` | Make uppercase |
| `gu` | Make lowercase |
| `g~` | Toggle case |
| `!` | Filter through external program |

```
diw     -- delete inner word
gU$     -- uppercase to end of line
=yap    -- auto-indent a paragraph
!apfmt  -- format paragraph with `fmt` command
```

### The Dot Command (`.`)

`.` repeats the last change. This is one of Vim's most powerful features.

```
ciwhello<Esc>    -- change inner word to "hello"
j.               -- on next line, repeat the change
j.               -- again
3j.              -- repeat on line 3 down
```

### Surround Operations (mini.surround in Your Config)

Your config uses `mini.surround` with `gz` prefix:

| Mapping | Action |
|---------|--------|
| `gza"` | Add surrounding quotes around text object |
| `gzd"` | Delete surrounding quotes |
| `gzr"'` | Replace surrounding " with ' |
| `gzf"` | Find surrounding " to the right |
| `gzF"` | Find surrounding " to the left |
| `gzh"` | Highlight surrounding " |

```
gzaiw"      -- add " around inner word
--> "word"
gzda"       -- delete " around cursor
--> word
gzra"'      -- replace " with ' around cursor
--> 'word'
```

---

## 9. Registers, Macros, and Recordings

### Registers

Vim has named registers `a-z`. You can yank/delete into specific registers and paste from them.

```
"ayy       -- yank line into register a
"ap        -- paste from register a
"Add       -- delete line, append to register a (capital = append)
"+yy       -- yank to system clipboard (+ register)
"*yy       -- yank to primary selection (* register)
"0p        -- paste from register 0 (last yank, unaffected by delete)
"_dd       -- delete to black hole (your config does this by default)
```

**Special registers:**

| Register | Content |
|----------|---------|
| `"` | Unnamed (default) |
| `0` | Last yank |
| `1-9` | Delete history (1 = most recent) |
| `+` | System clipboard |
| `*` | Primary selection |
| `/` | Last search pattern |
| `:` | Last command-line |
| `.` | Last inserted text |
| `%` | Current file name |
| `#` | Alternate file name |
| `=` | Expression register (CALCULATOR!) |

**The expression register (`=`) is amazing:**

```
In insert mode:
<C-r>=    -- then type a math expression
<C-r>=2+2<CR>    -- inserts "4"
<C-r>=strftime("%Y-%m-%d")<CR>  -- inserts current date
```

### Viewing Registers

```vim
:registers        -- show all registers
:reg a            -- show register a
:reg +            -- show clipboard
```

### Macros (Recordings)

Macros record keystrokes into a register.

```
qa        -- start recording into register a
... do stuff ...
q         -- stop recording
@a        -- play back macro a
@@        -- repeat last macro
5@a       -- play macro a 5 times
```

**Example: Add semicolon to end of 10 lines:**

```
qa        -- start recording
A;<Esc>   -- append ; at end of line, exit insert
j         -- go down one line
q         -- stop recording
9@a       -- repeat on next 9 lines
```

**Editing a macro:**

```
"ap       -- paste macro a into buffer
... edit the text ...
"ay$      -- yank line back into register a
```

### Advanced Macro Tips

```
:let @a = @a . 'j'    -- append 'j' to macro a
:let @a = ''            -- clear macro a
```

---

## 10. Command-Line Mode: The Real Power User Tool

Press `:` to enter command-line mode. This is where you run Ex commands.

### Essential Commands

| Command | Action |
|---------|--------|
| `:w` | Save |
| `:q` | Quit |
| `:wq` / `:x` | Save and quit |
| `:q!` | Quit without saving |
| `:e file` | Edit file |
| `:vs file` | Vertical split |
| `:sp file` | Horizontal split |
| `:bd` | Close buffer |
| `:bn` / `:bp` | Next/previous buffer |
| `:ls` | List buffers |
| `:b5` | Go to buffer 5 |
| `:tabnew` | New tab |
| `:tabc` | Close tab |
| `:tabn` / `:tabp` | Next/previous tab |
| `:sh` | Shell (exit with `exit` or Ctrl-d) |

### Ranges

```vim
:5,10d          -- delete lines 5-10
:%d             -- delete all lines
:1,$s/foo/bar/g -- substitute foo->bar in entire file
:'<,'>s/foo/bar/g -- substitute in visual selection
:g/pattern/d    -- delete all lines matching pattern
:v/pattern/d    -- delete all lines NOT matching pattern (inverse)
```

### Global Command (`:g`)

```vim
:g/TODO/t$      -- copy all TODO lines to end of file
:g/^$/d         -- delete all empty lines
:g/^\s*$/d      -- delete all blank lines
:g/console.log/d -- delete all console.log lines
```

### Substitution Mastery

```vim
:s/old/new/        -- first occurrence on current line
:s/old/new/g       -- all occurrences on current line
:%s/old/new/g      -- all occurrences in file
:%s/old/new/gc     -- all occurrences, confirm each
:%s/old/new/gi     -- case-insensitive
:%s/\s\+$//g       -- remove trailing whitespace
:%s/^\n\+//g     -- collapse multiple blank lines
```

### Command-Line Editing

When in `:` prompt:

| Key | Action |
|-----|--------|
| `<C-a>` | Beginning of line |
| `<C-e>` | End of line |
| `<C-w>` | Delete word backward |
| `<C-u>` | Delete to beginning |
| `<C-p>` / `<C-n>` | Previous/next command from history |
| `<C-f>` | Open command-line window (HUGE!) |
| `<C-r>+` | Paste from clipboard |
| `<C-r>"` | Paste from unnamed register |
| `<C-r>=` | Expression register |
| `<Tab>` | Auto-complete |

**The command-line window (`q:` or `<C-f>` from `:`) lets you edit commands like normal text!**

```
q:              -- open command history in a window
... navigate with j/k, edit a command ...
<CR>            -- execute the command under cursor
```

---

## 11. Changing Keymaps: The Complete Guide

### Understanding Your Current Keymaps

```vim
:nmap            -- show all normal mode mappings
:imap            -- show all insert mode mappings
:vmap            -- show all visual mode mappings
:map <leader>    -- show all leader mappings
:verbose nmap <leader>w   -- show what mapped <leader>w and where
```

### LazyVim's Default Leader Mappings

LazyVim uses `<Space>` as leader. Here are the main prefixes:

| Prefix | Category |
|--------|----------|
| `<leader>b` | Buffer |
| `<leader>c` | Code (LSP) |
| `<leader>d` | Debug |
| `<leader>f` | File/Find |
| `<leader>g` | Git |
| `<leader>h` | Help |
| `<leader>l` | LSP |
| `<leader>n` | Notifications |
| `<leader>q` | Quit/Session |
| `<leader>s` | Search |
| `<leader>t` | Test |
| `<leader>u` | UI toggle |
| `<leader>w` | Window |
| `<leader>x` | Diagnostics |
| `<leader>,` | Switch buffer |
| `<leader>/` | Search in file |
| `<leader><Space>` | Find files |
| `<leader>:` | Command history |

### How to Override a LazyVim Keymap

```lua
-- In lua/config/keymaps.lua
-- Override LazyVim's default <leader>ff (find files)
vim.keymap.set("n", "<leader>ff", function()
  Snacks.picker.files({ hidden = true })
end, { desc = "Find Files (including hidden)" })
```

### How to Remove a Keymap

```lua
vim.keymap.del("n", "<leader>ff")
```

### Buffer-Local Keymaps

```lua
-- Only active in specific filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function(args)
    vim.keymap.set("n", "<leader>pr", "<cmd>PythonRun<cr>", {
      buffer = args.buf,
      desc = "Run Python file",
    })
  end,
})
```

### Which-Key Groups

LazyVim uses `which-key` to show help. You can add descriptions:

```lua
-- In a plugin spec or init
vim.keymap.set("n", "<leader>z", function() end, { desc = "+Custom" })
vim.keymap.set("n", "<leader>za", function() print("A") end, { desc = "Action A" })
vim.keymap.set("n", "<leader>zb", function() print("B") end, { desc = "Action B" })
```

Press `<leader>z`, wait, and which-key shows your group.

---

## 12. How to Make or Modify Plugins

### Modifying an Existing Plugin's Behavior

```lua
-- Override a plugin's options
return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    -- opts is the table that WILL be passed to setup()
    -- Modify it in place
    opts.picker.show_delay = 0
    return opts
  end,
}
```

### Disabling a Plugin

```lua
return {
  "folke/trouble.nvim",
  enabled = false,  -- This plugin won't load at all
}
```

### Adding a Dependency

```lua
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-fzf-native.nvim",
  },
}
```

### Conditional Loading

```lua
return {
  "iamkarasik/sonarqube.nvim",
  cond = function()
    return os.getenv("PERSONAL") ~= "1"
  end,
}
```

### Creating a Simple Plugin

A "plugin" is just a Lua module that does something when required:

```lua
-- lua/myplugin.lua
local M = {}

function M.setup(opts)
  opts = opts or {}
  local prefix = opts.prefix or "[MyPlugin]"

  vim.api.nvim_create_user_command("MyPluginHello", function()
    vim.notify(prefix .. " Hello!")
  end, {})
end

return M
```

```lua
-- In your plugin spec
return {
  dir = "~/dotfiles/nvim/lua/myplugin",  -- or a git repo
  config = function()
    require("myplugin").setup({ prefix = "[Awesome]" })
  end,
}
```

### Using `init.lua` for Simple Plugins

For tiny one-off things, you don't need a separate repo:

```lua
-- lua/plugins/my-hacks.lua
return {
  "my-hacks",  -- dummy name
  dir = vim.fn.stdpath("config") .. "/lua/my-hacks",
  config = function()
    -- Your code here
  end,
}
```

---

## 13. Learning Neovim *From Inside* Neovim

### Built-in Tutor

```vim
:Tutor          -- Interactive vim tutorial (30 min)
```

### Vimtutor from Shell

```bash
vimtutor        -- Same thing, from terminal
```

### `:checkhealth`

```vim
:checkhealth        -- Diagnose your Neovim setup
:checkhealth lazy   -- Check lazy.nvim health
:checkhealth lsp    -- Check LSP health
```

### The `:messages` Command

```vim
:messages           -- Show all notifications/errors
:messages clear     -- Clear message history
```

### Inspecting Your Config

```vim
:echo $MYVIMRC              -- Show path to init.lua
:lua print(vim.fn.stdpath("config"))   -- Config directory
:lua print(vim.fn.stdpath("data"))     -- Data directory (plugins)
:lua print(vim.inspect(vim.opt.tabstop:get()))  -- Get option value
```

### Live Lua Execution

```vim
:lua print("hello")         -- Execute Lua
:lua =vim.opt.number        -- Print value (= is shorthand for print(vim.inspect(...)))
:lua =package.loaded        -- See all loaded modules
:lua =vim.api.nvim_list_bufs()  -- List all buffers
```

### Keymap Discovery

```vim
:nmap <leader>f             -- Show what <leader>f does
:verbose nmap <leader>ff    -- Show source file for mapping
:map                        -- Show ALL mappings
```

### Plugin Discovery

```vim
:Lazy                       -- Open lazy.nvim UI
  -- Press ? for help in Lazy UI
  -- Press i to see plugin info
  -- Press l to see logs
```

### Treesitter Playground

If installed, this shows the AST:

```vim
:TSPlaygroundToggle         -- Show syntax tree
:TSHighlightCapturesUnderCursor  -- Show highlight group under cursor
```

### LSP Info

```vim
:LspInfo                    -- Show active LSP clients
:LspLog                     -- Show LSP logs
```

### Profiling Startup

```bash
# From shell
nvim --startuptime startup.log
# Then read startup.log to see what's slow
```

```lua
-- In Neovim, profile Lua
:lua require("plenary.profile").start("profile.log")
-- ... do stuff ...
:lua require("plenary.profile").stop()
```

---

## 14. Plugin Recommendations for Leveling Up

You already have a solid setup. Here are plugins to consider for specific skill-building:

### For Learning Vim Properly

| Plugin | What It Does | Why Get It |
|--------|-------------|------------|
| `m4xshen/hardtime.nvim` | Restricts repeated keys (hjkl spam) | Forces you to use proper motions |
| `tris203/precognition.nvim` | Shows possible motions as virtual text | Teaches you what motions are available |
| `ThePrimeagen/vim-be-good` | Vim motion minigames | Fun practice |
| `tjdevries/train.nvim` | Train yourself on motions | Drills |

### For Advanced Editing

| Plugin | What It Does |
|--------|-------------|
| `gbprod/substitute.nvim` | Better substitution (like `s` but with registers) |
| `Wansmer/treesj` | Split/join code blocks (toggle multi-line) |
| `chrisgrieser/nvim-spider` | Better `w`/`e`/`b` that respects camelCase |
| `numToStr/Comment.nvim` | Smart commenting (you likely have this via LazyVim) |
| `kylechui/nvim-surround` | Alternative to mini.surround |

### For Code Navigation

| Plugin | What It Does |
|--------|-------------|
| `rgroli/other.nvim` | Switch between related files (test/src, header/impl) |
| `dmmulroy/tsc.nvim` | TypeScript project-wide type checking |
| `SmiteshP/nvim-navbuddy` | Symbol navigation popup |

### For Debugging Mastery

You have `nvim-dap` via LazyVim extras. Learn it:

```vim
:help dap.txt
```

Key LazyVim debug mappings (check with `:nmap <leader>d`):
- `<leader>db` — Toggle breakpoint
- `<leader>dB` — Conditional breakpoint
- `<leader>dc` — Continue/start debugging
- `<leader>di` — Step into
- `<leader>do` — Step over
- `<leader>dO` — Step out
- `<leader>dr` — Open REPL
- `<leader>du` — Toggle DAP UI

### For Git Mastery

You have `gitsigns` and `diffview`. Consider:

| Plugin | What It Does |
|--------|-------------|
| `NeogitOrg/neogit` | Magit-like git interface |
| `sindrets/diffview.nvim` | You already have this! |
| `tpope/vim-fugitive` | The classic git plugin |
| `aaronhallaert/advanced-git-search.nvim` | Search git history with telescope |

### For Note-Taking/Org

You already have `orgmode`. Also consider:

| Plugin | What It Does |
|--------|-------------|
| `nvim-neorg/neorg` | Alternative to orgmode, more "Neovim-native" |
| `epwalsh/obsidian.nvim` | Obsidian vault integration |
| `lukas-reineke/headlines.nvim` | Better markdown headers |

---

## 15. Quick Reference Cheat Sheet

### Modes

| Mode | How to Enter | How to Exit |
|------|-------------|-------------|
| Normal | `<Esc>` or `Ctrl-[` | (default) |
| Insert | `i`, `a`, `o`, `I`, `A`, `O` | `<Esc>` |
| Visual | `v` | `<Esc>` |
| Visual Line | `V` | `<Esc>` |
| Visual Block | `Ctrl-v` | `<Esc>` |
| Command-line | `:` | `<Esc>` or `<CR>` |
| Terminal | `:term` | `Ctrl-\ Ctrl-n` |

### Essential Normal Mode

| Key | Action |
|-----|--------|
| `i` | Insert before cursor |
| `a` | Insert after cursor |
| `I` | Insert at start of line |
| `A` | Insert at end of line |
| `o` | Open line below |
| `O` | Open line above |
| `u` | Undo |
| `Ctrl-r` | Redo |
| `.` | Repeat last change |
| `x` | Delete character |
| `r` | Replace character |
| `R` | Replace mode |
| `J` | Join lines |
| `~` | Toggle case |
| `>>` | Indent line |
| `<<` | Unindent line |
| `==` | Auto-indent line |
| `gg=G` | Auto-indent entire file |
| `Ctrl-a` | Increment number |
| `Ctrl-x` | Decrement number |

### Window Management

| Key | Action |
|-----|--------|
| `Ctrl-w s` | Horizontal split |
| `Ctrl-w v` | Vertical split |
| `Ctrl-w c` | Close window |
| `Ctrl-w o` | Only this window |
| `Ctrl-w h/j/k/l` | Navigate windows |
| `Ctrl-w H/J/K/L` | Move window |
| `Ctrl-w =` | Equalize windows |
| `Ctrl-w _` | Maximize height |
| `Ctrl-w |` | Maximize width |
| `Ctrl-w r` | Rotate windows |
| `Ctrl-w x` | Exchange with next |

### Tabs

| Key | Action |
|-----|--------|
| `gt` | Next tab |
| `gT` | Previous tab |
| `ngt` | Go to tab n |
| `:tabnew` | New tab |
| `:tabc` | Close tab |
| `:tabo` | Close other tabs |

### Marks

```
ma        -- set mark a
`a        -- jump to mark a (exact position)
'a        -- jump to mark a (start of line)
:marks    -- list marks
```

### Jumps

| Key | Action |
|-----|--------|
| `Ctrl-o` | Older position in jump list |
| `Ctrl-i` | Newer position in jump list |
| `gf` | Go to file under cursor |
| `gF` | Go to file:line under cursor |
| `gd` | Go to definition (LSP) |
| `gD` | Go to declaration |
| `gr` | Go to references (LSP) |
| `gi` | Go to implementation (LSP) |
| `K` | Show hover docs (LSP) |

### Search

| Key | Action |
|-----|--------|
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` | Next match |
| `N` | Previous match |
| `*` | Search word under cursor forward |
| `#` | Search word under cursor backward |
| `g*` | Partial word search forward |
| `g#` | Partial word search backward |

### Search and Replace

```vim
:%s/old/new/g          -- global replace
:%s/old/new/gc         -- with confirmation
:'<,'>s/old/new/g      -- in visual selection
:5,10s/old/new/g       -- lines 5-10
```

### Folding

| Key | Action |
|-----|--------|
| `zf` | Create fold |
| `zo` | Open fold |
| `zc` | Close fold |
| `za` | Toggle fold |
| `zR` | Open all folds |
| `zM` | Close all folds |
| `zj` | Next fold |
| `zk` | Previous fold |

### Your Custom Keymaps (Quick Ref)

| Key | What It Does | Defined In |
|-----|-------------|------------|
| `gh` | Go to start of line | `keymaps.lua` |
| `gl` | Go to end of line | `keymaps.lua` |
| `<leader>fp` | Find projects | `keymaps.lua` |
| `<leader>yp` | Copy file path | `keymaps.lua` |
| `<C-Arrow>` | Resize windows | `keymaps.lua` |
| `d` / `c` / `x` | Black hole delete | `keymaps.lua` |
| `<leader>n` | Notification history | `snacks.lua` |
| `<leader>gb` | Git blame line | `snacks.lua` |
| `<leader>gd` | Open diffview | `diffview.lua` |
| `<leader>gh` | File history | `diffview.lua` |
| `gza` | Add surround | `mini-surround.lua` |
| `gzd` | Delete surround | `mini-surround.lua` |
| `gzr` | Replace surround | `mini-surround.lua` |
| `<C-h/j/k/l>` | Tmux/navigate splits | `vim-tmux-navigator.lua` |
| `<leader>cv` | Select Python venv | `python.lua` |
| `<leader>os` | Org super agenda | `orgmode.lua` |
| `:JavaFormatToggle` | Toggle Java format | `autocmds.lua` |
| `:FormatProject` | Format all Java files | `keymaps.lua` |

---

## Appendix A: Your Config File Map

```
nvim/
├── init.lua                          -- Entry point: requires config.lazy
├── lua/
│   ├── config/
│   │   ├── lazy.lua                  -- Bootstraps lazy.nvim, loads 3 spec layers
│   │   ├── options.lua               -- Editor options (tabs, clipboard, etc.)
│   │   ├── keymaps.lua               -- Your custom keymaps
│   │   └── autocmds.lua              -- Auto-commands (format on save, etc.)
│   └── plugins/
│       ├── catppuccin-rose.lua       -- Custom colorscheme palette
│       ├── colorscheme.lua           -- Applies catppuccin-rose as theme
│       ├── snacks.lua                -- Snacks.nvim config (picker, dashboard)
│       ├── mini-surround.lua         -- Surround mappings override
│       ├── oil.lua                   -- File browser
│       ├── bufferline.lua            -- Tab/buffer line
│       ├── lualine.lua               -- Status line colors
│       ├── git-highlights.lua        -- Diff colors
│       ├── colorizer.lua             -- Color preview in code
│       ├── diffview.lua              -- Git diff viewer
│       ├── snacks-diffview.lua       -- Snacks + diffview bridge
│       ├── vim-tmux-navigator.lua    -- Tmux pane navigation
│       ├── markdown.lua              -- Markdown rendering
│       ├── orgmode.lua               -- Org-mode setup
│       ├── devdocs.lua               -- Offline docs browser
│       ├── java.lua                  -- Java LSP & debug config
│       ├── python.lua                -- Python LSP & venv
│       ├── neotest.lua               -- Test runner
│       ├── dap-ui.lua                -- Debug UI settings
│       ├── conform.lua               -- Formatter config
│       ├── neodev.lua                -- Lua dev helpers
│       ├── sonarqube.lua             -- SonarQube integration
│       ├── codecompanion.lua         -- AI chat (disabled)
│       ├── ascii.lua                 -- ASCII art for dashboard
│       └── example.lua               -- Template (not loaded)
├── colors/
│   └── catppuccin-rose.lua           -- Custom colorscheme definition
├── conform/
│   └── formatters/
│       └── org_space_todos.lua       -- Custom org formatter
└── JAVA_SETUP.md                     -- Java setup notes
```

## Appendix B: Recommended Learning Path

1. **Week 1**: Read `:Tutor` (30 min). Practice `f/F/t/T`, text objects (`ci"`, `dap`), and the dot command.
2. **Week 2**: Master registers (`"ayy`, `"ap`) and record your first macro (`qa...q`, `@a`).
3. **Week 3**: Explore your config. Open each file, read it, and understand what it does.
4. **Week 4**: Learn `:g` and substitution. Delete all `console.log` lines in a project with one command.
5. **Week 5**: Use `:help` for everything. When you don't know a mapping, `:verbose nmap <key>`.
6. **Ongoing**: Add one custom keymap per week. Make it solve a real problem you have.

## Appendix C: Quick Lua Snippets for Your Config

```lua
-- Print the current highlight group under cursor
vim.api.nvim_create_user_command("ShowHighlight", function()
  local id = vim.fn.synID(vim.fn.line("."), vim.fn.col("."), 1)
  local name = vim.fn.synIDattr(id, "name")
  local trans = vim.fn.synIDattr(vim.fn.synIDtrans(id), "name")
  print("Highlight: " .. name .. " -> " .. trans)
end, {})

-- Toggle a boolean option
vim.api.nvim_create_user_command("ToggleWrap", function()
  vim.opt.wrap = not vim.opt.wrap:get()
end, {})

-- Show all loaded plugins
vim.api.nvim_create_user_command("LoadedPlugins", function()
  for name, _ in pairs(package.loaded) do
    if name:match("^plugins") then
      print(name)
    end
  end
end, {})
```

---

> **Final thought**: Neovim is not about memorizing every command. It's about knowing the *patterns* — motions, text objects, operators, registers — and knowing where to look when you need more. Your config is already excellent. Now you own it.
