-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
--                       Contains useful general Lua Functions
-- ===================================================================================

---@class LuaUtils
LuaUtils = {
}

LuaUtils.CheckGlobal = function(sGlobal, hDefault)
    local t
    if (string.sub(sGlobal, 2) ~= "_G") then
        t = _G
    end
    for key in sGlobal:gmatch("[^%.]+") do
        t = t[key]
        if (t == nil) then
            return hDefault
        end
    end
    return t
end

