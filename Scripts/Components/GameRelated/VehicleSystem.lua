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
            --hVehicle:SetInfo("DoomsdayMachine", g_gameRules:IsDoomsdayVehicle(hVehicle.class)) -- moved to Init in vehiclebase

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

            local tLock = hVehicle:GetTempInfo("Lock")
            if (tLock) then
                if (tLock.LockedBy ~= hUser.id) then
                    self:Message(hUser, "@vehicle_locked")
                    return false
                end
            end

            local bOwnerEntered = hVehicle:GetTempInfo("OwnerFirstEnter")
            local hBuildBy = hVehicle:GetTempInfo("BuildBy")
            if (hBuildBy) then
                if (hBuildBy ~= hUser.id and not bOwnerEntered) then
                    self:Message(hUser, "@vehicle_ownerNotEntered")
                    return false
                end
            end

            return true
        end,

    }
})