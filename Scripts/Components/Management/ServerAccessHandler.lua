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
                    Name = "Guest", Level = 1, Color = CRY_COLOR_GREEN, Default = true
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
                    Name = "Owner", Level = 8, Color = CRY_COLOR_YELLOW
                },
            },

            RegisteredUsers = {
                --[[
                {
                    Name = "shortcut0",
                    AccessLevel = 9,
                    NameProtected = true,
                    ProfileID = "1073103" -- someone keep this thing static please
                }
                ]]
                {
                    Name = "shortcut0",
                    AccessLevel = 9,
                    NameProtected = true,
                    ProfileID = "1073450" -- someone keep this thing static please
                }
            },

            -- The offset for ip-profiles
            IPProfileOffset = 10000,

            -- The offset for unique user ids
            UniqueIDOffset = 100000,
        },

        EarlyInitialize = function(self)
            self:BuildAccessInfo()
        end,

        Initialize = function(self)
            for _, aUserInfo in pairs(self.Properties.RegisteredUsers) do
                self.SavedUsers[aUserInfo.ProfileID] = aUserInfo
                self.SavedUsers[aUserInfo.ProfileID].IsHardcoded = true
            end

            self:ValidateUsers()

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

        ValidateUsers = function(self)
            for _, tUser in pairs(self.SavedUsers or {}) do

                if (not tUser.Name) then
                    self:LogError("No Name specified for User on ID %s", tostring(tUser.ProfileID))
                    tUser.Name = ("%s #%s"):format("User", tostring(tUser.ProfileID))
                end

                local iLevel = tUser.AccessLevel
                if (not iLevel or iLevel < self:GetLowestAccess()) then
                    self:LogError("None or too low Access Level for User %s (%s)", tUser.Name, tostring(iLevel or "<Null>"))
                    tUser.AccessLevel = self:GetLowestAccess()
                elseif (iLevel > self:GetHighestAccess()) then
                    self:LogError("Too high Access Level for User %s (%s)", tUser.Name, tostring(iLevel))
                    tUser.AccessLevel = self:GetHighestAccess()
                end
            end
        end,

        OnHardwareIDReceived = function(self, hPlayer)
            if (not hPlayer.Info.UniqueIDAssigned) then
                self:AssignUniqueID(hPlayer, self:GetUniqueID(hPlayer))
            end
        end,

        OnValidationFinished = function(self, hPlayer)

            Server.Chat:SendWelcomeMessage(hPlayer)
            Server.Network:SendMessage(hPlayer, "Connected")

            --moved to timer function to allow clients to send hardware ids
            --self:AssignUniqueID(hPlayer, self:GetUniqueID(hPlayer))
            if (string.emptyN(hPlayer:GetHardwareId()) and not hPlayer.Info.UniqueIDAssigned) then
                self:AssignUniqueID(hPlayer, self:GetUniqueID(hPlayer))
            end

            Server.Events:Call(ServerScriptEvent_OnValidationFinished, hPlayer, hPlayer:GetProfileId())
        end,

        GetPlayerByUniqueID = function(self, hId)
            for _, hPlayer in pairs(Server.Utils:GetPlayers()) do
                if (hPlayer:GetUniqueID() == hId) then
                    return hPlayer
                end
            end
        end,

        AssignUniqueID = function(self, hPlayer, hId)

            if (hPlayer.Info.UniqueIDAssigned) then
                local hOldId = hPlayer:GetUniqueID()
                if (hOldId and hId ~= hOldId) then
                    self:LogWarning("Attempt to Assign a different UniqueID to '%s$9' (Old ID: %s, New ID: %s)", hPlayer:GetName(), hOldId, hId)
                    return
                end
                self:LogWarning("Attempt to Assign UniqueID even though it's already been Assigned to '%s'", hPlayer:GetName())
                return
            end

            hPlayer.Info.UniqueId = hId
            hPlayer.Info.UniqueName = self:GetUniqueName(hId)
            hPlayer.Info.UniqueIDAssigned = true
            self:Log("Resolved Unique ID for User '%s' ID: %s, Name: %s", hPlayer:GetName(), hId, hPlayer.Info.UniqueName)
            self:LogEvent({
                Message = "@uniqueId_assigned",
                MessageFormat = { Name = hPlayer:GetName(), UniqueName = hPlayer.Info.UniqueName, ID = hId },
                Recipients = Server.Utils:GetPlayers({ ByAccess = math.max(hPlayer:GetAccess(), ServerAccess_SuperAdmin) })
            })

            -- Check for Hard Bans here
            local bCheckHardBan = true
            if (Server.Punisher:CheckPlayerForBan(hPlayer, true, bCheckHardBan)) then
                return
            end
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

            local function Increment()
                self.UniqueUserIDs.Next = (self.UniqueUserIDs.Next + 1)
            end
            local function MakeID()
                Increment()
                return ("u%05d"):format(self.Properties.UniqueIDOffset + self.UniqueUserIDs.Next)
            end

            local sID = MakeID()
            while (self:GetUniqueProfile(sID)) do
                sID = MakeID()
                self:LogWarning("Accidental duplicated UniqueID '%s' on index %d", sID, self.UniqueUserIDs.Next)
            end

            table.insert(self.UniqueUserIDs.Profiles, {
                RegisterDate = Date:GetTimestamp(),
                UniqueName   = hPlayer:GetName(),
                UniqueId     = sID,
                Identifiers  = table.copy(aIdentifiers),
            })

            return self.UniqueUserIDs.Profiles[#self.UniqueUserIDs.Profiles].UniqueId
        end,

        OnNoProfileReceived = function(self, hPlayer)
        end,

        OnValidationFailed = function(self, hPlayer)

            if (self.Properties.KickInvalidProfiles) then
                Server.Punisher:KickPlayer(Server:GetEntity(), hPlayer, "Profile Validation Failed")

            elseif (self.Properties.BanInvalidProfiles) then
                Server.Punisher:BanPlayer(Server:GetEntity(), hPlayer, FIVE_MINUTES, "Profile Validation Failed" )

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

                -- This is purely so that if the user is of higher access, they will be able to see this log as well.
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

                --DebugLog(hIdLower,aInfo.Name)
                --local sLowerId = string.lower(aInfo.Level)
                local sLowerName = string.lower(aInfo.Name)
                --if (sLowerId == hIdLower or sLowerName == hIdLower or aInfo.Level == hIdNumber) then
                if (sLowerName == hIdLower or aInfo.Level == hIdNumber) then
                    hFound = aInfo
                    break -- stop on complete matches
                --elseif (string.match(sLowerId, "^" .. string.Escape(hIdLower)) or string.match(sLowerName, "^" .. string.Escape(hIdLower))) then
                elseif (string.match(sLowerName, "^" .. string.Escape(hIdLower))) then
                    if (hFound) then
                        hFound = nil
                        --DebugLog("found 2?",hFound.Level)
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

        IsNameProtected = function(self, sName, sOwnerId)

            local sNameLower = sName:lower()
            for _, tUser in pairs(self.SavedUsers) do
                if (tUser.NameProtected or (tUser.AccessLevel >= ServerAccess_Developer)) then
                    if (tUser.ProfileId ~= sOwnerId) then
                        if (tUser.Name:len() > 3) then
                            if (tUser.Name:lower():find(sNameLower)) then
                                return true
                            end
                        end
                    end
                end
            end
            return false
        end,

        GetIPProfile = function(self, sIPAddress)
            local iIPDecimal = string.ip2dec(sIPAddress)
            local sIPProfile = self.IPProfiles[iIPDecimal]
            if (sIPProfile == nil) then

                local function Increment()
                    self.IPProfiles["Next"] = (self.IPProfiles["Next"] or 0) + 1
                end
                local function Exists(sID)
                    for _, sOId in pairs(self.IPProfiles) do
                        if (_ ~= "Next" and sOId == sID) then
                            return true
                        end
                    end
                end
                local function MakeID()
                    Increment()
                    return ("ip%d"):format(self.Properties.IPProfileOffset + self.IPProfiles["Next"])
                end

                sIPProfile = MakeID()
                while Exists(sIPProfile) do
                    sIPProfile = MakeID()
                    self:LogWarning("Accidental duplicated IP-Profile '%s' on index %d", sIPProfile, self.IPProfiles.Next)
                end

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

        IsHardcodedUser = function(self, sProfileId)
            local tUser = self:GetRegisteredUser(sProfileId)
            if (not tUser) then
                return false
            end
            return tUser.IsHardcoded
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
            return true
        end,

        AddRegisteredUser = function(self, sUserName, sProfileId, iAccessLevel, sAdmin, bQuiet)

            local aUserInfo = (self.SavedUsers[sProfileId] or self:GetEmptyUser())

            aUserInfo.ProfileID     = sProfileId
            aUserInfo.Name          = sUserName
            aUserInfo.NameProtected = (iAccessLevel >= self:GetAdminLevel())

            local sAccessColor = self:GetAccessColor(iAccessLevel)
            local sAccessName = self:GetAccessName(iAccessLevel)

            if (not bQuiet) then
                sAdmin = (sAdmin or "Server")
                self:LogEvent({
                    Event = self:GetFriendlyName(),
                    Message = "@user_registered",
                    MessageFormat = { AccessName = sAccessName, AccessColor = sAccessColor, UserName = sUserName, ProfileID = sProfileId, AdminName = sAdmin }
                })
            end

            self.SavedUsers[sProfileId] = aUserInfo
        end,

        SetPlayerDefaultAccess = function(self, hPlayer)
            local iDefaultLevel = self:GetDefaultAccess()
            local bIsLocal = ServerDLL.IsChannelLocal(hPlayer:GetChannel())
            local sLocale = ""
            if (bIsLocal) then
                if (self.Properties.GrantHighestAccessToLocalUsers) then
                    iDefaultLevel = self:GetHighestAccess()
                    sLocale = "@str_local"
                end
            end
            hPlayer:SetAccess(iDefaultLevel, { Local = sLocale })
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

            if (iAccessLevel == nil) then
                error("no access level")
            end

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


            DebugLog(ServerAccess_Admin)
            if (hUser.Data.HasToxicityPass == nil) then
                if (hUser:HasAccess(ServerAccess_Admin)) then
                    hUser.Data.HasToxicityPass = true -- Automatically enable this on Admins
                end
            end

            g_gameRules.game:SetSynchedEntityValue(hUser.id, GlobalKeys.PlayerAccessName, sAccessName)
        end,

        GetAccessName = function(self, iAccessLevel)
            local aInfo = self:GetAccessInfo(iAccessLevel)
            if (not aInfo) then
                return
            end

            if (not aInfo:GetName()) then
                self:LogWarning("Level %s Has no Name assigned", aInfo:GetName())
                return "<Null>"
            end
            return aInfo:GetName()
        end,

        GetAccessColor = function(self, iAccessLevel)
            local aInfo = self:GetAccessInfo(iAccessLevel)
            if (not aInfo) then
                return
            end

            if (not aInfo:GetColor()) then
                self:LogWarning("Level %s Has no Color assigned", aInfo:GetName())
                return CRY_COLOR_WHITE
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

        GetModeratorLevel = function(self)
            return self.ModeratorAccessLevel
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
                    Moderator   = aInfo.Moderator,
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
                if (aInfo.Moderator) then
                    self.ModeratorAccessLevel = iLevel
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

        -- ============================================================================
        -- Commands

        Command_ChangeAccess = function(self, hPlayer, hTarget, iLevel, bDemote, bTemporary, sReason)
            iLevel = tonumber(iLevel)
            sReason = sReason or "@admin_decision"

            local bIsDeveloper = hPlayer:IsDeveloper()
            if (type(hTarget) == "table") then

                local iTargetAccess = hTarget:GetAccess()
                local sTargetId = hTarget:GetProfileId()

                if (iLevel == -1) then
                    iLevel = (iTargetAccess + (bDemote and -1 or 1))
                    iLevel = math.min(self:GetHighestAccess(), iLevel)
                    iLevel = math.max(self:GetLowestAccess(), iLevel)
                end

                if (iLevel > self:GetHighestAccess() or iLevel < self:GetLowestAccess()) then
                    return false, "@command_argNotAccess"
                elseif (iLevel < self:GetHighestAccess() and iTargetAccess >= hPlayer:GetAccess()) then
                    return false, "@insufficientAccess"
                end

                local sNewName = self:GetAccessName(iLevel)
                local sOldName = self:GetAccessName(iTargetAccess)
                if (iLevel == iTargetAccess) then
                    return false, (hPlayer:LocalizeText("@alreadyAccess", { Class = sNewName }))
                end

                local bLogEvent = true
                bTemporary = (bTemporary or (not hTarget:IsValidated()))
                if (not bTemporary) then

                    bLogEvent = (self:GetRegisteredUser(sTargetId))
                    local bIsHCUser = (bLogEvent and self:IsHardcodedUser(sTargetId))

                    if (bLogEvent and not bIsDeveloper) then
                        return false, hPlayer:Localize("@l_ui_cannotModifyHCUsers") -- fixme: locale
                    end
                    if (iLevel == self:GetLowestAccess()) then

                        -- Only Devs can overwrite hardcoded users (but even them cant delete one)
                        if (bLogEvent and bIsHCUser) then
                            return false, (hPlayer:LocalizeText("@cannotDeleteHCUser"))-- fixme: locale
                        end

                        -- 'not' means user does not exist
                        if (self:DeleteRegisteredUser(sTargetId, hPlayer:GetName())) then
                            bLogEvent = false -- so we log the event
                            return true
                        end
                    else
                        -- Log the "Promoted" (below) only if the user exists already, else show the user registered message
                        self:AddRegisteredUser(hTarget:GetName(), sTargetId, iLevel, hPlayer:GetName(), (bLogEvent)) -- Quiet
                    end
                else
                    bLogEvent = nil
                end

                -- Quiet always
                self:AssignAccess(hTarget, iLevel, { Quiet = bLogEvent, Temporary = (bTemporary and "@str_temporarily"or "" ) })
                if (bLogEvent) then
                    self:LogEvent({
                        Recipients = math.max(iLevel, self:GetModeratorLevel()),
                        Message = ("@user_%s"):format((iLevel > iTargetAccess and "promoted" or "demoted")),
                        MessageFormat = {
                            Admin = hPlayer:GetName(),
                            User = hTarget:GetName(),
                            NewLevel = self:GetAccessColor(iLevel) .. sNewName,
                            OldLevel = self:GetAccessColor(iTargetAccess) .. sOldName,
                        }
                    })
                end
                return true
            end
            error("implementation missing.")
            return self:Command_PromoteUser(hPlayer, hTarget, iLevel, sReason)
        end,


        Command_ListUsers = function(self, hPlayer, sFilter)

            -- Terrible, do something else.
            --      Name |      Nomad.CV (#0005)         | Name
            -- Unique ID |            p0001
            --   Profile |           1008858
            --      Host |
            --        IP |

        end,

        Command_SetUniqueName = function(self, hPlayer, hTarget, sName)

            local tProfile = self:GetUniqueProfile(hTarget:GetUniqueID())
            if (not tProfile) then
                return false, "@user_not_registered"
            end

            local tFormat = { OldName = tProfile.UniqueName, NewName = sName }
            self:LogEvent({
                Message = "@unique_name_changed",
                MessageFormat = tFormat,
                Recipients = math.max(ServerAccess_SuperAdmin, hTarget:GetAccess())
            })
            tProfile.UniqueName = sName
            return true, hPlayer:LocalizeText("@unique_name_changedChat", tFormat)
        end,

        Command_UniqueListUsers = function(self, hPlayer, sFilter)

            --[[
            #============================================================================================# ???
            #=== [           Name          |    Online    |    ID   | Entries |   Register Date     ] ===#
            [             Shortcut0            Yes (#31)    u108858   8           1y 30d 12h Ago         ]
            [             Shortcut1               No        u108859   31          30d 12h Ago            ]
            [             Shortcut2            Yes (#556)   u108860   3           12h Ago                ]
            [             Shortcut3            Yes (#556)   u108861   813         Today                  ]

            #====[ USER:COUNT (04) ]=====================================================================#
            ]]

            local aProfiles = self.UniqueUserIDs.Profiles
            local iProfiles = #aProfiles
            if (iProfiles == 0) then
                return false, hPlayer:LocalizeText("@noClassToDisplay", { Class = "@unique_users" })
            end

            local iConsoleWidth = Server.Chat:GetConsoleWidth()
            local iBoxWidth = iConsoleWidth - 4
            local iNameWidth = 38
            local iOnlineWidth = 12
            local iIDWidth = 7
            local iEntriesWidth = 7
            local iDateWidth = 29

            local tHeaders = {
                Name    = string.mspace(hPlayer:LocalizeText("@arg_name"), iNameWidth, nil, string.COLOR_CODE),
                Online  = string.mspace(hPlayer:LocalizeText("@online"), iOnlineWidth, nil, string.COLOR_CODE),
                ID      = string.mspace(hPlayer:LocalizeText("ID"), iIDWidth, nil, string.COLOR_CODE),
                Entries = string.mspace(hPlayer:LocalizeText("@entries"), iEntriesWidth, nil, string.COLOR_CODE),
                Date    = string.rspace(hPlayer:LocalizeText("@registry_date"), iDateWidth, string.COLOR_CODE),
            }

            local aLines = {
                ("=%s="):format(("="):rep(iBoxWidth - 2)),
                ("[ %s | %s | %s | %s | %s ]"):format(tHeaders.Name, tHeaders.Online, tHeaders.ID, tHeaders.Entries, tHeaders.Date)
            }

            local iTimestamp = Date:GetTimestamp()
            local sFilterLower = (sFilter or ""):lower()
            for _, tProfile in pairs(aProfiles) do

                local sUniqueName = tProfile.UniqueName
                local bAddToList = true
                if (string.emptyN(sFilter)) then
                    local iStart, iEnd = string.find(sUniqueName:lower(), sFilterLower)
                    if (iStart and iEnd) then
                        sUniqueName = sUniqueName:sub(1, iStart - 1) .. CRY_COLOR_YELLOW .. sUniqueName:sub(iStart, iEnd) .. CRY_COLOR_WHITE .. sUniqueName:sub(iEnd + 1)
                    else
                        bAddToList = false
                    end
                end

                if (bAddToList) then
                    local sOnlineStatus = CRY_COLOR_RED .. "@No"
                    local hOnline = self:GetPlayerByUniqueID(tProfile.UniqueId)
                    if (hOnline) then
                        sOnlineStatus = CRY_COLOR_GREEN .. ("@Yes $9(#$4%d$9)"):format(hOnline:GetChannel())
                    end
                    local tLine = {
                        Name    = string.mspace(sUniqueName, iNameWidth, nil, string.COLOR_CODE),
                        Online  = string.mspace(hPlayer:LocalizeText(sOnlineStatus), iOnlineWidth, nil, string.COLOR_CODE),
                        ID      = string.mspace(tProfile.UniqueId, iIDWidth, nil, string.COLOR_CODE),
                        Entries = string.rspace("#" .. #tProfile.Identifiers, iEntriesWidth, string.COLOR_CODE),
                        Date    = string.rspace(hPlayer:LocalizeText(Date:Colorize(Date:Format(iTimestamp - tProfile.RegisterDate), CRY_COLOR_BLUE)  .. " @ago"), iDateWidth, string.COLOR_CODE),
                    }
                    local sLine =
                    ("[ $1%s$9 | %s$9 | $4%s$9 | $8%s$9 | %s$9 ]"):format(tLine.Name, tLine.Online, tLine.ID, tLine.Entries, tLine.Date)
                    table.insert(aLines, sLine)
                end
            end

            if (#aLines == 2) then
                return false, hPlayer:LocalizeText("@noClassMatchingFilter", { Class = "@entries", Filter = sFilter })
            end

            table.insert(aLines, ("=%s="):format(("="):rep(iBoxWidth - 2)))

            for _, sLine in pairs(aLines) do
                Server.Chat:ConsoleMessage(hPlayer, string.mspace(CRY_COLOR_GRAY .. sLine, iConsoleWidth, nil, string.COLOR_CODE))
                --Server.Chat:ConsoleMessage(hPlayer, CRY_COLOR_GRAY .. sLine)
            end

            return true, hPlayer:LocalizeText("@entitiesListedInConsole", { Count = (#aLines - 3), Class = "@unique_users"})
        end,

    }
})