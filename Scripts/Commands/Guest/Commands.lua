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

    Name        = "commands",
    Access      = ServerRank_Guest,
    Description = "command_commands",

    Arguments = {
        { Name = "@arg_filter", Desc = "@arg_filter_desc" },
    },

    Properties = {
        This = Server.ChatCommands
    },

    Function = function(self, hPlayer, sClass)
        self:ListCommands(hPlayer, self.CommandMap, sClass)
        return true
    end
})