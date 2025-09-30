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
table.Find_Value = function(this, find_these)
    find_these = table.ToTable(find_these, {})
    if (#find_these == 0) then
        return
    end
    for k, v in pairs(this) do
        for kk, vv in pairs(find_these) do
            if (v == vv) then
                return v
            end
        end
    end
end

----------------------------------
table.Find_ValueAll = function(this, find_these)
    find_these = table.ToTable(find_these, {})
    if (#find_these == 0) then
        error("nothing to find")
    end
    local found = 0
    for k, v in pairs(this) do
        for kk, vv in pairs(find_these) do
            if (v == vv) then
                found = found + 1
            end
        end
    end
    return (found == #find_these)
end

----------------------------------
--- Use recursion with caution!
table.Destroy = function(this, recursive)
    for k, v in pairs(this) do
        if (type(v) == "table" and recursive) then
            if (v == _G) then
                error("attempt to destroy _G, check the table you are trying to destroy")
            end
            table.Destroy(v, true)
        end
        this[k] = nil
    end
    return this
end

----------------------------------
table.ShiftLeft = function(this, start, in_place)

    local removed = this[start]
    if (in_place) then
        for i = start, #this - 1 do
            this[i] = this[i + 1]
        end
        return removed
    end
    local t = {}
    for i = start, #this - 1 do
        t[i] = this[i + 1]
    end
    return t, removed
end

----------------------------------
table.GetIndex = function(t, value, default)
    for k, v in pairs(t) do
        if (value == v) then
            return k
        end
    end
    return default
end

table.GetIndexRecursive = function(t, value, full_stack, __info, sOrigin)
    t = t or _G
    if (value == _G) then
        return "_G"
    end
    __info  = __info  or { Processed = {}, Stack = table.GetIndexRecursive(_G, t) }
    if (__info.Processed[t]) then
        return
    end
    __info.Processed[t] = true
    sOrigin = (sOrigin or __info.Stack)

    for k, v in pairs(t) do
        local path = sOrigin .. "." .. tostring(k)
        if v == value then
            return k, path
        elseif type(v) == "table" then
            local _k, _path = table.GetIndexRecursive(v, value, full_stack, __info, path)
            if _k then
                return _k, _path
            end
        end
    end
    return
end

----------------------------------
table.Size = function(this)
    if (type(this) ~= "table") then
        error("Size() but it's not a table")
    end
    local count = 0
    for _ in pairs(this) do
        count = (count + 1)
    end
    return count
end

----------------------------------
table.Copy = function(t)
    local n = {}
    for k, v in pairs(t or{}) do
        n[k] = v
    end
    return n
end

----------------------------------
table.DeepCopy = function(t)
    local n = {}
    for k, v in pairs(t or{}) do
        if (type(v) == "table" and v ~= t) then
            n[k] = table.DeepCopy(v)
        else
            n[k] = v
        end
    end
    return n
end

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
        table.Destroy(tbl)
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
--- Returns a random index
table.Random = function(tbl)
    local iSize = table.size(tbl)
    if (iSize == 0) then
        return
    end
    local iRandom = math.random(1, iSize)
    local iCurrent = 0
    for _, v in pairs(tbl) do
        iCurrent = iCurrent + 1
        if (iCurrent == iRandom) then
            return v
        end
    end
end

----------------------------------
--- Combines the values of two tables, making sure the result wont contain duplicates
table.Combine_Values = function(table_one, table_two)

    local table_new = {}
    local table_index = {}
    for i, v in pairs(table_one) do
        table_index[v] = true
        table.insert(table_new, v)
    end
    for _, v in pairs(table_two) do
        if (not table_index[v]) then
            table.insert(table_new, v)
        end
    end
    return table_new
end

----------------------------------
--- Removes the key from a table
table.Remove_Key = function(tbl, key)
    tbl[key] = nil
    return tbl
end

----------------------------------
--- Removes Values from a table
table.Remove_Value = function(tbl, value, limit)
    local c = 0
    for _, v in pairs(tbl) do
        if (v == value) then
            tbl[_] = nil
            c = c + 1
            if (limit and c >= limit) then
                break
            end
        end
    end
    return tbl
end

----------------------------------
--- Formats a table to string
table.ToString = function(tbl, tInfo)

    tInfo = tInfo or {}
    tInfo.Processed = tInfo.Processed or {}

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
    for _, hValue in pairs(tbl) do
        local sElement
        local sKey = tostring(_)
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

----------------------------------
--- Converts an input into a table, if input is nil, returns the specified default value, if no default value was provided, will return an empty table instead
table.ToTable = function(t, d)

    -- t is nil
    if (t == nil) then
        -- return default or empty table
        return (d ~= nil and d or {})
    end
    -- t is not a table, so we encapsulate it
    if (type(t) ~= "table") then
        return { t }
    end
    -- t is a table
    return t
end

----------------------------------
--- Assigns a value to a table using a nested key path.
---
--- Supports dot-separated paths and automatically creates intermediate tables.
--- Optionally raises an error if a non-table value would be overwritten.
---
--- Examples:
--- local x = {}
--- table.Assign(x, "a.b.c", "hello world")
--- -- Result: x = { a = { b = { c = "hello world" } } }
---
--- table.Assign(x, "a", "hello world")
--- -- Result: x = { a = "hello world" }
---
--- local x = { a = "not_a_table" }
--- table.Assign(x, "a.b", 42, true)
--- -- Raises an error because 'a' is not a table
---
---@param tbl table         The table to assign the value into.
---@param nest string       The nested key path (dot-separated), e.g., "foo.bar.baz".
---@param value any         The value to assign at the specified path.
---@param raise_error boolean?  If true, raises an error when a non-table key would be overwritten.
---@return any              Returns the assigned value.
table.Assign = function(tbl, nest, value, raise_error)

    local curr_index = tbl
    if (not string.find(nest, "%.")) then
        tbl[nest] = value
        return value
    end

    local split = string.split(nest, ".")
    for i = 1, #split do
        local index = split[i]
        if (i == #split) then
            curr_index[index] = value
            break
        end

        if (curr_index[index] == nil) then
            curr_index[index] = {}
        else
            local index_type = type(curr_index[index])
            if (raise_error and index_type ~= "table") then
                error("attempt to overwrite an existing key " .. tostring(index) .. " - its a " .. index_type)
            end
        end

        curr_index = curr_index[index]
    end

    return value
end

