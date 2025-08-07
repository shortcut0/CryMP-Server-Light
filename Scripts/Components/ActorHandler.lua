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

        OnPlayerDisconnect = function(self, hActor)
            if (hActor.Info.IsValidated) then
                hActor.Data.LastConnect = Date:GetTimestamp()
                self:ExportPlayerData(hActor.Data, hActor:GetProfileId())
            end
        end,

        ExportPlayerData = function(self, aData, sId)
            self.PlayerData[sId] = aData
        end,

        OnProfileValidated = function(self, hPlayer, sId)
            DebugLog("validated?",sId)
            local aData = self.PlayerData[sId]
            if (aData) then
                table.MergeInPlace(hPlayer.Data, aData)
                DebugLog(table.tostring(hPlayer.Data))
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

        OnActorSpawn = function(self, hActor)

            local bIsPlayer = hActor.actor:IsPlayer()
            local iChannel = hActor.actor:GetChannel()

            hActor.IsPlayer = bIsPlayer
            hActor.Timers = {
                Initialized = TimerNew(),
                Connection = Server.Network:GetConnectionTimer(iChannel)
            }

            hActor.Data = {
                OutOfMana = true,
                LastConnect = -1, -- Never
                ServerTime = 0, -- Time spent on this server
            }
            hActor.Info = {

                IsPlayer  = bIsPlayer,
                ChannelId = iChannel,
                ProfileId = "0",
                ProfileReceived = false,
                IPAddress = "127.0.0.1",
                HostName  = "localhost",

                GeoData   = Server.Network:GetGeoInfo(iChannel),

                Access    = 0,
                IsInTestMode = false,
                IsValidated  = false,
                IsValidating = false,
                ValidationFailed = false,

                Language = {
                    Preferred = Language_None,
                    Detected = Language_None
                },
            }

            if (bIsPlayer) then
                hActor.Info.IPAddress = ServerDLL.GetChannelIP(iChannel)
                hActor.Info.HostName  = ServerDLL.GetChannelName(iChannel)
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


            hActor.IsInVehicle     = function(this) return this:GetVehicleId() ~= nil end -- NOT synched
            hActor.GetVehicle      = function(this) return Server.Utils:GetEntity(this:GetVehicleId()) end -- NOT synched
            hActor.GetVehicleId    = function(this) return this.actor:GetLinkedVehicleId() end -- NOT synched
            hActor.GetVehicleSeat  = function(this) local c = this:GetVehicle() if (not c) then return end return c:GetSeat(this.id) end -- NOT synched
            hActor.GetVehicleSeatId= function(this) local c = this:GetVehicleSeat()if (not c) then return end return c.seatId end -- NOT synched

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
                    return Date:Format(Date:GetTimestamp() - iLastConnect, DateFormat_Days) .. " @Ago"
                end
                return (iLastConnect)
            end

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

            hActor.SetPreferredLanguage  = function(this, sLang) this.Info.Language.Preferred = sLang  end
            hActor.GetPreferredLanguage  = function(this) return this.Info.Language.Preferred  end
            hActor.SetLanguage  = function(this, sLang) this.Info.Language.Detected = sLang  end
            hActor.GetLanguage  = function(this) return this.Info.Language.Detected  end

            hActor.GetIPAddress = function(this) return this.Info.IPAddress  end
            hActor.GetHostName  = function(this) return this.Info.HostName  end
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
            hActor.AddPrestige     = function(this, pp, reason)
                this:SetPrestige(this:GetPrestige() + pp)
                if (reason) then
                end
            end
            hActor.AwardPrestige   = function(this, pp, reason)
                g_gameRules:AwardPPCount(this.id, pp, nil, this:HasClientMod())
                if (reason) then
                end
            end

            hActor.LocalizeText = function(this, sMessage, tFormat) return Server.LocalizationManager:LocalizeForPlayer(this, sMessage, tFormat)  end
        end,
    }
})