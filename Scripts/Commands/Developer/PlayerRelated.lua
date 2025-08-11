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
    -- !Revive <Target> <AtSpawn>
    {
        Name = "InitPlayer",
        Access = ServerAccess_Developer,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Required = true, Type = CommandArg_TypePlayer, Default = "self", AcceptSelf = true, AcceptAll = true },
        },
        Properties = {
        },
        Function = function(self, hTarget, sOption)
            if (hTarget == self) then
                Server.ActorHandler:AddActorFunctions(self)
                return true
            elseif (hTarget == ALL_PLAYERS) then
                for _, hVictim in pairs(Server.Utils:GetPlayers()) do
                    Server.ActorHandler:AddActorFunctions(hVictim)
                end
                return true
            end

            Server.ActorHandler:AddActorFunctions(hTarget)
            return true
        end
    },
})