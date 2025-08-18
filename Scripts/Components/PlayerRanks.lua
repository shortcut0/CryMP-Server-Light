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
    FriendlyName = "Levels",
    Body = {

        --ExternalData = {
        --    { Key = "PlayerData", Name = "RankData.lua", Path = (SERVER_DIR_DATA .. "Users/") }
        --},

        ChatEntity = "< RANKS >",

        Properties = {

            IsEnabled = true,

        },

        Protected = {
            PlayerData = {}
        },

        RankList = {

            -- EXP Required for a level up
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
                { Name = "DIAMOND",     Stages = 9, StageXPMultiplier = 18,  },
                { Name = "EMERALD",     Stages = 9, StageXPMultiplier = 18,  },
                { Name = "RUBY",        Stages = 9, StageXPMultiplier = 18,  },
                { Name = "OPAL",        Stages = 9, StageXPMultiplier = 18,  },
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
                        Last = TimerNew(),
                        Count = 0
                    })

                    local tPlayerAction = self.XPActions[hEvent][hPlayer.id]
                    if (tXPEvent.Timeout and tPlayerAction.Last.Expired_Refresh(tXPEvent.Timeout)) then
                        tPlayerAction.Count = 0
                    else
                        tPlayerAction.Last.Refresh()
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
                end
            else
                self:LogError("Invalid XP Event '%s'", tostring(hEvent))
            end
        end,

        AwardRankXP = function(self, hPlayer, iXP)

            local tRankData = self:GetRankData(hPlayer)
            if (iXP < 0) then
                if (not self.Properties.AllowDownRanking) then
                    return
                end
                -- Refresh rank from scratch upon XP decrement
                self:ResetRankData(tRankData)
            end

            tRankData.RankXP = (tRankData.RankXP + iXP)
            self:RefreshRank(hPlayer)
        end,

        ResetRankData = function(self, tRankData)
            tRankData.Rank = nil
            tRankData.RankStage = nil
            tRankData.NextRankXP = nil
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
                    self:OnRankIncreased(hPlayer)
                    iNextRankXP = iNextRankXP + (iBaseRankXP * (tRankInfo.StageXPMultiplier or 1))
                end

                tRankData.NextRankXP = iNextRankXP
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

        GetRankData = function(self, hPlayer)
            local tData = hPlayer.Data.Rank
            if (not tData) then
                hPlayer.Data.Rank = self:GetEmptyData()
                self:RefreshRank(hPlayer)
                return self:GetRankData(hPlayer)
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