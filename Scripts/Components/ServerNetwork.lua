-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
--                  This File contains the Server Network Component
--            It's main purpose is to expose the Server to the Master Server-
--                 But it also handles incoming and outgoing Channels,
--                    And the Caching and saving Geolocation Data
-- ===================================================================================

Server:CreateComponent({
    Name = "Network",
    Body = {

        ExternalData = {
            { Key = "SavedGeoData", Name = "GeoData.lua", Path = SERVER_DIR_DATA }
        },

        CCommands = {
            { Name = "push_update", FunctionName = "UpdateServer", Description = "Directly pushes for a Server Update, bypassing all restrictions" },
        },

        Protected = {

            -- so we dont do this over and over and over again!
            IsRegistered = false,
            Cookie = "-1",

            SavedGeoData = {},
            ChannelCache = {},
            FailedQueries = {},
            ActiveQueries = {},
            ActiveConnections = {},
            BannedChannels = {},
            CurrentChannel = 0,
        },


        Properties = {

            -- There is a few servers who clearly do this
            -- This is just an option for the sake of adding it, using it is something else!
            PingMultiplier = 1.0,
            AveragePingWarningThreshold = 200,
            NetworkUsageWarningThresholds = { Up = 9999, Down = 9999 },
            PingControl = {},
            IPFilter = {},

            -- Timeout for waiting on the UUID of a user
            UUIDAwaitTimeout = 15,


            GeoService = "http://ip-api.com/json/{Query}?fields=3854107",

            MasterServerAPI     = ServerDLL.GetMasterServerAPI(),
            MasterServerTimeout = 30, -- timeout for connection attempts

            Headers = {
                Default = { ["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8" },
                JSON    = { ["Content-Type"] = "application/json" },
            },

            EndPoints = {
                Register = "/reg.php",
                Updater  = "/up.php",
                Validate = "/validate.php",
            },

            -- The info sent to the Master Server
            ServerInfo = {
                GameVersion = ServerDLL.GetGameVersion(),
                Description = "No Description Available.",
            },

            UseJSONBody = true,

            UpdateInterval = 60, -- The interval between each status update
            RecoveryInterval = 25, -- When a network error occurs, we try again after this amount of time has passed

            MapLinkDir  = (SERVER_DIR_DATA .. "\\"),
            MapLinkFile = "MapLinks\.(txt|json|lua)",
            MapLinkList = {},

        }, ---< Properties

        DefaultGeoData = {
            ContinentName = "Lingshan Island",
            ContinentCode = "LI",
            CountryName   = "Crysis ville",
            CountryCode   = "CV",
            RegionName    = "Onslaught",
            City          = "Unnamed Village at the Lake",
            District      = "School District",
            Timezone      = "Lingshan/Korea",
            ISP           = "AlieNet Technologies",
            Organisation  = "Korean People's Army",
            AS            = "AS205016 KoreanPeople Inc.",
            Proxy         = false,
            IsDefault     = true
        },

        --Cookie = nil, -- Session ID
        --IsRegistered = false,
        IsRegistering = false, -- In the process of registering the server
        RegisterFailed = false,

        IsUpdating = false,
        UpdateFailed = false,

        Timers = {
            Update = TimerNew(0),
            UpdateFail = TimerNew(0),
            UpdateLog = TimerNew(HALF_HOUR),
            RegisterFail = TimerNew(0),

            PingUpdate = TimerNew(1),
            PingWarning = TimerNew(8),
        },

        Initialize = function(self)

            local aMapLinks = self:LoadMapLinks()
            self.Properties.MapLinkList = aMapLinks
            self:Log("Imported %d Map-Links", table.size(aMapLinks))


            self.Properties.ServerInfo.Description = Server.Config:Get("Server.ServerDescription", "No Description")

            self.Timers.RegisterFail.setexpiry(self.Properties.RecoveryInterval)
            self.Timers.UpdateFail.setexpiry(self.Properties.RecoveryInterval)
            self.Timers.UpdateLog.expire()
            self.Timers.Update.setexpiry(self.Properties.UpdateInterval)
            self.Timers.PingUpdate.setexpiry(1)

            self.Properties.PingMultiplier = Server.Config:Get("Network.PingMultiplier", 1, ConfigType_Number)
            self.Properties.AveragePingWarningThreshold = Server.Config:Get("Network.AveragePingWarningThreshold", 200, ConfigType_Number)
            self.PingControl = {
                Enabled = Server.Config:Get("Network.PingControl.Enabled", true, ConfigType_Boolean),
                Tolerance = Server.Config:Get("Network.PingControl.Tolerance", 300, ConfigType_Number),
                WarningLimit = Server.Config:Get("Network.PingControl.WarningLimit", 5, ConfigType_Number),
                WarningDelay = Server.Config:Get("Network.PingControl.WarningDelay", 10, ConfigType_Number),
                ResetWarnings = Server.Config:Get("Network.PingControl.ResetWarnings", false, ConfigType_Boolean),
                IssuedWarnings = {}, -- Internal data
            }

            self.IPFilter = {
                Enabled = Server.Config:Get("Network.ConnectionFilter.Enabled", true, ConfigType_Boolean),
                Countries = Server.Config:Get("Network.ConnectionFilter.Blacklist.Countries", {}, ConfigType_Array),
                IPAddresses = Server.Config:Get("Network.ConnectionFilter.Blacklist.IPAddresses", {}, ConfigType_Array),
                Providers = Server.Config:Get("Network.ConnectionFilter.Blacklist.Providers", {}, ConfigType_Array),
            }

            self.Properties.NetworkUsageWarningThresholds = Server.Config:Get("Network.NetworkUsageWarningThresholds", {Up=0,Down=0}, ConfigType_Array)
            self.Properties.ForcedCVars = Server.Config:Get("Network.ForcedCVars", {}, ConfigType_Array)

            self:Log("Initialized")
        end,

        PostInitialize = function(self)

            local iChanged = 0
            for sCVar, sValue in pairs(self.Properties.ForcedCVars) do
                Server.Utils:FSetCVar(sCVar, tostring(sValue))
                iChanged = iChanged + 1
            end

            self:Log("Changed %d CVars", iChanged)
        end,

        OnReset = function(self)

            -- Upon changing a map, we won't receive a new connection timer
            -- So we "reset" it here
            for iChannel, aInfo in pairs(self.ActiveConnections) do
                aInfo.Timer.refresh()
            end
        end,

        OnProfileValidated = function(self, hPlayer, sProfile, sError, sResponse, iCode)

            if (not Server.Utils:GetEntity(hPlayer)) then
                self:LogEvent({ Event = self:GetName(), Recipients = Server.AccessHandler:GetAdministrators(), Message = "@user_notValidatedQuit", MessageFormat = {{ UserName = ToString(hPlayer:GetName()) }} })
                return
            end

            hPlayer:SetProfileValidated(false)

            if (iCode ~= 200 or sResponse ~= "%Validation:Successful%") then
                self:LogEvent({ Event = self:GetName(), Recipients = Server.AccessHandler:GetAdministrators(), Message = "@user_notValidated", MessageFormat = {{ ProfileId = sProfile, UserName = ToString(hPlayer:GetName()) }} })
                Server.Events:Call(ServerScriptEvent_OnValidationFailed, hPlayer, sResponse, iCode)
                self:LogError("Validation Failed with Code %d (Response '%s')", iCode, (sResponse or "<Null>"))
                return
            end

            hPlayer:SetProfileValidated(true)
            Server.Events:Call(ServerScriptEvent_OnProfileValidated, hPlayer, sProfile)
        end,

        ValidateHardwareId = function(self, hPlayer, sSupposedID)

            if (string.emptyN(hPlayer:GetHardwareId())) then
                self:Log("Hardware ID Already Assigned")
                return true
            end

            local hCheck = hPlayer.TempData.UUIDCheck
            local iCheckLen = string.len(hCheck)
            local hUUIDCheck = sSupposedID:sub(1, iCheckLen)
            if (hUUIDCheck ~= hCheck) then
                self:LogWarning("Hardware ID Checks don't match on User %s", hPlayer:GetName())
                return true
            end

            local sIDProof = sSupposedID:sub(iCheckLen + 1)
            local sHardwareId, sProof = sIDProof:match("(.*):(.*)")
            if (not sHardwareId or not sProof) then
                self:LogWarning("Missing Proof or ID on User %s", hPlayer:GetName())
                return true
            end
            if (#sHardwareId ~= 64) then
                self:LogWarning("ID Length out of Bounds on User %s", hPlayer:GetName())
                return true
            end

            hPlayer.Info.HardwareId = sHardwareId
            self:DestroyUUIDCheck(hPlayer)
            Server.AccessHandler:OnHardwareIDReceived(hPlayer)
            return true
        end,

        ValidateProfile = function(self, hPlayer, sProfile, sHash, sName)

            sProfile = tostring(sProfile)

            -- Don't allow empty profiles, profiles longer than 7 characters, or negative profile id values
            if (string.empty(sProfile) or not string.match(sProfile, "^%d+$") or (#sProfile > 7) or (not tonumber(sProfile) or tonumber(sProfile) < 0)) then
                return false
            end

            hPlayer:SetProfileReceived(true)
            if (hPlayer.Info.IsValidating or hPlayer:IsValidated()) then
                return true
            end

            if (hPlayer.Info.ValidationFailed) then
                return false
            end

            ServerDLL.Request({
                url = (self.Properties.MasterServerAPI .. self.Properties.EndPoints.Validate),
                method = "GET",
                body = self.ServerReport:BodyToString({
                    prof = sProfile,
                    uid = sHash
                }),
                headers = self.Properties.Headers.Default,
                timeout = self.Properties.MasterServerTimeout,
            }, function(...)
                self:OnProfileValidated(hPlayer, sProfile, ...)
            end)

            hPlayer.Info.IsValidating = true
            return true
        end,

        OnChannelCreated = function(self, iChannel)

            local sIPAddress = ServerDLL.GetChannelIP(iChannel)
            local sNickname = ServerDLL.GetChannelNick(iChannel)

            local aGeoInfo, bIsInvalidIP = self:GetGeoInfo(sIPAddress, iChannel)

            local sCountryName = aGeoInfo.CountryName
            local sCountryCode = aGeoInfo.CountryCode

            self.ChannelCache[iChannel] = {
                IPAddress = sIPAddress,
                NickName  = sNickname,
                GeoInfo   = aGeoInfo
            }

            -- This if kind of redundant, but for the sake of readability we shall step out of Thor's Region here!
            self.ActiveConnections[iChannel] = {
                Timer    = TimerNew(),
                NickNick = sNickname,
            }

            if (self.SavedGeoData[sIPAddress] or bIsInvalidIP) then
                self:OnGeoDataQueried(iChannel)
            end

            self.CurrentChannel = iChannel
            Server.Statistics:Event(StatisticsEvent_OnNewChannel, iChannel)

            -- Check the Channel for a Ban here
            if (Server.Punisher:CheckChannelForBan(iChannel)) then
                self.BannedChannels[iChannel] = true
                return
            end

            if (self.SavedGeoData[sIPAddress] and not bIsInvalidIP) then
                if (self:CheckBlacklist(iChannel, sIPAddress, aGeoInfo)) then
                   -- self.BannedChannels[iChannel] = true
                end
            end
        end,

        GetConnectionTimer = function(self, iChannel)
            if (not self.ActiveConnections[iChannel]) then
                return TimerNew()--error("timer not found!")
            end
            return self.ActiveConnections[iChannel].Timer
        end,

        ParseDisconnectReason = function(self, sDescription)
            -- TODO
            local sShort = "Disconnected"
            return sShort, sDescription
        end,

        OnChannelDisconnect = function(self, iChannel, sDescription)

            local sReasonShort, sReason = self:ParseDisconnectReason(sDescription)
            local sNickname = ServerDLL.GetChannelNick(iChannel)

            if (not self.BannedChannels[iChannel]) then
                self:LogEvent({
                    Recipients = Server.Utils:GetPlayers(),
                    Message = "@channel_disconnect",
                    MessageFormat = { Channel = iChannel, Nick = sNickname, Reason = sReason, ShortReason = sReasonShort }
                })
            end

            -- Channels NEVER decrement, so this is fine
            self.ActiveConnections[iChannel] = nil
            self.ChannelCache[iChannel]      = nil
            self.ActiveQueries[iChannel]     = nil
            self.FailedQueries[iChannel]     = nil

        end,

        DestroyUUIDCheck = function(self, hClient)
            hClient.TempData.UUIDCheck = string.random(math.random(52,125))
        end,

       Event_OnActorSpawn = function(self, hClient)
           local sCheck = string.random(math.random(25, 75))
           hClient.TempData.UUIDCheck = sCheck
       end,

        OnClientConnected = function(self, iChannel, hClient)

            -- Check for Bans here
            if (Server.Punisher:CheckPlayerForBan(hClient, true)) then
                return
            end

            -- Push for an update to reflect new Players
            if (self.Timers.Update:GetExpiry() > 3) then
                self.Timers.Update:SetExpiry(3)
            end
        end,

        OnClientDisconnect = function(self, hClient, iChannel, iCause, sDescription)
            if (not hClient:WasIntentionallyDisconnected()) then
                self:SendMessage(hClient, "Disconnected", { Cause = iCause, Description = (sDescription or "Undefined") })
            end

            -- Do this a little later so we wont lag the Script
            Script.SetTimer(100, function()
                if (Server.Utils:GetPlayerCount() == 0) then
                    Server:OnServerEmptied()
                end
            end)
        end,

        SendMessage = function(self, hPlayer, sMessage, aInfo)

            local sCountryCode = hPlayer:GetCountryCode()
            local sCountryName = hPlayer:GetCountryName()
            local sPlayerName = hPlayer:GetName()
            local iChannel = hPlayer:GetChannel()

            if (sMessage == "Connected") then
                Server.Network:LogEvent({
                    Message = "@player_connected",
                    MessageFormat = {
                        Name = sPlayerName,
                        Channel = iChannel,
                        Time = Date:Format(hPlayer.Timers.Connection.diff()),
                        CountryCode = sCountryCode,
                        CountryName = sCountryName,
                    }
                })
                Server.Chat:ChatMessage(ChatEntity_Server, Server.Utils:GetPlayers(), "@player_connectedChat", { Name = hPlayer:GetName(), Channel = hPlayer:GetChannel(), CountryCode = sCountryCode, ISP = hPlayer:GetISP() })
            elseif (sMessage == "Disconnected") then

                local sReasonShort, sReason = self:ParseDisconnectReason(aInfo.Description)
                Server.Network:LogEvent({
                    Message = "@player_disconnected",
                    MessageFormat = {
                        Name = sPlayerName,
                        Channel = iChannel,
                        Time = Date:Format(hPlayer.Timers.Initialized.diff()),
                        Reason = sReason,
                        ShortReason = sReasonShort
                    }
                })
                Server.Chat:ChatMessage(ChatEntity_Server, Server.Utils:GetPlayers(), "@player_disconnectedChat", { Name = sPlayerName, Channel = iChannel, Time = Date:Format(hPlayer.Timers.Initialized.diff()), Reason = sReason, ShortReason = sReasonShort })
            end
        end,

        GetGeoMember = function(self, hPlayer, sMember)
            local sIP, iChannel
            if (type(hPlayer) == "table") then
                sIP, iChannel = hPlayer:GetIPAddress(), hPlayer:GetChannel()
            else
                sIP = ServerDLL.GetChannelIP(hPlayer)
                iChannel = hPlayer
            end
            local aGeoInfo = self:GetGeoInfo(sIP, iChannel)
            local hMember = aGeoInfo[sMember]
            return hMember
        end,

        GetCountryCode = function(self, hPlayer)
            return self:GetGeoMember(hPlayer, "CountryCode")
        end,

        GetCountryName = function(self, hPlayer)
            return self:GetGeoMember(hPlayer, "CountryName")
        end,

        GetISP = function(self, hPlayer)
            return self:GetGeoMember(hPlayer, "ISP")
        end,

        OnGeoDataQueried = function(self, iChannel)

            Server.NameHandler:CheckChannelNick(iChannel)

            local sNickname = ServerDLL.GetChannelNick(iChannel)
            local sIPAddress = ServerDLL.GetChannelIP(iChannel)

            local sCountryName = self:GetCountryName(iChannel)
            local sCountryCode = self:GetCountryCode(iChannel)

            local tFormat = { Channel = iChannel, Nick = sNickname, IP = sIPAddress, CountryCode = sCountryCode, Country = sCountryName }
            Server.Chat:ChatMessage(ChatEntity_Server, ServerAccess_GetAdmins(), "@channel_created", tFormat)
            Server.Chat:BattleLog(BattleLog_Information, ALL_PLAYERS, "@channel_created", tFormat)
            self:LogEvent({ Recipients = Server.Utils:GetPlayers(), Message = "@channel_created", MessageFormat = tFormat })

        end,

        GetDefaultGeoData = function(self)
            return table.copy(self.DefaultGeoData)
        end,

        GetGeoInfo = function(self, sIPAddress, iChannel)

            -- Assumable an NPC
            if (self.FailedQueries[iChannel] or iChannel == 0 or sIPAddress == "127.0.0.1") then
                self:Log("[%d, %s] Invalid IP-Address, Skipping Query", iChannel, sIPAddress)
                return table.copy(self.DefaultGeoData), true
            end

            local aGeoInfo = self.SavedGeoData[sIPAddress]
            if (aGeoInfo) then

                -- If somehow some default data snuck into the database
                if (aGeoInfo.IsDefault) then
                    self:QueryGeoData(sIPAddress, iChannel)
                else
                    self:Log("Found GeoData in local database")
                end
                return aGeoInfo
            end

            self:QueryGeoData(sIPAddress, iChannel)
            return table.copy(self.DefaultGeoData)
        end,

        QueryGeoData = function(self, sIPAddress, iChannel)

            if (self.ActiveQueries[iChannel]) then
                return self:Log("Query for IP %s already exists", sIPAddress)
            end

            self.ActiveQueries[sIPAddress] = true
            self:Log("Resolving IP %s for Channel %d", sIPAddress, iChannel)

            ServerDLL.Request({
                url = string.gsub(self.Properties.GeoService, "{Query}", sIPAddress),
                method = "GET",
            }, function(...)
                if (Server.Network:OnGeoDataReceived(sIPAddress, iChannel, ...) == false) then
                end
            end)
        end,

        OnGeoDataReceived = function(self, sIPAddress, iChannel, sError, sResponse, iCode)

            local hPlayer = Server.Utils:GetPlayerByChannel(iChannel)
            local sContinentName = self.DefaultGeoData.ContinentName
            local sCountryName = self.DefaultGeoData.CountryName
            local sCountryCode = self.DefaultGeoData.CountryCode
            local sCity = self.DefaultGeoData.City
            local sISP = self.DefaultGeoData.ISP

            self.ActiveQueries[sIPAddress] = nil

            local bOk, aResponse = pcall(function()
                if (iCode == 419) then
                    return false, self:LogFatal("We have been throttled!")
                end

                if (iCode ~= 200) then
                    self:LogError("Failed to Query Geolocation for IP %s", sIPAddress)
                    self:LogError("%s", sError)
                    return false
                end

                local aResponse = json.decode(sResponse)
                if (not IsArray(aResponse)) then
                    self:LogError("Failed to decode JSON Response")
                    self:LogError("%s", sResponse)
                    return false
                end

                if (not IsAny(aResponse.status, "success", "ok", "succeeded")) then
                    self:LogError("Query Failed with message %s", CheckVar(aResponse.message, "<Unknown>"))
                    self:LogError("%s", sResponse)
                    return false
                end

                return aResponse
            end)
            if (bOk and aResponse ~= false) then
                local FindKey = function(tbl, keys)
                    return table.FindAny(tbl, keys, function(a, b)
                        return ToString(a):lower() == ToString(b):lower()
                    end)
                end

                local aGeoData = {
                    ContinentName = FindKey(aResponse, { "continent" }),
                    ContinentCode = FindKey(aResponse, { "continentCode" }),
                    CountryName   = FindKey(aResponse, { "country" }),
                    CountryCode   = FindKey(aResponse, { "countryCode" }),
                    RegionName    = FindKey(aResponse, { "regionName" }),
                    City          = FindKey(aResponse, { "city" }),
                    District      = FindKey(aResponse, { "district" }),
                    Timezone      = FindKey(aResponse, { "tz", "timezone" }),
                    ISP           = FindKey(aResponse, { "carrier", "provider", "isp" }),
                    Organisation  = FindKey(aResponse, { "organisation", "org" }),
                    AS            = FindKey(aResponse, { "as" }),
                    Proxy         = FindKey(aResponse, { "tor", "vpn", "proxy" }),
                }
                self.SavedGeoData[sIPAddress] = aGeoData

                if (self.ChannelCache[iChannel]) then
                    self.ChannelCache[iChannel].GeoInfo = self.SavedGeoData
                end
                if (hPlayer) then
                    hPlayer.Info.GeoData = self.SavedGeoData[sIPAddress]
                end

                sContinentName = aGeoData.ContinentName
                sCountryName = aGeoData.CountryName
                sCountryCode = aGeoData.CountryCode
                sCity = aGeoData.City
                sISP = aGeoData.ISP
            else
                self.FailedQueries[iChannel] = true
            end

            self:OnGeoDataQueried(iChannel)
            self:Log("Queried Info for %s | Country: %s, Continent: %s, City: %s, ISP: %s", sIPAddress, sCountryName, sContinentName, sCity, sISP)
        end,

        CheckBlacklist = function(self, iChannel, sIPAddress, aGeoInfo)

            local aConfig = self.IPFilter
            if (not aConfig or not aConfig.Enabled) then
                return
            end

            self.BannedChannels[iChannel] = true

            local aIPFilters = aConfig.IPAddresses
            for _, sFilter in pairs(aIPFilters or {}) do
                if (sIPAddress:match(sFilter:lower())) then
                    Server.Punisher:KickPlayer(Server:GetEntity(), iChannel, "Blacklisted IP")
                    return
                end
            end

            local aProviderFilters = aConfig.Providers
            local sProvider = aGeoInfo.ISP
            if (string.emptyN(sProvider)) then
                sProvider = sProvider:lower()
                for _, sFilter in pairs(aProviderFilters or {}) do
                    if (sProvider:match(sFilter:lower())) then
                        Server.Punisher:KickPlayer(Server:GetEntity(), iChannel, "Blacklisted Provider")
                        return
                    end
                end
            end

            local aCountryFilters = aConfig.Providers
            local sCountryName = aGeoInfo.CountryName
            if (string.emptyN(sCountryName)) then
                sCountryName = sCountryName:lower()
                for _, sFilter in pairs(aCountryFilters or {}) do
                    if (sCountryName:match(sFilter:lower())) then
                        Server.Punisher:KickPlayer(Server:GetEntity(), iChannel, "Blacklisted Country")
                        return
                    end
                end
            end

            -- All checks passed!
            self.BannedChannels[iChannel] = false
        end,

        ExtractCookie = function(self, sMessage)
            return (string.match(sMessage, "^<<Cookie>>(.*)<<$"))
        end,

        Event_TimerSecond = function(self)

            for _, hPlayer in pairs(Server.Utils:GetPlayers()) do
                if (not hPlayer.Info.UniqueIDAssigned) then
                    if (hPlayer.Timers.Connection.Diff() >= self.Properties.UUIDAwaitTimeout) then
                        Server.AccessHandler:AssignUniqueID(hPlayer, Server.AccessHandler:GetUniqueID(hPlayer))
                        self:DestroyUUIDCheck(hPlayer)
                    end
                end
            end

            if (not self.Initialized) then
                return
            end

            if (not self.IsRegistered) then
                if (self.RegisterFailed) then
                    if (not self.Timers.RegisterFail.expired()) then
                        return
                    end
                end
                if (self.IsRegistering) then
                    return
                end

                return self:RegisterServer()
            end

            if (self.UpdateFailed) then
                self.Timers.UpdateLog.expire() -- So next successful update will correctly show up
                if (not self.Timers.UpdateFail.expired()) then
                    return
                end
                return self:UpdateServer()
            end
            if (self.Timers.Update.expired_refresh()) then
                if (self.IsUpdating) then
                    return
                end
                return self:UpdateServer()
            end
        end,

        OnRegistered = function(self, sError, sResponse, iCode)

            self.IsRegistered   = false
            self.RegisterFailed = true
            self.IsRegistering  = false

            self.Timers.RegisterFail.refresh()

            if (iCode ~= 200) then
                return self:LogError("Request failed with Code %d (%s)", CheckNumber(iCode), ToString(sResponse))
            end

            if (sResponse == "FAIL") then
                return self:LogError("Failed to Register the Server.")
            end

            self.Cookie = self:ExtractCookie(sResponse)
            if (not self.Cookie) then
                return self:LogError("Failed to extract Cookie from Response (%s)", ToString(sResponse))
            end

            self:Log("Successfully Registered! Cookie for this Session is %s", ToString(self.Cookie))

            self.IsRegistered   = true
            self.RegisterFailed = false
        end,

        RegisterServer = function(self)

            if (self.IsRegistering) then
                return
            end

            self.RegisterFailed = false
            self.IsRegistering = false
            self.IsRegistering = true

            local sBody = self.ServerReport:Get(ServerNetwork_GetRegister)
            local aHeaders = self.Properties.Headers.Default
            if (self.Properties.UseJSONBody) then
                aHeaders = self.Properties.Headers.JSON
            end

            ServerDLL.Request({
                url = (self.Properties.MasterServerAPI .. self.Properties.EndPoints.Register),
                method = "POST",
                body = sBody,
                headers = aHeaders,
                timeout = self.Properties.MasterServerTimeout,
            }, function(...)
                self:OnRegistered(...)
            end)

            self:Log("Registering Server at %s...", (self.Properties.MasterServerAPI .. self.Properties.EndPoints.Register))
        end,

        OnUpdated = function(self, sError, sResponse, iCode)

            self.UpdateFailed = true
            self.IsUpdating  = false

            self.Timers.UpdateFail.refresh()

            if (iCode ~= 200) then
                return self:LogError("Update Request failed with Code %d (%s)", CheckNumber(iCode), ToString(sResponse))
            end

            if (sResponse == "FAIL") then
                return self:LogError("Failed to Update the Server.")
            end

            self.UpdateFailed = false
            if (self.Timers.UpdateLog.expired_refresh()) then
                self:Log("Successfully Updated!")
            end
        end,

        UpdateServer = function(self)

            if (self.IsUpdating) then
                return
            end

            self.UpdateFailed = false
            self.IsUpdating = true

            local sBody = self.ServerReport:Get(ServerNetwork_GetUpdater)
            local aHeaders = self.Properties.Headers.Default
            if (self.Properties.UseJSONBody) then
                aHeaders = self.Properties.Headers.JSON
            end

            ServerDLL.Request({
                url = string.gsub(self.Properties.MasterServerAPI .. self.Properties.EndPoints.Updater, "^https://", "http://"),
                method = "POST",
                body = sBody,
                headers = aHeaders,
                timeout = self.Properties.MasterServerTimeout,
            }, function(...)
                self:OnUpdated(...)
            end)

            if (self.Timers.UpdateLog.expired()) then
                self:Log("Updating Server Info at %s", (self.Properties.MasterServerAPI .. self.Properties.EndPoints.Updater))
            end
        end,

        ServerReport = {

            BoldCharMap = {
                ['A'] = '𝗔', ['B'] = '𝗕', ['C'] = '𝗖', ['D'] = '𝗗', ['E'] = '𝗘',
                ['F'] = '𝗙', ['G'] = '𝗚', ['H'] = '𝗛', ['I'] = '𝗜', ['J'] = '𝗝',
                ['K'] = '𝗞', ['L'] = '𝗟', ['M'] = '𝗠', ['N'] = '𝗡', ['O'] = '𝗢',
                ['P'] = '𝗣', ['Q'] = '𝗤', ['R'] = '𝗥', ['S'] = '𝗦', ['T'] = '𝗧',
                ['U'] = '𝗨', ['V'] = '𝗩', ['W'] = '𝗪', ['X'] = '𝗫', ['Y'] = '𝗬',
                ['Z'] = '𝗭', ['a'] = '𝗮', ['b'] = '𝗯', ['c'] = '𝗰', ['d'] = '𝗱',
                ['e'] = '𝗲', ['f'] = '𝗳', ['g'] = '𝗴', ['h'] = '𝗵', ['i'] = '𝗶',
                ['j'] = '𝗷', ['k'] = '𝗸', ['l'] = '𝗹', ['m'] = '𝗺', ['n'] = '𝗻',
                ['o'] = '𝗼', ['p'] = '𝗽', ['q'] = '𝗾', ['r'] = '𝗿', ['s'] = '𝘀',
                ['t'] = '𝘁', ['u'] = '𝘂', ['v'] = '𝘃', ['w'] = '𝘄', ['x'] = '𝘅',
                ['y'] = '𝘆', ['z'] = '𝘇', ['0'] = '𝟬', ['1'] = '𝟭', ['2'] = '𝟮',
                ['3'] = '𝟯', ['4'] = '𝟰', ['5'] = '𝟱', ['6'] = '𝟲', ['7'] = '𝟳',
                ['8'] = '𝟴', ['9'] = '𝟵'
            },

            Get = function(self, iType, bReturnArray)

                -- Server Config
                local sName         = Server.Utils:GetCVar("sv_servername")
                local sPakLink      = self:GetServerPakLink()
                local sDesc         = self:ConvertFormatTags(self:GetServerDescription())
                local sLocal        = "localhost"
                local sVersion      = Server.Network.Properties.ServerInfo.GameVersion
                local sPass         = (self:GetServerPassword() == "0" and "0" or "1")

                -- Map Config
                local iDirectX10    = 1
                local sMapName      = Server.MapRotation:GetMapPath()
                local sMapTitle     = self:GetMapTitle(sMapName)
                local sMapDownload  = self:GetMapDownloadLink()
                local iTimeLeft     = (g_gameRules.game:GetRemainingGameTime())

                -- Player Config
                local iMaxPlayers   = Server.Utils:GetCVar("sv_maxPlayers")
                local hPlayerList   = self:GetPlayers()
                local iPlayerCount  = table.count(hPlayerList)
                if (IsString(hPlayerList)) then
                    iPlayerCount    = string.count(hPlayerList, "@")
                end

                -- Net Config
                local iPort         = Server.Utils:GetCVar("sv_port")
                local iPublicPort   = Server.Utils:GetCVar("sv_port")
                local bGameSpy      = "0"

                -- General Config
                local iVoiceChat    = Server.Utils:GetCVar("net_enable_voice_chat") >= 1
                local iIsDedicated  = (ServerDLL.IsDedicated() and 1 or 0)
                local iAntiCheat    = ToString(Server.Utils:GetCVar("sv_cheatprotection"))
                local iGPOnly       = "0" -- FIXME
                local iFriendlyFire = ToString(Server.Utils:GetCVar("g_friendlyFireRatio"))
                local iRanked       = "1"

                local aBody = {
                    cookie       = nil,
                    players      = nil,
                    port         = iPort,
                    gamespy      = bGameSpy,
                    desc         = sDesc,
                    timel        = iTimeLeft,
                    name         = sName,
                    numPlayers   = iPlayerCount,
                    numpl        = iPlayerCount,
                    maxpl        = iMaxPlayers,
                    pak          = sPakLink,
                    map          = sMapName,
                    mapnm        = sMapTitle,
                    mapdl        = sMapDownload,
                    pass         = sPass,
                    ranked       = iRanked,
                    gameVersion  = sVersion,
                    ["local"]    = sLocal,
                    public_port  = iPublicPort,
                    dx10         = iDirectX10,
                    voicechat    = iVoiceChat,
                    dedicated    = ToString(iIsDedicated),
                    anticheat    = iAntiCheat,
                    gamepadsonly = iGPOnly,
                    friendlyfire = iFriendlyFire
                }

                if (iType == ServerNetwork_GetUpdater) then
                    aBody.cookie  = Server.Network.Cookie
                    aBody.players = hPlayerList
                end

                if (bReturnArray) then
                    return aBody
                elseif (self.UseJSONBody) then
                    return json.encode(aBody)
                end

                return self:BodyToString(aBody)
            end,

            BodyToString = function(self, aBody)
                local aTemp = {}
                for i, v in pairs(aBody) do
                    table.insert(aTemp, tostring(i) .. "=" .. ServerDLL.URLEncode(tostring(v)))
                end
                return (table.concat(aTemp, "&"))
            end,

            GetPlayers = function(self, iPopulation)

                local sName, sRank, sKills, sDeaths, sProfile, sTeam
                local aPlayers = {}
                local aPopulation = {}
                local sPlayers = ""
                local sPopulation = ""

                if (iPopulation) then
                    for i = 1, iPopulation do
                        sName    = ("Entity" .. i)
                        sRank    = 1
                        sKills   = GetRandom(1, 100)
                        sDeaths  = GetRandom(1, 100)
                        sProfile = "1008858"
                        sTeam    = GetRandom(0, 2)
                        if (g_gameRules.IS_IA) then sTeam = "1"
                        end
                        sPopulation = string.format("%s@%s%%%s%%%s%%%s%%%s", sPopulation, sName, sRank, sKills, sDeaths, sProfile)
                        table.insert(aPopulation, {
                            name       = sName,
                            rank       = sRank,
                            kills      = sKills,
                            deaths     = sDeaths,
                            profile_id = sProfile,
                            team       = sTeam
                        })
                    end
                end

                for _, hClient in pairs(Server.Utils:GetPlayers()) do

                    sName    = Server.NameHandler:Sanitize(hClient:GetName())
                    sRank    = hClient:GetRank()
                    sKills   = hClient:GetKills() if (sKills < 0) then sKills = 0 end
                    sDeaths  = hClient:GetDeaths()  if (sDeaths < 0) then sDeaths = 0 end
                    sProfile = hClient:GetProfileId()
                    sTeam    = hClient:GetTeam()
                    if (g_sGameRules == INSTANT_ACTION) then sTeam = "1"
                    end
                    sPlayers = string.format("%s@%s%%%s%%%s%%%s%%%s%%%s", ToString(sPlayers), (ToString(sName)), ToString(sRank), ToString(sKills), ToString(sDeaths), ToString(sProfile), ToString(sTeam))
                    table.insert(aPlayers, {
                        name       = sName,
                        rank       = sRank,
                        kills      = sKills,
                        deaths     = sDeaths,
                        profile_id = sProfile,
                        team       = sTeam
                    })
                end

                for _, tConnection in pairs(Server.Network.ActiveConnections) do
                    if (not Server.Utils:GetPlayerByChannel(_) and ServerDLL.IsExistingChannel(_)) then
                        sName    = ("(Connecting) %s"):format(ServerDLL.GetChannelNick(_) or "Nomad")
                        sRank    = 0
                        sKills   = 0
                        sDeaths  = 0
                        sProfile = 0
                        sTeam    = 0
                        sPlayers = string.format("%s@%s%%%s%%%s%%%s%%%s%%%s", ToString(sPlayers), (ToString(sName)), ToString(sRank), ToString(sKills), ToString(sDeaths), ToString(sProfile), ToString(sTeam))
                        table.insert(aPlayers, {
                            name       = sName,
                            rank       = sRank,
                            kills      = sKills,
                            deaths     = sDeaths,
                            profile_id = sProfile,
                            team       = sTeam
                        })
                    end
                end

                if (Server.Network.Properties.UseJSONReport) then
                    return table.append(aPlayers, aPopulation)
                end

                return (sPlayers .. sPopulation)
            end,

            GetServerDescription = function(self)
                return CheckString(Server.Network.Properties.ServerInfo.Description, "No Description")
            end,

            GetServerPassword = function(self)
                local sPass = Server.Utils:GetCVar("sv_password")
                if (string.empty(sPass)) then
                    return "0"
                end
                return sPass
            end,

            GetMapTitle = function(self, sMap)
                local sForced = Server.Utils:GetCVar("server_maptitle")
                if (string.len(sForced) < 1 or sForced == "0") then
                    local sTitle = (string.match(string.lower(sMap), ".-/.-/(.*)") or sMap)
                    return string.capitalN(sTitle)
                end
                return sForced
            end,

            GetMapDownloadLink = function(self, sLevel)
                return (Server.Network.Properties.MapLinkList[string.lower((sLevel or ServerDLL.GetMapName()))] or "")
            end,

            GetServerPakLink = function(self)
                -- TODO: client-pak
                return ""
            end,

            ConvertFormatTags = function(self, sInput)
                local aMap = self.BoldCharMap
                local sResult = string.gsub(sInput, "<bold>(.-)</bold>", function(content)
                    return content:gsub(".", function(c)
                        return (aMap[c] or c)  -- Use the mapped character or keep the original if not found
                    end)
                end)
                return sResult
            end,

        },

        LoadMapLinks = function(self)

            local aLinks = {}
            local sDir = self.Properties.MapLinkDir
            local sFilter = self.Properties.MapLinkFile

            if (not ServerLFS.DirExists(sDir)) then
                return aLinks
            end

            local aMapLinkFiles = ServerLFS.DirGetFiles(sDir, GETFILES_FILES, sFilter)
            if (table.empty(aMapLinkFiles)) then
                return aLinks
            end

            local sType, sData, sName
            local hTemp
            local bOk, sErr
            for _, sFile in pairs(aMapLinkFiles) do

                sName = ServerLFS.FileGetName(sFile)
                sType = FileGetExtension(sFile)
                sData = FileRead(sFile)

                if (string.len(sData) > 0) then
                    if (sType == "lua") then
                        bOk, sErr = pcall(loadstring(sData))
                        if (IsArray(sErr)) then
                            for sMap, sLink in pairs(sErr) do
                                aLinks[string.lower(sMap)] = sLink
                            end
                        else self:LogError("Failed to read Map Link file %s (%s)", sName, ToString(sErr))
                        end
                    elseif (sType == "txt") then
                        for _, sLine in pairs(string.split(sData, "\n")) do
                            hTemp = { string.match(sLine, "(.-/../[^/]*) = (.*)") }
                            if (table.size(hTemp) == 2) then
                                aLinks[string.lower(hTemp[1])] = hTemp[2]
                            else self:LogError("[%d] Bad Line in Map Links file %s (%s)", _, sName, ToString(sErr))
                            end
                        end
                    elseif (sType == "json") then
                        hTemp = json.decode(sData)
                        if (IsArray(hTemp)) then
                            for _, aLink in pairs(hTemp) do
                                aLinks[string.lower(aLink.map)] = aLink.link
                            end
                        else self:LogError("Failed to read Map Link file %s (%s)", sName, ToString("Json Error"))
                        end
                    end
                end
            end
            return aLinks
        end,

        OnFrameLag = function(self, iFrameDiff, iRateAverage, iFPS, iActualFPS, sActualFPSDiff)
            --self:LogWarning("{Gray}Lag Spike Occurred {Red}%0.2f{Gray} ms ({Red}%0.2f{Gray} FPS) Steps: {Red}%s {Gray}({Red}%s{Gray})",
            --    iFrameDiff, iFPS, iActualFPS, sActualFPSDiff
            --)
        end,

        UpdatePingControl = function(self, hPlayer, iPing)

            local aPingControl = self.PingControl
            if (not aPingControl.Enabled) then
                return
            end

            if (aPingControl.IssuedWarnings[hPlayer.id] == nil) then
                aPingControl.IssuedWarnings[hPlayer.id] = { Timer = TimerNew(aPingControl.WarningDelay), Count = 0 }
                aPingControl.IssuedWarnings[hPlayer.id].Timer.expire()
            end

            local tWarning = aPingControl.IssuedWarnings[hPlayer.id]
            local iTolerance = aPingControl.Tolerance

            if (iPing > iTolerance) then
                if (tWarning.Timer.expired_refresh()) then
                    tWarning.Count = math.min(aPingControl.WarningLimit, (tWarning.Count + 1))
                    if (tWarning.Count >= aPingControl.WarningLimit) then
                        Server.Punisher:KickPlayer(Server:GetEntity(), hPlayer, ("Ping Limit (%d \\ %d)"):format(iPing, iTolerance))
                        return
                    else
                        Server.Chat:ChatMessage(ChatEntity_Server, hPlayer, "@ping_warning", { Count = tWarning.Count, Limit = aPingControl.WarningLimit, Ping = iPing, PingLimit = iTolerance })
                    end
                end
            elseif (aPingControl.ResetWarnings) then
                if (tWarning.Timer.expired_refresh() and tWarning.Count > 0) then
                    tWarning.Count = (tWarning.Count - 1)
                end
            end
        end,

        UpdateNetUsage = function(self)
            local aStatistics = ServerDLL.GetNetStatistics()
            local tNetThresholds = self.Properties.NetworkUsageWarningThresholds
            local bShowWarning = false
            local ColorUp = CRY_COLOR_GREEN
            local ColorDown = CRY_COLOR_GREEN
            local iUp = aStatistics.Up
            local iDown = aStatistics.Down

            if (iUp >= tNetThresholds.Up) then
                ColorUp = CRY_COLOR_RED
                bShowWarning = true
            end
            if (iDown >= tNetThresholds.Down) then
                ColorDown = CRY_COLOR_RED
                bShowWarning = true
            end
            local sNetUsageWarning = ("Up: %s%s{Gray}, Down: %s%s"):format(ColorUp, Server.Utils:ByteSuffix(iUp), ColorDown, Server.Utils:ByteSuffix(iDown))
            if (bShowWarning) then
                self:LogWarning("{Gray}Excessive Net Usage | " .. sNetUsageWarning)
            end

            local iCPUUsage = ServerDLL.GetCPUUsage() or 0
            sNetUsageWarning = ("CPU: %d%%, Net: ^%s v%s"):format(iCPUUsage, Server.Utils:ByteSuffix(iUp), Server.Utils:ByteSuffix(iDown))
            g_gameRules.game:SetSynchedGlobalValue(GLOBAL_SERVER_IP_KEY, sNetUsageWarning)

            local sServerName = Server.Utils:GetCVar("sv_servername")
            if (sServerName ~= self.LastServerName) then
                g_gameRules.game:SetSynchedGlobalValue(GLOBAL_SERVER_NAME_KEY, sServerName)
                self.LastServerName = sServerName
            end
        end,

        UpdateGamePings = function(self)

            if (self.Timers.PingUpdate.expired_refresh()) then

                self:UpdateNetUsage()

                local iAveragePing = 0
                local aPlayers = g_gameRules.game:GetPlayers()
                local iPlayerCount = #(aPlayers or {})

                if (iPlayerCount > 0) then
                    for _, hPlayer in ipairs(aPlayers) do
                        local iChannel = hPlayer and hPlayer.actor:GetChannel()
                        if (iChannel) then
                            local iPing = math.floor((g_gameRules.game:GetPing(iChannel) or 0) * 1000 + 0.5)
                            local iFinalPing = (iPing * self.Properties.PingMultiplier)

                            if (hPlayer.Initialized) then
                                hPlayer.Info.RealPing = iPing
                                hPlayer.Info.FakePing = iFinalPing
                            end

                            iAveragePing = (iAveragePing + iPing)
                            g_gameRules.game:SetSynchedEntityValue(hPlayer.id, g_gameRules.SCORE_PING_KEY, iFinalPing)
                            self:UpdatePingControl(hPlayer, iFinalPing)
                        end
                    end

                    iAveragePing = (iAveragePing / iPlayerCount)
                end

                local iThreshold = self.Properties.AveragePingWarningThreshold
                if (iAveragePing > iThreshold) then
                    if (self.Timers.PingWarning.expired_refresh()) then
                        self:LogEvent({
                            Message = "@average_ping_warning",
                            MessageFormat = { Average = iAveragePing, Threshold = iThreshold },
                            Recipients = ServerAccess_Admin,
                        })
                    end
                end

            end
        end,
    }
})