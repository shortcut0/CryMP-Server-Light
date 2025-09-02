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
    {
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
        Function = function(THIS, ...)

            Server.Chat:SendWelcomeMessage(THIS)
            return true, "return"
        end
    },
    -- ==========================================================================================
    -- !TestMode <Target>
    {
        Name = "TestMode",
        Access = ServerAccess_Developer,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Required = true, Default = "self", AcceptSelf = true, Type = CommandArg_TypePlayer },
        },
        Function = function(self, hTarget)

            local sStatus = "@enabled_on"
            if (hTarget.Info.IsInTestMode) then
                hTarget.Info.IsInTestMode = false
                sStatus = "@disabled_on"
            else
                hTarget.Info.IsInTestMode = true
            end

            return CmdResp_RawMessage, self:LocalizeText("@developerMode " .. sStatus, {{}, { Name = (self == hTarget and "@yourself" or hTarget:GetName()) }})
        end
    }
})