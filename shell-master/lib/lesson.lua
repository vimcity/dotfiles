-- Lesson structure and management
local Lesson = {}

function Lesson.new(title, description, category, difficulty, task, expected_output, hints)
    return {
        title = title,
        description = description,
        category = category or "general",
        difficulty = difficulty or "beginner", -- beginner, intermediate, advanced
        task = task, -- What the user needs to do
        expected_output = expected_output, -- What the output should contain/be
        hints = hints or {},
        completed = false,
        attempts = 0,
        max_attempts = 3,
    }
end

function Lesson:display()
    print("\n" .. string.rep("=", 60))
    print("📚 " .. self.title .. " [" .. string.upper(self.difficulty) .. "]")
    print(string.rep("=", 60))
    print("\n" .. self.description)
    print("\n" .. "Task:")
    print("  " .. self.task)
    print("\n" .. "Try it:")
end

function Lesson:show_hint(attempt_num)
    if self.hints and self.hints[attempt_num] then
        print("\n💡 Hint " .. attempt_num .. ": " .. self.hints[attempt_num])
    end
end

function Lesson:validate(output)
    -- Simple substring matching for now
    -- Can be extended for regex or more complex validation
    if type(self.expected_output) == "table" then
        for _, expected_str in ipairs(self.expected_output) do
            if output:find(expected_str, 1, true) then
                return true
            end
        end
        return false
    else
        return output:find(self.expected_output, 1, true) ~= nil
    end
end

return Lesson
