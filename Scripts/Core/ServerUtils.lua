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

        ByteSuffix = function(iBytes, iNulls)
            return string.ByteSuffix(iBytes, iNulls)
        end,

        GetCVar = function(sCVar)
            local sValue = System.GetCVar(sCVar)
            if (sValue == nil) then
                ServerLogError("CVar '%s' not Found", sCVar)
            end
            return sValue
        end,

        SetCVar = function(sCVar, sValue)
            if (System.GetCVar(sCVar) == nil) then
                ServerLogError("CVar '%s' not Found", sCVar)
            end
            System.SetCVar(sCVar, sValue)
        end,

        FindPlayerByName = function()
        end,

        GetPlayerByChannel = function(iChannel)
            return g_gameRules.game:GetPlayerByChannelId(iChannel)
        end,

        GetPlayers = function(aInfo)
            local aPlayers = {}
            for _, hEntity in pairs(System.GetEntitiesByClass("Player") or {}) do
                local bOk = true
                if (not aInfo.IncludeNPC and hEntity.actor:IsPlayer()) then
                    bOk = false
                end
                if (bOk and (aInfo.TeamID and hEntity:GetTeam() == aInfo.TeamID)) then
                    bOk = true
                end
                if (bOk) then
                    table.insert(aPlayers, hEntity)
                end
            end
            return aPlayers
        end,

        GetPlayerCount = function(bInGame)
            return (g_gameRules.game:GetPlayerCount(bInGame))
        end,
    }
})