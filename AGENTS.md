# AGENTS.md

Guidance for agents working in this dotfiles repository.

## Repository Overview

This is a personal macOS development environment dotfiles repository with configurations for:
- **Shell (Zsh)** - zshrc, starship.toml
- **Terminal (Ghostty)** - ghostty/config with custom shaders
- **Editor (Neovim)** - LazyVim-based configuration in nvim/
- **Terminal Multiplexer (Tmux)** - Modular tmux configuration
- **CLI Tools** - Configurations for atuin, lazygit, fd, ripgrep, bat, etc.

This is **NOT** a compiled software project. There are no build commands, tests, or CI pipelines. Changes are primarily configuration edits and script updates.

## Quick Commands

### Installation & Verification
```bash
cd ~/dotfiles
./install.sh                    # Full setup with backups, Oh My Zsh, TPM, symlinks
bash -n zshrc                   # Validate zsh syntax (no execution)
bash -n install.sh              # Validate shell script syntax
```

### Configuration Validation
```bash
nvim -c "checkhealth"          # Check Neovim health (LazyVim, LSPs, tools)
zsh -n ~/.zshrc                # Validate zshrc without sourcing
tmux -f tmux/tmux.conf new -d  # Test tmux config (creates detached session)
```

### Commonly Edited Files
- `zshrc` - Shell aliases, functions, environment, plugin setup
- `starship.toml` - Prompt configuration
- `nvim/init.lua` - Neovim entry point
- `nvim/lua/config/` - Core settings (keymaps, options, autocmds)
- `nvim/lua/plugins/` - Plugin configurations
- `tmux/tmux.conf` - Main tmux config (sources modular configs)
- `tmux/conf/settings.conf`, `keybindings.conf`, `plugins.conf` - Modular tmux
- `ghostty/config` - Terminal emulator settings
- `atuin/config.toml` - Shell history configuration

## Code Style Guidelines

### Shell Scripts (Bash/Zsh)

**Formatting & Syntax**
- Use 4-space indentation
- Quote all variables: `"$VAR"` not `$VAR`
- Use `set -e` in scripts to exit on error
- Check file existence before operations: `[ -d "$path" ]` or `[ -e "$file" ]`
- Use `()` for subshells, `{}` for code blocks
- Prefer `[[` over `[` in bash/zsh (more features, fewer edge cases)

**Naming Conventions**
- Function names: lowercase with underscores (e.g., `backup_config()`)
- Constants: UPPERCASE (e.g., `BACKUP_DIR`)
- Variables: lowercase or camelCase for clarity

**Error Handling**
- Always handle errors in critical paths
- Use `|| exit 1` for commands that shouldn't fail silently
- Provide helpful error messages with context
- Log operations with progress indicators (e.g., "✓ Installed X")

**Example Pattern** (from install.sh):
```bash
backup_if_exists() {
    if [ -e "$1" ] && [ ! -L "$1" ]; then
        echo "📦 Backing up $1 to $backup_dir"
        mv "$1" "$backup_dir/"
    elif [ -L "$1" ]; then
        echo "🔗 Removing existing symlink $1"
        rm "$1"
    fi
}
```

### Lua Configuration (Neovim)

**Structure** (per LazyVim conventions)
- Entry point: `nvim/init.lua`
- Settings: `nvim/lua/config/options.lua`, `keymaps.lua`, `autocmds.lua`
- Plugins: `nvim/lua/plugins/*.lua` (one file per plugin or feature)
- Each plugin file returns a table with `{ "plugin/name", ... }`

**Formatting & Syntax**
- Use 2-space indentation (LazyVim standard)
- Lua uses `--` for comments, `--[[...]]` for blocks
- Table keys: `{ key = value }` for clarity
- String keys in tables can omit quotes if valid identifiers

**Naming Conventions**
- Plugin files: descriptive names (e.g., `colorscheme.lua`, `codecompanion.lua`)
- Keymaps: use descriptive names in which_key groups
- Functions: lowercase with underscores

**Error Handling**
- Use `pcall()` for operations that might fail
- Log errors with `vim.notify()` or `vim.warn_notify()`
- Check for tool/LSP availability before configuring

**Plugin Pattern** (LazyVim):
```lua
return {
  "plugin/namespace",
  opts = {
    -- configuration merged with defaults
  },
  config = function(_, opts)
    require("plugin").setup(opts)
  end,
}
```

### TOML Configuration (starship.toml, atuin config)

**Format**
- Use `[section]` headers for module grouping
- String values in quotes: `"value"`
- Boolean: `true` or `false`
- Colors: Use theme names (e.g., `"Catppuccin Frappe"`)

**Naming**
- Follow tool's documented option names exactly
- Comment non-obvious configurations
- Group related settings together

### Git Workflow

**Commit Messages**
- Concise, descriptive: "update zshrc aliases" or "add codecompanion plugin"
- Scope common: tmux, nvim, zshrc, install, etc.
- Examples from repo: "lazygit commit aliases", "neotest, docker colima fixes"

**File Organization**
- Keep related configs together (tmux/ modular configs, nvim/ plugins grouped)
- Use .gitignore for machine-specific overrides (`.zshrc.local`)
- Symlinks created during install.sh preserve repo structure

## Code Patterns & Conventions

### Using Catppuccin Theme
All tools use **Catppuccin Frappe** (or Mocha/Macchiato variants):
- Terminal: Ghostty config specifies theme
- Prompt: Starship config uses Catppuccin colors
- Editor: Set in `nvim/lua/plugins/colorscheme.lua`
- Git: Lazygit uses GitHub-style colors (configured in repo)
- Pager: BAT_THEME environment variable in zshrc

When modifying themes, maintain consistency across all tools.

### Vim Keybindings
- All tools support Vim keybindings consistently
- Zsh: `bindkey -v` enables vi mode
- Tmux: Custom keybindings in `tmux/conf/keybindings.conf`
- Neovim: Keymaps configured in `nvim/lua/config/keymaps.lua`

### Lazy Loading Patterns
- **Pyenv**: Lazy-loaded in zshrc (deferred until needed)
- **Plugins**: Lazy-loaded by Tmux Plugin Manager (TPM) and LazyVim
- Goal: Fast shell startup (sub-500ms ideally)

### Cross-Machine Configuration
- Machine-specific settings: `~/.zshrc.local` (sourced if exists, ignored by git)
- Secrets/API keys: ONLY in `.zshrc.local`, never in repo
- Portable configs: Keep most settings in dotfiles, override selectively

## Imports & Dependencies

**Shell Dependencies** (installed via Homebrew before install.sh):
- Core: ghostty, neovim, tmux, zsh
- Prompt: starship, zoxide, atuin
- CLI tools: bat, eza, fd, ripgrep, fzf, delta, glow, lazygit, fastfetch
- Optional: pyenv (Python), nvm/fnm (Node)

**Neovim Plugin Manager**
- LazyVim handles plugin loading automatically
- Plugin specs in `nvim/lua/plugins/*.lua`
- Install/update via `:Lazy` command in Neovim

**Tmux Plugin Manager (TPM)**
- Located at ~/.tmux/plugins/
- Install plugins after install.sh: tmux → Ctrl+Space+Shift+I
- Plugins defined in `tmux/conf/plugins.conf`

**Oh My Zsh**
- Framework: ~/.oh-my-zsh
- Custom plugins: ~/.oh-my-zsh/custom/plugins/
- Plugins used: git, zsh-autosuggestions, zsh-syntax-highlighting, docker-compose

## Modification Guidelines

### When Editing Configuration Files

1. **Before editing**: Understand which tool uses it (check file path)
2. **Test changes**: Use validation commands above (e.g., `bash -n zshrc`)
3. **Preserve structure**: Don't remove required configuration sections
4. **Document changes**: Use git commits with clear messages
5. **Machine-specific overrides**: Use `.zshrc.local`, not main configs
6. **Reload configs**: 
   - Zsh: `source ~/.zshrc` or new terminal
   - Tmux: `tmux source-file ~/.tmux.conf` or restart
   - Neovim: `:source %` or restart

### Common Edits

**Adding shell aliases**: Edit `zshrc` alias section, validate, reload
**Adding keybinds**: Neovim in `nvim/lua/config/keymaps.lua`, Tmux in `tmux/conf/keybindings.conf`
**Adding plugins**: Neovim in `nvim/lua/plugins/`, Tmux in `tmux/conf/plugins.conf`
**Changing theme**: Update theme names across zshrc, starship.toml, nvim colors plugin
**System-specific tweaks**: Add to `.zshrc.local`, never commit sensitive data

## Key Integration Points

- **Shell → Editor**: Zsh functions pipe to Neovim for editing (`ffe`, `opencode`)
- **Shell → Git**: Git aliases integrated in zshrc, lazygit as UI
- **Shell → Tmux**: Startup sourced in tmux, vim navigation shared
- **Neovim → Tmux**: Seamless pane navigation with vim-tmux-navigator plugin
- **All tools → Theme**: Catppuccin Frappe colors unified

## Important Notes

- **No tests or CI**: Changes don't require passing tests. Validate syntax and test manually.
- **Installation idempotent**: install.sh can run multiple times safely (backs up existing configs)
- **Symlink structure**: Repo files symlinked to ~/.config/ (XDG Base Directory Spec)
- **Recent additions**: Codecompanion plugin (Jan 12), neotest, docker colima fixes
- **Development**: Main branch is stable; create feature branches for experimental changes

When in doubt, refer to CLAUDE.md for architectural details or specific tool documentation.
