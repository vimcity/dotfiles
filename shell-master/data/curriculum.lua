-- Shell Mastery Curriculum
-- Comprehensive lessons for bash/zsh scripting and CLI tool mastery
-- Each lesson now has input_data so users can practice immediately

return {
    -- JQ FUNDAMENTALS
    {
        title = "jq Basics: Identity (.)",
        description = "Learn the most basic jq selector. The dot (.) represents the entire input.",
        category = "jq",
        difficulty = "beginner",
        task = "Use jq to return the entire JSON object",
        input_data = '{"name": "Alice", "age": 30}',
        expected_output = "Alice",
        hints = {
            "Use the dot (.) to select the entire input",
            "Type: jq '.'",
            "The command should show all fields"
        }
    },
    {
        title = "jq Field Access",
        description = "Access nested fields in JSON objects using dot notation",
        category = "jq",
        difficulty = "beginner",
        task = "Extract just the name field from a nested JSON object",
        input_data = '{"user": {"name": "Alice"}}',
        expected_output = "Alice",
        hints = {
            "Use .user.name to navigate nested objects",
            "Type: jq '.user.name'",
            "Add -r flag to remove quotes: jq -r '.user.name'"
        }
    },
    {
        title = "jq Array Iteration ([])",
        description = ".[] iterates over each element in an array",
        category = "jq",
        difficulty = "beginner",
        task = 'Use .[] to iterate over array elements',
        input_data = '[1,2,3]',
        expected_output = {"1", "2", "3"},
        hints = {
            ".[] means \"for each element\"",
            "Type: jq '.[]'",
            "Each number appears on its own line"
        }
    },
    {
        title = "jq with Filtering",
        description = "Use select() to filter array elements based on conditions",
        category = "jq",
        difficulty = "intermediate",
        task = 'Filter to get only people over age 26',
        input_data = '[{"name":"Alice","age":30},{"name":"Bob","age":25}]',
        expected_output = "Alice",
        hints = {
            "Use .[] | select(.age > 26)",
            "Type: jq '.[] | select(.age > 26)'",
            "select() keeps only matching items"
        }
    },

    -- PIPING AND COMPOSITION
    {
        title = "Simple Pipe: grep",
        description = "Basics of piping: pass output from one command to another",
        category = "piping",
        difficulty = "beginner",
        task = "Use grep to find lines containing 'error'",
        input_data = "warning: something\nerror: failed\nerror: timeout\nsuccess: done",
        expected_output = "error",
        hints = {
            "Use | to pipe output",
            "Type: grep error",
            "grep finds matching lines"
        }
    },
    {
        title = "Multi-Stage Pipeline",
        description = "Chain multiple commands: filter -> sort -> unique",
        category = "piping",
        difficulty = "intermediate",
        task = "Show each unique name once, sorted",
        input_data = "alice\nzoe\nalice\nbob\nzoe\nalice",
        expected_output = "alice",
        hints = {
            "Use sort | uniq to remove duplicates",
            "Type: sort | uniq",
            "Order matters: sort first, then uniq"
        }
    },
    {
        title = "Cut: Extract Columns",
        description = "Extract specific columns from delimited data",
        category = "piping",
        difficulty = "beginner",
        task = "Extract the second column (ages) from CSV data",
        input_data = "alice,30,seattle\nbob,25,portland\ncarol,28,san francisco",
        expected_output = "30",
        hints = {
            "cut -d',' -f2 extracts 2nd column",
            "Type: cut -d',' -f2",
            "-d sets delimiter, -f sets field number"
        }
    },

    -- XARGS
    {
        title = "xargs: Basic Usage",
        description = "Pass piped input as arguments to a command",
        category = "xargs",
        difficulty = "beginner",
        task = "Use xargs to pass list items as arguments to echo",
        input_data = "file1\nfile2\nfile3",
        expected_output = "file",
        hints = {
            "xargs converts each line to an argument",
            "Type: xargs echo",
            "This will output all items on one line"
        }
    },
    {
        title = "xargs with -I: Placeholder",
        description = "Use -I {} to place arguments in specific positions",
        category = "xargs",
        difficulty = "intermediate",
        task = "For each number, print 'Item: X'",
        input_data = "1\n2\n3",
        expected_output = "Item:",
        hints = {
            "Use -I {} to define a placeholder",
            "Type: xargs -I {} echo 'Item: {}'",
            "This processes each item separately"
        }
    },

    -- FZF (Note: fzf is interactive, these are conceptual)
    {
        title = "fzf: Concept",
        description = "Interactively select items from a list",
        category = "fzf",
        difficulty = "beginner",
        task = "Use fzf to select from options (manually type one option)",
        input_data = "option1\noption2\noption3",
        expected_output = "option",
        hints = {
            "fzf is interactive in a real terminal",
            "Type: echo 'option1' (simulating selection)",
            "In practice you'd use: fzf and select with arrows"
        }
    },

    -- BASH SCRIPTING FUNDAMENTALS
    {
        title = "Bash: Variable Assignment",
        description = "Store and use variables in bash",
        category = "bash-scripting",
        difficulty = "beginner",
        task = "Create a variable and output it",
        input_data = nil,
        expected_output = "Alice",
        hints = {
            "Use name='Alice' then echo $name",
            "Type: name='Alice' && echo $name",
            "No spaces around = in assignment"
        }
    },
    {
        title = "Bash: Command Substitution",
        description = "Capture command output in a variable",
        category = "bash-scripting",
        difficulty = "beginner",
        task = "Store output of 'echo hello' in a variable",
        input_data = nil,
        expected_output = "hello",
        hints = {
            "Use var=$(echo hello)",
            "Type: msg=$(echo hello) && echo $msg",
            "$(command) captures the output"
        }
    },
    {
        title = "Bash: Simple Function",
        description = "Write a simple function",
        category = "bash-scripting",
        difficulty = "beginner",
        task = "Create a function that returns 'Hello'",
        input_data = nil,
        expected_output = "Hello",
        hints = {
            "Use: greet() { echo 'Hello'; }",
            "Then call it: greet() { echo 'Hello'; }; greet",
            "Semicolon separates statements"
        }
    },
    {
        title = "Bash: If Conditional",
        description = "Use if/else for decisions",
        category = "bash-scripting",
        difficulty = "intermediate",
        task = "Check if a number is greater than 5",
        input_data = nil,
        expected_output = "greater",
        hints = {
            "Use: if [[ 10 -gt 5 ]]; then echo 'greater'; fi",
            "-gt means greater than",
            "Type the full if/then/fi statement"
        }
    },

    -- ADVANCED PATTERNS
    {
        title = "Process Substitution Concept",
        description = "Understand <() and >() for treating output as files",
        category = "advanced-patterns",
        difficulty = "advanced",
        task = "Compare two different outputs",
        input_data = nil,
        expected_output = "file",
        hints = {
            "<() creates a file-like input from command output",
            "Example: diff <(echo a) <(echo b)",
            "This is a concept lesson - focus on understanding"
        }
    },
    {
        title = "Command Substitution",
        description = "Embed command output directly in strings",
        category = "advanced-patterns",
        difficulty = "intermediate",
        task = "Use $(command) to embed output",
        input_data = nil,
        expected_output = "echo",
        hints = {
            "$(command) or `command` captures output",
            "Type: echo $(echo hello world)",
            "Modern: use $(  ) instead of backticks"
        }
    },
}
