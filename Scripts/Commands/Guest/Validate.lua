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
    -- ======================================================================================
    -- !Validate <ID> <Hash> <Name>
    {
        Name = "validate",
        Access = ServerAccess_Lowest,
        Arguments = {
            { Name = "@arg_profileId", Required = true, Type = CommandArg_TypeNumber },
            { Name = "@arg_hash", Required = true },
            { Name = "@arg_name", Required = true }
        },
        Properties = {
            Hidden = true,
            IsQuiet = true
        },
        Function = function(self, iProfileId, sHash, sName)
            if (Server.Network:ValidateProfile(self, iProfileId, sHash, sName)) then
                return true
            end
            return false
        end
    },
    -- ======================================================================================
    -- !HereIsMyID <Check> <ID>
    {
        Name = "HereIsMyID",
        Access = ServerAccess_Lowest,
        Arguments = {
        },
        Properties = {
            Hidden = true,
            IsQuiet = true
        },
        Function = function(self, sSupposedID)
            return Server.Network:ValidateHardwareId(self, sSupposedID)
        end
    },
})