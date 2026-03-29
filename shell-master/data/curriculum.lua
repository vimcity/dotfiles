-- Shell Mastery Curriculum
-- Comprehensive lessons for bash/zsh scripting and CLI tool mastery

return {
    -- JQ FUNDAMENTALS
    {
        title = "jq Basics: Identity (.)",
        description = "Learn the most basic jq selector. The dot (.) represents the entire input.",
        category = "jq",
        difficulty = "beginner",
        task = "Given JSON: {\"name\": \"Alice\", \"age\": 30}, use jq to return the entire object",
        expected_output = "alice",
        hints = {
            "Use the dot (.) to select the entire input",
            "Command format: echo 'JSON' | jq '.'"
        }
    },
    {
        title = "jq Field Access",
        description = "Access nested fields in JSON objects using dot notation",
        category = "jq",
        difficulty = "beginner",
        task = "Given {\"user\": {\"name\": \"Alice\"}}, extract just the name field",
        expected_output = "Alice",
        hints = {
            "Use .user.name to navigate nested objects",
            "Add -r flag to remove quotes from string output"
        }
    },
    {
        title = "jq Array Iteration ([])",
        description = ".[] iterates over each element in an array",
        category = "jq",
        difficulty = "beginner",
        task = 'Filter array [1,2,3]: echo "[1,2,3]" | jq .[]',
        expected_output = {"1", "2", "3"},
        hints = {
            ".[] means \"for each element\"",
            "Each number appears on its own line"
        }
    },
    {
        title = "jq with Pipe and Select",
        description = "Combine field access with filtering using select()",
        category = "jq",
        difficulty = "intermediate",
        task = 'From [{\"name\":\"Alice\",\"age\":30},{\"name\":\"Bob\",\"age\":25}], get only people over 26',
        expected_output = "Alice",
        hints = {
            "Use .[] | select(.age > 26) to filter",
            "select() keeps only matching items"
        }
    },
    
    -- PIPING AND COMPOSITION
    {
        title = "Simple Pipe: cat to grep",
        description = "Basics of piping: pass output from one command to another",
        category = "piping",
        difficulty = "beginner",
        task = "Create a file with lines, use cat and grep to find lines containing 'error'",
        expected_output = "error",
        hints = {
            "Use | to pipe output",
            "cat file.txt | grep error"
        }
    },
    {
        title = "Multi-Stage Pipeline",
        description = "Chain multiple commands: filter -> sort -> unique",
        category = "piping",
        difficulty = "intermediate",
        task = "From a list of names (with duplicates), show each unique name once, sorted",
        expected_output = "sorted",
        hints = {
            "Use cat | sort | uniq",
            "Order matters: sort first, then uniq"
        }
    },
    {
        title = "Cut: Extract Columns",
        description = "Extract specific columns from delimited data",
        category = "piping",
        difficulty = "beginner",
        task = "From CSV 'name,age,city', extract just the ages using cut",
        expected_output = "age",
        hints = {
            "cut -d',' -f2 extracts 2nd column",
            "-d sets delimiter, -f sets field number"
        }
    },

    -- XARGS
    {
        title = "xargs: Basic Usage",
        description = "Pass piped input as arguments to a command",
        category = "xargs",
        difficulty = "beginner",
        task = "List files, then pass filenames to wc -l to count lines in each",
        expected_output = "lines",
        hints = {
            "echo file1 file2 | xargs wc -l",
            "xargs turns stdin into command arguments"
        }
    },
    {
        title = "xargs with -I: Replace Token",
        description = "Use -I {} to place arguments in specific positions",
        category = "xargs",
        difficulty = "intermediate",
        task = "Given a list of 5, for each number, print 'Number: X'",
        expected_output = "Number:",
        hints = {
            "xargs -I {} echo 'Number: {}'",
            "-I {} defines a placeholder for each argument"
        }
    },

    -- FZF
    {
        title = "fzf: Select from List",
        description = "Interactively select items from a list",
        category = "fzf",
        difficulty = "beginner",
        task = "Use fzf to select one item from a list of options",
        expected_output = "selected",
        hints = {
            "echo -e 'option1\\noption2\\noption3' | fzf",
            "Type to filter, Enter to select"
        }
    },
    {
        title = "fzf: Multiselect",
        description = "Select multiple items with -m flag",
        category = "fzf",
        difficulty = "intermediate",
        task = "Use fzf -m to select multiple items",
        expected_output = "multiple",
        hints = {
            "Add -m flag for multiselect",
            "Use Tab to mark items"
        }
    },

    -- BASH SCRIPTING FUNDAMENTALS
    {
        title = "Bash: Variables",
        description = "Store and use variables in scripts",
        category = "bash-scripting",
        difficulty = "beginner",
        task = "Create a variable name='Alice' and echo it",
        expected_output = "Alice",
        hints = {
            "No spaces around = when assigning",
            "Use $name to access the variable"
        }
    },
    {
        title = "Bash: Functions",
        description = "Define and call reusable functions",
        category = "bash-scripting",
        difficulty = "beginner",
        task = "Write a function greet() that prints 'Hello World'",
        expected_output = "Hello",
        hints = {
            "greet() { echo 'Hello'; }",
            "Call it with: greet"
        }
    },
    {
        title = "Bash: Conditionals",
        description = "Use if/else to make decisions",
        category = "bash-scripting",
        difficulty = "beginner",
        task = "Check if a number is greater than 5",
        expected_output = "greater",
        hints = {
            "if [[ $num -gt 5 ]]; then ... fi",
            "-gt means greater than"
        }
    },
    {
        title = "Bash: Loops (for)",
        description = "Iterate over lists with for loops",
        category = "bash-scripting",
        difficulty = "intermediate",
        task = "Loop through 1 2 3 and print each",
        expected_output = "1",
        hints = {
            "for item in 1 2 3; do echo $item; done",
            "semicolons separate statements"
        }
    },

    -- ADVANCED PATTERNS
    {
        title = "Process Substitution",
        description = "Use <() to treat output as a file",
        category = "advanced-patterns",
        difficulty = "advanced",
        task = "Compare output of two commands using diff <(cmd1) <(cmd2)",
        expected_output = "diff",
        hints = {
            "<() creates a file-like input from command output",
            "Useful for commands that require file arguments"
        }
    },
    {
        title = "Command Substitution",
        description = "Capture command output with $() or backticks",
        category = "advanced-patterns",
        difficulty = "intermediate",
        task = "Store the result of 'ls' in a variable",
        expected_output = "file",
        hints = {
            "files=$(ls) or files=`ls`",
            "$() is preferred modern syntax"
        }
    },
}
