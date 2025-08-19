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
    -- !Firework
    {
        Name = "BigFirework",
        Access = ServerAccess_Premium,
        Arguments = {
        },
        Properties = {
            CoolDown = 120,
        },
        Function = function(self)
            for i = 0, 3 do
                Script.SetTimer(i * 300, function()
                    Server.Utils:SpawnEffect(Effect_Firework, self:GetPos())
                end)
            end
        end
    },

    -- ===============================================================================
    -- !NanoGirl
    {
        Name = "NanoGirl",
        Access = ServerAccess_Lowest,
        Arguments = {
        },
        Properties = {
            This = "Server.ClientMod"
        },
        Function = function(self, hPlayer)
            return self:Command_RequestModel(hPlayer, self.PlayerModels.NanoGirl)
        end
    },

    -- ===============================================================================
    -- !ModelId
    {
        Name = "ModelId",
        Access = ServerAccess_Lowest,
        Arguments = {
            { Name = "@arg_number", "@arg_cmId_desc", Type = CommandArg_TypeNumber, Default = 1000, Required = true }
        },
        Properties = {
            This = "Server.ClientMod"
        },
        Function = function(self, hPlayer, iModel)
            return self:Command_RequestModel(hPlayer, iModel)
        end
    },
})