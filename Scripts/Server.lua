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
end

Server = {

    PreInitializeList = {}, -- A list of functions to call before Initializing
    InitializeList = {},    -- A list of functions to call upon Initializing
    PostInitializeList = {},-- A list of functions to call upon Post-Initializing

    ComponentList           = {}, -- A list of to be added Components
    ComponentData           = ComponentData,
    ComponentExternal       = {},
    InitializedComponents   = {}, -- A list of Initialized Components

    Initialized = false,
    PostInitialized = false,
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
    SERVER_DIR_CORE     = (SERVER_DIR_SCRIPTS .. "Core\\")       -- Core Scripts (Scripts the server depends on)
    SERVER_DIR_INTERNAL = (SERVER_DIR_SCRIPTS .. "Internal\\")   -- Internal Scripts (Scripts the server relies on)
    SERVER_DIR_COMMANDS = (SERVER_DIR_SCRIPTS .. "Commands\\")   -- Commands
    SERVER_DIR_PLUGINS  = (SERVER_DIR_SCRIPTS .. "Plugins\\")    -- Plugins

    self.ErrorHandler:Initialize()

    if (not self.FileLoader:Initialize()) then
        ServerLogFatal("FileLoader Failed to Initialize!")
        return false
    end

    -----
    ServerLog("Initializing Components...")

    self:CreateComponents()
    for sComponent, hFunction in pairs(self.InitializeList) do

        local bOk, sError = pcall(hFunction, self[sComponent])
        if (bOk == false) then -- No, we are not PirateSoftware, but we don't want 'nil' returns to cause mayhem!
            ServerLogFatal("Failed to Initialize Component '%s'", sComponent)
            ServerLogFatal("> %s", (sError or "<Null>"))
            return false
        end

        local aComponentExternal = self.ComponentExternal[sComponent]
        if (aComponentExternal) then
            local hData
            for _, aKeyInfo in pairs(aComponentExternal) do
                bOk, hData = self.FileLoader:ExecuteFile(aKeyInfo.Name, aKeyInfo.Path, {}, eFileType_Data)
                if (not bOk) then
                    ServerLogFatal("Failed to Import External Data for Component '%s'", sComponent)
                    ServerLogFatal("Aborting Initialization to Preserve Data!")
                    return false
                end

                self[sComponent][aKeyInfo.Key] = hData
                ServerLog("restore %s",table.tostring(hData or {}))
            end
        end
        self[sComponent].Initialized = true
    end

    self.Initialized = true
    ServerLog("Script Fully Initialized!")
    return true
end

----------------------------------
--- Called when g_gameRules exists
Server.PostInitialize = function(self)

    ServerLog("Post-Initializing..")

    self.ErrorHandler:PostInitialize()
    if (not self.FileLoader:PostInitialize()) then
        ServerLogError("FileLoader Failed to Post-Initialize!")
        return false
    end

    -- TODO: Move this
    g_sGameRules = g_gameRules.class
    g_pGame = g_gameRules.game

    ServerLog("Post-Initializing Components...")
    for sComponent, hFunction in pairs(self.PostInitializeList) do

        local bOk, sError = pcall(hFunction, self[sComponent])
        if (bOk == false) then
            ServerLogError("Failed to Post-Initialize Component '%s'")
            ServerLogError("> %s", (sError or "<Null>"))
            return false
        end

        self[sComponent].PostInitialized = true
    end

    self.PostInitialized = true
    ServerLog("Script Fully Post-Initialized!")
    return true
end

----------------------------------
--- Happens before Initialization
Server.PreInitialize = function(self)

    self:ExportComponentData()
    ServerLog("Script Pre-Initialized Successfully!")
    return true
end

----------------------------------
Server.Reset = function(self)
end

----------------------------------
Server.OnUpdate = function(self, iFrameTime, iFrameID)
end

----------------------------------
Server.OnTimerSecond = function(self)

    -- Inform Components
    for _, sComponent in pairs(self.InitializedComponents) do
        if (self[sComponent].Event_TimerSecond) then
            self[sComponent]:Event_TimerSecond()
        end
    end
end

----------------------------------
Server.OnTimerQuarterHour = function(self)

    -- Inform Components
    if (self.Timers:Expired_Refresh(ServerTimer_ComponentDataExport)) then
        if (self.Utils.GetPlayerCount() > 0) then

        end
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
                if (aData ~= nil) then
                    bOk, iTotalSize = self.FileLoader:SaveFile(aData, aKeyInfo.Name, aKeyInfo.Path)
                end
            end
        end
    end

    ServerLog("Exported %d Keys from %d Components (Size %s)", table.countRec(self.ComponentExternal, nil, 1), table.count(self.ComponentExternal), self.Utils.ByteSuffix(iTotalSize))
end

----------------------------------
Server.CreateComponents = function(self)

    self.FFF=1

    for _, aComponent in pairs(self.ComponentList) do
        local sName = aComponent.Name
        local aBody = aComponent.Body

        if (self[sName]) then
            return ServerLogError("Component or Member by the Name '%s' Already Exists!", sName)
        end

        self.InitializeList[sName]      = aBody.Initialize
        self.PreInitializeList[sName]   = aBody.PreInitialize
        self.PostInitializeList[sName]  = aBody.PostInitialize
        self.ComponentData[sName]       = (self.ComponentData[sName] or {})
        self.ComponentExternal[sName]   = aBody.SaveToFile

        self:CreateLogAbstract(aBody, sName)

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
        end
        aBody:Log("Restored %d Protected Keys", iRestoredKeys)


        self[sName] = aBody
        table.insert(self.InitializedComponents, sName)
        ServerLog("Component %s Created", sName)
    end

    ServerLog("Restored %d Protected Keys from %d Components!", table.countRec(self.ComponentData, function(a, b, iLevel) return true--[[((iLevel == 0 and IsArray(b)) or iLevel == 1) ]]end, 1), table.count(self.ComponentData))
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
Server.CreateLogAbstract = function(self, aBody, sName)

    aBody.LogFatal = (aBody.LogFatal or function(this, sMessage, ...)
        Server:LogFatal(("[" .. sName .. "] <Fatal>: " .. sMessage), ...)
    end)

    aBody.LogError = (aBody.LogError or function(this, sMessage, ...)
        Server:LogError(("[" .. sName .. "] Error: " .. sMessage), ...)
    end)

    aBody.LogWarning = (aBody.LogWarning or function(this, sMessage, ...)
        Server:LogWarning(("[" .. sName .. "] Warning: " .. sMessage), ...)
    end)

    aBody.Log = (aBody.Log or function(this, sMessage, ...)
        Server:Log(("[" .. sName .. "] " .. sMessage), ...)
    end)

    aBody.LogDebug = (aBody.LogDebug or function(this, sMessage, ...)
        Server:LogDebug(("[" .. sName .. "] <Debug>: " .. sMessage), ...)
    end)

    aBody.LogEvent = (aBody.LogEvent or function(this, sMessage, ...)
        Server.Logger:LogEvent((aBody.LogEventType or sName), sMessage, ...)
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

    LogInformation = {
        Colors = {
            Error   = "$4",
            Warning = "$6",
            Fatal   = "$4",
            Normal  = "$1"
        },
    },

    GetLogInfo = function(self, sTag)
    end,

    LogEvent = function(self, hEvent, sMessage, ...)

        if (not Server:IsInitialized() and not Server:WasInitialized()) then
            return
        end

        if (#{...} > 0) then
            sMessage = string.format(sMessage, ...)
        end

        local sClass = string.match(sMessage, "^%[([^%]]+)%]")
        if (sClass == nil) then
            sClass = "Server"
        end

        --SystemLog("Class = " .. sClass .. ", Event = " .. hEvent .. " Message = " .. sMessage)
        --SystemLog("class="..sClass..",type="..hEvent.." >>" .. sMessage)
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
        self:Log(sMessage, ...)
        self:LogEvent(ServerLogEvent_ScriptWarning, (string.gsub(sMessage, "Warning:%s*", "", 1)), ...)
    end,
    LogError = function(self, sMessage, ...)
        self:Log(sMessage, ...)
        self:LogEvent(ServerLogEvent_ScriptError, (string.gsub(sMessage, "Error:%s*", "", 1)), ...)
    end,
    LogFatal = function(self, sMessage, ...)
        self:Log(sMessage, ...)
        self:LogEvent(ServerLogEvent_ScriptFatal, (string.gsub(sMessage, "<Fatal>:%s*", "", 1)), ...)
    end,
    DebugLog = function(self, sMessage)
        self:Log(sMessage)
        self:LogEvent(ServerLogEvent_ScriptDebug, (string.gsub(sMessage, "<Debug>:%s*", "", 1)))
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

        Server:CreateLogAbstract(self, "FileLoader")

        self:Log("Loading Libraries..")
        if (not self:LoadLibraries()) then
            return false, self:LogError("Failed to load all Libraries!")
        end

        self:Log("Loading Utilities and Definitions..")
        if (not self:LoadUtils()) then
            return false, self:LogError("Failed to load Utilities and Definitions")
        end

        self:Log("Loading Core Files..")
        if (not self:LoadCoreFiles()) then
            return false, self:LogError("Failed to load all Core Files")
        end

        self:Log("Fully Initialized!")
        return true
    end,

    PostInitialize = function(self)
        return true
    end,

    LoadCoreFiles = function(self)

        local sPath = SERVER_DIR_CORE
        local aFiles = ServerLFS.DirGetFiles(sPath, GETFILES_FILES)
        if ((#aFiles <= 0)) then
            return true
        end

        for _, sFile in pairs(aFiles) do
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

    SaveFile = function(self, hData, sFile, sDir)

        sDir = (sDir or SERVER_DIR_DATA)
        sFile = (sDir .. sFile)

        if (not ServerLFS.DirExists(sDir)) then
            ServerLFS.DirCreate(sDir)
        end

        local sData = string.format("return %s", (table.tostring((hData or {}), "", "") or "{}"))
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
        sFile = ((sPath or "") .. sFile)

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
