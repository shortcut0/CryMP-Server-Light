-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- This file Contains the Actor Handler Component
-- ===================================================================================

Server:CreateComponent({
    Name = "ActorHandler",
    Body = {

        ExternalData = {
            { Key = "PlayerData", Name = "UserData.lua", Path = (SERVER_DIR_DATA .. "Users\\") },
        },

        Protected = {
            PlayerData = {}
        },

        Properties = {
            AwaitProfileTimeout = 5,
        },

        Initialize = function(self)
        end,

        PostInitialize = function(self)
        end,

        OnReset = function(self)
            for _, hPlayer in pairs(Server.Utils:GetPlayers()) do
                self:OnPlayerDisconnect(hPlayer)
            end
        end,

        OnPlayerDisconnect = function(self, hActor)
            if (hActor.Info.IsValidated) then
                hActor.Data.LastConnect = Date:GetTimestamp()
                hActor.Data.LastName = nil
                if (not Server.NameHandler:IsNomadOrTemplate(hActor:GetName())) then
                    hActor.Data.LastName = hActor:GetName()
                end
                self:ExportPlayerData(hActor.Data, hActor:GetProfileId())
            end
        end,

        ExportPlayerData = function(self, aData, sId)
            self.PlayerData[sId] = aData
        end,

        OnProfileValidated = function(self, hPlayer, sId)
            local aData = self.PlayerData[sId]
            if (aData) then
                table.MergeInPlace(hPlayer.Data, aData)
            end
        end,

        Event_TimerSecond = function(self)
            for _, hPlayer in pairs(Server.Utils:GetPlayers()) do
                self:OnActorTick(hPlayer)
            end
        end,

        OnActorTick = function(self, hActor)

            if (hActor.Timers.Initialized.diff() >= self.Properties.AwaitProfileTimeout) then
                -- We never received a profile
                if (not hActor.Info.ProfileReceived) then
                    -- So we treat it as failed
                    Server.AccessHandler:AssignIPProfile(hActor)
                end
            end

            if (hActor:IsValidated()) then
                hActor.Data.ServerTime = (hActor.Data.ServerTime + 1)
            end
        end,

        OnServerSpawn = function(self, hServer)

            hServer.Timers = {}
            hServer.Data = {}
            hServer.Info = {
                IsPlayer  = false,
                ChannelId = 0,
                ProfileId = "0",
                IPAddress = "127.0.0.1",
                HostName  = "localhost",
                HardwareId = nil,
                Language = {
                    Detected = Language_English,
                    Preferred = Language_English
                }
            }

            self:AddActorFunctions(hServer)
        end,

        OnActorSpawn = function(self, hActor, bForceInitialize)

            local bIsPlayer = hActor.actor:IsPlayer()
            local iChannel = hActor.actor:GetChannel()

            if (hActor.Initialized and not bForceInitialize) then
                self:Log("Skipping Re-Initialization for '%s'", hActor:GetName())
                return
            end


            hActor.IsPlayer = bIsPlayer
            hActor.Timers = {
                Initialized = TimerNew(),
                Connection  = Server.Network:GetConnectionTimer(iChannel),
                Spawn       = TimerNew(),
                WallJump    = TimerNew(),
                UnclaimedVehicle = TimerNew(),
            }

            hActor.TagAward = {
                CP = 0,
                PP = 0,
                Num = 0,
                Hostiles = 0,
            }

            hActor.Data = {
                LastConnect      = -1, -- Never
                ServerTime       = 0, -- Time spent on this server
                FirstBloodScored = 0, -- the amount of times this player scored first blood, used to amplify rewards
            }
            hActor.Info = {

                IsPlayer  = bIsPlayer,
                ChannelId = iChannel,
                ProfileId = "0",
                ProfileReceived = false,
                IPAddress = "127.0.0.1",
                HostName  = "localhost",
                Port      = "localhost",
                HardwareId = nil, -- TODO

                GeoData   = Server.Network:GetDefaultGeoData(),

                Access    = 0,
                IsInTestMode = false,
                IsValidated  = false,
                IsValidating = false,
                ValidationFailed = false,

                Language = {
                    Preferred = Language_None,
                    Detected = Language_None
                },

                HitAccuracy = {
                    Timer   = TimerNew(10), -- Expires after 10s..

                    Hits    = 0,
                    Shots   = 0,

                    OnHit   = function(this) this:Refresh(1) this.Hits = ((this.Hits or 0) + 1)  end,
                    OnShot  = function(this) this:Refresh(1) this.Shots = ((this.Shots or 0) + 1)  end,
                    Expired = function(this) return (this.Timer.expired())  end,
                    Refresh = function(this, keep) this.Timer.refresh() if (not keep) then this.Shots = 0 this.Hits = 0 end  end,
                    Get     = function(this) if (this.Shots + this.Hits <= 0) then return 0 end return math.min(100, math.max(0, (this.Hits / this.Shots) * 100))  end,
                }
            }

            hActor.Streaks = {
                Kills   = 0,
                Deaths  = 0,
                Repeats = {},

                -- Kill streak
                SetKills = function(this, kills) this.Kills = kills return kills end,
                AddKill  = function(this, kills) kills = (kills or 1) return this:SetKills(this.Kills + kills) end,

                -- Death streak
                SetDeaths = function(this, deaths) this.Deaths = deaths return deaths end,
                AddDeath  = function(this, deaths) deaths = (deaths or 1) return this:SetDeaths(this.Deaths + deaths) end,

                -- Repeated streaks
                SetRS   = function(this, id, rs) table.checkM(this.Repeats, id, 0) rs = (rs or 1) this.Repeats[id] = rs return rs  end,
                AddRS   = function(this, id, rs) table.checkM(this.Repeats, id, 0) rs = (rs or 1) return this:SetRS(id, this.Repeats[id] + rs)  end,
                GetRS   = function(this, id) table.checkM(this.Repeats, id, 0) return this.Repeats[id] end,
                ResetRS = function(this, id, def) def = (def or 0) if (id) then this.Repeats[id] = 0 else for i, v in pairs(this.Repeats) do this.Repeats[i] = def end end end,
            }

            hActor.SpawnTimer = TimerNew()
            hActor.KillMessageTimer = TimerNew(1)
            hActor.KillMessageCount = 0

            if (bIsPlayer) then
                hActor.Info.IPAddress = ServerDLL.GetChannelIP(iChannel)

                local sHostName = ServerDLL.GetChannelName(iChannel)
                hActor.Info.HostName  = (sHostName:match("(.*):%d+$") or sHostName)
                hActor.Info.Port = (sHostName:match(":(%d+)$") or -1)
            end

            self:AddActorFunctions(hActor)

            if (bIsPlayer) then
                self:Log("OnActorSpawn(%s)", hActor:GetName())
            end

            hActor.Initialized = true
        end,

        AddActorFunctions = function(self, hActor)

            if (hActor.Info.IsPlayer) then
            end

            hActor.CalcPos             = function(this, distance, dv) local d = this:SmartGetDir(dv) local p = this:GetHeadPos() Vector.FastSum(p, p, Vector.Scale(d, (distance or 5))) return p end
            hActor.IsSwimming          = function(this) return this:IsUnderwater(1) or this:GetStance(STANCE_SWIM)  end
            hActor.GetHeadPos          = function(this) return this.actor:GetHeadPos() end
            hActor.GetHeadDir          = function(this) return this.actor:GetHeadDir()  end
            hActor.GetViewPoint        = function(this, dist) return (this.actor:GetLookAtPoint(dist or 9999))  end
            hActor.SvMoveTo            = function(this, pos, ang) this:SetInvulnerability(5) local v = this:GetVehicle() if (v) then v:SetWorldPos(pos) return end g_gameRules.game:MovePlayer(this.id, Vector.ModifyZ(pos, 0.25), (ang or this:GetWorldAngles()))  end
            hActor.SetInvulnerability  = function(this, time) g_gameRules.game:SetInvulnerability(this.id, true, (time or 2.5)) end
            hActor.GetSpectatorDir     = function(this) return (this.actor:GetLookDirection() or this.PseudoDirection or Vector.Empty()) end
            hActor.GetVehicleDir       = function(this) return (this.actor:GetVehicleViewDir()) end
            hActor.SmartGetDir         = function(this, dv) if (this:IsSpectating()) then return this:GetSpectatorDir() elseif (this:GetVehicleId()) then return this:GetVehicleDir()end return (dv and this:GetDirectionVector() or this.actor:GetLookDirection() or this:GetHeadDir()) end
            hActor.GetLean             = function(this, dir) local d = this.actor:GetLean() if (dir) then return d == dir end return d end
            hActor.GetStance           = function(this, check) local s = this.actorStats.stance if (check) then return s==check end return s end


            hActor.GetPing         = function(this, check, n) local p = this.Info.LastPing if (check) then if (n) then return p ~= check end return p == check end return p end
            hActor.SetPing         = function(this, ping) this.Info.LastPing = ping end
            hActor.GetRealPing     = function(this) return (g_gameRules.game:GetPing(this:GetChannel() or 0) * 1000)  end
            hActor.SetRealPing     = function(this, real) g_gameRules.game:SetSynchedEntityValue(this.id, g_gameRules.SCORE_PING_KEY, math.floor(real))  end
            hActor.GetCurrentItem  = function(this) return this.inventory:GetCurrentItem() end
            hActor.GetCurrentItemClass = function(this) local c =  this.inventory:GetCurrentItem() return c and c.class end
            hActor.GetItemByClass  = function(this, class) local h = this.inventory:GetItemByClass(class) return Server.Utils:GetEntity(h) end
            hActor.HasItem         = function(this, class) return this.inventory:GetItemByClass(class) end
            hActor.GetItem         = function(this, class) return this.inventory:GetItemByClass(class) end
            hActor.RemoveItem      = function(this, class) local id = this.inventory:GetItemByClass(class) if (id) then this.inventory:RemoveItem(id) end end
            hActor.GiveItem        = function(this, class, noforce) this.actor:SetActorMode(ActorMode_NoItemLimit, 1) if (class == "Parachute") then this:RemoveItem("Parachute") end local i = ItemSystem.GiveItem(class, this.id, (not noforce))this.actor:SetActorMode(ActorMode_NoItemLimit, 0) return i end
            hActor.GiveItemPack    = function(this, pack, noforce) return ItemSystem.GiveItemPack(this.id, pack, (not noforce)) end
            hActor.SelectItem      = function(this, class) return this.actor:SelectItemByNameRemote(class) end
            hActor.GetEquipment    = function(this) local a = this.inventory:GetInventoryTable() local e for i, v in pairs(a) do local x = Server.Utils:GetEntity(v) if (x and x.weapon) then if (e == nil) then e = {} end table.insert(e, { x.class, x.weapon:GetAttachedAccessories(true)}) end end return e end
            hActor.GetInventory    = function(this) local a = this.inventory:GetInventoryTable() local n = {} for _,id in pairs(a or {}) do table.insert(n,Server.Utils:GetEntity(id)) end return n end
            hActor.SetActorMode    = function(this, m, v) this.actor:SetActorMode(m,v) end
            hActor.GetActorMode    = function(this, m) return this.actor:GetActorMode(m) end
            hActor.IsLagging       = function(this) return this.actor:IsLagging() or this:GetPing() >= g_gameRules:GetPingControlLimit() end --this.actor:IsFlying()  end
            hActor.IsFlying        = function(this) return this.actor:IsFlying()  end
            hActor.IsInDoors       = function(this) return Server.Utils:IsPointInDoors(this:GetPos())  end
            hActor.IsFrozen        = function(this) return g_gameRules.game:IsFrozen(this.id)  end
            hActor.IsAlive         = function(this, ignorespec) return (this:GetHealth() > 0 and (ignorespec or not this:IsSpectating()))  end
            hActor.IsDead          = function(this) return (this:GetHealth() <= 0) end
            hActor.IsSpectating    = function(this) return (this.actor:GetSpectatorMode() ~= 0) end
            hActor.Spectate        = function(this, mode, target) this.inventory:Destroy() this.actor:SetSpectatorMode(mode, (target and target.id or NULL_ENTITY)) end
            hActor.GetHealth       = function(this) return (this.actor:GetHealth() or 0)  end
            hActor.SetHealth       = function(this, health) this.actor:SetHealth(health)  end
            hActor.GetEnergy       = function(this) return (this.actor:GetNanoSuitEnergy())  end
            hActor.SetEnergy       = function(this, energy) this.actor:SetNanoSuitEnergy(energy)  end
            hActor.GetSuitMode     = function(this, mode) local m = this.actor:GetNanoSuitMode() if (mode) then return (m == mode) end return m  end
            hActor.SetSuitMode     = function(this, mode) this.actor:SetNanoSuitMode(mode) end -- NOT synched


            hActor.LeaveVehicle    = function(this)
                local hVehicle = this:GetVehicle()
                if (not hVehicle) then return end
                hVehicle.vehicle:ExitVehicle(this.id, true)
            end
            hActor.IsInVehicle     = function(this) return this:GetVehicleId() ~= nil end -- NOT synched
            hActor.GetVehicle      = function(this) return Server.Utils:GetEntity(this:GetVehicleId()) end -- NOT synched
            hActor.GetVehicleId    = function(this) return this.actor:GetLinkedVehicleId() end -- NOT synched
            hActor.GetVehicleSeat  = function(this) local c = this:GetVehicle() if (not c) then return end return c:GetSeat(this.id) end -- NOT synched
            hActor.GetVehicleSeatId= function(this) local c = this:GetVehicleSeat()if (not c) then return end return c.seatId end -- NOT synched
            hActor.GetFreeVehicleSeat= function(this)
                local hVehicle = this:GetVehicle()
                if (not hVehicle) then
                    return
                end
                for _, aSeat in pairs(hVehicle.Seats) do
                    if (not aSeat.passengerId and not aSeat.locked) then
                        return _
                    end
                end
            end -- NOT synched

            hActor.GetServerTime = function(this)
                return this.Data.ServerTime
            end
            hActor.GetLastConnect = function(this, bFormat, sNever, sToday)
                local iLastConnect = this.Data.LastConnect
                if (bFormat) then
                    if (iLastConnect == -1) then
                        return (sNever or "@str_Never")
                    elseif (sToday and (Date:GetTimestamp() - iLastConnect) < ONE_DAY) then
                        return ((sToday == true) and "@str_Today" or sToday)
                    end
                    -- Rounds to nearest time ago in Days
                    return Date:Format(Date:GetTimestamp() - iLastConnect, DateFormat_Days) .. " @ago"
                end
                return (iLastConnect)
            end

            hActor.IsInventoryEmpty     = function(this, count) return (table.count(this.inventory:GetInventoryTable()) <= (count or 0)) end

            hActor.IsValidated  = function(this) return this.Info.IsValidated  end
            hActor.SetProfileValidated  = function(this, bMode)  this.Info.IsValidated = bMode end
            hActor.SetProfileReceived  = function(this, bMode)  this.Info.ProfileReceived = bMode end
            hActor.GetAccessName = function(this) return Server.AccessHandler:GetAccessName(this:GetAccess()) end
            hActor.GetAccessColor = function(this) return Server.AccessHandler:GetAccessColor(this:GetAccess()) end
            hActor.GetAccess    = function(this, min) if (min) then if (min > this.Info.Access) then return min end end return this.Info.Access  end
            hActor.SetAccess    = function(this, iLevel, tInfo)  Server.AccessHandler:AssignAccess(this, iLevel, tInfo) end
            hActor.HasAccess    = function(this, iLevel) return this.Info.Access >= iLevel  end
            hActor.IsAdministrator  = function(this, iAccessLevel) iAccessLevel = iAccessLevel or this.Info.Access return Server.AccessHandler:IsAdministrator(iAccessLevel)  end
            hActor.IsDeveloper      = function(this, iAccessLevel) iAccessLevel = iAccessLevel or this.Info.Access return Server.AccessHandler:IsDeveloper(iAccessLevel)  end
            hActor.IsPremium        = function(this, iAccessLevel) iAccessLevel = iAccessLevel or this.Info.Access return Server.AccessHandler:IsPremium(iAccessLevel)  end
            hActor.IsServerOwner    = function(this, iAccessLevel) iAccessLevel = iAccessLevel or this.Info.Access return Server.AccessHandler:IsOwner(iAccessLevel)  end
            hActor.GetTeam    = function(this) return Server.Utils:GetTeamId(this) end

            hActor.GetTeamName     = function(this, neutral) return Sever.Utils:GetTeam_String(this) end
            hActor.SetTeam         = function(this, iTeam) g_pGame:SetTeam(iTeam, this.id) end
            hActor.GetKills        = function(this) return (g_gameRules:GetKills(this.id) or 0) end
            hActor.SetKills        = function(this, kills) g_gameRules:SetKills(this.id, kills) end
            hActor.GetDeaths       = function(this) return (g_gameRules:GetDeaths(this.id) or 0) end
            hActor.SetDeaths       = function(this, deaths) g_gameRules:SetDeaths(this.id, deaths) end
            hActor.GetRank         = function(this) return (g_gameRules:GetPlayerRank(this.id) or 0) end
            hActor.SetRank         = function(this, rank) g_gameRules:SetPlayerRank(this.id, rank) end
            hActor.GetCP           = function(this) g_gameRules:GetPlayerCP(this.id) end
            hActor.SetCP           = function(this, cp) g_gameRules:SetPlayerCP(this.id, cp) end

            hActor.SetPreferredLanguage  = function(this, sLang) this.Info.Language.Preferred = sLang  end
            hActor.GetPreferredLanguage  = function(this) return this.Info.Language.Preferred  end
            hActor.SetLanguage  = function(this, sLang) this.Info.Language.Detected = sLang  end
            hActor.GetLanguage  = function(this) return this.Info.Language.Detected  end

            hActor.GetHardwareId = function(this) return this.Info.HardwareId  end
            hActor.GetIPAddress = function(this) return this.Info.IPAddress  end
            hActor.GetHostName  = function(this) return this.Info.HostName  end
            hActor.GetPort  = function(this) return this.Info.Port  end
            hActor.GetProfileId = function(this) return this.Info.ProfileId  end
            hActor.SetProfileId = function(this, sId) this.Info.ProfileId = sId end
            hActor.GetChannel   = function(this) return this.Info.ChannelId  end
            hActor.GetCountryCode   = function(this) return Server.Network:GetCountryCode(this)  end
            hActor.GetCountryName   = function(this) return Server.Network:GetCountryName(this)  end
            hActor.GetISP   = function(this) return Server.Network:GetISP(this)  end

            hActor.IsHuman      = function(this) return this.Info.IsPlayer  end
            hActor.IsInTestMode = function(this) return this.Info.IsInTestMode  end
            hActor.SetValidationFailed = function(this, mode)  this.Info.ValidationFailed = mode  end

            hActor.GetPrestige     = function(this) return (999999 or g_gameRules:GetPlayerPrestige(this.id) or 0) end
            hActor.SetPrestige     = function(this, pp, reason)
                g_gameRules:SetPlayerPrestige(this.id, pp)
                if (reason) then
                end
            end
            hActor.AddPrestige     = function(this, pp, reason, tFormat)
                this:SetPrestige(this:GetPrestige() + pp)
                if (reason) then
                end
            end
            hActor.AwardPrestige   = function(this, pp, reason, tFormat)
                g_gameRules:PrestigeEvent(this.id, pp, reason, tFormat)
            end

            hActor.LocalizeText = function(this, sMessage, tFormat) return Server.LocalizationManager:LocalizeForPlayer(this, sMessage, tFormat)  end
            hActor.GetTextCoords = function(this) return Server.Utils:GetEntityTextCoords(this)  end

            hActor.GetHitAccuracy       = function(this) return this.Info.HitAccuracy:Get() end
            hActor.RefreshHitAccuracy   = function(this) return this.Info.HitAccuracy:Refresh() end
            hActor.UpdateHitAccuracy    = function(this, t) if (t == "Shot") then this.Info.HitAccuracy:OnShot() elseif (t == "Hit") then this.Info.HitAccuracy:OnHit() end end
            hActor.HitAccuracyExpired   = function(this) return this.Info.HitAccuracy:Expired() end
        end,
    }
})