-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- Contains the Server Punisher Component
-- Handling Kicks, Bans & HardBans and Mutes
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
            self:RefreshBans()
            for _, hPlayer in pairs(Server.Utils:GetPlayers()) do
                self:CheckPlayerForBan(hPlayer)
            end
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

            local aBanInfo = {
                Name        = hVictim:GetName(),
                Admin       = sAdmin,
                Reason      = (sReason or "@admin_decision"),
                Duration    = iDuration,
                Expiry      = iExpiry,
                Timestamp   = iTimestamp,
                Identifiers = {
                    hVictim:GetIPAddress(),
                    hVictim:GetProfileId(),
                    hVictim:GetHostName(),
                },
                IsHardBan   = bHardBan,
                UniqueID    = hVictim:GetUniqueID(),
                UniqueName  = hVictim:GetUniqueName()
            }
            table.insert(self.BanList, aBanInfo)
            self:CheckPlayersForBan()
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

            self:WriteBan(hAdmin, hVictim, iDuration, sReason, bHardBan)
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

            self:KickPlayer(hAdmin, iChannelId, sReason)
        end,

        Command_KickPlayer = function(self, hAdmin, hVictim, sReason)
            local iAccess = hAdmin:GetAccess()
            if (iAccess ~= ServerAccess_Highest and hVictim:HasAccess(iAccess)) then
                return false, hAdmin:LocalizeText("@insufficientAccess")
            end

            sReason = (sReason or "@admin_decision")
            self:KickPlayer(hAdmin, hVictim, sReason)
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

            self:BanPlayer(hAdmin, hVictim, sDuration, sReason, bHardBan)
        end,
    }
})