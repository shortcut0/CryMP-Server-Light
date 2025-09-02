-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
--                          This file Contains Chat-Commands
-- ===================================================================================

Server.ChatCommands:Add({

    -- ================================================================
    -- !PDA
    {
        Name = "pda",
        Access = ServerAccess_Lowest,
        Function = function(self)
            Server.Chat:SendWelcomeMessage(self, true)
        end
    },

    -- ================================================================
    -- !NAME
    {
        Name = "name",
        Access = ServerAccess_Lowest,
        Arguments = {
            { Name = "@name", Desc = "@arg_rename_desc", Required = true, Type = CommandArg_TypeMessage }
        },
        Function = function(self, sName)
            return Server.NameHandler:Command_Name(self, sName)
        end
    },

    -- ================================================================
    -- !ResetRank
    {
        Name = "ResetRank",
        Access = ServerAccess_Lowest,
        Arguments = {
        },
        Function = function(self)
            if (not self.TempData.RankResetConfirmation) then
                self.TempData.RankResetConfirmation = true
                Server.Chat:ChatMessage(Server.PlayerRanks.ChatEntity, self, "@rank_reset_confirmation")
                Server.Chat:ChatMessage(Server.PlayerRanks.ChatEntity, self, "@rank_reset_confirmation2")
                Server.Chat:ChatMessage(Server.PlayerRanks.ChatEntity, self, "@rank_reset_confirmation3")
                return true
            end
            self.TempData.RankResetConfirmation = false
            Server.PlayerRanks:Command_ResetRank(self)
            return true, "@rank_reset"
        end
    },

    -- ================================================================
    -- !TransferPP <Target> <Amount>
    {
        Name = "TransferPP",
        Access = ServerAccess_Lowest,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Required = true, Type = CommandArg_TypePlayer, NotSelf = true },
            { Name = "@amount", Desc = "@arg_amount_desc", Required = true, Type = CommandArg_TypeNumber, Minimum = 1 },
        },
        Properties = {
            GameRules = GameMode_PS,
            CoolDown = 10,
        },
        Function = function(self, hTarget, iAmount)
            local iPrestige = self:GetPrestige()
            if (iAmount > iPrestige) then
                return false, "@insufficientPrestige"
            end

            -- A player could connect with the same profile twice, transfer all their prestige to the second account,
            -- Disconnect with the first, then the second, then reconnect with both, and both now would have the same amount of prestige
            -- Doing this for a few times will grant them an unreasonably large amount of prestige
            -- Another way to fix or block this issue is to erase the stored prestige upon connecting to the server, but this works as well :)
            if (hTarget:GetProfileId() == self:GetProfileId()) then
                return false, "@duping_not_allowed"
            end

            local sTargetName = hTarget:GetName()
            g_gameRules:PrestigeEvent(hTarget, iAmount, "@gift_from", { Name = self:GetName() })
            g_gameRules:PrestigeEvent(self, -iAmount, "@transferred_to", { Name = sTargetName })
            return true, self:LocalizeText(("%d PP @transferred_to"):format(iAmount), { Name = sTargetName })
        end
    },

    -- ================================================================
    -- !Flare
    {
        Name = "Flare",
        Access = ServerAccess_Lowest,
        Arguments = {
        },
        Properties = {
            CoolDown = 120,
        },
        Function = function(self)
            Server.Utils:SpawnEffect((Server.Utils:GetCVar("e_time_of_day") <= 12 and Effect_FlareNight or Effect_Flare), self:GetPos())
        end
    },

    -- ================================================================
    -- !Firework
    {
        Name = "Firework",
        Access = ServerAccess_Lowest,
        Arguments = {
        },
        Properties = {
            CoolDown = 120,
        },
        Function = function(self)
            Server.Utils:SpawnEffect(Effect_Firework, self:GetPos())
        end
    },
})