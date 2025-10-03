-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- This file Contains the Player Ranks & Leveling Component
-- ===================================================================================

Server:CreateComponent({
    Name = "PlayerRanks",
    FriendlyName = "Ranking",
    Body = {

        ChatEntity = "FARQUAAD:LEAGUES",
        ComponentStatus = true,

        Protected = {
            PlayerData = {}
        },

        ComponentConfig = {
            { Config = "IsEnabled",             Key = "$ComponentStatus",   Default = true },
            { Config = "AllowDownRanking",      Key = "AllowDownRanking",   Default = false },
            { Config = "EnableRanking",         Key = "EnableRanking",      Default = true },
            { Config = "AllowDownLevelling",    Key = "AllowDownLevelling", Default = true },
            { Config = "EnableLevelling",       Key = "EnableLevelling",    Default = true },

            -- TODO: Im lzy rn
           -- { Config = "Levels.BaseXP", Key = "$LevelInfo.BaseXP", Default = 100 },
           -- { Config = "Levels.LevelXPMultiplier", Key = "$LevelInfo.LevelXPMultiplier", Default = 1.15 },
        },

        LevelInfo = {

            -- Base XP Required for a level up
            BaseXP = 100,

            -- Per level, multiply base XP by this amount as the requirement for the next level
            LevelXPMultiplier = 1.15,

            -- Multipliers applied after reaching the target level
            LevelXPMultipliers = {
                [10] = 1.35,
                [20] = 1.45,
                [30] = 1.55,
                [40] = 1.65,
                [50] = 1.75,
                [60] = 1.85,
                [70] = 1.95,
                [80] = 2.00,
                [90] = 2.25,
                [100] = 3.0,
                [125] = 5.0,
                [150] = 7.0,
                [175] = 9.0,
                [200] = 10.,
                [250] = 15.,
                [300] = 20.,
                [400] = 25.,
                [500] = 30.,
                [600] = 35.,
                [700] = 40.,
                [800] = 50.,
                [900] = 75.,
                [1000] = 100,
            }
        },

        RankList = {

            -- EXP Required for a rank up
            RankXP = 75,

            -- List of Ranks
            Names = {
                { Name = "PLASTIC",     Stages = 3, StageXPMultiplier = 1.0, },
                { Name = "POTATO",      Stages = 3, StageXPMultiplier = 2.0, },
                { Name = "WOODEN",      Stages = 3, StageXPMultiplier = 3.0, },
                { Name = "COPPER",      Stages = 5, StageXPMultiplier = 4.0, },
                { Name = "BRONZE",      Stages = 5, StageXPMultiplier = 5.0, },
                { Name = "SILVER",      Stages = 5, StageXPMultiplier = 6.0, },
                { Name = "GOLD",        Stages = 5, StageXPMultiplier = 10,  },
                { Name = "PLATINUM",    Stages = 5, StageXPMultiplier = 15,  },
                { Name = "AMETHYST",    Stages = 5, StageXPMultiplier = 15,  },
                { Name = "DIAMOND",     Stages = 9, StageXPMultiplier = 16,  },
                { Name = "EMERALD",     Stages = 9, StageXPMultiplier = 17,  },
                { Name = "OBSIDIAN",    Stages = 9, StageXPMultiplier = 18,  },
                { Name = "RUBY",        Stages = 9, StageXPMultiplier = 19,  },
                { Name = "OPAL",        Stages = 9, StageXPMultiplier = 20,  },
                { Name = "AMD",         Stages = 10, StageXPMultiplier = 25,  },

                -- no one will reach this
                { Name = "RANK_LIST_END", Stages = 1000, StageXPMultiplier = 1000 },
            }

        },

        XPActions = {},
        XPEvents = {
            [XPEvent_ChatMessage] = {
                Reward  = 1,
                Actions = 10, -- 1 XP per 10 messages sent
            },
            [XPEvent_CommandUsed] = {
                Reward  = 1,
                Actions = 5,
            },
        },

        Initialize = function(self)
        end,

        PostInitialize = function(self)
        end,

        IsEnabled = function(self)
            return self.Properties.IsEnabled
        end,

        XPEvent = function(self, hPlayer, hEvent)

            local tXPEvent = self.XPEvents[hEvent]
            if (tXPEvent) then
                local iXP = tXPEvent.Reward
                local iActions = tXPEvent.Actions
                local bActionsOk = true
                if (iActions and iActions > 1) then
                    self.XPActions[hEvent] = (self.XPActions[hEvent] or {})
                    self.XPActions[hEvent][hPlayer.id] = (self.XPActions[hEvent][hPlayer.id] or {
                        Last = Timer:New(),
                        Count = 0
                    })

                    local tPlayerAction = self.XPActions[hEvent][hPlayer.id]
                    if (tXPEvent.Timeout and tPlayerAction.Last.Expired_Refresh(tXPEvent.Timeout)) then
                        tPlayerAction.Count = 0
                    else
                        tPlayerAction.Last:Refresh()
                    end
                    local iCompletedActions = (tPlayerAction.Count + 1)
                    if (iCompletedActions >= iActions) then
                        iCompletedActions = 0
                        bActionsOk = true
                    end

                    tPlayerAction.Count = iCompletedActions
                end
                if (bActionsOk) then
                    self:AwardRankXP(hPlayer, iXP)
                    self:AwardLevelXP(hPlayer, iXP)
                end
            else
                self:LogError("Invalid XP Event '%s'", tostring(hEvent))
            end
        end,

        AwardRankXP = function(self, hPlayer, iXP)

            if (not self.Config.EnableRanking) then
                return
            end

            local tRankData = self:GetRankData(hPlayer)
            if (iXP < 0) then
                if (not self.Config.AllowDownRanking) then
                    return
                end
                -- Refresh rank from scratch upon XP decrement
                self:ResetRankData(tRankData)
            end

            --DebugLog(iXP,tRankData.RankXP)
            tRankData.RankXP = (tRankData.RankXP + iXP)
            self:RefreshRank(hPlayer)

            g_gameRules.game:SetSynchedEntityValue(hPlayer.id, GlobalKeys.PlayerRankXP, tRankData.RankXP)
            Server.ClientMod:ExecuteCode({
                Client = hPlayer,
                Code = ([[CryMP_Client:Event(ClEvents.XP,{Type="%s",Value=%f})]]):format("Rank", iXP)
            })
        end,

        AwardLevelXP = function(self, hPlayer, iXP)

            if (not self.Config.EnableLevelling) then
                return
            end

            local tLevelData = self:GetLevelData(hPlayer)
            if (iXP < 0) then
                if (not self.Config.AllowDownLevelling) then
                    return
                end
                -- Refresh rank from scratch upon XP decrement
                self:ResetLevelData(tLevelData)
            end

            tLevelData.LevelXP = (tLevelData.LevelXP + iXP)
            self:RefreshLevel(hPlayer)

            do return end
            DebugLog(tLevelData.LevelXP)
            g_gameRules.game:SetSynchedEntityValue(hPlayer.id, GlobalKeys.PlayerLevelXP, tLevelData.LevelXP)
            Server.ClientMod:ExecuteCode({
                Client = hPlayer,
                Code = ([[CryMP_Client:Event(ClEvents.XP,{Type="%s",Value=%f})]]):format("Level", iXP)--tLevelInfo.LevelXP)
            })
        end,

        ResetLevelData = function(self, tLevelData)
            tLevelData.NextLevelXP = nil
        end,

        ResetRankData = function(self, tRankData)
            tRankData.Rank = nil
            tRankData.RankStage = nil
            tRankData.NextRankXP = nil
        end,

        OnLevelIncreased = function(self, hPlayer)

            DebugLog("level up")
          --  error("lvl up")

        end,

        OnRankIncreased = function(self, hPlayer)

            local tRankData = self:GetRankData(hPlayer)

            local tFormat = {
                Name = hPlayer:GetName(),
                Rank = tRankData.Name
            }
            self:LogEvent({ Message = "@rank_advanced", MessageFormat = tFormat })
            Server.Chat:ChatMessage(ChatEntity_Server, ALL_PLAYERS, "@rank_advanced", tFormat)

        end,

        RefreshRank = function(self, hPlayer)

            local tRankData = self:GetRankData(hPlayer)

            local iBaseRankXP   = self.RankList.RankXP
            local iRankXP       = (tRankData.RankXP) or iBaseRankXP
            local iNextRankXP   = (tRankData.NextRankXP) or iBaseRankXP
            local iRank         = (tRankData.Rank) or 1
            local iStage        = (tRankData.RankStage) or 0

            local aNameList     = self.RankList.Names
            local tRankInfo     = aNameList[iRank]
            local iMaxRanks     = #aNameList
            local iMaxStage     = tRankInfo.Stages or 3

            local bRanked
            if (iRankXP > iNextRankXP) then
                while (iRankXP > iNextRankXP) do

                    iStage = iStage + 1

                    if (iStage > iMaxStage and iRank < iMaxRanks) then
                        iRank = iRank + 1
                        tRankInfo = aNameList[iRank]
                        iStage = 1
                        iMaxStage = tRankInfo.Stages or 3

                        tRankData.Rank = iRank
                    end

                    -- increment next XP required for next stage
                    tRankData.RankStage = iStage
                    tRankData.Name = ("%s %s"):format(tRankInfo.Name, math.ToRoman(iStage))
                    iNextRankXP = iNextRankXP + (iBaseRankXP * (tRankInfo.StageXPMultiplier or 1))
                    bRanked = true
                end

                tRankData.NextRankXP = iNextRankXP
            end
            if (bRanked) then
                self:OnRankIncreased(hPlayer)
            end

            return
        end,

        RefreshLevel = function(self, hPlayer)

            local tLevelInfo = self:GetLevelData(hPlayer)

            local iBaseLevelXP   = self.LevelInfo.BaseXP
            local iLevelXP       = (tLevelInfo.LevelXP) or 0
            local iNextLevelXP   = (tLevelInfo.NextLevelXP) or iBaseLevelXP
            local iLevel         = (tLevelInfo.Rank) or 1
            local iLevelXPMult   = self.LevelInfo.LevelXPMultiplier

            if (iLevelXP > iNextLevelXP) then
                while (iLevelXP > iNextLevelXP) do

                    iLevel = iLevel + 1
                    for _, iMultiplier in pairs(self.LevelInfo.LevelXPMultipliers) do
                        if (iLevel >= _ and (iMultiplier > iLevelXPMult)) then
                            iLevelXPMult = iMultiplier
                            DebugLog("mult for lvl %d=%f",_,iLevelXPMult)
                        end
                    end

                    iNextLevelXP = iNextLevelXP + (iBaseLevelXP * (iLevelXPMult))
                    tLevelInfo.Level = iLevel
                    self:OnLevelIncreased(hPlayer)
                end

                tLevelInfo.NextLevelXP = iNextLevelXP
            end

            return
        end,

        GetEmptyData = function(self)
            return {
                Rank = nil,
                RankStage = nil,
                RankXP = 0,
                NextRankXP = nil,
                Name = ("%s %s"):format(self.RankList.Names[1].Name, math.ToRoman(1))
            }
        end,

        GetEmptyLevelData = function(self)
            return {
                Level = 0,
                LevelXP = 0,
                NextLevelXP = nil,
            }
        end,

        GetLevelData = function(self, hPlayer)
            local tData = hPlayer.Data.Level
            if (not tData) then
                hPlayer.Data.Level = self:GetEmptyLevelData()
                self:RefreshLevel(hPlayer)
                return self:GetLevelData(hPlayer)
            end
            return tData
        end,

        GetRankData = function(self, hPlayer)
            local tData = hPlayer.Data.Rank
            if (not tData) then
                hPlayer.Data.Rank = self:GetEmptyData()
                self:RefreshRank(hPlayer)
                return hPlayer.Data.Rank
            end
            return tData
        end,

        GetRankName = function(self, hPlayer)
            local tRankData = self:GetRankData(hPlayer)
            return tRankData.Name
        end,

        Command_ResetRank = function(self, hPlayer, hAdmin, sReason)

            hPlayer.Data.Rank = self:GetEmptyData()
            self:RefreshRank(hPlayer)

            if (hAdmin) then
                sReason = sReason or "@admin_decision"
            else
                sReason = sReason or "@user_decision"
            end
            self:LogEvent({
                Message = "@rank_reset_by" .. (hAdmin and "_admin" or ""),
                MessageFormat = {
                    Admin = (hAdmin and (hAdmin:GetName()) or ""),
                    Name = hPlayer:GetName(),
                    Reason = sReason
                }
            })
        end

    }
})