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

        ComponentPriority = PRIORITY_HIGHER,

        ExternalData = {
            { Key = "SavedUsers", Name = "SavedUsers.lua", Path = (SERVER_DIR_DATA .. "Users\\") },
            { Key = "IPProfiles", Name = "IPProfiles.lua", Path = (SERVER_DIR_DATA .. "Users\\") },
            { Key = "UniqueUserIDs", Name = "UniqueUserIDs.lua", Path = (SERVER_DIR_DATA .. "Users\\") },
        },

        Protected = {
            UniqueUserIDs = {
                Profiles = {},
                Next = 0,
            },
            SavedUsers = {},
            IPProfiles = {
                Next = 0,
            },
        },

        AccessLevelMap = {},
        Properties = {

            KickInvalidProfiles = false,
            BanInvalidProfiles = false,

            -- Will automatically apply an IP-Based profile if the validation failed or the user is using a legacy client
            ApplyIPProfiles = true,
            GrantHighestAccessToLocalUsers = true,

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
                    Name = "Admin", Level = 5, Color = CRY_COLOR_RED, Admin = true
                },
                {
                    Name = "SuperAdmin", Level = 6, Color = CRY_COLOR_WHITE
                },
                {
                    Name = "Developer", Level = 7, Color = CRY_COLOR_MAGENTA, Developer = true
                },
                {
                    Name = "Owner", Level = 9, Color = CRY_COLOR_YELLOW
                },
            },

            RegisteredUsers = {
                {
                    Name = "shortcut0",
                    AccessLevel = 9,
                    NameProtected = true,
                    ProfileID = "1073103"
                },
                {
                    Name = "shortcut0",
                    AccessLevel = 9,
                    NameProtected = true,
                    ProfileID = "127.0.0.1"
                },
            }
        },

        EarlyInitialize = function(self)
            self:BuildAccessInfo()
        end,

        Initialize = function(self)
            for _, aUserInfo in pairs(self.Properties.RegisteredUsers) do
                self.SavedUsers[aUserInfo.ProfileID] = aUserInfo
            end

            local iLoadedUsers = table.size(self.SavedUsers)
            self:LogEvent({
                Event = self:GetName(),
                Recipients = self:GetAdministrators(),
                Message = [[@users_loaded]],
                MessageFormat = { Count = iLoadedUsers },
            })
        end,

        PostInitialize = function(self)
        end,

        OnValidationFinished = function(self, hPlayer)

            Server.Chat:SendWelcomeMessage(hPlayer)
            Server.Network:SendMessage(hPlayer, "Connected")

            self:AssignUniqueID(hPlayer, self:GetUniqueID(hPlayer))
        end,

        AssignUniqueID = function(self, hPlayer, hId)
            hPlayer.Info.UniqueId = hId
            hPlayer.Info.UniqueName = self:GetUniqueName(hId)
            self:Log("Resolved Unique ID for User '%s' ID: %s, Name: %s", hPlayer:GetName(), hId, hPlayer.Info.UniqueName)
        end,

        GetUniqueName = function(self, hId)
            local tProfile = self:GetUniqueProfile(hId)
            if (not tProfile) then
                return "Nomad"
            end

            return tProfile.UniqueName or "Nomad"
        end,

        GetUniqueProfile = function(self, hId)
            for _, tProfile in pairs(self.UniqueUserIDs.Profiles) do
                if (tProfile.UniqueId == hId) then
                    return tProfile
                end
            end
            return
        end,

        GetUniqueID = function(self, hPlayer)
            local aIdentifiers = {
                hPlayer:GetProfileId(),
                hPlayer:GetHostName(),
                hPlayer:GetIPAddress(),
                hPlayer:GetHardwareId(),
            }

            local tUserProfile
            for _, sId in pairs(aIdentifiers) do
                for _, tProfile in pairs(self.UniqueUserIDs.Profiles) do
                    if (table.find_value(tProfile.Identifiers, sId)) then
                        tUserProfile = tProfile
                        break
                    end
                end
            end

            if (tUserProfile) then
                for _, sIdentifier in pairs(aIdentifiers) do
                    if (not table.find_value(tUserProfile.Identifiers, sIdentifier)) then
                        table.insert(tUserProfile.Identifiers, sIdentifier)
                        self:Log("Inserted new identifier '%s'", sIdentifier)
                    end
                end
                return tUserProfile.UniqueId
            end

            self.UniqueUserIDs.Next = (self.UniqueUserIDs.Next + 1)
            table.insert(self.UniqueUserIDs.Profiles, {
                UniqueName = hPlayer:GetName(),
                UniqueId = ("p%05d"):format(self.UniqueUserIDs.Next),
                Identifiers = table.copy(aIdentifiers),
            })

            return self.UniqueUserIDs.Profiles[#self.UniqueUserIDs.Profiles].UniqueId
        end,

        OnNoProfileReceived = function(self, hPlayer)
        end,

        OnValidationFailed = function(self, hPlayer)

            if (self.Properties.KickInvalidProfiles) then
                -- TODO
                Server.Security:KickPlayer(Server:GetEntity(), hPlayer, "Profile Validation Failed")

            elseif (self.Properties.BanInvalidProfiles) then
                -- TODO
                Server.Security:BanPlayer(Server:GetEntity(), hPlayer, { Duration = FIVE_MINUTES, Reason = "Profile Validation Failed" })

            else
                self:AssignIPProfile(hPlayer)
            end
        end,

        AssignIPProfile = function(self, hPlayer)
            if (self.Properties.ApplyIPProfiles) then

                local sIPAddress = hPlayer:GetIPAddress()
                local sIPProfile, sIPIndex = self:GetIPProfile(sIPAddress)

                hPlayer:SetProfileValidated(true)
                hPlayer:SetProfileId(sIPProfile)

                -- This is purely so that if the user if of higher access, they will be able to see this log as well.
                -- after all, i'm not thor!
                local function Log()
                    self:LogEvent({ Event = self:GetName(), Recipients = self:GetAdministrators(), Message = [[@user_ipIdAssigned]], MessageFormat = { ID = sIPProfile, UserName = hPlayer:GetName() }, })
                end

                local aUserInfo = (self:GetRegisteredUser(sIPProfile) or self:GetRegisteredUser(sIPIndex))
                if (aUserInfo) then

                    DebugLog("found them?",sIPProfile,sIPIndex)
                    hPlayer:SetAccess(aUserInfo.AccessLevel, { Quiet = true }) -- Quiet
                    Log()

                    local aAccessInfo = self:GetAccessInfo(aUserInfo.AccessLevel)
                    self:LogEvent({ Event = self:GetName(), Recipients = self:GetAdministrators(), Message = [[@user_restored]], MessageFormat = { AccessName = aAccessInfo:GetName(), AccessColor = aAccessInfo:GetColor(), UserName = hPlayer:GetName() }, })
                else
                    self:SetPlayerDefaultAccess(hPlayer)
                    Log()
                end

                -- restore any data associated with this ID
                Server.ActorHandler:OnProfileValidated(hPlayer, sIPProfile)
                hPlayer:SetValidationFailed(true)
                hPlayer:SetProfileReceived(true)
                self:OnValidationFinished(hPlayer)
            end
        end,

        OnProfileValidated = function(self, hPlayer, sProfileId)

            local sPlayerName = hPlayer:GetName()
            local aUserInfo = self:GetRegisteredUser(sProfileId)

            local function Log()
                self:LogEvent({
                    Event = self:GetName(),
                    Recipients = self:GetAdministrators(),
                    Message = [[@user_validated]],
                    MessageFormat = { ProfileId = sProfileId, UserName = sPlayerName },
                })
            end

            if (aUserInfo) then

                hPlayer:SetAccess(aUserInfo.AccessLevel, { Quiet = true }) -- Quiet
                Log()

                local aAccessInfo = self:GetAccessInfo(aUserInfo.AccessLevel)
                self:LogEvent({ Event = self:GetName(), Recipients = self:GetAdministrators(), Message = [[@user_restored]], MessageFormat = { AccessName = aAccessInfo:GetName(), AccessColor = aAccessInfo:GetColor(), UserName = sPlayerName }, })
            else
                self:SetPlayerDefaultAccess(hPlayer)
                Log()
                --self:LogEvent({ Event = self:GetName(), Recipients = self:GetAdministrators(), Message = [[@user_accessAssigned]], MessageFormat = { AccessName = aDefaultAccessInfo:GetName(), AccessColor = aDefaultAccessInfo:GetColor(), UserName = sPlayerName }, })
            end

            hPlayer:SetProfileValidated(true)
            hPlayer:SetProfileId(sProfileId)
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

        GetIPProfile = function(self, sIPAddress)
            local iIPDecimal = string.ip2dec(sIPAddress)
            local sIPProfile = self.IPProfiles[iIPDecimal]
            if (sIPProfile == nil) then
                sIPProfile = ("ip%d"):format(self.IPProfiles["Next"] or 1)
                self.IPProfiles["Next"] = (self.IPProfiles["Next"] or 0) + 1
                self.IPProfiles[iIPDecimal] = sIPProfile
                self:Log("Inserted new IP-Profile %s on Index %d", sIPProfile, self.IPProfiles["Next"])
            else
                self:Log("IP-Profile %s for IP %s already generated", sIPProfile, sIPAddress)
            end
            return sIPProfile, iIPDecimal
        end,

        GetEmptyUser = function(self)
            return {
                Name = "Nomad",
                Level = self:GetLowestAccess(),
                ProfileID = "-1",
                NameProtected = false,
            }
        end,

        GetRegisteredUser = function(self, sProfileId)
            return self.SavedUsers[sProfileId]
        end,

        DeleteRegisteredUser = function(self, sProfileId, sAdmin)
            local aUserInfo = self.SavedUsers[sProfileId]
            if (not aUserInfo) then
                return false
            end

            sAdmin = (sAdmin or "Server")
            self:LogEvent({
                Event = self:GetFriendlyName(),
                Message = "@user_deleted",
                MessageFormat = { UserName = aUserInfo.Name, ProfileID = sProfileId, AdminName = sAdmin }
            })

            self.SavedUsers[sProfileId] = nil
        end,

        AddRegisteredUser = function(self, sUserName, sProfileId, iAccessLevel, sAdmin)

            local aUserInfo = (self.SavedUsers[sProfileId] or self:GetEmptyUser())

            aUserInfo.ProfileID     = sProfileId
            aUserInfo.Name          = sUserName
            aUserInfo.NameProtected = (iAccessLevel >= self:GetAdminLevel())

            local sAccessColor = self:GetAccessColor(iAccessLevel)
            local sAccessName = self:GetAccessName(iAccessLevel)

            sAdmin = (sAdmin or "Server")
            self:LogEvent({
                Event = self:GetFriendlyName(),
                Message = "@user_registered",
                MessageFormat = { AccessName = sAccessName, AccessColor = sAccessColor, UserName = sUserName, ProfileID = sProfileId, AdminName = sAdmin }
            })

            self.SavedUsers[sProfileId] = aUserInfo
        end,

        SetPlayerDefaultAccess = function(self, hPlayer)
            local iDefaultLevel = self:GetDefaultAccess()
            local bIsLocal = ServerDLL.IsChannelLocal(hPlayer:GetChannel())
            if (bIsLocal) then
                bIsLocal = nil
                if (self.Properties.GrantHighestAccessToLocalUsers) then
                    iDefaultLevel = self:GetHighestAccess()
                    bIsLocal = "@str_local"
                end
            end
            hPlayer:SetAccess(iDefaultLevel, { Local = bIsLocal })
        end,

        SetUserAccess = function(self, hUser, hAdmin, iAccessLevel, bForceTemporary)

            hAdmin = (hAdmin or Server:GetEntity())
            local sProfileId = hUser:GetProfileId()
            local bTemporary = (bForceTemporary or not hUser:IsValidated())
            local iUserAccess = hUser:GetAccess()
            local iAdminAccess = hAdmin:GetAccess()
            local bEqualAccess = (iUserAccess == iAccessLevel)

            -- Only allow the admin to promote to their own level, but only if the user has lesser access!
            if (bEqualAccess or iAccessLevel > iAdminAccess) then
                if (hAdmin.IsPlayer) then
                    -- "@insufficientAccess"
                    -- TODO: chat msg, from USERS entity
                    DebugLog("insufficient access BRO")
                end
                return false
            end

            if (iUserAccess == iAccessLevel) then
                if (hAdmin.IsPlayer) then
                    -- "@alreadyAccess"
                    -- TODO: chat msg, from USERS entity
                    DebugLog("user is already this level")
                end
                return false
            end

            if (iAccessLevel == self:GetDefaultAccess()) then
                if (not bTemporary) then
                    self:DeleteRegisteredUser(sProfileId, hAdmin:GetName())
                end
                if (hAdmin.IsPlayer) then
                    -- @user_deletedChat
                    -- TODO: chat msg, from USERS entity
                    DebugLog("user demoted")
                end
                self:AssignAccess(hUser, iAccessLevel)
                return true
            end

            if (not bTemporary) then
                self:AddRegisteredUser(sProfileId, iAccessLevel, hAdmin:GetName())
            end
            self:AssignAccess(hUser, iAccessLevel, { Temporary = (bTemporary and "@str_temporarily") })
            if (hAdmin.IsPlayer) then
                -- TODO: chat msg, from USERS entity
            end
            return true
        end,

        AssignAccess = function(self, hUser, iAccessLevel, tInfo)

            tInfo = (tInfo or {})
            local sTemporary = (string.emptyN(tInfo.Temporary) and tInfo.Temporary .. " " or "")
            local sLocalUser = (string.emptyN(tInfo.Local) and tInfo.Local .. " " or "")
            local bQuiet = tInfo.Quiet

            local sAccessColor = self:GetAccessColor(iAccessLevel)
            local sAccessName = self:GetAccessName(iAccessLevel)

            hUser.Info.Access = iAccessLevel

            if (not bQuiet) then
                self:LogEvent({
                    Message = "@user_accessAssigned",
                    MessageFormat = { Local = sLocalUser, Temporary = sTemporary, UserName = hUser:GetName(), AccessColor = sAccessColor, AccessName = sAccessName },
                    Recipients = self:GetAdmins()
                })
            end
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

                -- ServerAccess_Admin
                -- ServerAccess_GetAdmins()
                _G[("ServerAccess_%s"):format(aInfo.Name)] = aInfo.Level
                _G[("ServerAccess_Get%ss"):format(aInfo.Name)] = function()
                    return Server.Utils:GetPlayers({ ByAccess = aInfo.Level })
                end
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

            ServerAccess_Lowest = self.LowestAccessLevel
            ServerAccess_Highest = self.HighestAccessLevel
        end,



    }
})