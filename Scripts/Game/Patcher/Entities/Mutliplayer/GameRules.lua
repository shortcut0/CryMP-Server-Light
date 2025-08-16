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

                self.IS_PS    = (self.class == GameMode_PS)
                self.IS_IA    = (self.class == GameMode_IA)
                self.IS_TIA   = (self.class == GameMode_TIA)

                self:InitializeConfig() -- FIXME
            end,
        },
        {
            ------------------------------
            ---   InitializeConfig
            ------------------------------
            Name = "InitializeConfig",
            Value = function(self)
                self.SkipPreGame = Server.Config:Get("GameConfig.SkipPreGames", false, ConfigType_Boolean)
                --if (self.SkipPreGame and self:GetState() ~= "InGame") then
                --    self:GotoState("InGame")
                --end

                self.TaggedExplosives = {}

                self.KillConfig = {
                    DropEquipment   = Server.Config:Get("GameConfig.KillConfig.DropEquipment", true,  ConfigType_Boolean),
                    SuicideKills    = Server.Config:Get("GameConfig.KillConfig.DeductSuicideKills", 0,  ConfigType_Number),
                    SuicideDeaths   = Server.Config:Get("GameConfig.KillConfig.SuicideAddDeaths", 1,    ConfigType_Number),
                    TeamKill        = Server.Config:Get("GameConfig.KillConfig.DeductTeamKill", 1,      ConfigType_Number),
                    BotScore        = Server.Config:Get("GameConfig.KillConfig.DeductBotKills", false,  ConfigType_Boolean),
                    NewMessages     = Server.Config:Get("GameConfig.KillConfig.EnableNewKillMessages", true, ConfigType_Boolean),
                    PremiumAmplification = Server.Config:Get("GameConfig.KillConfig.PremiumRewardsScale", 1.25, ConfigType_Number)
                }

                self.StreakMessages = {
                    InstantActionOnly = Server.Config:Get("GameConfig.KillConfig.KillStreaks.InstantActionOnly", true, ConfigType_Boolean),
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
                self.SnipingRewards = {
                    Enabled = Server.Config:Get("GameConfig.KillConfig.SnipingRewards.Enabled", true, ConfigType_Boolean),
                    MinimumDistance = Server.Config:Get("GameConfig.KillConfig.SnipingRewards.MinimumDistance", 100, ConfigType_Number),
                    RewardPP = Server.Config:Get("GameConfig.KillConfig.SnipingRewards.RewardPP", 500, ConfigType_Number),
                    RewardCP = Server.Config:Get("GameConfig.KillConfig.SnipingRewards.RewardXP", 35, ConfigType_Number),
                    HeadshotAmplification = Server.Config:Get("GameConfig.KillConfig.SnipingRewards.HeadshotAmplification", 1.25, ConfigType_Number),

                }

                self.AutoSpectateTimer = Server.Config:Get("GameConfig.AutoSpectateTimer", 30, ConfigType_Number)

                self.TurretConfig = {
                    RPGTurretDamageScale = Server.Config:Get("GameConfig.TurretConfig.RPGDamageScale", 1, ConfigType_Number),
                    TargetPlayersOnAttack = Server.Config:Get("GameConfig.TurretConfig.TargetPlayersOnAttack", true, ConfigType_Boolean),
                    RepairReward = Server.Config:Get("GameConfig.TurretConfig.RepairReward", 125, ConfigType_Number),
                }

                self.PrestigeConfig = {
                    AwardDisarmPrestigeAlways = Server.Config:Get("GameConfig.Prestige.AwardDisarmPrestigeAlways", true, ConfigType_Boolean),
                    VehicleTheftReward = Server.Config:Get("GameConfig.Prestige.VehicleTheftReward", 50, ConfigType_Number),
                    PremiumSpawnAmplification = Server.Config:Get("GameConfig.Prestige.PremiumSpawnPrestigeMultiplier", 1.25, eConfigGet_Number)
                }
                self.BuyingConfig = {
                    KitLimit = Server.Config:Get("GameConfig.Buying.KitLimit", 1, ConfigType_Number),
                    ItemSellPriceScale = Server.Config:Get("GameConfig.Buying.SellItemPriceScale", 75, ConfigType_Number),
                    AwardInvestItemPrestige = Server.Config:Get("GameConfig.Buying.AwardItemInvestPrestige", 0.25, ConfigType_Number),
                    AwardInvestVehiclePrestige = Server.Config:Get("GameConfig.Buying.AwardVehicleInvestPrestige", 0.15, ConfigType_Number),
                }

                self.KillAssistConfig = {
                    Enabled     = Server.Config:Get("GameConfig.KillConfig.KillAssistance.Enabled", true, ConfigType_Boolean),
                    Type        = Server.Config:Get("GameConfig.KillConfig.KillAssistance.Type", 1, ConfigType_Number),
                    Threshold   = Server.Config:Get("GameConfig.KillConfig.KillAssistance.Threshold", 15, ConfigType_Number),
                    Timeout     = Server.Config:Get("GameConfig.KillConfig.KillAssistance.Timeout", 12.5, ConfigType_Number),
                }


                self.CaptureConfig = {
                    PlayerCountAmplification = Server.Config:Get("GameConfig.Capturing.CaptureSpeedAmplification", 0, ConfigType_Number),
                    PlayerCountAmplificationLimit = Server.Config:Get("GameConfig.Capturing.CaptureSpeedAmplificationMax", 0.5, ConfigType_Number),
                }

                self.HitConfig = {
                    FriendlyFire = {
                        Punish = Server.Config:Get("GameConfig.HitConfig.FriendlyFire.Punish", false, ConfigType_Boolean),
                        KillLimit = Server.Config:Get("GameConfig.HitConfig.FriendlyFire.TeamKillLimit", 10, ConfigType_Number),
                        TeamKills = {}, -- Internal
                    }
                }

                self.Config = {
                    OpenDoorsOnCollision = Server.Config:Get("GameConfig.Immersion.OpenDoorsOnCollision", true, ConfigType_Boolean),
                }

                self:Log("Initialized with Config")
            end,
        },
        {
            ------------------------------
            ---   cpList
            ------------------------------
            Name = "cpList",
            Value = {

                IA_XP_MULT          = 1.35, -- multiplier in IA games

                FIRST_BLOOD         = 30,
                HEADSHOT_BONUS      = 4,
                BUY_DOOMSDAYMACHINE = 10, -- tac/tac vehicles done!!
                CAPTURE_SPECIAL     = 18, -- proto done!!

                KILL                = 5,
                KILL_RANKDIFF_MULT  = 1.2,
                TURRETKILL          = 12,
                REPAIR              = 3,
                LOCKPICK            = 3,
                CAPTURE             = 15,
                BUYVEHICLE          = 7,

                TAG_ENEMY           = 1,	--TODO once design is confirmed

                VEHICLE_KILL_MIN    = 5,
                VEHICLE_KILL_MULT   = 0.02,

                --ATTACKING FACILITY (Killing inside hostile facility)
                --DEFENDING FACILITY (Killing inside owned facility)
                --DESTROYING ENEMY TURRETS
                --REPAIRING TURRET
                --DAMAGING ENEMY HQ
                --DESTROYING ENEMY HQ
                --KILLING TAC WEAPON BEARER
            }
        },
        {
            ------------------------------
            ---      PostInitialize
            ------------------------------
            Name = "PostInitialize",
            Value = function(self)

                self:CollectPSBuildings()
                self:InitializeConfig() -- FIXME

                Server.Utils:SetCVar("g_friendlyfireRatio", Server.Config:Get("GameConfig.HitConfig.FriendlyFire.Ratio", 0, ConfigType_Number))
                Server.Utils:SetCVar("mp_killMessages", (self.KillConfig.NewMessages and "0" or "1"))

                ServerDLL.GameRulesInitScriptTables()
                self:Log("PostInitialize")
            end,
        },
        {
            ------------------------------
            ---   CollectPSBuildings
            ------------------------------
            Name = "CollectPSBuildings",
            Value = function(self)
                if (not self.IS_PS) then
                    return
                end

                self.Buildings = {}
                self.SortedBuildings = {
                    [BuildingType_Bunker] 	= {},
                    [BuildingType_Base]	    = {},
                    [BuildingType_Alien]	= {},
                    [BuildingType_HQ]		= {},
                    [BuildingType_Air]		= {},
                    [BuildingType_Small] 	= {},
                    [BuildingType_War]		= {},
                    [BuildingType_Boat]     = {},
                    [BuildingType_Proto] 	= {}
                }

                local hBuildings = System.GetEntitiesByClass("Factory")
                local sType, sLocale
                if (hBuildings) then
                    for _, hFactory in pairs(hBuildings) do
                        table.insert(self.Buildings, hFactory)
                        if (hFactory.Properties.buyOptions.bPrototypes == 1) then
                            sType = BuildingType_Proto
                            sLocale = "@building_type_prototypeFac"
                        elseif (hFactory:GetName():lower():find("air")) then
                            sType = BuildingType_Air
                            sLocale = "@building_type_airFac"
                        elseif (hFactory:GetName():lower():find("naval")) then
                            sType = BuildingType_Boat
                            sLocale = "@building_type_navalFac"
                        elseif (hFactory:GetName():lower():find("small")) then
                            sType = BuildingType_Small
                            sLocale = "@building_type_smallFac"
                        else
                            sType = BuildingType_War
                            sLocale = "@building_type_warFac"
                        end
                        hFactory.LocaleType = sLocale
                        hFactory.BuildingType = sType
                        table.insert(self.SortedBuildings[sType], hFactory)
                        table.insert(self.Buildings, hFactory)
                    end
                end

                -- Spawn Groups
                hBuildings = System.GetEntitiesByClass("SpawnGroup")
                if (hBuildings) then
                    for _, hSpawn in pairs(hBuildings) do
                        table.insert(self.Buildings, hSpawn)
                        if ((hSpawn.Properties.teamName == "tan" or hSpawn.Properties.teamName == "black") and not hSpawn.Properties.bCaptureable) then
                            sType = BuildingType_Base
                            sLocale = "@building_type_base"
                        else
                            sType = BuildingType_Bunker
                            sLocale = "@building_type_bunker"
                        end
                        hSpawn.BuildingType = sType
                        hSpawn.LocaleType = sLocale
                        table.insert(self.SortedBuildings[sType], hSpawn)
                        table.insert(self.Buildings, hSpawn)
                    end
                end

                -- Alien Energy Sites
                hBuildings = System.GetEntitiesByClass("AlienEnergyPoint")
                if (hBuildings) then
                    for _, hAlienSite in pairs(hBuildings) do

                        hAlienSite.BuildingType = BuildingType_Alien
                        hAlienSite.LocaleType = "@building_type_alien"
                        table.insert(self.Buildings, hAlienSite)
                        table.insert(self.SortedBuildings[BuildingType_Alien], hAlienSite)
                    end
                end

                -- HQs
                hBuildings = System.GetEntitiesByClass("HQ")
                if (hBuildings) then
                    for _, hHQ in pairs(hBuildings) do
                        hHQ.BuildingType = BuildingType_HQ
                        hHQ.LocaleType = "@building_type_hq"
                        table.insert(self.Buildings, hHQ)
                        table.insert(self.SortedBuildings[BuildingType_HQ], hHQ)
                    end
                end

                -- Init Functions
                for _, hBuilding in pairs(self.Buildings) do
                    if (hBuilding.GetTeam == nil) then
                        hBuilding.GetTeam = function(this) return self.game:GetTeam(this.id)  end
                    end
                end
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
            ---        Reset
            ------------------------------
            Name = "Reset",
            Value = function(self, forcePregame)

                if (self.IS_PS) then
                    self.inBuyZone={}
                    self.inServiceZone={}
                    self.unclaimedVehicle={}
                    self.reviveQueue={}

                    self:ResetMinimap()
                    self:ResetPower()

                    self.game:ResetReviveCycleTime()
                end

                self:ResetTime()

                -- done!! Disabled until Aspect RMI disco has been hunted down
                local bForceInGame = (self.SkipPreGame == true)
                local bInGame = ((self:PlayerCountOk() and (not forcePregame)) or (self.forceInGame))
                if (bForceInGame or bInGame) then
                    self:GotoState("InGame")
                else
                    self:GotoState("PreGame")
                end
                self.forceInGame=nil
                self.works={}
            end,
        },
        {
            ------------------------------
            ---        UpdatePings
            ------------------------------
            Name = "UpdatePings",
            Value = function(self, iFrameTime)
                Server.Network:UpdateGamePings(iFrameTime)
            end,
        },
        {
            ------------------------------
            ---    GetStepCaptureSpeed
            ------------------------------
            Name = "GetStepCaptureSpeed",
            Value = function(self, hBuilding, iInsideCount)

                local iCaptureSpeed = 1
                -- Amplify the speed based on the players inside
                iCaptureSpeed = (iCaptureSpeed * (1 + math.min((math.max(0, iInsideCount-1) * self.CaptureConfig.PlayerCountAmplification), self.CaptureConfig.PlayerCountAmplificationLimit)))

               -- DebugLog("hello?",iInsideCount,iCaptureSpeed)
                return iCaptureSpeed
            end,
        },
        {
            ------------------------------
            ---    GetStepUncaptureSpeed
            ------------------------------
            Name = "GetStepUncaptureSpeed",
            Value = function(self, hBuilding, iInsideCount)

                local iCaptureSpeed = 1
                -- Amplify the speed based on the players inside
                iCaptureSpeed = (iCaptureSpeed * (1 + math.min((math.max(0, iInsideCount-1) * self.CaptureConfig.PlayerCountAmplification), self.CaptureConfig.PlayerCountAmplificationLimit)))

               -- DebugLog("UN hello?",iInsideCount,iCaptureSpeed)
                return iCaptureSpeed
            end,
        },
        {
            ------------------------------
            ---        GetKills
            ------------------------------
            Name = "GetKills",
            Value = function(self, hPlayerId)
                return (g_gameRules.game:GetSynchedEntityValue(hPlayerId, self.SCORE_KILLS_KEY) or 1)
            end,
        },
        {
            ------------------------------
            ---        GetDeaths
            ------------------------------
            Name = "GetDeaths",
            Value = function(self, hPlayerId)
                return (g_gameRules.game:GetSynchedEntityValue(hPlayerId, self.SCORE_DEATHS_KEY) or 1)
            end,
        },
        {
            ------------------------------
            ---        SetDeaths
            ------------------------------
            Name = "SetDeaths",
            Value = function(self, hPlayerId, iDeaths)
                return (g_gameRules.game:SetSynchedEntityValue(hPlayerId, self.SCORE_DEATHS_KEY, iDeaths))
            end,
        },
        {
            ------------------------------
            ---        SetKills
            ------------------------------
            Name = "SetKills",
            Value = function(self, hPlayerId, iKills)
                return (g_gameRules.game:SetSynchedEntityValue(hPlayerId, self.SCORE_KILLS_KEY, iKills))
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
                return (g_gameRules.game:GetSynchedEntityValue(hPlayerId, self.RANK_KEY) or 1)
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
                return (g_gameRules.game:SetSynchedEntityValue(hPlayerId, self.RANK_KEY, iRank))
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
                return (g_gameRules.game:GetSynchedEntityValue(hPlayerId, self.PP_AMOUNT_KEY) or 1)
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
                return (g_gameRules.game:SetSynchedEntityValue(hPlayerId, self.PP_AMOUNT_KEY, iPP))
            end,
        },
        {
            ------------------------------
            ---       AwardPPCount
            ------------------------------
            Name = "AwardCPCount",
            Value = function(self, hPlayerId, iCount, sWhy, bQuiet)

                local hPlayer = Server.Utils:GetEntity(hPlayerId)
                if (not hPlayer) then
                    return
                end

                if (Server.PlayerRanks:IsEnabled()) then
                    Server.PlayerRanks:AwardRankXP(hPlayer, iCount)
                end

                if (self.IS_IA) then
                    return
                end
                self:SetPlayerCP(hPlayerId, self:GetPlayerCP(hPlayerId) + iCount)
            end

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
                    bSilent = true
                    if (type(iPPCount) == "table") then
                        sMessage = hPlayer:LocalizeText(("%s ( %s%d PP, %s%d XP )"):format(sMessage, (iPPCount[1] >= 0 and "+" or ""), iPPCount[1], (iPPCount[2] >= 0 and "+" or "-"), iPPCount[2]), { tFormat })
                    else
                        sMessage = hPlayer:LocalizeText(("%s ( %s%d PP )"):format(sMessage, (iPPCount >= 0 and "+" or ""), iPPCount), { tFormat })
                    end

                    local sCryFormat = ""
                    if (tCryFormat) then
                        sCryFormat = ([[,"%s"]]):format(table.concat(tCryFormat, [[", "]]))
                    end
                    Server.ClientMod:ExecuteCode({
                        Code = ([[HUD.BattleLogEvent(eBLE_Currency,"%s"%s)]]):format(sMessage, sCryFormat),
                        Clients = hPlayer
                    })
                    --DebugLog("msg=",sMessage)
                end

                if (type(iPPCount) == "table") then
                    self:AwardPPCount(hPlayer.id, iPPCount[1], nil, bSilent)
                    self:AwardCPCount(hPlayer.id, iPPCount[2], nil)
                else
                    self:AwardPPCount(hPlayer.id, iPPCount, nil, bSilent)
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
                local iPremiumBonus = self.KillConfig.PremiumAmplification

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
                        if (not revive) then
                            self:ResetRevive(hPlayer.id)
                            revive = self.reviveQueue[hPlayer.id]
                        end
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
                        local iAmplification = aFirstBlood.RewardAmplification[iFirstBloodCount]

                        if (self.IS_IA) then
                            local iXP = (self.cpList.FIRST_BLOOD + iFirstBloodCount) * (iAmplification or 1)
                            Server.Chat:ChatMessage(ChatEntity_Server, ALL_PLAYERS, ("@first_blood_instantAction"), { XP = iXP, Shooter = hShooter:GetName() })
                            self:AwardCPCount(hShooter.id, iXP)
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

                DebugLog(self.StreakMessages.InstantActionOnly)
                if (self.StreakMessages.Enabled and (self.IS_IA or not self.StreakMessages.InstantActionOnly)) then
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

                    if (sDeathMessage and aDeathMessages.Status ~= false) then
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

                    if (sRSMessage and aRSMessages.Status ~= false) then
                        aFormat["Kills"] = iRSStreak
                        Message(Server.Logger:FormatTags(sRSMessage, aFormat))
                        bMsg = true

                    elseif (sKillMessage and aKillMessages.Status ~= false) then
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

                    local sShooterName = hShooter:GetName()
                    if (not hShooter.actor) then
                        sShooterName = hShooter.class
                    end
                    local sMessage = Server.Logger:FormatTags(table.Random(aMessages):format(sShooterName, hTarget:GetName()), {
                        TargetName  = hTarget:GetName(),
                        ShooterName = sShooterName,
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
            ---      CalcKillCP
            ------------------------------
            Name = "CalcKillCP",
            Value = function(self, tHitInfo)

                local target = tHitInfo.target
                local shooter = tHitInfo.shooter
                local headshot = self:IsHeadShot(tHitInfo)

                if (target ~= shooter) then

                    -- This is for player ranks, nothing more
                    if (self.IS_IA) then
                        -- More XP in Instant Action Games
                        return (self.cpList.KILL * (self.cpList.IA_XP_MULT) +(headshot and self.cpList.HEADSHOT_BONUS or 0))
                    end


                    local team1 = self.game:GetTeam(shooter.id)
                    local team2 = self.game:GetTeam(target.id)
                    if (team1 ~= team2) then
                        local ownRank = self:GetPlayerRank(shooter.id)
                        local enemyRank = self:GetPlayerRank(target.id)

                        return self.cpList.KILL + math.max(0, (enemyRank - ownRank) * self.cpList.KILL_RANKDIFF_MULT) + (headshot and self.cpList.HEADSHOT_BONUS or 0)
                    else
                        return -10
                    end
                end

                return 0
            end
        },
        {
            ------------------------------
            ---      AwardKillCP
            ------------------------------
            Name = "AwardKillCP",
            Value = function(self, tHitInfo)
                local xp = self:CalcKillCP(tHitInfo)
                self:AwardCPCount(tHitInfo.shooter.id, xp)
            end
        },
        {
            ------------------------------
            ---      OnTeamKill
            ------------------------------
            Name = "OnTeamKill",
            Value = function(self, hPlayerId)

                local hPlayer = Server.Utils:GetEntity(hPlayerId)
                if (not hPlayer) then
                    return
                end

                local aTk = self.Properties.HitConfig.FriendlyFire
                if (not aTk.Punish) then
                    return
                end

                aTk.TeamKills[hPlayerId] = (aTk.TeamKills[hPlayerId] + 1)
                if (aTk.TeamKills[hPlayerId] > aTk.TeamKillLimit) then
                    Server.Punisher:KickPlayer(Server:GetEntity(), hPlayer, "Team Kill Limit")
                end
                --[[
                if(System.GetCVar("g_tk_punish")==0) then
                    return;
                end

                self.teamkills[playerId] = 1 + (self.teamkills[playerId] or 0);
                if (self.teamkills[playerId] >= System.GetCVar("g_tk_punish_limit")) then
                    CryAction.BanPlayer(playerId, "You were banned for exceeding team kill limit");
                end
                ]]
            end
        },
        {
            ------------------------------
            ---      ProcessScores
            ------------------------------
            Name = "ProcessScores",
            Value = function(self, tHitInfo)

                local target = tHitInfo.target
                local shooter = tHitInfo.shooter
                local headshot = self:IsHeadShot(tHitInfo)

                local h = 0
                if (headshot) then
                    h = 1
                end

                if (target.actor and target.actor:IsPlayer()) then
                    self:Award(target, 1, 0, 0)
                end

                if (self.IS_IA) then

                    if (shooter and shooter.actor and shooter.actor:IsPlayer()) then
                        if (target ~= shooter) then
                            self:Award(shooter, 0, 1, h)
                        else
                            self:Award(shooter, 0, -1, 0)
                        end
                        self:AwardKillCP(tHitInfo)
                    end
                else

                    if (shooter and shooter.actor and shooter.actor:IsPlayer()) then
                        if (target ~= shooter) then
                            local team1=self.game:GetTeam(shooter.id)
                            local team2=self.game:GetTeam(target.id)

                            if (team1~=team2) then
                                self:Award(shooter, 0, 1, h)

                                -- update team score
                                self:SetTeamScore(team1, self:GetTeamScore(team1)+1)
                            else
                                self:Award(shooter, 0, -1, 0)
                                self:OnTeamKill(shooter.id)
                            end
                        else
                            self:Award(shooter, 0, -1, 0)
                        end
                    end

                    if (shooter and shooter.actor and shooter.actor:IsPlayer()) then
                        self:AwardKillPP(tHitInfo)
                        self:AwardKillCP(tHitInfo)
                    end
                end
            end
        },
        {
            ------------------------------
            ---      OnBeforePlayerKilled
            ------------------------------
            Name = "OnBeforePlayerKilled",
            Value = function(self, hTarget, tKillHit)
                if (hTarget and hTarget.IsPlayer and self.KillConfig.DropEquipment) then
                    for _, hItem in pairs(hTarget:GetInventory() or {}) do
                        if (hItem.weapon) then
                            hTarget.actor:DropItem(hItem.id)
                        end
                    end
                end
            end
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

                self:OnBeforePlayerKilled(hTarget, tKillHit)

                self.game:KillPlayer(tKillHit.targetId, true, true, tKillHit.shooterId, tKillHit.weaponId, tKillHit.damage, tKillHit.materialId, tKillHit.typeId, tKillHit.dir)
                self:ProcessScores(tKillHit)

                -- PowerStruggle Specific
                if (self.IS_PS) then
                    self:AwardAssistPPAndCP(tKillHit)
                    if (tKillHit.target and tKillHit.target.actor) then
                        self:VehicleOwnerDeath(tKillHit.target)
                    end
                elseif (self.IS_IA) then
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

                    if (hShooter ~= hTarget) then
                        self:UpdateHitAssist(hShooter, hTarget, tHitInfo)
                    end
                    if (not hShooter:HitAccuracyExpired()) then
                        hShooter:UpdateHitAccuracy("Hit")
                    end
                end
            end,
        },
        {
            ------------------------------
            ---   UpdateHitAssist
            ------------------------------
            Name = "UpdateHitAssist",
            Value = function(self, hShooter, hTarget, tHitInfo)

                if (not self.IS_PS) then
                    return
                end

                if (hShooter.IsPlayer and hTarget.class == "Player" and hShooter:GetTeam() ~= self.game:GetTeam(hTarget.id)) then

                    hTarget.CollectedHits = (hTarget.CollectedHits or {})
                    hTarget.CollectedHits[hShooter.id] = (hTarget.CollectedHits[hShooter.id] or {
                        Timer       = TimerNew(self.KillAssistConfig.Timeout),
                        HitCount    = 0,
                        DamageCount = 0
                    })

                    if (hTarget.CollectedHits[hShooter.id].Timer.expired()) then
                        hTarget.CollectedHits[hShooter.id].HitCount     = 0
                        hTarget.CollectedHits[hShooter.id].DamageCount  = 0
                    end

                    hTarget.CollectedHits[hShooter.id].Timer.refresh()
                    hTarget.CollectedHits[hShooter.id].HitCount     = (hTarget.CollectedHits[hShooter.id].DamageCount + 1)
                    hTarget.CollectedHits[hShooter.id].DamageCount  = (hTarget.CollectedHits[hShooter.id].DamageCount + tHitInfo.damage)

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
            ---     Server.RequestRevive
            ------------------------------
            Name = "Server.RequestRevive",
            Value = function(self, hPlayerId)
                local hPlayer = System.GetEntity(hPlayerId)
                if (not hPlayer) then
                    return
                end

                if (hPlayer and hPlayer.actor) then

                    if (self.IS_PS) then
                        -- Send Warning message if player has no spawn group selected!
                        if (not hPlayer.spawnGroupId or hPlayer.spawnGroupId == NULL_ENTITY) then
                            Server.Chat:TextMessage(ChatType_Error, hPlayer, "@no_spawnGroup_selected")
                        end
                        -- allow respawn if spectating player and on a team
                        if (((hPlayer.actor:GetSpectatorMode() == 3 and self.game:GetTeam(hPlayerId)~=0) or (hPlayer:IsDead() and hPlayer.death_time and _time-hPlayer.death_time>2.5)) and (not self:IsInReviveQueue(hPlayerId))) then
                            self:QueueRevive(hPlayerId)
                        end
                    else
                        if (hPlayer.death_time and _time-hPlayer.death_time>2.5 and hPlayer:IsDead()) then
                            self:RevivePlayer(hPlayer.actor:GetChannel(), hPlayer)
                        end
                    end
                end
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

                if (self.USE_SPAWN_GROUPS and iGroupId and iGroupId ~= NULL_ENTITY) then
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
                    Log("<1> Failed to spawn %s! iTeamId: %d  iGroupId: %s  group TeamId: %d", hPlayer:GetName(), self.game:GetTeam(hPlayer.id), tostring(iGroupId), self.game:GetTeam(iGroupId or NULL_ENTITY))

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
            ---Server.RequestSpectatorTarget
            ------------------------------
            Name = "Server.RequestSpectatorTarget",
            Value = function(self, hPlayerId, iChange)

                local hPlayer = Server.Utils:GetEntity(hPlayerId)
                if (not hPlayer or not hPlayer.actor) then
                    return
                end

                -- Something else blocked it!
                if (Server.Events.Callbacks:RequestSpectatorTarget(hPlayer, iChange) == false) then
                    return
                end

                local iTeam = self.game:GetTeam(hPlayerId)
                local iMode = hPlayer.actor:GetSpectatorMode()
                if (self.IS_PS) then
                    if (not hPlayer:IsDead() and iTeam ~= 0 and iMode ~= 3) then
                        return
                    end
                end

                local hTargetId = self.game:GetNextSpectatorTarget(hPlayerId, iChange)
                if (hTargetId) then
                    if (hTargetId ~= 0) then
                        self.game:ChangeSpectatorMode(hPlayerId, 3, hTargetId)
                    elseif (self.game:GetTeam(hPlayerId) == 0) then
                        self.game:ChangeSpectatorMode(hPlayerId, 1, NULL_ENTITY)	-- noone to spectate, so revert to free look mode
                    end
                end

            end
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
                local iPremiumSpawnPP = self.PrestigeConfig.PremiumSpawnAmplification --ConfigGet("General.GameRules.PremiumSpawnPP", 1.25, eConfigGet_Number)

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
                                                -- message will be drowned by equipment otherwise.
                                                Script.SetTimer(100, function()
                                                    --self:PrestigeEvent(player.id, iMinPP, "%1 - @spawn_prestige", {}, {rank.desc})
                                                    self:PrestigeEvent(player.id, iMinPP, "@spawning_as %1", {}, {rank.desc})
                                                end)
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

                    if ((vTeam~=0) and (vTeam~=sTeam)) then
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
                        self:PrestigeEvent(aHitInfo.shooterId, pp, (sName and "%%1" or "@vehicle") .. " @destroyed", {}, {sName})
                        self:AwardCPCount(aHitInfo.shooterId, cp)
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
            ---   AwardAssistPPAndCP
            ------------------------------
            Name = "AwardAssistPPAndCP",
            Value = function(self, aHitInfo)

                if (not self.IS_PS) then
                    return
                end

                local hTarget    = aHitInfo.target
                local hShooter   = aHitInfo.shooter

                if (not hShooter or not hTarget) then
                    return
                end

                local tAssistConfig = self.KillAssistConfig
                if (not tAssistConfig.Enabled) then
                    return
                end

                local hMethod = tAssistConfig.Type
                local iThreshold = tAssistConfig.Threshold

                local iPP = self:CalcKillPP(aHitInfo)
                local iCP = self:CalcKillCP(aHitInfo)

                if (hTarget.id ~= hShooter.id) then
                    local aCollectedHits = hTarget.CollectedHits
                    if (table.empty(aCollectedHits)) then
                        return
                    end

                    local iTotalHits   = 0
                    local iTotalDamage = 0

                    for hPlayerID, aInfo in pairs(aCollectedHits) do
                        if (hPlayerID ~= hTarget.id and Server.Utils:GetEntity(hPlayerID)) then

                            -- only add hits from players who actually assisted in the kill
                            if (not aInfo.Timer.expired()) then
                                iTotalHits   = iTotalHits   + aInfo.HitCount
                                iTotalDamage = iTotalDamage + aInfo.DamageCount
                            end
                        end
                    end

                    local iAssistance = 0
                    for hPlayerID, aInfo in pairs(aCollectedHits) do
                        local hPlayer = Server.Utils:GetEntity(hPlayerID)
                        if (hPlayerID ~= hShooter.id and hPlayerID ~= hTarget.id and hPlayer and hPlayer.IsPlayer) then

                            -- only add hits from players who actually assisted in the kill
                            if (not aInfo.Timer.expired()) then

                                -- Divide the rewards by the percentage of hits
                                iAssistance = (aInfo.HitCount / iTotalHits)
                                if (hMethod == 1) then

                                    -- Divide the rewards by the percentage of damage dealt
                                    iAssistance = (aInfo.DamageCount / iTotalDamage)
                                end

                                DebugLog(hPlayerID,"assistance:",iAssistance,">",(iThreshold or 0))
                                if ((iAssistance * 100) > (iThreshold or 0)) then
                                    self:PrestigeEvent(hPlayerID, {
                                        math.floor(math.max(0, iPP * iAssistance)),
                                        math.floor(math.max(0, iCP * iAssistance))
                                    }, "@kill_assist " .. ("%0.2f%%"):format(iAssistance * 100))
                                end
                            else
                                --    throw_error("timer expired")
                            end
                        end
                    end
                end
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
                                local sName
                                if (string.emptyN(hBuilding.Properties.szName)) then
                                    sName = hBuilding.Properties.szName
                                end

                                local iXP = self.cpList.CAPTURE
                                if (hBuilding.BuildingType == BuildingType_Proto) then
                                    iXP = self.cpList.CAPTURE_SPECIAL
                                end
                                self:PrestigeEvent(hPlayer, { iValue, self.cpList.CAPTURE}, (sName and "%1" or (hBuilding.LocaleType or "@unknown")) .. " @captured", {}, { sName })
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
                            local aNearby = Server.Utils:GetPlayers({ NotById = nil, InRage = iScanDistance, FromPos = hShooter:GetPos(), ByTeam = hShooter:GetTeam() })
                            for _, hNearby in pairs(aNearby) do
                                -- done
                                -- sounds/interface:multiplayer_interface:mp_tac_alarm_suit
                                -- "@hostiles_on_radar", { Count = iHostile }
                                --DebugLog("hostiles scanned")
                                Server.ClientMod:ExecuteCode({ Client = hNearby, Code = ([[CryMP_Client:PSE(g_laId,"sounds/interface:multiplayer_interface:mp_tac_alarm_suit")HUD.BattleLogEvent(eBLE_Warning,"%s")]]):format(hNearby:LocalizeText("@hostiles_on_radar", { Count = iHostile }))})
                            end
                        end
                        self:PrestigeEvent(hShooter.id, { hShooter.TagAward.PP, hShooter.TagAward.CP }, "@x_entities_scanned", { Count = hShooter.TagAward.Num })
                    else
                        -- don!!
                        -- "@no_entities_scanned"
                        --DebugLog("none scanned")
                        Server.ClientMod:ExecuteCode({ Client = hShooter, Code = ([[HUD.BattleLogEvent(eBLE_Warning,"%s")]]):format(hShooter:LocalizeText("@no_entities_scanned"))})
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
                                self:PrestigeEvent(hPlayerID, iSellPrice, (aDef.name and "%1" or ("@item " .. hCurrent.class)) .. " @sold", {}, {aDef.name})

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
                                        sFmt = "@ammo"
                                        sName = ""
                                    end
                                    self:PrestigeEvent(hPlayerID, -iPrice, sFmt .. " @bought", {}, { sName })
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
                                    g_gameRules.game:SendTextMessage(TextMessageError, "@mp_CannotCarryMoreKit", TextMessageToClient, hPlayerID)
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
                local iTeam     = g_gameRules.game:GetTeam(hPlayerID)
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

                        self:PrestigeEvent(hPlayerID, -iPrice, "" .. (aDef.name and "%1" or ("@item "..hItem.class)) .. " @bought", {}, { aDef.name })
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

                        -- special XP for buying doomsday items (tac tank, tac gun, etc)
                        local iXPBonus = self.cpList.BUYVEHICLE
                        local bIsSpecial = aDef.doomsday
                        if (bIsSpecial) then
                            iXPBonus = self.cpList.BUY_DOOMSDAYMACHINE
                        end

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
            ---  EMPTY
            ------------------------------
            Name = "EMPTY",
            Value = function(self, iFrameTime)
            end,
        },
        {
            ------------------------------
            ---       OnCollision
            ------------------------------
            Name = "OnCollision",
            Value = function(self, entity, hit)

                local collider = hit.target;
                local colliderMass = hit.target_mass; -- beware, collider can be null (e.g. entity-less rigid entities)
                local contactVelocitySq;
                local contactMass;

                local hTarget = hit.target
                if (entity and hTarget) then
                    if (entity.vehicle and hTarget.class == "Door") then
                        if (hTarget.action ~= DOOR_OPEN and self.Config.OpenDoorsOnCollision) then
                            Server.Utils:SpawnEffect("explosions.Deck_sparks.VTOL_explosion", hit.pos, hit.normal, 0.1)
                            hTarget:Open(entity, DOOR_OPEN, true)
                        end
                    end
                end

                -- check if frozen
                if (self.game:IsFrozen(entity.id)) then
                    if ((not entity.CanShatter) or (tonumber(entity:CanShatter())~=0)) then
                        local energy = self:GetCollisionEnergy(entity, hit);

                        local minEnergy = 1000;

                        if (energy >= minEnergy) then
                            if (not collider) then
                                collider=entity;
                            end

                            local colHit = self.collisionHit;
                            colHit.pos = hit.pos;
                            colHit.dir = hit.dir or hit.normal;
                            colHit.radius = 0;
                            colHit.partId = -1;
                            colHit.target = entity;
                            colHit.targetId = entity.id;
                            colHit.weapon = collider;
                            colHit.weaponId = collider.id
                            colHit.shooter = collider;
                            colHit.shooterId = collider.id
                            colHit.materialId = 0;
                            colHit.damage = 0;
                            colHit.typeId = g_collisionHitTypeId;
                            colHit.type = "collision";

                            if (collider.vehicle and collider.GetDriverId) then
                                local driverId = collider:GetDriverId();
                                if (driverId) then
                                    colHit.shooterId = driverId;
                                    colHit.shooter=System.GetEntity(colHit.shooterId);
                                end
                            end

                            self:ShatterEntity(entity.id, colHit);
                        end

                        return;
                    end
                end

                if (not (entity.Server and entity.Server.OnHit)) then
                    return;
                end

                if (entity.IsDead and entity:IsDead()) then
                    return;
                end

                local minVelocity;

                -- collision with another entity
                if (collider or colliderMass>0) then
                    FastDifferenceVectors(self.tempVec, hit.velocity, hit.target_velocity);
                    contactVelocitySq = vecLenSq(self.tempVec);
                    contactMass = colliderMass;
                    minVelocity = self:GetCollisionMinVelocity(entity, collider, hit);
                else	-- collision with world
                    contactVelocitySq = vecLenSq(hit.velocity);
                    contactMass = entity:GetMass();
                    minVelocity = 7.5;
                end

                -- marcok: avoid fp exceptions, not nice but I don't want to mess up any damage calculations below at this stage
                if (contactVelocitySq < 0.01) then
                    contactVelocitySq = 0.01;
                end

                local damage = 0;

                -- make sure we're colliding with something worthy
                if (contactMass > 0.01) then
                    local minVelocitySq = minVelocity*minVelocity;
                    local bigObject = false;
                    --this should handle falling trees/rocks (vehicles are more heavy usually)
                    if(contactMass > 200.0 and contactMass < 10000 and contactVelocitySq > 2.25) then
                        if(hit.target_velocity and vecLenSq(hit.target_velocity) > (contactVelocitySq * 0.3)) then
                            bigObject = true;
                            --vehicles and doors shouldn't be 'bigObject'-ified
                            if(collider and (collider.vehicle or collider.advancedDoor)) then
                                bigObject = false;
                            end
                        end
                    end

                    local collideBarbWire = false;
                    if(hit.materialId == g_barbWireMaterial and entity and entity.actor) then
                        collideBarbWire = true;
                    end

                    --Log("velo : %f, mass : %f", contactVelocitySq, contactMass);
                    if (contactVelocitySq >= minVelocitySq or bigObject or collideBarbWire) then
                        -- tell AIs about collision
                        if(AI and entity and entity.AI and not entity.AI.Colliding) then
                            g_SignalData.id = hit.target_id;
                            g_SignalData.fValue = contactVelocitySq;
                            AI.Signal(SIGNALFILTER_SENDER,1,"OnCollision",entity.id,g_SignalData);
                            entity.AI.Colliding = true;
                            entity:SetTimer(COLLISION_TIMER,4000);
                        end
                        --

                        -- marcok: Uncomment this stuff when you need it
                        --local debugColl = self.game:DebugCollisionDamage();

                        --if (debugColl>0) then
                        -- Log("------------------------- collision -------------------------");
                        --end

                        local contactVelocity = math.sqrt(contactVelocitySq)-minVelocity;
                        if (contactVelocity < 0.0) then
                            contactVelocitySq = minVelocitySq;
                            contactVelocity = 0.0;
                        end

                        -- damage
                        if(entity.vehicle) then
                            if(not self:IsMultiplayer()) then
                                damage = 0.0005*self:GetCollisionEnergy(entity, hit); -- vehicles get less damage SINGLEPLAYER ONLY.
                            else
                                damage = 0.0002*self:GetCollisionEnergy(entity, hit);	-- keeping the original values for MP.
                            end
                        else
                            damage = 0.0025*self:GetCollisionEnergy(entity, hit);
                        end

                        -- apply damage multipliers
                        damage = damage * self:GetCollisionDamageMult(entity, collider, hit);

                        if(collideBarbWire and entity.id == g_localActorId) then
                            damage = damage * (contactMass * 0.15) * (30.0 / contactVelocitySq);
                        end

                        if(bigObject) then
                            if (damage > 0.5) then
                                damage = damage * (contactMass / 10.0) * (10.0 / contactVelocitySq);
                                if(entity.id ~= g_localActorId) then
                                    damage = damage * 3;
                                end
                            else
                                return;
                            end
                        end

                        -- subtract collision damage threshold, if available
                        if (entity.GetCollisionDamageThreshold) then
                            local old = damage;
                            damage = __max(0, damage - entity:GetCollisionDamageThreshold());
                        end

                        if (entity.actor) then
                            if(entity.actor:IsPlayer()) then
                                if(hit.target_velocity and vecLen(hit.target_velocity) == 0) then --limit damage from running agains static objects
                                    damage = damage * 0.2;
                                end
                            end

                            if(collider and collider.class=="AdvancedDoor")then
                                if(collider:GetState()=="Opened")then
                                    entity:KnockedOutByDoor(hit,contactMass,contactVelocity);
                                end
                            end;

                            if (collider and not collider.actor) then
                                local contactVelocityCollider = __max(0, vecLen(hit.target_velocity)-minVelocity);
                                local killVelocity = (entity.collisionKillVelocity or 20.0);

                                if(contactVelocity > killVelocity and contactVelocityCollider > killVelocity and colliderMass > 50 and not entity.actor:IsPlayer()) then
                                    local bNoDeath = entity.Properties.Damage.bNoDeath;
                                    local bFall = bNoDeath and bNoDeath~=0;

                                    -- don't allow killing friendly AIs by collisions
                                    if(not AI.Hostile(entity.id, g_localActorId, false)) then
                                        return;
                                    end


                                    --if (debugColl~=0) then
                                    --  Log("%s for <%s>, collider <%s>, contactVel %.1f, contactVelCollider %.1f, colliderMass %.1f", bFall and "FALL" or "KILL", entity:GetName(), collider:GetName(), contactVelocity, contactVelocityCollider, colliderMass);
                                    --end

                                    if(bFall) then
                                        entity.actor:Fall(hit.pos);
                                    else
                                        entity:Kill(true, NULL_ENTITY, NULL_ENTITY);
                                    end
                                else
                                    if(g_localActorId and AI.Hostile(entity.id, g_localActorId, false)) then
                                        if(not entity.isAlien and contactVelocity > 5.0 and contactMass > 10.0 and not entity.actor:IsPlayer()) then
                                            if(damage < 50) then
                                                damage = 50;
                                                entity.actor:Fall(hit.pos);
                                            end
                                        else
                                            if(not entity.isAlien and contactMass > 2.0 and contactVelocity > 15.0 and not entity.actor:IsPlayer()) then
                                                if(damage < 50) then
                                                    damage = 50;
                                                    entity.actor:Fall(hit.pos);
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end


                        if (damage >= 0.5) then
                            if (not collider) then collider = entity; end;

                            --prevent deadly collision damage (old system somehow failed)
                            if(entity.actor and not self:IsMultiplayer() and not AI.Hostile(entity.id, g_localActorId, false)) then
                                if(entity.id ~= g_localActorId) then
                                    if(entity.actor:GetHealth() <= damage) then
                                        entity.actor:Fall(hit.pos);
                                        return;
                                    end
                                end
                            end

                            local curtime = System.GetCurrTime();
                            if (entity.lastCollDamagerId and entity.lastCollDamagerId==collider.id and
                                    entity.lastCollDamageTime+0.3>curtime and damage<entity.lastCollDamage*2) then
                                return
                            end
                            entity.lastCollDamagerId = collider.id;
                            entity.lastCollDamageTime = curtime;
                            entity.lastCollDamage = damage;

                            --if (debugColl>0) then
                            --  Log("[SinglePlayer] <%s>: sending coll damage %.1f", entity:GetName(), damage);
                            --end

                            local colHit = self.collisionHit;
                            colHit.pos = hit.pos;
                            colHit.dir = hit.dir or hit.normal;
                            colHit.radius = 0;
                            colHit.partId = -1;
                            colHit.target = entity;
                            colHit.targetId = entity.id;
                            colHit.weapon = collider;
                            colHit.weaponId = collider.id
                            colHit.shooter = collider;
                            colHit.shooterId = collider.id
                            colHit.materialId = 0;
                            colHit.damage = damage;
                            colHit.typeId = g_collisionHitTypeId;
                            colHit.type = "collision";
                            colHit.impulse=hit.impulse;

                            if (collider.vehicle and collider.GetDriverId) then
                                local driverId = collider:GetDriverId();
                                if (driverId) then
                                    colHit.shooterId = driverId;
                                    colHit.shooter=System.GetEntity(colHit.shooterId);
                                end
                            end

                            local deadly=false;

                            if (entity.Server.OnHit(entity, colHit)) then
                                -- special case for actors
                                -- if more special cases come up, lets move this into the entity
                                if (entity.actor and self.ProcessDeath) then
                                    self:ProcessDeath(colHit);
                                elseif (entity.vehicle and self.ProcessVehicleDeath) then
                                    self:ProcessVehicleDeath(colHit);
                                end

                                deadly=true;
                            end

                            local debugHits = self.game:DebugHits();

                            if (debugHits>0) then
                                self:LogHit(colHit, debugHits>1, deadly);
                            end
                        end
                    end
                end
            end
        },
        {
            ------------------------------
            ---   protoList
            ------------------------------
            Name = "protoList",
            Value = {
                { id="moac",				name="@mp_eAlienWeapon", 			price=300, 		class="AlienMount", 			level=50,	uniqueId=11,	category="@mp_catWeapons", loadout=1 },
                { id="moar",				name="@mp_eAlienMOAR", 				price=100, 		class="MOARAttach", 			level=50,	uniqueId=12,	category="@mp_catWeapons", loadout=1 },

                { id="minigun",				name="@mp_eMinigun",				price=250, 		class="Hurricane", 		doomsday=1,		level=50,	uniqueId=13,	category="@mp_catWeapons", loadout=1 },
                { id="tacgun",				name="@mp_eTACLauncher", 			price=500, 		class="TACGun", 		doomsday=1,		level=100,	energy=5, uniqueId=14,	category="@mp_catWeapons", md=true, loadout=1 },

                { id="usmoac4wd",			name="@mp_eMOACVehicle",			price=300, 		class="US_ltv", 				level=50, 	modification="MOAC", 				vehicle=true, buildtime=20,	category="@mp_catVehicles", loadout=0 },
                { id="usmoar4wd",			name="@mp_eMOARVehicle",			price=350,		class="US_ltv", 				level=50,	modification="MOAR", 				vehicle=true, buildtime=20,	category="@mp_catVehicles", loadout=0 },

                { id="ussingtank",			name="@mp_eSingTank",				price=800, 		class="US_tank",		doomsday=1, 		level=100, 	energy=10, modification="Singularity",	vehicle=true, md=true, buildtime=60,	category="@mp_catVehicles", loadout=0 },
                { id="ustactank",			name="@mp_eTACTank",				price=750,		class="US_tank", 		doomsday=1,		level=100, 	energy=10, modification="TACCannon",		vehicle=true, md=true, buildtime=60,	category="@mp_catVehicles", loadout=0 },
            },
        },
        {
            ------------------------------
            ---   vehicleList
            ------------------------------
            Name = "vehicleList",
            Value = {
                { id="light4wd",				name="@mp_eLightVehicle", 			price=0,		class="US_ltv",					modification="Unarmed", 		buildtime=5,		category="@mp_catVehicles", loadout=0 },
                { id="us4wd",					name="@mp_eHeavyVehicle", 			price=50,		class="US_ltv",					modification="MP", 		buildtime=5,					category="@mp_catVehicles", loadout=0 },
                { id="usgauss4wd",		        name="@mp_eGaussVehicle",			price=200,		class="US_ltv", 				modification="Gauss", buildtime=10,					category="@mp_catVehicles", loadout=0 },

                { id="nktruck",				    name="@mp_eTruck",					price=0,		class="Asian_truck", 			modification="Hardtop_MP", buildtime=5,			category="@mp_catVehicles", loadout=0 },

                { id="ussupplytruck",		    name="@mp_eSupplyTruck",			price=300,		class="Asian_truck",			modification="spawntruck",	teamlimit=3, abandon=0, spawngroup=true,	buyzoneradius=6, servicezoneradius=16,	buyzoneflags=bor(bor(8 or PowerStruggle.BUY_AMMO, 1 or PowerStruggle.BUY_WEAPON), 4 or PowerStruggle.BUY_EQUIPMENT),			buildtime=25,		category="@mp_catVehicles", loadout=0		},

                { id="usboat",					name="@mp_eSmallBoat", 				price=0,		class="US_smallboat", 			modification="MP", buildtime=5,				category="@mp_catVehicles", loadout=0 },
                { id="nkboat",					name="@mp_ePatrolBoat", 			price=100,		class="Asian_patrolboat", 		modification="MP", buildtime=5,				category="@mp_catVehicles", loadout=0 },
                { id="nkgaussboat",		        name="@mp_eGaussPatrolBoat", 		price=200,		class="Asian_patrolboat", 		modification="Gauss", buildtime=10,		category="@mp_catVehicles", loadout=0 },
                { id="ushovercraft",	    	name="@mp_eHovercraft", 			price=100,		class="US_hovercraft",			modification="MP", buildtime=20,			category="@mp_catVehicles", loadout=0 },
                { id="nkaaa",					name="@mp_eAAVehicle",			    price=200,		class="Asian_aaa", 				modification="MP",	buildtime=20,			category="@mp_catVehicles", loadout=0 },

                { id="usapc",					name="@mp_eICV",					price=350,		class="US_apc", 				buildtime=20,		category="@mp_catVehicles", loadout=0 },
                { id="nkapc",					name="@mp_eAPC",					price=450,		class="Asian_apc", 				buildtime=20,	["special" or jeep]=true,	category="@mp_catVehicles", loadout=0 },

                { id="nktank",					name="@mp_eLightTank", 				price=400,		class="Asian_tank",				buildtime=30,		category="@mp_catVehicles", loadout=0 },
                { id="ustank",					name="@mp_eBattleTank",				price=450,		class="US_tank", 				modification="GaussRifle", 	buildtime=40,		category="@mp_catVehicles", loadout=0 },
                { id="usgausstank",		        name="@mp_eGaussTank",				price=600,		class="US_tank", 				modification="FullGauss", 	buildtime=60,		category="@mp_catVehicles", loadout=0 },

                { id="nkhelicopter",		    name="@mp_eHelicopter", 			price=400,		class="Asian_helicopter",		modification="MP",	buildtime=30,		category="@mp_catVehicles", loadout=0 },
                { id="usvtol",					name="@mp_eVTOL", 					price=600,		class="US_vtol", 				modification="MP",	buildtime=30,		category="@mp_catVehicles", loadout=0 },
            },
        },
        {
            ------------------------------
            ---   ammoList
            ------------------------------
            Name = "ammoList",
            Value = {
                { id="",							name="@mp_eAutoBuy",				price=0,												category="@mp_catAmmo", loadout=1 },
                { id="bullet",						name="@mp_eBullet", 				price=5,			amount=30,				category="@mp_catAmmo", loadout=1 },
                { id="fybullet",					name="@mp_eFYBullet", 				price=5,			amount=30,				category="@mp_catAmmo", loadout=1 },
                { id="shotgunshell",				name="@mp_eShotgunShell",		    price=5,			amount=8,					category="@mp_catAmmo", loadout=1 },
                { id="smgbullet",					name="@mp_eSMGBullet",				price=5,			amount=40,				category="@mp_catAmmo", loadout=1 },
                { id="lightbullet",					name="@mp_eLightBullet",			price=5,			amount=40,				category="@mp_catAmmo", loadout=1 },

                { id="sniperbullet",				name="@mp_eSniperBullet",			price=10,			amount=10,				category="@mp_catAmmo", loadout=1 },
                { id="scargrenade",					name="@mp_eRifleGrenade",			price=20,			amount=1,					category="@mp_catAmmo", loadout=1 },
                { id="gaussbullet",					name="@mp_eGaussSlug",				price=50,			amount=5, 				category="@mp_catAmmo", loadout=1 },

                { id="incendiarybullet",																	price=50,			amount=30,		invisible=true,		category="@mp_catAmmo", loadout=1 },

                { id="hurricanebullet",			    name="@mp_eMinigunBullet",		    price=50,			amount=500,				category="@mp_catAmmo", loadout=1 },

                { id="claymoreexplosive",																    price=25,			amount=1,			invisible=true,		category="@mp_catAmmo", loadout=1 },
                { id="avexplosive",																			price=25,			amount=1,			invisible=true,		category="@mp_catAmmo", loadout=1 },
                { id="c4explosive",																			price=50,		    amount=1,			invisible=true,		category="@mp_catAmmo", loadout=1 },

                { id="Tank_singularityprojectile",name="@mp_eSingularityShell",			price=200,		amount=1,					category="@mp_catAmmo", loadout=0 },

                { id="towmissile",			name="@mp_eAPCMissile",			price=50,			amount=2,					category="@mp_catAmmo", loadout=0 },
                { id="dumbaamissile",		name="@mp_eAAAMissile",			price=50,			amount=4,					category="@mp_catAmmo", loadout=0 },
                { id="tank125",				name="@mp_eTankShells",			price=100,		amount=10,				category="@mp_catAmmo", loadout=0 },
                { id="helicoptermissile",	name="@mp_eHelicopterMissile",	price=100,		amount=7,					category="@mp_catAmmo", loadout=0 },

                { id="tank30",				name="@mp_eAPCCannon",			price=100,		amount=100,				category="@mp_catAmmo", loadout=0 },
                { id="tankaa",				name="@mp_eAAACannon",			price=100,		amount=250,				category="@mp_catAmmo", loadout=0 },
                { id="a2ahomingmissile",	name="@mp_eVTOLMissile",		price=100,		amount=6,					category="@mp_catAmmo", loadout=0 },
                { id="gausstankbullet",		name="@mp_eGaussTankSlug",		price=100,		amount=10,				category="@mp_catAmmo", loadout=0 },

                { id="tacgunprojectile",    name="@mp_eTACGrenade",			price=200,		amount=1,	ammo=true, 			level=100,		category="@mp_catAmmo", loadout=1 },
                { id="tacprojectile",		name="@mp_eTACTankShell",	    price=200,		amount=1,	ammo=true, 			level=100,		category="@mp_catAmmo" },

                { id="iamag",				name="@mp_eIncendiaryBullet",	price=50, 			class="FY71IncendiaryAmmo",			ammo=false, equip=true, 	buyammo="incendiarybullet", category="@mp_catAddons", loadout=1 },
                { id="psilent",				name="@mp_ePSilencer",			price=10, 			class="SOCOMSilencer",			uniqueId=121, ammo=false, equip=true,		category="@mp_catAddons", loadout=1 },
                { id="plam",				name="@mp_ePLAM",				price=25, 			class="LAM",				uniqueId=122, ammo=false, equip=true,		category="@mp_catAddons", loadout=1 },
                { id="silent",				name="@mp_eRSilencer",			price=10, 			class="Silencer", 				uniqueId=123, ammo=false, equip=true,		category="@mp_catAddons", loadout=1 },
                { id="lam",					name="@mp_eRLAM",				price=25, 			class="LAMRifle",						uniqueId=124, ammo=false, equip=true,		category="@mp_catAddons", loadout=1 },
                { id="reflex",				name="@mp_eReflex",				price=25,				class="Reflex", 					uniqueId=125, ammo=false, equip=true,		category="@mp_catAddons", loadout=1 },
                { id="ascope",				name="@mp_eAScope",				price=50, 			class="AssaultScope", 			uniqueId=126, ammo=false, equip=true,		category="@mp_catAddons", loadout=1 },
                { id="scope",				name="@mp_eSScope",				price=100, 			class="SniperScope", 			uniqueId=127, ammo=false, equip=true,		category="@mp_catAddons", loadout=1 },
                { id="gl",					name="@mp_eGL",					price=50, 			class="GrenadeLauncher",		uniqueId=128, ammo=false, equip=true,		category="@mp_catAddons", loadout=1 },
            },
        },
        {
            ------------------------------
            ---   equipList
            ------------------------------
            Name = "equipList",
            Value = {
                { id="binocs",			name="@mp_eBinoculars",							price=50,			class="Binoculars", 			uniqueId=101,		category="@mp_catEquipment", loadout=1 },
                { id="nsivion",			name="@mp_eNightvision", 						price=10, 			class="NightVision", 			uniqueId=102,		category="@mp_catEquipment", loadout=1 },
                { id="pchute",			name="@mp_eParachute",							price=25,			class="Parachute",				uniqueId=103,		category="@mp_catEquipment", loadout=1 },
                { id="lockkit",			name="@mp_eLockpick",							price=25, 			class="LockpickKit",			uniqueId=110,		category="@mp_catEquipment", loadout=1 },
                { id="repairkit",		name="@mp_eRepair",								price=50, 			class="RepairKit", 				uniqueId=110,		category="@mp_catEquipment", loadout=1 },
                { id="radarkit",		name="@mp_eRadar",								price=50, 			class="RadarKit", 				uniqueId=110,		category="@mp_catEquipment", loadout=1 },
            },
        },
        {
            ------------------------------
            ---   weaponList
            ------------------------------
            Name = "weaponList",
            Value = {
                { id="flashbang",           name="@mp_eFlashbang",			price=10, 			amount=1, ammo=true, weapon=false, category="@mp_catExplosives", loadout=1},
                { id="smokegrenade",        name="@mp_eSmokeGrenade",		price=10, 			amount=1, ammo=true, weapon=false, category="@mp_catExplosives", loadout=1 },
                { id="explosivegrenade",	name="@mp_eFragGrenade",		price=25, 			amount=1, ammo=true, weapon=false, category="@mp_catExplosives", loadout=1 },
                { id="empgrenade",			name="@mp_eEMPGrenade",		    price=50,			amount=1, ammo=true, weapon=false, category="@mp_catExplosives", loadout=1 },

                { id="pistol",              name="@mp_ePistol", 			price=50, 			class="SOCOM",				                                category="@mp_catWeapons"},
                { id="claymore",			name="@mp_eClaymore",			price=25,			class="Claymore",			buyammo="claymoreexplosive",	category="@mp_catExplosives", loadout=1 },
                { id="avmine",				name="@mp_eMine",				price=25,			class="AVMine",				buyammo="avexplosive",			category="@mp_catExplosives", loadout=1 },
                { id="c4",					name="@mp_eExplosive", 			price=50, 			class="C4", 				buyammo="c4explosive",			category="@mp_catExplosives", loadout=1 },

                { id="shotgun",				name="@mp_eShotgun", 			price=50, 			class="Shotgun", 			uniqueId=4,		category="@mp_catWeapons", loadout=1 },
                { id="smg",					name="@mp_eSMG", 				price=75, 			class="SMG", 				uniqueId=5,		category="@mp_catWeapons", loadout=1 },
                { id="fy71",		    	name="@mp_eFY71", 				price=125, 			class="FY71", 				uniqueId=6,		category="@mp_catWeapons", loadout=1 },
                { id="macs",			    name="@mp_eSCAR", 				price=150, 			class="SCAR", 				uniqueId=7,		category="@mp_catWeapons", loadout=1 },
                { id="rpg",					name="@mp_eML", 				price=200, 			class="LAW", 				uniqueId=8,		category="@mp_catExplosives", loadout=1 },
                { id="dsg1",				name="@mp_eSniper"	,			price=200, 			class="DSG1", 				uniqueId=9,		category="@mp_catWeapons", loadout=1 },
                { id="gauss",				name="@mp_eGauss", 				price=600, 			class="GaussRifle",			uniqueId=10,	category="@mp_catWeapons", loadout=1 },
            },
        },
    }
})