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
    Name = "NextMap",
    Access = ServerAccess_Guest,
    Arguments = {
        { Name = "@arg_time/@arg_stop", Desc = "@arg_time_desc/@arg_stop_desc" }
    },
    Properties = {
        This = "Server.MapRotation"
    },
    Function = function(self, hPlayer, hOption)
        if (hOption == "show" or not hPlayer:HasAccess(ServerAccess_Moderator)) then
            return true, hPlayer:LocalizeText("@next_map", { Name = self:GetNextMapName() })
        end
        return self:Command_NextMap(hOption, hPlayer)
    end
})