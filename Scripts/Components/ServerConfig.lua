-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- This is the Server Configuration Handler
-- ===================================================================================

Server:CreateComponent({
    Name = "Config",
    Body = {

        ExternalData = {
            { Name = "%.lua$", Path = (SERVER_DIR_CONFIG .. "ServerConfig\\"), Recursive = true, ReadOnly = true }
        },

        ConfigurationList = {},
        ActiveConfiguration = nil,

        EarlyInitialize = function(self)
        end,

        Initialize = function(self)
        end,

        PostInitialize = function(self)
        end,

        Get = function(self, sValue, hDefault, iType)
            local hValue = LuaUtils.CheckGlobal("Server.Config.ActiveConfiguration.Body." .. sValue, hDefault)

            iType = (iType or ConfigType_Any)
            if (iType == eConfigGet_Any) then
                if (hValue ~= nil) then
                    return hValue
                end
                return hDefault

            elseif (iType == ConfigType_Array) then
                if (not IsArray(hValue)) then
                    return hDefault
                end

            elseif (iType == ConfigType_Number) then
                if (not IsNumber(hValue)) then
                    return hDefault
                end

            elseif (iType == ConfigType_String) then
                if (not IsString(hValue)) then
                    return hDefault
                end

            elseif (iType == ConfigType_Boolean) then
                if (not IsBool(hValue)) then
                    return hDefault
                end
            end

            return hValue
        end,

        Activate = function(self, sName)
            local tConfig = self:GetConfig(sName)
            self.ActiveConfiguration = {
                Name = tConfig.Name,
                Body = tConfig.Body
            }
            self:Log("Activated Config '%s'", sName)
        end,

        GetConfig = function(self, sName)
            return self.ConfigurationList[sName:lower()]
        end,

        Create = function(self, tConfig)

            local sName = tConfig.Name
            local aBody = tConfig.Body

            local bStatus = (tConfig.Active or tConfig.Status)
            if (not bStatus or bStatus == 0) then
                bStatus = false
            else
                bStatus = true
            end

            local sNameLower = sName:lower()
            if (self:GetConfig(sNameLower)) then
                self:LogError("Attempt to create new Configuration with existing Name '%s'", sName)
                return
            end

            self.ConfigurationList[sNameLower] = {
                Status = bStatus,
                Body = aBody
            }

            self:Log("Created new Configuration with Name '%s' (Enabled: %s)", sName, (bStatus and "Yes" or "No"))
            if (bStatus) then
                self:Activate(sName)
            end
        end

    }
})