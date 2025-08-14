-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
--                             Contains math utilities
-- ===================================================================================

math.GetMin = function(a, b)
    return (a<b and a or b)
end

math.GetMax = function(a, b)
    return (a>b and a or b)
end

math.ToRoman = function(n)
    local tRoman = {
        { 1000, "M" },  { 900, "CM" },  { 500, "D" },   { 400, "CD" },
        { 100, "C" },   { 90, "XC" },   { 50, "L" },    { 40, "XL" },
        { 10, "X" },    { 9, "IX" },    {  5, "V" },    {  4, "IV" }, {  1, "I" }
    }

    local sResult = ""
    for _, v in ipairs(tRoman) do
        local value, roman = v[1], v[2]
        while (n >= value) do
            sResult = sResult .. roman
            n = n - value
        end
    end

    return sResult
end
