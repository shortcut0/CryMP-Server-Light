-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
--                          This file Contains Chat-Commands
-- ===================================================================================

Server.ChatCommands:Add({

    -- ================================================================
    -- !Revive <Target> <AtSpawn>
    {
        Name = "Revive",
        Access = ServerAccess_Admin,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Required = true, Type = CommandArg_TypePlayer, Default = "self", AcceptSelf = true, AcceptAll = true },
            { Name = "@option1",Desc = "@arg_revive_option_desc",  },
        },
        Properties = {
        },
        Function = function(self, hTarget, sOption)
            if (hTarget == self) then
                Server.Utils:RevivePlayer(self, (not sOption and self:GetPos()))
                Server.Utils:SpawnEffect(Effect_LightExplosion, hTarget:GetPos())
                return true
            elseif (hTarget == ALL_PLAYERS) then
                for _, hVictim in pairs(Server.Utils:GetPlayers()) do
                    Server.Utils:RevivePlayer(hVictim, (not sOption and hVictim:GetPos()))
                    Server.Utils:SpawnEffect(Effect_LightExplosion, hVictim:GetPos())
                    if (hVictim ~= self) then
                        Server.Chat:ChatMessage(ChatEntity_Server, hVictim, "@you_were_revived", {})
                    end
                end
                return true
            end

            Server.Utils:RevivePlayer(hTarget, (not sOption and hTarget:GetPos()))
            Server.Utils:SpawnEffect(Effect_LightExplosion, hTarget:GetPos())
            Server.Chat:ChatMessage(ChatEntity_Server, hTarget, "@you_were_revived", {})
            return true
        end
    },

    -- ================================================================
    -- !Bring <Target> <IntoVehicle>
    {
        Name = "Bring",
        Access = ServerAccess_Admin,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Required = true, Type = CommandArg_TypePlayer, NotSelf = true, AcceptAll = true },
            { Name = "@option1",Desc = "@arg_bring_option_desc",  },
        },
        Properties = {
        },
        Function = function(self, hTarget, bIntoVehicle)

            local vPos = self:CalcPos(1.75)
            if (hTarget == ALL_PLAYERS) then
                for _, hVictim in pairs(Server.Utils:GetPlayers()) do
                    if (hVictim ~= self) then
                        if (hVictim:IsDead()) then
                            Server.Utils:RevivePlayer(hVictim, vPos)
                        else
                            if (hVictim:GetVehicle()) then
                                hVictim:LeaveVehicle()
                            end
                            Script.SetTimer(10, function()
                                hVictim:SvMoveTo(vPos)
                            end)
                        end
                        Server.Utils:SpawnEffect(Effect_LightExplosion, vPos)
                        Server.Chat:ChatMessage(ChatEntity_Server, hVictim, "@you_were_broughtTo", { To = self:GetName() })
                        if (bIntoVehicle) then
                            local hVehicle = self:GetVehicle()
                            local iFreeSeat = self:GetFreeVehicleSeat()
                            if (iFreeSeat) then
                                hVehicle.vehicle:EnterVehicle(hVictim.id, iFreeSeat, false)
                            end
                        end
                    end
                end
                return true
            end

            if (hTarget:IsDead()) then
                Server.Utils:RevivePlayer(hTarget, vPos)
            else
                if (hTarget.actor:GetLinkedVehicleId()) then
                    hTarget:LeaveVehicle()
                end
                Script.SetTimer(10, function()
                    hTarget:SvMoveTo(vPos)
                end)
            end
            if (bIntoVehicle) then
                local hVehicle = self:GetVehicle()
                local aFreeSeat = self:GetFreeVehicleSeat()
                if (aFreeSeat) then
                    hVehicle.vehicle:EnterVehicle(hTarget.id, aFreeSeat.id, false)
                end
            end
            Server.Utils:SpawnEffect(Effect_LightExplosion, vPos)
            Server.Chat:ChatMessage(ChatEntity_Server, hTarget, "@you_were_broughtTo", { To = self:GetName() })
            return true
        end
    },

    -- ================================================================
    -- !Goto <Target> <IntoVehicle>
    {
        Name = "Goto",
        Access = ServerAccess_Admin,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Required = true, Type = CommandArg_TypePlayer, NotSelf = true,},
            { Name = "@option1",Desc = "@arg_goto_option_desc", Default = "1", Type = CommandArg_TypeBoolean },
        },
        Properties = {
        },
        Function = function(self, hTarget, bIntoVehicle)

            local bUseDV = true -- directional vector instead of actual look direction
            local vPos = hTarget:CalcPos(1, bUseDV)
            if (self:IsDead()) then
                Server.Utils:RevivePlayer(self, vPos)
            else
                self:SvMoveTo(vPos)
            end
            if (bIntoVehicle) then
                local hVehicle = hTarget:GetVehicle()
                local aFreeSeat = hTarget:GetFreeVehicleSeat()
                if (aFreeSeat) then
                    hVehicle.vehicle:EnterVehicle(self.id, aFreeSeat, false)
                end
            end
            Server.Utils:SpawnEffect(Effect_LightExplosion, vPos)
            Server.Chat:ChatMessage(ChatEntity_Server, self, "@you_teleportedTo", { To = hTarget:GetName() })
            Server.Chat:ChatMessage(ChatEntity_Server, hTarget, "@x_teleportedToYou", { X = self:GetName() })
            return true
        end
    },

    -- ================================================================
    -- !Spectate <Target>
    {
        Name = "Spectate",
        Access = ServerAccess_Admin,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Required = false, Type = CommandArg_TypePlayer },
        },
        Properties = {
        },
        Function = function(self, hTarget)

            -- Stop
            if (self:IsSpectating()) then
                self:Revive(self:GetPos(), self:GetTemp("SpectatorEquip", true))
                return true
            end

            -- Start
            if (g_gameRules.IS_PS) then-- and not self.Info.TeamSelected) then
                if (self:GetTeam() == GameTeam_Neutral) then
                    self:SetTeam(GameTeam_US) -- Not racially motivated
                end
            end
            self:SetTemp("SpectatorEquip", self:GetEquipment())
            self:Spectate(1, hTarget)
            return true
        end
    },

    -- ================================================================
    -- !GiveXP <Target> <Amount> <Reason>
    {
        Name = "GiveXP",
        Access = ServerAccess_Admin,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Required = true, Type = CommandArg_TypePlayer },
            { Name = "@amount", Desc = "@arg_amount_desc", Required = true, Type = CommandArg_TypeNumber, Minimum = 1, Maximum = 255 },
            { Name = "@reason", Desc = "@arg_reason_desc", Type = CommandArg_TypeMessage, Default = "@admin_decision" },
        },
        Properties = {
           -- GameRules = GameMode_PS, -- r:works for IA too
        },
        Function = function(self, hTarget, iAmount, sReason)
            g_gameRules:XPEvent(hTarget, iAmount, sReason)
        end
    },

    -- ================================================================
    -- !GivePrestige <Target> <Amount> <Reason>
    {
        Name = "GivePrestige",
        Access = ServerAccess_Admin,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Required = true, Type = CommandArg_TypePlayer,  },
            { Name = "@amount", Desc = "@arg_amount_desc", Required = true, Type = CommandArg_TypeNumber, Minimum = 1, Maximum = 10000 },
            { Name = "@reason", Desc = "@arg_reason_desc", Type = CommandArg_TypeMessage, Default = "@admin_decision" },
        },
        Properties = {
            GameRules = GameMode_PS,
            CoolDown = 10,
        },
        Function = function(self, hTarget, iAmount, sReason)
            g_gameRules:PrestigeEvent(hTarget, iAmount, sReason)
        end
    },

    -- ================================================================
    -- !GivePrestige <Target> <Amount> <Reason>
    {
        Name = "GiveItem",
        Access = ServerAccess_Admin,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", AcceptSelf = true,Required = true, Type = CommandArg_TypePlayer,  },
            { Name = "@Item",  Desc = "@arg_item_class" , Required = true },
            { Name = "@amount",  Desc = "@arg_amount_desc", Required = true, Default = 1, Type = CommandArg_TypeNumber, Minimum = 1, Maximum = 100 },
        },
        Properties = {
            CoolDown = 10,
        },
        Function = function(self, hTarget, sClass, iCount, ...)

            local aItems = ServerDLL.GetItemClasses()
            local iItems = table.size(aItems)
            if (iItems == 0) then
                return false, self:LocalizeText("@noClassToDisplay", {Class = "@items"})
            end

            local aFound
            if (sClass) then
                aFound = table.it(aItems, function(x, i, v)
                    local t = x
                    local a = string.lower(v)
                    local b = string.lower(sClass)
                    if (a == b) then
                        return { v }, 1
                    elseif (string.len(b) > 1 and string.match(a, "^" .. b)) then
                        if (t) then
                            table.insert(t, v)
                            return t
                        end
                        return { v }
                    end
                    return t
                end)
                if (table.count(aFound) == 0) then aFound = nil end
            end
            if (sClass == nil or (not aFound or table.count(aFound) > 1)) then
                Server.Utils:ListToConsole({
                    Client      = self,
                    List        = (aFound or aItems),
                    Title       = self:LocalizeText("@item_list"),
                    ItemWidth   = 20,
                    PerLine     = 4,
                    Value       = 1
                })
                return true, self:LocalizeText("@entitiesListedInConsole", { Class = "@items", Count = table.count((aFound or aItems)) })
            end

            local sItem = aFound[1]
            local hReceived
            local aAttachments = { ... }

            if (hTarget == ALL_PLAYERS) then
                for _, hPlayer in pairs(Server.Utils:GetPlayers()) do
                    if (hPlayer:IsAlive()) then
                        if (hPlayer ~= self) then
                            for _ = 1, iCount do
                                hReceived = hPlayer:GiveItem(sItem)
                            end
                            if (hReceived) then
                                Server.PlayerEquipment:AttachOnWeapon(hPlayer, Server.Utils:GetEntity(hReceived), aAttachments)
                            end
                        end
                        if (self ~= hPlayer) then
                            Server.Chat:ChatMessage(ChatEntities.Equipment, self, self:LocalizeText("@item_Received", { By = self:GetName(), Item = sItem, Count = iCount }))
                        end
                    end
                end
                Server.Chat:ChatMessage(ChatEntities.Equipment, self, self:LocalizeText("@item_given_to", { Name = "@all_players", Item = sItem, Count = iCount }))
                return true
            else
                for i = 1, iCount do
                    hReceived = hTarget:GiveItem(sItem)
                end
                if (hReceived) then
                    Server.PlayerEquipment:AttachOnWeapon(hTarget, Server.Utils:GetEntity(hReceived), aAttachments)
                end
                if (self ~= hTarget) then
                    Server.Chat:ChatMessage(ChatEntities.Equipment, self, self:LocalizeText("@item_Received", { By = self:GetName(), Item = sItem, Count = iCount }))
                end
                Server.Chat:ChatMessage(ChatEntities.Equipment, self, self:LocalizeText("@item_given_to", { Name = (hTarget == self and "@yourself" or hTarget:GetName()), Item = sItem, Count = iCount }))
            end
            return true
        end
    },
})