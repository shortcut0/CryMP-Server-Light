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
                { Name = "POTATO",      Stages = 3, StageXPMultiplier = 1.0, },
                { Name = "WOODEN",      Stages = 3, StageXPMultiplier = 2.0, },
                { Name = "COPPER",      Stages = 5, StageXPMultiplier = 3.0, },
                { Name = "BRONZE",      Stages = 5, StageXPMultiplier = 5.0, },
                { Name = "SILVER",      Stages = 5, StageXPMultiplier = 6.0, },
                { Name = "GOLD",        Stages = 9, StageXPMultiplier = 10,  },
                { Name = "AMETHYST",    Stages = 9, StageXPMultiplier = 15,  },
                { Name = "DIAMOND",     Stages = 10, StageXPMultiplier = 18,  },
                { Name = "AMD",         Stages = 10, StageXPMultiplier = 25,  },

                -- no one will reach this
                { Name = "RANK_LIST_END", },
            }

        },

        Initialize = function(self)
        end,

        PostInitialize = function(self)
        end,

        IsEnabled = function(self)
            return self.Properties.IsEnabled
        end,

        AwardRankXP = function(self, hPlayer, iXP)

            if (iXP < 0 and not self.Properties.AllowDownRanking) then
                return
            end

            DebugLog("award xp",iXP)

            local tRankData = self:GetRankData(hPlayer)
            tRankData.RankXP = (tRankData.RankXP + iXP)
            self:RefreshRank(hPlayer)
        end,

        OnRankIncreased = function(self, hPlayer)

            local tRankData = self:GetRankData(hPlayer)
            Server.Chat:ChatMessage(ChatEntity_Server, ALL_PLAYERS, "@rank_advanced", {
                Name = hPlayer:GetName(),
                Rank = tRankData.Name
            })

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
                RankXP = 0,
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

    }
})