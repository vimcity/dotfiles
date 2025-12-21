return {
    "stevearc/conform.nvim",
    opts = {
        formatters_by_ft = {
            org = { "org_space_todos", "trim_whitespace", "trim_newlines" },
        },
        formatters = {
            org_space_todos = {
                meta = {
                    url = "internal",
                    description = "Add spacing between top-level org todos",
                },
                format = function(self, ctx, lines, callback)
                    local result = {}

                    for i = 1, #lines do
                        local line = lines[i]

                        -- Remove leading spaces from org headings
                        -- e.g., "  * TODO item" becomes "* TODO item"
                        local rest = line:match("^%s*(%*.*)")
                        if rest then
                            line = rest
                        end

                        table.insert(result, line)

                        local next_line = lines[i + 1]
                        local current_is_blank = line:match("^%s*$") ~= nil
                        local next_is_top_level = next_line and next_line:match("^%*%s") ~= nil

                        -- Add blank line before a top-level item if current line is not blank
                        if not current_is_blank and next_is_top_level then
                            table.insert(result, "")
                        end
                    end

                    callback(nil, result)
                end,
            },
        },
    },
}
