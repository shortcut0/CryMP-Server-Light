-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- Contains Patched functions for Turrets
-- ===================================================================================

-- !! New Client does NOT load Items.lua anymore to define Turrets, etc. It loads them directly in the code..
--[[

Server.Patcher:HookClass({
    Parent = "AutoTurret",
    Class = {
        "AutoTurretAA",
        "WarriorMOARTurret",
        "AlienTurret",
    },
    Body  = {
        {
            -------------------------------
            ---    Server.OnUpdate
            -------------------------------
            Name = "Server.OnUpdate",
            Value = function(self, iFt)
                DebugLog("update ?")
            end,
        },
    }
})
]]