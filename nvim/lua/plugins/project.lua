return {
  "ahmedkhalf/project.nvim",
  config = function()
    require("project_nvim").setup({
      manual_mode = false,
      detection_methods = { "lsp", "pattern" },
      patterns = { ".git", "package.json", "Makefile" },
    })

    -- Create a command to scan and add all projects from ~/Projects
    vim.api.nvim_create_user_command("ProjectScanAll", function()
      local projects_dir = vim.fn.expand("~/Projects")
      if vim.fn.isdirectory(projects_dir) ~= 1 then
        vim.notify("~/Projects directory not found", vim.log.levels.ERROR)
        return
      end

      local count = 0
      local handle = vim.loop.fs_scandir(projects_dir)
      
       if handle then
         while true do
           local name, type = vim.loop.fs_scandir_next(handle)
           if not name then break end

           if type == "directory" then
             local project_path = projects_dir .. "/" .. name
             local git_path = project_path .. "/.git"

             -- If it's a git repo, add to project history
             if vim.fn.isdirectory(git_path) == 1 then
               require("project_nvim.project").set_pwd(project_path, "manual")
               count = count + 1
             end
           end
         end
       end

      vim.notify(string.format("Added %d projects from ~/Projects", count), vim.log.levels.INFO)
    end, { desc = "Scan and add all projects from ~/Projects" })
  end,
}
