-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- Contains Patched functions for 'HQ'
-- ===================================================================================

Server.Patcher:HookClass({
    Class = "HQ",
    Body  = {
        {
            ---------------------------
            --      ProcessHit
            ---------------------------
            Name  = "ProcessHit",
            Value = function(self, tHit)

                local hShooter = tHit.shooter
                local hShooterId = tHit.shooterId

                local bTesting = (hShooter and hShooter.IsPlayer and hShooter:IsInTestMode())
                local aConfig = g_gameRules.HQConfig
                if (not aConfig) then
                    return true
                end

                if (not aConfig.UseCustomHQSettings) then
                    return true
                end

                local iShooterTeam = g_gameRules.game:GetTeam(hShooterId)
                local iHQTeam = g_gameRules.game:GetTeam(self.id)

                if (iShooterTeam and (iShooterTeam == 0 or iShooterTeam ~= self:GetTeamId()) and (tHit.explosion or bTesting) and tHit.type and (tHit.type == "tac" or bTesting)) then --if tac hit

                    local sHQTeam = Server.Utils:GetTeam_String(iHQTeam)
                    if (aConfig.HQUnDestroyable) then
                        Server.Chat:TextMessage(ChatType_Error, ALL_PLAYERS, "@hq_notDestroyable_UPPER")
                        Server.Chat:ChatMessage(ChatEntities.HQMod, hShooter, "@hq_notDestroyable")
                        tHit.damage = 0
                        return false
                    end

                    local iRemaining = (MAP_START_TIME + aConfig.AttackDelay) - _time
                    if (aConfig.AttackDelay > 0 and iRemaining > 0) then
                        local sRemaining = Date:Format(iRemaining)

                        Server.Chat:TextMessage(ChatType_Error, ALL_PLAYERS, "@hq_protectedTime_UPPER", { Time = sRemaining })
                        Server.Chat:ChatMessage(ChatEntities.HQMod, hShooter, "@hq_protectedTime", { Time = sRemaining })
                        tHit.damage = 0
                        return false
                    end


                    local iNewHP, iNeededHits
                    local sHitMsg
                    local tRewards = aConfig.HitRewards
                    local iRewardMult = aConfig.PremiumRewardAmplification
                    local iPP = tRewards.PP or 0
                    local iXP = tRewards.XP or 0

                    if (aConfig.LocalizedDamage) then
                        -- TODO
                        error("fixme")
                        Debug(checkFunc(self.GetRadius,-696969,self))
                        local iRadius = 65
                        local AABB = { self:GetLocalBBox() }
                        if (table.count(AABB) >= 1) then
                            iRadius = vector.length(vector.bbox_size(AABB))
                        end
                        local vHQPos = vector.modifyz(self:GetPos(), 5.3) -- centerofmasspos() there is none since its a static object
                        local iDamage = tHit.damage
                        local iHitDistance = vector.distance(tHit.pos, vHQPos) - 0.25
                        local iHitAccuracy = math.max(0, math.min(100, (1 - (iHitDistance / (iRadius))) * 100))
                        iRewardMult = (iHitAccuracy / 100)
                        sHitMsg = table.it({
                            [0] = "@l_ui_horrible",
                            [50] = "@l_ui_bad",
                            [60] = "@l_ui_decent",
                            [70] = "@l_ui_good",
                            [80] = "@l_ui_verygood",
                            [90] = "@l_ui_perfect",
                            [999] = "@l_ui_godlike",
                        }, function(x, i, v) if (iHitAccuracy >= i and (x == nil or x[1] < i)) then return { i, v } end return x end)[2]
                        iNewHP = (iDamage * (iHitAccuracy / 100))
                    else
                        tHit.damage = math.ceil(self.Properties.nHitPoints / aConfig.TacHits)
                        iNewHP = (self:GetHealth() - tHit.damage)
                        iNeededHits = (iNewHP / tHit.damage)
                        self.RemainingHits = iNeededHits
                    end


                    local sShooterName = hShooter:GetName()

                    if (hShooter:IsPremium()) then
                        iXP = iXP * iRewardMult
                        iPP = iPP * iRewardMult
                    end
                    g_gameRules:PrestigeEvent(hShooter.id, { iPP, iXP }, "@enemy_hq_hit")
                    local sReward = string.format(" (+$4%d$9 PP, +$4%d$9 XP)", iPP, iXP)

                    local sTeamPlayers = Server.Utils:GetPlayers({ ByTeam = g_gameRules.game:GetTeam(tHit.shooter.id) })
                    local oTeamPlayers = Server.Utils:GetPlayers({ NotByTeam = g_gameRules.game:GetTeam(tHit.shooter.id) })

                    if (iNewHP > 0) then

                        Server.Chat:TextMessage(ChatType_Error, sTeamPlayers, "@enemy_hq_wasHit", { Name = sShooterName, Reward = sReward })--"** ENEMY HQ HIT BY :: %s %s**", shooterName, (reward and "- GOT " .. pp .. " PRESTIGE "or""));
                        Server.Chat:TextMessage(ChatType_Error, oTeamPlayers, "@our_hq_wasHit", { Name = sShooterName, Remaining = self.RemainingHits })--"** ENEMY HQ HIT BY :: %s %s**", shooterName, (reward and "- GOT " .. pp .. " PRESTIGE "or""));

                        Server.Logger:LogEvent({
                            Class = "HQMods",
                            Event = "HQMods",
                            Recipients = sTeamPlayers,
                            Message = "@our_hq_wasHit",
                            MessageFormat = { Name = sShooterName, Remaining = self.RemainingHits }
                        })
                        Server.Logger:LogEvent({
                            Class = "HQMods",
                            Event = "HQMods",
                            Recipients = oTeamPlayers,
                            Message = "@enemy_hq_wasHit",
                            MessageFormat = { Name = sShooterName, Reward = sReward }
                        })
                    else--if (iNeededHits <= 0 and iNewHP <= 0) then

                        Server.Chat:TextMessage(ChatType_Error, sTeamPlayers, "@enemy_hq_wasDestroyed", { Name = sShooterName,  })--"** ENEMY HQ HIT BY :: %s %s**", shooterName, (reward and "- GOT " .. pp .. " PRESTIGE "or""));
                        Server.Chat:TextMessage(ChatType_Error, oTeamPlayers, "@our_hq_wasDestroyed", { Name = sShooterName, })--"** ENEMY HQ HIT BY :: %s %s**", shooterName, (reward and "- GOT " .. pp .. " PRESTIGE "or""));


                        Server.Logger:LogEvent({
                            Class = "HQMods",
                            Event = "HQMods",
                            Recipients = sTeamPlayers,
                            Message = "@enemy_hq_wasDestroyed",
                            MessageFormat = { Name = sShooterName }
                        })
                        Server.Logger:LogEvent({
                            Class = "HQMods",
                            Event = "HQMods",
                            Recipients = oTeamPlayers,
                            Message = "@our_hq_wasDestroyed",
                            MessageFormat = { Name = sShooterName }
                        })
                    end
                end
                return true
            end,
        },
        {
            ---------------------------
            --     AttackTACBearer
            ---------------------------
            Name  = "AttackTACBearer",
            Value = function(self, hTarget)

                local aNearbyTurrets = Server.Utils:GetEntities({ ByTeam = self:GetTeamId(), Class = { "AutoTurret", "AutoTurretAA", }, InRange = 100, FromPos = self:GetPos() })
                if (table.empty(aNearbyTurrets)) then
                    return
                end

                if (not g_gameRules.TurretConfig.TargetHQAttackers) then
                    return
                end

                if (not (hTarget.actor or hTarget.vehicle)) then
                    return
                end

                for _, hTurret in pairs(aNearbyTurrets) do
                    if (not hTurret.item:IsDestroyed()) then
                        hTurret.GunTurret:SetAimPosition(hTarget:GetPos(), 10)
                        Script.SetTimer(2500, function()
                            hTurret.GunTurret:SetTarget(hTarget.id, 7.5)
                        end)
                    end
                end
            end,
        },
        {
            ---------------------------
            --      Server.OnHit
            ---------------------------
            Name  = "Server.OnHit",
            Value = function(self, tHit)
                if (self.destroyed) then
                    return
                end

                local bDestroyed = false
                -- check if destroyed, decrease health if needed

                local teamId=g_gameRules.game:GetTeam(tHit.shooterId)
                if (teamId == 0 or teamId ~= self:GetTeamId()) then

                    if (self:ProcessHit(tHit)) then
                        return false
                    end
                    if (tHit.explosion and tHit.type == "tac") then

                        self:SetHealth(self:GetHealth() - tHit.damage)
                        if (self:GetHealth() <= 0) then
                            bDestroyed = true
                        end

                        self:AttackTACBearer(tHit.shooter)

                        if (tHit.damage>0 and tHit.type~="repair") then
                            if (g_gameRules.Server.OnHQHit) then
                                g_gameRules.Server.OnHQHit(g_gameRules, self, tHit)
                            end
                        end
                    end
                end

                if (bDestroyed) then
                    if (not self.isClient) then
                        self:Destroy()
                    end

                    self.allClients:ClDestroy()
                    if (g_gameRules and g_gameRules.OnHQDestroyed) then
                        g_gameRules:OnHQDestroyed(self, tHit.shooterId, teamId)
                    end
                end

                return bDestroyed
            end
        }
    }
})
