-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- Contains Patched functions for 'Factory'
-- ===================================================================================

Server.Patcher:HookClass({
    Class = "Factory",
    Body  = {
        {
            ---------------------------
            --         Queue
            ---------------------------
            Name  = "Queue",
            Value = function(self, class, ownerId)

                local hPlayer = Server.Utils:GetEntity(ownerId)
                if (hPlayer and hPlayer.IsPlayer) then
                    --[[
                    table.checkM(self, "JobFloods", {})
                    table.checkM(self.JobFloods, ownerId, { Timer = Timer:New(0.5), Flood = 0 })

                    local aJob = self.JobFloods[ownerId]
                    local bExpired = aJob.Timer:Expired()

                    aJob.Timer:Refresh()
                    DebugLog("cspm")

                    if (not bExpired) then
                        aJob.Flood = (aJob.Flood + 1)
                        if (aJob.Flood > 2) then
                            DebugLog("smp")
                            return
                        end
                    else
                        aJob.Flood = 0
                    end]]
                end

                local slot=self:GetFreeSlot()
                if (slot) then
                    local time=self:GetBuildTime(class)
                    if (not time) then
                        Log("Vehicle Factory %s - Can't build that!", self:GetName())
                        return false
                    end
                    Log("build NOW")
                    self:StartBuilding(slot, time, class, ownerId, g_gameRules.game:GetTeam(ownerId))
                    return true
                end

                if (self:AddToQueue(class, ownerId)) then
                    return true
                else
                    Log("Vehicle Factory %s - No free factory slots available and queue is full!", self:GetName())
                    return false
                end
            end
        },
        {
            ---------------------------
            --      BuildVehicle
            ---------------------------
            Name  = "BuildVehicle",
            Value = function(self, hSlot)

                local def = g_gameRules:GetItemDef(hSlot.buildVehicle)
                if ((not def) or (not def.vehicle)) then
                    ServerLogError("Failed to find item def for class %s", hSlot.buildVehicle or "<null>")
                    return
                end

                local pos, dir = self:GetParkingLocation(hSlot)
                if (def.modification) then
                    self.spawnparams.properties.Modification=def.modification
                else
                    self.spawnparams.properties.Modification=nil
                end

                if (def.abandon) then
                    if (def.abandon>0) then
                        self.spawnparams.properties.Respawn.bAbandon=1
                        self.spawnparams.properties.Respawn.nAbandonTimer=def.abandon
                    else
                        self.spawnparams.properties.Respawn.bAbandon=0
                    end
                else
                    self.spawnparams.properties.Respawn.bAbandon=1
                    self.spawnparams.properties.Respawn.nAbandonTimer=300
                end

                self.spawnparams.position=pos;
                self.spawnparams.orientation=dir;

                -- make names unique!
                self.spawnparams.name=hSlot.buildVehicle.."_built_" .. Server.Utils:UpdateCounter()
                self.spawnparams.class=def.class;
                self.spawnparams.position.z=pos.z;

                if (self:GetTeamId()~=0 and g_gameRules.VehiclePaint) then
                    self.spawnparams.properties.Paint = g_gameRules.VehiclePaint[g_gameRules.game:GetTeamName(self:GetTeamId())] or "";
                end

                local vehicle = Server.Utils:SpawnEntity(self.spawnparams)
                if (vehicle) then
                    Log("Vehicle Factory %s - Built %s at door %s...", self:GetName(), hSlot.buildVehicle, hSlot.id);
                    vehicle.builtas=hSlot.buildVehicle;
                    vehicle.vehicle:SetOwnerId(hSlot.buildOwnerId);
                    g_gameRules.game:SetTeam(hSlot.buildTeamId, vehicle.id);
                    self:AdjustVehicleLocation(vehicle); -- adjust the position of the vehicle so that the vehicle is centered in the spawn helper,
                    -- using the center of the bounding box
                    vehicle:AwakePhysics(1);

                    -- Set build def
                    vehicle:SetInfo("BuildDef", table.copy(def))

                    if (def.buyzoneradius) then
                        self:MakeBuyZone(vehicle, def.buyzoneradius*1.15, def.buyzoneflags);

                        if (not def.spawngroup) then
                            g_gameRules.game:AddMinimapEntity(vehicle.id, 1, 0);
                        end
                    end

                    if (def.servicezoneradius) then
                        self:MakeServiceZone(vehicle, def.servicezoneradius*1.15);
                    end

                    if (def.spawngroup) then
                        g_gameRules.game:AddSpawnGroup(vehicle.id);
                    end
                end

                return vehicle
            end
        },
        {
            ---------------------------
            --      KillPlayers
            ---------------------------
            Name  = "KillPlayers",
            Value = function(self, hSlot)

                local pGR = g_gameRules
                if (not pGR.HitConfig.DisableFactoryGarageKills) then
                    return
                end

                local aEntities = self:GetNearbyEntities(true, false)
                if (aEntities) then
                    local iAreaID = hSlot.areaId
                    for _, hEntity in pairs(aEntities) do
                        if (self:IsPointInsideArea(iAreaID, hEntity:GetWorldPos(g_Vectors.temp_v1))) then
                            if (hEntity.actor and (not hEntity:IsDead())) then
                                pGR:CreateHit(hEntity.id, hEntity.id, NULL_ENTITY, 1000)
                            end
                        end
                    end
                end
            end
        },
        {
            ---------------------------
            --      UpdateSlot
            ---------------------------
            Name  = "UpdateSlot",
            Value = function(self, hSlot, iFrameTime_)

                if (not hSlot.enabled) then
                    return
                end

                local iFrameTime = Server.Utils:FrameTime(hSlot)
                local pGR = g_gameRules

                if (hSlot.building) then
                    hSlot.buildTimer = (hSlot.buildTimer - iFrameTime)
                    --DebugLog(hSlot.buildTimer,iFrameTime,_time-self.LastUpdateTime,iFrameTime_)
                    if (hSlot.buildTimer <= 0) then
                        local hVehicle = self:BuildVehicle(hSlot)
                        self:StopBuilding(hSlot, true)

                        if (pGR.Server.OnVehicleBuilt) then
                            pGR.Server.OnVehicleBuilt(pGR, self, hSlot.buildVehicle, hVehicle.id, hSlot.buildOwnerId, hSlot.buildTeamId, hSlot.id)
                        end

                        self.allClients:ClVehicleBuilt(hSlot.buildVehicle, hVehicle.id, hSlot.buildOwnerId, hSlot.buildTeamId, hSlot.id)
                        hSlot.builtVehicleId = hVehicle.id
                    end
                end

                if (hSlot.opening) then
                    hSlot.openTimer = (hSlot.openTimer - iFrameTime)
                    if (hSlot.openTimer <= 0) then

                        if (not self.isClient) then
                            self:OpenSlot(hSlot, true, false)
                        end

                        -- need to tell the clients that this is a buy zone
                        if (hSlot.builtVehicleId) then
                            local aDef = pGR:GetItemDef(hSlot.buildVehicle);
                            if (aDef.buyzoneradius and aDef.buyzoneflags) then

                                self.allClients:ClSetBuyFlags(hSlot.builtVehicleId, aDef.buyzoneflags)
                                local hVehicle = Server.Utils:GetEntity(hSlot.builtVehicleId)
                                if (hVehicle) then

                                    -- Save it for sync for clients that connect after the fact
                                    hVehicle:SetInfo("BuyZone", {
                                        FactoryID = self.id,
                                        Flags     = aDef.buyzoneflags,
                                        Radius    = aDef.buyzoneradius,
                                    })
                                    --DebugLog("set sync for vehicle bz")
                                end
                            end
                        end

                        self.allClients:ClOpenSlot(hSlot.id, true, false)
                        hSlot.opening = false
                        hSlot.builtVehicleId = nil
                    end

                elseif(hSlot.closing) then
                    self:KillPlayers(hSlot)
                    hSlot.closeTimer = (hSlot.closeTimer - iFrameTime)

                    if (hSlot.closeTimer <= 0) then
                        if (not self.isClient) then
                            self:OpenSlot(hSlot, false, false)
                        end

                        self.allClients:ClOpenSlot(hSlot.id, false, false)
                        hSlot.closing = false
                    end
                end
            end
        },
    }
})