-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
--             This file Contains the Server UAL (User Access Level) Handler
-- ===================================================================================

Server:CreateComponent({
    Name = "AccessHandler",
    FriendlyName = "Users",

    Body = {

        ExternalData = {
            { Key = "SavedUsers", Name = "SavedUsers.lua", Path = SERVER_DIR_DATA }
        },

        Protected = {
            SavedUsers = {}
        },

        AccessLevelMap = {},

        Properties = {

            KickInvalidProfiles = false,
            BanInvalidProfiles = false,

            -- Will automatically apply an IP-Based profile if the validation failed or the user is using a legacy client
            ApplyIPProfiles = true,

            -- The list of different User Access levels
            UserAccessLevels = {
                {
                    Name = "Guest", Level = 0, Color = CRY_COLOR_GREEN, Default = true
                },
                {
                    Name = "Player", Level = 2, Color = CRY_COLOR_GREEN,
                },
                {
                    Name = "Premium", Level = 3, Color = CRY_COLOR_BLUE, Premium = true
                },
                {
                    Name = "Moderator", Level = 4, Color = CRY_COLOR_ORANGE, Moderator = true
                },
                {
                    Name = "Administrator", Level = 5, Color = CRY_COLOR_RED, Admin = true
                },
                {
                    Name = "Super-Admin", Level = 6, Color = CRY_COLOR_WHITE
                },
                {
                    Name = "Developer", Level = 7, Color = CRY_COLOR_MAGENTA, Developer = true
                },
                {
                    Name = "Owner", Level = 9, Color = CRY_COLOR_YELLOW
                },
            }
        },

        Initialize = function(self)
            self:BuildAccessInfo()
        end,

        PostInitialize = function(self)

            local iLoadedUsers = table.size(self.SavedUsers)
            self:LogEvent({
                Event = self:GetName(),
                Recipients = self:GetAdministrators(),
                Message = [[@users_loaded]],
                MessageFormat = { Count = iLoadedUsers },
            })
        end,

        OnValidationFinished = function(self, hPlayer)
            Server.Chat:SendWelcomeMessage(hPlayer)
        end,

        OnValidationFailed = function(self, hPlayer)

            if (self.Properties.KickInvalidProfiles) then
                Server.Security:KickPlayer(Server:GetEntity(), hPlayer, "Profile Validation Failed")

            elseif (self.Properties.BanInvalidProfiles) then
                Server.Security:BanPlayer(Server:GetEntity(), hPlayer, { Duration = FIVE_MINUTES, Reason = "Profile Validation Failed" })

            elseif (self.Properties.ApplyIPProfiles) then
                local sIPAddress = hPlayer:GetIPAddress()
                local iIPDecimal = string.ip2dec(sIPAddress)
                local sIPProfile = ("i%d"):format(iIPDecimal)

                self:LogEvent({ Event = self:GetName(), Recipients = self:GetAdministrators(), Message = [[@user_ipIdAssigned]], MessageFormat = { ID = sIPProfile, UserName = hPlayer:GetName() }, })

                hPlayer:SetProfileValidated(true)
                hPlayer:SetProfileId(sIPProfile)
                self:OnValidationFinished(hPlayer)
            end
        end,

        OnProfileValidated = function(self, hPlayer, sProfileId)

            local sPlayerName = hPlayer:GetName()
            local aUserInfo = self:GetRegisteredUser(sProfileId)
            if (aUserInfo) then
                local aAccessInfo = self:GetAccessInfo(aUserInfo.AccessLevel)
                self:LogEvent({ Event = self:GetName(), Recipients = self:GetAdministrators(), Message = [[@user_restored]], MessageFormat = { AccessName = aAccessInfo:GetName(), AccessColor = aAccessInfo:GetColor(), UserName = sPlayerName }, })
                hPlayer:SetAccess(aUserInfo.AccessLevel)
            else
                local aDefaultAccessInfo = self:GetAccessInfo(self:GetDefaultAccess())
                hPlayer:SetAccess(aDefaultAccessInfo.Level)
                self:LogEvent({ Event = self:GetName(), Recipients = self:GetAdministrators(), Message = [[@user_accessAssigned]], MessageFormat = { AccessName = aDefaultAccessInfo:GetName(), AccessColor = aDefaultAccessInfo:GetColor(), UserName = sPlayerName }, })
            end

            hPlayer:SetProfileValidated(true)
            hPlayer:SetProfileId(sProfileId)

            self:LogEvent({
                Event = self:GetName(),
                Recipients = self:GetAdministrators(),
                Message = [[@user_validated]],
                MessageFormat = { ProfileId = sProfileId, Name = sPlayerName },
            })
            self:OnValidationFinished(hPlayer)
        end,

        -- ===================================================================================

        FindAccessByNameOrId = function(self, hId)

            local hFound
            local hIdLower = string.lower(hId)
            local hIdNumber = (tonumber(hId) or -1)

            for _, aInfo in pairs(self.AccessLevelMap) do
                local sLowerId = string.lower(aInfo.ID)
                local sLowerName = string.lower(aInfo.Name)
                if (sLowerId == hIdLower or sLowerName == hIdLower or aInfo.Level == hIdNumber) then
                    hFound = aInfo
                    break -- stop on complete matches
                elseif (string.match(sLowerId, "^" .. string.escape(hIdLower)) or string.match(sLowerName, "^" .. string.escape(hIdLower))) then
                    if (hFound) then
                        hFound = nil
                        break
                    end
                    hFound = aInfo
                end
            end

            return hFound
        end,

        -- ===================================================================================

        GetAdministrators = function(self)
            return self:GetAdmins()
        end,

        GetAdmins = function(self)
            return Server.Utils:GetPlayers({ ByAccess = self.AdministratorAccessLevel })
        end,

        GetDevelopers = function(self)
            return Server.Utils:GetPlayers({ ByAccess = self.DefaultAccessLevel })
        end,

        GetOwners = function(self)
            return Server.Utils:GetPlayers({ ByAccess = self.HighestAccessLevel })
        end,

        -- ===================================================================================

        IsAdministrator = function(self, iAccessLevel)
            return (iAccessLevel >= self:GetAdminLevel())
        end,

        IsPremium = function(self, iAccessLevel)
            return (iAccessLevel >= self:GetPremiumLevel())
        end,

        IsDeveloper = function(self, iAccessLevel)
            return (iAccessLevel >= self:GetDeveloperLevel())
        end,

        IsOwner = function(self, iAccessLevel)
            return (iAccessLevel >= self:GetHighestAccess())
        end,

        -- ===================================================================================

        GetRegisteredUser = function(self, sProfileId)
            return self.SavedUsers[sProfileId]
        end,

        GetAccessName = function(self, iAccessLevel)
            local aInfo = self:GetAccessInfo(iAccessLevel)
            if (not aInfo) then
                return
            end

            return aInfo:GetName()
        end,

        GetAccessColor = function(self, iAccessLevel)
            local aInfo = self:GetAccessInfo(iAccessLevel)
            if (not aInfo) then
                return
            end

            return aInfo:GetColor()
        end,

        GetDefaultAccess = function(self)
            return self.DefaultAccessLevel
        end,

        GetLowestAccess = function(self)
            return self.LowestAccessLevel
        end,

        GetHighestAccess = function(self)
            return self.HighestAccessLevel
        end,

        GetDeveloperLevel = function(self)
            return self.DeveloperAccessLevel
        end,

        GetAdminLevel = function(self)
            return self.AdministratorAccessLevel
        end,

        GetPremiumLevel = function(self)
            return self.PremiumAccessLevel
        end,

        GetAccessInfo = function(self, iAccessLevel)
            local aInfo = self.AccessLevelMap[iAccessLevel]
            return aInfo
        end,

        BuildAccessInfo = function(self)
            local aAccessList = self.Properties.UserAccessLevels
            for _, aInfo in pairs(aAccessList) do
                self.AccessLevelMap[aInfo.Level] = {

                    Level       = aInfo.Level,
                    Name        = aInfo.Name,
                    Color       = aInfo.Color,
                    Premium     = aInfo.Premium,
                    Admin       = aInfo.Admin,
                    Developer   = aInfo.Developer,
                    Default     = aInfo.Default,
                    Highest     = false,
                    Lowest      = false,

                    GetName     = function(this)
                        return this.Name
                    end,
                    GetColor    = function(this)
                        return this.Color
                    end,
                }

                _G[("ServerAccess_%s"):format(aInfo.Name)] = aInfo.Level
                _G[("ServerAccess_%s"):format(aInfo.Name:lower())] = aInfo.Level
                _G[("ServerAccess_%s"):format(aInfo.Name:upper())] = aInfo.Level
            end

            for iLevel, aInfo in pairs(self.AccessLevelMap) do
                local bIsHighest = true
                local bIsLowest = true
                for _iLevel in pairs(self.AccessLevelMap) do
                    if (_iLevel > iLevel) then
                        bIsHighest = false
                    end
                    if (_iLevel < iLevel) then
                        bIsLowest = false
                    end
                end

                if (aInfo.Default) then
                    self.DefaultAccessLevel = iLevel
                end
                if (aInfo.Developer) then
                    self.DeveloperAccessLevel = iLevel
                end
                if (aInfo.Admin) then
                    self.AdministratorAccessLevel = iLevel
                end
                if (aInfo.Premium) then
                    self.PremiumAccessLevel = iLevel
                end

                if (bIsHighest) then
                    self.HighestAccessLevel = iLevel
                end
                if (bIsLowest) then
                    self.LowestAccessLevel = iLevel
                end

                aInfo.Lowest = bIsLowest
                aInfo.Highest = bIsHighest
            end

        end,



    }
})