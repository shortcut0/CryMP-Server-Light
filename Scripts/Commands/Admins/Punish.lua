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
    -- !Ban <Player> <Duration> <Reason>
    {
        Name = "Ban",
        Access = ServerAccess_Admin,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Required = true, Type = CommandArg_TypePlayer, NotSelf = true },
            { Name = "@time",   Desc = "@arg_time_desc",   Required = true, Type = CommandArg_TypeTime, AcceptInvalidTime = true },
            { Name = "@reason", Desc = "@reason_desc", Default = "@admin_decision", Type = CommandArg_TypeMessage },
        },
        Properties = {
            This = "Server.Punisher"
        },
        Function = function(self, hPlayer, hTarget, sDuration, sReason)
            return self:Command_BanPlayer(hPlayer, hTarget, sDuration, sReason)
        end
    },
    -- ================================================================
    -- !UnBan <Identifier> <Reason>
    {
        Name = "UnBan",
        Access = ServerAccess_Admin,
        Arguments = {
            { Name = "@Identifier", Desc = "@arg_Identifier_desc", Required = true },
            { Name = "@reason", Desc = "@reason_desc", Default = "@admin_decision", Type = CommandArg_TypeMessage },
        },
        Properties = {
            This = "Server.Punisher"
        },
        Function = function(self, hPlayer, sIdentifier, sReason)
            return self:Command_UnBanPlayer(hPlayer, sIdentifier, sReason)
        end
    },

    -- ================================================================
    -- !BanList <Index> <Action>
    {
        Name = "BanList",
        Access = ServerAccess_Admin,
        Arguments = {
            { Name = "@index", Desc = "@arg_banIndex_desc", },
            { Name = "@action",     Desc = "@arg_banAction_desc",         },
        },
        Properties = {
            This = "Server.Punisher"
        },
        Function = function(self, hPlayer, sIndex, sAction)
            return self:Command_ListBans(hPlayer, sIndex, sAction)
        end
    },

    -- ================================================================
    -- !BanInfo <Index> <Action>
    {
        Name = "BanInfo",
        Access = ServerAccess_Admin,
        Arguments = {
            { Name = "@index", Desc = "@arg_banIndex_desc", },
            { Name = "@action",     Desc = "@arg_banAction_desc",         },
        },
        Properties = {
            This = "Server.Punisher"
        },
        Function = function(self, hPlayer, sIndex, sAction)
            return self:Command_IndexBan(hPlayer, sIndex, sAction)
        end
    },

    -- ================================================================
    -- !KickChannel <ChannelId> <Reason>
    {
        Name = "KickChannel",
        Access = ServerAccess_Admin,
        Arguments = {
            { Name = "@channel", Desc = "@arg_channel_desc", Required = true, Type = CommandArg_TypeNumber },
            { Name = "@reason", Desc = "@reason_desc", Default = "@admin_decision", Type = CommandArg_TypeMessage },
        },
        Properties = {
            This = "Server.Punisher"
        },
        Function = function(self, hPlayer, iChannel, sReason)
            return self:Command_KickChannel(hPlayer, iChannel, sReason)
        end
    },
})