-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
--                          This file Contains Chat-Commands
-- ===================================================================================

Server.ChatCommands:Add({

    -- ================================================================
    -- !Firework
    {
        Name = "BigFirework",
        Access = ServerAccess_Premium,
        Arguments = {
        },
        Properties = {
            CoolDown = 120,
        },
        Function = function(self)
            for i = 0, 3 do
                Script.SetTimer(i * 300, function()
                    Server.Utils:SpawnEffect(Effect_Firework, self:GetPos())
                end)
            end
        end
    },
})