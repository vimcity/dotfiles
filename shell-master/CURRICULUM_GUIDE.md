# 📚 Shell Master Curriculum Guide

Complete reference for understanding and expanding the Shell Master learning system.

## Overview

Shell Master teaches practical CLI skills through **interactive lessons** organized by:
- **Tool/Category** (jq, fzf, piping, bash scripting, xargs, etc.)
- **Difficulty Level** (beginner, intermediate, advanced)
- **Real-world Scenarios** (based on your actual dotfiles)

## Core Concepts

### 1. Learning Progression

```
Beginner                  Intermediate              Advanced
└─ Variables             └─ Loops & Functions      └─ Process Substitution
└─ Basic Pipes           └─ Complex Pipelines      └─ Signal Handling
└─ Simple Filters        └─ Error Handling         └─ Performance Tuning
```

### 2. Tool Categories

#### **jq** - JSON Query Language
Most powerful tool for working with JSON from CLI.

**Lessons cover:**
- `.` - Identity (return whole input)
- `.[]` - Iterate over array elements
- `.field` - Access object fields
- `.[] | select(...)` - Filtering
- `map()` - Transform arrays
- `group_by()` - Aggregation

**Real-world use:**
```bash
# Your bwrm function
bw list items | jaq '.[] | .name' | fzf
```

#### **fzf** - Fuzzy Finder
Interactive selection tool for lists.

**Lessons cover:**
- Basic filtering and selection
- Multiselect mode (`-m`)
- Preview window (`--preview`)
- Key bindings and escaping
- Integration with pipes

**Real-world use:**
```bash
# Your tldr function
ls | fzf | xargs vim
```

#### **piping** - Unix Philosophy
"Do one thing well" - chain simple tools.

**Lessons cover:**
- Output redirection (`|`)
- Input redirection (`<`, `>`)
- Process substitution (`<()`, `>()`)
- Multiple pipe stages
- Error handling (`2>&1`)

**Real-world use:**
```bash
# Your git alias patterns
git log | grep "pattern" | cut -d' ' -f1 | xargs git show
```

#### **xargs** - Argument Processing
Convert stdin into command arguments.

**Lessons cover:**
- Basic usage (pass args to command)
- `-I {}` for argument placement
- `-0` for null-delimited input
- Parallel execution (`-P`)
- Multiselect handling

**Real-world use:**
```bash
# Your bwrm function (final version)
echo "ids..." | xargs -I {} bw delete item {}
```

#### **bash-scripting** - Shell Fundamentals
Writing reusable shell scripts.

**Lessons cover:**
- Variables and quoting
- Functions and return codes
- Control flow (if/case/for/while)
- Arrays and parameter expansion
- Subshells and sourcing

**Real-world use:**
```bash
# Your cheat(), tldr(), functions
function myfunction() {
    local input="$1"
    # ...
}
```

## Curriculum Structure

### Lesson Anatomy

Each lesson has:

```lua
{
    title = "Descriptive Title",          -- What you're learning
    description = "Explanation...",       -- Why this matters
    category = "jq",                      -- One of the tool categories
    difficulty = "beginner",              -- beginner|intermediate|advanced
    task = "Do this...",                  -- What to practice
    expected_output = "substring" or      -- Validation: what output should contain
                      {"opt1", "opt2"},   -- OR multiple valid options
    hints = {                             -- Progressive hints
        "First hint (attempt 1)",
        "Second hint (attempt 2)",
        "Third hint (attempt 3)"
    }
}
```

### Validation System

Lessons validate by checking if output **contains** the `expected_output` string.

```lua
-- Simple validation (exact substring match)
expected_output = "Alice"

-- Multiple valid outputs (any match succeeds)
expected_output = {"Alice", "BOB", "charlie"}

-- Can be partial match
expected_output = "error"  -- matches "error", "errors", "error_message", etc.
```

## Your Learning Path

Based on your current dotfiles, here's the **recommended progression**:

### Week 1: Fundamentals
- [ ] jq Basics (identity, field access, array iteration)
- [ ] Simple Pipes (cat → grep)
- [ ] cut (column extraction)
- [ ] Variables in bash

### Week 2: Integration
- [ ] jq with filtering (select)
- [ ] Multi-stage pipelines
- [ ] Functions in bash
- [ ] fzf basics

### Week 3: Real Patterns
- [ ] Replicate your bwrm function
- [ ] Replicate your tldr function
- [ ] Command substitution
- [ ] Error handling patterns

### Week 4: Mastery
- [ ] Process substitution
- [ ] xargs advanced patterns
- [ ] Bash loop patterns
- [ ] Performance optimization

## Adding New Lessons

### Step 1: Identify the Pattern

Look at your dotfiles. What patterns don't you fully understand?

```bash
# From your zshrc:
bwrm() {
    local selection=$(bw list items | jaq -r '.[] | ...')  # ← Complex jaq
    local id=$(echo "$selection" | cut -d'|' -f2)            # ← cut usage
    # ...
}
```

Pattern: **Extract specific fields from piped JSON**

### Step 2: Write the Lesson

```lua
{
    title = "jq + cut: Extract and Parse",
    description = "Combine JSON parsing with column extraction for structured data",
    category = "jq",
    difficulty = "intermediate",
    task = 'From JSON array with names and IDs, extract just the IDs in a list',
    expected_output = "id",
    hints = {
        "First parse JSON with jaq: jaq -r '.[] | ...'",
        "Then use cut to extract a specific column",
        "Pipe: jaq | cut -d'|' -f2"
    }
}
```

### Step 3: Test It

```bash
shellmaster
# Navigate to the lesson
# Verify it validates correctly
```

### Step 4: Add to Curriculum

Edit `data/curriculum.lua` and add your lesson in the appropriate section.

## Extending for Your Tools

Looking at your `brew list`, you use:

- **git** - Version control (lesson category: `git-workflows`)
- **tmux** - Terminal multiplexer (lesson category: `tmux`)
- **neovim** - Editor (lesson category: `nvim`)
- **ripgrep** - Search (lesson category: `searching`)
- **delta** - Git diff (lesson category: `git`)
- **fd** - Find files (lesson category: `finding`)
- **exa** - ls alternative (lesson category: `exploring`)

### To add a new category:

1. Create lessons in `curriculum.lua`:
```lua
-- GIT WORKFLOWS
{
    title = "Git Worktree: Multi-Branch Work",
    description = "Use git worktree to work on multiple branches simultaneously",
    category = "git-workflows",
    difficulty = "intermediate",
    -- ...
}
```

2. Use `shellmaster` to access by category

## Future: AI-Powered Generation

When implemented, you'll be able to:

```bash
shellmaster --generate-from-manpage jq
# Reads: man jq
# Outputs: 10 progressive lessons on jq
```

Or:

```bash
shellmaster --generate-from-function ~/dotfiles/zshrc:tldr
# Analyzes your tldr() function
# Generates lessons to help you understand each part
```

## Performance & Optimization

### Current System
- Pure Lua implementation
- Instant lesson loading
- Immediate validation
- No external dependencies (except bash, lua)

### Optimization Ideas
- Cache compiled lessons (for faster startup)
- Background lesson pre-loading
- Streaming output for large commands
- Parallel lesson validation

## Troubleshooting

### Lesson validation failing when you're right?

Check the `expected_output` field. It must match a **substring** in your output.

```lua
-- This will fail if output is "Alice" but you expect "alice"
expected_output = "alice"  -- Must be exact substring

-- Solution:
expected_output = {"Alice", "alice"}  -- Both options work
```

### Want to see the actual output?

Modify the TUI to show more of the output:

In `shell-master.lua`, around line 95:
```lua
print(output:sub(1, 200))  -- Show first 200 chars
-- Change to:
print(output)  -- Show all
```

## Contributing Ideas

Have lesson ideas? Submit them:

1. **As PRs** - Add directly to `curriculum.lua`
2. **As Issues** - Describe the pattern you want to learn
3. **As Discussions** - Share your real-world CLI scenarios

## Resources Referenced

Your learning draws from:
- **awesome-bash** - Comprehensive Bash ecosystem guide
- **awesome-shell** - Best CLI tools and patterns
- **Your own dotfiles** - Real patterns you actually use
- **Bash Pitfalls** - Common mistakes to avoid
- **Google Shell Style Guide** - Best practices

See `shell-master/README.md` for full resource list.

---

**Remember**: The best way to learn is by **doing**. Each lesson is designed to be:
- ✅ Self-contained
- ✅ Immediately useful
- ✅ Progressively challenging
- ✅ Forgiving (hints and retries)

Happy learning! 🚀
