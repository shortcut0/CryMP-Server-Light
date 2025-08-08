-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0, C4leb                           --
--                  This file contains the Entity Patcher Component
-- ===================================================================================

Server:CreateComponent({
    Name = "Patcher",
    Body = {

        Properties = {

            -- Enables replacing of dangerous RMI Flags. Without this, 'Haxors' can easily crash the server by flooding requests
            FixDangerousRMIFlags = true
        },

        ExternalData = {
            { Name = "*.lua$", Path = SERVER_DIR_SCRIPTS .. "/Game/Patcher/", Recursive = true, ReadOnly = true }
        },

        TotalHookCount = 0,
        ActiveHooks = {
        },

        Initialize = function(self)
        end,

        PostInitialize = function(self)

            ServerDLL.GameRulesInitScriptTables()
            self:LogEvent({
                Message = "@patcher_initialized",
                MessageFormat = { Classes = table.size(self.ActiveHooks), Functions = self.TotalHookCount }
            })
        end,

        SnapshotEnvironment = function(self)
            self.CurrentEnvironment = {}
            for sKey in pairs(_G) do
                self.CurrentEnvironment[sKey] = true
            end
        end,

        CompareEnvironment = function(self)
            local tOld = self.CurrentEnvironment or {}
            local tChanges = {}
            for sKey in pairs(_G) do
                if (not tOld[sKey]) then -- new global
                    table.insert(tChanges, sKey)
                end
            end
            return tChanges
        end,

        OnLoadingScript = function(self, sPath)
            self:SnapshotEnvironment()
        end,

        OnScriptLoaded = function(self, sPath)
            local tChange = self:CompareEnvironment()
            if (table.emptyN(tChange)) then
                for _, sKey in pairs(tChange) do
                    if (_G[sKey] ~= nil and type(_G[sKey]) == "table") then
                        self:CheckClass(sKey)
                    end
                end
            end
        end,

        CheckClass = function(self, sClass)
            local aClassInfo = self.ActiveHooks[sClass]
            if (not aClassInfo) then
                return
            end

            local aBody = aClassInfo.Body
            local hClass = _G[sClass]
            if (aClassInfo.ReplaceBody) then
                for sKey in pairs(hClass) do
                    hClass[sKey] = nil
                end
            end

            local function CopyToClass(aTable, aTarget, sStack)
                for sKey, tValue in pairs(aTable) do
                    if (type(tValue) == "table") then
                        if (aTarget[sKey] == nil) then
                            aTarget[sKey] = {}
                        end
                        CopyToClass(tValue, aTarget[sKey], (sStack .. "." .. sKey))
                    else
                        aTarget[sKey] = tValue
                    end
                end
            end

            for sKey, tValue in pairs(aBody) do
                if (type(tValue.Value) == "table") then
                    if (hClass[sKey] == nil) then
                        hClass[sKey] = {}
                    end
                    CopyToClass(tValue.Value, hClass[sKey], (sClass .. "." .. sKey))
                else
                    if (tValue.Backup) then
                        if (hClass[(sKey .. "_Backup")] == nil) then
                            hClass[(sKey .. "_Backup")] = hClass[sKey]
                        end
                    end
                    hClass[sKey] = tValue.Value
                end
            end
        end,

        InsertHook = function(self, sClass, sMember, hValue, bCreateBackup)
            local hIndex = self.ActiveHooks[sClass].Body
            local aParts = string.split(sMember, ".")
            for i = 1, #aParts do
                local sPart = aParts[i]
                if (i == #aParts) then
                    self.TotalHookCount = (self.TotalHookCount + 1)
                    hIndex[sPart] = {
                        Backup = bCreateBackup,
                        Value = hValue
                    }
                else
                    hIndex[sPart] = hIndex[sPart] or {}
                    hIndex = hIndex[sPart]
                end
            end
        end,

        HookClass = function(self, aInfo)

            if (table.IsRecursive(aInfo)) then
                for _, tInfo in pairs(aInfo) do
                    self:HookClass(tInfo)
                end
                return
            end

            local sClass = (aInfo.Class)
            local aBody = aInfo.Body

            self.ActiveHooks[sClass] = (self.ActiveHooks[sClass] or {
                ReplaceBody = (aInfo.ReplaceBody),
                Body = {}
            })

            for _, aBodyPart in pairs(aBody) do
                self:InsertHook(sClass, aBodyPart.Name, aBodyPart.Value, aBodyPart.Backup)
            end

            if (aInfo.HookNow) then
                self:CheckClass(sClass)
            end

        end,

        FixRMIFlags = function(self, tInfo)

            if (not self.Properties.FixDangerousRMIFlags) then
                return
            end

            local iFixedCount = 0
            for sFunction, aMethodParams in pairs(tInfo.ClientMethods) do
                if (aMethodParams[2] == POST_ATTACH) then
                    aMethodParams[2] = NO_ATTACH
                    iFixedCount = (iFixedCount + 1)
                end
            end
            for sFunction, aMethodParams in pairs(tInfo.ServerMethods) do
                if (aMethodParams[2] == POST_ATTACH) then
                    aMethodParams[2] = NO_ATTACH
                    iFixedCount = (iFixedCount + 1)
                end
            end

            if (iFixedCount > 0) then
                self:LogEvent({
                    Message = "@rmi_flags_fixed",
                    MessageFormat = { Class = (table.lookup(_G, tInfo.Class) or "Unknown"), Count = iFixedCount },
                    Recipients = ServerAccess_GetAdmins(),
                })
            end
        end

    }
})