local M = {}

local launcher = vim.fn.expand("~/dotfiles/bin/org-pi")

local function current_org_context()
  if vim.bo.filetype ~= "org" then
    vim.notify("Org AI: open an Org file first", vim.log.levels.WARN)
    return nil
  end

  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("Org AI: save the Org file first", vim.log.levels.WARN)
    return nil
  end

  local line = vim.fn.line(".")
  while line > 0 and not vim.fn.getline(line):match("^%*+%s+") do
    line = line - 1
  end
  if line == 0 then
    vim.notify("Org AI: no heading under cursor", vim.log.levels.WARN)
    return nil
  end

  return { file = file, line = line }
end

local function run(args, callback)
  local command = vim.list_extend({ launcher }, args)
  vim.system(command, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        local message = vim.trim(result.stderr ~= "" and result.stderr or result.stdout)
        vim.notify("Org AI: " .. message, vim.log.levels.ERROR)
        return
      end
      callback(vim.trim(result.stdout))
    end)
  end)
end

function M.plan()
  local context = current_org_context()
  if not context then
    return
  end

  run({ "plan", "--org-file", context.file, "--line", tostring(context.line) }, function(output)
    if output ~= "" then
      vim.cmd.edit(vim.fn.fnameescape(output:match("[^\n]+")))
    end
  end)
end

function M.launch()
  local context = current_org_context()
  if not context then
    return
  end

  local args = { "launch", "--org-file", context.file, "--line", tostring(context.line) }
  run(vim.list_extend(vim.deepcopy(args), { "--dry-run" }), function(preview)
    if vim.fn.confirm("Launch this Org task with Pi in Herdr?\n\n" .. preview, "&Launch\n&Cancel", 2) ~= 1 then
      return
    end
    run(args, function(output)
      vim.notify("Org AI: launched Pi task", vim.log.levels.INFO)
      if output ~= "" then
        vim.notify(output, vim.log.levels.DEBUG)
      end
    end)
  end)
end

vim.api.nvim_create_user_command("OrgAiPlan", M.plan, { desc = "Open or create a plan for the current Org task" })
vim.api.nvim_create_user_command("OrgAiLaunch", M.launch, { desc = "Launch the current Org task with Pi in Herdr" })

return M
