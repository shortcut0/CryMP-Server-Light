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

    -- ================================================================
    -- !Mute <Player> <Duration> <Reason>
    {
        Name = "Mute",
        Access = ServerAccess_Admin,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Required = true, Type = CommandArg_TypePlayer, NotSelf = false },
            { Name = "@time",   Desc = "@arg_time_desc",   Required = true, Type = CommandArg_TypeTimeRaw, AcceptInvalidTime = true },
            { Name = "@reason", Desc = "@reason_desc", Default = "@admin_decision", Type = CommandArg_TypeMessage },
        },
        Properties = {
            This = "Server.Punisher"
        },
        Function = function(self, hPlayer, hTarget, sDuration, sReason)
            return self:Command_MutePlayer(hPlayer, hTarget, sDuration, sReason)
        end
    },

    -- ================================================================
    -- !UnMute <Player> <Reason>
    {
        Name = "UnMute",
        Access = ServerAccess_Admin,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Required = true, Type = CommandArg_TypePlayer, NotSelf = false },
            { Name = "@reason", Desc = "@reason_desc", Default = "@admin_decision", Type = CommandArg_TypeMessage },
        },
        Properties = {
            This = "Server.Punisher"
        },
        Function = function(self, hPlayer, hTarget, sReason)
            return self:Command_UnMutePlayer(hPlayer, hTarget, sReason)
        end
    },

})