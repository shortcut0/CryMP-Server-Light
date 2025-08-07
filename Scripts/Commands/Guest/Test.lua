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
    Access = ServerAccess_Highest,
    Arguments = {
        { Required = nil, Type = CommandArg_TypePlayer, Name = "Hello?", Desc = "Bye!",

          Minimum = 1000,
          Maximum = 9999999,
          ForceLimit = false,

        },
       -- { Required = 1, Type = CommandArg_TypeMessage, Name = "Hello?", Desc = "Bye!", },
       -- { Required = 1, Type = CommandArg_TypeBoolean, Name = "Hello?", Desc = "Bye!", },
       -- { Required = 1, Type = CommandArg_TypePlayer, Name = "Hello?", Desc = "Bye!", },
     --   { Required = 1, Type = CommandArg_TypeString, Name = "Hello?", Desc = "Bye!", },
      --  { Required = 1, Type = CommandArg_TypeNumber, Name = "Hello?", Desc = "Bye!", },
    },
    Function = function(THIS,...)

        Server.Chat:SendWelcomeMessage(THIS)
        return true, "return"
    end
})

Server.ChatCommands:Add({
    Name = "mmmm2",
    Access = ServerAccess_Highest,
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
    Access = ServerAccess_Highest,
    Arguments = {
    },
    Function = function()
        return false
    end
})

Server.ChatCommands:Add({
    Name = "mmmm4",
    Access = ServerAccess_Highest,
    Arguments = {
    },
    Function = function()
        return false, "error"
    end
})

Server.ChatCommands:Add({
    Name = "mmmm5",
    Access = ServerAccess_Highest,
    Arguments = {
    },
    Function = function()
        return nil
    end
})