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
    -- !HardBan <Player> <Duration> <Reason>
    {
        Name = "HardBan",
        Access = ServerAccess_SuperAdmin,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Required = true, Type = CommandArg_TypePlayer, NotSelf = true },
            { Name = "@time",   Desc = "@arg_time_desc",   Required = true, Type = CommandArg_TypeTime, AcceptInvalidTime = true },
            { Name = "@reason", Desc = "@reason_desc", Default = "@admin_decision", Type = CommandArg_TypeMessage },
        },
        Properties = {
            This = "Server.Punisher"
        },
        Function = function(self, hPlayer, hTarget, sDuration, sReason)
            return self:Command_BanPlayer(hPlayer, hTarget, sDuration, sReason, true)
        end
    },

    -- ================================================================
    -- !UniqueUsers <Filter>
    {
        Name = "UniqueUsers",
        Access = ServerAccess_SuperAdmin,
        Arguments = {
            { Name = "@filter", Desc = "@arg_filter_desc", Type = CommandArg_TypeMessage }
        },
        Properties = {
            This = "Server.AccessHandler"
        },
        Function = function(self, hPlayer, sFilter)
            return self:Command_UniqueListUsers(hPlayer, sFilter)
        end
    },

    -- ================================================================
    -- !SetUniqueName <Player> <Name>
    {
        Name = "SetUniqueName",
        Access = ServerAccess_SuperAdmin,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Required = true, Type = CommandArg_TypePlayer },
            { Name = "@name", Desc = "@arg_name_desc", Required = true, Type = CommandArg_TypeMessage }
        },
        Properties = {
            This = "Server.AccessHandler"
        },
        Function = function(self, hPlayer, hTarget, sName)
            if (not hPlayer:HasAccess(math.min(ServerAccess_Highest, hTarget:GetAccess() + 1))) then
                return false, "@insufficientAccess"
            end
            return self:Command_SetUniqueName(hPlayer, hTarget, sName)
        end
    },
})

--Command_UniqueListUsers