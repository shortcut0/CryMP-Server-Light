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

            elseif (IsAny(sId, "neutral", "none", tostring(GameTeam_Neutral))) then
                return GameTeam_Neutral
            end

        end,

        GetTeam_String = function(self, sId)

            sId = string.lower(sId)
            if (IsAny(sId, "nk", "korea", tostring(GameTeam_NK))) then
                return GameTeam_NK_String

            elseif (IsAny(sId, "us", "america", tostring(GameTeam_US))) then
                return GameTeam_US_String

            elseif (IsAny(sId, "neutral", "none", tostring(GameTeam_Neutral))) then
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

        FSetCVar = function(self, sCVar, sValue)
            if (System.GetCVar(sCVar) == nil) then
                ServerLogError("CVar '%s' not Found", sCVar)
            end
            ServerDLL.FSetCVar(sCVar, sValue)
        end,

        ExecuteCommand = function(self, sCommand, hAdmin)
            local sAdmin = "Server"
            if (hAdmin) then
                sAdmin = hAdmin:GetName()
            end
            if (not sCommand) then
                ServerLogError("No Command Specified to ExecuteCommand")
                return
            end
            if (string.match(sCommand:lower(), "^map")) then
                Server:OnMapCommand()
            end
            ServerLog("%s Executes Command '%s'", sAdmin, sCommand)
            System.ExecuteCommand(sCommand)
        end,

        GetEntityMapCoords = function(self, pEntity)
            local hEntity = self:GetEntity(pEntity)
            if (not hEntity) then
                error("no or invalid entity")
            end

            local aMiniMap = Server.MapRotation:GetMiniMap()
            if (not aMiniMap) then
                return 1, 1
            end

            local vPos = hEntity:GetWorldPos()
            local iPlayerX = vPos.x
            local iPlayerY = vPos.y

            -- [will not]: Move to MapRotation component?! make this REDUNDANT
            local iMiniMapXLength = math.abs(aMiniMap.EndX - aMiniMap.StartX)
            local iMiniMapYLength = math.abs(aMiniMap.EndY - aMiniMap.StartY)

            local iNormalX = (iPlayerX - aMiniMap.StartX) / iMiniMapXLength
            local iNormalY = (iPlayerY - aMiniMap.StartY) / iMiniMapYLength

            iNormalX = math.min(math.max(iNormalX, 0), 1)
            iNormalY = math.min(math.max(iNormalY, 0), 1)

            -- Determine grid coords (1..8)
            local iGridX = math.floor(iNormalX * 8) + 1
            local iGridY = math.floor(iNormalY * 8) + 1

            -- Clamp grid coords to [1..8]
            if (iGridX > 8) then iGridX = 8 end
            if (iGridY > 8) then iGridY = 8 end

            return iGridX, iGridY

        end,

        GetEntityTextCoords = function(self, pEntity)
            local hEntity = self:GetEntity(pEntity)
            if (not hEntity) then
                error("no or invalid entity")
            end

            local sNumeric = { "A", "B", "C", "D", "E", "F", "G", "H" }
            local sAlpha   = { "1", "2", "3", "4", "5", "6", "7", "8" }

            local iGridX, iGridY = self:GetEntityMapCoords(hEntity)
            return ("%s%s"):format(sNumeric[iGridX], sAlpha[iGridY])
        end,

        GetDistance = function(self, vPos1, vPos2)

            if (self:IsEntity(vPos1)) then
                vPos1 = vPos1:GetPos()
            end
            if (self:IsEntity(vPos2)) then
                vPos2 = vPos2:GetPos()
            end

            return Vector.Distance3d(vPos1, vPos2)
        end,

        IsEntity = function(self, pEntity)
            return self:GetEntity(pEntity, true) ~= nil
        end,

        GetEntities = function(self, aInfo)
            local aEntities
            if (aInfo and aInfo.ByClass) then
                aEntities = System.GetEntitiesByClass(aInfo.ByClass)
            end

            return aEntities or {}
        end,

        GetEntity = function(self, hId, bExcludeByName)

            local sType = type(hId)
            if (sType == "userdata") then
                return System.GetEntity(hId)
            elseif (sType == "table" and hId.id ~= nil) then
                return System.GetEntity(hId.id)
            elseif (not bExcludeByName and sType == "string") then
                return System.GetEntityByName(hId)
            end
            return
        end,

        SpawnEffect = function(self, sEffect, vPos, vDir, iScale)
            if (not sEffect) then
                error("no effect")
            end
            g_gameRules:CreateExplosion(NULL_ENTITY, NULL_ENTITY, 1, vPos, (vDir or Vector.Up()), 45, 0.1, 0.1, 0.1, sEffect, (iScale or 1), 0.1, 0.1, 0.1);
        end,

        RevivePlayer = function(self, hPlayer, vPosition, bKeepEquip, tEquip)
            if (vPosition) then
                hPlayer.RevivePosition = vPosition
            else
                hPlayer.RevivePosition = nil
            end

            if (bKeepEquip == nil) then
                bKeepEquip = true
            end

            if (g_gameRules.IS_PS) then
                if ((not hPlayer.spawnGroupId or hPlayer.spawnGroupId == NULL_ENTITY)) then
                    hPlayer.spawnGroupId = g_gameRules.game:GetTeamDefaultSpawnGroup(hPlayer:GetTeam())
                end
            end
            g_gameRules:RevivePlayer(hPlayer:GetChannel(), hPlayer, bKeepEquip, hPlayer.RevivePosition ~= nil, tEquip)
            if (g_gameRules.IS_PS) then
                g_gameRules:ResetRevive(hPlayer.id, true)
            end
        end,

        RenamePlayer = function(self, hPlayer, sName)
            g_gameRules.game:RenamePlayer(hPlayer.id, sName)
        end,

        GetPlayerByName = function(self, sName)
            local sNameLower = sName:lower()
            for _, hPlayer in pairs(self:GetPlayers()) do
                if (hPlayer:GetName():lower() == sNameLower) then
                    return hPlayer
                end
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

                if (aInfo.FromPos) then
                    if (aInfo.InRange) then
                        bOk = bOk and self:GetDistance(hEntity, aInfo.FromPos) < aInfo.InRange
                    elseif (aInfo.OutsideRange) then
                        bOk = bOk and self:GetDistance(hEntity, aInfo.FromPos) > aInfo.OutsideRange
                    end
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