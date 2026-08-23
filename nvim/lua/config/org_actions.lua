local M = {}

local function org_api()
  return require("orgmode.api")
end

local function collect_headlines(headlines, result)
  for _, headline in ipairs(headlines) do
    if headline.todo_value == "DONE" and not headline.is_archived then
      -- A completed project headline represents its whole subtree. Do not also
      -- offer its completed children, or selecting both could split the tree.
      result[#result + 1] = headline
    else
      collect_headlines(headline.headlines, result)
    end
  end
end

local function completed_headlines()
  local result = {}
  local files = org_api().load()

  for _, file in ipairs(files) do
    if not file.is_archive_file then
      collect_headlines(file.headlines, result)
    end
  end

  table.sort(result, function(left, right)
    if left.file.filename == right.file.filename then
      return left.position.start_line < right.position.start_line
    end
    return left.file.filename < right.file.filename
  end)

  return result
end

local function picker_items()
  local items = {}

  for _, headline in ipairs(completed_headlines()) do
    local relative_file = vim.fn.fnamemodify(headline.file.filename, ":~:.")
    items[#items + 1] = {
      text = ("[%s] %s  ·  %s:%d"):format(
        headline.todo_value,
        headline.title,
        relative_file,
        headline.position.start_line
      ),
      file = headline.file.filename,
      pos = { headline.position.start_line, 0 },
      item = headline,
    }
  end

  return items
end

local function collect_inbox_headlines(headlines, items, tag_filter)
  for _, headline in ipairs(headlines) do
    local matches_tag = not tag_filter
    for _, headline_tag in ipairs(headline.all_tags) do
      matches_tag = matches_tag or headline_tag:lower() == tag_filter
    end
    if (headline.todo_value == "TODO" or headline.todo_value == "PROGRESS")
        and not headline.is_archived
        and not headline.scheduled
        and not headline.deadline
        and matches_tag then
      local tags = #headline.all_tags > 0 and ("  :%s:"):format(table.concat(headline.all_tags, ":")) or ""
      items[#items + 1] = {
        text = ("[%s] %s%s  ·  %s:%d"):format(
          headline.todo_value,
          headline.title,
          tags,
          vim.fn.fnamemodify(headline.file.filename, ":~:."),
          headline.position.start_line
        ),
        file = headline.file.filename,
        pos = { headline.position.start_line, 0 },
        item = headline,
      }
    end
    collect_inbox_headlines(headline.headlines, items, tag_filter)
  end
end

local function notify_error(error)
  vim.notify("Org action failed: " .. tostring(error), vim.log.levels.ERROR)
end

local function open_headline(headline)
  vim.cmd.edit(vim.fn.fnameescape(headline.file.filename))
  vim.api.nvim_win_set_cursor(0, { headline.position.start_line, 0 })
end

local function run_serial(items, action, on_complete)
  local promise = require("orgmode.utils.promise").resolve()

  for _, item in ipairs(items) do
    promise = promise:next(function()
      return action(item.item)
    end)
  end

  promise:next(on_complete, notify_error)
end

local function fresh_headline(headline)
  local file = org_api().load(headline.file.filename)
  return file:get_headline_on_line(headline.position.start_line)
end

local function toggle_archive_tag(picker)
  local items = picker:selected({ fallback = true })
  picker:close()

  if #items == 0 then
    vim.notify("No completed tasks selected", vim.log.levels.INFO)
    return
  end

  run_serial(items, function(headline)
    local current = fresh_headline(headline)
    local tags = vim.deepcopy(current.tags)
    tags[#tags + 1] = "ARCHIVE"
    return current:set_tags(tags)
  end, function()
    vim.notify(("Tagged %d task(s) with :ARCHIVE:"):format(#items), vim.log.levels.INFO)
  end)
end

local function archive_to_file(picker)
  local items = picker:selected({ fallback = true })
  picker:close()

  if #items == 0 then
    vim.notify("No completed tasks selected", vim.log.levels.INFO)
    return
  end

  -- Refile from bottom to top within each file. Removing a later subtree then
  -- cannot invalidate the original line positions of earlier selections.
  table.sort(items, function(left, right)
    local left_headline, right_headline = left.item, right.item
    if left_headline.file.filename == right_headline.file.filename then
      return left_headline.position.start_line > right_headline.position.start_line
    end
    return left_headline.file.filename < right_headline.file.filename
  end)

  run_serial(items, function(headline)
    local current = fresh_headline(headline)
    local internal_file = require("orgmode").files:get(current.file.filename)
    local archive_path = internal_file:get_archive_file_location()

    if not archive_path then
      error("No archive location for " .. current.file.filename)
    end

    local archive_directory = vim.fn.fnamemodify(archive_path, ":p:h")
    vim.fn.mkdir(archive_directory, "p")
    if vim.fn.filereadable(archive_path) == 0 then
      vim.fn.writefile({}, archive_path)
    end

    local destination = org_api().load(archive_path)
    return org_api().refile({ source = current, destination = destination })
  end, function()
    vim.notify(("Archived %d task(s) to their archive file(s)"):format(#items), vim.log.levels.INFO)
  end)
end

function M.inbox_picker(tag)
  require("orgmode").files:ensure_loaded()
  local tag_filter = tag and tag:lower() or nil
  local items = {}

  for _, file in ipairs(org_api().load()) do
    if not file.is_archive_file then
      collect_inbox_headlines(file.headlines, items, tag_filter)
    end
  end

  local function selected_item(picker)
    return picker:selected({ fallback = true })[1]
  end

  Snacks.picker({
    source = "org_inbox",
    title = tag_filter and ("Org inbox · " .. tag) or "Org inbox · unscheduled",
    items = items,
    format = "text",
    preview = "file",
    actions = {
      open_org = function(picker)
        local selected = selected_item(picker)
        picker:close()
        if selected then
          vim.schedule(function()
            open_headline(selected.item)
          end)
        end
      end,
      schedule_org = function(picker)
        local selected = selected_item(picker)
        picker:close()
        if not selected then
          return
        end
        vim.schedule(function()
          open_headline(selected.item)
          local current = org_api().current():get_headline_on_line(selected.item.position.start_line)
          current:set_scheduled():next(function()
            vim.notify("Scheduled: " .. current.title, vim.log.levels.INFO)
          end, notify_error)
        end)
      end,
    },
    confirm = "open_org",
    win = {
      input = {
        keys = {
          ["s"] = { "schedule_org", mode = { "n", "i" }, desc = "Schedule task" },
        },
      },
      list = {
        keys = {
          ["s"] = { "schedule_org", desc = "Schedule task" },
        },
      },
    },
  })
end

function M.bulk_archive_picker()
  require("orgmode").files:ensure_loaded()

  Snacks.picker({
    source = "org_bulk_archive",
    title = "Archive completed Org tasks",
    finder = picker_items,
    format = "text",
    preview = "file",
    actions = {
      archive_file = archive_to_file,
      archive_tag = toggle_archive_tag,
    },
    win = {
      input = {
        keys = {
          ["a"] = { "archive_file", mode = { "n", "i" }, desc = "Archive to file" },
          ["t"] = { "archive_tag", mode = { "n", "i" }, desc = "Add ARCHIVE tag" },
        },
      },
      list = {
        keys = {
          ["a"] = { "archive_file", desc = "Archive to file" },
          ["t"] = { "archive_tag", desc = "Add ARCHIVE tag" },
        },
      },
    },
  })
end

vim.api.nvim_create_user_command("OrgBulkArchiveDone", M.bulk_archive_picker, {
  desc = "Select completed Org tasks and archive them",
})
vim.api.nvim_create_user_command("OrgInbox", function(opts)
  M.inbox_picker(opts.args ~= "" and opts.args or nil)
end, {
  nargs = "?",
  desc = "Browse unscheduled Org tasks, optionally filtered by tag",
})

return M
