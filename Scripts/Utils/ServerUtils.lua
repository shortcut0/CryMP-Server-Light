-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- This File contains the Server Utils Component
-- ===================================================================================

----------------------------
Server:CreateComponent({
    Name = "Utils",
    Body = {

        Initialize = function(self)
        end,

        PostInitialize = function(self)
            self.Game = g_gameRules.game
        end,

        IsPointInDoors = function(self, vPoint)
           return ( System.IsPointIndoors(vPoint))
        end,

        GetTeamId = function(self, pEntity)
            local hEntity = self:GetEntity(pEntity)
            if (not hEntity) then
                return
            end
            return self.Game:GetTeam(hEntity.id)
        end,

        GetTeam_Number = function(self, sId)

            sId = string.lower(sId)
            if (IsAny(sId, "nk", "korea", tostring(GameTeam_NK))) then
                return GameTeam_NK

            elseif (IsAny(sId, "us", "america", tostring(GameTeam_US))) then
                return GameTeam_US

            elseif (IsAny(sId, "neutral", "none", GameTeam_Neutral)) then
                return GameTeam_Neutral
            end

        end,

        GetTeam_String = function(self, sId)

            sId = string.lower(sId)
            if (IsAny(sId, "nk", "korea", tostring(GameTeam_NK))) then
                return GameTeam_NK_String

            elseif (IsAny(sId, "us", "america", tostring(GameTeam_US))) then
                return GameTeam_US_String

            elseif (IsAny(sId, "neutral", "none", GameTeam_Neutral)) then
                return GameTeam_Neutral_String
            end

        end,

        IsValidIPAddress = function(self, sIPAddress)
            return (string.MatchesNone(sIPAddress, { "127%.0%.0%.1", "localhost", "0%.0%.0%.0", "192%.168%.%d+%.%d+" }))
        end,

        ByteSuffix = function(self, iBytes, iNulls)
            return string.ByteSuffix(iBytes, iNulls)
        end,

        GetCVar = function(self, sCVar)
            local sValue = System.GetCVar(sCVar)
            if (sValue == nil) then
                ServerLogError("CVar '%s' not Found", sCVar)
            end
            return sValue
        end,

        SetCVar = function(self, sCVar, sValue)
            if (System.GetCVar(sCVar) == nil) then
                ServerLogError("CVar '%s' not Found", sCVar)
            end
            System.SetCVar(sCVar, sValue)
        end,

        IsEntity = function(self, pEntity)
            return ((IsUserdata(pEntity) and self:GetEntity(pEntity)) or (IsTable(pEntity) and self:GetEntity(pEntity.id)))
        end,

        GetEntity = function(self, hId)

            if (IsNull(hId)) then
                return
            end

            if (IsUserdata(hId)) then
                return System.GetEntity(hId)
            end

            if (IsArray(hId) and hId.id ~= nil) then
                return System.GetEntity(hId.id)
            end

            if (IsString(hId)) then
                return System.GetEntityByName(hId)
            end
            return
        end,

        FindPlayerByName = function(self)
        end,

        GetPlayerByChannel = function(self, iChannel)
            return self.Game:GetPlayerByChannelId(iChannel)
        end,

        GetPlayers = function(self, aInfo)
            aInfo = aInfo or {}
            local aPlayers = {}
            for _, hEntity in pairs(System.GetEntitiesByClass("Player") or {}) do

                local bOk = hEntity.actor:IsPlayer()
                if (aInfo.IncludeNPC) then
                    bOk = true
                end

                if (aInfo.ByTeam) then
                    bOk = (bOk and (self:GetTeamId(hEntity.id) == aInfo.ByTeam))
                end

                if (aInfo.NotByTeam) then
                    bOk = (bOk and (self:GetTeamId(hEntity.id) ~= aInfo.NotByTeam))
                end

                if (aInfo.ByAccess) then
                    bOk = (bOk and (hEntity:HasAccess(aInfo.ByAccess)))
                end

                if (aInfo.NotByAccess) then
                    bOk = (bOk and (not hEntity:HasAccess(aInfo.NotByAccess)))
                end

                if (bOk) then
                    table.insert(aPlayers, hEntity)
                end
            end
            return aPlayers
        end,

        GetPlayerCount = function(self, bInGame)
            if (bInGame == nil) then
                bInGame = false
            end
            return (g_gameRules.game:GetPlayerCount(bInGame))
        end,
    }
})