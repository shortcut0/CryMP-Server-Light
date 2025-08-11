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

        CurrentEnvironment = {},
        EnvironmentChanges = {},
        TotalHookCount = 0,
        ActiveHooks = {
        },

        Initialize = function(self)
            ServerDLL.GameRulesInitScriptTables()
            self:LogEvent({
                Message = "@patcher_initialized",
                MessageFormat = { Classes = table.size(self.ActiveHooks), Functions = self.TotalHookCount }
            })

            if (Server:WasInitialized()) then
                for sClass, tHookInfo in pairs(self.ActiveHooks) do
                    for _, hEntity in pairs(Server.Utils:GetEntities({ ByClass = sClass })) do
                        self:HookObject(hEntity, sClass, tHookInfo.Body)
                    end
                    if (_G[sClass]) then
                        self:HookObject(_G[sClass], sClass, tHookInfo.Body)
                    end
                end
            end
        end,

        PostInitialize = function(self)

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
            local tChange = (self.EnvironmentChanges[sPath] or self:CompareEnvironment())
            if (table.emptyN(tChange)) then
                for _, sKey in pairs(tChange) do
                    if (_G[sKey] ~= nil and type(_G[sKey]) == "table") then
                        self:CheckClass(sKey)
                    end
                end
                self.EnvironmentChanges[sPath] = table.copy(tChange)
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

            self:HookObject(hClass, sClass, aBody)
        end,

        HookObject = function(self, hClass, sClass, aBody)

            local function Log(...)
                if (1) then
                    return
                end
                self:Log(...)
            end

            local function Stack(a, b)
                return ("%s.%s"):format(a, b)
            end

            local function Table(tArray, tParent, sStack)
                for i, v in pairs(tArray) do
                    if (type(v) == "table") then
                        if (tParent[i]) then
                            if (type(tParent[i]) ~= "table") then
                                error("mismatching types in Table() <stack:" .. Stack(sStack, i) .. ">")
                            end
                        else
                            tParent[i] = {}
                        end
                        Table(v, tParent[i], Stack(sStack, i))
                    else
                        tParent[i] = v
                        Log("Final stack: %s = %s", Stack(sStack, i), tostring(v))
                    end
                end
            end

            local function Body(tBody, tParent, sStack)
                for sKey, aInfo in pairs(tBody) do
                    Log("%s.%s=", sStack,sKey)
                    if (aInfo.Value and aInfo.Name) then
                        if (type(aInfo.Value) == "table") then
                            Log("Value is table")
                            if (tParent[aInfo.Name]) then
                                if (type(tParent[aInfo.Name]) ~= "table") then
                                    error("mismatching types in Body() <stack:" .. Stack(sStack, sKey) .. ">")
                                end
                            else
                                tParent[aInfo.Name] = {}
                            end
                            Table(aInfo.Value, tParent[aInfo.Name], Stack(sStack, aInfo.Name))
                        else
                            if (aInfo.Backup) then
                                local sBackup = ("%s_Backup"):format(sKey)
                                if (tParent[sKey] ~= nil and tParent[sBackup] == nil) then
                                    tParent[sBackup] = tParent[sKey]
                                    Log("backup of %s was made (%s)", Stack(sStack, sKey), sBackup)
                                end
                            end
                            tParent[sKey] = aInfo.Value
                            Log("Value Final stack: %s = %s", Stack(sStack, sKey),tostring(aInfo.Value))
                        end
                    else
                        if (tParent[sKey]) then
                            if (type(tParent[sKey]) ~= "table") then
                                error("mismatching types")
                            end
                        else
                            tParent[sKey] = {}
                        end
                        Body(aInfo, tParent[sKey], Stack(sStack, sKey))
                    end
                end
            end

            Body(aBody, hClass, sClass)

            --[[
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

            local function OnValue(tValue, tParent, sKey)
                if (type(tValue.Value) == "table") then
                    if (tParent[sKey] == nil) then
                        tParent[sKey] = {}
                    end
                    CopyToClass(tValue.Value, tParent[sKey], (sClass .. "." .. sKey))
                else
                    if (tValue.Backup) then
                        if (tParent[(sKey .. "_Backup")] == nil) then
                            tParent[(sKey .. "_Backup")] = tParent[sKey]
                        end
                    end
                    tParent[sKey] = tValue.Value
                end
            end

            local function OnBody(tBody, tParent)
                for sKey, tValue in pairs(tBody) do
                    self:Log("[body] key=%s",sKey)
                    if (tValue.IsBody) then

                        self:Log("key is a body..")
                        tParent[sKey] = tParent[sKey] or {}
                        OnBody(tValue, tParent[sKey])
                    else
                        self:Log("key is a value..")
                        OnValue(tValue, tParent, sKey)
                    end
                end
            end

            self:Log(table.tostring(aBody))
            for sKey, tValue in pairs(aBody) do
                self:Log("[1] key= %s",sKey)
                if (tValue.IsBody) then
                    self:Log("key is a body..")
                    OnBody(tValue, hClass[sKey])
                else
                    self:Log("key is value")
                    OnValue(tValue, hClass, sKey)
                end
            end
            ]]
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
                        Name = sPart,
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
            local sParent = (aInfo.Parent)
            local bHookNow = (aInfo.HookNow)
            if (IsArray(sClass)) then
                for _, tClass in pairs(sClass) do
                    self:HookClass({
                        Class   = tClass,
                        Body    = aInfo.Body,
                        Parent  = sParent,
                        ReplaceBody = aInfo.ReplaceBody,
                    })
                end
                return
            end

            local aClassEntities = Server.Utils:GetEntities({ ByClass = sClass })
            local aBody = aInfo.Body
            if (sParent) then
                if (not self.ActiveHooks[sParent]) then
                    self:Log("Creating new Parent Class '%s'",sParent)
                    self:HookBody(table.Merge(aInfo, {
                        Class = sParent,
                    }))
                end
                self.ActiveHooks[sClass] = {
                    ReplaceBody = (aInfo.ReplaceBody),
                    Body = self.ActiveHooks[sParent].Body
                }
                --for _, hEntity in pairs(aClassEntities) do
                --    self:Log("Hook Entity %s (%s)", hEntity:GetName(), hEntity.class)
                --end

                self:Log("Linked Class '%s' to Parent Class '%s'",sClass,sParent)
                return
            end

            self:HookBody(aInfo)
           -- for _, hEntity in pairs(aClassEntities) do
           --     self:HookObject(hEntity, sClass, aBody)
           -- end
        end,

        HookBody = function(self, aInfo)

            self.ActiveHooks[aInfo.Class] = (self.ActiveHooks[aInfo.Class] or {
                ReplaceBody = (aInfo.ReplaceBody),
                Body = {}
            })

            for _, aBodyPart in pairs(aInfo.Body) do
                self:InsertHook(aInfo.Class, aBodyPart.Name, aBodyPart.Value, aBodyPart.Backup)
            end

            if (aInfo.HookNow) then
                self:CheckClass(aInfo.Class)
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