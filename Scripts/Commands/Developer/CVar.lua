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
    -- !SetCVar <CVar> <Value>
    {
        Name = "SetCVar",
        Access = ServerAccess_Developer,
        Arguments = {
            { Name = "CVar", Desc = "@arg_cvar_desc", Required = true, Type = CommandArg_TypeCVar},
            { Name = "@value",Desc = "@arg_value_desc", Required = true,  },
        },
        Properties = {
        },
        Function = function(self, sCVar, sValue)

            local aForbidden = {
                "sys_crashtest",
                "sv_password"
            }

            if (not self:HasAccess(ServerAccess_Highest)) then
                if (table.find_Value(aForbidden, sCVar:lower())) then
                    return false, "@insufficientaccess"
                end
            end

            if (sValue:lower() == "default") then
                local hDefault = Server.Utils:GetCVarDefault(sCVar)
                if (hDefault == nil) then
                    return false, "@no_default_value_found"
                end
                sValue = hDefault
                Server.Utils:SetCVar(sCVar, sValue, self)
                return true, self:LocalizeText("@cvar_setRestored", { CVar = sCVar, Value = sValue })
            end

            local bCache = true
            Server.Utils:SetCVar(sCVar, sValue, self, bCache)
            return true, self:LocalizeText("@cvar_setTo_chat", { CVar = sCVar, Value = sValue })
        end
    },
})