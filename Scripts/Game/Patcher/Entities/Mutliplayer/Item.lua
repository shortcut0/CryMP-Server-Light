-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- Contains Patched functions for 'Item'
-- ===================================================================================

Server.Patcher:HookClass({
    Class = "Item",
    Body  = {
        {
            Name = "Server.OnHit",
            Value = function(self, tHit)

                -- !! AntiCheat
                if (not Server.AntiCheat:ProcessItemHit(tHit)) then
                    tHit.damage = 0
                    return false
                end

                local explosionOnly=tonumber(self.Properties.bExplosionOnly or 0)~=0
                local hitpoints = self.Properties.HitPoints

                if (hitpoints and (hitpoints > 0)) then
                    local destroyed=self.item:IsDestroyed()
                    if (tHit.type=="repair") then
                        self.item:OnHit(tHit)
                    elseif ((not explosionOnly) or (tHit.explosion)) then
                        if ((not g_gameRules:IsMultiplayer()) or g_gameRules.game:GetTeam(tHit.shooterId)~=g_gameRules.game:GetTeam(self.id)) then
                            self.item:OnHit(tHit)
                            if (not destroyed) then
                                if (tHit.damage>0) then
                                    if (g_gameRules.Server.OnTurretHit) then
                                        g_gameRules.Server.OnTurretHit(g_gameRules, self, tHit)
                                    end
                                end

                                if (self.item:IsDestroyed()) then
                                    if(self.FlowEvents and self.FlowEvents.Outputs.Destroyed)then
                                        self:ActivateOutput("Destroyed",1)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        }
    }
})

