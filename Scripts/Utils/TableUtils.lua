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
--- { {1} }             ---> true
--- { {1}, [5] = {} }   ---> true
--- { 1 }               ---> false
--- { 1, {1} }          ---> false
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

----------------------------------
--- Recursively counts elements inside a table
table.CountRecursive = function(tbl, fPred, tInfo)

    tInfo = tInfo or { Level = 1 }

    local iCount = 0
    for i, v in pairs(tbl) do
        if (fPred == nil or fPred(i, v, tInfo.Level)) then
            if (type(v) == "table") then
                iCount = iCount + table.CountRecursive(v, fPred, { Level = tInfo.Level + 1 })
            else
                iCount = iCount + 1
            end
        end
    end
    return iCount
end

----------------------------------
--- Formats a table to string
table.ToString = function(tbl, tInfo)

    local iMaxDepth = (tInfo.MaxDepth or -1)
    local iDepth = (tInfo.CurrentDepth or 0)
    local sName = (tInfo.Name or tostring(tbl))
    local sTab = (tInfo.Tab or "   ")
    local sTbl = "{"
    if (string.emptyN(sName)) then
        sTbl = ("%s = {"):format(sName)
    end

    sTbl = (sTbl .. "\n")

    local iTbl = table.size(tbl)
    local iCurr = 0
    for sKey, hValue in pairs(tbl) do
        local sElement
        local sType = type(hValue)
        iCurr = (iCurr + 1)
        if (sType == "table") then
            if (tInfo.Processed[hValue]) then
                sElement = ([[["%s"] = %s]]):format(sKey, tostring(hValue))
            else
                tInfo.Processed[hValue] = true
                if (iMaxDepth ~= -1 and iDepth >= iMaxDepth) then
                    sElement = ([[["%s"] = %s]]):format(sKey, tostring(hValue))
                else
                    sElement = ([[["%s"] = %s]]):format(sKey, table.ToString(hValue, {
                        iDepth = (iDepth + 1),
                        iMaxDepth = iMaxDepth,
                        Processed = tInfo.Processed,
                        Name = "",
                        Tab = (sTab .. sTab),
                    }))
                end
            end
        elseif (sType == "number") then
            sElement = ([[["%s"] = %d]]):format(sKey, hValue)
            if (string.find(tostring(hValue), "%.")) then
                sElement = ([[["%s"] = %f]]):format(sKey, hValue)
            end
        elseif (sType == "string") then
            sElement = ([[["%s"] = "%s"]]):format(sKey, hValue)
        else
            sElement = ([[["%s"] = %s]]):format(sKey, tostring(hValue))
        end

        if (iCurr ~= iTbl) then
            sElement = sElement .. ","
        end

        sTbl = (sTbl .. sElement .. "\n")
    end

    sTbl = (sTbl .. "}")
    return sTbl
end

