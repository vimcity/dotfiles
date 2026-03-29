# 🎓 Shell Master - Interactive CLI Learning System

An interactive terminal-based trainer to master bash, zsh, jq, fzf, xargs, cut, and other essential Unix/Linux tools through hands-on practice lessons.

## Quick Start

```bash
shellmaster      # Start the interactive menu
```

## Features

### 📚 Structured Learning
- **Progressive Curriculum**: Beginner → Intermediate → Advanced
- **Multiple Categories**: jq, fzf, piping, bash scripting, xargs, and more
- **Real-World Scenarios**: Lessons based on actual CLI patterns you use

### 🎮 Practice Modes
1. **Tutorial Mode**: Linear progression through all lessons
2. **Browse by Category**: Learn specific tools (jq, fzf, etc.)
3. **Filter by Difficulty**: Start easy, work your way up
4. **Practice Mode**: Random challenges to test your skills
5. **Progress Tracking**: See what you've mastered

### 🤖 Intelligent Feedback
- Validates your command output
- Provides hints if you get stuck
- Shows expected output when you're wrong
- Tracks attempts and success rates

### 🔄 Extensible Curriculum
- Add new lessons by editing `data/curriculum.lua`
- AI-powered lesson generation (coming soon)
- Custom challenge creation

## Directory Structure

```
shell-master/
├── shell-master           # Main executable (wrapper)
├── shell-master.lua       # Core TUI application
├── lib/
│   └── lesson.lua        # Lesson structure & validation
├── data/
│   └── curriculum.lua    # All lesson definitions
├── lessons/              # (Future) Organized lesson files
└── README.md            # This file
```

## What You'll Learn

### Fundamentals
- **Pipes & Composition**: Chaining commands with `|`
- **Variables & Substitution**: `$()` and command substitution
- **Redirection**: `>`, `>>`, `2>`, `<`

### Essential Tools
- **jq**: JSON query and transformation
  - `.` (identity), `.[]` (iterate), `.field` (access)
  - `select()` (filtering), `map()` (transformation)
  
- **fzf**: Fuzzy finder
  - Interactive selection from lists
  - Multiselect mode with `-m`
  - Preview window integration

- **xargs**: Process arguments
  - Basic usage for piping
  - `-I {}` for placement
  - Multiselect handling with `xargs -0`

- **cut**: Extract columns
  - `-d` for delimiters
  - `-f` for field numbers
  - `-c` for character ranges

- **Bash/Zsh Scripting**
  - Variables and quoting
  - Functions and control flow
  - Loops and conditionals
  - Error handling

### Advanced Patterns
- Process substitution: `<()` and `>()`
- Command substitution: `$()`
- Parameter expansion: `${var%pattern}`, etc.
- Signal handling and cleanup

## Example Lessons

### Beginner
```
Title: jq Field Access
Task: Given {"user": {"name": "Alice"}}, extract just the name field
Expected: Alice
Hint: Use .user.name to navigate nested objects
```

### Intermediate
```
Title: Multi-Stage Pipeline
Task: From a list of names (with duplicates), show each unique name once, sorted
Expected: sorted unique output
Hint: Use cat | sort | uniq
```

### Advanced
```
Title: Process Substitution
Task: Compare output of two commands using diff <(cmd1) <(cmd2)
Expected: diff output showing differences
```

## Adding New Lessons

Edit `data/curriculum.lua` and add a lesson table:

```lua
{
    title = "Your Lesson Title",
    description = "What this teaches",
    category = "jq",  -- or fzf, xargs, bash-scripting, etc.
    difficulty = "beginner",  -- or intermediate, advanced
    task = "What the user should do",
    expected_output = "string to check for" or {"option1", "option2"},
    hints = {
        "First hint if they get stuck",
        "Second hint after another attempt"
    }
}
```

## Future Enhancements

- [ ] AI-powered lesson generation from man pages
- [ ] Progress persistence (JSON/SQLite tracking)
- [ ] Spaced repetition system
- [ ] Community lesson sharing
- [ ] Video demonstrations
- [ ] Real-time shell integration (run in actual shell)
- [ ] Performance profiling lessons
- [ ] Git/GitHub workflow lessons
- [ ] Container/Docker lessons

## Contributing

Have ideas for lessons? Want to improve the curriculum?

1. Edit `data/curriculum.lua` to add/improve lessons
2. Test lessons thoroughly
3. Submit via PR or GitHub issue

## License

MIT - Use, modify, and distribute freely

## Resources

This tool is inspired by:
- `vim-tutor` - Interactive Vim learning
- `bandit` / `overthewire.org` - Security CTF challenges
- `bash-handbook` and `awesome-bash` lists
- Your own dotfiles and real-world CLI patterns

Happy learning! 🚀
