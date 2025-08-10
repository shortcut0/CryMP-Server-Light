-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- This file contains the Server Name handler Component
-- ===================================================================================

Server:CreateComponent({
    Name = "NameHandler",
    FriendlyName = "Names",
    Body = {

        Properties = {
        },

        Initialize = function(self)

            self.Properties.NameTemplate         = Server.Config:Get("PlayerNames.DefaultNameTemplate", "Nomad.{CountryCode} (#{Channel})", ConfigType_String)
            self.Properties.ReplacementCharacter = Server.Config:Get("PlayerNames.ReplacementCharacter", "_", ConfigType_String)
            self.Properties.MinimumLength        = Server.Config:Get("PlayerNames.MinimumLength", 3, ConfigType_Number)
            self.Properties.MaximumLength        = Server.Config:Get("PlayerNames.MaximumLength", 3, ConfigType_Number)
            self.Properties.AllowSpaces          = Server.Config:Get("PlayerNames.AllowSpaces", true, ConfigType_Boolean)
            self.Properties.ForbiddenNames       = Server.Config:Get("PlayerNames.ForbiddenNames", { "Nomad" }, ConfigType_Array)
            self.Properties.ForbiddenSymbols     = Server.Config:Get("PlayerNames.ForbiddenSymbols", { "$", "@", "%%", }, ConfigType_Array)

            self.Properties.NameTemplatePattern = string.gsub(string.Escape(self.Properties.NameTemplate), "{[^}]+}", ".*"):lower()
        end,

        PostInitialize = function(self)
        end,

        ValidateName = function(self, sName)

            local sReplaceChar = (self.Properties.ReplacementCharacter or "_")
            if (not self.Properties.AllowSpaces) then
                sName = string.gsub(sName, " ", sReplaceChar)
            end
            for _, sForbiddenSymbol in pairs(self.Properties.ForbiddenSymbols) do
                sName = string.gsub(sName, sForbiddenSymbol, sReplaceChar)
            end

            return sName
        end,

        CheckChannelNick = function(self, iChannel)
            local sCountryCode = Server.Network:GetCountryCode(iChannel)
            local sCountryName = Server.Network:GetCountryName(iChannel)

            local sFixedName
            local sNickName = ServerDLL.GetChannelNick(iChannel)
            if (self:IsNomad(sNickName)) then
                sFixedName = self:GetNameForNomad({ CountryCode = sCountryCode, Channel = ("%04d"):format(iChannel)})
            end

            if (sNickName ~= sFixedName) then
                ServerDLL.SetChannelNick(iChannel, sFixedName)
            end
        end,

        IsForbidden = function(self, sName)
            local sNameLower = sName:lower()
            if (table.find_value(self.Properties.ForbiddenNames, sNameLower, function(a, b) return (a:lower() == b:lower())  end)) then
                return true
            end
        end,

        IsNomad = function(self, sName)
            if (not sName) then
                return false
            end
            return (sName:lower() == "nomad")
        end,

        IsNomadOrTemplate = function(self, sName)
            if (self:IsNomad(sName)) then
                return true
            end
            return string.match(sName:lower(), self.Properties.NameTemplatePattern)
        end,

        GetNameForNomad = function(self, tFormat)
            return Server.Logger:FormatTags(self.Properties.NameTemplate, tFormat)
        end,
    }
})