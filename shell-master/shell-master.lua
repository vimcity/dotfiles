#!/usr/bin/env lua
-- Shell Master: Interactive CLI Training System
-- Learn bash, zsh, jq, fzf, xargs, and more through hands-on lessons

local Lesson = require("lib.lesson")
local curriculum = require("data.curriculum")

-- Helper to clear screen
local function clear()
    os.execute("clear")
end

-- Helper to read user input
local function read_line()
    return io.read("*l")
end

-- Helper to validate command output (with timeout)
local function run_command(cmd)
    if not cmd or cmd == "" then
        return "(no command)"
    end
    
    -- Add timeout using 'timeout' command if available, or run normally on macOS
    local safe_cmd = cmd .. " 2>&1"
    
    -- Try to use gtimeout (from brew install coreutils) if available
    local has_timeout = os.execute("command -v gtimeout >/dev/null 2>&1") == 0
    if has_timeout then
        safe_cmd = "gtimeout 5 " .. safe_cmd
    end
    
    local handle = io.popen(safe_cmd, "r")
    if not handle then
        return "Error: Failed to execute command"
    end
    
    local output = handle:read("*a")
    local status = handle:close()
    
    if not output or output == "" then
        return "(no output)"
    end
    
    return output
end

-- Main Menu
local function main_menu()
    clear()
    print("\n╔═══════════════════════════════════════════════════════════════╗")
    print("║                    🎓 SHELL MASTER 🎓                        ║")
    print("║         Master bash, zsh, jq, fzf, xargs and more!          ║")
    print("╚═══════════════════════════════════════════════════════════════╝\n")
    
    print("Choose an option:")
    print("  1) Start Learning (Tutorial Mode)")
    print("  2) Browse by Category")
    print("  3) Filter by Difficulty")
    print("  4) Practice Mode (Random Challenge)")
    print("  5) View Progress")
    print("  6) Generate New Lessons (AI)")
    print("  0) Exit\n")
    
    io.write("> ")
    return read_line()
end

-- Show lesson with practice
local function practice_lesson(lesson_data)
    -- Create lesson object
    local lesson = {
        title = lesson_data.title,
        description = lesson_data.description,
        category = lesson_data.category,
        difficulty = lesson_data.difficulty,
        task = lesson_data.task,
        expected_output = lesson_data.expected_output,
        hints = lesson_data.hints,
        completed = false,
        attempts = 0,
        max_attempts = 3,
    }
    
    -- Display lesson
    print("\n" .. string.rep("=", 60))
    print("📚 " .. lesson.title .. " [" .. string.upper(lesson.difficulty) .. "]")
    print(string.rep("=", 60))
    print("\n" .. lesson.description)
    print("\nTask:")
    print("  " .. lesson.task)
    
    -- Show input data if available
    if lesson_data.input_data then
        print("\nInput data available:")
        print("  " .. lesson_data.input_data:sub(1, 60))
        if #lesson_data.input_data > 60 then
            print("  ...")
        end
    end
    
    print("\nTry it (type your command):")
    
    -- Practice loop
    for attempt = 1, lesson.max_attempts do
        io.write("\n> ")
        local user_input = read_line()
        
        if user_input == "" then
            print("❌ Empty input. Try again.")
            goto next_attempt
        end
        
        -- Run the command with input data if available
        local full_command = user_input
        if lesson_data.input_data then
            -- If input_data exists, pipe it to the command
            full_command = "echo '" .. lesson_data.input_data:gsub("'", "'\\''") .. "' | " .. user_input
        end
        
        local output = run_command(full_command)
        
        -- Validate
        local is_correct = false
        if type(lesson_data.expected_output) == "table" then
            for _, expected_str in ipairs(lesson_data.expected_output) do
                if output:find(expected_str, 1, true) then
                    is_correct = true
                    break
                end
            end
        else
            is_correct = output:find(lesson_data.expected_output, 1, true) ~= nil
        end
        
        if is_correct then
            print("\n✅ Correct! Well done!\n")
            print("Output:")
            print(output:sub(1, 200))  -- Show first 200 chars
            return true
        else
            print("\n❌ Not quite right.")
            if attempt < lesson.max_attempts then
                print("You have " .. (lesson.max_attempts - attempt) .. " attempt(s) left.")
                if lesson_data.hints and lesson_data.hints[attempt] then
                    print("\n💡 Hint " .. attempt .. ": " .. lesson_data.hints[attempt])
                end
            else
                print("\n💡 Expected output to contain: " .. tostring(lesson_data.expected_output))
            end
        end
        
        ::next_attempt::
    end
    
    return false
end

-- List lessons by category
local function show_by_category()
    clear()
    print("\n📚 Lessons by Category:\n")
    
    local categories = {}
    for _, lesson in ipairs(curriculum) do
        if not categories[lesson.category] then
            categories[lesson.category] = {}
        end
        table.insert(categories[lesson.category], lesson)
    end
    
    local cat_list = {}
    for cat, _ in pairs(categories) do
        table.insert(cat_list, cat)
    end
    table.sort(cat_list)
    
    for i, cat in ipairs(cat_list) do
        print(i .. ") " .. cat .. " (" .. #categories[cat] .. " lessons)")
    end
    
    io.write("\nChoose category (or 0 to go back): ")
    local choice = tonumber(read_line())
    
    if choice == 0 or not cat_list[choice] then
        return
    end
    
    local selected_cat = cat_list[choice]
    clear()
    print("\n📖 " .. selected_cat .. " Lessons:\n")
    
    for i, lesson in ipairs(categories[selected_cat]) do
        print(i .. ") " .. lesson.title .. " [" .. lesson.difficulty .. "]")
    end
    
    io.write("\nChoose lesson (or 0 to go back): ")
    local lesson_choice = tonumber(read_line())
    
    if lesson_choice and lesson_choice > 0 and categories[selected_cat][lesson_choice] then
        clear()
        practice_lesson(categories[selected_cat][lesson_choice])
        io.write("\nPress Enter to continue...")
        read_line()
    end
end

-- Filter by difficulty
local function show_by_difficulty()
    clear()
    print("\n🎯 Filter by Difficulty:\n")
    print("1) Beginner")
    print("2) Intermediate")
    print("3) Advanced")
    print("0) Back\n")
    
    io.write("> ")
    local choice = read_line()
    
    local difficulty_map = {
        ["1"] = "beginner",
        ["2"] = "intermediate",
        ["3"] = "advanced"
    }
    
    local selected_difficulty = difficulty_map[choice]
    if not selected_difficulty then return end
    
    clear()
    print("\n" .. string.upper(selected_difficulty) .. " Lessons:\n")
    
    local filtered = {}
    for i, lesson in ipairs(curriculum) do
        if lesson.difficulty == selected_difficulty then
            table.insert(filtered, lesson)
            print(#filtered .. ") " .. lesson.title .. " [" .. lesson.category .. "]")
        end
    end
    
    io.write("\nChoose lesson (or 0 to go back): ")
    local lesson_choice = tonumber(read_line())
    
    if lesson_choice and lesson_choice > 0 and filtered[lesson_choice] then
        clear()
        practice_lesson(filtered[lesson_choice])
        io.write("\nPress Enter to continue...")
        read_line()
    end
end

-- Random challenge
local function practice_mode()
    clear()
    local lesson = curriculum[math.random(1, #curriculum)]
    print("\n🎮 Random Challenge!\n")
    practice_lesson(lesson)
    io.write("\nPress Enter to continue...")
    read_line()
end

-- Main loop
local function main()
    while true do
        local choice = main_menu()
        
        if choice == "0" then
            print("\nHappy learning! 📚\n")
            break
        elseif choice == "1" then
            -- Sequential tutorials
            for i, lesson_data in ipairs(curriculum) do
                clear()
                print("Lesson " .. i .. " of " .. #curriculum .. "\n")
                if not practice_lesson(lesson_data) then
                    io.write("\nContinue to next lesson? (y/n): ")
                    if read_line():lower() ~= "y" then break end
                end
            end
        elseif choice == "2" then
            show_by_category()
        elseif choice == "3" then
            show_by_difficulty()
        elseif choice == "4" then
            practice_mode()
        elseif choice == "5" then
            clear()
            print("\n📊 Progress (coming soon!)\n")
            print("Features to track:")
            print("- Lessons completed")
            print("- Success rate per category")
            print("- Time spent learning")
            io.write("\nPress Enter to continue...")
            read_line()
        elseif choice == "6" then
            clear()
            print("\n🤖 AI Lesson Generation (coming soon!)\n")
            print("You'll be able to:")
            print("- Feed tool man pages")
            print("- Get auto-generated lessons")
            print("- Create custom challenges")
            io.write("\nPress Enter to continue...")
            read_line()
        end
    end
end

-- Run
main()
