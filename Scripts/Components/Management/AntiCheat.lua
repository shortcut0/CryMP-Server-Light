--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- Contains the Server Anti-Cheat Script-Side Component
-- ===================================================================================

Server:CreateComponent({

    Name = "AntiCheat",
    FriendlyName = "Defense",
    Body = {

        -- Automatic [Config] creation and loading
        ComponentConfig = {
            ConfigPrefix = "$",
            { Config = "AntiCheat.IsEnabled", Key = "Status", Default = true, Type = nil --[[ConfigType_Boolean]] }
        },

        Config = {

            -- TODO: Move to ComponentConfig
            FilterNonPlayerHits = true, -- filter checking hits where the target entity is not a player

            Thresholds = {

                ChatSpam = 4,
                ChatFlood = 8, -- Cannot sent the same message this amount of time within 20 seconds

                UseDoor = 10, -- Maximum Distance in meters
                EnterVehicle = 18.5, -- Maximum Distance in meters (larger value for big vehicles)
                VehicleBuySpam = 10, -- Maximum Vehicle Purchase requests per timer
                ItemBuySpam = 10, -- Maximum Vehicle Purchase requests per timer

                UseOrPickupItem = 10, -- Maximum distance to pick up or use items

                RadioSpeed = 1, -- normal Radio speed
                RadioLimit = 2, -- very generous, no more then this amount of messages within speed limit

                MeleeSpeed = 0.5, -- maximum time between melee attacks
                MeleeAttacks = 3, -- Trigger if this amount of attacks within maximum time
                MeleeHitDistance = 10, -- Maximum distance between a target and the shooter
                HitPositionDistance = 10, -- Maximum distance between a target and the supposed hit position
                FireWeaponDistance = 25, -- Maximum distance between the player and the weapon they are firing

                LagForgiveness = 0.25, -- threshold forgiveness multiplier for lagging players
            },
        },

        GhostDescriptors = {
            Melee = "Melee attack",
            OnShoot = "Shooting",
            UsingDoor = "Using Door",
            EnterVehicle = "Entering Vehicle",
            UseOrPickupItem = "Interacting with Items"
        },

        Initialize = function(self)

            self.Config.LogRecipients = ServerAccess_Developer
            self:Log("Status: %s", string.bool(self.Config.Status))
        end,

        PostInitialize = function(self)
        end,

        OnCheat = function(self)
        end,

        -- For Handling C++ Callbacks
        OnCheatCallback = function(self, tInfo)

            local sCheat = tInfo.Cheat
            local sInfo = tInfo.Description or "No additional info"
            local tPlayer = tInfo.Player
            local tParams = tInfo.Params or {}

            self:LogWarning("Detected %s{Gray} on %s (%s)", sCheat, tPlayer:GetName(), sInfo)
        end,

        GetThreshold = function(self, sId, tPlayer)

            local tThresholds = self.Config.Thresholds
            local iLagScale = (tPlayer and tPlayer.IsPlayer and tPlayer:IsLagging()) and tThresholds.LagForgiveness

            local iThreshold = (tThresholds[sId])
            if (not iThreshold) then
                self:LogWarning("Invalid Threshold Id %s", tostring(sId))
                return (tThresholds.Default or 10000)
            end

            return (iThreshold * (iLagScale or 1))
        end,

        LogWarning = function(self, sMessage, ...)
            sMessage = (#{...} > 0 and (string.format(sMessage, ...)) or sMessage)
            self:LogEvent({
                Message = sMessage,
                Recipients = self.Config.LogRecipients
            })
        end,

        LogDebug = function(self, sMessage, aFormat, tFormat)
            self:LogEvent({
                Message = sMessage,
                MessageArgs = aFormat,
                MessageFormat = tFormat,
                Recipients = self.Config.LogRecipients
            })
        end,

        DebugLogHit = function(self, tHit)
            self:LogEvent({
                Message = ("============================================="),
                Recipients = ServerAccess_Developer
            })
            for _, v in pairs(tHit) do

                local sV = tostring(v)
                if (type(v) == "table") then
                    if (v.class) then
                        sV = v.class or "<null>"
                        if (v.GetName) then
                            sV = (sV .. " (%s)"):format(v:GetName())
                        end
                    elseif (Vector.IsVecAny(v)) then
                        sV = Vector.ToString(v, true)
                    end
                end
                self:LogEvent({
                    Message = ("%s = %s"):format(string.LSpace(tostring(_),10,string.COLOR_CODE), sV),
                    Recipients = ServerAccess_Developer
                })
            end
        end,

        -- ================================================================
        -- Events
        Event_OnActorSpawn = function(self, tPlayer)
            tPlayer.AntiCheat = {
                LastChatMessage     = "",
                ChatMessageTimer    = TimerNew(1),
                LastItemPurchase    = TimerNew(0.2),
                LastVehiclePurchase = TimerNew(0.3),
                MeleeTimer          = TimerNew(),
                RadioTimer          = TimerNew(),
                ItemBuySpam     = 0,
                VehicleBuySpam  = 0,
                WeaponFireSeq   = 0,
                ChatSpamSeq     = 0,
                ChatFloodSeq    = 0,
                MeleeSeq        = 0,
                RadioSeq        = 0,
            }
        end,

        -- ================================================================
        -- Checks
        CheckGhostGlitch = function(self, tPlayer, sAction)
            local bIsOnLadder = tPlayer.actorStats.isOnLadder
            if (not bIsOnLadder) then
                return false
            end

            if (sAction == nil) then
                sAction = (LuaUtils.TraceFunction(2) or "<Unknown>")
            end
            self:LogWarning("Detected Ghost-Glitch on %s{Gray} (%s - While on a Ladder)", tPlayer:GetName(), sAction)
            return true
        end,

        CheckMessage = function(self, tPlayer, sMessage, iType)

            local tAC = tPlayer.AntiCheat
            local hTimer = tAC.ChatMessageTimer
            local bExpiredFlood = hTimer.expired(20)
            local bExpiredSpam = hTimer.expired(1)

            local iSpamThreshold  = self:GetThreshold("ChatSpam")
            local iFloodThreshold = self:GetThreshold("ChatFlood")

            local bOk = true

            -- Check Spamming first
            if (not bExpiredSpam and sMessage == tAC.LastChatMessage) then
                tAC.ChatSpamSeq = (tAC.ChatSpamSeq + 1)
                if (tAC.ChatSpamSeq >= iSpamThreshold) then
                    self:LogWarning("Detected Chat Spam on %s{Gray} (%d Messages within 1s)", tPlayer:GetName(), tAC.ChatSpamSeq)
                    bOk = false
                    tAC.ChatSpamSeq = 0
                end
            else
                tAC.ChatSpamSeq = 0
            end

            -- If no spamming has been detected, check for flooding!
            if (bOk) then
                if (not bExpiredFlood and #sMessage > 3) then
                    tAC.ChatFloodSeq = (tAC.ChatFloodSeq + 1)
                    if (tAC.ChatFloodSeq > iFloodThreshold) then
                        bOk = false
                        self:LogWarning("Detected Chat Flood on %s{Gray} (%d Messages within 1s)", tPlayer:GetName(), tAC.ChatFloodSeq)
                        tAC.ChatFloodSeq = 0
                    end
                else
                    tAC.ChatFloodSeq = 0
                end
            end

            tAC.LastChatMessage = sMessage
            tAC.ChatMessageTimer.refresh()

            return bOk
        end,

        ProcessShot = function(self, tPlayer, tWeapon, tInfo)

            local bOk, bReturn, sDescription = pcall(function()
                if (not tPlayer or not tPlayer.IsPlayer) then
                    return true
                elseif (self:CheckGhostGlitch(tPlayer, self.GhostDescriptors.OnShoot)) then
                    return false
                end

               -- self:LogDebug("dist look+dir=%f", {Vector.Distance3d(tPlayer:SmartGetDir(),tInfo.Dir)})

                local iSeqReset = ((tWeapon.weapon:GetClipSize() or 10) / 3)
                tPlayer.AntiCheat.WeaponFireSeq = (tPlayer.AntiCheat.WeaponFireSeq + 1)

                -- We only check every Nth shot. For a clip with 30 rounds, every 10th shot will be checked.
                if (tPlayer.AntiCheat.WeaponFireSeq < iSeqReset and (tPlayer.AntiCheat.LastWeaponId == tWeapon.id)) then
                    return true
                end

                tPlayer.AntiCheat.LastWeaponId = tWeapon.id
                tPlayer.AntiCheat.WeaponFireSeq = 0


                if (Vector.Length(tInfo.Pos) > 0) then
                    local iDistance = Server.Utils:GetDistance(tPlayer, tInfo.Pos)
                    if (tPlayer:GetVehicle()) then
                        iDistance = (iDistance * 2.5) -- some leeway for vehicles
                    end
                    if (iDistance > self:GetThreshold("FireWeaponDistance", tPlayer)) then
                        return false, ("%0.2fm out of Sync"):format(iDistance)
                    end
                end
                return true
            end)

            if (not bOk) then
                error(bReturn)
            end

            -- There is a logical reason for this statement
            if ((bReturn == false)) then
                if (tInfo.AmmoId) then
                    Server.Utils:RemoveEntity(tInfo.AmmoId)
                end

                self:LogDebug("Weapon = %s", { tWeapon.class })
                self:LogDebug("Player Pos = %s", { Vector.ToString(tPlayer:GetPos()) })
                self:LogDebug("Weapon Pos = %s", { Vector.ToString(tWeapon:GetPos()) })
                self:LogDebug("Fire Pos = %s", { Vector.ToString(tInfo.Pos) })
                self:LogDebug("Hit Pos = %s", { Vector.ToString(tInfo.Hit) })
                self:LogDebug("Fire Dir = %s", { Vector.ToString(tInfo.Dir) })
                self:LogWarning("Detected Invalid Shoot Request on %s{Grey} (%s)", tPlayer:GetName(), (sDescription or "<Null>"))
                return false
            end

            return true
        end,

        ProcessItemHit = function(self, tHit)
            return true
        end,

        ProcessVehicleHit = function(self, tHit)
            return true
        end,

        ProcessRadio = function(self, tChannel, tPlayer, iRadio)

            if (tChannel.id ~= tPlayer.id) then
                self:LogWarning("Detected Radio Spoof on %s{Gray} (Pretending to be {Red}%s{Gray})", tChannel:GetName(), tPlayer:GetName())
                return false
            end

            if (g_gameRules.IS_PS) then
                local tAC = tChannel.AC
                local iRadioTime = self:GetThreshold("RadioSpeed")
                local tRadioTimer = tAC.RadioTimer
                local bOk = true

                if (not tRadioTimer.Expired(iRadioTime)) then
                    tAC.RadioSeq = (tAC.RadioSeq + 1)
                    if (tAC.RadioSeq >= self:GetThreshold("RadioLimit")) then
                        self:LogWarning("Detected Radio Speed on %s{Gray} (%d Messages with in %0.2fs)", tChannel:GetName(), iRadioTime)
                    end
                    bOk = false -- Block the request
                else
                    tAC.RadioSeq = 0
                end

                tRadioTimer.Refresh()
                return bOk
            end

            self:LogWarning("Detected Unrestricted Radio on %s{Gray} (Bad GameMode {Red}%s{Grey})", tChannel:GetName(), g_gameRules.class)
            return false
        end,

        ProcessMelee = function(self, tPlayer, tFists)

            if (not tPlayer or self:CheckGhostGlitch(tPlayer, self.GhostDescriptors.Melee)) then
                return false
            end

            local tAC = tPlayer.AntiCheat
            local iMeleeTime = self:GetThreshold("MeleeSpeed")
            local tMeleeTimer = tAC.MeleeTimer
            local bOk = true

            if (not tMeleeTimer.Expired(iMeleeTime)) then
                tAC.MeleeSeq = (tAC.MeleeSeq + 1)
                if (tAC.MeleeSeq >= self:GetThreshold("MeleeAttacks")) then
                    self:LogWarning("Detected Melee Speed on %s{Gray} (%d Melee attacks with in %0.2fs)", tPlayer:GetName(), iMeleeTime)
                end
                bOk = false -- Block the request
            else
                tAC.MeleeSeq = 0
            end

            tMeleeTimer.Refresh()
            return bOk
        end,

        ProcessHit = function(self, tHit)

            local tConfig = self.Config
            if (not tHit.remote) then
                return true -- Don't check hits created by the Server
            end

            local tPlayer = tHit.shooter or Server.Utils:GetEntity(tHit.shooterId)
            if (not tPlayer or not tPlayer.IsPlayer) then
                return true
            end

            local tTarget = tHit.target or Server.Utils:GetEntity(tHit.targetId)
            if (not tTarget or (tTarget == tPlayer)) then
                return true
            end

            if (tConfig.FilterNonPlayerHits and not tTarget.IsPlayer) then
                return true
            end

            local bHitLogged
            if (tPlayer:IsInTestMode() or (tTarget.IsPlayer and tTarget:IsInTestMode())) then
                self:DebugLogHit(tHit)
                bHitLogged = true
            end

            local bBullet = (tHit.type or ""):find("bullet")
            local bMelee = (tHit.type or "") == "melee"
            if (not tHit.explosion) then
                local iDistance = Server.Utils:GetDistance(tHit.pos, tTarget)
                if (bBullet) then
                    if (iDistance > self:GetThreshold("HitPositionDistance", tPlayer)) then
                        if (not bHitLogged) then self:DebugLogHit(tHit) end
                        self:LogWarning("Detected Hit Distance on %s{Gray} (%0.2fm out of sync)", tPlayer:GetName(), iDistance)
                        return false
                    end
                elseif (bMelee) then
                    if (self:CheckGhostGlitch(tPlayer, self.GhostDescriptors.Melee)) then
                        return false
                    end
                    local iMeleeDistance = Server.Utils:GetDistance(tHit.pos, tPlayer)
                    if (iMeleeDistance > self:GetThreshold("MeleeHitDistance", tPlayer)) then
                        if (not bHitLogged) then self:DebugLogHit(tHit) end
                        self:LogWarning("Detected Melee Distance on %s{Gray} (%0.2fm away from target)", tPlayer:GetName(), iMeleeDistance)
                        return false
                    end
                end
            end

            return true
        end,

        CanPurchaseVehicle = function(self, tPlayer, tVehicleDef)

            local tAC = tPlayer.AntiCheat
            local bExpired = tAC.LastVehiclePurchase.Expired()
            tAC.LastVehiclePurchase.Refresh()

            if (not bExpired) then
                tAC.VehicleBuySpam = (tAC.VehicleBuySpam + 1)
                if (tAC.VehicleBuySpam > self:GetThreshold("VehicleBuySpam", tPlayer)) then
                    self:LogWarning("Detected Vehicle Buy Flood on %s{Gray} (%d Requests within %0.2f Second)", tPlayer:GetName(), tAC.VehicleBuySpam, tAC.LastVehiclePurchase.GetSetExpiry())
                end
                return false
            end

            tAC.VehicleBuySpam = 0
            return true
        end,

        CanPurchaseItemOrAmmo = function(self, tPlayer, tItemDef)

            local tAC = tPlayer.AntiCheat
            local bExpired = tAC.LastItemPurchase.Expired()
            tAC.LastItemPurchase.Refresh()

            if (not bExpired) then
                tAC.ItemBuySpam = (tAC.ItemBuySpam + 1)
                if (tAC.ItemBuySpam > self:GetThreshold("ItemBuySpam", tPlayer)) then
                    self:LogWarning("Detected Item Buy Flood on %s{Gray} (%d Requests within %0.2f Second)", tPlayer:GetName(), tAC.ItemBuySpam, tAC.LastItemPurchase.GetSetExpiry())
                end
                return false
            end

            tAC.ItemBuySpam = 0
            return true
        end,

        CanOpenDoor = function(self, tPlayer, tDoor)
            if (not (tPlayer or tDoor)) then
                return false
            end

            if (not tPlayer.IsPlayer) then
                return true
            elseif (self:CheckGhostGlitch(tPlayer, self.GhostDescriptors.UsingDoor)) then
                return false
            end

            local iDistance = Server.Utils:GetDistance(tPlayer, tDoor)
            if (iDistance > self:GetThreshold("UseDoor", tPlayer)) then
                self:LogWarning("%s{Gray} tried to Use Door from %0.2fm away", tPlayer:GetName(), iDistance)
                return false
            end

            return true
        end,

        CanEnterVehicle = function(self, tPlayer, tVehicle)
            if (not (tPlayer or tVehicle)) then
                return false
            end

            if (not tPlayer.IsPlayer) then
                return true
            elseif (self:CheckGhostGlitch(tPlayer, self.GhostDescriptors.CanEnterVehicle)) then
                return false
            end

            local iDistance = Server.Utils:GetDistance(tPlayer, tVehicle)
            if (iDistance > self:GetThreshold("EnterVehicle", tPlayer)) then
                self:LogWarning("%s{Gray} tried to Enter Vehicle from %0.2fm away", tPlayer:GetName(), iDistance)
                return false
            end

            return true
        end,

        CanUseOrPickupItem = function(self, tPlayer, tItem)
            if (not (tPlayer or tItem)) then
                return false
            end

            if (not tPlayer.IsPlayer) then
                return true
            elseif (self:CheckGhostGlitch(tPlayer, self.GhostDescriptors.UseOrPickupItem)) then
                return false
            end

            local iDistance = Server.Utils:GetDistance(tPlayer, tItem)
            local iDistanceZ = Server.Utils:GetDistanceZ(tPlayer, tItem)
            if (iDistance > self:GetThreshold("UseOrPickupItem", tPlayer)) then

                -- You are able to pick up items from infinite differences in altitude if you look down on them at a very specific angle.
                -- This check will filter out such anomalies
                if (iDistanceZ > 3) then
                    self:LogWarning("Detected weapon pickup glitch on %s", tPlayer:GetName())
                    return false
                end

                self:LogWarning("%s{Gray} tried to Use or Pick Up Item from %0.2fm away", tPlayer:GetName(), iDistance)
                return false
            end

            return true
        end,

        Localizations = {
            {
                String = "antiCheat_simpleLogDetect",
                Languages = {
                    English = "Detected {Red}{Cheat}{Gra} on {Red}{Player}{Gray} ({Red}{Info}{Gray})"
                }
            }
        }
    }
})