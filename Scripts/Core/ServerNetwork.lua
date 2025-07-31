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

        SaveToFile = {
            { Key = "SavedGeoData", Name = "GeoData.lua", Path = SERVER_DIR_DATA }
        },

        Protected = {
            SavedGeoData = {},
            ChannelCache = {},
            ActiveQueries = {},
            ActiveConnections = {},
        },

        Properties = {

            GeoService = "http://ip-api.com/json/{Query}?fields=3854107",

            MasterServerAPI     = ServerDLL.GetMasterServerAPI(),
            MasterServerTimeout = 30, -- timeout for connection attempts

            Headers = {
                JSON    = { ["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8" },
                Default = { ["Content-Type"] = "application/json" },
            },

            EndPoints = {
                Register = "/reg.php",
                Updater  = "/up.php,"
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
            CountryName   = "Crysisville",
            CountryCode   = "CS",
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

        Cookie = nil, -- Session ID
        IsRegistered = false,
        IsRegistering = false, -- In the process of registering the server
        RegisterFailed = false,

        IsUpdating = false,
        UpdateFailed = false,

        TimerUpdate = TimerNew(0),
        TimerUpdateFail = TimerNew(0),
        TimerRegisterFail = TimerNew(0),

        Initialize = function(self)

            local aMapLinks = self:LoadMapLinks()
            self.Properties.MapLinkList = aMapLinks
            self:Log("Imported %d Map-Links", table.size(aMapLinks))

            self.TimerRegisterFail.setexpiry(self.Properties.RecoveryInterval)
            self.TimerUpdateFail.setexpiry(self.Properties.RecoveryInterval)
            self.TimerUpdate.setexpiry(self.Properties.UpdateInterval)

            self:Log("Initialized")
        end,

        PostInitialize = function(self)
        end,

        OnChannelCreated = function(self, iChannel)

            local sIPAddress = "77.200.75.23" or ServerDLL.GetChannelIP(iChannel)
            local sNickname = ServerDLL.GetChannelNick(iChannel)
            local aGeoInfo = self:GetGeoInfo(sIPAddress, iChannel)

            local sCountryName = aGeoInfo.CountryName
            local sCountryCode = aGeoInfo.CountryCode

            self.ChannelCache[iChannel] = {
                IPAddress = sIPAddress,
                NickName  = sNickname,
                GeoInfo   = aGeoInfo
            }

            -- This if kind of redundant, but for the sake of readability we shall step into Thors Region here!
            self.ActiveConnections[iChannel] = {
                Timer    = TimerNew(),
                NickNick = sNickname,
            }

            self:Log("Created Channel %d with Name %s$9 (IP: %s, Country: [%s] %s)", iChannel, sNickname, sIPAddress, sCountryCode, sCountryName)
            self:LogEvent(ServerLogEvent_Network, [[channel_created]], { Channel = iChannel, Nick = sNickname, IP = sIPAddress, CountryCode = sCountryCode, Country = sCountryName })
        end,

        OnChannelDisconnect = function(self, iChannel)

            -- Channels NEVER decrement, so this is fine
            self.ActiveConnections[iChannel] = nil
            self.ChannelCache[iChannel]      = nil
            self.ActiveQueries[iChannel]     = nil
        end,

        GetGeoInfo = function(self, sIPAddress, iChannel)

            -- Assumable an NPC
            if (iChannel == 0) then
                return table.copy(self.DefaultGeoData)
            end

            local aGeoInfo = self.SavedGeoData[sIPAddress]
            if (aGeoInfo) then

                -- If somehow some default data snuck into the database
                if (aGeoInfo.IsDefault) then
                    self:QueryGeoData(sIPAddress, iChannel)
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
                self:OnGeoDataReceived(sIPAddress, iChannel, ...)
            end)
        end,

        OnGeoDataReceived = function(self, sIPAddress, iChannel, sError, sResponse, iCode)

            self.ActiveQueries[sIPAddress] = nil

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

            local hPlayer = Server.Utils.GetPlayerByChannel(iChannel)
            if (hPlayer) then
                hPlayer.Info.GeoData = self.SavedGeoData[sIPAddress]
            end
            self:Log("Queried Info for %s | Country: %s, Continent: %s, City: %s, ISP: %s", sIPAddress, aGeoData.CountryName, aGeoData.ContinentName, aGeoData.City, aGeoData.ISP)
        end,

        ExtractCookie = function(self, sMessage)
            return (string.match(sMessage, "^<<Cookie>>(.*)<<$"))
        end,

        Event_TimerSecond = function(self)

            if (not self.Initialized) then
                return
            end

            if (not self.IsRegistered) then
                if (self.RegisterFailed) then
                    if (not self.TimerRegisterFail.expired()) then
                        return
                    end
                end
                if (self.IsRegistering) then
                    return
                end

                return self:RegisterServer()
            end

            if (self.UpdateFailed) then
                if (not self.TimerUpdateFail.expired()) then
                    return
                end
                return self:UpdateServer()
            end
            if (self.TimerUpdate.expired_refresh()) then
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

            self.TimerRegisterFail.refresh()

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

            self.Exposed = true
            self.ExposedSuccess = false

            self:Log("Registering Server at %s...", (self.Properties.MasterServerAPI .. self.Properties.EndPoints.Register))
        end,

        OnUpdated = function(self, sError, sResponse, iCode)

            self.UpdateFailed = true
            self.IsUpdating  = false

            self.TimerUpdateFail.refresh()

            if (iCode ~= 200) then
                return self:LogError("Update Request failed with Code %d (%s)", CheckNumber(iCode), ToString(sResponse))
            end

            if (sResponse == "FAIL") then
                return self:LogError("Failed to Update the Server.")
            end

            self.UpdateFailed = false
            self:Log("Successfully Updated!")
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
                url = (self.Properties.MasterServerAPI .. self.Properties.EndPoints.Updater),
                method = "POST",
                body = sBody,
                headers = aHeaders,
                timeout = self.Properties.MasterServerTimeout,
            }, function(...)
                self:OnUpdated(...)
            end)

            self.Exposed = true
            self.ExposedSuccess = false

            self:Log("Updating Server Info at %s", (self.Properties.MasterServerAPI .. self.Properties.EndPoints.Updater))
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
                local sName         = Server.Utils.GetCVar("sv_servername")
                local sPakLink      = self:GetServerPakLink()
                local sDesc         = self:ConvertFormatTags(self:GetServerDescription())
                local sLocal        = "localhost"
                local sVersion      = Server.Network.Properties.ServerInfo.GameVersion
                local sPass         = (self:GetServerPassword() == "0" and "0" or "1")

                -- Map Config
                local iDirectX10    = 1
                local sMapName      = ServerDLL.GetMapName()
                local sMapTitle     = self:GetMapTitle(sMapName)
                local sMapDownload  = self:GetMapDownloadLink()
                local iTimeLeft     = (g_pGame:GetRemainingGameTime())

                -- Player Config
                local iMaxPlayers   = Server.Utils.GetCVar("sv_maxPlayers")
                local hPlayerList   = self:GetPlayers()
                local iPlayerCount  = table.count(hPlayerList)
                if (IsString(hPlayerList)) then
                    iPlayerCount    = string.count(hPlayerList, "@")
                end

                -- Net Config
                local iPort         = Server.Utils.GetCVar("sv_port")
                local iPublicPort   = Server.Utils.GetCVar("sv_port")
                local bGameSpy      = "0"

                -- General Config
                local iVoiceChat    = Server.Utils.GetCVar("net_enable_voice_chat") >= 1
                local iIsDedicated  = (ServerDLL.IsDedicated() and 1 or 0)
                local iAntiCheat    = ToString(Server.Utils.GetCVar("sv_cheatprotection"))
                local iGPOnly       = "0" -- FIXME
                local iFriendlyFire = ToString(Server.Utils.GetCVar("g_friendlyFireRatio"))
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
                    table.insert(aTemp, ToString(i) .. "=" .. ServerDLL.URLEncode(ToString(v)))
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
                        if (g_sGameRules == INSTANT_ACTION) then sTeam = "1"
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

                for _, hClient in pairs(Server.Utils.GetPlayers()) do
                    sName    = ServerNames:RemoveCrypt(hClient:GetName())
                    sRank    = hClient:GetRank()
                    sKills   = hClient:GetKills() if (sKills < 0) then sKills = 0 end
                    sDeaths  = hClient:GetDeaths()  if (sDeaths < 0) then sDeaths = 0 end
                    sProfile = hClient:GetProfileID()
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

                -- TODO: INCOMING CONNECTIONS !!

                if (Server.Network.Properties.UseJSONReport) then
                    return table.append(aPlayers, aPopulation)
                end

                return (sPlayers .. sPopulation)
            end,

            GetServerDescription = function(self)
                return CheckString(Server.Network.Properties.ServerInfo.Description, "No Description")
            end,

            GetServerPassword = function(self)
                local sPass = Server.Utils.GetCVar("sv_password")
                if (string.empty(sPass)) then
                    return "0"
                end
                return sPass
            end,

            GetMapTitle = function(self, sMap)
                local sForced = Server.Utils.GetCVar("server_maptitle")
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
    }
})