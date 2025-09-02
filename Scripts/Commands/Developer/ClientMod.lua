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
    -- !InstallClient <Target>
    {
        Name = "InstallClient",
        Access = ServerAccess_Developer,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Required = true, Type = CommandArg_TypePlayer, Default = "self", AcceptSelf = true, AcceptAll = true },
        },
        Properties = {
        },
        Function = function(self, hTarget)
            if (not Server.ClientMod:IsComponentEnabled()) then
                return false, "@clientMod_disabled"
            end

            if (hTarget == ALL_PLAYERS) then
                for _, hVictim in pairs(Server.Utils:GetPlayers()) do
                    Server.ClientMod:InstallMod(hVictim, true)
                end
                return true
            end

            Server.ClientMod:InstallMod(hTarget, true)
            return true
        end
    },
})