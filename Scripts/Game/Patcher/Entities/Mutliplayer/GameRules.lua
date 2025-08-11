-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- Contains Patched functions for all game modes
-- ===================================================================================

Server.Patcher:HookClass({

    -- This is the actual patching target
    Parent = "SinglePlayer",

    -- These will then use the same Parent Body to save memory!
    Class = {
        "TeamInstantAction",
        "InstantAction",
        "PowerStruggle",
    },

    -- The Actual body
    Body = {
        {
            ------------------------------
            ---        Template
            ------------------------------
            Name = "Hook_Template",
            Value = "Hook_TemplateValue",
            Value = { "Hook_TemplateValue" },
            Value = function(self) return "Hook_TemplateValue"  end,
        },
        {
            ------------------------------
            ---        Template
            ------------------------------
            Name = "123",
            Value = { "Hook_TemplateValue", { [5] = { 1 }, {{3,{{5,{"ff",{{5}}}}}}}} },
        },
        {
            ------------------------------
            ---   Initialize_CryMP
            ------------------------------
            Name = "Initialize_CryMP",
            Value = function(self)

                self.LogClass = "GameRules"

                Server:CreateLogAbstract(self, self.LogClass)
                Server.Events:LinkEvent(ServerEvent_OnPostInit, self, self.PostInitialize)
            end,
        },
        {
            ------------------------------
            ---      PostInitialize
            ------------------------------
            Name = "PostInitialize",
            Value = function(self)

                self.IS_PS    = (self.class == GameMode_PS)
                self.IS_IA    = (self.class == GameMode_IA)
                self.IS_TIA   = (self.class == GameMode_TIA)

                self.SkipPreGame = Server.Config:Get("GameConfig.SkipPreGames", false, ConfigType_Boolean)
                if (self.SkipPreGame and self:GetState() ~= "InGame") then
                    self:GotoState("InGame")
                end

                self.KillConfig = {
                    SuicideKills    = Server.Config:Get("GameConfig.KillConfig.DeductSuicideKills", 0,  ConfigType_Number),
                    SuicideDeaths   = Server.Config:Get("GameConfig.KillConfig.SuicideAddDeaths", 1,    ConfigType_Number),
                    TeamKill        = Server.Config:Get("GameConfig.KillConfig.DeductTeamKill", 1,      ConfigType_Number),
                    BotScore        = Server.Config:Get("GameConfig.KillConfig.DeductBotKills", false,  ConfigType_Boolean),
                    NewMessages     = Server.Config:Get("GameConfig.KillConfig.EnableNewKillMessages", true, ConfigType_Boolean)
                }

                self.StreakMessages = {
                    Deaths  = Server.Config:Get("GameConfig.KillConfig.KillStreaks.DeathMessages", {}, ConfigType_Array),
                    Kills   = Server.Config:Get("GameConfig.KillConfig.KillStreaks.KillMessages", {}, ConfigType_Array),
                    Repeats = Server.Config:Get("GameConfig.KillConfig.KillStreaks.RepeatMessages", {}, ConfigType_Array)
                }

                Server.Utils:SetCVar("mp_killMessages", (self.KillConfig.NewMessages and "0" or "1"))
                self:Log("PostInitialize")
            end,
        },
        {
            ------------------------------
            ---        OnSpawn
            ------------------------------
            Name = "OnSpawn",
            Value = function(self)
                Server:OnGameRulesSpawn(self)
                self:Initialize_CryMP()
                self:InitHitMaterials()
                self:InitHitTypes()
            end,
        },
        {
            ------------------------------
            ---        GetKills
            ------------------------------
            Name = "GetKills",
            Value = function(self, hPlayerId)
                return (g_pGame:GetSynchedEntityValue(hPlayerId, self.SCORE_KILLS_KEY) or 1)
            end,
        },
        {
            ------------------------------
            ---        GetDeaths
            ------------------------------
            Name = "GetDeaths",
            Value = function(self, hPlayerId)
                return (g_pGame:GetSynchedEntityValue(hPlayerId, self.SCORE_DEATHS_KEY) or 1)
            end,
        },
        {
            ------------------------------
            ---        SetDeaths
            ------------------------------
            Name = "SetDeaths",
            Value = function(self, hPlayerId, iDeaths)
                return (g_pGame:SetSynchedEntityValue(hPlayerId, self.SCORE_DEATHS_KEY, iDeaths))
            end,
        },
        {
            ------------------------------
            ---        SetKills
            ------------------------------
            Name = "SetKills",
            Value = function(self, hPlayerId, iKills)
                return (g_pGame:SetSynchedEntityValue(hPlayerId, self.SCORE_KILLS_KEY, iKills))
            end,
        },
        {
            ------------------------------
            ---        SetKills
            ------------------------------
            Name = "GetPlayerRank",
            Value = function(self, hPlayerId)
                if (self.IS_IA) then
                    return 1
                end
                return (g_pGame:GetSynchedEntityValue(hPlayerId, self.RANK_KEY) or 1)
            end,
        },
        {
            ------------------------------
            ---    SetPlayerRank
            ------------------------------
            Name = "SetPlayerRank",
            Value = function(self, hPlayerId, iRank)
                if (self.IS_IA) then
                    return
                end
                return (g_pGame:SetSynchedEntityValue(hPlayerId, self.RANK_KEY, iRank))
            end,
        },
        {
            ------------------------------
            ---    GetPlayerPrestige
            ------------------------------
            Name = "GetPlayerPrestige",
            Value = function(self, hPlayerId)
                if (self.IS_IA) then
                    return 0
                end
                return (g_pGame:GetSynchedEntityValue(hPlayerId, self.PP_AMOUNT_KEY) or 1)
            end,
        },
        {
            ------------------------------
            ---    SetPlayerPrestige
            ------------------------------
            Name = "SetPlayerPrestige",
            Value = function(self, hPlayerId, iPP)
                if (self.IS_IA) then
                    return 0
                end
                return (g_pGame:SetSynchedEntityValue(hPlayerId, self.PP_AMOUNT_KEY, iPP))
            end,
        },
        {
            ------------------------------
            ---  OnPlayerKilled_CryMP
            ------------------------------
            Name = "OnPlayerKilled_CryMP",
            Value = function(self, aHitInfo)

                local hWeapon    = aHitInfo.weapon
                local hTarget    = aHitInfo.target
                local hShooter   = aHitInfo.shooter

                local iKillType = KillType_Unknown
                local bHeadshot = false

                local bSuicide    = (not hShooter or hShooter == hTarget)
                local aKillConfig = self.KillConfig

                local iSuicideKills   = aKillConfig.SuicideKills
                local iSuicideDeaths  = aKillConfig.SuicideDeaths
                local iTeamKillReward = aKillConfig.TeamKill
                local bRemoveBotScore = aKillConfig.BotScore

                if (hTarget.IsPlayer) then
                    if (bSuicide) then
                        iKillType = KillType_Suicide
                        hTarget:SetKills(hTarget:GetKills() + (iSuicideKills + 1))
                        hTarget:SetDeaths(hTarget:GetDeaths() + (iSuicideDeaths))

                    elseif (hShooter.IsPlayer) then
                        if (not self.IS_IA and self.game:GetTeam(hShooter.id) == self.game:GetTeam(hTarget.id)) then
                            iKillType = KillType_Team
                            hShooter:SetKills(hShooter:GetKills() - (1 - iTeamKillReward))
                        else
                            iKillType = KillType_Enemy
                            if (aHitInfo.material_type and string.find(aHitInfo.material_type, "head", nil, true)) then
                                bHeadshot = true
                            end
                        end
                    else
                        iKillType = KillType_Bot
                    end

                elseif (hShooter) then
                    if (hShooter.IsPlayer) then

                        -- target is not player -> remove points
                        iKillType = KillType_Bot

                        if (bRemoveBotScore) then

                            hShooter:SetKills(hShooter:GetKills() - 1)
                            self:AwardPPCount(aHitInfo.shooterId, -self.ppList.KILL)
                            self:AwardCPCount(aHitInfo.shooterId, -self.cpList.KILL)
                        end
                    else
                        iKillType = KillType_Bot
                    end
                else
                    iKillType = KillType_BotDeath
                end

                local bExcludeShooter
                if (hShooter and hShooter.IsPlayer and (iKillType ~= KillType_Suicide) and not aHitInfo.explosion) then

                    local iAccuracy = hShooter:GetHitAccuracy()
                    local aMessageList = {
                        [ 0] = "@hit_accuracy_0",
                        [ 5] = "@hit_accuracy_5",
                        [10] = "@hit_accuracy_10",
                        [20] = "@hit_accuracy_20",
                        [30] = "@hit_accuracy_30",
                        [40] = "@hit_accuracy_40",
                        [50] = "@hit_accuracy_50",
                        [60] = "@hit_accuracy_60",
                        [70] = "@hit_accuracy_70",
                        [80] = "@hit_accuracy_80",
                        [90] = "@hit_accuracy_90",
                        [99] = "@hit_accuracy_99",
                    }
                    local sAccuracy = table.it(aMessageList, function(x, i, v) if (iAccuracy >= i and (x == nil or x[1] < i)) then return { i, v } end return x end)[2]
                    Server.Chat:BattleLog(BattleLog_Information, hShooter , ("@hitaccuracy %s"):format(sAccuracy), { {}, { Percent = ("%0.2f"):format(iAccuracy) } })
                    --Server.Chat:ChatMessage(Server:GetEntity(), hShooter, ("@hitaccuracy %s"):format(sAccuracy), { {}, { Percent = ("%0.2f"):format(iAccuracy) } })
                    hShooter:RefreshHitAccuracy()
                    bExcludeShooter = true
                end

                aHitInfo.kill_type = iKillType

                if (iKillType == KillType_Enemy) then-- or (hShooter.IsPlayer and hShooter:IsTesting())) then
                    local aFPConfig = self.FirstBlood
                    local iTeam = self.game:GetTeam(hShooter.id)
                    if (aFPConfig.Shooters[iTeam] == nil and aFPConfig.Enabled) then
                        aFPConfig.Shooters[iTeam] = timernew()

                        local iRewardPP = aFPConfig.Reward
                        local iRewardCP = aFPConfig.RewardCP or 10
                        Server.Chat:ChatMessage(Server:GetEntity(), ALL_PLAYERS, ("@first_blood_" .. self.class), { Shooter = hShooter:GetName(), Team = Server.Utils:GetTeam_String(iTeam), PP = iRewardPP, CP = iRewardCP })
                        if (self.IS_PS) then
                            hShooter:AwardPrestige(iRewardPP)
                            if (iRewardCP > 0) then
                                self:AwardCPCount(hShooter.id, iRewardCP)
                            end
                        end
                    end
                end

                if (aKillConfig.NewMessages) then
                    self:SendKillMessage_CryMP(aHitInfo, bExcludeShooter)
                end

                -- TODO CONFIG
                --if (self.KillStreaks.Enabled) then
                if (self:SendKillStreakMessage_CryMP(hTarget, hShooter, aKillInfo)) then
                    --    return
                end
                --end

            end,
        },
        {
            ------------------------------
            ---  SendKillStreakMessage_CryMP
            ------------------------------
            Name = "SendKillStreakMessage_CryMP",
            Value = function(self, hTarget, hShooter, aKillInfo)

                local bMsg = false
                local aDeathMessages = self.StreakMessages.Deaths
                local aKillMessages  = self.StreakMessages.Kills
                local aRSMessages    = self.StreakMessages.Repeats

                local iKills = (hShooter and self:GetKills(hShooter.id) or 0)
                local aFormat = {
                    TargetName  = hTarget:GetName(),
                    ShooterName = hShooter:GetName(),
                    Kills = iKills
                }

                local function Message(sMessage)
                    DebugLog(sMessage)
                    Server.Chat:TextMessage(ChatType_Info, ALL_PLAYERS, sMessage)
                end

                if (hTarget and hTarget.IsPlayer) then

                    local iDeathStreak  = hTarget.Streaks:AddDeath()
                    local sDeathMessage = aDeathMessages[iDeathStreak]

                    if (sDeathMessage) then
                        aFormat["Kills"] = iDeathStreak
                        Message(Server.Logger:FormatTags(sDeathMessage, aFormat))
                        bMsg = true
                    end

                    hTarget.Streaks:SetKills(0)
                    hTarget.Streaks:ResetRS()
                end


                if (hShooter and hShooter.IsPlayer and hTarget ~= hShooter) then
                    hShooter.Streaks:SetDeaths(0)

                    local iKillStreak  = hShooter.Streaks:AddKill()
                    local sKillMessage = aKillMessages[iKillStreak]
                    local iRSStreak    = hShooter.Streaks:AddRS(hTarget.id)
                    local sRSMessage   = aRSMessages[iRSStreak]

                    if (sRSMessage) then
                        aFormat["Kills"] = iRSStreak
                        Message(Server.Logger:FormatTags(sRSMessage, aFormat))
                        bMsg = true

                    elseif (sKillMessage) then
                        aFormat["Kills"] = iKillStreak
                        Message(Server.Logger:FormatTags(sKillMessage, aFormat))
                        bMsg = true
                    end
                end

                return bMsg -- no message was sent
            end,
        },
        {
            ------------------------------
            ---  SendKillMessage_CryMP
            ------------------------------
            Name = "SendKillMessage_CryMP",
            Value = function(self, aKillInfo, bExcludeShooter)

                local hTarget  = aKillInfo.target
                local hShooter = aKillInfo.shooter
                local hWeapon  = aKillInfo.weapon
                local sWeapon  = (hWeapon or { class = "" }).class
                local sType    = (aKillInfo.type or "")
                local iType    = (aKillInfo.kill_type or -1)
                local iDamage  = aKillInfo.damage


                if (hTarget and hShooter) then
                    if (hShooter.IsPlayer) then

                        if (hShooter.KillMessageTimer.expired_refresh()) then
                            hShooter.KillMessageCount = 0
                        end

                        hShooter.KillMessageCount = (hShooter.KillMessageCount + 1)
                        if (hShooter.KillMessageCount > 10) then
                            return
                        end
                    end

                    local bFists 	    = (sWeapon == "Fists")
                    local bFrag 	    = (sType == "frag")
                    local bSuicide 		= (iType == KillType_Suicide)
                    local bFell 	    = (hTarget == hShooter and iDamage <= 1000 and hShooter.IsPlayer and not aKillInfo.material_type and not hWeapon and sType == "")
                    local bExploded     = (aKillInfo.explosion == true)
                    local bC4           = (bExploded and sWeapon == "c4explosive")
                    local bClaymore     = (bExploded and sWeapon == "claymoreexplosive")
                    local bPistol 		= (sWeapon == "SOCOM")
                    local bSniped 		= (sWeapon == "DSG1")
                    local bGauss 		= (sWeapon == "GaussRifle")
                    local bHurricane 	= (sWeapon == "Hurricane")
                    local bShotgunned   = (sWeapon == "Shotgun")
                    local bDrivenOver   = (hWeapon and (hWeapon.VehicleCMParent or hWeapon.vehicle))
                    local bKilledSelf   = (bSuicide and iDamage == 8190)
                    local bSpawnKill    = (not bSuicide and hTarget.IsPlayer and not hTarget.Timers.Spawn.expired(10))

                    local aMessages = { "%s Killed %s", }
                    if (bFell) then
                        aMessages = { "%s Thought they can Fly", "%s Believed they had wings", "%s Fell to Death", "%s Slipped Off a Cliff", "%s Took the Jump" }

                    elseif (bKilledSelf) then
                        aMessages = { "%s Took the Easy way Out" }

                    elseif (bSuicide) then
                        if (bExploded) then
                            aMessages = { "%s Blew Themselves Up", "%s Took the Bomb", "%s Ate a Frag" }

                        elseif (bDrivenOver) then
                            aMessages = { "%s Drove Over Themselves", "%s rammed themself" }

                        else
                            aMessages = { "%s Commited Suicide" }
                        end

                    elseif (bDrivenOver) then
                        aMessages = { "%s Drove Over %s", "%s Flattened %s", "%s Ran Over %s", "%s Ran %s Down" }

                    elseif (bFists) then
                        aMessages = { "%s Fisted %s", "%s knocked %s Out", "%s Knocked %s tf out", "%s Slapped %s" }

                    elseif (bSpawnKill) then
                        aMessages = {
                            "{TargetName} was born and immediately regretted it",
                            "{TargetName} barely had time to breathe",
                            "{ShooterName} made sure {TargetName}'s return was short lived"
                        }

                    elseif (bPistol) then
                        aMessages = { "%s Pistoled %s" }

                    elseif (bSniped) then
                        aMessages = { "%s Sniped %s", "%s Picked Off %s", "%s Scoped %s" }

                    elseif (bGauss) then
                        aMessages = { "%s GAUSSED %s", "%s NOOB GUNNED %s", "%s Killed %s WITH A GAUSS" }

                    elseif (bFrag) then
                        aMessages = { "%s Fragged %s", "%s Fed %s the Frag", "%s Gave %s the Frag" }

                    elseif (bC4) then
                        aMessages = { "%s Fed %s Chocolate", "%s Handed %s An Explosive Cake", "%s Got Fed C4" }

                    elseif (bClaymore) then
                        aMessages = { "{TargetName} Didnt watch their Step", "{TargetName} found a surprise underfoot", "{TargetName} Squashed a Claymore" }

                    elseif (bExploded) then
                        aMessages = { "%s Blew Up %s", "%s Bombed %s", "%s Detonated %s", "%s Erased %s", "%s Destroyed %s", "%s Obliterated %s", "%s Nuked %s" }

                    elseif (bHurricane) then
                        aMessages = { "%s Ripped %s Apart", "%s Torn %s Apart", "%s Wiped %s Out" }

                    elseif (bShotgunned) then
                        aMessages = { "%s Pulverised %s", "%s Shotgunned %s" }

                    else
                        aMessages = { "%s Eliminated %s" }
                    end

                    local sMessage = Server.Logger:FormatTags(table.Random(aMessages):format(hShooter:GetName(), hTarget:GetName()), {
                        TargetName  = hTarget:GetName(),
                        ShooterName = hShooter:GetName(),
                    })

                    local aRecipients = ALL_PLAYERS
                    if (bExcludeShooter) then
                        aRecipients = Server.Utils:GetPlayers({ NotById = hShooter.id })
                    end
                    Server.Chat:BattleLog(BattleLog_Information, aRecipients , sMessage)
                end
            end,
        },
        {
            ------------------------------
            ---      OnPlayerKilled
            ------------------------------
            Name = "Server.OnPlayerKilled",
            Value = function(self, tKillHit)

                local hTarget = tKillHit.target
                hTarget.death_time = _time
                hTarget.death_pos = hTarget:GetWorldPos(hTarget.death_pos)

                self.game:KillPlayer(tKillHit.targetId, true, true, tKillHit.shooterId, tKillHit.weaponId, tKillHit.damage, tKillHit.materialId, tKillHit.typeId, tKillHit.dir)
                self:ProcessScores(tKillHit)

                -- PowerStruggle Specific
                if (self.IS_PS) then
                    if (tKillHit.target and tKillHit.target.actor) then
                        self:VehicleOwnerDeath(tKillHit.target)
                    end
                end

                self:OnPlayerKilled_CryMP(tKillHit)
            end,
        },
        {
            ------------------------------
            ---   ProcessActorDamage_CryMP
            ------------------------------
            Name = "ProcessActorDamage_CryMP",
            Value = function(self, tHitInfo)

                local hTarget = tHitInfo.target
                local hShooter = tHitInfo.shooter

                if (hShooter and hShooter.IsPlayer) then
                    if (not hShooter:HitAccuracyExpired()) then
                        hShooter:UpdateHitAccuracy("Hit")
                        DebugLog("f")
                    end
                end
            end,
        },
        {
            ------------------------------
            ---   ProcessActorDamage
            ------------------------------
            Name = "ProcessActorDamage",
            Value = function(self, tHitInfo)

                local target = tHitInfo.target
                local iHealth = target.actor:GetHealth()

                self:ProcessActorDamage_CryMP(tHitInfo)

                iHealth = math.floor(iHealth - tHitInfo.damage * (1 - self:GetDamageAbsorption(target, tHitInfo)))
                target.actor:SetHealth(iHealth)

                return (iHealth <= 0)
            end,
        },
        {
            ------------------------------
            ---     EquipPlayer
            ------------------------------
            Name = "EquipPlayer",
            Value = function(self, hPlayer, aAdditionalEquip, aForcedEquip)

                hPlayer.inventory:Destroy()
                Script.SetTimer(1, function()
                    hPlayer:GiveItem("AlienCloak")
                    hPlayer:GiveItem("OffHand")
                    hPlayer:GiveItem("Fists")

                    local bEquipped = Server.PlayerEquipment:EquipPlayer(hPlayer, aForcedEquip, true)
                    if (not bEquipped) then
                        if (aAdditionalEquip and aAdditionalEquip ~= "") then
                            hPlayer:GiveItemPack(aAdditionalEquip)
                        end
                        hPlayer:GiveItem("SOCOM")
                    end
                end)
            end

        },
        {
            ------------------------------
            ---     RevivePlayer
            ------------------------------
            Name = "RevivePlayer",
            Value = function(self, iChannel, hPlayer, bKeepEquip, bForce, aEquip)

                if (self.IS_PS) then
                    if (hPlayer.actor:GetSpectatorMode() ~= 0) then
                        self.game:ChangeSpectatorMode(hPlayer.id, 0, NULL_ENTITY)
                    end
                    self:ResetUnclaimedVehicle(hPlayer.id, false)
                    hPlayer.lastVehicleId = nil
                end

                if (hPlayer.IsPlayer) then
                    hPlayer.Timers.Spawn.refresh()
                end

                if (bForce) then
                    if (hPlayer:IsSpectating()) then
                        hPlayer.actor:SetSpectatorMode(0, NULL_ENTITY)
                    end
                    self.game:RevivePlayer(hPlayer.id, (hPlayer.RevivePosition or hPlayer:GetPos()), (hPlayer.ReviveAngles or hPlayer:GetAngles()), hPlayer:GetTeam(), not bKeepEquip)
                    if (not bKeepEquip or (hPlayer:IsInventoryEmpty())) then
                        self:EquipPlayer(hPlayer, nil, aEquip)
                    end

                    if (self.IS_PS) then
                        self:ResetRevive(hPlayer.id, true)
                    end
                    return true
                end


                local bResult  = false
                local iGroupId = hPlayer.spawnGroupId
                local iTeamId  = self.game:GetTeam(hPlayer.id)

                if (hPlayer:IsDead()) then
                    bKeepEquip = false
                end

                if (self.USE_SPAWN_GROUPS and iGroupId and iGroupId~=NULL_ENTITY) then
                    local spawnGroup = System.GetEntity(iGroupId)
                    if (spawnGroup and spawnGroup.vehicle) then -- spawn group is a vehicle, and the vehicle has some free seats then
                        bResult = false
                        for i,seat in pairs(spawnGroup.Seats) do
                            if ((not seat.seat:IsDriver()) and (not seat.seat:IsGunner()) and (not seat.seat:IsLocked()) and (seat.seat:IsFree()))  then
                                self.game:RevivePlayerInVehicle(hPlayer.id, spawnGroup.id, i, iTeamId, not bKeepEquip)
                                bResult = true
                                break
                            end
                        end

                        -- if we didn't find a valid seat, rather than failing pass an invalid seat id. RevivePlayerInVehicle will try and
                        --	find a respawn point at one of the seat exits etc.
                        if(not bResult) then
                            self.game:RevivePlayerInVehicle(hPlayer.id, spawnGroup.id, -1, iTeamId, not bKeepEquip)
                            bResult=true
                        end
                    end
                elseif (self.USE_SPAWN_GROUPS) then
                    Log("Failed to spawn %s! iTeamId: %d  iGroupId: %s  groupiTeamId: %d", hPlayer:GetName(), self.game:GetTeam(hPlayer.id), tostring(iGroupId), self.game:GetTeam(iGroupId or NULL_ENTITY))

                    return false
                end

                if (not bResult) then
                    local ignoreTeam=(iGroupId~=nil) or (not self.TEAM_SPAWN_LOCATIONS)

                    local includeNeutral=true
                    if (self.TEAM_SPAWN_LOCATIONS) then
                        includeNeutral=self.NEUTRAL_SPAWN_LOCATIONS or false
                    end

                    local spawnId,zoffset
                    if (self.USE_SPAWN_GROUPS or (not hPlayer.death_time) or (not hPlayer.death_pos)) then
                        spawnId,zoffset = self.game:GetSpawnLocation(hPlayer.id, ignoreTeam, includeNeutral, iGroupId or NULL_ENTITY)
                    else
                        spawnId,zoffset = self.game:GetSpawnLocation(hPlayer.id, ignoreTeam, includeNeutral, iGroupId or NULL_ENTITY, 50, hPlayer.death_pos)
                    end

                    local pos,angles

                    if (spawnId) then
                        local spawn=System.GetEntity(spawnId)
                        if (spawn) then
                            spawn:Spawned(hPlayer)
                            pos=spawn:GetWorldPos(g_Vectors.temp_v1)
                            angles=spawn:GetWorldAngles(g_Vectors.temp_v2)
                            pos.z=pos.z+zoffset

                            if (zoffset>0) then
                                Log("Spawning player '%s' with ZOffset: %g!", hPlayer:GetName(), zoffset)
                            end

                            self.game:RevivePlayer(hPlayer.id, pos, angles, iTeamId, not bKeepEquip)

                            bResult=true
                        end
                    end
                end

                -- make the game realise the areas we're in right now...
                -- otherwise we'd have to wait for an entity system update, next frame
                hPlayer:UpdateAreas()

                if (bResult) then
                    if(hPlayer.actor:GetSpectatorMode() ~= 0) then
                        hPlayer.actor:SetSpectatorMode(0, NULL_ENTITY)
                    end

                    if (not bKeepEquip) then
                        local additionalEquip
                        if (iGroupId) then
                            local group=System.GetEntity(iGroupId)
                            if (group and group.GetAdditionalEquipmentPack) then
                                additionalEquip=group:GetAdditionalEquipmentPack()
                            end
                        end
                        self:EquipPlayer(hPlayer, additionalEquip)
                    end
                    hPlayer.death_time=nil
                    hPlayer.frostShooterId=nil

                    if (self.INVULNERABILITY_TIME and self.INVULNERABILITY_TIME>0) then
                        self.game:SetInvulnerability(hPlayer.id, true, self.INVULNERABILITY_TIME)
                    end
                end

                if (not bResult) then
                    Log("Failed to spawn %s! iTeamId: %d  iGroupId: %s  group team: %d", hPlayer:GetName(), self.game:GetTeam(hPlayer.id), tostring(iGroupId), self.game:GetTeam(iGroupId or NULL_ENTITY))
                end

                return bResult
            end,
        },
    }
})