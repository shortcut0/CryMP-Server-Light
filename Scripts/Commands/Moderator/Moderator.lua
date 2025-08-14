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
    -- !NextMap <Timer>
    {
        Name = "NextMap",
        Access = ServerAccess_Guest,
        Arguments = {
            { Name = "@arg_time/@arg_stop", Desc = "@arg_time_desc/@arg_stop_desc" }
        },
        Properties = {
            This = "Server.MapRotation"
        },
        Function = function(self, hPlayer, hOption)
            if (hOption == "show" or not hPlayer:HasAccess(ServerAccess_Moderator)) then
                return true, hPlayer:LocalizeText("@next_map", { Name = self:GetNextMapName() })
            end
            return self:Command_NextMap(hOption, hPlayer)
        end
    },

    -- ================================================================
    -- !Map <MapName> <Timer>
    {
        Name = "Map",
        Access = ServerAccess_Moderator,
        Arguments = {
            { Name = "@map", Desc = "@arg_map_desc" },
            { Name = "@arg_time/@arg_stop", Desc = "@arg_time_desc/@arg_stop_desc" }
        },
        Properties = {
            This = "Server.MapRotation"
        },
        Function = function(self, hPlayer, sMap, hOption)
            return self:Command_StartMap(hPlayer, sMap, hOption)
        end
    },

    -- ================================================================
    -- !RENAME <Target> <Name, ...>
    {
        Name = "rename",
        Access = ServerAccess_Moderator,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Required = true, Type = CommandArg_TypePlayer, AcceptAll = true },
            { Name = "@name",   Desc = "@arg_renameT_desc", Required = true, Type = CommandArg_TypeMessage },
        },
        Function = function(self, hTarget, sName)
            return Server.NameHandler:Command_Rename(self, hTarget, sName)
        end
    },

    -- ================================================================
    -- !Team <Target> <TeamId>
    {
        Name = "Team",
        Access = ServerAccess_Admin,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Required = true, Type = CommandArg_TypePlayer, AcceptSelf = true, AcceptAll = true,},
            { Name = "@team",   Desc = "@arg_team_desc",   Required = true, Type = CommandArg_TypeTeam,   DefaultEval = "return Player:GetTeam()" },
        },
        Properties = {
        },
        Function = function(self, hTarget, iTeam)

            local sTeamName = Server.Utils:GetTeam_String(iTeam)
            if (hTarget == ALL_PLAYERS) then
                for _, hVictim in pairs(Server.Utils.GetPlayers()) do
                    if (hVictim:GetTeam() ~= iTeam) then
                        hVictim:SetTeam(iTeam)
                        if (hVictim ~= self) then
                            Server.Chat:ChatMessage(ChatEntity_Server, hVictim, "@you_were_movedToTeam", { TeamName = sTeamName })
                        end
                    end
                end
                Server.Chat:ChatMessage(ChatEntity_Server, self, "@everyone_movedToTeam", { TeamName = sTeamName })
                return true
            end

            if (hTarget:GetTeam() == iTeam) then
                return false, self:LocalizeText("@already_inTeam", { Target = (hTarget == self and "@you_are" or hTarget:GetName()), TeamName = sTeamName })
            end

            if (hTarget ~= self) then
                Server.Chat:ChatMessage(ChatEntity_Server, hTarget, "@you_were_movedToTeam", { TeamName = sTeamName })
            else
                Server.Chat:ChatMessage(ChatEntity_Server, self, "@movedToTeam", { Target = "@you_were", TeamName = sTeamName })
            end

            hTarget:SetTeam(iTeam)
            return true
        end
    },
})