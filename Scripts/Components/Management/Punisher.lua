-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- Contains the Server Punisher Component
-- Handling Kicks, Bans & HardBans, and Mutes
-- ===================================================================================

Server:CreateComponent({
    Name = "Punisher",
    FriendlyName = "Punish",
    Body = {

        ExternalData = {
            { Key = "BanList",  Name = "Bans.lua",    Path = (SERVER_DIR_DATA .. "Punishments\\"), }, -- ReadOnly = true },
            { Key = "MuteList", Name = "Mutes.lua",   Path = (SERVER_DIR_DATA .. "Punishments\\"), }, -- ReadOnly = true },
            { Key = "WarnList", Name = "Warning.lua", Path = (SERVER_DIR_DATA .. "Punishments\\"), }, -- ReadOnly = true },
        },

        Protected = {
            BanList = {},
            MuteList = {},
            WarnList = {},
        },

        ChatEntity = "SERVER : DEFENSE",

        Initialize = function(self)
        end,

        PostInitialize = function(self)
        end,

        Event_TimerSecond = function(self)
            self:RefreshMutes()
            self:RefreshBans()
        end,

        -- ============================================================================================================
        -- MUTE HANDLER

        MutePlayer = function(self, hPlayer, hAdmin, sDuration, sReason, bHardMute)

            if (self:GetMuteInfo(hPlayer)) then
                return false, "@player_alreadyMuted"
            end

            hAdmin = hAdmin or Server:GetEntity()
            sDuration = sDuration or "5m"
            sReason = sReason or "@admin_decision"

            local iDuration = Date:ParseTime(sDuration)
            local bAllowExtendedMutes = (hAdmin:HasAccess(ServerAccess_SuperAdmin))
            if (bAllowExtendedMutes and (sDuration == "-1" or sDuration:lower() == "infinite")) then
                iDuration = -1
            else
                -- Regular Admins can only mute people for up to 12 hours
                iDuration = math.min(iDuration, (ONE_HOUR * 12))
            end

            local sDurationFormatted = Date:Format(iDuration)
            local tFormat = {
                Name = hPlayer:GetName(),
                Admin = hAdmin:GetName(),
                Reason = sReason,
                Time = sDurationFormatted
            }
            Server.Chat:ChatMessage(self.ChatEntity, ALL_PLAYERS, "@player_muted", tFormat)
            Server.Chat:TextMessage(ChatType_Error, ALL_PLAYERS, "@player_muted", tFormat)
            self:LogEvent({
                Message = "@player_muted",
                MessageFormat = tFormat
            })

            self:WriteMute(hPlayer, hAdmin, iDuration, sReason)
        end,

        WriteMute = function(self, hAdmin, hVictim, iDuration, sReason, bHardMute)

            local sAdmin = hAdmin:GetName()
            local iTimestamp = Date:GetTimestamp()
            local iExpiry = -1

            local bInfinite = (iDuration == -1)
            if (not bInfinite) then

                -- Clamp to duration to safe levels
                iDuration = Date:ClampToMaxInteger(math.max(10, iDuration))
                iExpiry = iTimestamp + iDuration
            end

            local aMuteInfo = {
                Name        = hVictim:GetName(),
                Access      = hVictim:GetAccess(),
                Admin       = sAdmin,
                Reason      = (sReason or "@admin_decision"),
                Duration    = iDuration,
                Expiry      = iExpiry,
                Timestamp   = iTimestamp,
                Identifiers = {
                    hVictim:GetIPAddress(),
                    hVictim:GetProfileId(),
                    hVictim:GetHostName(),
                    hVictim:GetHardwareId(),
                },
                IsHardMute  = bHardMute,
                UniqueID    = hVictim:GetUniqueID(),
                UniqueName  = hVictim:GetUniqueName()
            }
            table.insert(self.MuteList, aMuteInfo)
        end,

        UnMutePlayer = function(self, hPlayer, hAdmin, sReason)

            hAdmin = hAdmin or Server:GetEntity()
            sReason = sReason or "@admin_decision"

            local tMute = self:GetMuteInfo(hPlayer)
            self:RemoveMute(tMute, hPlayer:GetName(), hAdmin, sReason)
        end,

        RemoveMute = function(self, tMute, sPlayer, hAdmin, sReason)
            for _, tInfo in pairs(self.MuteList) do
                if (tInfo == tMute) then
                    self.MuteList[_] = nil
                    break
                end
            end

            local tFormat = {
                Name = (sPlayer or tMute.Name),
                Admin = hAdmin:GetName(),
                Reason = sReason,
            }
            Server.Chat:ChatMessage(self.ChatEntity, ALL_PLAYERS, "@player_unMuted", tFormat)
            Server.Chat:TextMessage(ChatType_Error, ALL_PLAYERS, "@player_unMuted", tFormat)
            self:LogEvent({
                Message = "@player_unMuted",
                MessageFormat = tFormat
            })
        end,

        CheckChatMessage = function(self, hPlayer, sMessage)

            local tMute = self:GetMuteInfo(hPlayer)
            if (not tMute) then
                return true -- No Mute
            end

            if (tMute.Expiry ~= -1 and Date:GetTimestamp() >= tMute.Expiry) then
                self:UnMutePlayer(hPlayer, Server:GetEntity(), "@mute_expired")
                return true -- No Mute
            end

            local sExpiry = "Never"
            if (tMute.Expiry ~= -1) then
                sExpiry = Date:Format(tMute.Expiry - Date:GetTimestamp())
            end

            Server.Chat:ToAdminConsole(hPlayer:GetName(), ("(MUTED) $4%s"):format(sMessage))
            Server.Chat:ChatMessage(self.ChatEntity, hPlayer, "@you_are_muted", { Reason = tMute.Reason, Expiry = sExpiry })
            return false -- Muted
        end,

        RefreshMutes = function(self)

            local iTimestamp = Date:GetTimestamp()
            for _, tMute in pairs(self.MuteList) do
                if (tMute.Expiry ~= -1 and iTimestamp >= tMute.Expiry) then
                    self:RemoveMute(tMute, tMute.Name, Server:GetEntity(), "@mute_expired")
                end
            end
        end,

        GetMuteInfo = function(self, hPlayer, bCheckHardMutesOnly)

            self:RefreshMutes()
            local aIdentifiers = {
                hPlayer:GetIPAddress(),
                hPlayer:GetProfileId(),
                hPlayer:GetHostName(),
                hPlayer:GetHardwareId(),
            }
            local sUniqueId = hPlayer:GetUniqueID()
            for _, tMute in pairs(self.MuteList) do
                if (tMute.IsHardMute) then
                    if (sUniqueId == tMute.UniqueID) then
                        return tMute
                    end
                end
                if (not bCheckHardMutesOnly) then
                    for _, sIdentifier in pairs(tMute.Identifiers) do
                        for _, sPlayerIdentifier in pairs(aIdentifiers) do
                            if (sIdentifier == sPlayerIdentifier) then
                                return tMute
                            end
                        end
                    end
                end
            end
        end,

        Command_MutePlayer = function(self, hAdmin, hVictim, sDuration, sReason, bIsHardMute)
            local iAccess = hAdmin:GetAccess()
            if (iAccess ~= ServerAccess_Highest and hVictim:HasAccess(iAccess)) then
                return false, hAdmin:LocalizeText("@insufficientAccess")
            end

            sReason = (sReason or "@admin_decision")
            sDuration = (sDuration or "5m")
            return self:MutePlayer(hAdmin, hVictim, sDuration, sReason, bIsHardMute)
        end,

        Command_UnMutePlayer = function(self, hAdmin, hVictim, sReason)
            local iAccess = hAdmin:GetAccess()
            if (iAccess ~= ServerAccess_Highest and hVictim:HasAccess(iAccess)) then
                return false, hAdmin:LocalizeText("@insufficientAccess")
            end

            sReason = (sReason or "@admin_decision")
            return self:UnMutePlayer(hVictim, hAdmin, sReason)
        end,

        -- ============================================================================================================
        -- BAN HANDLER

        DisconnectChannel = function(self, iChannel, iType, sReason)
            local hPlayer = Server.Utils:GetPlayerByChannel(iChannel)
            if (hPlayer and hPlayer.Initialized) then
                hPlayer:SetIntentionalDisconnect(true)
            else
                sReason = Server.LocalizationManager:LocalizeMessage(sReason, Language_English)
            end

            ServerDLL.KickChannel(iType, iChannel, Server.Logger:RidColors(sReason))
        end,

        KickPlayer = function(self, hAdmin, hVictim, sReason)

            local sVictimName
            local iVictimChannel
            if (type(hVictim) == "number") then
                sVictimName = ServerDLL.GetChannelNick(hVictim)
                iVictimChannel = hVictim
            else
                sVictimName = hVictim:GetName()
                iVictimChannel = hVictim:GetChannel()
            end

            sReason = (sReason or "@admin_decision")
            self:DisconnectChannel(iVictimChannel, DisconnectType_Kicked, sReason)

            local tFormat = {
                Name = sVictimName,
                Admin = hAdmin:GetName(),
                Reason = sReason
            }
            Server.Chat:ChatMessage(self.ChatEntity, ALL_PLAYERS, "@player_kicked", tFormat)
            Server.Chat:TextMessage(ChatType_Error, ALL_PLAYERS, "@player_kicked", tFormat)
            self:LogEvent({
                Message = "@player_kicked",
                MessageFormat = tFormat
            })
        end,

        CheckPlayersForBan = function(self)

            -- Remove any expired bans
            local bAnyBanned
            self:RefreshBans()
            for _, hPlayer in pairs(Server.Utils:GetPlayers()) do
                bAnyBanned = bAnyBanned or self:CheckPlayerForBan(hPlayer)
            end

            return bAnyBanned
        end,

        -- Old ban taking action
        LogBanned = function(self, tBan)
            self:LogBanOrUnban(tBan, "@player_banned_ex")
        end,

        -- Next ban taking effect
        LogBanOrUnban = function(self, tBan, sLocale, sUnbanReason)

            local sAdmin = tBan.Admin
            local sName = tBan.Name
            local sReason = tBan.Reason
            local sExpiry = "{Red}@Never"
            if (tBan.Expiry ~= -1) then
                local iBanTime = (tBan.Expiry - Date:GetTimestamp())

                local iFlag = 0
                if (iBanTime > ONE_DAY) then
                    iFlag = DateFormat_Hours
                end

                sExpiry = Date:Colorize(Date:Format(iBanTime, DateFormat_Cramped + iFlag), CRY_COLOR_RED, CRY_COLOR_GRAY)
            end

            local tFormat = {
                Time = sExpiry,
                Admin = sAdmin,
                Name = sName,
                Reason = sReason,
                UnbanReason = sUnbanReason,
            }

            sLocale = sLocale or "@player_banned"
            Server.Chat:ChatMessage(self.ChatEntity, ALL_PLAYERS, sLocale, tFormat)
            Server.Chat:TextMessage(ChatType_Error, ALL_PLAYERS, sLocale, tFormat)
            self:LogEvent({
                Message = sLocale,
                MessageFormat = tFormat
            })
        end,

        RefreshBans = function(self)
            local iTimestamp = Date:GetTimestamp()
            for _, tBan in pairs(self.BanList) do
                if (tBan.Expiry ~= -1 and iTimestamp >= tBan.Expiry) then
                    self:RemoveBan(tBan, "@ban_expired")
                end
            end
        end,

        RemoveBan = function(self, tBan, sReason, hAdmin)

            for _, tOtherBan in pairs(self.BanList) do
                if (tOtherBan == tBan) then
                    table.remove(self.BanList, _)
                    break
                end
            end

            hAdmin = hAdmin or Server:GetEntity()
            tBan.Admin = (hAdmin:GetName()) -- this is purely for logging now
            self:LogBanOrUnban(tBan, "@player_unbanned", sReason)
        end,

        GetBanReason = function(self, tBan)

            local sReason = tBan.Reason or "@admin_decision"
            local sExpiry = "@Never"
            if (tBan.Expiry ~= -1) then
                local iBanTime = (tBan.Expiry - Date:GetTimestamp())
                local iFlag = 0
                if (iBanTime > ONE_DAY) then
                    iFlag = DateFormat_Hours
                end
                sExpiry = Date:Colorize(Date:Format(iBanTime, DateFormat_Cramped + iFlag), CRY_COLOR_RED, CRY_COLOR_GRAY)
            end

            return ("%s | Expiry: %s"):format(sReason, sExpiry)
        end,

        CheckChannelForBan = function(self, iChannel)

            local aBanList = self.BanList
            if (#aBanList == 0) then
                return false
            end

            local sIPAddress = ServerDLL.GetChannelIP(iChannel)
            if (not sIPAddress) then
                return false
            end

            -- Remove any expired bans
            self:RefreshBans()
            for _, tBan in pairs(self.BanList) do
                if (table.find_value(tBan.Identifiers, sIPAddress)) then
                    self:LogBanned(tBan)
                    self:DisconnectChannel(iChannel, DisconnectType_Banned, (Server.LocalizationManager:LocalizeMessage(self:GetBanReason(tBan), Language_English)))
                    return true
                end
            end

            return false
        end,

        CheckPlayerForBan = function(self, hPlayer, sLocale, bCheckHardBansOnly)

            -- Its an existing ban, not a new one
            if (sLocale == true) then
                sLocale = "@player_banned_ex"

                -- Remove any expired bans
                self:RefreshBans()
            end

            local function OnDetected(tBan)

                local sReason = tBan.Reason
                local sExpiry = "{Red}@Never"
                if (tBan.Expiry ~= -1) then
                    sExpiry = Date:Colorize(Date:Format(tBan.Expiry - Date:GetTimestamp(), DateFormat_Cramped), CRY_COLOR_RED, CRY_COLOR_GRAY)
                end

                self:LogBanOrUnban(tBan, sLocale)
                self:DisconnectChannel(hPlayer:GetChannel(), DisconnectType_Banned, hPlayer:LocalizeText(self:GetBanReason(tBan)))
            end

            local aIdentifiers = {
                hPlayer:GetIPAddress(),
                hPlayer:GetProfileId(),
                hPlayer:GetHostName(),
                hPlayer:GetHardwareId(),
            }

            local sUniqueId = hPlayer:GetUniqueID()
            for _, tBan in pairs(self.BanList) do
                if (tBan.IsHardBan) then
                    if (sUniqueId == tBan.UniqueID) then
                        OnDetected(tBan)
                        return true
                    end
                elseif (not bCheckHardBansOnly) then
                    for _, sIdentifier in pairs(tBan.Identifiers) do
                        for _, sPlayerIdentifier in pairs(aIdentifiers) do
                            if (sIdentifier == sPlayerIdentifier) then
                                OnDetected(tBan)
                                return true
                            end
                        end
                    end
                end
            end
        end,

        WriteBan = function(self, hAdmin, hVictim, iDuration, sReason, bHardBan)

            local sAdmin = hAdmin:GetName()
            local iTimestamp = Date:GetTimestamp()
            local iExpiry = -1

            local bInfinite = (iDuration == -1)
            if (not bInfinite) then

                -- Clamp to duration to safe levels
                iDuration = Date:ClampToMaxInteger(math.max(10, iDuration))
                iExpiry = iTimestamp + iDuration
            end

            local sDebug1, sDebug2, sDebug3, sDebug4, sDebug5, sDebug6
            if (false) then
                sDebug1 = string.random(8)
                sDebug2 = string.random(16)
                sDebug3 = string.random(32)
                sDebug4 = string.random(64)
                sDebug5 = string.random(10)
                sDebug6 = string.random(10)
            end

            local aBanInfo = {
                Name        = hVictim:GetName(),
                Access      = hVictim:GetAccess(), -- for !UnBan
                Admin       = sAdmin,
                AdminAccess = hAdmin:GetAccess(),
                Reason      = (sReason or "@admin_decision"),
                Duration    = iDuration,
                Expiry      = iExpiry,
                Timestamp   = iTimestamp,
                Identifiers = {
                    sDebug1 or hVictim:GetIPAddress(),
                    sDebug2 or hVictim:GetProfileId(),
                    sDebug3 or hVictim:GetHostName(),
                    sDebug4 or hVictim:GetHardwareId(),
                },
                IsHardBan   = bHardBan,
                UniqueID    = sDebug5 or hVictim:GetUniqueID(),
                UniqueName  = sDebug6 or hVictim:GetUniqueName()
            }
            table.insert(self.BanList, aBanInfo)
            return aBanInfo, self:CheckPlayersForBan()
        end,

        FindBanByIdentifier = function(self, sIdentifier)

            local tFound = {
                ByUniqueID = {}, -- ??
                ByName = {},
                ByIDs = {},
            }

            local sIdentifierLower = sIdentifier:lower()
            for _, tBan in pairs(self.BanList) do

                -- First, check names
                if (tBan.Name:lower():find(sIdentifierLower) or tBan.Name:lower():find(sIdentifierLower, true)) then
                    table.insert(tFound.ByName, tBan)

                -- Then, check if unique IDs match
                elseif (tBan.UniqueID:lower() == sIdentifierLower) then
                    table.insert(tFound.ByUniqueID, tBan)
                else
                    -- And lastly, check if any identifiers match
                    for _, sBanIdentifier in pairs(tBan.Identifiers) do
                        if (string.Escape(sBanIdentifier):lower():match(string.Escape(sIdentifierLower))) then
                            table.insert(tFound.ByIDs, tBan)
                        end
                    end
                end
            end

            -- Now, check for the best match
            if (#tFound.ByName > 0) then
                return tFound.ByName

            elseif (#tFound.ByUniqueID > 0) then
                return tFound.ByUniqueID

            elseif (#tFound.ByIDs > 0) then
                return tFound.ByIDs
            end

            -- Nil in this case
            return
        end,

        IndexBan = function(self, hAdmin, tBan, sAction)

            --[[
            ==== [ BAN:INFO ] ===============================================================
            [                                                                               ]
            [   Name        : Nomad.CV (#1008858     |   Banned By : CryMP-Server           ]
            [   Access      : Developer              |   Access    : Owner                  ]
            [   Unique Name : Shortcut0              |   Reason    : Admin Decision         ]
            [   Unique ID   : u1008858               |   Time Ago  : 30d, 21h, 15m, 10s     ]
            [   Hard Ban    : Yes                    |   Expiry    : 25d, 15h, 56m, 43s     ]
            [                                                                               ]
            [ Identifiers:                                                                  ]
            [ 01) 127.0.0.1          02) nomad.nullptr.one                                  ]
            [ 03) 1008858            04) 192.168.0.1                                        ]
            =============================================================== [ BAN:INFO ] ====
            ]]

            local sActionLower = (sAction or ""):lower()
            local bIsManager = hAdmin:HasAccess(ServerAccess_SuperAdmin)
            if (string.emptyN(sActionLower)) then
                if (IsAny(sActionLower, "del", "erase", "remove", "unban", "flush")) then
                    if (not bIsManager or tBan.Access > hAdmin:GetAccess()) then
                        return false, "@insufficientAccess"
                    end

                    self:RemoveBan(tBan, "@admin_decision", hAdmin)
                    return true
                else
                    Server.Chat:ChatMessage(self.ChatEntity, hAdmin, "@ban_action_info1")
                    return false, "@invalid_action"
                end
            end

            local function RC(s)
                return (s:gsub(string.COLOR_CODE, ""))
            end
            local function RCC(s)
                return #(RC(s))
            end

            local iTimestamp = Date:GetTimestamp()

            local sTitle = hAdmin:LocalizeText("@baninfo")
            local aMessageList = {
                ("==== [ {Gray}%s{Gray} ] %s"):format(sTitle, string.rep("=", 99 - RCC(sTitle))),
                ("[ %s ]"):format(string.rep(" ", 105))
            }

            local iLeftItemWidth = 32
            local sName = string.rspace(tBan.Name, iLeftItemWidth, string.COLOR_CODE)
            local sAccess = Server.AccessHandler:GetAccessColor(tBan.Access) .. string.rspace(Server.AccessHandler:GetAccessName(tBan.Access), iLeftItemWidth, string.COLOR_CODE)
            local sUniqueName = string.rspace(tBan.UniqueName, iLeftItemWidth, string.COLOR_CODE)
            local sUniqueID = string.rspace(tBan.UniqueID, iLeftItemWidth, string.COLOR_CDOE)
            local sHardBan = string.rspace((tBan.IsHardBan and "$4Yes" or "$3No"), iLeftItemWidth, string.COLOR_CODE)

            local iRightItemWidth = 32
            local sBannedBy = string.rspace(tBan.Admin, iRightItemWidth, string.COLOR_CODE)
            local sBannedByAccess = Server.AccessHandler:GetAccessColor(tBan.AdminAccess) .. string.rspace(Server.AccessHandler:GetAccessName(tBan.AdminAccess), iRightItemWidth, string.COLOR_CODE)
            local sBanReason = string.rspace(tBan.Reason, iRightItemWidth, string.COLOR_CODE)
            local sTimeAgo = string.rspace((
                    Date:Colorize(Date:Format(iTimestamp - tBan.Timestamp))
            ), iRightItemWidth, string.COLOR_CODE)
            local sExpiry = string.rspace((
                    tBan.Expiry == -1 and "@Never" or Date:Colorize(Date:Format(tBan.Expiry - iTimestamp))
            ), iRightItemWidth, string.COLOR_CODE)

            -- LEFT
            local sNameT = string.rspace(hAdmin:LocalizeText("@name"), 14, string.COLOR_CODE)
            local sAccessT = string.rspace(hAdmin:LocalizeText("@access"), 14, string.COLOR_CODE)
            local sUNameT = string.rspace(hAdmin:LocalizeText("@unique_name"), 14, string.COLOR_CODE)
            local sUIDT = string.rspace(hAdmin:LocalizeText("@unique_id"), 14, string.COLOR_CODE)
            local sHardBanT = string.rspace(hAdmin:LocalizeText("@hard_ban"), 14, string.COLOR_CODE)

            -- RIGHT
            local sBannedByT = string.rspace(hAdmin:LocalizeText("@banned_by"), 14, string.COLOR_CODE)
            local sBannedByAccessT = string.rspace(hAdmin:LocalizeText("@access"), 14, string.COLOR_CODE)
            local sReasonT = string.rspace(hAdmin:LocalizeText("@reason"), 14, string.COLOR_CODE)
            local sTimeAgoT = string.rspace(hAdmin:LocalizeText("@time_ago"), 14, string.COLOR_CODE)
            local sExpiryT = string.rspace(hAdmin:LocalizeText("@expiry"), 14, string.COLOR_CODE)

            table.insert(aMessageList, ("[   %s : {Blue}%s{Gray} |   %s : {Red}%s{Gray} ]"):format(
                    sNameT, sName, sBannedByT, sBannedBy))

            table.insert(aMessageList, ("[   %s : %s{Gray} |   %s : %s{Gray} ]"):format(
                    sAccessT, sAccess, sBannedByAccessT, sBannedByAccess))

            table.insert(aMessageList, ("[   %s : {White}%s{Gray} |   {Gray}%s{Gray} : {White}%s{Gray} ]"):format(
                    sUNameT, sUniqueName, sReasonT, sBanReason))

            table.insert(aMessageList, ("[   %s : {Orange}%s{Gray} |   %s : %s{Gray} ]"):format(
                    sUIDT, sUniqueID, sTimeAgoT, sTimeAgo))

            table.insert(aMessageList, ("[   %s : %s{Gray} |   %s : %s{Gray} ]"):format(
                    sHardBanT, sHardBan, sExpiryT, sExpiry))

            -- BOTTOM
            local sIdentifiersT = string.rspace(hAdmin:LocalizeText("{Orange}@identifiers{Gray}:"), 105, string.COLOR_CODE)
            table.insert(aMessageList, ("[ %s ]"):format(string.rep(" ", 105)))
            table.insert(aMessageList, ("[ %s ]"):format(sIdentifiersT))

            local iStep = 0
            local iStepMax = 1
            local iIdentifiers = #tBan.Identifiers
            if (1 or iIdentifiers > 8) then
                iStepMax = 2
            end
            local sLine = ""
            for _, sIdentifier in ipairs(tBan.Identifiers) do
                iStep = iStep + 1
                sLine = sLine .. (" $9#$1%02d$9) $1%s"):format(_, string.rspace(sIdentifier, 33))
                if ((iStep < iStepMax and (_ + 1 <= iIdentifiers) and string.len(tBan.Identifiers[_ + 1]) >= 32) or iStep == iStepMax or (_ == iIdentifiers)) then
                    iStep = 0
                    table.insert(aMessageList, ("[ %s $9]"):format(string.rspace(sLine, 105, string.COLOR_CODE)))
                    sLine = ""
                end
                DebugLog(_, sLine)
            end

            table.insert(aMessageList, ("%s [ {Gray}%s{Gray} ] ===="):format(string.rep("=", 99 - RCC(sTitle)), sTitle))
            for _, sMessage in pairs(aMessageList) do
                Server.Chat:ConsoleMessage(hAdmin, ("{Gray}%s"):format(sMessage))
            end
        end,

        ListBans = function(self, hAdmin, sFilter, tList, sAction)

            self:RefreshBans()

            local tBanList = (tList or self.BanList)
            if (#tBanList == 0) then
                return false, "@no_bans_found"
            end

            local iFilter = tonumber(sFilter or "")
            if (iFilter) then
                local tIndexBan = tBanList[iFilter]
                if (tIndexBan) then
                    return self:IndexBan(hAdmin, tIndexBan, sAction)
                end
            end

            --[[
            ==== [ BAN:LIST ] =============================================================================================
            [   #ID  Name                     Admin                   Reason                      Expiry                  ]
            [  (#01) Nomad.CV (#1008858)    | CryMP-Server          | Admin Decision            | 10d: 15h: 25m: 10s      ]
            [  (#01) Nomad.CV (#1008858)    | CryMP-Server          | Admin Decision            | 10d: 15h: 25m: 10s      ]
            [  (#01) Nomad.CV (#1008858)    | CryMP-Server          | Admin Decision            | 10d: 15h: 25m: 10s      ]
            [  (#01) Nomad.CV (#1008858)    | CryMP-Server          | Admin Decision            | 10d: 15h: 25m: 10s      ]
            [  (#01) Nomad.CV (#1008858)    | CryMP-Server          | Admin Decision            | 10d: 15h: 25m: 10s      ]
            [  (#01) Nomad.CV (#1008858)    | CryMP-Server          | Admin Decision            | 10d: 15h: 25m: 10s      ]
            [  (#01) Nomad.CV (#1008858)    | CryMP-Server          | Admin Decision            | 10d: 15h: 25m: 10s      ]
            [  (#01) Nomad.CV (#1008858)    | CryMP-Server          | Admin Decision            | 10d: 15h: 25m: 10s      ]
            [                                                                                                             ]
            [  For Detailed Info, Index a Ban using !BanInfo <#ID>                                                        ]
            ============================================================================================= [ BAN:LIST ] ====
            ]]

            local function RC(s)
                return (s:gsub(string.COLOR_CODE, ""))
            end
            local function RCC(s)
                return #(RC(s))
            end

            -- 93
            local sTitle = hAdmin:LocalizeText("@banlist")
            local sNameT = string.rspace(hAdmin:LocalizeText("@name"), 22, string.COLOR_CODE)
            local sAdminT = string.rspace(hAdmin:LocalizeText("@admin"), 21, string.COLOR_CODE)
            local sReasonT = string.rspace(hAdmin:LocalizeText("@reason"), 25, string.COLOR_CODE)
            local sExpiryT = string.rspace(hAdmin:LocalizeText("@expiry"), 23, string.COLOR_CODE)

            local aMessageList = {
                ("==== [ {Gray}%s{Gray} ] %s"):format(sTitle, string.rep("=", 94 - RCC(sTitle))),
                ("[   #ID %s{Gray} %s{Gray} %s{Gray} %s{Gray} ]"):format(sNameT, sAdminT, sReasonT, sExpiryT),
            }

            table.insert(aMessageList, ("[ %s ]"):format(string.rep(" ", 100)))

            local iTimestamp = Date:GetTimestamp()
            local iDisplayed = 0
            for _, tBan in ipairs(tBanList) do

                local sID = ("(#$4%02d$9)"):format(_)
                local sName = string.rspace(tBan.Name, 22, string.COLOR_CODE)
                local sAdmin = string.rspace(tBan.Admin, 21, string.COLOR_CODE)
                local sReason = string.rspace(tBan.Reason:sub(1, 24), 25, string.COLOR_CODE)
                local sExpiry = string.rspace((
                        tBan.Expiry == -1 and "@never" or Date:Colorize(Date:Format(iTimestamp - tBan.Expiry))
                ), 23, string.COLOR_CODE)

                local bOk = true
                if (sFilter) then
                    -- TODO
                    DebugLog("add filter!!")
                end
                if (bOk) then
                    iDisplayed = (iDisplayed + 1)
                    table.insert(aMessageList, ("[ %s{Gray} %s{Gray} %s{Gray} %s{Gray} %s{Gray} ]"):format(sID, sName, sAdmin, sReason, sExpiry))
                end
            end

            if (iDisplayed == 0) then
                table.insert(aMessageList, ("[ %s ]"):format(string.rep(" ", 108)))
                table.insert(aMessageList, string.rspace(hAdmin:LocalizeText("@noClassMatchingFilter", { Class = "@bans", Filter = sFilter }), 108, string.COLOR_CODE))
            end

            table.insert(aMessageList, ("[ %s ]"):format(string.rep(" ", 100)))
            table.insert(aMessageList, ("[ %s ]"):format(string.rspace(hAdmin:LocalizeText("@ban_index_info"), 100, string.COLOR_CODE)))
            table.insert(aMessageList, ("%s [ {Gray}%s{Gray} ] ===="):format(string.rep("=", 94 - RCC(sTitle)), sTitle))

            for _, sLine in pairs(aMessageList) do
                Server.Chat:ConsoleMessage(hAdmin, ("{Gray}%s"):format(sLine))
            end

            if (iDisplayed == 0) then
                return false, hAdmin:LocalizeText("@noClassMatchingFilter", { Class = "@entries", Filter = sFilter })
            end
            return true, hAdmin:LocalizeText("@entitiesListedInConsole", { Class = "@bans", Count = iDisplayed })
        end,

        UnBanPlayer = function(self, hAdmin, sIdentifier, sReason)

            local bIsDeveloper = hAdmin:IsDeveloper()
            local tBans = self:FindBanByIdentifier(sIdentifier)
            if (not tBans) then
                local sIdentifierLower = sIdentifier:lower()
                if (sIdentifierLower == "all") then
                    if (not bIsDeveloper) then
                        return false, "@insufficientAccess"
                    end
                    local tAllBans = {}
                    for _, tBan in pairs(self.BanList) do
                        tAllBans[_] = tBan
                    end
                    if (#tAllBans == 0) then
                        return false, "@no_bans_found"
                    end
                    for _, tBan in pairs(tAllBans) do
                        self:RemoveBan(tBan, sReason, hAdmin)
                    end
                    return true
                end
                return false, "@ban_not_found"
            end

            if (#tBans > 1) then
                return self:ListBans(hAdmin, nil, tBans)
            end

            local tBan = tBans[1]
            if (tBan.Access > hAdmin:GetAccess()) then
                return false, "@insufficientAccess"
            end

            self:RemoveBan(tBan, sReason, hAdmin)
            return true
        end,

        BanPlayer = function(self, hAdmin, hVictim, sDuration, sReason, bHardBan)

            sReason = (sReason or "@admin_decision")
            sDuration = tostring(sDuration or "5m")

            local sVictimName = hVictim:GetName()
            local iVictimChannel = hVictim:GetChannel()
            local iDuration = Date:ParseTime(sDuration)
            local bAllowExtendedBans = (hAdmin:HasAccess(ServerAccess_SuperAdmin))
            if (bAllowExtendedBans and (sDuration == "-1" or sDuration:lower() == "infinite")) then
                iDuration = -1
            else
                -- Regular Admins can only ban people for up to three days
                iDuration = math.min(iDuration, (ONE_DAY * 3))
            end

            local tBan, bAnyBanned = self:WriteBan(hAdmin, hVictim, iDuration, sReason, bHardBan)
            if (not bAnyBanned) then
                self:LogBanOrUnban(tBan, "@player_banned")
            end
            --self:DisconnectChannel(iVictimChannel, DisconnectType_Banned, sReason) -- done a little later down the chain

            --[[
            local tFormat = {
                Name = sVictimName,
                Admin = hAdmin:GetName(),
                Reason = sReason
            }
            Server.Chat:ChatMessage(self.ChatEntity, ALL_PLAYERS, "@player_banned", tFormat)
            Server.Chat:TextMessage(ChatType_Error, ALL_PLAYERS, "@player_banned", tFormat)
            self:LogEvent({
                Message = "@player_banned",
                MessageFormat = tFormat
            })]]
        end,

        -- ==========================================================
        -- Commands

        Command_KickChannel = function(self, hAdmin, iChannelId, sReason)

            local hVictim = Server.Utils:GetPlayerByChannel(iChannelId)
            if (hVictim) then
                return self:Command_KickPlayer(hAdmin, hVictim, sReason)
            end

            local tChannelInfo = Server.Network.ActiveConnections[iChannelId]
            if (not tChannelInfo) then
                return false, "@invalid_channel"
            end

            return self:KickPlayer(hAdmin, iChannelId, sReason)
        end,

        Command_KickPlayer = function(self, hAdmin, hVictim, sReason)
            local iAccess = hAdmin:GetAccess()
            if (iAccess ~= ServerAccess_Highest and hVictim:HasAccess(iAccess)) then
                return false, hAdmin:LocalizeText("@insufficientAccess")
            end

            sReason = (sReason or "@admin_decision")
            return self:KickPlayer(hAdmin, hVictim, sReason)
        end,

        Command_BanPlayer = function(self, hAdmin, hVictim, sDuration, sReason, bHardBan)
            local iAccess = hAdmin:GetAccess()
            if (iAccess ~= ServerAccess_Highest and hVictim:HasAccess(iAccess)) then
                return false, hAdmin:LocalizeText("@insufficientAccess")
            end

            sReason = (sReason or "@admin_decision")
            sDuration = (sDuration or "5m")

            --if (iAccess <= ServerAccess_Admin) then
            --end

            return self:BanPlayer(hAdmin, hVictim, sDuration, sReason, bHardBan)
        end,

        Command_UnBanPlayer = function(self, hAdmin, sIdentifier, sReason)
            sReason = (sReason or "@admin_decision")
            return self:UnBanPlayer(hAdmin, sIdentifier, sReason)
        end,

        Command_ListBans = function(self, hAdmin, sIndex, sAction)
            return self:ListBans(hAdmin, sIndex, nil, sAction)
        end,

        Command_IndexBan = function(self, hAdmin, sIndex, sAction)

            local iIndex = tonumber(sIndex or "")
            local tIndexBan = self.BanList[iIndex]
            if (tIndexBan) then
                return self:IndexBan(hAdmin, tIndexBan, sAction)
            end

            return self:ListBans(hAdmin, sIndex, nil, sAction)
        end,
    }
})