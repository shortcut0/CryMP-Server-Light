-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- This is the Main Server Script File
-- ===================================================================================

local ComponentData = {}
--local iFullInitStart, bIsFullInitializing
if (Server) then
    for sComponent, aKeys in pairs(Server.ComponentData) do
        ComponentData[sComponent] = {}
        for sKey in pairs(aKeys) do
            if (Server[sComponent]) then
                ComponentData[sKey] = Server[sComponent][sKey]
            end
        end
    end
    ComponentData = Server.ComponentData
    --iFullInitStart, bIsFullInitializing = Server.FullInitializationStart, Server.IsFullInitializing
end

---@class Server
Server = {

    Properties = {
        ServerEntityName = "CryMP-Server",
    },

    FrameCounters = {},


    PreInitializeList = {}, -- A list of functions to call before Initializing
    InitializeList = {},    -- A list of functions to call upon Initializing
    PostInitializeList = {},-- A list of functions to call upon Post-Initializing

    ComponentList           = {}, -- A list of to be added Components
    ComponentData           = ComponentData,
    ComponentExternal       = {},
    InitializedComponents   = {}, -- A list of Initialized Components

    Initialized = false,
    PostInitialized = false,

    FullInitializationStart = iFullInitStart,
    IsFullInitializing = bIsFullInitializing
}

----------------------------------
--- Called Immediately
Server.Initialize = function(self)

    ServerDLL.SetScriptErrorLog(true)

    SCRIPT_ERROR = true
    LOG_STARS    = (string.rep("*", 40))

    -----
    MOD_RAW_NAME = ("CryMP-Server")
    MOD_EXE_NAME = (MOD_RAW_NAME .. ".exe")
    MOD_NAME     = (MOD_RAW_NAME .. " x" .. CRYMP_SERVER_BITS)
    MOD_VERSION  = ("v" .. CRYMP_SERVER_VERSION)
    MOD_BITS     = CRYMP_SERVER_BITS
    MOD_COMPILER = CRYMP_SERVER_COMPILER

    -----
    ServerLog(LOG_STARS .. LOG_STARS)
    ServerLog("Initializing Script..")

    -----
    SERVER_ROOT       = ServerDLL.GetRoot()
    SERVER_DIR        = ServerDLL.GetRoot()
    SERVER_WORKINGDIR = ServerDLL.GetWorkingDir()

    -----
    SERVER_DIR_LOGS     = (SERVER_ROOT .. "\\Logs\\")            -- Server Logs
    SERVER_DIR_LOGS_OLD = (SERVER_DIR_LOGS .. "\\Retired\\")     -- Retired Server Logs
    SERVER_DIR_DATA     = (SERVER_ROOT .. "\\Data\\")            -- Server Data (Bans, Mutes, Warns, etc)
    SERVER_DIR_CONFIG   = (SERVER_ROOT .. "\\Config\\")          -- Server Configuration
    SERVER_DIR_SCRIPTS  = (SERVER_ROOT .. "\\Scripts\\")         -- Scripts (Commands, Plugins, etc)
    SERVER_DIR_LIBS     = (SERVER_DIR_SCRIPTS .. "Libraries\\")       -- Library (3rd party scripts)
    SERVER_DIR_UTILS    = (SERVER_DIR_SCRIPTS .. "Utils\\")       -- Library (3rd party scripts)
    SERVER_DIR_CORE     = (SERVER_DIR_SCRIPTS .. "Components\\")       -- Component Scripts (Scripts the server depends on)
    SERVER_DIR_INTERNAL = (SERVER_DIR_SCRIPTS .. "Internal\\")   -- Internal Scripts (Scripts the server relies on)
    SERVER_DIR_COMMANDS = (SERVER_DIR_SCRIPTS .. "Commands\\")   -- Commands
    SERVER_DIR_PLUGINS  = (SERVER_DIR_SCRIPTS .. "Plugins\\")    -- Plugins

    self.InitializeStart = os.clock()
    self.FullInitializationStart = os.clock()
    self.IsFullInitializing = true

    self:CreateComponentFunctions(self.ErrorHandler, "ErrorHandler")
    self:CreateComponentFunctions(self.FileLoader, "FileLoader")

    self.Logger:Initialize()
    self.ErrorHandler:Initialize()
    if (not self.FileLoader:Initialize()) then
        ServerLogFatal("FileLoader Failed to Initialize!")
        return false
    end

    -----

    if (self:CreateComponents() == false) then
        return false
    end

    if (self:ConfigureComponents() == false) then
        return false
    end

    if (self:InitializeComponents() == false) then
        return false
    end

    self.Events:Call(ServerScriptEvent_OnInit)
    self.Initialized = true
    ServerLog("Script Fully Initialized!")
    return true
end

----------------------------------
--- Called when g_gameRules exists
Server.PostInitialize = function(self)

    ServerLog("Post-Initializing..")

    local iPostInitStart = os.clock()
    local iFullInitStart = self.FullInitializationStart
    self.Chat:ChatMessage(ChatEntity_Server, ChatType_ToAll, "@post_initialization_start")
    self.Logger:LogEvent({ Event = "Server", Message = ("@post_initialization_start"), Recipients = self.Utils:GetPlayers() })

    -- Something went wrong. Either mad failed to load or is being accesses by a different process.
    if (not g_gameRules) then
        ServerLogFatal(LOG_STARS .. LOG_STARS)
        ServerLogFatal("PostInitialize called without GameRules!")
        ServerLogFatal("Either the Map Failed to Load, does not exist, or its currently opened by a different process.")
        return false
    end

    self.ErrorHandler:PostInitialize()
    if (not self.FileLoader:PostInitialize()) then
        ServerLogError("FileLoader Failed to Post-Initialize!")
        return false
    end

    -- -: Move this
    --g_sGameRules = g_gameRules.class
    --g_pGame = g_gameRules.game

    if (self:PostInitializeComponents() == false) then
        return false
    end

    self:CheckServerEntity()
    self.Logger:PostInitialize()
    self.Events:Call(ServerScriptEvent_OnPostInit)

    self.PostInitialized = true

    self.Logger:LogEvent({
        Event = "Server",
        Message = ("@post_initialization_time"),
        MessageFormat = { Time = Date:Format(os.clock() - iPostInitStart) },
        Recipients = self.Utils:GetPlayers()
    })
    if (self.IsFullInitializing) then
        self.Logger:LogEvent({
            Event = "Server",
            Message = ("@initialization_time"),
            MessageFormat = { Time = Date:Format(os.clock() - iFullInitStart) },
            Recipients = self.Utils:GetPlayers()
        })
        self.IsFullInitializing = false
    end

    self:ReadConfig()
    ServerLog("Script Fully Post-Initialized")
    return true
end

----------------------------------
--- Happens before Initialization
Server.PreInitialize = function(self)

    self:ExportComponentData()
    ServerLog("Script Pre-Initializing Components...")
    for sComponent, hFunction in pairs(self.PreInitializeList) do
        local bOk, sError = pcall(hFunction, self[sComponent])
        if (bOk == false) then -- (not bOk) -- No, we are not PirateSoftware, but we don't want 'nil' returns to cause mayhem!
            ServerLogFatal("Failed to Pre-Initialize Component '%s'", sComponent)
            ServerLogFatal("> %s", (sError or "<Null>"))
            return false
        end
    end

    return true
end

----------------------------------
Server.ReadConfig = function(self)

    ServerLog("Reading Config...")
    self.Utils:SetCVar("sv_serverName", self.Logger:FormatTags(self.Config:Get("Server.ServerName", "CryMP-Server")))
end

----------------------------------
Server.OnMapCommand = function(self)
    self:OnReset()
    self:ExportComponentData()
    self.Events.Callbacks:OnMapCommand()
end

----------------------------------
Server.OnLoadingStart = function(self)
end

----------------------------------
Server.OnGameRulesSpawn = function(self)

    -- This function will be called right as the game rules are spawning, so
    -- this looks like a good place to start the resetting process
    -- Edit: It's not good, by this point player's don't even exist anymore!
    -- self:OnReset()

end

----------------------------------
Server.OnReset = function(self)

    ServerLog("Resetting ..")
    for _, aComponent in pairs(self.ComponentList) do
        local sComponent = aComponent.Name
        local fResetFunc = self[sComponent].OnReset
        if (fResetFunc) then
            local bOk, sError = pcall(fResetFunc, self[sComponent])
            if (not bOk) then
                self:LogFatal("Failed to Reset Component '%s'", sComponent)
                self:LogFatal("%s", (sError or "<Null>"))
                self:LogFatal("Aborting to Preserve Component Data")
                return false
            end
        end
    end
end

----------------------------------
Server.GetEntity = function(self)

    self:CheckServerEntity()
    if (not self.ServerEntity or not self.ServerEntity.id) then
        return
    end
    return self.ServerEntity
end

----------------------------------
Server.CheckServerEntity = function(self)

    local hServerEntity = self.Utils:GetEntity(self.ServerEntity.id)
    if (not hServerEntity or not hServerEntity.IS_CHAT_ENTITY) then
        self:SpawnServerEntity()
    else
        self:Log("Server Entity already Spawned")
    end
end

----------------------------------
Server.SpawnServerEntity = function(self)

    local sName = self.Properties.ServerEntityName
    local hEntity = self.Utils:SpawnEntity({
        class = "Reflex",
        name = sName,
        position = vector.make(0, 0, 0),
        orientation = vector.make(0, 0, 1),
        properties = {
            bAdjustToTerrain = 1,
            Respawn = {
                bRespawn = 1,
                nTimer = 1,
                bUnique = 1
            }
        }
    })

    if (not hEntity) then
        self:LogError("Failed to Spawn the Server Entity!")
    end

    hEntity.IS_CHAT_ENTITY = true
    self.ServerEntity = hEntity
    self.ActorHandler:OnServerSpawn(hEntity)
    self:Log("Spawned Server Entity")

end

----------------------------------
Server.OnUpdate = function(self, iFrameTime, iFrameID)


    --[[
    -- Done in C++. thanks C
    local iRate = self.Utils:GetCVar("sv_dedicatedMaxRate")
    if (#self.Utils:GetPlayers() == 0) then
        if (iRate ~= 5) then
            self.Utils:SetCVar("sv_dedicatedMaxRate", "5")
        end
        return -- return early as we don't need to frame profile in this scenario
    elseif (iRate == 5) then
        self.Utils:SetCVar("sv_dedicatedMaxRate", "30")
    end]]

    local iRate = self.Utils:GetCVar("sv_dedicatedMaxRate")
    local iCppIdleRate = 5 -- FIXME sync

    local iClock = os.clock()
    local iFrameCounterLimit = 30
    local iFrameCounters = #self.FrameCounters
    local iRateAverage = 0

    if (iFrameCounters > iFrameCounterLimit) then
        table.remove(self.FrameCounters, 1)
    end
    if (iFrameCounters > 1) then
        for _, tInfo in pairs(self.FrameCounters) do
            iRateAverage = iRateAverage + tInfo.Rate
        end
        iRateAverage = iRateAverage / iFrameCounters
    end

    self.FrameSteps = ((self.FrameSteps or 0) + 1)
    self.FrameStepReset = (self.FrameStepReset or os.clock())
    local iActualFPS = (self.FrameStepsPerSecond or 0)
    local sActualFPSDiff = ""
    if (self.FrameStepsPerSecondLast) then
        local iDiff = (self.FrameStepsPerSecond - self.FrameStepsPerSecondLast)
        sActualFPSDiff = ", $4" .. (iDiff >= 0 and "$3+" or "").. "" .. iDiff
    end

    if (iClock - self.FrameStepReset >= 1.0) then
        self.FrameStepReset = iClock
        self.FrameStepsPerSecondLast = self.FrameStepsPerSecond
        self.FrameStepsPerSecond = self.FrameSteps
        self.FrameSteps = 0
    end

    if (not self.FrameCounterIdleExitTimer) then
        self.FrameCounterIdleExitTimer = TimerNew(5)
    end

    local iLastCounter = (self.FrameCounters[#self.FrameCounters] or { Clock = iClock }).Clock
    local iFrameDiff = (iClock - iLastCounter)
    if (iRate > iCppIdleRate) then
        if (iFrameDiff > 0.08 and self.FrameCounterIdleExitTimer.expired()) then
            ServerLogWarning("{Gray}Frame Time {Red}%0.3f{Gray} (Avg: {Red}%0.3f{Gray}) | FPS: {Red}%0.2f{Gray} (Steps/s: {Red}%d{Gray}%s{Gray})", iFrameDiff, iRateAverage, (1 / iFrameDiff), iActualFPS, sActualFPSDiff)
            --self.Network:OnFrameLag(iFrameDiff, iRateAverage, (1 / iFrameDiff), iActualFPS, sActualFPSDiff)
        end
    else
        self.FrameCounterIdleExitTimer.refresh()
    end
    table.insert(self.FrameCounters, { Clock = iClock, Rate = iFrameDiff, This = os.clock() - iClock })
end

----------------------------------
Server.OnTimerSecond = function(self)
    self.Statistics:Event(StatisticsEvent_ServerLifetime, 1)
end

----------------------------------
Server.OnServerEmptied = function(self)
    self:Log("Server is Empty, Exporting Component Data.")
    self:ExportComponentData()
end

----------------------------------
Server.ConfigureComponents = function(self)

    local pConfig = self.Config
    if (not pConfig) then
        self:LogError("Cannot Configure Components yet")
        return
    end

    self:Log("Configuring Components ..")

    for _, aComponent in pairs(self.ComponentList) do
        local sComponent = aComponent.Name
        local tComponent = self[sComponent]
        if (tComponent) then
            local tConfig = tComponent.ComponentConfig
            local iAssignments = 0
            local iDefaults = 0
            if (tConfig) then

                --tComponent:Log("Configuring..")
                if (tComponent.Config == nil) then
                    tComponent.Config = {}
                end

                local tComponentConfig = tComponent.Config
                for _, tInfo in pairs(tConfig) do

                    ServerLog(tInfo.Config)
                    local hConfigValue, bIsDefault = pConfig:Get(tInfo.Config, tInfo.Default, tInfo.Type)
                    table.Assign(tComponentConfig, ("%s"):format(tInfo.Key), hConfigValue)
                    iAssignments = iAssignments + 1
                    if (bIsDefault) then
                        tComponent:LogWarning("Unable to locate Configuration '%s' for Key 'Config.%s'", tInfo.Config, tInfo.Key)
                        iDefaults = iDefaults + 1
                    end
                end
            end

            if (iAssignments > 0) then
                tComponent:Log("Configured %d Keys with %d Defaults", iAssignments, iDefaults)
            end
        else
            self:LogFatal("Unknown Component in ComponentList found '%s'", sComponent)
            return false
        end
    end

    self:Log("Components Configured!")
end

----------------------------------
Server.InitializeComponents = function(self)

    ServerLog("Initializing Components...")
    --InitializePriority
    local aInitializeList = {}
    for sComponent, hFunction in pairs(self.InitializeList) do
        table.insert(aInitializeList, {
            Function = hFunction,
            ComponentName = sComponent
        })
    end

    table.sort(aInitializeList, function(a, b)
        return ((Server[a.ComponentName].ComponentPriority) > (Server[b.ComponentName].ComponentPriority))
    end)

    for i = 1, #aInitializeList do

        local hInitializeFunction = aInitializeList[i].Function
        local sComponentName = aInitializeList[i].ComponentName

        local bOk, sError = pcall(hInitializeFunction, self[sComponentName])
        if (bOk == false) then -- No, we are not PirateSoftware, but we don't want 'nil' returns to cause mayhem!
            ServerLogFatal("Failed to Initialize Component '%s'", sComponentName)
            ServerLogFatal("> %s", (sError or "<Null>"))
            return false
        end

        if (self:LoadComponentExternal(self[sComponentName], sComponentName, true) == false) then
            return false
        end
        self[sComponentName].Initialized = true
    end
    self.ComponentsInitialized = true
end

----------------------------------
Server.PostInitializeComponents = function(self)

    ServerLog("Post-Initializing Components...")
    for sComponent, hFunction in pairs(self.PostInitializeList) do

        local bOk, sError = pcall(hFunction, self[sComponent])
        if (bOk == false) then
            ServerLogError("Failed to Post-Initialize Component '%s'", sComponent)
            ServerLogError("> %s", (sError or "<Null>"))
            return false
        end

        self[sComponent].PostInitialized = true
    end
end

----------------------------------
Server.ExportComponentData = function(self)

    local bOk
    local iTotalSize = 0
    for sComponent, aKeys in pairs(self.ComponentExternal) do
        if (self[sComponent]) then
            for _, aKeyInfo in pairs(aKeys) do
                local aData = self[sComponent][aKeyInfo.Key]
                if (not aKeyInfo.IsRecursive and not aKeyInfo.ReadOnly and aData ~= nil) then
                    local sComment = ("This file Contains data which will be loaded into the '%s' Key for the '%s' Server Component"):format(aKeyInfo.Key, sComponent)
                    bOk, iTotalSize = self.FileLoader:SaveFile(aData, aKeyInfo.Name, aKeyInfo.Path, sComment)
                end
            end
        end
    end

    self.Events.Callbacks:OnExportScriptData()
    ServerLog("Exported %d Keys from %d Components (Size %s)", table.countRec(self.ComponentExternal, nil, 1), table.count(self.ComponentExternal), self.Utils:ByteSuffix(iTotalSize))
end

----------------------------------
Server.CreateComponentFunctions = function(self, aBody, sName, sFriendlyName)

    aBody.Name = sName
    aBody.FriendlyName = sFriendlyName
    aBody.GetName = function(this)
        return this.Name
    end
    aBody.GetFriendlyName = function(this)
        return this.FriendlyName or this.Name
    end

    aBody.IsComponentEnabled = aBody.IsComponentEnabled or function(this)
        return this.ComponentStatus ~= false
    end

    self:CreateLogAbstract(aBody, sName)
end

----------------------------------
Server.LoadComponentExternal = function(self, aBody, sName, bIsAfterInit)

    local aComponentExternal = self.ComponentExternal[sName]
    if (aComponentExternal) then
        for _, aKeyInfo in pairs(aComponentExternal) do

            local bOk, hData
            if (aKeyInfo.AfterInit == nil) then
                aKeyInfo.AfterInit = false
            end
            if ((aKeyInfo.AfterInit == bIsAfterInit)) then
                if (not aKeyInfo.Recursive) then
                    bOk, hData = self.FileLoader:ExecuteFile(aKeyInfo.Name, aKeyInfo.Path, {}, eFileType_Data)
                    if (not bOk) then
                        ServerLogFatal("Failed to Import External Data for Component '%s'", sName)
                        ServerLogFatal("Aborting Initialization to Preserve Data!")
                        return false
                    end

                    if (hData) then
                        if (aKeyInfo.Key) then
                            aBody[aKeyInfo.Key] = hData
                        end
                        aBody:Log("Loaded External Data File %s", aKeyInfo.Name)
                    else
                        aBody:Log("External Data File %s was not found or is Empty", aKeyInfo.Name)
                    end
                else

                    local function LoadRecursive(sPath)

                        if (not ServerLFS.DirExists(sPath)) then
                            if (not ServerLFS.DirCreate(sPath)) then
                                return
                            end
                        end

                        local aFiles = ServerLFS.DirGetFiles(sPath, GETFILES_ALL)
                        if (table.empty(aFiles)) then
                            return
                        end

                        for _, sFile in pairs(aFiles) do
                            local sFileName = ServerLFS.FileGetName(sFile)
                            if (sFileName:sub(1, 1) ~= "!") then
                                if (ServerLFS.DirIsDir(sFile)) then
                                    if (LoadRecursive(sFile) == false) then
                                        return false
                                    end

                                elseif (aKeyInfo.NamePattern == nil or string.match(sFileName, aKeyInfo.NamePattern)) then
                                    bOk, hData = self.FileLoader:ExecuteFile(sFileName, ServerLFS.FileGetPath(sFile), {}, eFileType_Data)
                                    if (not bOk) then
                                        ServerLogFatal("Failed to Import External Data for Component '%s'", sName)
                                        ServerLogFatal("Aborting Initialization to Preserve Data!")
                                        return false
                                    end
                                    aBody:Log("Loaded External Data File %s", sFileName)
                                end
                            else
                                aBody:Log("Skipping Ignored file %s",sFileName)
                            end
                        end

                    end
                    local sCurrentDir = (aKeyInfo.Path)
                    if (ServerLFS.DirExists(sCurrentDir)) then
                        if (LoadRecursive(sCurrentDir) == false) then
                            return false
                        end
                    else
                        ServerLogFatal("Failed to Create Data Directory '%s' for Component '%s'", sCurrentDir, sName)
                    end
                end

            end
        end
    end
end

----------------------------------
Server.CreateComponents = function(self)

    ServerLog("Creating Components..")

    for _, aComponent in pairs(self.ComponentList) do
        local sName = aComponent.Name
        local aBody = aComponent.Body


        if (self[sName]) then
            return ServerLogError("Component or Member by the Name '%s' Already Exists!", sName)
        end

        self:CreateComponentFunctions(aBody, sName, aComponent.FriendlyName)

        aBody.ComponentPriority = (aBody.ComponentPriority or PRIORITY_NORMAL)

        self.InitializeList[sName]      = aBody.Initialize
        self.PreInitializeList[sName]   = aBody.PreInitialize
        self.PostInitializeList[sName]  = aBody.PostInitialize
        self.ComponentData[sName]       = (self.ComponentData[sName] or {})
        self.ComponentExternal[sName]   = aBody.ExternalData

        local aCCommands = aBody.CCommands
        local aCVars = aBody.CVars

        if (table.emptyN(aCCommands)) then
            for _, aCommandInfo in pairs(aCCommands) do
                local sCommandName = string.format("%s_%s_%s", "Server", sName, aCommandInfo.Name)
                local sCommandFunction = string.format([[return Server.%s:%s(%%%%)]], sName, aCommandInfo.FunctionName)
                local sCommandDescription = (aCommandInfo.Description or string.format("No Description Available. Executes the Function %s", aCommandInfo.FunctionName))
                System.AddCCommand(sCommandName, sCommandFunction, sCommandDescription)
            end
            aBody:Log("Created %d Console Commands", table.size(aCCommands))
        end

        local aProtected = aBody.Protected
        local iRestoredKeys = 0
        if (aProtected) then
            for sKey, aDefault in pairs(aProtected) do
                local hStored = self.ComponentData[sName][sKey]

                aBody[sKey] = aDefault
                if (hStored ~= nil) then
                    aBody[sKey] = hStored
                else
                    self.ComponentData[sName][sKey] = aDefault
                end
                iRestoredKeys = (iRestoredKeys + 1)
            end
            if (iRestoredKeys > 0) then
                aBody:Log("Restored %d Protected Keys", iRestoredKeys)
            end
        end

        --[[
        for _, tConfig in pairs(aBody.Config or {}) do
            local sKey = tConfig.Key
            local sDestination = tConfig.Key
        end
        ]]

        self[sName] = aBody
        if (aBody.EarlyInitialize) then
            local bOk, sError = pcall(aBody.EarlyInitialize, aBody)
            if (not bOk) then
                ServerLogError("Failed to Early-Initialize Component '%s'", sName)
                ServerLogError("%s", (sError or "<Null>"))
                return false
            end
        end

        if (self:LoadComponentExternal(aBody, sName, false) == false) then
            return false
        end

        table.insert(self.InitializedComponents, sName)
        ServerLog("Component %s Created", sName)
    end

    ServerLog("Restored %d Protected Keys from %d Components", table.countRec(self.ComponentData, function(a, b, iLevel) return true--[[((iLevel == 0 and IsArray(b)) or iLevel == 1) ]]end, 1), table.count(self.ComponentData))
end

----------------------------------
Server.CreateComponent = function(self, aComponent)

    if (not aComponent) then
        return
    end

    table.insert(self.ComponentList, aComponent)
end

----------------------------------
Server.WasInitialized = function(self)
    return SCRIPT_WAS_INITIALIZED == true
end

----------------------------------
Server.IsInitialized = function(self)
    return self.Initialized == true
end

----------------------------------
Server.IsPostInitialized = function(self)
    return self.PostInitialized == true
end

----------------------------------
Server.WasPostInitialized = function(self)
    return SCRIPT_WAS_POST_INITIALIZED == true
end

----------------------------------
Server.IsComponentsInitialized = function(self)
    return self.ComponentsInitialized
end

----------------------------------
Server.CreateLogAbstract = function(self, aBody, sName)

    aBody.GetLogName = aBody.GetLogName or function(this)
        return (sName or this:GetName())
    end

    aBody.LogFatal   = (aBody.LogFatal or function(this, sMessage, ...) Server:LogFatal(("[" .. this:GetLogName() .. "] <Fatal>: " .. sMessage), ...) end)
    aBody.LogError   = (aBody.LogError or function(this, sMessage, ...) Server:LogError(("[" .. this:GetLogName() .. "] Error: " .. sMessage), ...) end)
    aBody.LogWarning = (aBody.LogWarning or function(this, sMessage, ...) Server:LogWarning(("[" .. this:GetLogName() .. "] Warning: " .. sMessage), ...) end)
    aBody.Log        = (aBody.Log or function(this, sMessage, ...) Server:Log(("[" .. this:GetLogName() .. "] " .. sMessage), ...) end)
    aBody.LogDirect  = (aBody.Log or function(this, sMessage, ...) Server.Logger:Log(("[" .. this:GetLogName() .. "] " .. sMessage), ...) end)
    aBody.LogDebug   = (aBody.LogDebug or function(this, sMessage, ...) Server:LogDebug(("[" .. this:GetLogName() .. "] <Debug>: " .. sMessage), ...) end)

    aBody.LogWarning_NoPrefix = (aBody.LogWarning_NoPrefix or function(this, sMessage, ...) Server:LogWarning(("[" .. this:GetLogName() .. "] " .. sMessage), ...) end)

    aBody.LogEvent = (aBody.LogEvent or function(this, tEvent)
        if (tEvent.Class == nil) then
            tEvent.Class = this:GetFriendlyName()
        end
        if (tEvent.Event == nil) then
            tEvent.Event = this:GetFriendlyName()
        end
        if (tEvent.Recipients == nil) then
            tEvent.Recipients = Server.Utils:GetPlayers()
            this:LogWarning("No Recipients to LogEvent()")
        end
        Server.Logger:LogEvent(tEvent)--(aBody.LogEventType or sName), sMessage, ...)
    end)
end

----------------------------------
Server.Log = function(self, sMessage, ...)
    self.Logger:Log(sMessage, ...)
end

----------------------------------
Server.LogWarning = function(self, sMessage, ...)
    self.Logger:LogWarning(sMessage, ...)
end

----------------------------------
Server.LogError = function(self, sMessage, ...)
    self.Logger:LogError(sMessage, ...)
end

----------------------------------
Server.LogFatal = function(self, sMessage, ...)
    self.Logger:LogFatal(sMessage, ...)
end

----------------------------------
Server.DebugLog = function(self, sMessage, ...)
    self.Logger:DebugLog(sMessage, ...)
end

-- ===================================================================================

ServerLogEvent_ScriptWarning = "ScriptWarning"
ServerLogEvent_ScriptError   = "ScriptError"
ServerLogEvent_ScriptFatal   = "ScriptFatal"
ServerLogEvent_ScriptDebug   = "ScriptDebug"
ServerLogEvent_Network       = "Network"

Server.Logger = {

    EventQueue = {},
    CommonTags = {},
    ColorTags = {
        ["White"]   = "$1",      -- $1
        ["DBlue"]   = "$2",  -- $2
        ["Green"]   = "$3",      -- $3
        ["Red"]     = "$4",        -- $4
        ["Blue"]    = "$5",       -- $5
        ["Yellow"]  = "$6",     -- $6
        ["Pink"]    = "$7",    -- $7
        ["Magenta"] = "$7",    -- $7
        ["Orange"]  = "$8",     -- $8
        ["Gray"]    = "$9",       -- $9
        ["Grey"]    = "$9",       -- $9
        ["Black"]   = "$0",      -- $0, $O
    },

    Properties = {
        LogInformation = {
            Colors = {
                Error   = "{Red}",
                Warning = "{Yellow}",
                Fatal   = "{Red}",
                Debug   = "{Magenta}",
                Normal  = "{Gray}"
            },
        },
    },

    Initialize = function(self)

        self.CommonTags = {
            ["Mod_Name"]       = MOD_RAW_NAME, -- CryMP-Server
            ["Mod_BitName"]    = MOD_NAME,     -- CryMP-Server x64 bit
            ["Mod_Exe"]        = MOD_EXE_NAME, -- CryMP-Server.exe
            ["Mod_Bits"]       = MOD_BITS,     -- 64 bit
            ["Mod_Version"]    = MOD_VERSION,  -- v21
            ["Mod_Compiler"]   = MOD_COMPILER, -- MSVC 2019
        }

        for sName, sColor in pairs(self.ColorTags) do
            --self.ColorTags[("Color_" .. sName)] = sColor
        end
    end,

    PostInitialize = function(self)

        self.CommonTags["MapName"] = Server.MapRotation:GetMapName()
        self.CommonTags["MapPath"] = Server.MapRotation:GetMapPath()

        for i = 1, table.size(self.EventQueue) do
            self:LogEvent(self.EventQueue[i])
        end

        self.EventQueue = {}
        self:Log("Logger Queue Cleared..")
    end,

    GetLogInfo = function(self, sTag)
    end,

    LogEvent = function(self, tEvent)

        local hEvent         = tEvent.Event
        local sMessage       = tEvent.Message
        local aMessageFormat = tEvent.MessageArgs   -- { ... }
        local tFormat        = tEvent.MessageFormat -- { X = "Y" }
        local aRecipients    = tEvent.Recipients

        if (table.emptyN(aMessageFormat)) then
            sMessage = string.format(sMessage, unpack(aMessageFormat))
        end

        local sClass = string.match(sMessage, "^%[([^%]]+)%]")
        if (sClass == nil) then
            sClass = hEvent

        elseif (not IsArray(sClass)) then
            sMessage = string.gsub(sMessage, "^(%[" .. sClass .. "%] )", "", 1)
        else
            sClass = (sClass.Class or hEvent)
        end

        local aMessageInfo = {
            Recipients = aRecipients,
            Message = sMessage,
            Format = tFormat,
            Class = tEvent.Class or sClass
           -- Class = sClass
        }

        --for _, v in pairs(tEvent) do
        --    if (aMessageInfo[_] == nil) then ServerLog("add%s",_)aMessageInfo[_] = v end -- Merge..
        --end

        -- If we are not yet initialized, we push the log into the queue BUT immediately log it to the console
        if (not Server:IsInitialized()) then
            if (Server:IsComponentsInitialized()) then
                self:Log(string.format("[%s] %s", sClass, Server.LocalizationManager:LocalizeMessage(sMessage, Language_English, tFormat, true)))
                tEvent.NoServerLog = true
            end
            self:QueueEvent(tEvent)
            return
        end


        local aLogColors = self.Properties.LogInformation.Colors
        if (hEvent == ServerLogEvent_ScriptError) then
            aMessageInfo.Message = (aLogColors.Error .. "Error: " .. sMessage)
            aMessageInfo.Recipients = Server.Utils:GetPlayers({ ByAccess = Server.AccessHandler:GetDeveloperLevel() }) -- FIXME

        elseif (hEvent == ServerLogEvent_ScriptFatal) then
            aMessageInfo.Message = (aLogColors.Fatal .. "Fatal: " .. sMessage)
            aMessageInfo.Recipients = Server.Utils:GetPlayers({ ByAccess = Server.AccessHandler:GetDeveloperLevel() }) -- FIXME

        elseif (hEvent == ServerLogEvent_ScriptWarning) then
            aMessageInfo.Message = (aLogColors.Warning .. "Warning: " .. sMessage)
            aMessageInfo.Recipients = Server.Utils:GetPlayers({ ByAccess = Server.AccessHandler:GetAdminLevel() }) -- FIXME

        elseif (hEvent == ServerLogEvent_ScriptDebug) then
            aMessageInfo.Tag = "Debug"
            aMessageInfo.TagColor = aLogColors.Debug
            aMessageInfo.MessageColor = aLogColors.Debug
            aMessageInfo.Message = (aLogColors.Debug .. sMessage)
            aMessageInfo.Recipients = Server.Utils:GetPlayers({ ByAccess = Server.AccessHandler:GetDeveloperLevel() }) -- FIXME

        elseif (not tEvent.NoServerLog) then

            -- Only log this for non warnings and errors, as that's done by now already!
            self:Log(string.format("[%s] %s", tostring(sClass), Server.LocalizationManager:LocalizeMessage(sMessage, Language_English, tFormat, true)))
        end

        Server.Chat:ConsoleMessage(aMessageInfo)
    end,

    QueueEvent = function(self, tEvent)
        table.insert(self.EventQueue, tEvent)
    end,

    FormatTags = function(self, sMessage, aTagAppend)
        local aCommonTags = table.Merge(table.Merge(self.ColorTags, self.CommonTags), (aTagAppend or {}))
        for sTag, sValue in pairs(aCommonTags) do
            sMessage = string.gsub(sMessage, ("{%s}"):format(sTag), sValue)
        end
        return sMessage
    end,

    RidColors = function(self, sMessage)
        if (sMessage:find("{%W}")) then
            for sTag, sValue in pairs(self.ColorTags) do
                sMessage = string.gsub(sMessage, ("{%s}"):format(sTag), "")
            end
        end
        return string.gsub(sMessage, string.COLOR_CODE, "")
    end,

    LogToPlayers = function(self)
    end,

    Log = function(self, sMessage, ...)
        if (#{...} > 0) then
            sMessage = string.format(sMessage, ...)
        end

        local iLine = 0
        for sLine in string.gmatch(sMessage, "[^\n]+") do
            --SystemLog(sLine)--string.gsub(sLine, "\t", "   "))
            self:Print(("[Server] " .. (iLine > 0 and "  " or "") .. sLine))
            iLine = (iLine + 1)
        end
    end,

    LogWarning = function(self, sMessage, ...)
        sMessage = self:FormatTags(sMessage)
        self:Log(sMessage, ...)
        self:LogEvent({
            Event = ServerLogEvent_ScriptWarning,
            Message = string.gsub(sMessage, "Warning:%s*", "", 1),
            MessageArgs = { ... },
        })
    end,

    LogError = function(self, sMessage, ...)
        sMessage = self:FormatTags(sMessage)
        self:Log(sMessage, ...)
        self:LogEvent({
            Event = ServerLogEvent_ScriptError,
            Message = string.gsub(sMessage, "Error:%s*", "", 1),
            MessageArgs = { ... },
        })
    end,

    LogFatal = function(self, sMessage, ...)
        sMessage = self:FormatTags(sMessage)
        self:Log(sMessage, ...)
        self:LogEvent({
            Event = ServerLogEvent_ScriptFatal,
            Message = string.gsub(sMessage, "<Fatal>:%s*", "", 1),
            MessageArgs = { ... },
        })
    end,

    DebugLog = function(self, sMessage, bSafe)
        local sOrigin = LuaUtils.TraceSource(3):gsub("^%s+%.+", "")
        self:Log(sMessage)
        self:Log("<Debug Origin> %s", sOrigin)
        if (not bSafe) then
            self:LogEvent({
                Event = ServerLogEvent_ScriptDebug,
                Message = string.gsub(sMessage, "<Debug>:%s*", "", 1),
                MessageArgs = {},
            })
            self:LogEvent({
                Event = ServerLogEvent_ScriptDebug,
                Message = "Origin: " .. string.gsub((sOrigin:match("/?\\?(%w+%.lua.*)") or "<null>"), "<Debug>: Origin: %s*", "", 1),
                MessageArgs = {},
            })
        end
    end,

    Print = function(self, sMessage)
        SystemLog(sMessage)
    end,

    PuttyPrint = function(self, sMessage)
        SererDLL.PuttyLog(sMessage .. "$O")
    end,
}

-- ===================================================================================

Server.ErrorHandler = {

    CollectedErrors = {},

    Initialize = function(self)
        --ServerDLL.SetScriptErrorLog(false)
    end,

    PostInitialize = function(self)
        ServerDLL.SetScriptErrorLog(false)
    end,

    OnScriptError = function(self, sError)
        self:HandleError(sError)
    end,

    OnScriptWarning = function(self, sWarning)
        self:LogWarning(sWarning)
    end,

    HandleError = function(self, sErrorMessage, ...)

        ---------------------------------------
        --- !!!!!!! ONLY USE PCALL HERE !!!!!!!
        ---------------------------------------
        local aParams = { ... }
        local bOk, sError = pcall(function()
            local sFormatted = string.formatex(sErrorMessage, unpack(aParams))
            self:LogError(sFormatted)
        end)

        if (not bOk) then
            pcall(ServerLogFatal, "ErrorHandler Failed to Handle the Error")
            pcall(ServerLogFatal, "> %s", tostring(sError or ""))
        end

        -- Continue
        SCRIPT_ERROR = false
    end,

    LogError = function(self, sErrorMessage)
        self:CollectError(sErrorMessage)
        ServerLogError(sErrorMessage)
    end,

    OnScriptWarning = function(self, sWarning)
        self:CollectError(sWarning) -- ??
        ServerLogWarning(sWarning)
    end,

    CollectError = function(self, sFormatted)

        local sFixed
        local sErrorDesc = (string.matchex(sFormatted, "^(Error Thrown .-)\n*", "^(Error .-)\n", "(\\%w+%.lua:%d+:.*)") or sFormatted)
        local aLocation  = string.split(sFormatted, "\n", 2)
        if (table.empty(aLocation)) then
            aLocation = string.split(debug.traceback(), "\n", 2)
        end

        for i, sLine in pairs(aLocation) do
            sFixed = string.gsub(sLine, "^\t+", "")
            --for ii = 3, 1, -1 do
            --    if (sFixed) then
            --        break
            --    end
            --end
            if (sFixed) then
                aLocation[i] = sFixed
            end
        end

        local sEnd = aLocation[1]
        if (sEnd) then
            local sEndTrimmed = string.match(sEnd, ".*:%d+: in (.*)")
            if (sEndTrimmed) then aLocation = table.insertFirst(aLocation, sEndTrimmed)
            end
        end

        table.insert(self.CollectedErrors, {
            Timer        = TimerNew(),
            Error        = {
                Desc     = sErrorDesc,
                Location = aLocation
            }
        })
    end
}

-- ===================================================================================

eFileType_Core      = "Core"
eFileType_Internal  = "Internal"
eFileType_Plugin    = "Plugin"
eFileType_Command   = "Command"
eFileType_Library   = "Library"
eFileType_Utility   = "Utility"
eFileType_Data      = "Data-File"


FileError_NotFound      = "File does not exist."
FileError_LoadFailed    = "Failed to load the file."
FileError_ExecuteFailed = "Failed to execute the file."

Server.FileLoader = {

    LoadedFiles = {},
    FileList    = {},

    Initialize = function(self)

        self:Log("Loading Libraries..")
        if (not self:LoadLibraries()) then
            return false, self:LogError("Failed to load all Libraries!")
        end

        self:Log("Loading Utilities and Definitions..")
        if (not self:LoadUtils()) then
            return false, self:LogError("Failed to load Utilities and Definitions")
        end

        self:Log("Loading Core Files..")
        if (not self:LoadComponents()) then
            return false, self:LogError("Failed to load all Core Files")
        end

        self:Log("Fully Initialized!")
        return true
    end,

    PostInitialize = function(self)
        return true
    end,

    LoadComponents = function(self, sDir)

        sDir = (sDir or SERVER_DIR_CORE)
        local aFolders = ServerLFS.DirGetFiles(sDir, GETFILES_DIR)
        if (#(aFolders or {}) > 0) then
            for _, sFolder in pairs(aFolders) do
                if (not self:LoadComponents(sFolder)) then
                    return false
                end
            end
        end

        local aFiles = ServerLFS.DirGetFiles(sDir, GETFILES_FILES, ".*")
        if (#aFiles == 0) then
            return true
        end

        for _, sFile in pairs(aFiles) do
            -- We don't load Components where the name starts with '!'
            if ((string.sub(ServerLFS.FileGetName(sFile), 1, 1) ~= "!") and not self:LoadFile(sFile, eFileType_Core)) then
                return false
            end
        end
        return true
    end,

    LoadUtils = function(self, sDir)

        sDir = (sDir or SERVER_DIR_UTILS)
        local aFolders = ServerLFS.DirGetFiles(sDir, GETFILES_DIR)
        if (#(aFolders or {}) > 0) then
            for _, sFolder in pairs(aFolders) do
                if (not self:LoadUtils(sFolder)) then
                    return false
                end
            end
        end

        local aFiles = ServerLFS.DirGetFiles(sDir, GETFILES_FILES, ".*")
        if (#aFiles == 0) then
            return true
        end

        for _, sFile in pairs(aFiles) do

            -- We don't load Library files where the name starts with '!'
            if (ServerLFS.FileExists(sFile) and (string.sub(ServerLFS.FileGetName(sFile), 1, 1) ~= "!")) then
                if (not self:LoadFile(sFile, eFileType_Utility)) then
                    return false
                else
                    -- EDIT: Comment later
                end
            end
        end
        return true
    end,

    LoadLibraries = function(self, sPath)

        local sDir = (sPath or SERVER_DIR_LIBS)
        if (not ServerLFS.DirExists(sDir)) then
            return true
        end

        local aFolders = ServerLFS.DirGetFiles(sDir, GETFILES_DIR)
        if (#(aFolders or {}) > 0) then
            for _, sFolder in pairs(aFolders) do
                if (not self:LoadLibraries(sFolder)) then
                    return false
                end
            end
        end

        local aFiles = ServerLFS.DirGetFiles(sDir, GETFILES_FILES, ".*")
        if (#aFiles == 0) then
            return true
        end

        for _, sFile in pairs(aFiles) do

            -- We don't load Library files where the name starts with '!'
            if (ServerLFS.FileExists(sFile) and (string.sub(ServerLFS.FileGetName(sFile), 1, 1) ~= "!")) then
                if (not self:LoadFile(sFile, eFileType_Library)) then
                    return false
                else
                    -- EDIT: Comment later
                end
            end
        end

        -- Overwrite FileSystem Handle with our own File System
        if (fileutils) then
            fileutils.LFS = ServerLFS
        end

        -- Overwrite Error Handler Handle with our our handler
        if (luautils) then
            luautils.ERROR_HANDLER = HandleError
        end

        return true
    end,

    SaveFile = function(self, hData, sFile, sDir, sComment)

        sDir = (sDir or SERVER_DIR_DATA)
        sFile = (sDir .. sFile)

        if (not ServerLFS.DirExists(sDir)) then
            ServerLFS.DirCreate(sDir)
        end

        local sData = string.format("return %s", (table.tostring((hData or {}), "", "") or "{}"))
        if (sComment) then
            local iCurrentLineLength = 0
            local sCommentLines = ""
            for _, sWord in pairs(string.split(sComment, " ")) do
                if ((iCurrentLineLength + #sWord) > 60) then
                    iCurrentLineLength = 0
                    sCommentLines = sCommentLines .. "\n-- "
                end
                sCommentLines = sCommentLines .. sWord .. " "
                iCurrentLineLength = (iCurrentLineLength + #sWord)
            end
            sData =
            "-- ===================================================================================\n" ..
            "--          ____            __  __ ____            ____                             --\n" ..
            "--         / ___|_ __ _   _|  \\/  |  _ \\          / ___|  ___ _ ____   _____ _ __   --\n" ..
            "--        | |   | '__| | | | |\\/| | |_) |  _____  \\___ \\ / _ \\ '__\\ \\ / / _ \\ '__|  --\n" ..
            "--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \\ V /  __/ |     --\n" ..
            "--         \\____|_|   \\__, |_|  |_|_|             |____/ \\___|_|    \\_/ \\___|_|     --\n" ..
            "--                    |___/          by: shortcut0                                  --\n" ..
            "-- Generated by " .. MOD_EXE_NAME .. "(" .. MOD_VERSION .. ") Build " .. MOD_COMPILER .. "\n" ..
            "-- " .. sCommentLines .. "\n" ..
            "-- ===================================================================================\n" ..
	        sData
        end

        -- This saves the file in a second thread, so even on huge data, the main thread won't get lagged out
        -- It's also asynchronous, so always the latest data is written to the file
        ServerDLL.SaveFile(sFile, sData)
        return true, string.len(sData)
    end,

    LoadFile = function(self, sFile, sType)

        if (not sFile) then
            return false, self:LogError("No File Specified to LoadFile()")
        end
        sType = (sType or "Unspecified")

        -----
        local hLib, bOk, sErr, sErr2
        hLib, sErr = loadfile(sFile)
        if (not hLib) then
            self:LogError("Failed to Load File %s", ServerLFS.FileGetName(sFile))
            self:LogError("%s", (sErr or "N/A"))
            return false
        end

        bOk, sErr2 = pcall(hLib)
        if (not bOk) then
            self:LogError("Failed to Execute File %s", ServerLFS.FileGetName(sFile))
            self:LogError("%s", (sErr2 or "N/A"))
            return false
        end

        -- Statistical reasons
        self:OnFileLoaded(sFile, sType)
        return true, sErr2
    end,

    OnFileLoaded = function(self, sFile, sType)
        table.insert(self.LoadedFiles, { File = sFile, Type = sType, Time = _time })
    end,

    ExecuteFile = function(self, sFile, sPath, hDefault, sType)
        if (not sFile) then
            return false, self:LogError("No File Specified to ExecuteFile()")
        end
        sType = (sType or "Unspecified")
        sPath = string.gsub(sPath, "\\", "/")
        if (string.sub(sPath, -1) ~= "/") then
            sPath = (sPath .. "/")
        end
        sFile = ((sPath or "") .. sFile)

        local hLib, bOk, sErr, sErr2
        hLib, sErr = loadfile(sFile)
        if (not hLib) then
            if (string.match(sErr or "", "No such file or directory$")) then
                return true
            end
            self:LogError("Failed to Load File %s", ServerLFS.FileGetName(sFile))
            self:LogError("%s", (sErr or "N/A"))
            return false
        end

        bOk, sErr2 = pcall(hLib)
        if (not bOk) then
            self:LogError("Failed to Execute File %s", ServerLFS.FileGetName(sFile))
            self:LogError("%s", (sErr2 or "N/A"))
            return false
        end

        -- Statistical reasons
        self:OnFileLoaded(sFile, sType)
        return true, sErr2
    end
}

-- ===================================================================================

SystemLog = System.LogAlways
ServerLog = function(sMessage, ...)
    Server:Log(sMessage, ...)
end
ServerLogWarning = function(sMessage, ...)
    Server:LogWarning(("Warning: " .. sMessage), ...)
end
ServerLogError = function(sMessage, ...)
    Server:LogError(("Error: " .. sMessage), ...)
end
ServerLogFatal = function(sMessage, ...)
    Server:LogFatal(("<Fatal>: " .. sMessage), ...)
end
DebugLog = function(...)
    local sMessage = ""
    for _, sParam in pairs({...}) do
        sMessage = sMessage .. (sMessage ~= "" and ", " or "") .. tostring(sParam)
    end
    Server:DebugLog("<Debug>: " .. sMessage)
end
DebugLogSafe = function(...)
    local sMessage = ""
    for _, sParam in pairs({...}) do
        sMessage = sMessage .. (sMessage ~= "" and ", " or "") .. tostring(sParam)
    end
    Server:DebugLog("<Debug>: " .. sMessage, true)
end
