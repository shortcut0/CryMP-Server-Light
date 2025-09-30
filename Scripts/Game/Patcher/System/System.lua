-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- Contains Patched functions for 'System'
-- ===================================================================================

Server.Patcher:HookClass({
    Class = "System",
    HookNow = true,
    Body = {
        {
            Name = "SpawnEntity",
            Backup = true,
            Value = function(tParams, ...)
                --if (not tParams) then
                --    error("empty spawn params")
                --     return
                -- end
                --if (tParams.IsServerSpawn) then
                local hEntity = System.SpawnEntity_Backup(tParams, ...)
                return hEntity
                --end
                --return Server.Utils:SpawnEntity(tParams)
            end,
        },
        {
            Name = "Log",
            Backup = true,
            Value = function(sMsg, ...)
                Server.Logger:Log("[System] " .. sMsg, ...)
                System.Log_Backup(sMsg, ...)
            end,
        },
        {
            Name = "Warning",
            Backup = true,
            Value = function(sMsg, ...)
                Server.Logger:LogWarning("[System] Warning: " .. sMsg, ...)
                System.Warning_Backup(sMsg, ...)
            end,
        },
        {
            Name = "Error",
            Backup = true,
            Value = function(sMsg, ...)
                Server.Logger:LogError("[System] Error: " .. sMsg, ...)
                System.Error_Backup(sMsg, ...)
            end,
        }
    }
})