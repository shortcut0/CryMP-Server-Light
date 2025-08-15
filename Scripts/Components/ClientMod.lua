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
        },

        Protected = {
            CodeStack = {},
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

        IsComponentEnabled = function(self)
            return true
        end,

        PrepCode = function(self, sCode)
            local hId = (#self.CodeStack + 1)
            self.CodeStack[hId] = {
                Code    = sCode,
                Trace   = debug.traceback() or "<Unknown>",
                Time    = os.clock()
            }

            if (hId >= 255) then
            --    table.remove(self.CodeStack, 1)
            end

            return string.format("lua:%06d:%s", hId, sCode)
        end,

        QueueCode = function(self, hClientId, sCode)
            self.CodeQueue.Clients[hClientId] = self.CodeQueue.Clients[hClientId] or {}
            table.insert(self.CodeQueue.Clients[hClientId], sCode)
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

            local sCode = self:PrepCode(tCode.Code)
            local tClients = tCode.Clients
            if (tClients == ALL_PLAYERS) then
                tClients = Server.Utils:GetPlayers()
            elseif (not table.IsRecursive(tClients)) then
                tClients = { tClients }
            end
            for _, hClient in pairs(tClients) do
                self:ExecuteCodeOnClient(hClient, sCode)
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

            local tClientQueue = self.CodeQueue.Clients[hClient.id]
            for _, sCode in pairs(tClientQueue or {}) do
                self:ExecuteCodeOnClient(hClient, sCode)
            end
            self.CodeQueue.Clients[hClient.id] = nil

            local tGlobalQueue = self.Code.Global
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