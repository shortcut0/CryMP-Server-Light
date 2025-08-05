-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
--                             Contains table utilities
-- ===================================================================================

----------------------------------
--- Checks if a table is recursive
--- { {1} }     ---> true
--- { 1 }       ---> false
--- { 1, {1} }  ---> false
table.IsRecursive = function(this)
    if (type(this) ~= "table") then
        return
    end

    local count = 0
    for _, v in pairs(this) do
        count = (count + 1)
        if (type(_) ~= "number" or type(v) ~= "table") then
            return false
        end
    end
    return true
end

----------------------------------
--- Merges two tables
--- table_one elements will always be overwritten by table_two
table.Merge = function(table_one, table_two, in_place)
    if (type(table_one) ~= "table") then
        return
    end
    if (type(table_two) ~= "table") then
        return
    end

    if (in_place) then
        for sKey, pVal in pairs(table_two) do
            table_one[sKey] = pVal
        end
        return table_one
    end

    local table_new = {}
    for sKey, pVal in pairs(table_one) do
        table_new[sKey] = pVal
    end
    for sKey, pVal in pairs(table_two) do
        table_new[sKey] = pVal
    end

    return table_new
end

----------------------------------
--- Merges two tables, overwriting the table_one directly
--- table_one elements will always be overwritten by table_two
table.MergeInPlace = function(table_one, table_two)
    return table.Merge(table_one, table_two, true)
end

----------------------------------
--- Appends table_two into table_one
table.Append = function(table_one, table_two, in_place)

    if (in_place) then
        for i, value in pairs(table_two) do
            table.insert(table_one, value)
        end
        return table_one
    end

    local table_new = {}
    for i, value in pairs(table_one) do
        table.insert(table_new, value)
    end
    for i, value in pairs(table_two) do
        table.insert(table_new, value)
    end
    return table_new
end

----------------------------------
--- Appends table_two into table_one, overwriting table_one
table.AppendInPlace = function(table_one, table_two)
    return table.Append(table_one, table_two, true)
end

----------------------------------
--- Reverse the order of a table
table.Reverse = function(tbl, in_place)
    local reversed = {}
    for i = #tbl, 1, -1 do
        reversed[#reversed + 1] = tbl[i]
    end
    if in_place then
        for k in pairs(tbl) do
            tbl[k] = nil
        end
        for i, value in ipairs(reversed) do
            tbl[i] = value
        end
        return tbl
    end
    return reversed
end

