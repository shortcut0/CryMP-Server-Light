-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
--                             Contains string utilities
-- ===================================================================================

-- =============================================
string.LSpace = function(str, space, _gsub, _space)
    local str_len = str:len() if (_gsub) then str_len = str:gsub(_gsub, ""):len() end
    local spaces = (space - str_len)
    return ("%s%s"):format(string.rep(_space or " ", spaces), str)
end

-- =============================================
string.RSpace = function(str, space, _gsub, _space)
    local str_len = str:len() if (_gsub) then str_len = str:gsub(_gsub, ""):len() end
    local spaces = (space - str_len)
    return ("%s%s"):format(str, string.rep(_space or " ", spaces))
end

-- =============================================
string.MSpace = function(str, space, _gsub, _space)
    local str_len = str:len()
    if (_gsub) then str_len = str:gsub(_gsub, ""):len() end
    local total_spaces = space - str_len
    if (total_spaces < 0) then total_spaces = 0 end
    local left = math.floor(total_spaces / 2)
    local right = total_spaces - left
    local pad = _space or " "
    return ("%s%s%s"):format(string.rep(pad, left), str, string.rep(pad, right))
end

-- =============================================
-- Primitive string escaping function
string.Escape = function(str)
    return str:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1")
end

-- =============================================
-- Highly advanced string escaping function
-- Key difference: it will NOT escape specials that are already escaped.
-- Examples:
-- "%%"  ==> "%%"      (kept as-is, no double escaping)
-- "%%%" ==> "%%%"     (the first %% is preserved, the remaining % is escaped)
-- With Simple Escape, these would double-escape:
-- "%%"  ==> "%%%%"
-- "%%%" ==> "%%%%%%"
string.ComplexEscape = function(str)
    local out, skipTo = {}, nil
    local specials = "[%^%$%(%)%%%.%[%]%*%+%-%?]"
    for i = 1, #str do
        if not skipTo or i >= skipTo then
            skipTo = nil
            local c = str:sub(i,i)
            if c:match(specials) then
                local next_part  = str:sub(i+1)
                local prev_part  = str:sub(1,i-1)
                local next_perc  = next_part:match("%%+")
                local prev_perc  = prev_part:match("(%%+)$")
                if c == "%" then
                    if i == 1 and not next_perc then
                        c = "%%"
                    elseif next_perc then
                        if #next_perc % 2 == 0 then
                            c = "%" .. next_perc
                            skipTo = i + (#next_perc / 2) + 1
                        end
                    elseif not prev_perc then
                        c = "%%"
                    end
                else
                    c = "%" .. c
                end
            end
            table.insert(out, c)
        end
    end
    return table.concat(out)
end

-- =============================================
string.MatchesAll = function(str, all_of_these)
    for _, not_this in pairs(all_of_these) do
        if (not string.match(str, not_this)) then
            return false
        end
    end
    return true
end

-- =============================================
string.MatchesNone = function(str, none_of_these)
    for _, not_this in pairs(none_of_these) do
        if (string.match(str, not_this)) then
            return false
        end
    end
    return true
end

-- =============================================
string.MatchesAny = function(str, any_of_these)
    return (not string.MatchesNone(str, any_of_these))
end

-- =============================================
string.CleanNonASCII = function(s, sPattern)
    local sCleaned = ""
    local sCleanedPattern = sPattern or "[a-zA-Z0-9_'{}\"%(%) %*&%%%$#@!%?/\\;:,%.<>%-%[%]%+]"

    for i = 1, #s do
        local sChar = s:sub(i, i)
        if sChar:match(sCleanedPattern) then
            sCleaned = sCleaned .. sChar
        end
    end

    return sCleaned
end
