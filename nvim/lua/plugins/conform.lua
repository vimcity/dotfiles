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
                    description = "Format org todos with consistent spacing",
                },
                format = function(self, ctx, lines, callback)
                    local result = {}
                    local i = 1

                    local function is_heading(line)
                        return line:match("^%*+") ~= nil
                    end

                    local function is_blank(line)
                        return line:match("^%s*$") ~= nil
                    end

                    local function is_property(line)
                        return line:match("^%s*SCHEDULED:") or line:match("^%s*DEADLINE:")
                    end

                    local function heading_level(line)
                        local star = line:match("^(%*+)")
                        return star and #star or 0
                    end

                    local function add_line(line)
                        table.insert(result, line)
                    end

                    local function add_blank()
                        local last = result[#result]
                        if not last or not is_blank(last) then
                            table.insert(result, "")
                        end
                    end

                    local function should_add_blank(prev_line, next_line)
                        if not next_line then
                            return false
                        end

                        if is_blank(next_line) then
                            return false
                        end

                        local prev_is_heading = prev_line and is_heading(prev_line)
                        local next_is_heading = next_line and is_heading(next_line)

                        if prev_is_heading and next_is_heading then
                            local prev_level = heading_level(prev_line)
                            local next_level = heading_level(next_line)
                            return next_level < prev_level or (prev_level == 1 and next_level == 1)
                        end

                        return false
                    end

                    while i <= #lines do
                        local line = lines[i]
                        local orig_line = line

                        if is_heading(line) then
                            line = line:gsub("^%s+", "")
                            add_line(line)

                            local next_line = lines[i + 1]
                            if is_property(next_line) then
                            elseif is_heading(next_line) or is_blank(next_line) then
                                if should_add_blank(orig_line, next_line) then
                                    add_blank()
                                end
                            end
                        elseif is_property(line) then
                            add_line(line)

                            local next_line = lines[i + 1]
                            if next_line and not is_heading(next_line) then
                                add_blank()
                            end
                        elseif is_blank(line) then
                            local prev_line = result[#result]
                            local next_line = lines[i + 1]

                            if prev_line and next_line then
                                if should_add_blank(prev_line, next_line) then
                                    add_blank()
                                end
                            end
                        else
                            add_line(line)
                        end

                        i = i + 1
                    end

                    callback(nil, result)
                end,
            },
        },
    },
}
