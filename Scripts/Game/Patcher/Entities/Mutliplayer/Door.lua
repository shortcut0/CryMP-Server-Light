-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- Contains Patched functions for 'Door'
-- ===================================================================================

Server.Patcher:HookClass({
    Class = "Door",
    Body  = {
        {
            ---------------------------
            -- Check if door will open toward user
            ---------------------------
            Name  = "CheckIfOpensTowardUser",
            Value = function(self, user)
                if not user or not self.frontAxis then
                    return false
                end

                local userForward = g_Vectors.temp_v2
                local myPos = self:GetWorldPos(g_Vectors.temp_v3)
                local userPos = user:GetWorldPos(g_Vectors.temp_v4)

                SubVectors(userForward, myPos, userPos)
                NormalizeVector(userForward)

                local dot = dotproduct3d(self.frontAxis, userForward)

                -- dot > 0 = door faces toward user
                return dot > 0
            end
        },
        {
            ---------------------------
            --      Server.OnHit
            ---------------------------
            Name  = "Server.OnHit",
            Value = function(self, tHit)
                if g_gameRules.Config.OpenDoorsOnCollision then
                    if (tHit.type == "melee") then
                        Server.Utils:SpawnEffect("bullet.hit_metal.a" or "explosions.Deck_sparks.VTOL_explosion", tHit.pos, tHit.normal, 0.3)
                        self:Open(tHit.shooter, DOOR_TOGGLE, true)
                    end
                end
            end
        },
        {
            ---------------------------
            --      Open
            ---------------------------
            Name  = "Open",
            Value = function(self, user, mode, bOnlyIfOpensForward)

                local lastAction = self.action;

                if (mode == DOOR_TOGGLE) then
                    if (self.action == DOOR_OPEN) then
                        self.action = DOOR_CLOSE;
                    else
                        self.action = DOOR_OPEN;
                    end
                else
                    self.action = mode;
                end

                if (lastAction == self.action) then
                    return 0;
                end

                if (self.Properties.Rotation.fRange ~= 0) then
                    local open=false;
                    local fwd=true;

                    if (self.action == DOOR_OPEN) then
                        if (user and (tonumber(self.Properties.Rotation.bRelativeToUser) ~=0)) then
                            local userForward=g_Vectors.temp_v2;
                            local myPos=self:GetWorldPos(g_Vectors.temp_v3);
                            local userPos=user:GetWorldPos(g_Vectors.temp_v4);
                            SubVectors(userForward,myPos,userPos);
                            NormalizeVector(userForward);

                            local dot = dotproduct3d(self.frontAxis, userForward);

                            if (dot<0) then
                                fwd=false;
                            end
                        end

                        open=true;
                    end

                    local bForward = (open and fwd or not fwd)
                    if (not bForward and bOnlyIfOpensForward) then
                        self.action = lastAction
                        return
                    end

                    self.fwd=fwd;
                    self:Rotate(open, fwd);
                    self.allClients:ClRotate(open, fwd);
                end

                if (self.Properties.Slide.fRange ~= 0) then
                    local open=(self.action == DOOR_OPEN);

                    self:Slide(open);
                    self.allClients:ClSlide(open);
                end

                if AI then
                    if (self.action == DOOR_OPEN) then
                        AI.ModifySmartObjectStates( self.id, "Open-Closed" );
                        BroadcastEvent(self, "Open");
                    elseif (self.action == DOOR_CLOSE) then
                        AI.ModifySmartObjectStates( self.id, "Closed-Open" );
                        BroadcastEvent(self, "Close");
                    end
                end

                return 1;
            end
        }
    }
})
