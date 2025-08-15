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
    Name = "ClError",
    Access = ServerAccess_Lowest,
    Arguments = {
        { Name = "id", Required = true, Type = CommandArg_TypeNumber },
        { Name = "error", Required = true },
    },
    Properties = {
        Hidden = true,
        IsQuiet = true
    },
    Function = function(self, hId, sError)
        Server.ClientMod:OnError(self, hId, sError)
    end
})