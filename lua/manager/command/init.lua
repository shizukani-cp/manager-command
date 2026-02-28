local M = {}
local manager = require("manager.core")

M.subcommands = {
    ["clean"] = function()
        manager.clean()
        vim.notify("Clean completed. Untracked plugins removed.")
    end,
    ["list"] = function()
        local buf = vim.api.nvim_create_buf(false, true)
        local ids = {}

        for name, _ in pairs(manager.plugins or {}) do
            table.insert(ids, name)
        end

        if #ids == 0 then
            ids = { "No plugins found" }
        else
            table.sort(ids)
        end

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, ids)
        vim.api.nvim_set_current_buf(buf)
    end,
    ["load"] = function(args)
        local target = args[2]
        if not target then
            vim.notify("Please specify plugin id to load.", vim.log.levels.WARN)
            return
        end
        manager.load(target)
    end,
    ["remove"] = function(args)
        local target = args[2]
        if not target then
            vim.notify("Please specify plugin id to remove.", vim.log.levels.WARN)
            return
        end
        manager.remove(target)
    end,
    ["update"] = function(args)
        local target = args[2]
        manager.update(target)
        if target then
            vim.notify("Updating plugin: " .. target)
        else
            vim.notify("Updating all plugins.")
        end
    end,
}

function M.add_subcommand(name, body)
    M.subcommands[name] = body
end

function M.setup()
    vim.api.nvim_create_user_command("Manager", function(opts)
        local args = opts.fargs
        local sub = args[1]

        if not sub then
            vim.notify(
                "Usage: :Manager <" .. table.concat(vim.tbl_keys(M.subcommands), "|") .. "> [args]",
                vim.log.levels.WARN
            )
            return
        end

        for name, body in pairs(M.subcommands) do
            if sub == name then
                body(args)
                return
            end
        end
        vim.notify("Unknown subcommand: " .. sub, vim.log.levels.ERROR)
    end, {
        nargs = "*",
        complete = function(_, line)
            local subcmds = vim.tbl_keys(M.subcommands)
            local args = vim.split(line, "%s+")
            if #args == 2 then
                return vim.tbl_filter(function(item)
                    return vim.startswith(item, args[2])
                end, subcmds)
            end
            return {}
        end,
    })
end

return M
