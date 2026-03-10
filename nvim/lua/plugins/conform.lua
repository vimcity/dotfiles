return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        formatters_by_ft = {
            -- Java formatting is done via IDE (IntelliJ/VS Code)
            -- Use eclipse-formatter.xml imported into your IDE
            org = { "org_space_todos" },
        },
        formatters = {
            org_space_todos = require("conform.formatters.org_space_todos"),
        },
    },
}
