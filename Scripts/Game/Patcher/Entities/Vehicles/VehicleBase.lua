-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- Contains Patched functions for 'VehicleBase'
-- ===================================================================================

Server.Patcher:HookClass({
    Parent = "VehicleBase",
    Class = Server.Utils:GetVehicleClasses(),
    Body  = {
        {
            -------------------------------
            ---        InitCryMP
            -------------------------------
            Name = "InitCryMP",
            Value = function(self)


                self.Properties.ServerInfo = (self.Properties.ServerInfo or {})
                self.ServerInfo = self.Properties.ServerInfo -- Persistent info staying even after respawns
                self.ServerInfo_Temp = {} -- Temporary data not passed down to respawns

                self.IsOriginalSpawn = (not self.Properties.IsChildSpawn)
                self.Properties.IsChildSpawn = true
                self.HasBeenUsed = false

                local sModification = self.Properties.Modification
                self:SetInfo("DoomsdayMachine", IsAny(sModification, "TACCannon", "Singularity"))
                ServerLog("Is machine: %s",tostring(self:GetInfo("DoomsdayMachine")))

                ServerLog("VehicleBase.InitCryMP on '%s'. Is Child %s", self:GetName(), (self.IsOriginalSpawn and "No" or "Yes"))
            end,
        },
        {
            -------------------------------
            ---        GetInfo
            -------------------------------
            Name = "GetInfo",
            Value = function(self, hId, hDef)

                local hVal = self.ServerInfo[hId]
                if (hVal == nil) then
                    return hDef
                end
                return hVal
            end,
        },
        {
            -------------------------------
            ---        GetTempInfo
            -------------------------------
            Name = "GetTempInfo",
            Value = function(self, hId, hDef)

                local hVal = self.ServerInfo_Temp[hId]
                if (hVal == nil) then
                    return hDef
                end
                return hVal
            end,
        },
        {
            -------------------------------
            ---        GetInfo
            -------------------------------
            Name = "SetInfo",
            Value = function(self, hId, hValue)
                self.ServerInfo[hId] = hValue
            end,
        },
        {
            -------------------------------
            ---        GetInfo
            -------------------------------
            Name = "SetTempInfo",
            Value = function(self, hId, hValue)
                self.ServerInfo_Temp[hId] = hValue
            end,
        },
        {
            -------------------------------
            ---        GetDriver
            -------------------------------
            Name = "GetDriver",
            Value = function(self, hId, hValue)
                return Server.Utils:GetEntity(self:GetDriverId())
            end,
        },
        {
            -------------------------------
            ---        CanEnter
            -------------------------------
            Name = "CanEnter",
            Value = function(self, hUserId)

                local bOk = true
                if (g_gameRules and g_gameRules.CanEnterVehicle) then
                    bOk = g_gameRules:CanEnterVehicle(self, hUserId)
                end

                if (bOk) then
                    self:SetTempInfo("WasUsed", true)
                end

                return bOk
            end,
        },
        {
            -------------------------------
            ---     GetNearestFreeSeat
            -------------------------------
            Name = "GetNearestFreeSeat",
            Value = function(self, vSource)

                local aNearest = { nil, -1 }
                for _, aSeat in pairs(self.Seats) do
                    if (aSeat.seat:IsFree()) then
                        local iDistance = Vector.Distance3d(self:GetSeatEnterPosition(aSeat.seatId), vSource)
                        if (aNearest[2] == -1 or iDistance < aNearest[2]) then
                            aNearest = {
                                aSeat.seatId,
                                iDistance
                            }
                        end
                    end
                end
                return aNearest[1], aNearest[2]
            end,
        },
        {
            -------------------------------
            ---     GetFreeSeat
            -------------------------------
            Name = "GetFreeSeat",
            Value = function(self, iException)
                for _, aSeat in pairs(self.Seats) do
                    if (aSeat.seat:IsFree()) then
                        if (not iException or (aSeat.seatId ~= iException)) then
                            return aSeat.seatId
                        end
                    end
                end
                return
            end,
        },
        {
            -------------------------------
            ---    GetSeatEnterPosition
            -------------------------------
            Name = "GetSeatEnterPosition",
            Value = function(self, iSeat)
                local vEnterPos = self:GetPos()
                local aSeat = self.Seats[iSeat]
                if (not aSeat) then
                    return vEnterPos
                end

                if (aSeat.exitHelper) then
                    vEnterPos = self.vehicle:MultiplyWithWorldTM(self:GetVehicleHelperPos(aSeat.exitHelper))
                elseif (aSeat.enterHelper) then
                    vEnterPos = self.vehicle:MultiplyWithWorldTM(self:GetVehicleHelperPos(aSeat.enterHelper))
                end

                return vEnterPos
            end,
        },
        {
            -------------------------------
            ---         IsEmpty
            -------------------------------
            Name = "IsEmpty",
            Value = function(self, iSeat)
                return self:GetPassengerCount() == 0
            end,
        },
        {
            -------------------------------
            ---         IsDestroyed
            -------------------------------
            Name = "IsDestroyed",
            Value = function(self, iSeat)
                return self.vehicle:IsDestroyed()
            end,
        },
        {
            -------------------------------
            ---       HasPassenger
            -------------------------------
            Name = "HasPassenger",
            Value = function(self, hId)
                if (self:GetPassengerCount() == 0) then
                    return false
                end
                for _, aSeat in pairs(self.Seats) do
                    if (aSeat:GetPassengerId() == hId) then
                        return true
                    end
                end

                return false
            end
        },
        {
            -------------------------------
            ---    GetPassengerCount
            -------------------------------
            Name = "GetPassengerCount",
            Value = function(self)
                local iCount = 0
                for _, aSeat in pairs(self.Seats) do
                    if (aSeat:GetPassengerId()) then
                        iCount = iCount + 1
                    end
                end
                return iCount
            end
        },
        {
            -------------------------------
            ---      OnActorSitDown
            -------------------------------
            Name = "OnActorSitDown",
            Value = function(self, seatId, passengerId)
                --Log("VehicleBase:OnActorSitDown() seatId=%s, passengerId=%s", tostring(seatId), tostring(passengerId));

                local passenger = System.GetEntity(passengerId);
                if (not passenger) then
                    Log("Error: entity for player id <%s> could not be found. %s", tostring(passengerId));
                    return;
                end

                local seat = self.Seats[seatId];
                if (not seat) then
                    Log("Error: entity for player id <%s> could not be found!", tostring(passengerId));
                    return;
                end

                if (g_gameRules.OnEnterVehicleSeat) then
                    g_gameRules:OnEnterVehicleSeat(self, seat, passengerId);
                end

                self.HasBeenUsed = true

                -- need to generate AI sound event (vehicle engine)
                if(seat.isDriver) then
                    --System.Log(">>> vehicleSoundTimer setting NOW >>>>>>");
                    self:SetTimer(AISOUND_TIMER, AISOUND_TIMEOUT);
                end

                seat.passengerId = passengerId;
                passenger.vehicleId = self.id;
                passenger.AI.theVehicle = self; -- fix for behaviors
                if (passenger.ai ) then
                    if(seat.isDriver) then
                        self.State.aiDriver = 1;
                        if (passenger.actor and passenger.actor:GetHealth() > 0) then
                            self:AIDriver(1);
                        else
                            self:AIDriver(0);
                        end
                    end
                else
                    --AI.SetSkip(self.id);

                    if( self.hidesUser == 1 )then
                        -- Do not hide outside gunners, so that the AI may use them as targets.
                        local isOutsideGunner = false;
                        if (seat.Sounds) then
                            isOutsideGunner = (seat.seat:GetWeaponCount() > 0) and (seat.Sounds.inout == 1);
                        end
                        if (AI and not isOutsideGunner) then
                            AI.ChangeParameter(passengerId, AIPARAM_INVISIBLE, 1);
                        end
                    end

                    if(AI and seat.isDriver) then
                        -- squadmates enter vehicle only if player is the driver
                        CopyVector(g_SignalData.point, g_Vectors.v000);
                        CopyVector(g_SignalData.point2, g_Vectors.v000);
                        g_SignalData.iValue = AIUSEOP_VEHICLE;
                        g_SignalData.iValue2 = 1; -- leader has already entered
                        g_SignalData.fValue = 1; -- Leader is the driver
                        g_SignalData.id = seat.vehicleId;
                        AI.Signal(SIGNALFILTER_LEADER, 1, "ORD_USE", passengerId, g_SignalData);

                    end
                    self:EnableMountedWeapons(false);
                end

                -- set vehicle species to driver's
                if (seat.isDriver and passenger.Properties and passenger.Properties.species and self.ChangeSpecies) then
                    self:ChangeSpecies(passenger, 1);
                    --System.Log("Changing species to "..passenger.Properties.species);
                    --		AI.ChangeParameter(self.id, AIPARAM_SPECIES, passenger.Properties.species);
                else
                end

                local wc = seat.seat:GetWeaponCount();
                --Log("VehicleBase:OnActorSitDown() weapons=%s", tostring(wc));

                if AI then
                    if ( seat.seat:GetWeaponCount() > 0) then
                        if (seat.isDriver) then
                            AI.Signal(SIGNALFILTER_SENDER, 1, "entered_vehicle", passengerId);
                        else
                            AI.Signal(SIGNALFILTER_SENDER, 1, "entered_vehicle_gunner", passengerId);
                        end
                    else
                        AI.Signal(SIGNALFILTER_SENDER, 1, "entered_vehicle", passengerId);
                    end

                    -- notify the "wait" goalop
                    AI.Signal(SIGNALFILTER_SENDER, 9, "ENTERING_END", passengerId); -- 9 is to skip normal processing of signal
                end
            end
        },
        {
            -------------------------------
            ---       Server.OnHit
            -------------------------------
            Name = "Server.OnHit",
            Value = function(self, aHitInfo)

                local explosion = aHitInfo.explosion or false
                local targetId = (explosion and aHitInfo.impact) and aHitInfo.impact_targetId or aHitInfo.targetId;
                local hitType = (explosion and aHitInfo.type == "") and "explosion" or aHitInfo.type;
                local direction = aHitInfo.dir;
                local hDriver = self:GetDriver()

                for _, aSeat in pairs(self.Seats) do
                    local hPassenger = Server.Utils:GetEntity(aSeat:GetPassengerId())
                    if (hPassenger) then
                        if (hPassenger.IsPlayer and hPassenger:HasGodMode()) then
                            aHitInfo.damage = 0 break
                        end
                    end
                end

                -- BUGFIX: prevents infinite chain explosions from respawning vehicles damaging each other
                local hWeapon = aHitInfo.weapon
                if (not self:GetTempInfo("WasUsed") and (aHitInfo.explosion or hitType == "fire") and hWeapon and hWeapon.vehicle and hWeapon ~= self) then
                    --aHitInfo.damage = 0
                    Script.SetTimer(1, function()
                        self.vehicle:KillAbandonTimer()
                    end)
                end

                if (not self.HasBeenUsed and _time - (self.LastAbandonTKill or 0) >= 20) then
                    Script.SetTimer(1, function()
                        self.vehicle:KillAbandonTimer()
                    end)
                    self.LastAbandonTKill = _time
                end

                if (aHitInfo.type ~= "fire" and aHitInfo.damage > 0) then
                    g_gameRules.game:SendHitIndicator(aHitInfo.shooterId, aHitInfo.explosion~=nil)
                end

                if (aHitInfo.type == "collision") then
                    direction.x = -direction.x
                    direction.y = -direction.y
                    direction.z = -direction.z
                end

                Server.VehicleSystem:ProcessHit(self, aHitInfo)
                g_gameRules:ProcessVehicleDamage(self, aHitInfo)
                self.vehicle:OnHit(targetId, aHitInfo.shooterId, aHitInfo.damage, aHitInfo.pos or Vector.Empty(), aHitInfo.radius, hitType, explosion)

                --[[
                if (AI and hit.type ~= "collision") then
                    if (hit.shooter) then
                        g_SignalData.id = hit.shooterId;
                    else
                        g_SignalData.id = NULL_ENTITY;
                    end
                    g_SignalData.fValue = hit.damage;
                    if (hit.shooter and self.Properties.species ~= hit.shooter.Properties.species) then
                        CopyVector(g_SignalData.point, hit.shooter:GetWorldPos());
                        AI.Signal(SIGNALFILTER_SENDER,0,"OnEnemyDamage",self.id,g_SignalData);
                    elseif (self.Behaviour and self.Behaviour.OnFriendlyDamage ~= nil) then
                        AI.Signal(SIGNALFILTER_SENDER,0,"OnFriendlyDamage",self.id,g_SignalData);
                    else
                        AI.Signal(SIGNALFILTER_SENDER,0,"OnDamage",self.id,g_SignalData);
                    end
                end]]

                local bDestroyed = self.vehicle:IsDestroyed()
                if (bDestroyed) then
                end
                return bDestroyed
            end
        },
        {
            -------------------------------
            ---     SpawnVehicleBase
            -------------------------------
            Name = "SpawnVehicleBase",
            Value = function(self)
                if (self.OnPreSpawn) then
                    self:OnPreSpawn()
                end

                if (_G[self.class.."Properties"]) then
                    mergef(self, _G[self.class.."Properties"], 1)
                end

                if (self.OnPreInit) then
                    self:OnPreInit()
                end

                self:InitCryMP()
                self:InitVehicleBase()

                self.ProcessMovement = nil

                if (not EmptyString(self.Properties.FrozenModel)) then
                    self.frozenModelSlot = self:LoadObject(-1, self.Properties.FrozenModel)
                    self:DrawSlot(self.frozenModelSlot, 0)
                end

                if (self.OnPostSpawn) then
                    self:OnPostSpawn()
                end

                local aiSpeed = self.Properties.aiSpeedMult
                local AIProps = self.AIMovementAbility
                if (AIProps and aiSpeed and aiSpeed ~= 1.0) then
                    if (AIProps.walkSpeed) then AIProps.walkSpeed = AIProps.walkSpeed * aiSpeed end
                    if (AIProps.runSpeed) then AIProps.runSpeed = AIProps.runSpeed * aiSpeed end
                    if (AIProps.sprintSpeed) then AIProps.sprintSpeed = AIProps.sprintSpeed * aiSpeed end
                    if (AIProps.maneuverSpeed) then AIProps.maneuverSpeed = AIProps.maneuverSpeed * aiSpeed end
                end

                if (self.InitAI) then
                    self:InitAI()
                end
                self:InitSeats()
                self:OnReset()
            end,
        },
    }
})