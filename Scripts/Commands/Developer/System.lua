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
    -- =================================================================
    -- !RELOAD
    {
        Name = "reload",
        Access = ServerAccess_Developer,
        Function = function(self)
            Server.Utils:ExecuteCommand("server_reloadScript", self)
        end
    },
    -- =================================================================
    -- !SvConsole <Target>
    {
        Name = "SvConsole",
        Access = ServerAccess_Developer,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Required = true, Default = "self", AcceptSelf = true, Type = CommandArg_TypePlayer },
        },
        Function = function(self, hTarget)

            local sStatus = "@enabled_on"
            if (hTarget.Info.ServerConsole) then
                hTarget.Info.ServerConsole = false
                sStatus = "@disabled_on"
            else
                hTarget.Info.ServerConsole = true
            end

            return CmdResp_RawMessage, self:LocalizeText("@serverConsole " .. sStatus, {{}, { Name = (self == hTarget and "@yourself" or hTarget:GetName()) }})
        end
    },
})