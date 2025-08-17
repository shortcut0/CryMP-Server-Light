-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- This file contains the Server Map Rotation Handler
-- ===================================================================================

Server:CreateComponent({
    Name = "MapRotation",
    Body = {

        ComponentPriority = PRIORITY_HIGHER,

        CCommands = {
            { Name = "next_map", FunctionName = "Command_NextMap", Description = "Starts the next level in the map rotation" },
            { Name = "previous_map", FunctionName = "Command_PreviousMap", Description = "Starts the previous level in the map rotation" },
            { Name = "end_game", FunctionName = "Command_EndGame", Description = "Ends the current game" },
        },


        Protected = {
            FirstInitialization = false
        },

        ChatEntity = "Map Rotation",

        Properties = {

            MapPathPatterns = {
                "^([^/]+)/([^/]+)/([^/]+)$",
                "^([^\\]+)\\([^\\]+)\\([^\\]+)$",
            },

            DefaultTimeLimit = ONE_HOUR,
            DefaultTimeLimits = {
                Other = ONE_HOUR,
                PowerStruggle = ONE_HOUR,
                InstantAction = ONE_HOUR
            },

            MaximumTimeLimit = ONE_DAY,

        },

        MapRules = {
            Long = {
                ia = "InstantAction",
                ps = "PowerStruggle"
            },
            Short = {
                powerstruggle = "ps",
                instantaction = "ia"
            }
        },

        MapList = {
            List = {},
            GetAll = function(this)
                local aResult = {}
                for _, aMaps in pairs(this.List) do
                    for __, tMap in pairs(aMaps) do
                        table.insert(aResult, tMap)
                    end
                end
                return aResult
            end,
            GetMap = function(this, sMap)
                for _, aMaps in pairs(this.List) do
                    for __, tMap in pairs(aMaps) do
                        if (tMap:GetPath() == sMap:lower()) then
                            return tMap
                        end
                    end
                end
                return
            end,
            FindMaps = function(this, sMap)
                local aResults = {}
                for _, aMaps in pairs(this.List) do
                    for __, tMap in pairs(aMaps) do
                        if (tMap:GetName():lower() == sMap:lower()) then
                            return { tMap }
                        elseif (tMap:GetName():lower():match(string.Escape(sMap:lower()))) then
                            table.insert(aResults, tMap)
                        end
                    end
                end
                return aResults
            end,
            Exists = function(this, sMap)
                local bIsPath = string.matchex(sMap, unpack(Server.MapRotation.Properties.MapPathPatterns))
                for _, aMaps in pairs(this.List) do
                    for __, tMap in pairs(aMaps) do
                        if (bIsPath) then
                            if (tMap:GetPath():lower() == sMap:lower()) then
                                return true
                            end
                        elseif (tMap:GetName():lower() == sMap:lower()) then
                            return true
                        end
                    end
                end
                return false
            end
        },
        ForbiddenMaps = {
        },

        Initialize = function(self)

            self.Properties.DeleteClientEntities = Server.Config:Get("MapConfig.DeleteClientEntities", true, ConfigType_Boolean)
            self.Properties.DefaultTimeLimits = Server.Config:Get("MapConfig.MapRotation.DefaultTimeLimits", {}, ConfigType_Array)
            self.Properties.DefaultTimeLimits.Default = (self.Properties.DefaultTimeLimit or ONE_HOUR)
            self:CollectMaps()
            self:InitRotation()

            self.FirstInitialization = true
        end,

        PostInitialize = function(self)
            if (self.Properties.DeleteClientEntities) then
                local iDeletedCount = 0
                local aDeletedClasses = {}
                for _, hEntity in pairs(System.GetEntities()) do
                    if (hEntity:HasFlags(ENTITY_FLAG_CLIENT_ONLY)) then
                        iDeletedCount = (iDeletedCount + 1)
                        if (not table.find_value(aDeletedClasses, hEntity.class)) then
                            table.insert(aDeletedClasses, hEntity.class)
                        end
                        System.RemoveEntity(hEntity.id)
                    end
                end
                self:Log("Deleted %d Client-Side Entities", iDeletedCount)
                self:Log("Classes: %s", table.concat(aDeletedClasses, ", "))
            end
        end,

        GetRawMapList = function(self)
            local aRawList = {}
            for _, aMaps in pairs(self.MapList.List) do
                for __, tMap in pairs(aMaps) do
                 table.insert(aRawList, tMap:GetPath())
                end
            end
            return aRawList
        end,

        GetMapList = function(self)
            local aRawList = {}
            for _, aMaps in pairs(self.MapList.List) do
                for __, tMap in pairs(aMaps) do
                    table.insert(aRawList, tMap)
                end
            end
            return aRawList
        end,

        InitRotation = function(self)

            local aMapConfig = Server.Config:Get("MapConfig", {}, ConfigType_Array)
            local aRotationConfig = (aMapConfig.MapRotation or {})

            local aRotationMapList = {}
            if (aRotationConfig.UseAvailableMaps) then
                for _, aMap in pairs(self:GetMapList()) do
                    table.insert(aRotationMapList, { Path = aMap:GetPath(), TimeLimit = aMap:GetDefaultTimeLimit() })
                end

            elseif (aRotationConfig.MapList) then
                for _, aMapInfo in pairs(aRotationConfig.MapList) do
                    if (aMapInfo.Enabled ~= false and aMapInfo.Enabled ~= 0) then
                        table.insert(aRotationMapList, { Path = aMapInfo.Path, TimeLimit = self:GetDefaultTimeLimit(aMapInfo.Path) })
                    end
                end

            else
                aRotationMapList = {
                    Path = ServerDLL.GetMapName(), TimeLimit = self:GetDefaultTimeLimit(ServerDLL.GetMapName())
                }
            end

            self.MapRotation = self:CreateRotation(aRotationMapList, { Shuffle = aRotationConfig.ShuffleRotation })
            if (not ServerDLL.GetMapName()) then
                self.MapRotation:StartCurrent()
            end
        end,

        CreateRotation = function(self, aMapList, tInfo)

            local aRotation = {
                List     = {},
                NextList = nil,
                Current = 1,
                Last    = 1,
                LastMap = "",
                Shuffle = (tInfo.Shuffle),

                IsEmpty      = function(this) return (this.Last == 1) end,
                Next         = function(this)
                    this.Current = this.Current + 1
                    if (this.Current > this.Last) then
                        this:Reset()
                    end
                    if (this.Last >= 2 and this.List[this.Current].Map:GetPath() == this.LastMap) then
                        this:Next()
                    end
                end,
                Reset        = function(this) this.Current = 1 if (this.Shuffle) then this.List = (this.NextList or table.shuffle(this.List)) end end,
                QueueReset   = function(this)
                    if (this.Shuffle) then
                        -- keep the old NextList
                        this.NextList = this.NextList or table.shuffle(this.List)
                    end
                end,
                GetNext      = function(this)
                    local iNext = this.Current + 1
                    if (iNext > this.Last) then
                        if (this.Shuffle) then
                            this:QueueReset()
                            return this.NextList[iNext].Map
                        end
                        iNext = 1
                    end
                    return this.List[iNext].Map
                end,
                StartNext    = function(this)
                    this:Next()
                    this:StartCurrent()
                end,
                StartCurrent = function(this)
                    local tMap = this.List[this.Current]
                    this.LastMap = tMap.Map:GetPath()
                    Server.MapRotation:StartMap(tMap.Map:GetPath(), tMap.Map:GetRules(), tMap.TimeLimit)
                end,
            }

            for _, aMapInfo in pairs(aMapList) do
                if (self.MapList:Exists(aMapInfo.Path)) then
                    local tMap = self.MapList:GetMap(aMapInfo.Path)
                    local iTimeLimit = tMap:GetDefaultTimeLimit()
                    if (tInfo.TimeLimit) then
                        iTimeLimit = Date:ParseTime(tInfo.TimeLimit)
                    end
                    table.insert(aRotation.List, { Map = tMap, TimeLimit = iTimeLimit })
                else
                    self:LogError("Invalid Map in Rotation list! Removed '%s'", aMapInfo.Path)
                end
            end

            aRotation.Last = #aRotation.List
            aRotation:Reset()
            self:Log("Initialized Map Rotation with %d Maps", aRotation.Last)
            return aRotation
        end,

        GetDefaultTimeLimit = function(self, sPath)
            local sType, sMode, sName = string.matchex(sPath, unpack(self.Properties.MapPathPatterns))
            local sKey = "Other"
            if (sType and sMode and sName) then
                sKey = ((self.MapRules.Long)[sMode:lower()] or "Other")
            end
            return self.Properties.DefaultTimeLimits[sKey] or self.Properties.DefaultTimeLimit
        end,

        CollectMaps = function(self)

            self.ForbiddenMaps = {}
            for sMode, aMaps in pairs(Server.Config:Get("MapConfig.ForbiddenMaps", {}, ConfigType_Array)) do
                self.ForbiddenMaps[sMode] = {
                    DisableAll = false,
                    List = {},
                }
                if (IsArray(aMaps)) then
                    for sMap, _ in pairs(aMaps) do
                        if (IsString(sMap)) then
                            table.insert(self.ForbiddenMaps[sMode].List, self:ResolveMapPath(sMap, sMode))
                        elseif (sMap == "DisableAll") then
                            self.ForbiddenMaps[sMode].DisableAll = true
                        end
                    end
                end
            end

            self.MapList.List = {}
            for _, tLevel in pairs(ServerDLL.GetLevels()) do
                local sType, sMode, sName = string.matchex(tLevel[1], unpack(self.Properties.MapPathPatterns))
                if (sType and sMode and sName) then
                    self.MapList.List[sMode] = (self.MapList.List[sMode] or {})
                    table.insert(self.MapList.List[sMode], {
                        Path  = tLevel[1]:lower(),
                        Name  = sName,
                        Rules = sMode:lower(),
                        Type  = sType:lower(),
                        Forbidden = self:IsMapForbidden(tLevel[1]),
                        GetPath  = function(this) return this.Path end,
                        GetName  = function(this) return this.Name end,
                        GetRules = function(this) return this.Rules end,
                        GetType  = function(this) return this.Type end,
                        GetLongRules = function(this) return Server.MapRotation:GetLongRules(this:GetPath()) end,
                        IsForbidden = function(this) return Server.MapRotation:IsMapForbidden(this:GetPath())  end,
                        GetDefaultTimeLimit = function(this) return Server.MapRotation:GetDefaultTimeLimit(this:GetPath()) end
                    })
                end
            end

        end,

        GetLongRules = function(self, sPath)
            local sType, sMode, sName = string.matchex(sPath, unpack(self.Properties.MapPathPatterns))
            if (sType and sMode and sName) then
                return ((self.MapRules.Long)[sMode:lower()] or "Unknown")
            end
            return ((self.MapRules.Long)[sPath:lower()] or "Unknown")
        end,

        GetShortRules = function(self, sPath)
            local sType, sMode, sName = string.matchex(sPath, unpack(self.Properties.MapPathPatterns))
            if (sType and sMode and sName) then
                return ((self.MapRules.Short)[sMode:lower()] or "Unknown")
            end
            return ((self.MapRules.Short)[sPath:lower()] or "Unknown")
        end,

        ResolveMapPath = function(self, sPath, sGameRules)
            local sType, sMode, sName = string.matchex(sPath, unpack(self.Properties.MapPathPatterns))
            if (sType and sMode and sName) then
                return sPath
            end

            local sFixedPath = ("multiplayer/" .. self:GetShortRules(sGameRules) .. "/" .. sPath)
            return sFixedPath
        end,

        IsMapForbidden = function(self, sPath)
            for sMode, aMaps in pairs(self.ForbiddenMaps) do
                if (aMaps.DisableAll) then
                    return true
                end
                for sMap in pairs(aMaps) do
                    if (IsString(sMap) and sMap:lower() == sPath) then
                        return true
                    end
                end
            end
            return false
        end,

        GetNextMapName = function(self)
            local tNextMap = self.MapRotation:GetNext()
            return tNextMap:GetName()
        end,

        GetNextMapPath = function(self)
            local tNextMap = self.MapRotation:GetNext()
            return tNextMap:GetPath()
        end,

        GetNextMapRules = function(self, bLong)
            local tNextMap = self.MapRotation:GetNext()
            return (bLong and tNextMap:GetLongRules() or tNextMap:GetRules())
        end,

        GetMapName = function(self)
            local sType, sMode, sName = string.matchex(ServerDLL.GetMapName(), unpack(self.Properties.MapPathPatterns))
            if (sType and sMode and sName) then
                return sName
            end
        end,

        GetMapPath = function(self)
            return ServerDLL.GetMapName() or "Unknown"
        end,

        CanStartNextLevel = function(self)

            if (not self.Properties.RotationEnabled) then
            --    return true -- Let C++ handle it
            end

            if (self.MapRotation:IsEmpty()) then
                self:Log("Rotation is Empty, Restarting Current Map")
                self.MapRotation:Restart()
                return false -- We will handle it here
            end

            self:Log("Starting Next Map")
            self.MapRotation:StartNext()
            return false -- We will handle it here
        end,

        StartMap = function(self, sPath, sRules, iTimeLimit)

            self.MapStartTimer = nil
            self.NextMapTimer = nil


            Script.SetTimer(1, function()
                self:Log("Starting Map '%s'", sPath)
                Server.Utils:SetCVar("g_timeLimit", tostring(iTimeLimit / 60))
                Server.Utils:SetCVar("sv_gameRules", sRules)
                Server.Utils:ExecuteCommand("map " .. sPath)
            end)
        end,

        GetMiniMap = function(self)

            local aMiniMaps = self.CachedMiniMaps
            local sMapPath = self:GetMapPath()
            if (aMiniMaps == nil or sMapPath ~= self.LastMiniMapPath) then
                local sMapXML = ("levels/%s/%s.xml"):format(ServerDLL.GetMapName(), Server.MapRotation:GetMapName())
                self.CachedMiniMaps = ServerDLL.GetMiniMapBBox(sMapXML)
                aMiniMaps = self.CachedMiniMaps
            end

            self.LastMiniMapPath = sMapPath
            return table.copy((aMiniMaps or {})[1] or {})
        end,

        SetTimeLimit = function(self, sDuration)
            local iMinutes = math.max(0, math.min((self.Properties.MaximumTimeLimit / 60), Date:ParseTime(sDuration) / 60))
            Server.Utils:SetCVar("g_timelimit", iMinutes)
            g_gameRules.game:ResetGameTime()
        end,

        ListMapsToConsole = function(self, hPlayer, sFilter, aMaps)

            ----------
            local aList = aMaps
            if (not aList) then
                aList = self.MapList:GetAll()
                if (table.countRec(aList) == 0) then
                    return false, hPlayer:LocalizeText("@no_maps_found")
                end
            end

            local sTypeFilter
            sFilter = string.lower(sFilter or "")
            if (string.findex(sFilter, "po", "pow", "power", "power+struggle")) then
                sTypeFilter = "ps"
                sFilter = nil
            elseif (string.findex(sFilter, "ins", "inst", "instant", "instant+action", "action", "iaction")) then
                sTypeFilter = "ia"
                sFilter = nil
            end

            ----------
            local aPrintableList = {}
            local iMatchingMaps = 0

            for _, tMap in pairs(aList) do
                local sMapType = tMap:GetRules()
                if (aPrintableList[sMapType] == nil) then
                    aPrintableList[sMapType] = {}
                end

                if (string.empty(sTypeFilter) or sMapType:lower() == sTypeFilter) then
                    table.insert(aPrintableList[sMapType], tMap)
                    iMatchingMaps = iMatchingMaps + 1
                end
            end

            if (iMatchingMaps == 0) then
                if (not sTypeFilter) then
                    return false, hPlayer:LocalizeText("@no_maps_found")
                end
                return false, hPlayer:LocalizeText("@no_maps_foundOfType", { Type = self:GetLongRules(sTypeFilter) })
            end

            local iDisplayedMaps = 0
            local iLineWidth = Server.Chat:GetConsoleWidth()
            local iMapNameWidth = 25
            for sType, tMapList in pairs(aPrintableList) do

                local iIndex = 0
                local iCounter = 0
                local iMapCount = #(tMapList)
                local sLine = "     "

                Server.Chat:ConsoleMessage(hPlayer, " ")
                Server.Chat:ConsoleMessage(hPlayer, "$9" .. string.mspace(" [ ~ $4" .. self:GetLongRules(sType) .. "$9 ~ ] ", iLineWidth, nil, string.COLOR_CODE, "="))
                Server.Chat:ConsoleMessage(hPlayer, " ")


                for _, tMap in pairs(tMapList) do

                    local bDisplay = true
                    local sMapName = tMap:GetName()
                    if (sFilter ~= "") then
                        local iStart, iEnd = string.find(sMapName:lower(), sFilter:lower())
                        if (iStart) then
                            sMapName = ("$9%s$6%s$9%s"):format((sMapName:sub(1, iStart - 1)), (sMapName:sub(iStart, iEnd)):upper(), (sMapName:sub(iEnd + 1)))
                        else
                            bDisplay = false
                        end
                    end

                    if (bDisplay) then
                        iIndex = iIndex + 1
                        iCounter = iCounter + 1
                        iDisplayedMaps = iDisplayedMaps + 1

                        local sMapColor = "$9"
                        local sMapPath = tMap:GetPath()
                        local bHasLink = (Server.Network.Properties.MapLinkList[string.lower(sMapPath)] ~= nil)
                        if (self:IsMapForbidden(sMapPath)) then
                            sMapColor = "$4"
                        elseif (not bHasLink) then
                            sMapColor = "$6"
                        end

                        sLine = sLine .. "$1" .. string.lspace(iCounter, 2, nil, " ") .. ") " .. sMapColor .. sMapName .. string.rep(" ", iMapNameWidth -
                                string.len(string.gsub(sMapName, string.COLOR_CODE, "")))

                        if (iIndex >= 4 or iIndex == iMapCount) then
                            Server.Chat:ConsoleMessage(hPlayer, sLine)
                            sLine = "     "
                            iIndex = 0
                        end
                    end
                end
            end

            Server.Chat:ConsoleMessage(hPlayer, " ")
            Server.Chat:ConsoleMessage(hPlayer, "     $9" .. hPlayer:LocalizeText("@map_list_info1"))
            Server.Chat:ConsoleMessage(hPlayer, "$9================================================================================================================")
            return true, hPlayer:LocalizeText("@entitiesListedInConsole", { Class = "@maps", Count = iDisplayedMaps })
        end,

        Command_SetTimeLimit = function(self, hAdmin, sDuration)

            local iTime = math.max(0, math.min(self.Properties.MaximumTimeLimit, Date:ParseTime(sDuration)))
            local tFormat = { Time = Date:Colorize(Date:Format(iTime, DateFormat_Cramped)), Admin = hAdmin:GetName() }
            Server.Chat:ChatMessage(self.ChatEntity, ALL_PLAYERS, "@map_timeLimit_changed", tFormat)
            self:LogEvent({
                Message = "@map_timeLimit_changed",
                MessageFormat = tFormat
            })

            self:SetTimeLimit(iTime)
        end,

        Command_RestartMap = function(self, hPlayer, iTimer)

            if (iTimer and iTimer > 0) then
                if (self.MapRestartTimer) then
                    Script.KillTimer(self.MapRestartTimer)
                end

                local tFormat = { Time = Date:Format(iTimer) }
                self:LogEvent({ Message = "@map_restarting", MessageFormat = tFormat })
                Server.Chat:ChatMessage(self.ChatEntity, ALL_PLAYERS, "@map_restarting", tFormat)
                self.MapRestartTimer = Script.SetTimer(iTimer * 1000, function()
                    Server.Utils:ExecuteCommand("sv_restart", hPlayer)
                end)
                return
            end

            Server.Utils:ExecuteCommand("sv_restart", hPlayer)
        end,

        Command_StartMap = function(self, hPlayer, sMap, iTimer)

            hPlayer = (hPlayer or Server:GetEntity())
            iTimer = math.max(5, (iTimer or 0))
            sMap = sMap or ""

            if (not sMap) then
                self:ListMapsToConsole(hPlayer)
                return true
            end

            local sMapLower = sMap:lower()
            if (sMapLower == "stop") then
                if (not self.MapStartTimer) then
                    self:LogEvent({ Message = "@no_map_start_stopped" })
                    return false, "@no_map_start_stopped"
                end

                Script.KillTimer(self.MapStartTimer)
                self.MapStartTimer = nil
                self:LogEvent({ Message = "@map_start_stopped" })
                Server.Chat:ChatMessage(self.ChatEntity, ALL_PLAYERS, "@map_start_stopped")
                return true--, "@map_start_stopped"
            end

            local aMapResults = self.MapList:FindMaps(sMap)
            if (#aMapResults == 0) then
                return false, hPlayer:LocalizeText("@map_not_found", { Map = sMap })

            elseif (#aMapResults > 1) then
                --self:ListMapsToConsole(hPlayer, sMap)
                return self:ListMapsToConsole(hPlayer, sMap)
            end


            local tMap = aMapResults[1]
            if (iTimer > 0) then
                iTimer = math.max(iTimer, 5)
                if (self.MapStartTimer) then
                    Script.KillTimer(self.MapStartTimer)
                    self.MapStartTimer = nil
                end
                self.MapStartTimer = Script.SetTimer((iTimer * 1000), function()
                    self:StartMap(tMap:GetPath(), tMap:GetRules(), tMap:GetDefaultTimeLimit())
                end)

                local aFormat = { Next = "",Time = Date:Format(iTimer), Mode = tMap:GetRules():upper(), Map = tMap:GetName() }
                self:LogEvent({ Message = "@map_start_queued" , MessageFormat = aFormat })
                Server.Chat:ChatMessage(self.ChatEntity, ALL_PLAYERS, "@map_start_queued", aFormat)
                return true--, hPlayer:LocalizeText()
            end

            self:StartMap(tMap:GetPath(), tMap:GetRules(), tMap:GetDefaultTimeLimit())
            return true
        end,

        Command_NextMap = function(self, iTimer, hPlayer)

            hPlayer = (hPlayer or Server:GetEntity())

            if (iTimer == "stop") then
                if (not self.NextMapTimer) then
                    self:LogEvent({ Message = "@no_map_start_stopped" })
                    return false, "@no_map_start_stopped"
                end

                Script.KillTimer(self.NextMapTimer)
                self.NextMapTimer = nil
                self:LogEvent({ Message = "@map_start_stopped" })
                Server.Chat:ChatMessage(self.ChatEntity, ALL_PLAYERS, "@map_start_stopped")
                return true--CommandResp_SuccessQuiet, hPlayer:LocalizeText("@map_start_stopped")
            else
                iTimer = Date:ParseTime(iTimer) or 0
            end

            if (iTimer > 0) then
                iTimer = math.min(math.max(iTimer, 5), 59)
                if (self.NextMapTimer) then
                    Script.KillTimer(self.NextMapTimer)
                end
                self.NextMapTimer = Script.SetTimer((iTimer * 1000), function()
                    self.MapRotation:StartNext()
                end)

                local tMap = self.MapRotation:GetNext()
                local aFormat = { Next = "@next ", Time = Date:Format(iTimer), Mode = tMap:GetRules():upper(), Map = tMap:GetName() }
                self:LogEvent({ Message = "@map_start_queued" , MessageFormat = aFormat })
                Server.Chat:ChatMessage(self.ChatEntity, ALL_PLAYERS, "@map_start_queued", aFormat)
                return-- CommandResp_SuccessQuiet, hPlayer:LocalizeText("@map_start_queued", aFormat)
            end

            self.MapRotation:StartNext()
            return true
        end,


    }
})