#!/bin/bash
# Quick test of a single lesson

echo "🧪 Testing Shell Master Lesson"
echo "=============================="
echo ""

# Set up paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Create a simple test in Lua
lua << 'LUA'
local curriculum = require("data.curriculum")

-- Get first lesson
local lesson = curriculum[1]

print("📚 Lesson: " .. lesson.title)
print("Category: " .. lesson.category)
print("Difficulty: " .. lesson.difficulty)
print("")
print("Description:")
print("  " .. lesson.description)
print("")
print("Task:")
print("  " .. lesson.task)
print("")

if lesson.input_data then
    print("Input data available:")
    print("  " .. lesson.input_data:sub(1, 80))
    if #lesson.input_data > 80 then print("  ...") end
    print("")
end

print("Expected output should contain:")
if type(lesson.expected_output) == "table" then
    for _, exp in ipairs(lesson.expected_output) do
        print("  - " .. exp)
    end
else
    print("  - " .. lesson.expected_output)
end

print("")
print("Hints:")
for i, hint in ipairs(lesson.hints) do
    print("  " .. i .. ". " .. hint)
end

print("")
print("Testing: Let's try an answer...")
print("")

-- Simulate user typing: jq .
local user_input = "jq ."
local full_command = user_input
if lesson.input_data then
    full_command = "echo '" .. lesson.input_data:gsub("'", "'\\''") .. "' | " .. user_input
end

print("Your command: " .. user_input)
print("Full command executed: " .. full_command)
print("")
print("Output:")
local handle = io.popen(full_command .. " 2>&1", "r")
local output = handle:read("*a")
handle:close()
print(output)

-- Validate
local is_correct = false
if type(lesson.expected_output) == "table" then
    for _, exp in ipairs(lesson.expected_output) do
        if output:find(exp, 1, true) then
            is_correct = true
            break
        end
    end
else
    is_correct = output:find(lesson.expected_output, 1, true) ~= nil
end

if is_correct then
    print("✅ CORRECT! Great job!")
else
    print("❌ Not quite right yet.")
    print("Expected output to contain: " .. tostring(lesson.expected_output))
end
LUA
