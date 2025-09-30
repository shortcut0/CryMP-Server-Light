-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- Contains Patched functions for 'ForbiddenArea'
-- ===================================================================================

Server.Patcher:HookClass({
    Class = "ForbiddenArea",
    Body  = {
        {
            ---------------------------
            --      PunishPlayer
            ---------------------------
            Name  = "PunishPlayer",
            Value = function(self, hPlayer, iTime)

                if (not hPlayer) then
                    return
                end

                local pGR = g_gameRules
                if (pGR.Config.DisableForbiddenAreas or (hPlayer.IsPlayer and hPlayer:HasGodMode(1))) then
                    return
                end

                if ((hPlayer.actor:GetSpectatorMode() ~= 0) or hPlayer:IsDead()) then
                    return
                end

                local warning = self.warning[hPlayer.id]
                if (warning and warning > 0) then
                    warning = warning - (iTime / 1000)
                    self.warning[hPlayer.id] = warning

                elseif (not warning) then
                    warning = self.delay
                    self.warning[hPlayer.id] = warning
                end

                if (self.showWarning) then
                    pGR.game:ForbiddenAreaWarning(true, warning, hPlayer.id)
                end

                if (warning <= 0) then
                    pGR:CreateHit(hPlayer.id, hPlayer.id, hPlayer.id, self.dps * (iTime / 1000), nil, nil, nil, "punish")
                end
            end
        },
        {
            ---------------------------
            --   Server.OnLeaveArea
            ---------------------------
            Name  = "Server.OnEnterArea",
            Value = function(self, hEntity, AreaId)

                if (not hEntity) then
                    return
                end

                local bShowIndicator = true
                local pGR = g_gameRules

                if (pGR.Config.DisableForbiddenAreas or (hEntity.IsPlayer and hEntity:HasGodMode(1))) then
                    bShowIndicator = false
                end

                if (hEntity.actor) then
                    local inside = false
                    for i, v in ipairs(self.inside) do
                        if (v == hEntity.id) then
                            inside = true
                            break
                        end
                    end

                    if (inside) then
                        return
                    end

                    table.insert(self.inside, hEntity.id)

                    if (bShowIndicator) then
                        if ((not self.teamId) or (self.teamId ~= pGR.game:GetTeam(hEntity.id))) then
                            if (not self.reverse) then
                                self.warning[hEntity.id] = self.delay
                                if (self.showWarning) then
                                    if ((hEntity.actor:GetSpectatorMode() == 0) and (not hEntity:IsDead())) then
                                        pGR.game:ForbiddenAreaWarning(true, self.delay, hEntity.id)
                                    end
                                end
                            else
                                self.warning[hEntity.id] = nil
                                if (self.showWarning) then
                                    pGR.game:ForbiddenAreaWarning(false, 0, hEntity.id)
                                end
                            end
                        end
                    end
                end
            end
        },
        {
            ---------------------------
            --   Server.OnLeaveArea
            ---------------------------
            Name  = "Server.OnLeaveArea",
            Value = function(self, hEntity, AreaId)

                if (not hEntity) then
                    return
                end

                local bShowIndicator = true
                local pGR = g_gameRules

                if (pGR.Config.DisableForbiddenAreas or (hEntity.IsPlayer and hEntity:HasGodMode(1))) then
                    bShowIndicator = false
                end

                if (hEntity.actor) then
                    local inside = false
                    for i,v in ipairs(self.inside) do
                        if (v == hEntity.id) then
                            inside = true
                            table.remove(self.inside, i)
                            break
                        end
                    end

                    if (bShowIndicator) then
                        if ((not self.teamId) or (self.teamId ~= pGR.game:GetTeam(hEntity.id))) then
                            if (self.reverse) then
                                if (inside) then
                                    self.warning[hEntity.id] = self.delay
                                    if (self.showWarning) then
                                        if ((hEntity.actor:GetSpectatorMode() == 0) and (not hEntity:IsDead())) then
                                            pGR.game:ForbiddenAreaWarning(true, self.delay, hEntity.id)
                                        end
                                    end
                                end
                            else
                                self.warning[hEntity.id] = nil
                                if (self.showWarning) then
                                    pGR.game:ForbiddenAreaWarning(false, 0, hEntity.id)
                                end
                            end
                        end
                    end
                end
            end,
        },
    },
})