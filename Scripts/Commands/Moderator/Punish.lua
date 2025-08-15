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
    -- !Kick <Player> <Reason>
    {
        Name = "Kick",
        Access = ServerAccess_Moderator,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Required = true, Type = CommandArg_TypePlayer, NotSelf = true },
            { Name = "@reason", Desc = "@reason_desc", Default = "@admin_decision", Type = CommandArg_TypeMessage },
        },
        Properties = {
            This = "Server.Punisher"
        },
        Function = function(self, hPlayer, hTarget, sReason)
            return self:Command_KickPlayer(hPlayer, hTarget, sReason)
        end
    },

})