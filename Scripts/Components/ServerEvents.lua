-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- This is the Server Event and Callback Handler
-- ===================================================================================

Server:CreateComponent({
    Name = "Events",
    Body = {

        ComponentPriority = PRIORITY_HIGHER,
        Properties = {

            -- Error Threshold after which a specific event gets disabled
            ErrorCountThreshold = 10,
        },

        Callbacks = {

            -- ============================================================================
            -- Script Callbacks

            OnValidationFailed = function(this, hPlayer, sProfile, sError, iHTTPCode)
                Server.AccessHandler:OnValidationFailed(hPlayer)
            end,

            OnProfileValidated = function(this, hPlayer, sProfile)
                Server.ActorHandler:OnProfileValidated(hPlayer, sProfile)
                Server.AccessHandler:OnProfileValidated(hPlayer, sProfile)
            end,

            OnActorSpawn = function(this, hPlayer)
                return Server.Events:CheckComponentEvents("OnActorSpawn", hPlayer)
            end,

            RequestSpectatorTarget = function(this, hPlayer, iCode)
                return Server.Events:CheckComponentEvents("RequestSpectatorTarget", hPlayer, iCode)
            end,

            OnPostInitialize = function(this)
                g_gameRules:PostInitialize()
                Server.Events:CallEvent(ServerEvent_OnPostInit)
            end,

            OnInitialize = function(this)
                Server.Events:CallEvent(ServerEvent_OnInit)
            end,

            -- ============================================================================
            -- C++ Callbacks

            OnUpdate = function(self, ...)
                Server:OnUpdate(...)
                Server.Events:CheckComponentEvents("OnUpdate")
                Server.Events:CallEvent(ServerEvent_OnUpdate, System.GetFrameTime(), System.GetFrameID())
            end,

            OnTimer = function(self, iTimerID)

                if (iTimerID == 1) then
                    Server.Events:CheckComponentEvents("TimerSecond")
                    Server.Events:CallEvent(ServerEvent_OnTimerSecond, iTimerID)

                elseif (iTimerID == 2) then
                    Server.Events:CallEvent(ServerEvent_OnTimerMinute, iTimerID)

                elseif (iTimerID == 3) then
                    Server.Events:CallEvent(ServerEvent_OnTimerHourly, iTimerID)

                end
            end,

            OnCheat                 = function()
            end,
            RequestDropWeapon       = function()
            end,
            RequestPickWeapon       = function()
            end,
            RequestUseWeapon        = function() end,
            OnWeaponDropped         = function() end,
            OnShoot                 = function(self, hShooter, hWeapon, hAmmo, sAmmo, vPos, vHit, vDir)
                Server.PlayerEquipment:OnWeaponFired(hShooter, hWeapon, hAmmo, sAmmo, vPos, vHit, vDir)
            end,
            OnStartReload           = function() end,
            OnEndReload             = function() end,
            OnMelee                 = function(self, hShooterId, hWeaponId)
                Server.PlayerEquipment:OnWeaponMelee(hShooterId, hWeaponId)
            end,
            RequestPickObject       = function() end,
            OnObjectPicked          = function() end,
            OnExplosivePlaced       = function() end,
            OnExplosiveRemoved      = function() end,
            OnHitAssistance         = function() end,
            OnConnection            = function(this, iChannel, sIPAddress)
                Server.Network:OnChannelCreated(iChannel, sIPAddress)
            end,
            OnChannelDisconnect     = function(this, iChannel, sDescription)
                Server.Network:OnChannelDisconnect(iChannel, sDescription)
            end,
            OnClientDisconnect      = function(self, iChannel, hPlayer, sDescription)
                Server.Network:OnClientDisconnect(hPlayer, iChannel, sDescription)
                Server.ActorHandler:OnPlayerDisconnect(hPlayer)
            end,
            OnClientEnteredGame     = function() end,
            OnClientConnect     = function(self, hPlayer, iChannel, bIsReset, bWasOnHold)
                Server.Network:OnClientConnected(hPlayer, iChannel)
                Server.Statistics:Event(StatisticsEvent_PlayerRecord, #(Server.Utils:GetPlayers() or {}))
            end,
            OnWallJump              = function(self, hPlayerId)

                local hPlayer = Server.Utils:GetEntity(hPlayerId)
                if (hPlayer and hPlayer.IsPlayer) then
                    local sWeaponClass = hPlayer:GetCurrentItemClass()
                    if (sWeaponClass == "Fists" and hPlayer.Timers.WallJump.expired_refresh()) then
                        Server.Statistics:Event(StatisticsEvent_OnWallJumped)
                    end
                end
            end,
            OnChatMessage           = function(self, hSender, hTarget, sMessage, iType, iForcedTeam, bSentByServer)
                return Server.Chat:OnChatMessage(hSender, hTarget, sMessage, iType, iForcedTeam, bSentByServer)
            end,
            OnEntityCollision       = function() end,
            OnSwitchAccessory       = function() end,
            OnProjectileHit         = function(self, hShooterId, hProjectileId, bDestroyed, iDamage, nWeapon, vPos, vNormal)
                return Server.PlayerEquipment:OnProjectileHit(hShooterId, hProjectileId, bDestroyed, iDamage, nWeapon, vPos, vNormal)
            end,
            OnLeaveWeaponModify     = function() end,
            OnProjectileExplosion   = function() end,
            CanStartNextLevel       = function(self)
                return Server.MapRotation:CanStartNextLevel()
            end,
            OnLevelStart       = function(self)
                return Server:OnLoadingStart()
            end,
            OnRadarScanComplete     = function(self, hShooterID, hWeaponID, iScanDistance)
                g_gameRules:OnRadarScanComplete(hShooterID, hWeaponID, iScanDistance)
            end,
            OnGameShutdown          = function() end,
            OnMapStarted            = function() end,
            OnEntitySpawn           = function(this, hEntity, hEntityId, bVehicle, bItem, bActor, iType)

                -- We assume that this is done before ANYTHING else on a new actor/client, but not 100% sure!
                if (bActor) then
                    Server.ActorHandler:OnActorSpawn(hEntity)
                    g_gameRules:OnPlayerSpawn(hEntity)
                end

                if (bVehicle) then
                end

                if (bItem) then
                end

                Server.Patcher:OnEntitySpawned(hEntity)
            end,
            OnVehicleSpawn          = function() end,
            OnLoadingScript          = function(self, sFileName)
                Server.Patcher:OnLoadingScript(sFileName)
            end,
            OnScriptLoaded          = function(self, sFileName)
                Server.Patcher:OnScriptLoaded(sFileName)
            end,
            OnMapCommand            = function() end,
            OnScriptError            = function(this, sError)
                Server.ErrorHandler:HandleError(sError)
            end,

        },

        LinkedEvents = {
        },

        Initialize = function(self)
            for hEvent = 1, ServerEvent_MAX do
                table.checkM(self.LinkedEvents, hEvent, {})
            end
            return true
        end,

        PostInitialize = function(self)
        end,

        OnReset = function(self)
            for hEvent = 1, ServerEvent_MAX do
                self.LinkedEvents[hEvent]  = {}
            end
        end,

        TestOne = function(MASTER, ...)
            ServerLog("MASTER=%s, PUSHED=%s",ToString(MASTER),table.concat({...},","))
        end,

        CheckComponentEvents = function(self, sEvent, ...)

            sEvent = ("Event_%s"):format(sEvent)

            local aMostRecentCall = {}
            for _, sComponent in pairs(Server.InitializedComponents) do
                local tComponent = Server[sComponent]
                if (tComponent[sEvent] and tComponent:IsComponentEnabled()) then
                    aMostRecentCall = { tComponent[sEvent](tComponent, ...) }
                end
            end
            return unpack(aMostRecentCall)
        end,

        Call = function(self, hEvent, ...)
            local hFunction = self.Callbacks[hEvent]
            if (not hFunction) then
                self:LogError("Attempt to call invalid Event %s", ToString(hEvent))
                return
            end

            hFunction(self, ...)
        end,

        CheckEvent = function(self, hEvent)
            --return (hEvent ~= nil and table.find(self.EventList, hEvent))
            return (IsNumber(hEvent) and hEvent > 0 and hEvent < ServerEvent_MAX)
        end,

        CallEvent = function(self, hEvent, ...)

            if (not self:CheckEvent(hEvent)) then
                return self:LogError("Attempt to call Invalid Event '%s'", ToString(hEvent))
            end

            local aReturns = {}
            local aReturn, bOk, sError

            for _, aInfo in pairs(self.LinkedEvents[hEvent]) do
                if (aInfo.Active) then
                    local aPushArguments = { ... }
                    if (aInfo.PushArgs) then
                        -- keep push arguments first
                        aPushArguments = table.appendA(table.copy(aInfo.PushArgs), aPushArguments)
                    end
                    if (aInfo.Object) then
                        table.insertFirst(aPushArguments, aInfo.Object)
                    end

                    aReturn = { pcall(aInfo.Function, unpack(aPushArguments)) }
                    bOk, sError = aReturn[1], aReturn[2]
                    if (not bOk) then

                        self:LogError("Error while Calling Event %s", ToString(hEvent))
                        self:LogError("> %s", ToString(sError or "<Null>"))

                        aInfo.ErrorCount = (aInfo.ErrorCount + 1)
                        if (aInfo.ErrorCount >= self.Properties.ErrorCountThreshold) then
                            aInfo.Active = false
                            self:LogError("Disabled Link %s for Event %s (Error Overflow)", ToString(_), ToString(hEvent))
                        end
                    else
                        table.insert(aReturns, aReturn)
                    end
                end
            end

            return aReturns
        end,

        LinkEvent = function(self, hEvent, pObject, pFunction, ...)

            if (not hEvent or not self:CheckEvent(hEvent)) then
                return self:LogError("Attempt to link NO Event")
            end

            if (not pFunction) then
                return self:LogError("Attempt to link NO Function to event '%s'", ToString(hEvent))
            end

            local hFunction = (IsFunction(pFunction) and pFunction or CheckGlobal(pFunction))
            if (not IsFunction(hFunction)) then
                return self:LogError("Attempt to link NON Function to event '%s'", ToString(hEvent))
            end

            local hObject = pObject
            if (hObject) then
                if (IsString(pObject)) then
                    hObject = CheckGlobal(pObject)
                end
                if (not IsArray(hObject)) then
                    return self:LogError("Attempt to push NON Object to event '%s'", ToString(hObject))
                end
            end

            table.insert(self.LinkedEvents[hEvent], {

                Active = true,
                ErrorTimer = TimerNew(),
                ErrorCount = 0,

                Function = hFunction,
                PushArgs = { ... },
                Object = hObject,
            })

        end

    }
})