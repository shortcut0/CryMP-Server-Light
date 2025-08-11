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
            self.Properties.ForbiddenSymbols     = Server.Config:Get("PlayerNames.ForbiddenSymbols", { "$", "@", "%", }, ConfigType_Array)

            self.Properties.NameTemplatePattern = string.gsub(string.Escape(self.Properties.NameTemplate), "{[^}]+}", ".*"):lower()
        end,

        PostInitialize = function(self)
        end,

        ValidateName = function(self, sName)

            local sReplaceChar = (self.Properties.ReplacementCharacter or "_")
            if (not self.Properties.AllowSpaces) then
                sName = string.gsub(sName, "%s", sReplaceChar)
            end
            for _, sForbiddenSymbol in pairs(self.Properties.ForbiddenSymbols) do
                sName = string.gsub(sName, string.Escape(sForbiddenSymbol), sReplaceChar)
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
            return Server.Logger:FormatTags(self.Properties.NameTemplate, (tFormat))
        end,

        Command_Rename = function(self, hPlayer, hTarget, sNewName, sReason)

            local iAccess = hPlayer:GetAccess()
            if (hTarget == ALL_PLAYERS) then
                local iRenamed = 0
                if (iAccess < ServerAccess_Developer) then
                    return false, hPlayer:LocalizeText("@insufficientAccess")
                end
                for _, hVictim in pairs(Server.Utils:GetPlayers()) do
                    local iTargetAccess = hVictim:GetAccess()
                    if (hVictim == hPlayer or iAccess > iTargetAccess) then
                        local sVictimName = ("%s (%d)"):format(sNewName, iRenamed)
                        -- looks like someone is trying to reset ALL names
                        if (sNewName:lower() == "nomad") then
                            sVictimName = "nomad"
                        end
                        if (self:Command_Name(hVictim, sVictimName, hPlayer:IsDeveloper(), (sReason or "@admin_decision"))) then
                            iRenamed = iRenamed + 1
                        end
                    end
                end
                return (iRenamed > 0), hPlayer:LocalizeText("@count_players_renamed", { Count = iRenamed })
            end

            local iTargetAccess = hTarget:GetAccess()
            if (iAccess <= iTargetAccess) then
                return false, hPlayer:LocalizeText("@insufficientAccess")
            end
            local bOk, sError = self:Command_Name(hTarget, sNewName, hPlayer:IsDeveloper(), (sReason or "@admin_decision"))
            if (not bOk) then
                return false, sError
            end

            return true
        end,

        Command_Name = function(self, hPlayer, sNewName, bAllowExtended, sReason)

            local sOldName = hPlayer:GetName()
            local sOldNameLower = sOldName:lower()
            local sNewNameLower = sNewName:lower()

            bAllowExtended = (bAllowExtended or hPlayer:IsDeveloper())

            if (sOldNameLower == sNewNameLower or string.empty(sNewName)) then
                return false, hPlayer:LocalizeText("@invalid_name")
            end

            if (sNewNameLower == "nomad") then
                local iChannel = hPlayer:GetChannel()
                sNewName = self:GetNameForNomad({ CountryCode = Server.Network:GetCountryCode(iChannel), Channel = ("%04d"):format(iChannel)})
                sNewNameLower = sNewName:lower()
            else
                sNewName = self:ValidateName(sNewName)
                sNewNameLower = sNewName:lower()

                local iNewNameLen = sNewName:len()
                if (not bAllowExtended) then
                    if (iNewNameLen > self.Properties.MaximumLength) then
                        return false, hPlayer:LocalizeText("@name @too_long")
                    end

                    if (iNewNameLen < self.Properties.MinimumLength) then
                        return false, hPlayer:LocalizeText("@name @too_short")
                    end

                    if (self:IsForbidden(sNewName)) then
                        return false, hPlayer:LocalizeText("@name @forbidden")
                    end

                    if (Server.AccessHandler:IsNameProtected(sNewName, hPlayer:GetProfileId())) then
                        return false, hPlayer:LocalizeText("@name @reserved")
                    end
                end
            end

            if (Server.Utils:GetPlayerByName(sNewName)) then
                return false, hPlayer:LocalizeText("@name_in_use")
            end

            Server.Utils:RenamePlayer(hPlayer, sNewName)
            self:LogEvent({
                Message = "@user_renamed",
                MessageFormat = { Reason = (sReason or "@user_decision"), OldName = sOldName, NewName = sNewName }
            })

            return true
        end,
    }
})