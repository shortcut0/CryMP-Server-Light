-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- This Plugin Handles persistent Scores
-- ===================================================================================

Server.Plugins:CreatePlugin("PersistentScore", {

    -- Used for console logging // "Plugin(PersistentScore) : Test Message"
    PluginName = "PersistentScore", -- If empty, will use the plugin identifier as name
    PluginFriendlyName = "Score", -- A shorter, more user-friendly name which will be used instead of the PluginName field
    
    -- Disable/Enable the plugin here
    PluginStatus = true,

    -- External Data
    ExternalData = {
        { Key = "PermaScore", Name = "PermaScore.lua", Path = (SERVER_DIR_DATA .. "Users\\") },
        { Key = "PersistentScore", Name = "PersistentScore.lua", Path = (SERVER_DIR_DATA .. "Users\\") },
    },

    -- Persistent data kept and secured during script-reloads
    Protected = {
        PermaScore = {},
        PersistentScore = {
            MapSpecific = {},
            Global = {},
        }
    },

    -- Plugin Config
    PluginConfig = {

        --- Config Values default to 'Plugins.<PluginName>.', to use global values, you can put a '$' at the start of the Config Value
        --- Like so:
        --- { Config = "$Network.CVars"             Key = "$Direct_Member_Key_Not_Inside_Config_Table"

        { Config = "SaveScoreForEachMap",        Key = "SaveScoreForEachMap",           Default = false },
        { Config = "DeletePersistentScoreAfter", Key = "DeletePersistentScoreAfter",    Default = ONE_WEEK },
        { Config = "ResetScoreOnMapEnd",         Key = "ResetScoreOnMapEnd",            Default = true },
    },

    -- Called when the plugin is being loaded
    Initialize = function(self)
        --self:InitWithConfig()
        self:AddCommands()
        self:AddLocalizations()
    end,
    
    -- Called during post-initialization (when GameRules entity has spawned)
    PostInitialize = function(self)
    end,

    -- Pointer to the PermaScore data table
    GetPermaScore = function(self, hId)
        if (hId) then
            return self.PermaScore[hId]
        end
        return self.PermaScore
    end,

    -- An empty table serving as a preset or template
    GetEmptyScore = function(self, sID)
        return {

            ID = sID,

            XP = 0,
            PP = 0,
            Rank = 0,

            Kills = 0,
            Deaths = 0,
            Headshots = 0
        }
    end,

    -- Pointer to the PersistentScore data table
    GetScore = function(self, hId)

        local tScore = self.PersistentScore.Global
        if (self.Config.SaveScoreForEachMap) then
            local sMapPath = Server.MapRotation:GetMapPath():lower()
            if (not self.PersistentScore[sMapPath]) then
                self.PersistentScore[sMapPath] = {}
            end
            tScore = self.PersistentScore[sMapPath]
        end

        if (hId) then
            return tScore[hId]
        end
        return tScore
    end,

    -- Resets a players PERMA score
    ResetPermaScore = function(self, hPlayer, sReason)

        local tScore = self:GetPermaScore(hPlayer)
        if (not tScore) then
            return
        end

        self:GetPermaScore()[tScore.ID] = nil
        self:LogEvent({
            Message = "@event_playerPermaScoreReset",
            MessageFormat = { Reason = (sReason and ("(%s)"):format(sReason) or "") }
        })
    end,

    -- Resets a players persistent score
    ResetScore = function(self, hPlayer, sReason, bQuiet)

        local tScore = self:GetScore(hPlayer)
        if (not tScore) then
            return
        end

        self:GetScore()[tScore.ID] = nil
        if (not bQuiet) then
            self:LogEvent({
                Message = "@event_playerScoreReset",
                MessageFormat = { Reason = (sReason and ("(%s)"):format(sReason) or "") }
            })
        end
    end,

    -- Called when a new map is being loaded
    Event_OnMapCommand = function(self)

        if (not self.Config.ResetScoreOnMapEnd) then
            self:Log("Keeping Score from Current Map")
            return
        end

        self:Log("Resetting Scores..")
        for _, pActor in pairs(Server.Utils:GetPlayers()) do
            self:ResetScore(pActor, nil, true) -- No Reason, Quiet
        end
    end,

    -- Called every second
    Event_TimerSecond = function(self)

    end,

    -- Called when a player gets initialized (spawned)
    Event_OnActorSpawn = function(self, pActor)
    end,

    -- Called when a player disconnects
    Event_OnClientDisconnect = function(self, pClient)

        if (not pClient:IsValidated()) then
            return
        end

        local sProfile = pClient:GetProfileId()

        local tScore = self:GetScore()
        local tUserScore = tScore[sProfile]
        if (not tUserScore) then
            tScore[sProfile] = self:GetEmptyScore(sProfile)
            tUserScore = tScore[sProfile]
        end

        local pGR = g_gameRules
        if (pGR.IS_PS) then
            tUserScore.PP = pGR:GetPlayerPrestige(pClient.id)
            tUserScore.XP = pGR:GetPlayerXP(pClient.id)
            tUserScore.Rank = pGR:GetPlayerRank(pClient.id)
        end

        tUserScore.Kills = pGR:GetKills(pClient.id)
        tUserScore.Deaths = pGR:GetDeaths(pClient.id)
        tUserScore.Headshots = pGR:GetHeadshots(pClient.id)

        local sMap = ""
        if (self.Config.SaveScoreForEachMap) then
            sMap = (" @for_map {Red}%s"):format(Server.MapRotation:GetMapName():upper())
        end

        self:LogEvent({
            Message = "@scoreSaved",
            MessageFormat = {
                Name = pClient:GetName(),
                Extra = sMap
            }
        })
    end,

    -- Called when a players profile has been validated
    Event_OnProfileValidated = function(self, pActor, sProfile)

        local tScore = self:GetScore()
        local tUserScore = tScore[sProfile]
        if (not tUserScore) then
            tScore[sProfile] = self:GetEmptyScore(sProfile)
            self:Log("No score for '%s' found", sProfile)
            return -- Don't restore an empty score
        end

        local pGR = g_gameRules
        if (pGR.IS_PS) then
            local iPP = tUserScore.PP
            local iXP = tUserScore.XP
            local iRank = tUserScore.Rank

            local sPrefix = ""
            if (self.Config.SaveScoreForEachMap) then
                sPrefix = ("%s: "):format(Server.MapRotation:GetMapName():upper())
            end
            pGR:SetPlayerRank(pActor.id, iRank)
            pGR:PrestigeEvent(pActor, { iPP, iXP }, sPrefix .. "@score_Restored")
        end

        local iKills = tUserScore.Kills
        local iDeaths = tUserScore.Deaths
        local iHeadshots = tUserScore.Headshots
        pGR:SetKills(pActor.id, iKills)
        pGR:SetDeaths(pActor.id, iDeaths)
        pGR:SetHeadshots(pActor.id, iHeadshots)

        self:LogEvent({
            Message = "@scoreRestored",
            MessageFormat = {
                Name = pActor:GetName(),
                Extra = "" -- TODO
            }
        })
    end,

    -- Add new plugin-related chat commands
    AddCommands = function(self)

        local pCommands = Server.ChatCommands

        -- ===========================================
        -- !Reset
        pCommands:Add({
            Name = "Reset",
            Description = "@command_resetScore_desc",
            Arguments = {
                { Name = "@arg_resetAll", Desc = "@arg_resetAll_Desc", Type = CommandArg_TypeBoolean }
            },
            Properties = {
                CoolDown = 10,
                This = self,
            },
            Function = function(this, hUser, bResetAll)

                local pGR = g_gameRules
                if (not pGR.IS_PS) then
                    bResetAll = false -- Not possible outside of PS anyway
                end

                pGR.game:SetSynchedEntityValue(hUser.id, pGR.SCORE_KILLS_KEY, 0)
                pGR.game:SetSynchedEntityValue(hUser.id, pGR.SCORE_DEATHS_KEY, 0)
                pGR.game:SetSynchedEntityValue(hUser.id, pGR.SCORE_HEADSHOTS_KEY, 0)

                if (bResetAll) then
                    pGR:SetPlayerCP(hUser.id, 0)
                    pGR:SetPlayerPP(hUser.id, 100) -- FIXME: function to get actual spawn-prestige
                    pGR:SetPlayerRank(hUser.id, GameRank_PVT)
                end

                -- Persistent Score
                this:ResetScore(hUser)

                Server.Chat:ChatMessage(ChatEntity_Server, hUser, "@resetScore_ChatInfo", { Extended = (bResetAll and "@resetScoreExtended_ChatInfo" or "")})
                return true
            end
        })

        -- ===========================================
        -- !ResetPermaScore
        pCommands:Add({
            Name = "ResetPermaScore",
            Description = "@command_resetPermaScore_desc",
            Arguments = {
            },
            Properties = {
                CoolDown = 10,
                This = self,
            },
            Function = function(this, hUser)
                this:ResetPermaScore(hUser)
                Server.Chat:ChatMessage(ChatEntity_Server, hUser, "@resetPermaScore_ChatInfo")
                return true
            end
        })
    end,

    -- Add new locale strings
    AddLocalizations = function(self)

        -- TODO: Move these to a locale file, for the sake of the translators
        local pLocale = Server.LocalizationManager

        pLocale:Add({
            -- =====================================
            -- Commands
            { String = "command_resetScore_desc",
              Languages = {
                  English = "Resets your Current Score"
              }
            },
            { String = "command_resetPermaScore_desc",
              Languages = {
                  English = "Resets your Perma-Score"
              }
            },

            -- =====================================
            -- Event Logs
            { String = "event_playerScoreReset",
              Languages = {
                  English = "{Red}{Name}{Gray} Has Reset their {Red}Score{Gray} {Gray}{Reason}"
              }
            },
            { String = "event_playerPermaScoreReset",
              Languages = {
                  -- PirateSoftware's PERMA Score has been Reset (Admin Decision: Hes out of mana)
                  English = "{Red}{Name}{Gray}'s Red}PERMA Score{Gray} has been Reset {Gray}{Reason}"
              }
            },

            -- =====================================
            -- Others
            { String = "score_Restored",
              Languages = {
                  English = "Score Restored"
              }
            },
            { String = "scoreRestored",
              Languages = {
                  English = "Restored Score for {Red}{Name}{Gray}{Extra}"
              }
            },
            { String = "scoreSaved",
              Languages = {
                  English = "Saved Score for {Red}{Name}{Gray}{Extra}"
              }
            },

            -- =====================================
            -- Chat Messages
            { String = "resetScore_ChatInfo",
              Languages = {
                  English = "Your Score{Extended} has been Reset!"
              }
            },
            { String = "resetScoreExtended_ChatInfo",
              Languages = {
                  English = ", Rank, and Prestige"
              }
            },
            { String = "resetPermaScore_ChatInfo",
              Languages = {
                  English = "Your Perma-Score has been Reset"
              }
            },
        })
    end,

    -- Log Abstracts are automatically created, functions are
    -- Log
    -- LogDirect (directly into server console, skipping script log events)
    -- LogError
    -- LogWarning
    -- LogFatal
    -- LogDebug
    -- LogEvent

})