# Agent Sandboxing Setup

Consolidated guide for Pi (home & work), Codex, Cursor, and Claude Code.
Copy this repo to your work machine and run `install.sh` — it symlinks everything.

---

## Philosophy

**Open network, restricted commands, protected credentials.**

- Network is open by default (you use too many services to enumerate)
- Only destructive commands are blocked (git force push, rm -rf, AWS mutations)
- Only credential files are blocked from reads (~/.ssh, .env, auth.json)
- Only critical config files are blocked from writes (~/.zshrc, ~/.bashrc)

This is the "good intern" model. The agent can work freely, install packages,
do web research, call any API. It just can't destroy things or steal secrets.

---

## Install fence (all machines)

```bash
brew tap fencesandbox/tap
brew install fencesandbox/tap/fence

# Verify
fence --version
fence config show  # see the active config
```

---

## Config

The fence config is at `~/.config/fence/fence.jsonc` (symlinked from dotfiles).

It extends the `code-relaxed` template which:

- Allows all outbound network (no allowlist needed)
- Allows local binding and localhost outbound
- Block reads of SSH keys, AWS creds, GPG, Kube, Docker configs
- Allows writes to all coding agent directories (~/.claude, ~/.codex, ~/.cursor, ~/.pi, etc.)
- Blocks writes to .env, .pem, .key files

On top of that, our config adds:

- Command deny: git force push, rm -rf, sudo, curl|sh, aws mutations
- File denyRead: ~/.npmrc, .env, gh auth files, org notes
- File denyWrite: ~/.zshrc, ~/.zshenv, ~/.bashrc
- Network deny: cloud metadata endpoints, telemetry

See `dotfiles/.config/fence/fence.jsonc` for the full config.

---

## Aliases (`~/.zshrc`)

```bash
# These are auto-loaded from zshrc.d/fence.zsh (symlinked from dotfiles)
alias pi='fence -- pi'                # Default: fence-wrapped Pi
alias pi-read='fence --block-net -- pi'  # No network (untrusted projects)
```

For work machine, uncomment in `zshrc.d/fence.zsh`:

```bash
# alias codex='fence -- codex'
# alias claude='fence -- claude'
```

---

## Pi Setup (home & work)

Pi has no built-in sandbox — fence wraps it. That's the whole setup.

### Verify

```bash
# fence blocks destructive commands
fence -- bash -c "git push --force"    # → blocked
fence -- bash -c "aws ec2 terminate-instances"  # → blocked

# fence allows normal commands
fence -- bash -c "echo ok"             # → ok

# Pi runs under fence
fence -- pi -p "echo 'hello'"          # → hello
```

---

## Codex CLI Setup (work machine)

### `~/.codex/config.toml`

```toml
[sandbox]
mode = "workspace-write"  # write to project dir only

[permissions]
mode = "accept_edits"  # auto-approve edits, ask for commands
auto_approved_commands = [
  "git diff", "git log", "git status",
  "npm test", "npm run build", "npm install",
  "brew install", "brew update",
  "ls", "cat", "curl",
  "python3", "node", "go build", "make",
  "mvn", "gradle", "docker"
]

[secrets]
files = [
  "**/.env", "**/.env.*", "**/*.pem", "**/*.key",
  "**/auth.json", "**/credentials*"
]
```

---

## Cursor Setup (work machine)

In VS Code → Settings → Cursor Settings → Agent:

| Setting | Value |
| --- | --- |
| Agent Mode | `Accept edits + ask for commands` |
| Allowed Commands | `git diff`, `git log`, `git status`, `npm test`, `npm run build`, `npm install`, `brew install`, `curl`, `cat`, `ls`, `python3`, `node`, `mvn`, `gradle`, `docker` |
| Blocked Commands | `git push --force`, `git push -f`, `sudo`, `rm -rf`, `chmod -R`, `aws ec2 delete`, `aws s3 rb`, `aws iam delete` |

---

## Claude Code Setup (work machine)

### `~/.claude/settings.json`

```json
{
  "filesystem": {
    "denyRead": ["~/.ssh", "~/.aws", "~/.config/gh"],
    "allowWrite": ["."],
    "denyWrite": ["~/.zshrc", "~/.bashrc", "~/.ssh"]
  }
}
```

---

## Web Research

### At home

Pi's web research extension calls your homelab SearXNG or uses its built-in search. Fence's open network policy allows all outbound — this works without any config changes.

### At work

**Don't run SearXNG on your work laptop.** It's unnecessary overhead. Use:

- Codex's built-in web search (it just works)
- Claude Code's built-in web search (it just works)
- Pi's built-in web search (it has one built-in, same as the others)

If you really want to use your homelab SearXNG from work, it's on your local network via NordVPN Meshnet — fence allows localhost and local network outbound by default. But you don't need to. The built-in web search in all three agents is adequate.

---

## Keychain Setup (all machines)

```bash
# Store a secret (one per secret, -w prompts for value)
security add-generic-password -U -s "pi" -a "OPENROUTER_API_KEY" -w

# Load in ~/.zshrc (so your terminal has it, agents can't read keychain)
export OPENROUTER_API_KEY=$(security find-generic-password -s "pi" -a "OPENROUTER_API_KEY" -w 2>/dev/null)
```

---

## Quick Verification Checklist

```bash
# fence works
fence -- bash -c "git push --force"  # → blocked
fence -- bash -c "echo ok"           # → ok

# Pi works under fence
fence -- pi -p "echo 'test'"         # → test

# Keychain loads
security find-generic-password -s "pi" -a "OPENROUTER_API_KEY" -w
```

---

## Files in this repo

| File | Purpose |
| --- | --- |
| `.config/fence/fence.jsonc` | fence sandbox policy |
| `zshrc.d/fence.zsh` | Pi/agent aliases |
| `docs/agent-sandboxing-guide.md` | This guide |
| `install.sh` | Symlinks everything |
