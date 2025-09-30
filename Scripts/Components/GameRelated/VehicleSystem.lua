-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- Contains the Server Vehicle System component, handling ownership and other events
-- ===================================================================================

Server:CreateComponent({
    Name = "VehicleSystem",
    FriendlyName = "Vehicles",
    Body = {

        MovementTypes = {
            Sea = "sea",
            Air = "air",
            Land = "land",
            Amphibious = "amphibious",
        },

        Initialize = function(self)
          --  self:Test()
        end,

       --[[
        Test = function(self)
            self:Log(LogVerbosity_Highest, "LogVerbosity_Highest")
            self:LogWarning(LogVerbosity_High, "LogVerbosity_High")
            self:LogError(LogVerbosity_Higher, "LogVerbosity_Higher")
            self:LogDebug(LogVerbosity_Low, "LogVerbosity_Low")
            self:Log(LogVerbosity_Lowest, "LogVerbosity_Lower")

            self:LogV(LogVerbosity_Highest, "2 LogVerbosity_Highest")
            self:LogWarningV(LogVerbosity_High, "2 LogVerbosity_High")
            self:LogErrorV(LogVerbosity_Higher, "2 LogVerbosity_Higher")
            self:LogFatalV(LogVerbosity_Low, "2 LogVerbosity_Low")
            self:LogV(LogVerbosity_Lower, "2 LogVerbosity_Lower")
        end,
       ]]

        Message = function(self, hUser, sMessage, tFormat)
            Server.Chat:TextMessage(ChatType_Error, hUser, sMessage, tFormat)
        end,

        ProcessHit = function(self, hVehicle, tHit)

            local hShooter = tHit.shooter
            local vPos = tHit.pos
            local vDir = tHit.dir
            local vNormal = tHit.normal
            local sType = tHit.type

            if (hShooter and hShooter.IsPlayer) then
                if (hShooter:IsSuperman(2) or (hShooter:IsSuperman() and sType == "melee")) then
                    tHit.damage = 0
                    Server.Utils:AddImpulse(hVehicle, vPos, vDir, (hVehicle:GetMass() * 100))
                end
            end

            local hDriver = hVehicle:GetDriver()
            if (((hDriver and hDriver.TempData.BouncyVehicles) or Server.Sandbox:GetState(SandboxState_BouncyVehicles)) and sType == "collision") then
                Server.Utils:AddImpulse(hVehicle, vPos, vDir, (hVehicle:GetMass() * math.min(15,tHit.damage)))
                tHit.damage = 0
            end
        end,

        OnStartStealVehicle = function(self, hVehicle, hThief)
            DebugLog("car alarm...!!")
            hVehicle.vehicle:StartAbandonTimer(true, 7)
            Script.SetTimer(6500, function()
                if (not hVehicle) then
                    return
                end
                hVehicle.vehicle:KillAbandonTimer()
            end)
        end,

        OnVehicleStolen = function(self, hVehicle, hThief)

            local pUtils = Server.Utils
            local hBuildBy = pUtils:GetEntity(hVehicle:GetTempInfo("BuildBy"))
            if (hBuildBy) then
                local iTeam1 = pUtils:GetTeamId(hBuildBy)
                local iTeam2 = pUtils:GetTeamId(hThief)

                if (iTeam1 ~= iTeam2) then
                    Server.Chat:TextMessage(ChatType_Error, hBuildBy, "@your_vehicle_wasStolen", { Class = "%1" }, hVehicle:GetLocaleType())
                end
            end
        end,

        OnVehicleBuild = function(self, hVehicle, hOwner, tItemDef)

            if (not hVehicle) then
                return
            end

            if (not hOwner) then
                g_gameRules.game:SetSynchedEntityValue(hVehicle.id, GlobalKeys.VehicleReserved, NULL_ENTITY)
                return
            end

            hVehicle:SetTempInfo("BuildBy", hOwner.id)
            hVehicle:SetTempInfo("OwnerFirstEnter", false)
            --hVehicle:SetInfo("DoomsdayMachine", g_gameRules:IsDoomsdayVehicle(hVehicle.class)) -- moved to Init in VehicleBase

            g_gameRules.game:SetSynchedEntityValue(hVehicle.id, GlobalKeys.VehicleLocked, NULL_ENTITY)
            g_gameRules.game:SetSynchedEntityValue(hVehicle.id, GlobalKeys.VehicleReserved, hOwnerId)
        end,

        Command_YieldVehicle = function(self, hOwner, hVehicle)
            local hBuildBy = Server.Utils:GetEntity(hVehicle:GetTempInfo("BuildBy"))
            if (hBuildBy) then
                if (hOwner.id ~= hBuildBy.id) then
                    return false, hOwner:LocalizeText("@not_your_vehicle")
                end
            else
                return false, "@vehicle_hasNoOwner"
            end
            hVehicle:SetTempInfo("BuildBy", nil)
            Server.Chat:BattleLog(BattleLog_Information, hOwner, "@v_yielded_UPPER")
            return true
        end,

        Command_UnlockVehicle = function(self, hVehicle, hOwner)

            local tLock = hVehicle:GetTempInfo("Lock")
            if (tLock) then
                Server.Chat:BattleLog(BattleLog_Information, hOwner, "@v_unlocked_u")
                --Server.Chat:TextMessage(ChatType_Center, hOwner, "[ @v_unlocked_u ]")
                g_gameRules.game:SetSynchedEntityValue(hVehicle.id, GlobalKeys.VehicleLocked, NULL_ENTITY)
                hVehicle:SetTempInfo("Lock", nil)
                return true
            end


            return false, hOwner:LocalizeText("@vehicle_isNot_locked")
        end,

        Command_LockVehicle = function(self, hOwner, hVehicle)

            local hBuildBy = Server.Utils:GetEntity(hVehicle:GetTempInfo("BuildBy"))
            if (hBuildBy and hOwner.id ~= hBuildBy.id) then
                return false, hOwner:LocalizeText("@not_your_vehicle")
            end

            local tLock = hVehicle:GetTempInfo("Lock")
            if (tLock) then
                self:Command_UnlockVehicle(hVehicle, hOwner)
                return true
            end

            Server.Chat:BattleLog(BattleLog_Information, hOwner, "@v_locked_u")
            --Server.Chat:TextMessage(ChatType_Center, hOwner, "[ @v_locked_u ]")
            g_gameRules.game:SetSynchedEntityValue(hVehicle.id, GlobalKeys.VehicleLocked, hOwner.id)
            hVehicle:SetTempInfo("Lock", {
                LockedBy = hOwner.id
            })
            return true
        end,

        OnEnterVehicle = function(self, hUser, hVehicle, tSeat)
            if (hUser.id == hVehicle:GetTempInfo("BuildBy")) then
                if (not hVehicle:GetTempInfo("OwnerFirstEnter")) then
                    if (not hUser.TempData.VehicleYieldTip) then
                        hUser.TempData.VehicleYieldTip = true
                        Server.Chat:TextMessage(ChatType_Center, hUser, "@vehicle_yield_tip")
                    end
                end
                hVehicle:SetTempInfo("OwnerFirstEnter", true)
            end
        end,

        CanEnterSeat = function(self, hUser, hVehicle, tSeat)

            local bOk = true
            local iLastSeat = hUser.TempData.CurrentSeatId

            local hBuildBy = Server.Utils:GetEntity(hVehicle:GetTempInfo("BuildBy"))
            if (hBuildBy and hUser.id ~= hBuildBy.id) then
                if (tSeat.isDriver) then
                    bOk = false
                end
            end

            if (not bOk) then
                if (not iLastSeat or iLastSeat == tSeat.seatId) then
                    if (not iLastSeat) then
                        local iAnyOther = hVehicle:GetFreeSeat(tSeat.seatId)
                        if (iAnyOther) then
                            hVehicle:EnterVehicle(hUser.id, iAnyOther, false)
                            return
                        end
                    end
                    self:Message(hUser, "@cannot_enter_vehicle", { Reason = (" (@not_your_vehicle)") })
                    hVehicle:ExitVehicle(hUser.id, false)
                else
                    self:Message(hUser, "@cannot_enter_driverSeat", { Reason = (" (@not_your_vehicle)") })
                    hVehicle:EnterVehicle(hUser.id, iLastSeat, false)
                end
                return
            else
                hUser.TempData.CurrentSeatId = tSeat.seatId
            end

            return bOk
        end,

        CanEnterVehicle = function(self, hUser, hVehicle)

            -- Check for pushing Boats
            DebugLog(hVehicle.vehicle:GetMovementType())
            if (hVehicle.vehicle:GetMovementType() == self.MovementTypes.Sea and not hVehicle.vehicle:IsSubmerged()) then
                local tHitInfo = hUser:GetHitPos(hUser:GetPos(), Vector.Down(), 1.75)
                -- We are not standing on the vehicle, so push it
                if (not tHitInfo or tHitInfo.entity ~= hVehicle) then
                    Server.Utils:AddImpulse(hVehicle, hVehicle:GetCenterOfMassPos(), Server.Utils:GetDir(hUser, hVehicle), hVehicle:GetMass() * (hUser:GetSuitMode(NANOMODE_STRENGTH) and 5 or 2.5))
                    return false
                end
                DebugLog("sea and not submerged")
            end

            -- Test Mode exception
            if (hUser:IsInTestMode()) then
                return true
            end

            local tLock = hVehicle:GetTempInfo("Lock")
            if (tLock) then
                if (tLock.LockedBy ~= hUser.id) then
                    self:Message(hUser, "@vehicle_locked")
                    return false
                end
            end

            local bOwnerEntered = hVehicle:GetTempInfo("OwnerFirstEnter")
            local hBuildBy = hVehicle:GetTempInfo("BuildBy")
            if (hBuildBy and Server.Utils:GetEntity(hBuildBy)) then
                if (hBuildBy ~= hUser.id and not bOwnerEntered) then
                    self:Message(hUser, "@vehicle_ownerNotEntered")
                    return false
                end
            end

            return true
        end,

        -- DISABLED: WHAT IS THIS??
        X_Event_TimerSecond = function(self)

            local aVehicles = Server.Utils:GetEntities({ ByMember = "vehicle" })
            if (#aVehicles == 0 or #Server.Utils:GetPlayers() == 0) then
                return
            end

            local function SetSync(hVehicle, iKey, hValue)
                hVehicle.SyncTemp = hVehicle.SyncTemp or {}
                if (hVehicle.SyncTemp[iKey] == hVehicle) then
                    return
                end
                hVehicle.SyncTemp[iKey] = hVehicle
                g_gameRules.game:SetSynchedEntityValue(hVehicle, iKey, hValue)
                DebugLog(iKey,hValue,"ok")
            end

            for _, hVehicle in pairs(aVehicles) do

                local bDestroyed = hVehicle.vehicle:IsDestroyed()
                local bSubmerged = hVehicle.vehicle:IsSubmerged()
                if (hVehicle.vehicle:GetMovementType() == self.MovementTypes.Sea) then
                    if (not bDestroyed) then
                        if (not bSubmerged) then
                            SetSync(hVehicle, GlobalKeys.EntityUsabilityMessage, "PUSH")
                        else
                            SetSync(hVehicle, GlobalKeys.EntityUsabilityMessage, nil)
                        end
                    end
                end
            end
        end,

        Event_OnActorSpawn = function(self, hActor)

            for _, hVehicle in pairs(Server.Utils:GetEntities({ ByMember = "vehicle" })) do
                local tBuyZone = hVehicle:GetInfo("BuyZone")
                if (tBuyZone) then
                    local hFactory = Server.Utils:GetEntity(tBuyZone.FactoryID)
                    if (hFactory and hFactory.class == "Factory") then
                        hFactory.onClient:ClSetBuyFlags(hActor:GetChannel(), hVehicle.id, tBuyZone.Flags)
                        DebugLog("sync zone???",hVehicle:GetName())
                    end
                end
            end
        end

    }
})