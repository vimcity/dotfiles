# 🚀 Shell Master Quick Start

## Installation

Already done! The tool is installed in your dotfiles and aliased in zshrc.

```bash
shellmaster    # Type this anywhere to start
```

## First Time Using It

### Option 1: Browse by Category (Recommended for beginners)
```
shellmaster
  → Choose "2) Browse by Category"
  → Choose "jq" 
  → Pick a beginner lesson
  → Type your command
  → Hit Enter to see if you're correct
```

### Option 2: Tutorial Mode (Sequential learning)
```
shellmaster
  → Choose "1) Start Learning (Tutorial Mode)"
  → Works through lessons 1-by-1
  → Each lesson unlocks knowledge needed for the next
```

### Option 3: Random Challenge (Test your skills)
```
shellmaster
  → Choose "4) Practice Mode (Random Challenge)"
  → Get a random lesson
  → Try to solve it
  → Perfect for retention practice
```

## How Lessons Work

Each lesson has:

1. **Description** - What you're learning and why
2. **Task** - What you need to do
3. **Your command** - Type a shell command to solve it
4. **Feedback** - Immediate validation
5. **Hints** - If you get stuck (3 attempts max)

### Example Lesson Flow

```
📚 jq Field Access [BEGINNER]
============================================================

Learn to extract fields from JSON objects using dot notation

Task:
  Given {user: {name: Alice}}, extract just the name field

Try it:
Your command: echo '{"user":{"name":"Alice"}}' | jq '.user.name'

✅ Correct! Well done!

Output:
"Alice"
```

## Learning Progression

### Week 1: Fundamentals
- Start with **jq** category → beginner lessons
- Then **piping** category → beginner lessons
- Then **bash-scripting** → variables & functions

### Week 2: Intermediate
- **jq** → intermediate (filtering with select)
- **piping** → intermediate (multi-stage pipes)
- **xargs** → beginner & intermediate

### Week 3: Real Patterns
- Replicate your actual functions:
  - `bwrm` - JSON parsing + column extraction + deletion
  - `tldr` - Help output parsing + formatting
  
### Week 4: Mastery
- **advanced-patterns** lessons
- Process substitution, error handling, etc.

## Tips for Success

### ✅ DO
- Type actual commands (not pseudocode)
- Use pipes and real tools (jq, cut, grep, etc.)
- Try multiple times - hints only appear after attempts
- Move to next lesson when you understand the concept

### ❌ DON'T
- Ask "what should I type?" - figure it out with hints
- Copy the exact syntax from hints - adapt it
- Skip fundamentals - they're prerequisites for advanced lessons
- Use ChatGPT/AI to bypass learning - that defeats the purpose!

## Customizing Lessons

Want to add a lesson for a tool you use?

1. Edit `~/dotfiles/shell-master/data/curriculum.lua`
2. Add a new lesson table (copy an existing one as template)
3. Test it: `shellmaster` → Browse by Category
4. Commit: `git add/commit`

Example:

```lua
{
    title = "Your Lesson Title",
    description = "What you're learning",
    category = "jq",  -- or fzf, xargs, etc.
    difficulty = "beginner",
    task = "What to do",
    expected_output = "substring your output should contain",
    hints = {
        "First hint",
        "Second hint"
    }
}
```

## Troubleshooting

### "Lesson validation failing but I'm correct?"
- Check that your output **contains** the `expected_output` string
- It doesn't need to match exactly, just include it
- Example: if expected_output is "Alice", any output with "Alice" passes

### "Want to see full command output?"
- In `shell-master.lua` line ~105, change:
  ```lua
  print(output:sub(1, 200))
  ```
  to:
  ```lua
  print(output)
  ```

### "Can't figure out a lesson?"
- Use all 3 hints
- Try similar commands and see what happens
- Think about what the task is asking for
- Only then ask for help (use `man toolname`)

## Next Steps

1. **Start now**: Type `shellmaster`
2. **Pick a category**: jq, fzf, or piping
3. **Try a beginner lesson**: You've got this!
4. **Progress daily**: 15-30 min sessions are perfect
5. **Track progress**: See which tools you've mastered

## Resources

- **Lesson docs**: `~/dotfiles/shell-master/CURRICULUM_GUIDE.md`
- **Tool reference**: `man jq`, `man fzf`, etc.
- **Your functions**: `~/dotfiles/zshrc` (look at bwrm, tldr, etc.)

---

**Ready? Type: `shellmaster` and start learning! 🎓**
