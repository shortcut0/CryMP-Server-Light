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

        ListToConsole = function(self, aParams)


            local sLine     = ""
            local iCurrent  = 0
            local iBoxWidth = (aParams.BoxWidth or Server.Chat:GetConsoleWidth() )

            local hPlayer = aParams.Client
            local aList   = aParams.List
            local sTitle  = aParams.Title
            local iItems  = (aParams.PerLine or 5)
            local sIndex  = aParams.Index
            local iWidth  = (aParams.ItemWidth or (iBoxWidth / iItems))
            local bValue  = (aParams.Value or false)
            local bPIndex = aParams.PrintIndex
            local sColorFilter = aParams.ItemColorFilter

            Server.Chat:ConsoleMessage(hPlayer, string.format("$9%s", string.rep("=", iBoxWidth)))
            Server.Chat:ConsoleMessage(hPlayer, string.format("$9[ %s ]", string.mspace(("$4" .. sTitle .. "$9"), (iBoxWidth - 4), nil, string.COLOR_CODE)))

            local iTotal    = table.count(aList)
            local sItem
            for i, v in pairs(aList) do
                iCurrent = (iCurrent + 1)
                sItem = i
                if (sIndex) then
                    sItem = v[sIndex]
                elseif (bValue) then
                    sItem = v
                end
                if (sColorFilter) then
                    local iStart, iEnd = string.find(sItem, ("^" .. sColorFilter))
                    if (iStart) then
                        local sBefore = sItem:sub(1, iStart - 1) or ""
                        local sPiece = sItem:sub(iStart, iEnd)
                        local sAfter = sItem:sub(iEnd + 1) or ""
                        sItem = sBefore .. CRY_COLOR_YELLOW .. sPiece .. CRY_COLOR_GRAY .. sAfter
                    end
                end
                sLine = sLine .. "$1(" .. string.lspace((bPIndex and tostring(i) or iCurrent), string.len(iTotal)) .. ". $9" .. string.rspace(sItem, iWidth) .. "$1)" .. (iCurrent == iTotal and "" or " ")
                if (iCurrent % iItems == 0 or iCurrent == iTotal) then
                    Server.Chat:ConsoleMessage(hPlayer, "$9[ " .. string.mspace(string.rspace(string.ridtrail(sLine, "%s", 1), (iBoxWidth - 4), string.COLOR_CODE), iBoxWidth - 4, nil, string.COLOR_CODE)  .. " $9]")
                    sLine = ""
                else
                end
            end
            Server.Chat:ConsoleMessage(hPlayer, string.format("$9%s", string.rep("=", iBoxWidth)))
        end,

        FindCVarByName = function(self, sCVar, hPlayer)
            local aCVars = ServerDLL.GetVars()
            local iCVars = table.size(aCVars)
            if (iCVars == 0) then
                if (hPlayer) then
                --    Server.Chat:ChatMessage(Server:GetEntity(), hPlayer, "@noClassToDisplay", { Class = "CVars" })
                end
                return false, nil, (hPlayer and hPlayer:LocalizeText("@noClassToDisplay", { Class = "CVars" }))
            end

            local aFound
            if (sCVar) then
                aFound = table.it(aCVars, function(x, i, v)
                    local t = x
                    local a = string.lower(v)
                    local b = string.lower(sCVar)
                    if (a == b) then
                        return { v }, 1
                    elseif (string.len(b) > 0 and string.match(a, "^" .. b)) then
                        if (t) then
                            table.insert(t, v)
                            return t
                        end
                        return { v }
                    end
                    return t
                end)

                if (table.count(aFound) == 0) then
                    --aFound = nil
                    return false, nil, (hPlayer and hPlayer:LocalizeText("@noClassToDisplay", { Class = "CVars" }))
                end
            end

            local iFound = table.count(aFound)
            if (sCVar == nil or (not aFound or iFound > 1)) then
                if (hPlayer) then
                    local iElementsPerLine = 3
                    if (iFound < 50) then
                        iElementsPerLine = 1
                    elseif (iFound < 80) then
                        iElementsPerLine = 2
                    end
                    self:ListToConsole({
                        Client      = hPlayer,
                        List        = (aFound or aCVars),
                        Title       = hPlayer:LocalizeText("@classList", { Class = "CVars" }),
                        ItemWidth   = 96 / iElementsPerLine,
                        PerLine     = iElementsPerLine,
                        Value       = 1,
                        ItemColorFilter = sCVar
                    })
                    --Server.Chat:ChatMessage(Server:GetEntity(), hPlayer, "@entitiesListedInConsole", { Class = "CVars", Count = table.size((aFound or aCVars)) })
                end
                return false, aFound, (hPlayer and hPlayer:LocalizeText("@entitiesListedInConsole", { Class = "CVars", Count = table.size((aFound or aCVars)) }))
            end

            return true, aFound[1]
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

        FindPlayerByName = function(self, sName, bGreedy, bIgnoreChannels)

            sName = string.Escape(sName)
            local sNameLower = string.lower(sName)

            local aFound = {}
            local aChanFound = {}
            local iChannel

            for _, hClient in pairs(self:GetPlayers()) do
                if (bGreedy) then
                    if (string.match(string.lower(hClient:GetName()), sNameLower)) then
                        table.insert(aFound, hClient)
                    end
                elseif (string.match(hClient:GetName(), sName)) then
                    table.insert(aFound, hClient)
                end

                if (not bIgnoreChannels) then
                    iChannel = string.match(sName, "^chan(%d+)$")
                    if (iChannel) then
                        if (hClient:GetChannel() == iChannel) then
                            table.insert(aChanFound, hClient)
                        end
                    end
                end
            end

            local iResults = table.size(aFound)
            if (table.count(aChanFound) == 1 and (iResults > 1 or iResults == 0)) then
                return aChanFound[1]
            end
            if (iResults > 1) then
                return
            elseif (iResults == 0 and not bGreedy) then
                return self:FindPlayerByName(sName, true, bIgnoreChannels)
            end

            return aFound[1]
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

                if (aInfo.ById) then
                    bOk = (bOk and (aInfo.ById == hEntity.id))
                elseif (aInfo.NotById) then
                    bOk = (bOk and (aInfo.NotById ~= hEntity.id))
                end

                if (aInfo.ByTeam) then
                    bOk = (bOk and (self:GetTeamId(hEntity.id) == aInfo.ByTeam))
               elseif (aInfo.NotByTeam) then
                    bOk = (bOk and (self:GetTeamId(hEntity.id) ~= aInfo.NotByTeam))
                end

                if (aInfo.ByAccess) then
                    bOk = (bOk and (hEntity:HasAccess(aInfo.ByAccess)))
                elseif (aInfo.NotByAccess) then
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