-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- Contains the Server-Side Handler for the Remote Client Script
-- ===================================================================================

Server:CreateComponent({
    Name = "ClientMod",
    Body = {

        Properties = {
            ClientScriptURL = "http://nomad.nullptr.one/~finch/CryMP-ServerClient.lua",
            MaxInstallAttempts = 999,

            -- Not in config please
            ObfuscateStackIds = false, -- edit: no reason to use this, can cause duped ids. let clients fake it, who cares.
        },

        CCommands = {
            { Name = "test_queue", FunctionName = "TestQueue", Description = "Adds various test scenarios to the code queue" },
            { Name = "clear_queue", FunctionName = "ClearGlobalQueue", Description = "Clears the entire Code Queue" },
        },

        Protected = {
            CodeStack = {
                LastId = 0,
                Stack = {},
            },
            CodeQueue = {
                Clients = {},
                Global  = {}
            },
        },

        PlayerModels = {
            Reset       = { ID = -1, Name = "Default" },
            Nomad       = { ID = 1,  Name = "Nomad",             Model = "objects/characters/human/us/nanosuit/nanosuit_us_multiplayer.cdf" },
            NanoGirl    = { ID = 2,  Name = "Nano Girl",         Model = "Objects/characters/woman/NanoSuit_Female/NanoSuit_Female.cdf" },

            -- Story squad
            Kyong       = { ID = 3,  Name = "General Kyong",     Team = GameTeam_NK, Model = "objects/characters/human/story/Kyong/Kyong.cdf" },
            Aztec       = { ID = 4,  Name = "Aztec",             Model = "objects/characters/human/story/Harry_Cortez/harry_cortez_chute.cdf" },
            Jester      = { ID = 5,  Name = "Jester",            Model = "objects/characters/human/story/Martin_Hawker/Martin_Hawker.cdf" },
            Sykes       = { ID = 6,  Name = "Sykes",             Model = "objects/characters/human/story/Michael_Sykes/Michael_Sykes.cdf" },
            Prophet     = { ID = 7,  Name = "Prophet",           Model = "objects/characters/human/story/Laurence_Barnes/Laurence_Barnes.cdf" },
            Psycho      = { ID = 8,  Name = "Psycho",            Model = "objects/characters/human/story/Michael_Sykes/Michael_Sykes_face.cdf" },
            Badowsky    = { ID = 9,  Name = "Badowsky",          Model = "objects/characters/human/story/badowsky/Badowsky.cdf" },
            ScienceGirl = { ID = 10, Name = "Scientist",         Model = "objects/characters/human/story/female_scientist/female_scientist.cdf" },
            Keegan      = { ID = 11, Name = "Keegan",            Model = "Objects/characters/human/story/keegan/keegan.cdf" },
            Bradley     = { ID = 12, Name = "Lt Bradley",        Model = "objects/characters/human/story/Lt_Bradley/Lt_Bradley_radio.cdf" },
            Richard     = { ID = 13, Name = "Richard Morrison",  Model = "objects/characters/human/story/Richard_Morrison/morrison_with_hat.cdf" },
            Rosenthal   = { ID = 14, Name = "Dr Rosenthal",      Model = "objects/characters/human/story/Dr_Rosenthal/Dr_Rosenthal.cdf" },
            Helena      = { ID = 15, Name = "Helena Rosenthal",  Model = "objects/characters/human/story/helena_rosenthal/helena_rosenthal.cdf" },

            -- Civilians / NPCs
            Journalist  = { ID = 16, Name = "Journalist",        Model = "objects/characters/human/story/Journalist/journalist.cdf" },
            GongPitter  = { ID = 17, Name = "Gong Pitter",       Model = "objects/characters/human/us/fire_fighter/green_cleaner.cdf" },
            JumpSailor  = { ID = 18, Name = "Jump Sailor",       Model = "objects/characters/human/us/jumpsuitsailor/jumpsuitsailor.cdf" },
            NavyPilot   = { ID = 19, Name = "Navy Pilot",        Model = "objects/characters/human/us/navypilot/navypilot.cdf" },
            NKPilot     = { ID = 20, Name = "Asian Pilot",       Team = GameTeam_NK, Model = "objects/characters/human/asian/pilot/koreanpilot.cdf" },
            Technician  = { ID = 21, Name = "Asian Technician",  Model = {
                "objects/characters/human/asian/technician/technician_01.cdf",
                "objects/characters/human/asian/technician/technician_02.cdf",
            }},
            ArchaeologistF = { ID = 22, Name = "Female Archaeologist", Model = {
                "objects/characters/human/us/archaeologist/archaeologist_female_01.cdf",
                "objects/characters/human/us/archaeologist/archaeologist_female_02.cdf",
            }},
            ArchaeologistM = { ID = 23, Name = "Male Archaeologist", Model = {
                "objects/characters/human/us/archaeologist/archaeologist_male_01.cdf",
                "objects/characters/human/us/archaeologist/archaeologist_male_02.cdf",
            }},
            Firefighter = { ID = 24, Name = "US Firefighter",       Model = {
                "objects/characters/human/us/fire_fighter/firefighter.cdf",
                "objects/characters/human/us/fire_fighter/firefighter_helmet.cdf",
                "objects/characters/human/us/fire_fighter/firefighter_silver.cdf",
                "objects/characters/human/us/fire_fighter/firefighter_silver_mask.cdf",
                "objects/characters/human/us/fire_fighter/firefighter_silver_maskvs2.cdf",
            }},
            Worker      = { ID = 25, Name = "US Deckhander",        Model = {
                "objects/characters/human/us/deck_handler/deck_handler_grape_helmet.cdf",
                "objects/characters/human/us/deck_handler/deckhand_blue.cdf",
                "objects/characters/human/us/deck_handler/deckhand_brown.cdf",
                "objects/characters/human/us/deck_handler/deckhand_grape.cdf",
                "objects/characters/human/us/deck_handler/deckhand_green.cdf",
                "objects/characters/human/us/deck_handler/deckhand_red.cdf",
                "objects/characters/human/us/deck_handler/deckhand_white.cdf",
                "objects/characters/human/us/deck_handler/deckhand_blue2.cdf",
                "objects/characters/human/us/deck_handler/deckhand_yellow.cdf",
                "objects/characters/human/us/deck_handler/deckhand_brown2.cdf",
                "objects/characters/human/us/deck_handler/deckhand_grape2.cdf",
                "objects/characters/human/us/deck_handler/deckhand_green2.cdf",
                "objects/characters/human/us/deck_handler/deckhand_red2.cdf",
                "objects/characters/human/us/deck_handler/deckhand_white2.cdf",
                "objects/characters/human/us/deck_handler/deckhand_yellow2.cdf",
            }},
            Officer     = { ID = 26, Name = "US Officer",           Team = GameTeam_US, Model = {
                "objects/characters/human/us/officer/officer_01.cdf",
                "objects/characters/human/us/officer/officer_02.cdf",
                "objects/characters/human/us/officer/officer_03.cdf",
                "objects/characters/human/us/officer/officer_04.cdf",
                "objects/characters/human/us/officer/officer_05.cdf",
                "objects/characters/human/us/officer/officer_afroamerican_01.cdf",
                "objects/characters/human/us/officer/officer_afroamerican_02.cdf",
                "objects/characters/human/us/officer/officer_afroamerican_03.cdf",
                "objects/characters/human/us/officer/officer_afroamerican_04.cdf",
                "objects/characters/human/us/officer/officer_afroamerican_05.cdf",
            }},
            Marine      = { ID = 27, Name = "US Marine",            Team = GameTeam_US, Model = {
                "objects/characters/human/us/marine/marine_01.cdf",
                "objects/characters/human/us/marine/marine_02.cdf",
                "objects/characters/human/us/marine/marine_03.cdf",
                "objects/characters/human/us/marine/marine_04.cdf",
                "objects/characters/human/us/marine/marine_05.cdf",
                "objects/characters/human/us/marine/marine_06.cdf",
                "objects/characters/human/us/marine/marine_07.cdf",
                "objects/characters/human/us/marine/marine_08.cdf",
                "objects/characters/human/us/marine/marine_09.cdf",
            }},
            CoronaGuy   = { ID = 28, Name = "COVID 19 Guy",        Model = {
                "objects/characters/human/asian/scientist/chinese_scientist_01.cdf",
                "objects/characters/human/asian/scientist/chinese_scientist_02.cdf",
                "objects/characters/human/asian/scientist/chinese_scientist_03.cdf",
            }},
            Korean      = { ID = 29, Name = "Korean Soldier",    Team = GameTeam_NK, Model = {
                "objects/characters/human/asian/nk_soldier/nk_soldier_camp_cover_heavy_04.cdf",
                "objects/characters/human/asian/nk_soldier/nk_soldier_camp_cover_heavy_05.cdf",
                "objects/characters/human/asian/nk_soldier/nk_soldier_camp_cover_heavy_07.cdf",
                "objects/characters/human/asian/nk_soldier/nk_soldier_camp_cover_heavy_09.cdf",
                "objects/characters/human/asian/nk_soldier/nk_soldier_camp_cover_light_01.cdf",
                "objects/characters/human/asian/nk_soldier/nk_soldier_camp_cover_light_02.cdf",
                "objects/characters/human/asian/nk_soldier/nk_soldier_camp_light_leader_04.cdf",
                "objects/characters/human/asian/nk_soldier/nk_soldier_camp_light_leader_02.cdf",
                "objects/characters/human/asian/nk_soldier/nk_soldier_camp_light_leader_03.cdf",
            }},

            -- Aliens / Animals
            Alien       = { ID = 30, Name = "Alien",             Model = "objects/characters/alien/alienbase/alienbase.cdf" },
            AlienWork   = { ID = 31, Name = "Alien Worker",      Model = "objects/characters/alien/alienbase/alienbase.cdf" },
            Hunter      = { ID = 32, Name = "Hunter",            Model = "objects/characters/alien/hunter/hunter.cdf" },
            Scout       = { ID = 33, Name = "Scout",             Model = "objects/characters/alien/scout/scout_leader.cdf" },
            Trooper     = { ID = 34, Name = "Alien Trooper",     Model = "objects/characters/alien/trooper/trooper_leader.chr" },
            Dog         = { ID = 35, Name = "Dog or sum",        Model = "Objects/characters/alien/trooper/trooper_base.chr" },
            Shark       = { ID = 36, Name = "Shark",             Model = "objects/characters/animals/Whiteshark/greatwhiteshark.cdf" },
            Chicken     = { ID = 37, Name = "Chicken",           Model = "objects/characters/animals/birds/chicken/chicken.chr" },
            Turtle      = { ID = 38, Name = "Turtle",            Model = "objects/characters/animals/turtle/turtle.cdf" },
            Crab        = { ID = 39, Name = "Crab",              Model = "objects/characters/animals/crab/crab.cdf" },
            Finch       = { ID = 40, Name = "Finch",             Model = "objects/characters/animals/birds/plover/plover.cdf" },
            Tern        = { ID = 41, Name = "Tern",              Model = "Objects/characters/animals/birds/tern/tern.chr" },
            Frog        = { ID = 42, Name = "Frog",              Model = "objects/characters/animals/frog/frog.chr" },
            Butterfly   = { ID = 43, Name = "Butterfly",         Model = "objects/characters/animals/insects/butterfly/butterfly_brown.chr" },

            -- Specials
            Snowman     = { ID = 44, Name = "Snowman",           Model = "Objects/characters/snowman/snowman.cdf" },
            Headless    = { ID = 45, Name = "Headless",          Model = "Objects/characters/nomad/headless.cdf" },
        },

        Responses = {
            ClientInstalled = 10,
        },

        Initialize = function(self)
            self.Properties.ClientScriptURL = Server.Config:Get("Network.RemoteClientScript.URL", self.Properties.ClientScriptURL, ConfigType_String)
            self.Properties.MaxInstallAttempts = Server.Config:Get("Network.RemoteClientScript.MaxInstallAttempts", self.Properties.MaxInstallAttempts, ConfigType_Number)
        end,

        PostInitialize = function(self)
        end,

        OnReset = function(self)
            self:ClearGlobalQueue()
        end,

        IsComponentEnabled = function(self)
            return true
        end,

        ClearGlobalQueue = function(self)

            self:Log("Clearing Queue..")
            self.CodeQueue = {
                Clients = {},
                Global  = {}
            }
        end,

        TestQueue = function(self)

            local hEntity = Server.Utils:SpawnEntity({
                class = "RadarKit",
                position = Vector.Empty(),
                orientation = Vector.Up(),
                name = "test_clientModQueue"
            })

            self:QueueGlobalCode({
                Code = "System.LogAlways('error1')",
                Sync = {
                    BoundID = hEntity.id,
                    SyncID = "custom_id",
                }
            })

            System.RemoveEntity(hEntity.id)
            self:QueueGlobalCode({
                Code = "System.LogAlways('error2')",
                Sync = {
                    BoundID = hEntity.id,
                }
            })

            self:QueueGlobalCode({
                Code = "System.LogAlways('error3')",
                Sync = {
                }
            })

        end,

        PrepCode = function(self, sCode)
            local hId = (self.CodeStack.LastId + 1)
            if (self.Properties.ObfuscateStackIds) then
                hId = hId + math.random(66666, 77777)
            end
            self.CodeStack.LastId = hId

            --self.CodeStack[hId] = {
            table.insert(self.CodeStack.Stack, {
                ID      = hId,
                Code    = sCode,
                Trace   = debug.traceback() or "<Unknown>",
                Source  = LuaUtils.TraceSource(2):gsub("^%s+", ""):gsub("^%.+\\?", ""), -- skip the last two internal levels
                Time    = os.clock()
            })

            if (#self.CodeStack.Stack >= 255) then
                table.remove(self.CodeStack.Stack, 1)
            end

            return string.format("lua:%06d:%s", hId, sCode)
        end,

        QueueCode = function(self, hClientId, sCode)
            self.CodeQueue.Clients[hClientId] = self.CodeQueue.Clients[hClientId] or {}
            table.insert(self.CodeQueue.Clients[hClientId], sCode)
        end,

        QueueGlobalCode = function(self, tInfo)

            local tSync = tInfo.Sync
            if (not tSync) then
                return
            end

            local tGlobalStorage = self.CodeQueue.Global
            local hBoundID = tSync.BoundID or NULL_ENTITY
            if (tGlobalStorage[hBoundID] == nil) then
                tGlobalStorage[hBoundID] = {}
            end

            local hSyncID = (tSync.SyncID or ("Sync_" .. Server.Utils:UpdateCounter("ClientModGlobalSyncIndex")))
            tGlobalStorage[hBoundID][hSyncID] = {
                Client = tInfo.Code,
                Server = tInfo.Server,
                Predicate = tInfo.Predicate
            }

            DebugLog("index=",hSyncID)
        end,

        FindStackedCode = function(self, hId)
            for _, tStack in pairs(self.CodeStack.Stack) do
                if (tStack.ID == hId) then
                    return tStack
                end
            end
        end,

        OnRemoteError = function(self, hClient, hId, sError)

            self:LogError("Client %s{Red} Encountered a Script Error", hClient:GetName())
            self:LogError("> %s", sError or "<Null>")

            local tCode = self:FindStackedCode(hId)
            if (not tCode) then
                self:LogError("Failed to find Stack for Code %d")
                self:LogError("%s", sError or "<Null>")
                return
            end

            self:LogError("Stack ID: %d", tCode.ID)
            self:LogError("Source: %s", tCode.Source)
        end,

        ExecuteCodeOnClient = function(self, hClient, sCode, bSkipQueuing)


            if (hClient.ClientMod.InstallFailed) then
                self:LogError("Ignoring Client %s", hClient:GetName())
                return
            elseif (not hClient.ClientMod.IsInstalled) then
                if (not bSkipQueuing) then
                    self:QueueCode(hClient.id, sCode)
                    self:LogWarning("Queued Code for Client %s", hClient:GetName())
                end
                return
            end

            Server.Statistics:Event(StatisticsEvent_ClientDataSent, #sCode)
            g_gameRules.onClient:ClWorkComplete(hClient:GetChannel(), hClient.id, sCode)
            self:Log("ToClient %s",sCode)
        end,

        ExecuteCode = function(self, tCode)

            local sCode, hId = self:PrepCode(tCode.Code)
            local tClients = tCode.Clients or tCode.Client
            if (not tClients) then
                self:LogError("No Clients to Execute Code on! Assuming All")
                tClients = ALL_PLAYERS
            end

            if (tClients == ALL_PLAYERS) then
                tClients = Server.Utils:GetPlayers()
            elseif (not table.IsRecursive(tClients)) then
                tClients = { tClients }
            end
            for _, hClient in pairs(tClients) do
                self:ExecuteCodeOnClient(hClient, sCode, tCode.NoQueue)
            end

            if (tCode.Sync) then
                tCode.Code = sCode
                self:QueueGlobalCode(tCode)
            end
        end,

        OnInstalled = function(self, hClient)
            self:LogEvent({
                Message = "@clientMod_installedOn",
                MessageFormat = { Client = hClient:GetName(), Time = Date:Colorize(Date:Format(hClient.ClientMod.LastInstall.Diff())) },
                Recipients = ServerAccess_Admin,
            })
            hClient.ClientMod.IsInstalled = true

            self:SyncQueue(hClient)
            self:ExecuteCode({
                Code = ([[CryMP_Client:GET_INFO("%s","%s")]]):format(hClient.TempData.UUIDCheck, "CryMP"),
                Client = hClient
            })

            if (hClient:IsValidated()) then
                self:SyncData(hClient)
            else
                hClient.ClientMod.DataSyncQueued = true
            end
        end,

        SyncData = function(self, hClient)
            local iOldCM = hClient.Data.LastCMId
            if (iOldCM and not hClient.ClientMod.CurrentCM) then
                local tModel = self:FindModelById(iOldCM)
                if (tModel) then
                    self:Command_RequestModel(hClient, tModel, true)
                end
            end
        end,

        DeleteSync = function(self, hEntityId, sSyncId)
            if (sSyncId == nil) then
                self.CodeQueue.Global[hEntityId] = nil
            else
                self.CodeQueue.Global[hEntityId][sSyncId] = nil
            end
        end,

        SyncQueue = function(self, hClient)

            local iSyncedCount = 0
            local tClientQueue = self.CodeQueue.Clients[hClient.id]
            for _, sCode in pairs(tClientQueue or {}) do
                iSyncedCount = iSyncedCount + 1
                self:ExecuteCodeOnClient(hClient, sCode)
            end
            self.CodeQueue.Clients[hClient.id] = nil

            local tGlobalQueue = self.CodeQueue.Global
            for hBoundID, tStack in pairs(tGlobalQueue) do
                local hBoundEntity = Server.Utils:GetEntity(hBoundID)
                local sBoundEntityName = (hBoundEntity and hBoundEntity:GetName() or "GLOBAL")

                    if (hBoundID ~= NULL_ENTITY and hBoundEntity == nil) then
                        tGlobalQueue[hBoundID] = nil
                        self:Log("Removed Invalid Entity from Global Sync Queue")
                    else
                        self:Log("Synchronizing Stack for Entity '%s'", sBoundEntityName)
                        for hSyncID, tCode in pairs(tStack) do

                            tCode.SyncedOn = (tCode.SyncedOn or {})
                            if (not tCode.SyncedOn[hClient.id]) then
                                tCode.SyncedOn[hClient.id] = true

                                local fPredicate = tCode.Predicate
                                local bPredicateOk = true
                                if (fPredicate ~= nil) then
                                    local tParams = {}
                                    if (hBoundEntity) then
                                        tParams = { hBoundEntity }
                                    end
                                    table.insert(tParams, hClient)
                                    local bOk, hReturnOrError = pcall(fPredicate, unpack(tParams))
                                    if (not bOk) then
                                        self:LogError("Failed to Execute Predicate for Entity '%s' for SyncID '%s'", sBoundEntityName, tostring(hSyncID))
                                        self:LogError("%s", (hReturnOrError or "<Null>"))
                                    elseif (not hReturnOrError) then
                                        tStack[hSyncID] = nil
                                        bPredicateOk = false
                                        self:Log("Predicate failed for SyncID '%s' for Entity '%s', Discarding..", tostring(hSyncID), sBoundEntityName)
                                    end
                                end
                                if (bPredicateOk) then
                                    iSyncedCount = iSyncedCount + 1
                                    self:ExecuteCodeOnClient(hClient, tCode.Client)
                                    if (tCode.Server) then
                                        error("implementation missing.")
                                    end
                                end
                            else
                                self:Log("Code already Synced on Client '%s'", hClient:GetName())
                            end
                        end
                    end
            end

            if (iSyncedCount > 0) then
                self:LogEvent({ Recipients = ServerAccess_Admin, Message = "@clientMod_synched", MessageFormat = { Items = iSyncedCount }})
            end
        end,

        InstallMod = function(self, hClient, bResetAttempts)


            if (not self:IsComponentEnabled()) then
                return
            end

            local iAttempt = hClient.ClientMod.InstallAttempts
            if (bResetAttempts) then
                iAttempt = 0
            end

            self:Log("Installing on '%s'", hClient:GetName())
            self:LogEvent({
                Message = "@clientMod_installingOn" .. (iAttempt > 0 and (" (@attempt $4%d$9 \\ $4%d$9)"):format(iAttempt, self.Properties.MaxInstallAttempts) or ""),
                MessageFormat = { Client = hClient:GetName() },
                Recipients = ServerAccess_Admin,
            })

            hClient.ClientMod.IsInstalled     = false
            hClient.ClientMod.InstallAttempts = (iAttempt + 1)
            hClient.ClientMod.LastInstall.Refresh()

            RPC:OnPlayer(hClient, "Execute", { url = self.Properties.ClientScriptURL });
        end,

        Event_OnActorSpawn = function(self, hClient)

            hClient.ClientMod = {
                IsInstalled     = false,
                InstallFailed   = false,
                InstallAttempts = 0,
                LastInstall     = TimerNew(10),
            }

            if (not hClient.IsPlayer) then
                return
            end
            self:InstallMod(hClient)
        end,

        Event_TimerSecond = function(self)

            for _, hClient in pairs(Server.Utils:GetPlayers()) do
                if (not hClient.ClientMod.IsInstalled) then
                    if (hClient.ClientMod.InstallAttempts <= self.Properties.MaxInstallAttempts) then
                        if (hClient.ClientMod.LastInstall.Expired()) then
                            self:InstallMod(hClient)
                        end
                    else
                        hClient.ClientMod.InstallFailed = true
                    end
                else
                    if (hClient:IsValidated() and hClient.ClientMod.DataSyncQueued) then
                        self:SyncData(hClient)
                        hClient.ClientMod.DataSyncQueued = false
                    end
                end
            end

            --test stack finder
            --self:ExecuteCode({Code = "ERROR()"})
        end,

        Event_RequestSpectatorTarget = function(self, hClient, iRequest)

            if ((iRequest <= 3 and iRequest >= -3) or not self:IsComponentEnabled()) then
                return true
            end

            local tResponses = self.Responses
            if (iRequest == tResponses.ClientInstalled) then
                self:OnInstalled(hClient)
            else
                return true
            end
            return false
        end,

        FindModelById = function(self, iCM)
            for _, tModel in pairs(self.PlayerModels) do
                if (tModel.ID == iCM) then
                    return tModel
                end
            end
            -- ...
        end,

        ResetModel = function(self, hClient)

            hClient.ClientMod.CurrentCM = nil
            hClient.ClientMod.CurrentCMPath = nil
            hClient.Data.LastCMId = nil

            self:DeleteSync(hClient.id, "CM")

            local sUS = g_gameRules:GetPlayerModel(hClient, GameTeam_US) --g_gameRules.teamModel.black[1][1]
            local sNK = g_gameRules:GetPlayerModel(hClient, GameTeam_NK) --g_gameRules.teamModel.tan[1][1]

            g_gameRules.game:SetSynchedEntityValue(hClient.id, GlobalKeys.PlayerModel, sUS)
            g_gameRules.game:SetSynchedEntityValue(hClient.id, GlobalKeys.PlayerModelUS, sUS)
            g_gameRules.game:SetSynchedEntityValue(hClient.id, GlobalKeys.PlayerModelNK, sNK)

            if (hClient:IsAlive()) then
                Server.Utils:RevivePlayer(hClient, hClient:GetPos())
            end
        end,

        GetModelGreet = function(self, tModel)

            local aRng = {"01", "02", "03", "04", "05",}
            local sFile = "greets_"
            local sPath = "ai_marine_1/"

            if (tModel == self.PlayerModels.Kyong) then -- or c == 2
                sPath = "ai_kyong/"
                sFile = "aidowngroup_"
                aRng = {"04", "05",}

            elseif (tModel == self.PlayerModels.Korean) then
                sPath = "ai_korean_soldier_3/"
                sFile = "contactsoloclose_"
                aRng = {"01", "02", "03", "04", "05",}

            elseif (tModel == self.PlayerModels.Jeser) then
                sPath = "ai_jester/"
                aRng = {"01", "02", "03", "04", "05",}

            elseif (tModel == self.PlayerModels.Psycho) then
                sPath = "ai_psycho/"
                sFile = "contactsoloclose_"
                aRng = {"01",}

            elseif (tModel == self.PlayerModels.Prophet) then
                sPath = "ai_prophet/"
                aRng = {"00", "04",}

            elseif (tModel == self.PlayerModels.Marine) then
                sPath = "ai_marine_1/"
                aRng = {"01", "02", "03", "04", "05",}
            end
            local sFilePath = "languages/dialog/" .. sPath .. sFile .. table.Random(aRng) .. ".mp2"
            return sFilePath
        end,

        SetModel = function(self, hClient, tModelInfo)

            local sPath = tModelInfo.Model
            if (IsArray(sPath)) then
                sPath = sPath[math.random(#sPath)]
            end

            hClient.ClientMod.CurrentCM = tModelInfo.ID
            hClient.ClientMod.CurrentCMPath = sPath
            hClient.Data.LastCMId = tModelInfo.ID

            self:ExecuteCode({
                Code = ("CryMP_Client:Log('hi')CryMP_Client:Log('hi')CryMP_Client:Log('hi')CryMP_Client:Log('hi')local x=CryMP_Client:GP(%d)if(not x)then return;end;x.CM=%d;x.CM_P='%s';if(x.actor:GetHealth()>0)then x.actor:Revive()end"):format(hClient:GetChannel(), tModelInfo.ID, sPath),
                Clients = ALL_PLAYERS,
                Sync = {
                    BoundID = hClient.id,
                    SyncID = "CM"
                }
            })

            DebugLog(sPath)
            g_gameRules.game:SetSynchedEntityValue(hClient.id, GlobalKeys.PlayerModel, sPath)
            g_gameRules.game:SetSynchedEntityValue(hClient.id, GlobalKeys.PlayerModelNK, sPath)
            g_gameRules.game:SetSynchedEntityValue(hClient.id, GlobalKeys.PlayerModelUS, sPath)

            if (hClient:IsAlive()) then
                Server.Utils:RevivePlayer(hClient, hClient:GetPos())
            end
        end,

        GetInstantActionModel = function(self, hClient)
        end,

        Command_RequestModel = function(self, hClient, iCM, bQuiet)

            if (type(iCM) == "table") then
                iCM = iCM.ID
            end

            local bReset = (iCM == -1)
            local iCurrentCM = hClient.ClientMod.CurrentCM
            local tCurrentCM = self:FindModelById(iCurrentCM)
            local tModelInfo = self:FindModelById(iCM)

            if (iCurrentCM == iCM) then
                return false, hClient:LocalizeText("@choose_different_cm", { Name = tCurrentCM.Name })

            elseif (bReset) then
                if (iCurrentCM == nil) then
                    return false, "@you_have_noCM"
                end

                self:ResetModel(hClient)
                return true, "@cm_removedCl"

            elseif (not tModelInfo) then

                local aDisplayModels = {}
                for _, tModel in pairs(self.PlayerModels) do
                    aDisplayModels[tModel.ID] = { tModel.Name, tModel.Model }
                end
                Server.Utils:ListToConsole({
                    Client      = hClient,
                    List        = aDisplayModels,
                    Title       = hClient:LocalizeText("@custom_models"),
                    ItemWidth   = 20.2,
                    PerLine     = 4,
                    PrintIndex  = true,
                    Index       = 1
                })
                return true, hClient:LocalizeText("@entitiesListedInConsole", { Class = "@custom_models", Count = table.count(self.PlayerModels) })
            end

            local iTeam = hClient:GetTeam()
            if (g_gameRules.IS_PS) then
                local iModelTeam = tModelInfo.Team
                if (iModelTeam and iModelTeam ~= iTeam) then
                    return false, hClient:LocalizeText("@cm_reservedForTeam", { TeamName = Server.Utils:GetTeam_String(iModelTeam) })
                end
            end

            self:SetModel(hClient, tModelInfo)
            if (not bQuiet) then
                local sVoice = self:GetModelGreet(tModelInfo)
                if (sVoice) then
                    self:ExecuteCode({
                        Code = ([[CryMP_Client:PSE(%d,"%s")]]):format(hClient:GetChannel(), sVoice),
                        Clients = ALL_PLAYERS
                    })
                end
                Server.Chat:ChatMessage(ChatEntity_Server, ALL_PLAYERS, "@cm_activated", { Name = hClient:GetName(), ModelName = tModelInfo.Name })
            end

            return true
        end,
    }
})