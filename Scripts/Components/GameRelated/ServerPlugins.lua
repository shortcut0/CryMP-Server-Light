-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- Contains the Server Plugin Handler
-- ===================================================================================

Server:CreateComponent({
    Name = "Plugins",
    Body = {

        ComponentPriority = PRIORITY_LOWER,

        ExternalData = {
            { Name = "*.lua$", Path = SERVER_DIR_PLUGINS, Recursive = true, ReadOnly = true }
        },

        Protected = {
            PluginData = {},
        },

        Plugins = {},
        PluginExternal = {}, -- No need to protect this

        Initialize = function(self)

            self:Log("Loaded %d Plugins", table.count(self.Plugins))

            self:ConfigurePlugins()
            self:Log("Initializing Plugins..")
            self:PluginEvent("Initialize")
        end,

        PostInitialize = function(self)
            self:Log("Post-Initializing Plugins..")
            self:PluginEvent("PostInitialize")
        end,

        GetPlugin = function(self, sName)
            return self.Plugins[sName]
        end,

        CreatePlugin = function(self, sName, tBody)

            local sNameLower = (sName or ""):lower()
            if (string.empty(sName)) then
                self:LogError("Invalid Plugin Name")
                return
            end

            if (self:GetPlugin(sName)) then
                self:LogError("A Plugin by the Name '%s' Exists already", sName)
                return
            end

            if (not tBody) then
                self:LogError("No body provided for Plugin '%s'", sName)
                return
            end

            tBody.IsEnabled = tBody.IsEnabled or function(this)
                return this.PluginStatus ~= false and this.PluginStatus ~= 0 and this.PluginStatus ~= PLUGIN_DISABLED
            end

            tBody.PluginName = tBody.PluginName or sName
            tBody.PluginFriendlyName = tBody.PluginFriendlyName or sName
            tBody.GetName = tBody.GetName or function(this) return this.PluginName end
            tBody.GetFriendlyName = tBody.GetFriendlyName or function(this) return this.PluginFriendlyName end
            tBody.LogEvent = tBody.LogEvent or function(this, tEvent)

                if (tEvent.Recipients == nil) then
                    tEvent.Recipients = Server.Utils:GetPlayers()
                    this:LogWarning("No Recipients to LogEvent()")
                end

                if (tEvent.Event == nil) then tEvent.Event = this:GetFriendlyName() end
                if (tEvent.Class == nil) then tEvent.Class = this:GetFriendlyName() end
          --      tEvent.Event = ("%s] [%s"):format(Server.Plugins:GetFriendlyName(), this:GetFriendlyName())

                -- Overwrite class
                tEvent.Class = {
                    Class = "Plugins",
                    Tag = this:GetFriendlyName(),
                }
                Server.Logger:LogEvent(tEvent)
            end

            -- Check for previous data
            local tData = self.PluginData[sName]
            if (tData) then
                for sKey in pairs(tBody.Protected or {}) do
                    self:LogV(LogVerbosity_Low, "Restored Data Key %s", sKey)
                    tBody[sKey] = tData[sKey]
                end
            else
                self.PluginData[sName] = {}
                for sKey, hDefault in pairs(tBody.Protected or {}) do
                    self:LogV(LogVerbosity_Low, "Create Protected Data Key %s", sKey)
                    tBody[sKey] = hDefault
                    self.PluginData[sName][sKey] = hDefault
                end
            end

            local aExternalData = tBody.ExternalData
            if (aExternalData) then
                self.PluginExternal[sName] = aExternalData
            end

            -- Dirty little hacks
            Server:CreateLogAbstract(tBody, ("%s] [%s"):format(self:GetName(), tBody:GetName()))
            if (aExternalData and Server:LoadComponentExternalFiles(tBody, sName, false, aExternalData) == false) then
                return false
            end

            self.Plugins[sName] = tBody
        end,

        ConfigurePlugins = function(self)

            self:Log("Configuring Plugins..")
            for _, tPlugin in pairs(self.Plugins) do
                self:ConfigurePlugin(tPlugin)
            end
        end,

        ConfigurePlugin = function(self, tPlugin)

            local pConfig = Server.Config

            if (tPlugin.Config == nil) then
                tPlugin.Config = {}
            end

            local tPluginConfig = tPlugin.PluginConfig
            if (not tPluginConfig) then
                return
            end

            local sPluginName = tPlugin:GetName()
            --self:Log("Configuring Plugin '%s'", sPluginName)

            local iAssignments = 0
            local iDefaults = 0

            for _, tInfo in pairs(tPluginConfig) do

                local bLogNotFound = true
                if (tInfo.Config and tInfo.Key) then
                    local sConfigNest = ("Plugins.%s.%s"):format(sPluginName, tInfo.Config)
                    if (tInfo.Config:sub(1, 1) == "$") then
                        sConfigNest = tInfo.Config:sub(2)

                    else
                        local iBacktrack = string.len(string.match(tInfo.Config, "^(%.+)") or "")
                        if (iBacktrack > 0) then
                            sConfigNest = ("Plugins.%s.%s"):format(sPluginName, string.gsub(tInfo.Config, "^%.+", ""))
                            for i = 1, iBacktrack do
                                if (string.count(sConfigNest, "%.") >= 1) then
                                    sConfigNest = sConfigNest:gsub("^(%w+%.)", "")
                                else
                                    self:LogWarning("Plugin '%s': Config Branch backtracking too far!", sPluginName)
                                    self:LogWarning("Config '%s' for Key '%s'", tInfo.Config, tInfo.Key)
                                    bLogNotFound = false
                                    break
                                end
                            end
                        end
                    end

                    local sPluginNest = ("Config.%s"):format(tInfo.Key)
                    if (tInfo.Key:sub(1, 1) == "$") then
                        sPluginNest = tInfo.Key:sub(2)
                    end

                    --self:Log("%s TO %s",sConfigNest,sPluginNest)

                    local hConfigValue, bIsDefault = pConfig:Get(sConfigNest, tInfo.Default, tInfo.Type)
                    table.Assign(tPlugin, sPluginNest, hConfigValue)
                    iAssignments = iAssignments + 1
                    if (bIsDefault) then
                        if (bLogNotFound) then
                            self:LogWarning("Cannot find Config '%s' for Key '%s' for Plugin '%s'", sConfigNest, sPluginNest, sPluginName)
                        end
                        iDefaults = iDefaults + 1
                    end
                else
                    self:LogWarning("Plugin '%s': Bad configuration entry found on Index %s. Missing Config or Key field!", sPluginName, tostring(_))
                end
            end

            if (iAssignments > 0) then
                self:Log("Configured Plugin '%s' With %d Keys and %d Defaults", sPluginName, iAssignments, iDefaults)
            end
        end,

        ExportPluginData = function(self)
            local bOk
            local iTotalSize = 0
            for sPlugin, aKeys in pairs(self.PluginExternal) do
                local tPlugin = self.Plugins[sPlugin]
                if (tPlugin) then
                    for _, aKeyInfo in pairs(aKeys) do
                        local aData = tPlugin[aKeyInfo.Key]
                        if (not aKeyInfo.IsRecursive and not aKeyInfo.ReadOnly and aData ~= nil) then
                            local sComment = ("This file Contains data which will be loaded into the '%s' Key for the Server Plugin: '%s'"):format(aKeyInfo.Key, sPlugin)
                            bOk, iTotalSize = Server.FileLoader:SaveFile(aData, aKeyInfo.Name, aKeyInfo.Path, sComment)
                            if (not bOk) then
                                -- Edit: after looking at the behavior of the SaveFile function, I realised that this is NEVER called.
                                self:LogFatal("Failed to Export Plugin Data from Key '%s' to file '%s'", aKeyInfo.Key, aKeyInfo.Name)
                            end
                        end
                    end
                end
            end

            self:LogV(LogVerbosity_Low, "Exported %d Keys from %d Plugins (Size %s)", table.countRec(self.PluginExternal, nil, 1), table.count(self.PluginExternal), Server.Utils:ByteSuffix(iTotalSize))
        end,

        PluginEvent = function(self, sEvent, ...)
            for sPlugin, tPlugin in pairs(self.Plugins) do
                if (tPlugin:IsEnabled()) then
                    local fEvent = tPlugin[sEvent]
                    if (fEvent) then
                        local bOk, sError = pcall(fEvent, tPlugin, ...)
                        if (not bOk) then
                            self:LogError("Event %s Failed on Plugin %s (%s)", sEvent, sPlugin, tPlugin:GetName())
                            self:LogError("Error: %s", (sError or "<Null>"))
                        end
                    end
                end
            end
        end,

        -- ==========================================================================
        -- Events

        Event_OnActorSpawn = function(self, hActor)
            self:PluginEvent("Event_OnActorSpawn", hActor)
        end,

        Event_OnActorTick = function(self, hActor)
            self:PluginEvent("Event_OnActorTick", hActor)
        end,

        Event_TimerSecond = function(self)
            self:PluginEvent("Event_TimerSecond")
        end,

        Event_OnProfileValidated = function(self, hActor, sProfile)
            self:PluginEvent("Event_OnProfileValidated", hActor, sProfile)
        end,

        Event_OnClientDisconnect = function(self, pClient, iChannel, sDescription)
            self:PluginEvent("Event_OnClientDisconnect", pClient, iChannel, sDescription)
        end,

        Event_OnExportScriptData = function(self)
            self:ExportPluginData()
            self:PluginEvent("OnExportScriptData")
        end,

    },
})