-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
--                          This file Contains Chat-Commands
-- ===================================================================================

Server:CreateComponent({
    Name = "ClientMod",
    Body = {

        Properties = {
            ClientScriptURL = "http://nomad.nullptr.one/~finch/CryMP-ServerClient.lua",
            MaxInstallAttempts = 999,

            -- Not in config please
            ObfuscateStackIds = false, -- edit: no reason to use this, can cause duped ids. let clients fake it, who cares.
        },

        CCommands = {
            { Name = "test_queue", FunctionName = "TestQueue", Description = "Adds various test scenarios to the code queue" },
            { Name = "clear_queue", FunctionName = "ClearGlobalQueue", Description = "Clears the entire Code Queue" },
        },

        Protected = {
            CodeStack = {
                LastId = 0,
                Stack = {},
            },
            CodeQueue = {
                Clients = {},
                Global  = {}
            },
        },

        Responses = {
            ClientInstalled = 10,
        },

        Initialize = function(self)
            self.Properties.ClientScriptURL = Server.Config:Get("Network.RemoteClientScript.URL", self.Properties.ClientScriptURL, ConfigType_String)
            self.Properties.MaxInstallAttempts = Server.Config:Get("Network.RemoteClientScript.MaxInstallAttempts", self.Properties.MaxInstallAttempts, ConfigType_Number)
        end,

        PostInitialize = function(self)
        end,

        OnReset = function(self)
            self:ClearGlobalQueue()
        end,

        IsComponentEnabled = function(self)
            return true
        end,

        ClearGlobalQueue = function(self)

            self:Log("Clearing Queue..")
            self.CodeQueue = {
                Clients = {},
                Global  = {}
            }
        end,

        TestQueue = function(self)

            local hEntity = Server.Utils:SpawnEntity({
                class = "RadarKit",
                position = Vector.Empty(),
                orientation = Vector.Up(),
                name = "test_clientModQueue"
            })

            self:QueueGlobalCode({
                Code = "System.LogAlways('error1')",
                Sync = {
                    BoundID = hEntity.id,
                    SyncID = "custom_id",
                }
            })

            System.RemoveEntity(hEntity.id)
            self:QueueGlobalCode({
                Code = "System.LogAlways('error2')",
                Sync = {
                    BoundID = hEntity.id,
                }
            })

            self:QueueGlobalCode({
                Code = "System.LogAlways('error3')",
                Sync = {
                }
            })

        end,

        PrepCode = function(self, sCode)
            local hId = (self.CodeStack.LastId + 1)
            if (self.Properties.ObfuscateStackIds) then
                hId = hId + math.random(66666, 77777)
            end
            self.CodeStack.LastId = (self.CodeStack.LastId + 1)

            --self.CodeStack[hId] = {
            table.insert(self.CodeStack.Stack, {
                ID      = hId,
                Code    = sCode,
                Trace   = debug.traceback() or "<Unknown>",
                Source  = LuaUtils.TraceSource(2):gsub("^%s+", ""):gsub("^%.+\\?", ""), -- skip the last two internal levels
                Time    = os.clock()
            })

            if (#self.CodeStack.Stack >= 255) then
                table.remove(self.CodeStack.Stack, 1)
            end

            return string.format("lua:%06d:%s", hId, sCode)
        end,

        QueueCode = function(self, hClientId, sCode)
            self.CodeQueue.Clients[hClientId] = self.CodeQueue.Clients[hClientId] or {}
            table.insert(self.CodeQueue.Clients[hClientId], sCode)
        end,

        QueueGlobalCode = function(self, tInfo)

            local tSync = tInfo.Sync
            if (not tSync) then
                return
            end

            local tGlobalStorage = self.CodeQueue.Global
            local hBoundID = tSync.BoundID or NULL_ENTITY
            if (tGlobalStorage[hBoundID] == nil) then
                tGlobalStorage[hBoundID] = {}
            end

            local hSyncID = (tSync.SyncID or ("Sync_" .. Server.Utils:UpdateCounter("ClientModGlobalSyncIndex")))
            tGlobalStorage[hBoundID][hSyncID] = {
                Client = tInfo.Code,
                Server = tInfo.Server,
                Predicate = tInfo.Predicate
            }

            DebugLog("index=",hSyncID)
        end,

        FindStackedCode = function(self, hId)
            for _, tStack in pairs(self.CodeStack.Stack) do
                if (tStack.ID == hId) then
                    return tStack
                end
            end
        end,

        OnRemoteError = function(self, hClient, hId, sError)

            self:LogError("Client %s{Red} Encountered a Script Error", hClient:GetName())
            self:LogError("> %s", sError or "<Null>")

            local tCode = self:FindStackedCode(hId)
            if (not tCode) then
                self:LogError("Failed to find Stack for Code %d")
                self:LogError("%s", sError or "<Null>")
                return
            end

            self:LogError("Stack ID: %d", tCode.ID)
            self:LogError("Source: %s", tCode.Source)
        end,

        ExecuteCodeOnClient = function(self, hClient, sCode)

            if (hClient.ClientMod.InstallFailed) then
                self:LogError("Ignoring Client %s", hClient:GetName())
                return
            elseif (not hClient.ClientMod.IsInstalled) then
                self:QueueCode(hClient.id, sCode)
                self:LogWarning("Queued Code for Client %s", hClient:GetName())
                return
            end

            Server.Statistics:Event(StatisticsEvent_ClientDataSent, #sCode)
            g_gameRules.onClient:ClWorkComplete(hClient:GetChannel(), hClient.id, sCode)
            self:Log("exec %s",sCode)
        end,

        ExecuteCode = function(self, tCode)

            local sCode, hId = self:PrepCode(tCode.Code)
            local tClients = tCode.Clients or tCode.Client
            if (not tClients) then
                self:LogError("No Clients to Execute Code on! Assuming All")
                tClients = ALL_PLAYERS
            end

            if (tClients == ALL_PLAYERS) then
                tClients = Server.Utils:GetPlayers()
            elseif (not table.IsRecursive(tClients)) then
                tClients = { tClients }
            end
            for _, hClient in pairs(tClients) do
                self:ExecuteCodeOnClient(hClient, sCode)
            end

            if (tCode.Sync) then
                self:QueueGlobalCode(tCode)
            end
        end,

        OnInstalled = function(self, hClient)
            self:LogEvent({
                Message = "@clientMod_installedOn",
                MessageFormat = { Client = hClient:GetName(), Time = Date:Colorize(Date:Format(hClient.ClientMod.LastInstall.Diff())) },
                Recipients = ServerAccess_Admin,
            })
            hClient.ClientMod.IsInstalled = true

            self:SyncQueue(hClient)
        end,

        SyncQueue = function(self, hClient)

            local iSyncedCount = 0
            local tClientQueue = self.CodeQueue.Clients[hClient.id]
            for _, sCode in pairs(tClientQueue or {}) do
                iSyncedCount = iSyncedCount + 1
                self:ExecuteCodeOnClient(hClient, sCode)
            end
            self.CodeQueue.Clients[hClient.id] = nil

            local tGlobalQueue = self.CodeQueue.Global
            for hBoundID, tStack in pairs(tGlobalQueue) do
                local hBoundEntity = Server.Utils:GetEntity(hBoundID)
                local sBoundEntityName = (hBoundEntity and hBoundEntity:GetName() or "GLOBAL")

                    if (hBoundID ~= NULL_ENTITY and hBoundEntity == nil) then
                        tGlobalQueue[hBoundID] = nil
                        self:Log("Removed Invalid Entity from Global Sync Queue")
                    else
                        self:Log("Synchronizing Stack for Entity '%s'", sBoundEntityName)
                        for hSyncID, tCode in pairs(tStack) do

                            tCode.SyncedOn = (tCode.SyncedOn or {})
                            if (not tCode.SyncedOn[hClient.id]) then
                                tCode.SyncedOn[hClient.id] = true

                                local fPredicate = tCode.Predicate
                                local bPredicateOk = true
                                if (fPredicate ~= nil) then
                                    local tParams = {}
                                    if (hBoundEntity) then
                                        tParams = { hBoundEntity }
                                    end
                                    table.insert(tParams, hClient)
                                    local bOk, hReturnOrError = pcall(fPredicate, unpack(tParams))
                                    if (not bOk) then
                                        self:LogError("Failed to Execute Predicate for Entity '%s' for SyncID '%s'", sBoundEntityName, tostring(hSyncID))
                                        self:LogError("%s", (hReturnOrError or "<Null>"))
                                    elseif (not hReturnOrError) then
                                        tStack[hSyncID] = nil
                                        bPredicateOk = false
                                        self:Log("Predicate failed to SyncID '%s' for Entity '%s', Discarding..", tostring(hSyncID), sBoundEntityName)
                                    end
                                end
                                if (bPredicateOk) then
                                    iSyncedCount = iSyncedCount + 1
                                    self:ExecuteCodeOnClient(hClient, tCode.Client)
                                    if (tCode.Server) then
                                        error("implementation missing.")
                                    end
                                end
                            else
                                self:Log("Code already Synced on Client '%s'", hClient:GetName())
                            end
                        end
                    end
            end

            if (iSyncedCount > 0) then
                self:LogEvent({ Message = "@clientMod_synched", MessageFormat = { Items = iSyncedCount }})
            end
        end,

        InstallMod = function(self, hClient)

            if (not self:IsComponentEnabled()) then
                return
            end

            local iAttempt = hClient.ClientMod.InstallAttempts

            self:Log("Installing on '%s'", hClient:GetName())
            self:LogEvent({
                Message = "@clientMod_installingOn" .. (iAttempt > 0 and (" (@attempt $4%d$9 \\ $4%d$9)"):format(iAttempt, self.Properties.MaxInstallAttempts) or ""),
                MessageFormat = { Client = hClient:GetName() },
                Recipients = ServerAccess_Admin,
            })

            hClient.ClientMod.IsInstalled     = false
            hClient.ClientMod.InstallAttempts = (iAttempt + 1)
            hClient.ClientMod.LastInstall.Refresh()
            RPC:OnPlayer(hClient, "Execute", { url = self.Properties.ClientScriptURL });
        end,

        Event_OnActorSpawn = function(self, hClient)

            hClient.ClientMod = {
                IsInstalled     = false,
                InstallFailed   = false,
                InstallAttempts = 0,
                LastInstall     = TimerNew(10),
            }

            self:InstallMod(hClient)
        end,

        Event_TimerSecond = function(self)

            for _, hClient in pairs(Server.Utils:GetPlayers()) do
                if (not hClient.ClientMod.IsInstalled) then
                    if (hClient.ClientMod.InstallAttempts <= self.Properties.MaxInstallAttempts) then
                        if (hClient.ClientMod.LastInstall.Expired()) then
                            self:InstallMod(hClient)
                        end
                    else
                        hClient.ClientMod.InstallFailed = true
                    end
                end
            end

            --test stack finder
            --self:ExecuteCode({Code = "ERROR()"})
        end,

        Event_RequestSpectatorTarget = function(self, hClient, iRequest)

            if ((iRequest <= 3 and iRequest >= -3) or not self:IsComponentEnabled()) then
                return true
            end

            local tResponses = self.Responses
            if (iRequest == tResponses.ClientInstalled) then
                self:OnInstalled(hClient)
            else
                return true
            end
            return false
        end,
    }
})