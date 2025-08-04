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
    Name = "mmmm1",
    Arguments = {
    },
    Function = function()
        return true, "return"
    end
})

Server.ChatCommands:Add({
    Name = "mmmm2",
    Arguments = {
    },
    Properties = {
        This = "Server",
    },
    Function = function(this, hPlayer, x,y,z)
       return true
    end
})

Server.ChatCommands:Add({
    Name = "mmmm3",
    Arguments = {
    },
    Function = function()
        return false
    end
})

Server.ChatCommands:Add({
    Name = "mmmm4",
    Arguments = {
    },
    Function = function()
        return false, "error"
    end
})

Server.ChatCommands:Add({
    Name = "mmmm5",
    Arguments = {
    },
    Function = function()
        return nil
    end
})