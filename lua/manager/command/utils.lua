local M = {}

function M.get_table_keys(tab)
    local keyset = {}
    for k, _ in pairs(tab) do
        keyset[#keyset + 1] = k
    end
    table.sort(keyset)
    return keyset
end

return M
