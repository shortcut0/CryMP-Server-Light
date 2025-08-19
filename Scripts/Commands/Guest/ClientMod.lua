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
    -- ===============================================================================
    -- !ClError <StackId> <Description>
    {
        Name = "ClError",
        Access = ServerAccess_Lowest,
        Arguments = {
            { Name = "id", Required = true, Type = CommandArg_TypeNumber },
            { Name = "error", Required = true, Type = CommandArg_TypeMessage },
        },
        Properties = {
            Hidden = true,
            IsQuiet = true
        },
        Function = function(self, hId, sError)
            Server.ClientMod:OnRemoteError(self, hId, sError)
        end
    },

    -- ===============================================================================
    -- !Nomad
    {
        Name = "Nomad",
        Access = ServerAccess_Lowest,
        Arguments = {
        },
        Properties = {
            This = "Server.ClientMod"
        },
        Function = function(self, hPlayer)
           return self:Command_RequestModel(hPlayer, -1)
        end
    },

    -- ===============================================================================
    -- !Kyong
    {
        Name = "Kyong",
        Access = ServerAccess_Lowest,
        Arguments = {
        },
        Properties = {
            This = "Server.ClientMod"
        },
        Function = function(self, hPlayer)
           return self:Command_RequestModel(hPlayer, self.PlayerModels.Kyong)
        end
    },

    -- ===============================================================================
    -- !Prophet
    {
        Name = "Prophet",
        Access = ServerAccess_Lowest,
        Arguments = {
        },
        Properties = {
            This = "Server.ClientMod"
        },
        Function = function(self, hPlayer)
           return self:Command_RequestModel(hPlayer, self.PlayerModels.Prophet)
        end
    },

    -- ===============================================================================
    -- !Aztec
    {
        Name = "Aztec",
        Access = ServerAccess_Lowest,
        Arguments = {
        },
        Properties = {
            This = "Server.ClientMod"
        },
        Function = function(self, hPlayer)
           return self:Command_RequestModel(hPlayer, self.PlayerModels.Aztec)
        end
    },

    -- ===============================================================================
    -- !Psycho
    {
        Name = "Psycho",
        Access = ServerAccess_Lowest,
        Arguments = {
        },
        Properties = {
            This = "Server.ClientMod"
        },
        Function = function(self, hPlayer)
           return self:Command_RequestModel(hPlayer, self.PlayerModels.Psycho)
        end
    },

    -- ===============================================================================
    -- !Jester
    {
        Name = "Jester",
        Access = ServerAccess_Lowest,
        Arguments = {
        },
        Properties = {
            This = "Server.ClientMod"
        },
        Function = function(self, hPlayer)
           return self:Command_RequestModel(hPlayer, self.PlayerModels.Jester)
        end
    },

    -- ===============================================================================
    -- !Sykes
    {
        Name = "Sykes",
        Access = ServerAccess_Lowest,
        Arguments = {
        },
        Properties = {
            This = "Server.ClientMod"
        },
        Function = function(self, hPlayer)
           return self:Command_RequestModel(hPlayer, self.PlayerModels.Sykes)
        end
    },
})