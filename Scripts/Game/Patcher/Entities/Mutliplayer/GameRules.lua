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
                Server:CreateComponentFunctions(self, self.LogClass, self.LogClass)
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

                self.TaggedExplosives = {}

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
                    Repeats = Server.Config:Get("GameConfig.KillConfig.KillStreaks.RepeatMessages", {}, ConfigType_Array),
                    Enabled = Server.Config:Get("GameConfig.KillConfig.KillStreaks.Enabled", true, ConfigType_Boolean),
                }

                self.FirstBlood = {
                    RewardTeam  = Server.Config:Get("GameConfig.KillConfig.FirstBlood.Reward.RewardTeam", true, ConfigType_Boolean),
                    RewardPP    = Server.Config:Get("GameConfig.KillConfig.FirstBlood.Reward.PP", 100, ConfigType_Number),
                    RewardCP    = Server.Config:Get("GameConfig.KillConfig.FirstBlood.Reward.CP", 25, ConfigType_Number),
                    Enabled     = Server.Config:Get("GameConfig.KillConfig.FirstBlood.Enabled", true, ConfigType_Boolean),
                    RewardAmplification  = Server.Config:Get("GameConfig.KillConfig.FirstBlood.Reward.Amplifications", {}, ConfigType_Array),
                    Shooters = {} -- internal data
                }

                self.AutoSpectateTimer = Server.Config:Get("GameConfig.AutoSpectateTimer", 30, ConfigType_Number)
                self.PremiumSpawnPrestigeMultiplier = Server.Config:Get("GameConfig.Prestige.PremiumSpawnPrestigeMultiplier", 1.25, eConfigGet_Number)

                self.PremiumKillRewardScale = Server.Config:Get("GameConfig.KillConfig.PremiumRewardsScale", 1.25, ConfigType_Number)

                self.TurretConfig = {
                    RPGTurretDamageScale = Server.Config:Get("GameConfig.TurretConfig.RPGDamageScale", 1, ConfigType_Number),
                    TargetPlayersOnAttack = Server.Config:Get("GameConfig.TurretConfig.TargetPlayersOnAttack", true, ConfigType_Boolean),
                    RepairReward = Server.Config:Get("GameConfig.TurretConfig.RepairReward", 125, ConfigType_Number),
                }

                self.PrestigeConfig = {
                    AwardDisarmPrestigeAlways = Server.Config:Get("GameConfig.Prestige.AwardDisarmPrestigeAlways", true, ConfigType_Boolean),
                    VehicleTheftReward = Server.Config:Get("GameConfig.Prestige.VehicleTheftReward", 50, ConfigType_Number),

                }

                self.BuyingConfig = {
                    KitLimit = Server.Config:Get("GameConfig.Buying.KitLimit", 1, ConfigType_Number),
                    ItemSellPriceScale = Server.Config:Get("GameConfig.Buying.SellItemPriceScale", 75, ConfigType_Number),
                    AwardInvestItemPrestige = Server.Config:Get("GameConfig.Buying.AwardItemInvestPrestige", 0.25, ConfigType_Number),
                    AwardInvestVehiclePrestige = Server.Config:Get("GameConfig.Buying.AwardVehicleInvestPrestige", 0.15, ConfigType_Number),
                }

                Server.Utils:SetCVar("mp_killMessages", (self.KillConfig.NewMessages and "0" or "1"))
                ServerDLL.GameRulesInitScriptTables()
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
            ---       AwardPPCount
            ------------------------------
            Name = "AwardPPCount",
            Value = function(self, hPlayerId, iCount, sWhy, bQuiet)


                local hPlayer = System.GetEntity(hPlayerId)
                if (not hPlayer) then
                    return
                end

                if (iCount > 0) then
                    local iIncomeScale = System.GetCVar("g_pp_scale_income")
                    if (iIncomeScale) then
                        iCount = math.floor(iCount * math.max(0, iIncomeScale))
                    end
                end

                local iTotal = (self:GetPlayerPP(hPlayerId) + iCount)
                self:SetPlayerPP(hPlayerId, math.max(0, iTotal))

                if (not bQuiet) then
                    self.onClient:ClPP(hPlayer.actor:GetChannel(), iCount)
                end

                CryAction.SendGameplayEvent(hPlayerId, eGE_Currency, nil, iTotal)
                CryAction.SendGameplayEvent(hPlayerId, eGE_Currency, sWhy, iCount)
            end
        },
        {
            ------------------------------
            ---     PrestigeEvent
            ------------------------------
            Name = "PrestigeEvent",
            Value = function(self, hPlayer, iPPCount, sMessage, tFormat, tCryFormat)

                hPlayer = Server.Utils:GetEntity(hPlayer)
                if (not hPlayer) then
                    error("no player")
                end

                local bSilent = false
                if (sMessage) then
                    bSilent = false
                    if (type(iPPCount) == "table") then
                        sMessage = hPlayer:LocalizeText(("%s ( %s%d PP, %s%d CP )"):format(sMessage, (iPPCount[1] >= 0 and "+" or ""), iPPCount[1], (iPPCount[2] >= 0 and "+" or "-"), iPPCount[2]), { tFormat })
                    else
                        sMessage = hPlayer:LocalizeText(("%s ( %s%d PP )"):format(sMessage, (iPPCount >= 0 and "+" or ""), iPPCount), { tFormat })
                    end
                    DebugLog("msg=",sMessage)
                end

                if (type(iPPCount) == "table") then
                    self:AwardPPCount(hPlayer.id, iPPCount[1], nil)
                    self:AwardCPCount(hPlayer.id, iPPCount[2], nil)
                else
                    self:AwardPPCount(hPlayer.id, iPPCount, nil)
                end
            end
        },
        {
            ------------------------------
            ---     CheckDefenseKill
            ------------------------------
            Name = "CheckDefenseKill",
            Value = function(self, aHitInfo)

                -- check if inside a factory
                local hTarget   = aHitInfo.target
                local hShooter  = aHitInfo.shooter

                local bDefense = false
                local sType    = nil

                if (hTarget ~= hShooter) then
                    local iTeam1 = self.game:GetTeam(hShooter.id)
                    local iTeam2 = self.game:GetTeam(hTarget.id)
                    for _, hFactory in pairs(self.factories) do
                        local iFactoryTeam = self.game:GetTeam(hFactory.id)
                        if (hFactory:IsPlayerInside(aHitInfo.targetId) and (iFactoryTeam ~= iTeam2) and (iFactoryTeam == iTeam1)) then
                            bDefense = true
                            sType    = hFactory.LocaleType
                        end
                    end
                end

                return bDefense, sType
            end
        },
        {
            ------------------------------
            ---     CalcKillPP
            ------------------------------
            Name = "CalcKillPP",
            Value = function(self, aHitInfo)

                local weapon = aHitInfo.weapon
                local target = aHitInfo.target
                local shooter = aHitInfo.shooter
                local headshot = self:IsHeadShot(aHitInfo)
                local melee = aHitInfo.type=="melee"
                local iPremiumBonus = self.PremiumKillRewardScale

                if (target ~= shooter) then
                    local team1 = self.game:GetTeam(shooter.id)
                    local team2 = self.game:GetTeam(target.id)
                    if (team1 == 0 or team1 ~= team2) then
                        local ownRank = self:GetPlayerRank(shooter.id)
                        local enemyRank = self:GetPlayerRank(target.id)
                        local bonus = 0

                        if (headshot) then
                            bonus = bonus + self.ppList.HEADSHOT
                        end

                        if (melee) then
                            bonus = bonus + self.ppList.MELEE
                        end

                        local rankDiff = enemyRank-ownRank
                        if (rankDiff ~= 0) then
                            bonus = bonus + rankDiff * self.ppList.KILL_RANKDIFF_MULT
                        end

                        -- check if inside a factory
                        local bFactoryDefended = false
                        for _, hFactory in pairs(self.factories) do
                            local factoryTeamId = self.game:GetTeam(hFactory.id);
                            if (hFactory:IsPlayerInside(aHitInfo.targetId) and (factoryTeamId ~= team2) and (factoryTeamId == team1)) then
                                bonus = (bonus + self.defenseValue[hFactory:GetCaptureIndex() or 0] or 0)
                                bFactoryDefended = true
                            end
                        end

                        self.SnipingRewards = {
                            Enabled = Server.Config:Get("GameConfig.KillConfig.SnipingRewards.Enabled", true, ConfigType_Boolean),
                            MinimumDistance = Server.Config:Get("GameConfig.KillConfig.SnipingRewards.MinimumDistance", 100, ConfigType_Number),
                            RewardPP = Server.Config:Get("GameConfig.KillConfig.SnipingRewards.RewardPP", 500, ConfigType_Number),
                            RewardCP = Server.Config:Get("GameConfig.KillConfig.SnipingRewards.RewardCP", 35, ConfigType_Number),
                            HeadshotAmplification = Server.Config:Get("GameConfig.KillConfig.SnipingRewards.HeadshotAmplification", 1.25, ConfigType_Number),

                        }

                        -- check sniper kill
                        local aSniperRewards = self.SnipingRewards
                        if (aSniperRewards.Enabled and (weapon or {}).class == "DSG1") then
                            local iDistance = Server.Utils:GetDistance(shooter, target)
                            if (iDistance > aSniperRewards.MinimumDistance) then
                                local iRewardScale = math.floor((iDistance / 100) + 0.5) * 1 * (headshot and aSniperRewards.HeadshotAmplification or 1)
                                local iRewardPP = (aSniperRewards.RewardPP * iRewardScale)
                                return iRewardPP, "@special_sniper_kill", { Distance = iDistance }
                            end

                        end

                        return math.max(0, (self.ppList.KILL + bonus) * iPremiumBonus), (bFactoryDefended and "@factory_defended")
                    else
                        return self.ppList.TEAMKILL, "@team_kill"
                    end
                else
                    return self.ppList.SUICIDE, "@suicide"
                end
            end
        },
        {
            ------------------------------
            ---       AwardKillPP
            ------------------------------
            Name = "AwardKillPP",
            Value = function(self, aHitInfo)

                local hPlayer = aHitInfo.shooter
                if (not hPlayer or not hPlayer.IsPlayer) then
                    return
                end

                local iPP, sType, tFormat = self:CalcKillPP(aHitInfo)
                local hPlayerID = hPlayer.id

                sType = sType or "@enemy @eliminated"

                if (iPP ~= 0) then
                    self:PrestigeEvent(hPlayer, iPP, sType, tFormat)
                end

                if (self.IS_PS) then
                    if (iPP < 0) then -- negative points are assumed to be a teamkill here
                        local revive = self.reviveQueue[hPlayer.id]
                        revive.tk = true
                    end
                end
            end
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

                local sWeaponClass = (hWeapon and hWeapon.class or "")

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
                        if (not self.IS_IA and self.game:GetTeam(hShooter.id) == self.game:GetTeam(hTarget.id) and self.game:GetTeam(hShooter.id) ~= GameTeam_Neutral) then
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
                    local aFirstBlood = self.FirstBlood
                    local iTeam = self.game:GetTeam(hShooter.id)
                    if ((aFirstBlood.Shooters[iTeam] == nil and aFirstBlood.Enabled)) then
                        aFirstBlood.Shooters[iTeam] = TimerNew()

                        local iRewardPP = aFirstBlood.RewardPP or 100
                        local iRewardCP = aFirstBlood.RewardCP or 10
                        local iFirstBloodCount = hShooter.Data.FirstBloodScored + 1

                        if (self.IS_IA) then
                            Server.Chat:ChatMessage(ChatEntity_Server, ALL_PLAYERS, ("@first_blood_instantAction"), { Shooter = hShooter:GetName() })
                        else
                            local sTeamReward, sAmplified = "", ""
                            if (aFirstBlood.RewardTeam) then
                                sTeamReward = "@entire_team "
                                for _, hPlayer in pairs(Server.Utils:GetPlayers()) do
                                    hPlayer:AwardPrestige(iRewardPP)
                                    if (iRewardCP > 0) then
                                        self:AwardCPCount(hPlayer.id, iRewardCP)
                                    end
                                end
                            else
                                hShooter:AwardPrestige(iRewardPP)
                                if (iRewardCP > 0) then
                                    self:AwardCPCount(hShooter.id, iRewardCP)
                                end
                            end



                            local iAmplification = aFirstBlood.RewardAmplification[iFirstBloodCount]
                            if (iAmplification) then
                                sAmplified = ("#%d "):format(iFirstBloodCount)
                                iRewardCP = (iRewardCP or 0) * iAmplification
                                iRewardPP = (iRewardPP or 0) * iAmplification
                            end

                            local tFormat = { Amplified = sAmplified, Shooter = hShooter:GetName(), TeamReward = sTeamReward, Team = Server.Utils:GetTeam_String(iTeam), PP = iRewardPP, CP = iRewardCP }
                            Server.Chat:ChatMessage(ChatEntity_Server, ALL_PLAYERS, ("@first_blood_powerStruggle"), tFormat)
                            self:LogEvent({
                                Message = "@first_blood_powerStruggle",
                                MessageFormat = tFormat
                            })
                        end

                        hShooter.Data.FirstBloodScored = iFirstBloodCount
                    end



                end

                if (aKillConfig.NewMessages) then
                    self:SendKillMessage_CryMP(aHitInfo, bExcludeShooter)
                end

                if (self.StreakMessages.Enabled) then
                    self:SendKillStreakMessage_CryMP(hTarget, hShooter, aHitInfo)
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
                    TargetName  = hTarget and hTarget:GetName(),
                    ShooterName = hShooter and hShooter:GetName(),
                    Kills = iKills
                }

                local function Message(sMessage, tFormat)
                    Server.Chat:TextMessage(ChatType_Info, ALL_PLAYERS, sMessage, tFormat)
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
        {
            ------------------------------
            ---  UpdateUnclaimedVehicle
            ------------------------------
            Name = "UpdateUnclaimedVehicles",
            Value = function(self, iFrameTime)

                local sClass, hVehicle, hOwner
                for id, v in pairs(self.unclaimedVehicle) do
                    hOwner = Server.Utils:GetEntity(v.ownerId)
                    hVehicle = Server.Utils:GetEntity(id)
                    sClass = (hVehicle and hVehicle.class or "<Null>")

                    v.time = v.time - iFrameTime
                    if (v.time <= 0) then

                        -- inform the player
                        self.game:SendTextMessage(TextMessageInfo, "@mp_UnclaimedVehicle", TextMessageToClient, v.ownerId, g_gameRules:GetItemName(v.name))

                        -- refund
                        local price = self:GetPrice(v.name)
                        if (price and price > 0) then
                            self:PrestigeEvent(v.ownerId, math.floor(self.ppList.VEHICLE_REFUND_MULT * price + 0.5), "@vehicle @refund")
                        end

                        System.RemoveEntity(id)
                        self.unclaimedVehicle[id] = nil

                    elseif (self.IS_PS and v.time <= 15) then
                        if (hOwner and hOwner.Timers.UnclaimedVehicle:expired_refresh(1)) then
                            Server.Chat:TextMessage(ChatType_Center, hOwner, "@unclaimed_vehicle_countdown", { Time = math.floor(v.time) })
                        end
                    end
                end
            end,
        },
        {
            ------------------------------
            ---   OnPurchaseCancelled
            ------------------------------
            Name = "OnPurchaseCancelled",
            Value = function(self, hPlayerId, teamId, itemName)

                local price, energy = self:GetPrice(itemName)
                if (price > 0) then
                    self:PrestigeEvent(hPlayerId, price, "@vehicle @refund")
                end

                if (energy and energy > 0) then
                    self:SetTeamPower(teamId, self:GetTeamPower(teamId) + energy)
                end
            end,
        },
        {
            ------------------------------
            ---  CommitRevivePurchases
            ------------------------------
            Name = "CommitRevivePurchases",
            Value = function(self, playerId)

                local revive = self.reviveQueue[playerId]
                local player = System.GetEntity(playerId)

                for ammo,c in pairs(revive.ammo) do
                    player.actor:SetInventoryAmmo(ammo, c)
                end

                if (revive.ammo_price > 0) then
                    self:PrestigeEvent(playerId, -revive.ammo_price, "@ammo @bought")
                end

                local ok = false
                for i,itemName in ipairs(revive.items) do
                    ok = false
                    if (self:EnoughPP(playerId, itemName)) then
                        ok = self:BuyItem(playerId, itemName)
                    end

                    if (not ok) then
                        break
                    end
                end

                revive.ammo = {}
                revive.items = {}
                revive.items_price = 0
                revive.ammo_price = 0
            end,
        },
        {
            ------------------------------
            ---  UpdateReviveQueue
            ------------------------------
            Name = "UpdateReviveQueue",
            Value = function(self, iFrameTime)
                if (not self.IS_PS) then
                    return
                end

                local iAutoSpecTime   = self.AutoSpectateTimer --ConfigGet("General.GameRules.AutoSpectateTimer", 30, eConfigGet_Number)
                local iPremiumSpawnPP = self.PremiumSpawnPrestigeMultiplier --ConfigGet("General.GameRules.PremiumSpawnPP", 1.25, eConfigGet_Number)

                local reviveTimer = self.game:GetRemainingReviveCycleTime()
                if (reviveTimer>0) then
                    for playerId,revive in pairs(self.reviveQueue) do
                        if (revive.active) then
                            local player=System.GetEntity(playerId);
                            if (player and player.spawnGroupId and player.spawnGroupId~=NULL_ENTITY) then

                                if (not revive.announced) then
                                    self.onClient:ClReviveCycle(player.actor:GetChannel(), true);
                                    revive.announced=true;
                                    --Debug("show cycle!")
                                end
                            elseif (revive.announced) then -- spawngroup got invalidated while spawn cycle was up,
                                -- so need to make sure it gets sent again after the situation is cleared
                                revive.announced=nil;
                            end
                        end
                    end

                    -- if player has been dead more than 5s and isn't spectating, auto-switch to spectator mode 3
                    local players=self.game:GetPlayers();
                    if (players) then
                        for i,player in pairs(players) do
                            if(player and player:IsDead() and player.death_time and _time-player.death_time>iAutoSpecTime and player.actor:GetSpectatorMode() == 0) then
                                self.Server.RequestSpectatorTarget(self, player.id, 1);
                            end
                        end
                    end
                end

                if (reviveTimer<=0) then
                    self.game:ResetReviveCycleTime();

                    for i,teamId in ipairs(self.teamId) do
                        self:UpdateTeamRanks(teamId);
                    end

                    for playerId,revive in pairs(self.reviveQueue) do
                        if (revive.active and self:CanRevive(playerId)) then
                            revive.active=false;

                            local player=System.GetEntity(playerId);
                            if (player) then
                                self:RevivePlayer(player.actor:GetChannel(), player)

                                if (not revive.tk) then
                                    local rank=self.rankList[self:GetPlayerRank(player.id)]
                                    if (rank and rank.min_pp and rank.min_pp>0) then

                                        local currentpp = self:GetPlayerPP(player.id)
                                        local iMinPP = rank.min_pp * (player:IsPremium() and iPremiumSpawnPP or 1)
                                        if (currentpp < iMinPP) then
                                            local iAward = iMinPP - currentpp
                                            if (iAward > 0) then
                                                self:PrestigeEvent(player.id, iMinPP, "%1 @spawn_prestige", {}, {rank.name})
                                            end
                                        end
                                    end
                                end

                                self:CommitRevivePurchases(playerId)
                                revive.tk = nil
                                revive.announced = nil
                            end
                        end
                    end
                end
            end,
        },
        {
            ------------------------------
            ---  ProcessVehicleScores
            ------------------------------
            Name = "ProcessVehicleScores",
            Value = function(self, aHitInfo)

                local target=aHitInfo.target;
                local shooter=aHitInfo.shooter;

                if (shooter and shooter.actor) then
                    local vTeam=self.game:GetTeam(target.id);
                    local sTeam=self.game:GetTeam(aHitInfo.shooterId);

                    if (true or (vTeam~=0) and (vTeam~=sTeam)) then
                        local pp=self.ppList.VEHICLE_KILL_MIN;
                        local cp=self.cpList.VEHICLE_KILL_MIN;

                        local sName
                        if (target.builtas) then
                            local def=self:GetItemDef(target.builtas);
                            if (def) then
                                pp=math.max(pp, math.floor(def.price*self.ppList.VEHICLE_KILL_MULT))
                                cp=math.max(cp, math.floor(def.price*self.cpList.VEHICLE_KILL_MULT))
                                sName = def.name
                            end
                        end

                        --self:AwardPPCount(aHitInfo.shooterId, pp);
                        self:PrestigeEvent(aHitInfo.shooterId, pp, (sName and "%%1" or "@vehicle") .. " @destroyed", {}, {sName})
                        self:AwardCPCount(aHitInfo.shooterId, cp);
                    end
                end
            end,
        },
        {
            ------------------------------
            ---        OnExplosiveDisarmed
            ------------------------------
            Name = "OnExplosiveDisarmed",
            Value = function(self, hEntityID, hPlayerID)

                local hEntity = System.GetEntity(hEntityID)
                local hPlayer = System.GetEntity(hPlayerID)

                -- WHAT IS THIS OMG
                local sClass = hEntity and hEntity.class
                sClass = sClass == "claymoreexplosive" and "Claymore" or
                        sClass == "c4explosive" and "C4" or
                        sClass == "avexplosive" and "AVMine"

                if (hEntity and hPlayer and sClass) then
                    hPlayer:GiveItem(sClass)
                    hPlayer:SelectItem(sClass)
                end

                hEntity.DISARMED = true
                hEntity.WAS_DISARMED = true

                local iPP = 0
                if (self.IS_PS and (self.PrestigeConfig.AwardDisarmPrestigeAlways or self.game:GetTeam(hEntityID) ~= self.game:GetTeam(hPlayerID))) then

                    -- give the player some PP
                    iPP = self.ppList.DISARM
                    self:PrestigeEvent(hPlayerID, iPP, (sClass .. " @disarmed"))
                end

                Script.SetTimer(1, function()
                    System.RemoveEntity(hEntityID)
                end)
            end
        },
        {
            ------------------------------
            ---     AwardHQRepairPP
            ------------------------------
            Name = "AwardHQRepairPP",
            Value = function(self, hPlayer)
                local iReward = hPlayer.HQRepairAmount
                if (iReward > 0) then
                    self:PrestigeEvent(hPlayer, iReward, "@headquarters @repaired")
                end
            end
        },
        {
            ------------------------------
            ---   AwardVehicleRepairPP
            ------------------------------
            Name = "AwardVehicleRepairPP",
            Value = function(self, player)

                local iReward = self.PrestigeConfig.VehicleRepairAward
                if (iReward > 0) then
                    self:PrestigeEvent(player, iReward, "@vehicle @repaired")
                end
            end
        },
        {
            ------------------------------
            ---   AwardVehicleTheftPP
            ------------------------------
            Name = "AwardVehicleTheftPP",
            Value = function(self, player)

                local iReward = self.PrestigeConfig.VehicleTheftReward
                if (iReward > 0) then
                    self:PrestigeEvent(player, iReward, "@vehicle @stolen")
                end
            end
        },
        {
            ------------------------------
            ---   OnTurretRepaired
            ------------------------------
            Name = "OnTurretRepaired",
            Value = function(self, player, turret)
                local iReward = self.TurretConfig.RepairReward
                if (iReward > 0) then
                    self:PrestigeEvent(player.id, iReward, "@turret @repaired")
                end
            end
        },
        {
            ------------------------------
            ---   AwardCapturePP
            ------------------------------
            Name = "AwardCapturePP",
            Value = function(self, hBuilding, aPlayers, iValue, iTeamID)
                if (iValue > 0) then
                    for _, hPlayerID in ipairs(aPlayers) do
                        if (self.game:GetTeam(hPlayerID) == iTeamID) then
                            local hPlayer = System.GetEntity(hPlayerID)
                            if (hPlayer and hPlayer.actor and (not hPlayer:IsDead()) and (hPlayer.actor:GetSpectatorMode() == 0)) then
                                self:PrestigeEvent(hPlayer, { iValue, self.cpList.CAPTURE}, (hBuilding.LocaleType or "@unknown") .. " @captured")
                            end
                        end
                    end
                end
            end
        },
        {
            ------------------------------
            ---           Work
            ------------------------------
            Name = "StopWork",
            Value = function(self, playerId)

                local work = self.works[playerId]
                if (work and work.active) then
                    work.active = false

                    self.onClient:ClStopWorking(self.game:GetChannelId(playerId), work.entityId, work.complete or false)
                    local entity = System.GetEntity(work.entityId)
                    local player = System.GetEntity(playerId)


                    if (work.complete) then
                        self.allClients:ClWorkComplete(work.entityId, work.type)
                        if (entity and self:IsTurret(entity)) then
                            if (work.type == "repair") then
                                self:OnTurretRepaired(player, entity)
                            else
                            end
                        end

                        if (work.type == "lockpick") then
                            if (entity.vehicle) then
                                self:AwardVehicleTheftPP(player)
                            end
                        elseif (work.type == "repair") then
                            if (entity.vehicle) then
                                self:AwardVehicleRepairPP(player)
                            end

                            if (entity.class == "HQ") then
                                self:AwardHQRepairPP(player)
                            end
                        end
                    end


                    if (player) then
                        player.LastWorkCount = nil
                        if (player.LastWorkID and player.LastWorkID ~= work.entityId) then
                            player.HQRepairAmount = 0
                        end

                        player.LastWorkID = work.entityId
                    end
                end
            end
        },
        {
            ------------------------------
            ---           Work
            ------------------------------
            Name = "Work",
            Value = function(self, playerId, amount, frameTime)

                local work = self.works[playerId]
                if (work and work.active) then
                    --Log("%s doing '%s' work on %s for %.3fs...", EntityName(playerId), work.type, EntityName(work.entityId), frameTime);

                    local entity = System.GetEntity(work.entityId)
                    local player = System.GetEntity(playerId)
                    if (entity) then
                        local workamount = amount * frameTime

                        local iMult = entity.RepairSpeedMult
                        if (iMult) then
                            workamount = (workamount * iMult)
                        end

                        player.LastWorkCount = ((player.LastWorkCount or 0) + workamount)

                        if (work.type == "repair") then

                            if (not self.repairHit) then
                                self.repairHit = {
                                    typeId	    = self.game:GetHitTypeId("repair"),
                                    type		= "repair",
                                    material    = 0,
                                    materialId  = 0,
                                    dir			= g_Vectors.up,
                                    radius	    = 0,
                                    partId	    = -1,
                                }
                            end

                            local hit = self.repairHit
                            hit.shooter     = System.GetEntity(playerId)
                            hit.shooterId   = playerId
                            hit.target      = entity
                            hit.targetId    = work.entityId
                            hit.pos         = entity:GetWorldPos(hit.pos)
                            hit.damage      = workamount
                            work.amount     = work.amount+workamount

                            if (entity.vehicle) then
                                entity.Server.OnHit(entity, hit)
                                work.complete = entity.vehicle:GetRepairableDamage() <= 0 -- keep working?

                                local progress = math.floor(0.5+(1.0-entity.vehicle:GetRepairableDamage())*100)
                                self.onClient:ClStepWorking(self.game:GetChannelId(playerId), progress)
                                return (not work.complete)

                            elseif (entity.item and (entity.class == "AutoTurret" or entity.class == "AutoTurretAA") ) then
                                entity.Server.OnHit(entity, hit);
                                work.complete=entity.item:GetHealth()>=entity.item:GetMaxHealth();

                                local progress=math.floor(0.5+(100*entity.item:GetHealth()/entity.item:GetMaxHealth()));
                                self.onClient:ClStepWorking(self.game:GetChannelId(playerId), progress);
                                return (not work.complete)

                            elseif (entity.class == "HQ") then

                                workamount = 0.5
                                if (player and player.megaGod) then
                                    workamount = workamount * 100
                                end
                                hit.damage = workamount
                                work.amount = work.amount+workamount

                                player.HQRepairAmount = (player.HQRepairAmount or 0) + (hit.damage * 0.1)
                                entity:SetHealth(entity:GetHealth() + hit.damage)
                                work.complete = entity:GetHealth() >= entity.Properties.nHitPoints

                                local progress = math.floor(0.5+(100*entity:GetHealth()/entity.Properties.nHitPoints))
                                self.onClient:ClStepWorking(self.game:GetChannelId(playerId), progress)

                                return (not work.complete)
                            end
                        elseif (work.type=="lockpick") then


                            work.amount = work.amount + workamount
                            if (work.amount > 100) then
                                self.game:SetTeam(self.game:GetTeam(playerId), entity.id)
                                entity.vehicle:SetOwnerId(NULL_ENTITY)
                                work.complete = true
                            end
                            self.onClient:ClStepWorking(self.game:GetChannelId(playerId), math.floor(work.amount+0.5));
                            return (not work.complete)

                        elseif (work.type == "disarm") then
                            if ((entity.CanDisarm and entity:CanDisarm(playerId)) or (entity.class == "Claymore" or entity.class == "AVMine" or entity.class == "c4explosive")) then
                                work.amount = work.amount+(100/4)*frameTime

                                if (work.amount>100) then
                                    work.complete = true
                                    if (self.OnExplosiveDisarmed) then
                                        self:OnExplosiveDisarmed(work.entityId, playerId)
                                    end
                                end

                                self.onClient:ClStepWorking(self.game:GetChannelId(playerId), math.floor(work.amount+0.5));

                                return (not work.complete);
                            end
                        end
                    end
                end

                return false;
            end,
        },
        {
            ------------------------------
            --- Server.OnAddTaggedEntity
            ------------------------------
            Name = "Server.OnAddTaggedEntity",
            Value = function(self, hShooterID, hTargetID, sClass)

                local iTeam_S = self.game:GetTeam(hShooterID)
                local iTeam_T = self.game:GetTeam(hTargetID)
                local hTarget = System.GetEntity(hTargetID)
                local hShooter = System.GetEntity(hShooterID)

                local bTesting = false

                if ((iTeam_S ~= iTeam_T) or bTesting) then

                    hShooter.TagAward.Num = (hShooter.TagAward.Num) + 1
                    if (hTarget) then
                        if ((bTesting or not hTarget.last_scanned) or (_time - hTarget.last_scanned > 16)) then

                            if ((hTarget and hTarget.class == "Player") or bTesting) then
                                hShooter.TagAward.Hostiles = hShooter.TagAward.Hostiles + 1
                            end

                            hShooter.TagAward.PP  = (hShooter.TagAward.PP) + self.ppList.TAG_ENEMY
                            hShooter.TagAward.CP  = (hShooter.TagAward.CP) + self.cpList.TAG_ENEMY

                            hTarget.last_scanned = _time
                        end
                    end
                end
            end
        },
        {
            ------------------------------
            ---  OnRadarScanComplete
            ------------------------------
            Name = "OnRadarScanComplete",
            Value = function(self, hShooterID, hWeaponID, iScanDistance)

                local hShooter = System.GetEntity(hShooterID)
                local hWeapon = System.GetEntity(hWeaponID)

                local iTeam = hShooter:GetTeam()

                if (Server.Utils:GetCVar("server_allow_scan_explosives") > 0) then
                    local aNearby = System.GetEntitiesInSphere(hShooter:GetPos(), iScanDistance / 3)
                    for _, hNearby in pairs(aNearby) do
                        if (IsAny(hNearby.class, "claymoreexplosive", "avexplosive", "c4explosive"
                        )) then

                            self.TaggedExplosives[hNearby.id] = {
                                Timer       = TimerNew(),
                                EffectTimer = TimerNew(),
                                MsgTimer    = TimerNew(),
                                TeamID      = hShooter:GetTeam()
                            }
                            hShooter.TagAward.Num = hShooter.TagAward.Num + 1
                            hShooter.TagAward.PP  = hShooter.TagAward.PP + 5
                            hShooter.TagAward.CP  = hShooter.TagAward.CP + 1

                            local vPos = hNearby:GetPos()
                            if (iTeam ~= TEAM_NEUTRAL) then
                                -- TODO
                                DebugLog("Color the explosive..")
                            else
                                -- TODO
                                DebugLog("Color the explosive..")
                            end
                        end
                    end
                end

                if (self.IS_PS) then
                    local iScanned = hShooter.TagAward.Num
                    if (iScanned > 0) then
                        local iHostile = hShooter.TagAward.Hostiles
                        if (iHostile > 0) then
                            local aNearby = Server.Utils:GetPlayers({ NotById = hShooter.id, InRage = iScanDistance, FromPos = hShooter:GetPos(), ByTeam = hShooter:GetTeam() })
                            for _, hNearby in pairs(aNearby) do
                                -- TODO
                                -- sounds/interface:multiplayer_interface:mp_tac_alarm_suit
                                -- "@hostiles_on_radar", { Count = iHostile }
                                DebugLog("hostiles scanned")
                            end
                        end
                        self:PrestigeEvent(hShooter.id, { hShooter.TagAward.PP, hShooter.TagAward.CP }, "@x_entities_scanned", { Count = hShooter.TagAward.Num })
                    else
                        -- TODO
                        -- "@no_entities_scanned"
                        DebugLog("none scanned")
                    end
                end

                hShooter.TagAward = {
                    CP  = 0,
                    PP  = 0,
                    Num = 0,
                    Hostiles = 0
                }
            end
        },
        {
            ------------------------------
            ---  Server.OnTurretHit
            ------------------------------
            Name = "Server.OnTurretHit",
            Value = function(self, hTurret, aHitInfo)

                local hShooter = aHitInfo.shooter
                local hWeapon = Server.Utils:GetEntity(aHitInfo.weaponId)
                local sWeapon = (hWeapon and hWeapon.class)
                local sType = aHitInfo.type

                local aTurretConfig = self.TurretConfig

                if (sType == "law_rocket") then
                    local iRPGScale = aTurretConfig.RPGTurretDamageScale
                    aHitInfo.damage = aHitInfo.damage * iRPGScale
                end

                if (hTurret and self:GetState() == "InGame") then

                    local teamId = (self.game:GetTeam(hTurret.id) or 0)
                    hTurret.LastHitTimer = TimerNew()

                    if (teamId ~= 0) then
                        if (_time - self.lastTurretHit[teamId] >= 5) then

                            self.lastTurretHit[teamId] = _time
                            local players = self.game:GetTeamPlayers(teamId, true)
                            if (players) then
                                for i, p in pairs(players) do
                                    local channel = p.actor:GetChannel()
                                    if (channel > 0) then
                                        self.onClient:ClTurretHit(channel, hTurret.id)
                                        if (hTurret.item:IsDestroyed()) then
                                            self.onClient:ClTurretDestroyed(channel, hTurret.id)
                                        end
                                    end
                                end
                            end
                        end

                        local bShooterPlayer = (hShooter and hShooter.IsPlayer)
                        local bDestroyed = hTurret.item:IsDestroyed()
                        if (not bDestroyed and bShooterPlayer and teamId ~= self.game:GetTeam(hShooter.id)) then

                            if (aTurretConfig.TargetPlayersOnAttack and Server.Utils:GetDistance(hTurret, hShooter) < 300) then
                                hTurret.weapon:Sv_GunTurretTargetEntity(hShooter.id, 5)
                            end

                            local iMaxHP = hTurret.Properties.HitPoints
                            local iHP = math.max((hTurret.item:GetHealth() - aHitInfo.damage), 0)
                            local iMaxRemaining = math.max(0, math.ceil(iMaxHP / aHitInfo.damage))
                            local iRemainingHits = math.max(0, math.ceil(iHP / aHitInfo.damage))
                            if (not bDestroyed) then
                                Server.Chat:TextMessage(ChatType_Center, hShooter, string.format("( %0.2f%% HP - %d @hits_remaining )", (iHP / iMaxHP) * 100, iRemainingHits))--, )
                            end
                        end

                        if (bShooterPlayer and (teamId == 0 or (teamId ~= self.game:GetTeam(aHitInfo.shooterId))) and bDestroyed) then
                            self:PrestigeEvent(hShooter, { iPP, self.cpList.TURRETKILL }, "@turret @destroyed")
                            hTurret.DestroyedTimer = timernew()
                        end
                    end
                end
            end
        },
        {
            ------------------------------
            ---  SellItem
            ------------------------------
            Name = "SellItem",
            Value = function(self, hPlayerID, sItem)

                local hPlayer = System.GetEntity(hPlayerID)
                if (not hPlayer) then
                    return false
                end

                local hCurrent = hPlayer:GetCurrentItem()
                local bSold    = false
                local iPrice
                local aDef

                local iSellMultiplier = self.BuyingConfig.ItemSellPriceScale --ConfigGet("General.GameRules.Buying.SellItemReward", 75, eConfigGet_Number)
                if (self:IsInBuyZone(hPlayerID)) then
                    if (hCurrent) then
                        for _, aInfo in pairs(self.buyList) do
                            if (aInfo.class == hCurrent.class) then
                                aDef = aInfo
                                break
                            end
                        end

                        if (aDef) then
                            iPrice = aDef.price
                            if (iPrice) then

                                local iSellPrice = math.floor(math.max(0, iPrice * (iSellMultiplier)) + 0.5)
                                self:PrestigeEvent(hPlayerID, iSellPrice, (aDef.name and "%1" or ("@item " .. hCurrent.class)) .. " @sold", {aDef.name})

                                hPlayer.actor:SelectItemByNameRemote("Fists")
                                System.RemoveEntity(hCurrent.id)
                                bSold = true
                            else
                                Server.Chat:TextMessage(ChatType_Error, hPlayerID, "@cannot_sell_item", { Class = hCurrent.class })
                            end
                        else
                            Server.Chat:TextMessage(ChatType_Error, hPlayerID, "@cannot_sell_item", { Class = hCurrent.class })
                        end
                    else
                        Server.Chat:TextMessage(ChatType_Error, hPlayerID, "@no_item_to_sell", { })
                    end
                else
                    Server.Chat:TextMessage(ChatType_Error, hPlayerID, "@sellItem_not_inside_buyZone", { })
                end

                return bSold
            end
        },
        {
            ------------------------------
            ---  DoBuyAmmo
            ------------------------------
            Name = "DoBuyAmmo",
            Value = function(self, hPlayerID, sItem)

                local hPlayer = System.GetEntity(hPlayerID)
                if (not hPlayer) then
                    return
                end


                local hCurrent = hPlayer:GetCurrentItem()
                local iPrice
                local aDef

                if (string.MatchesAny(sItem, { "^sell_%d$", "^sellitem", "^sell"})) then
                    return self:SellItem(hPlayerID, sItem)
                end

                aDef = self:GetItemDef(sItem)
                if (not aDef) then
                    Server.Chat:TextMessage(ChatType_Error, hPlayer, "@ammo_not_found", { Class = sItem })
                    return false
                end

                local aReviveQueue
                local bAlive = hPlayer:IsAlive()
                if (not bAlive) then
                    aReviveQueue = self.reviveQueue[hPlayerID]
                end

                -- Server
                local aServerProperties = (aDef.ServerProperties or {})

                local iLevel    = 0
                local aZones    = self.inBuyZone[hPlayerID]
                local teamId    = self.game:GetTeam(hPlayerID)

                local hVehicle = Server.Utils:GetEntity(hPlayer:GetVehicleId())
                if (hVehicle and (not hVehicle.buyFlags or hVehicle.buyFlags == 0)) then
                    aZones = self.inServiceZone[hPlayerID]
                end

                local aZone, iZoneLevel
                for zoneId in pairs(aZones or {}) do
                    if (teamId == self.game:GetTeam(zoneId)) then
                        aZone = System.GetEntity(zoneId)
                        if (aZone and aZone.GetPowerLevel) then
                            iZoneLevel = aZone:GetPowerLevel()
                            if (iZoneLevel > iLevel) then
                                iLevel = iZoneLevel
                            end
                        end
                    end
                end

                if (aDef.level and aDef.level > 0 and aDef.level > iLevel) then
                    self.game:SendTextMessage(TextMessageError, "@mp_AlienEnergyRequired", TextMessageToClient, hPlayerID, aDef.name)
                    return false
                end
                ---------------------------------------

                local aAmmo = self.buyList[sItem]
                local iAmmoCurr, iAmmoMax, iNeed

                if (aAmmo and aAmmo.ammo) then
                    iPrice = self:GetPrice(sItem)

                    -- ignore vehicles with buyzones here (we want to buy ammo for the player not the vehicle in this case)
                    if (hVehicle and not hVehicle.buyFlags and not hVehicle.NoBuyAmmo) then
                        if (bAlive) then

                            --is in vehiclebuyzone
                            if (self:IsInServiceZone(hPlayerID) and (iPrice == 0 or self:EnoughPP(hPlayerID, nil, iPrice)) and self:VehicleCanUseAmmo(hVehicle, sItem)) then
                                iAmmoCurr = (hVehicle.inventory:GetAmmoCount(sItem) or 0)
                                iAmmoMax  = (hVehicle.inventory:GetAmmoCapacity(sItem) or 0)

                                if (iAmmoCurr < iAmmoMax or iAmmoMax == 0) then
                                    iNeed = aAmmo.amount
                                    if (iAmmoMax>0) then
                                        iNeed = math.min(iAmmoMax - iAmmoCurr, aAmmo.amount)
                                    end

                                    -- this function takes care of synchronizing it to clients
                                    hVehicle.vehicle:SetAmmoCount(sItem, iAmmoCurr + iNeed)

                                    if (iPrice > 0) then
                                        if (iNeed < aAmmo.amount) then
                                            iPrice = math.ceil((iNeed * iPrice) / aAmmo.amount)
                                        end

                                        self:PrestigeEvent(hPlayerID, -iPrice, "@vehicle @ammo @bought")
                                    end
                                    return true
                                end
                            end
                        end
                    elseif ((self:IsInBuyZone(hPlayerID) or (not bAlive)) and (iPrice == 0 or self:EnoughPP(hPlayerID, nil, iPrice))) then
                        iAmmoCurr = (hPlayer.inventory:GetAmmoCount(sItem) or 0)
                        iAmmoMax  = (hPlayer.inventory:GetAmmoCapacity(sItem) or 0)

                        if (not bAlive) then
                            iAmmoCurr = (aReviveQueue.ammo[sItem] or 0)
                        end

                        if (iAmmoCurr < iAmmoMax or iAmmoMax == 0) then
                            iNeed = aAmmo.amount;
                            if (iAmmoMax > 0) then
                                iNeed = math.min(iAmmoMax - iAmmoCurr, aAmmo.amount)
                            end

                            if (bAlive) then
                                -- this function takes care of synchronizing it to clients
                                hPlayer.actor:SetInventoryAmmo(sItem, iAmmoCurr + iNeed)
                            else
                                aReviveQueue.ammo[sItem] = (iAmmoCurr + iNeed)
                            end

                            if (iPrice > 0) then
                                if (iNeed < aAmmo.amount) then
                                    iPrice = math.ceil((iNeed * iPrice) / aAmmo.amount)
                                end

                                if (bAlive) then

                                    local sName = aDef.name
                                    local sFmt = "%1 "
                                    if (string.empty(sName)) then
                                        sFmt = ""
                                        sName = ""
                                    end
                                    self:PrestigeEvent(hPlayerID, -iPrice, sFmt .. "@ammo @bought", sName)
                                else
                                    aReviveQueue.ammo_price = (aReviveQueue.ammo_price + iPrice)
                                end
                            end

                            return true
                        end
                    end
                end
                return false
            end
        },
        {
            ------------------------------
            ---         BuyItem
            ------------------------------
            Name = "BuyItem",
            Value = function(self, hPlayerID, sItem)

                -- !!hook
                local hPlayer = Server.Utils:GetEntity(hPlayerID)
                if (not hPlayer) then
                    return false
                end

                if (string.MatchesAny(sItem, { "^sell_%d$", "^sellitem", "^sell"})) then
                    return self:SellItem(hPlayerID, sItem)
                end

                local iEnergy
                local iPrice = self:GetPrice(sItem)
                local aDef   = self:GetItemDef(sItem)

                if (not aDef) then
                    Server.Chat:TextMessage(ChatType_Error, hPlayer, "@item_not_found", { Class = sItem })
                    return false
                end

                if (not Server.PlayerEquipment:CanBuyItem(hPlayer, sItem, aDef)) then
                    return false
                end

                if (aDef.buy) then
                    local aBuyDef = self:GetItemDef(aDef.buy)
                    if (aBuyDef and (not self:HasItem(hPlayerID, aBuyDef.class))) then
                        local result = self:BuyItem(hPlayerID, aBuyDef.id)
                        if (not result) then
                            return false
                        end
                    end

                end

                if (aDef.buyammo and self:HasItem(hPlayerID, aDef.class)) then
                    local ret = self:DoBuyAmmo(hPlayerID, aDef.buyammo)
                    if (aDef.selectOnBuyAmmo and ret and hPlayer) then
                        hPlayer.actor:SelectItemByNameRemote(aDef.class)
                    end
                    return ret
                end

                local aReviveQueue
                local bAlive = hPlayer:IsAlive()
                if (not bAlive) then
                    aReviveQueue = self.reviveQueue[hPlayerID]
                end

                -- Server
                local aBuyConfig = self.BuyingConfig
                local iKitLimit = aBuyConfig.KitLimit
                local iKitCount = table.count({
                    hPlayer:GetItem("RadarKit"),
                    hPlayer:GetItem("RepairKit"),
                    hPlayer:GetItem("LockpickKit")
                })

                local uniqueOld
                if (aDef.uniqueId) then
                    local hasUnique, currentUnique = self:HasUniqueItem(hPlayerID, aDef.uniqueId)
                    if (hasUnique) then
                        if (bAlive and aServerProperties.NoItemLimit ~= true) then
                            if (aDef.category == "@mp_catEquipment") then
                                if (iKitCount > iKitLimit) then
                                    g_pGame:SendTextMessage(TextMessageError, "@mp_CannotCarryMoreKit", TextMessageToClient, hPlayerID)
                                end
                            else
                                if (aDef.class) then
                                    if (aDef.category == "@mp_catWeapons") then
                                        hPlayer:SelectItem(aDef.class)
                                    end
                                end
                                self.game:SendTextMessage(TextMessageError, "@mp_CannotCarryMore", TextMessageToClient, hPlayerID)
                            end
                            return false
                        end
                        uniqueOld = currentUnique
                    end
                end

                local flags     = 0
                local level     = 0
                local aZones    = self.inBuyZone[hPlayerID]
                local iTeam     = g_pGame:GetTeam(hPlayerID)
                local aFactory

                for zoneId in pairs(aZones) do
                    if (iTeam == self.game:GetTeam(zoneId)) then
                        local zone = System.GetEntity(zoneId)
                        if (zone and zone.GetPowerLevel) then
                            local zonelevel = zone:GetPowerLevel()
                            if (zonelevel > level) then
                                level = zonelevel
                            end
                        end
                        if (zone and zone.GetBuyFlags) then
                            flags = bor(flags, zone:GetBuyFlags())
                        end
                        aFactory = zone
                    end
                end

                -- dead players can't buy anything else
                if (not bAlive) then
                    flags = bor(bor(self.BUY_WEAPON, self.BUY_AMMO), self.BUY_EQUIPMENT)
                end

                if (aDef.level and aDef.level > 0 and aDef.level > level) then
                    self.game:SendTextMessage(TextMessageError, "@mp_AlienEnergyRequired", TextMessageToClient, hPlayerID, aDef.name, aDef.level)
                    return false
                end

                local itemflags = self:GetItemFlag(sItem)
                if (band(itemflags, flags) == 0) then
                    return false
                end

                -- FIXME: Bypass xyz mode
                local limitOk, teamCheck, iLimit = self:CheckBuyLimit(sItem, self.game:GetTeam(hPlayerID))
                if (not limitOk) then
                    if (teamCheck) then
                        self.game:SendTextMessage(TextMessageError, "@mp_TeamItemLimit" .. string.format(" (Limit %d)", iLimit), TextMessageToClient, hPlayerID, aDef.name)
                    else

                        self.game:SendTextMessage(TextMessageError, "@mp_GlobalItemLimit" .. string.format(" (Limit %d)", iLimit), TextMessageToClient, hPlayerID, aDef.name)
                    end

                    return false
                end

                -- check inventory
                local hItemID
                local bOk

                if (bAlive) then
                    bOk = hPlayer.actor:CheckInventoryRestrictions(aDef.class)
                else

                    if (aReviveQueue.items and table.count(aReviveQueue.items) > 0) then
                        local aInventory = {}
                        for _, v in ipairs(aReviveQueue.items) do
                            local aItem = self:GetItemDef(v)
                            if (aItem) then
                                table.insert(aInventory, aItem.class)
                            end
                        end
                        bOk = hPlayer.actor:CheckVirtualInventoryRestrictions(aInventory, aDef.class)
                    else
                        bOk = true
                    end
                end

                if (bOk) then
                    if ((not bAlive) and (uniqueOld)) then
                        for i, old in pairs(aReviveQueue.items) do
                            if (old == uniqueOld) then
                                aReviveQueue.items_price = aReviveQueue.items_price - self:GetPrice(old)
                                table.remove(aReviveQueue.items, i)
                                break
                            end
                        end
                    end

                    iPrice, iEnergy = self:GetPrice(aDef.id)
                    if (bAlive) then

                        -- TODO: Purchase CoolDowns?
                        local hItemId = hPlayer:GiveItem(aDef.class, true)
                        local hItem = Server.Utils:GetEntity(hItemId)
                        if (not hItem) then
                            self:LogError("Failed to Give Item '%s' to Player", aDef.class)
                        end

                        Server.PlayerEquipment:OnItemBought(hPlayer, hItem, aDef, iPrice, aFactory)
                        self:AwardItemInvestmentPrestige(hPlayer, aDef, iPrice, aFactory)

                        self:PrestigeEvent(hPlayerID, -iPrice, "@item " .. (aDef.name and "%1" or (hItem.class)) .. " @bought", aDef.name)
                        if (iEnergy and iEnergy > 0) then
                            self:SetTeamPower(iTeam, self:GetTeamPower(iTeam) - iEnergy)
                        end
                        if (hItem) then
                            hItem.builtas = aDef.id
                        end

                    elseif ((not iEnergy) or (iEnergy == 0)) then
                        table.insert(aReviveQueue.items, aDef.id)
                        aReviveQueue.items_price = aReviveQueue.items_price + iPrice
                    else
                        return false
                    end
                else
                    self.game:SendTextMessage(TextMessageError, "@mp_CannotCarryMore", TextMessageToClient, hPlayerID)
                    return false
                end

                if (hItemID) then
                    self.Server.OnItemBought(self, hItemID, sItem, hPlayerID)
                end

                return true

            end
        },
        {
            ------------------------------
            ---  Server.SvBuy
            ------------------------------
            Name = "Server.SvBuy",
            Value = function(self, hPlayerID, sItem)

                local hPlayer = System.GetEntity(hPlayerID)
                if (not hPlayer or not hPlayer.IsPlayer) then
                    return
                end

                -- TODO: AntiCheat

                local bOk = false
                local iChannel = hPlayer:GetChannel()

                if (hPlayer:GetTeam() ~= 0) then
                    local bFrozen = hPlayer:IsFrozen()
                    local bAlive  = hPlayer:IsAlive(true)

                    if ((not bFrozen)) then
                        if (self:ItemExists(hPlayerID, sItem)) then
                            local aDef     = self.buyList[sItem]
                            local iPrice   = aDef.price
                            local iMissing = (iPrice - hPlayer:GetPrestige())

                            if (self:IsVehicle(sItem) and bAlive) then
                                if (self:EnoughPP(hPlayerID, sItem)) then
                                    bOk = self:BuyVehicle(hPlayerID, sItem)
                                else
                                    Server.Chat:TextMessage(ChatType_Error, hPlayer, "@insufficient_pp_vehicle", { Missing = iMissing, Class = aDef.class })
                                end
                            elseif (((not bFrozen) and self:IsInBuyZone(hPlayerID)) or (not bAlive)) then
                                if (self:EnoughPP(hPlayerID, sItem)) then
                                    bOk = self:BuyItem(hPlayerID, sItem)
                                else
                                    Server.Chat:TextMessage(ChatType_Error, hPlayer, "@insufficient_pp_item", { Missing = iMissing, Class = aDef.class })
                                end
                            end
                        else
                            if (string.MatchesAny(sItem, { "^sell_%d$", "^sellitem", "^sell"})) then
                                if (self:SellItem(hPlayer.id, sItem)) then
                                    bOk = true
                                end
                            else
                                Server.Chat:TextMessage(ChatType_Error, hPlayer, "@item_not_found", { Class = sItem })
                            end
                        end
                    end
                end

                if (bOk) then
                    self.onClient:ClBuyOk(iChannel, sItem)
                else
                    self.onClient:ClBuyError(iChannel, sItem)
                end
            end
        },
        {
            ------------------------------
            ---AwardItemInvestmentPrestige
            ------------------------------
            Name = "AwardItemInvestmentPrestige",
            Value = function(self, hPlayer, aDef, iPrice, aFactory)


                local iInvestmentShare = self.BuyingConfig.AwardInvestItemPrestige
                if (iInvestmentShare > 0) then

                    local aShareholders = aFactory.CapturedBy or {}
                    local iShareHolders = table.size(aShareholders)
                    if (iShareHolders == 0) then
                        return DebugLog("none?")
                    end


                    local iShare = math.floor(((iPrice / math.min(3, iShareHolders))) + 0.5)
                    if (iShare > 0) then
                        for _, hUser in pairs(aShareholders) do
                            if (Server.Utils:GetEntity(hUser.id) and self.game:GetTeam(hUser.id) == self.game:GetTeam(aFactory.id) and hUser.IsPlayer and hUser ~= hPlayer) then
                                self:PrestigeEvent(hUser, iShare, "@item_invest_reward")
                            end
                        end
                    end
                end
            end,
        },
        {
            ------------------------------
            ---  Server.OnCapture
            ------------------------------
            Name = "Server.OnCapture",
            Value = function(self, hSpawn, iTeam)

                hSpawn.CapturedBy = {}
                local aInside = hSpawn.inside
                if (aInside) then
                    local hPlayer
                    for _, idPlayer in ipairs(aInside) do
                        if (self.game:GetTeam(idPlayer) == iTeam) then
                            hPlayer = System.GetEntity(idPlayer)
                            if (hPlayer and hPlayer:IsAlive()) then
                                hSpawn.CapturedBy[idPlayer] = hPlayer
                                DebugLog("Captured by ",hPlayer:GetName())
                            end
                        end
                    end
                end
            end
        },
        {
            ------------------------------
            ---  Server.OnUncapture
            ------------------------------
            Name = "Server.OnUncapture",
            Value = function(self, hSpawn)
                hSpawn.CapturedBy = {}
            end
        },
        {
            ------------------------------
            ---  BuyVehicle
            ------------------------------
            Name = "BuyVehicle",
            Value = function(self, hPlayerID, sItem)

                local hPlayer = System.GetEntity(hPlayerID)
                if (not hPlayer) then
                    return false
                end

                -- TODO
                ----if (Server.PlayerVehicles:CanBuyVehicle(hPlayer, sItem) ~= true) then
                ----    return false
                ----end

                local hFactory = self:GetProductionFactory(hPlayerID, sItem, true)
                if (hFactory) then

                    local bLimitOk, bTeamCheck = self:CheckBuyLimit(sItem, hPlayer:GetTeam())
                    if (not bLimitOk) then
                        if (bTeamCheck) then
                            self.game:SendTextMessage(TextMessageError, "@mp_TeamItemLimit", TextMessageToClient, hPlayerID, self:GetItemName(sItem))
                        else
                            self.game:SendTextMessage(TextMessageError, "@mp_GlobalItemLimit", TextMessageToClient, hPlayerID, self:GetItemName(sItem))
                        end

                        return false
                    end

                    for _, pFactory in pairs(self.factories) do
                        pFactory:CancelJobForPlayer(hPlayerID)
                    end

                    local aDef              = self.buyList[sItem]
                    local aServerProperties = (aDef.ServerProperties or {})

                    local iPrice, iEnergy = self:GetPrice(sItem)
                    if (hFactory:Buy(hPlayerID, sItem, aServerProperties)) then

                        self:PrestigeEvent(hPlayerID, { -iPrice, self.cpList.BUYVEHICLE }, "@vehicle %1 @bought", {}, {aDef.name})
                        if (iEnergy and iEnergy > 0) then
                            local iTeam = self.game:GetTeam(hPlayerID)
                            if (iTeam and iTeam ~= 0) then
                                self:SetTeamPower(iTeam, self:GetTeamPower(iTeam) - iEnergy)
                            end
                        end

                        self:AbandonPlayerVehicle(hPlayerID)
                        return true
                    end
                end

                return false
            end
        },
        {
            ------------------------------
            ---  UpdateUnclaimedVehicle
            ------------------------------
            Name = "EMPTY",
            Value = function(self, iFrameTime)
            end,
        },
    }
})