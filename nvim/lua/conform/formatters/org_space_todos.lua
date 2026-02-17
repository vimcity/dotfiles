local function is_heading(line)
  return line and line:match("^%*+") ~= nil
end

local function is_blank(line)
  return line and line:match("^%s*$") ~= nil
end

local function is_property(line)
  return line and (line:match("^%s*SCHEDULED:") or line:match("^%s*DEADLINE:"))
end

local function heading_level(line)
  local star = line and line:match("^(%*+)")
  return star and #star or 0
end

local function format_lines(lines)
  local result = {}
  local current_heading_level = 0

  local function last_nonblank()
    for i = #result, 1, -1 do
      if not is_blank(result[i]) then
        return result[i]
      end
    end
    return nil
  end

  local function add_blank()
    local last = result[#result]
    if not last or not is_blank(last) then
      table.insert(result, "")
    end
  end

  local function next_nonblank(start_index)
    for j = start_index + 1, #lines do
      local candidate = lines[j]:gsub("%s+$", "")
      if candidate ~= "" then
        return candidate
      end
    end
    return nil
  end

  for i, line in ipairs(lines) do
    local trimmed = line:gsub("%s+$", "")

    if trimmed == "" then
      local prev = last_nonblank()
      local next_line = next_nonblank(i)
      if prev and next_line then
        local next_is_top = is_heading(next_line) and heading_level(next_line) == 1
        if not next_is_top then
          add_blank()
        end
      end
    else
      if is_heading(trimmed) then
        local level = heading_level(trimmed)
        current_heading_level = level
        if level == 1 and last_nonblank() then
          add_blank()
        end
        table.insert(result, trimmed)
      elseif is_property(trimmed) then
        local indent = current_heading_level > 0 and (current_heading_level + 1) or 2
        local prop_line = string.rep(" ", indent) .. trimmed:gsub("^%s*", "")
        table.insert(result, prop_line)

        local next_line = next_nonblank(i)
        if next_line and is_heading(next_line) and heading_level(next_line) == 1 then
          add_blank()
        end
      else
        table.insert(result, trimmed)
      end
    end
  end

  while #result > 0 and is_blank(result[#result]) do
    table.remove(result)
  end

  return result
end

return {
  meta = {
    url = "internal",
    description = "Format org todos with consistent spacing",
  },
  format = function(self, ctx, lines, callback)
    local input = lines
    if not input then
      local bufnr = ctx and ctx.bufnr or 0
      input = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
    end
    local result = format_lines(input)
    callback(nil, result)
  end,
}
