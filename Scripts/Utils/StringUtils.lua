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
string.Escape = function(str)
    return (str):gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

-- =============================================
string.MatchesAll = function(str, none_of_these)
    for _, not_this in pairs(none_of_these) do
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
string.MatchesAny = function(str, none_of_these)
    return (not string.MatchesNone(str, none_of_these))
end