-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
--               This is the Server Chat Receiver & Seconder Component
-- ===================================================================================

Server:CreateComponent({
    Name = "Chat",
    Body = {

        CCommands = {
            { Name = "test_chat", FunctionName = "TestAll", Description = "Tests all possible Chat-Type Scenarios"}
        },

        Properties = {

            -- Examples of how it will look!

            -- Nomad0 (TEAM) : did i mention that i worked at blizzard for 7 years?
            --        Nomad1 : Pirate why are you running bro
            --   Nomad0 (PM) : Im out of Mana!

            ConsoleChatOffset              = 28,
            ConsoleChatMessageColor        = CRY_COLOR_WHITE,
            ConsoleChatMessageTeamTagColor = CRY_COLOR_BLUE,    -- (TEAM)
            ConsoleChatMessagePMTagColor   = CRY_COLOR_MAGENTA, -- (PM)
            ConsoleChatMessageSenderColor  = CRY_COLOR_WHITE,   -- Nomad : Hi!

            ChatMessageTags = {
                Status = false,
                And = {
                    { Status = true, Tag = "Coords: {Coords}", Type = ChatToTeam }
                },
                Or = {
                    { Tag = "SPEC",     Condition = "IsSpectating" },
                    { Tag = "DEAD",     Condition = "IsDead" },
                    { Tag = "LAG",      Condition = "IsLagging" },
                    { Tag = "TESTING",  Condition = "IsTesting" },
                    { Tag = "GOD",      Condition = "HasGodMode" },
                    { Tag = "DEV",      Condition = "IsDeveloper" },
                    { Tag = "ADMIN",    Condition = "IsAdmin" },
                    { Tag = "VIP",      Condition = "IsPremium" },
                },
            },

            ConsoleLogMessageColor      = CRY_COLOR_GRAY,
            ConsoleLogClassColor        = CRY_COLOR_GRAY,
            ConsoleLogTagDefaultColor   = CRY_COLOR_RED,
            ConsoleLogClassOffset = 28,
            ConsoleMaxLength = 113,
        },

        -- Class(Tag) : Message
        ConsoleLogClasses = {
            [ServerLogEvent_ScriptDebug] = {
                Class = "System",
                Tag = "Script-Debug",
            },
            [ServerLogEvent_ScriptError] = {
                Class = "System",
                Tag = "Script-Error",
            },
            [ServerLogEvent_ScriptFatal] = {
                Class = "System",
                Tag = "Script-Error",
            },
            [ServerLogEvent_ScriptWarning] = {
                Class = "System",
                Tag = "Script-Warning",
                TagColor = CRY_COLOR_YELLOW
            },
        },

        DefaultConsoleLogClass = {
            Class = "System",
            Tag = "CryMP"
        },

        TextMessageSpam = {
            TextMessageError,
            TextMessageServer,
            TextMessageInfo,
            TextMessageCenter,
            TextMessageConsole,
        },

        Protected = {
            ChatEntities = {},
        },

        Initialize = function(self)
            for _, aComponentInfo in pairs(Server.ComponentList) do

                local aComponent = Server[aComponentInfo.Name]
                local sComponent = aComponent.Name
                local aConsoleLogInfo = (Server[sComponent].ConsoleLogClass or {
                    Class = "System",
                    Tag = aComponent:GetFriendlyName(),
                    TagColor = self.Properties.ConsoleLogTagDefaultColor
                })
                self.ConsoleLogClasses[sComponent] = aConsoleLogInfo
            end
            self:Log("Created Default Log Classes for %d Components", table.count(Server.ComponentList))
        end,

        PostInitialize = function(self)


        end,

        GetConsoleWidth = function(self)
            return self.Properties.ConsoleMaxLength
        end,

        GetConsoleLogClass = function(self, sClass)
            return self.ConsoleLogClasses[sClass]
        end,

        TestAll = function(self)

            local hPlayerOne = Server.Utils:GetPlayers()[1] or Server:GetEntity()
            self:ChatMessage(Server:GetEntity(), ChatType_ToAll, "Spam!!!")
            for i=1, 10 do
                self:ChatMessage(Server:GetEntity(), ChatType_ToAll, "Spam!!!")
                self:TextMessage(ChatType_Error, ChatType_ToAll, "Spam!!!")
                self:ConsoleMessage(ChatType_Console, hPlayerOne, "PLAYER ONE!!!")
                self:ConsoleMessage(ChatType_Console, hPlayerOne, "PLAYER ONE!!!", {}, "System")
            end
            self:TextMessage(ChatType_Info, hPlayerOne, "hello in chat !")

        end,

        ChatMessage = function(self, pSender, pTarget, sMessage, tFormat)

            local hSender = Server.Utils:GetEntity(pSender)
            if (not Server.Utils:IsEntity(hSender)) then
                hSender = self:GetChatEntity(pSender)
            end

            if (not hSender) then
                Server.Logger:Log("Bad Sender Specified to ChatMessage(): %s", ToString(pSender))
                return
            end

            local iTeamId = ((IsString(pTarget) or (IsAny(pTarget, GameTeam_Neutral, GameTeam_NK, GameTeam_NK))) and Server.Utils:GetTeam_Number(pTarget))
            if (not iTeamId and pTarget == ChatType_ToTeam) then
                iTeamId = Server.Utils:GetTeamId(pSender)
            end

            if (iTeamId) then
                for _, hTarget in pairs(Server.Utils:GetPlayers({ ByTeam = iTeamId })) do
                    g_gameRules.game:SendChatMessage(ChatToTarget, hSender.id, hTarget.id, (Server.LocalizationManager:LocalizeForPlayer(hTarget, sMessage, tFormat)))
                end
                return --self:SendMessageToTeam(pSender, iTeamId, sMessage)

            elseif (pTarget == ChatType_ToAll) then
                for _, hTarget in pairs(Server.Utils:GetPlayers()) do
                    g_gameRules.game:SendChatMessage(ChatToTarget, hSender.id, hTarget.id, (Server.LocalizationManager:LocalizeForPlayer(hTarget, sMessage, tFormat)))
                end
                return --self:SendMessageToAll(pSender, sMessage)

            end
            local aTargetList = {}
            if (IsArray(pTarget) and pTarget.id) then
                aTargetList[1] = Server.Utils:GetEntity(pTarget)
            elseif (table.IsRecursive(pTarget)) then
                aTargetList = pTarget
            end

            for _, hTarget in pairs(aTargetList) do
                g_gameRules.game:SendChatMessage(ChatToTarget, hSender.id, hTarget.id, (Server.LocalizationManager:LocalizeForPlayer(hTarget, sMessage, tFormat)))
            end
        end,

        TextMessage = function(self, iType, pTarget, sMessage, tFormat)

            local iTeamId = ((IsString(pTarget) or (IsAny(pTarget, GameTeam_Neutral, GameTeam_NK, GameTeam_NK))) and Server.Utils:GetTeam_Number(pTarget))
            if (not iTeamId and pTarget == ChatType_ToTeam) then
                iTeamId = Server.Utils:GetTeamId(pSender)
            end

            if (iTeamId) then
                return self:SendTextMessageToTeam(iType, iTeamId, sMessage, tFormat)

            elseif (pTarget == ChatType_ToAll) then
                return self:SendTextMessageToAll(iType, sMessage, tFormat)

            end
            local aTargetList = ((IsArray(pTarget) and pTarget.id) and { Server.Utils:GetEntity(pTarget) or pTarget})
            if (table.empty(aTargetList)) then
                return
            end

            for _, hTarget in pairs(aTargetList) do
                self:SendTextMessageToTarget(iType, hTarget, sMessage, tFormat)
            end
        end,

        -- pClass = System(Network)
        -- pTarget = Player
        -- tFormat = Format for localization?
        ConsoleMessage = function(self, aMessageInfo, pArg1, pArg2, pArg3, pArg4, pArg5)

            -- The classic approach
            if (not IsTable(aMessageInfo)) then
                aMessageInfo = {
                    Type = aMessageInfo,
                    Recipients = pArg1,
                    Message = pArg2,
                    Format = pArg3,
                    Class = pArg4,
                    Centered = pArg5,
                }

            -- Player directly passed
            elseif (aMessageInfo.id) then
                aMessageInfo = {
                    Type = ChatType_Console,
                    Recipients = aMessageInfo,
                    Message = pArg1,
                    Format = pArg2,
                    Class = pArg3,
                    Centered = pArg4,
                }
            end

            if (table.IsRecursive(aMessageInfo)) then
                for _, aInfo in pairs(aMessageInfo) do
                    self:ConsoleMessage(aInfo)
                end
                return
            end

            local pTarget   = aMessageInfo.Recipients   -- Recipients
            local sMessage  = aMessageInfo.Message      -- The message
            local iType     = aMessageInfo.Type         -- The type of console message. e.g centered, class, normal
            local pClass    = aMessageInfo.Class        -- The class type
            local tFormat   = aMessageInfo.Format       -- The format table
            local bCentered = aMessageInfo.Centered     -- Center the message

            local iTeamId = ((IsString(pTarget) or (IsAny(pTarget, GameTeam_Neutral, GameTeam_NK, GameTeam_NK))) and Server.Utils:GetTeam_Number(pTarget))
            if (not iTeamId and pTarget == ChatType_ToTeam) then
                iTeamId = Server.Utils:GetTeamId(pSender)
            end

            if (pClass) then

                local aClassInfo = (IsTable(pClass) and pClass) or self:GetConsoleLogClass(pClass) or self.DefaultConsoleLogClass
                local sClassColor   = (aMessageInfo.ClassColor or aClassInfo.ClassColor or self.Properties.ConsoleLogClassColor)
                local sTagColor     = (aMessageInfo.TagColor or aClassInfo.TagColor or self.Properties.ConsoleLogTagDefaultColor)
                local sMessageColor = (aMessageInfo.MessageColor or aClassInfo.MessageColor or self.Properties.ConsoleLogMessageColor)

                local sClass = string.format("%s%s(%s%s%s) {Gray}: %s", sClassColor, aClassInfo.Class, sTagColor, (aMessageInfo.Tag or aClassInfo.Tag), sClassColor, sMessageColor)
                local iClassOffset = self.Properties.ConsoleLogClassOffset

                sClass = Server.Logger:FormatTags(sClass)
                sClass = string.lspace(sClass, iClassOffset, string.COLOR_CODE)
                sMessage = string.format("%s%s", sClass, sMessage)
            end

            if (bCentered or iType == ChatType_ConsoleCentered) then
                sMessage = string.mspace(sMessage, self.Properties.ConsoleMaxLength, nil, string.COLOR_CODE)
            end

            iType = ChatType_Console

            if (iTeamId) then
                return self:SendTextMessageToTeam(iType, iTeamId, sMessage, tFormat)

            elseif (pTarget == ChatType_ToAll) then
                return self:SendTextMessageToAll(iType, sMessage, tFormat)

            end

            local aTargetList
            if (table.IsRecursive(pTarget)) then
                aTargetList = pTarget

            else
                aTargetList = { Server.Utils:GetEntity(pTarget) }
            end

            if (table.empty(aTargetList)) then
                return
            end

            for _, hTarget in pairs(aTargetList) do
                self:SendTextMessageToTarget(iType, hTarget, sMessage, tFormat)
            end
        end,

        SendMessageToTeam = function(self, hSender, iTeamId, sMessage)
            g_gameRules.game:SendChatMessage(ChatToTeam, hSender.id, hSender.id, sMessage, iTeamId)
        end,

        SendMessageToAll = function(self, hSender, sMessage)
            g_gameRules.game:SendChatMessage(ChatToAll, hSender.id, hSender.id, sMessage)
        end,

        SendTextMessageToTeam = function(self, iType, iTeamId, sMessage, tFormat)
            for _, hClient in pairs(Server.Utils:GetPlayers({ ByTeam = iTeamId })) do
                self:SendTextMessageToTarget(iType, hClient, sMessage, tFormat)
            end
            --g_gameRules.game:SendTextMessage(iType, sMessage, TextMessageToTeam, iTeamId)
        end,

        SendTextMessageToAll = function(self, iType, sMessage, tFormat)
            for _, hClient in pairs(Server.Utils:GetPlayers()) do
                self:SendTextMessageToTarget(iType, hClient, sMessage, tFormat)
            end
        end,

        SendTextMessageToTarget = function(self, iType, hClient, sMessage, tFormat)
            if (not hClient.IsPlayer) then
                self:LogDirect("Invalid Recipient for SendTextMessageToTarget(): %s", hClient:GetName())
                return
            end

            sMessage = Server.LocalizationManager:LocalizeForPlayer(hClient, sMessage, tFormat)
            g_gameRules.game:SendTextMessage(iType, sMessage, TextMessageToClient, hClient.id)
        end,

        LogChatMessage = function(self, aLogInfo)

            local iType = aLogInfo.Type
            local hSender = aLogInfo.Sender
            local hTarget = aLogInfo.Target
            local sMessage = aLogInfo.Message

            local aProperties = self.Properties
            local aRecipients = Server.Utils.GetPlayers()

            local sTag = ""
            if (iType == ChatToTeam) then
                aRecipients = Server.Utils:GetPlayers({ ByTeam = Server.Utils:GetTeamId(hSender) })
                sTag = (" $9(%s@str_team$9)"):format(aProperties.ConsoleChatMessageTeamTagColor)

            elseif (iType == ChatToTarget) then
                sTag = (" $9(%s@str_pm$9)"):format(aProperties.ConsoleChatMessagePMTagColor)
                aRecipients = { hSender }
                if (hSender ~= hTarget) then
                    table.insert(aRecipients, hTarget)
                end
            end

            for _, hRecipient in pairs(aRecipients) do
                local sTagLocalized = Server.LocalizationManager:LocalizeForPlayer(hRecipient, sTag, {})
                local sFinalMessage = ("%s%s%s"):format(aProperties.ConsoleChatMessageSenderColor, hSender:GetName(), sTagLocalized)
                sFinalMessage = string.lspace(sFinalMessage, aProperties.ConsoleChatOffset - 3, string.COLOR_CODE)
                sFinalMessage = ("%s : %s%s"):format(sFinalMessage, aProperties.ConsoleChatMessageColor, sMessage)
                local sMessageLocalized = Server.LocalizationManager:LocalizeForPlayer(hRecipient, sFinalMessage, {})

                self:ConsoleMessage({
                    Type = ChatType_Console,
                    Message = sMessageLocalized,
                    Recipients = { hRecipient },
                })
            end
        end,

        GetChatPrefixTag = function(self, iType, hPlayer)

            local sForcedTag = hPlayer.Info.ForcedChatTag
            if (sForcedTag) then
                return sForcedTag:format("(%s)", sForcedTag), sForcedTag
            end

            local aTagList = self.Properties.ChatMessageTags
            if (table.empty(aTagList) or aTagList.Status == false) then
                return
            end

            local sPlayerCoords = hPlayer:GetMapCoords()

            local tAnd = aTagList.And -- all of these
            local tOr = aTagList.Or   -- plus any one of these, depending on the condition set

            local aTags = {}
            local function CheckTagList(aList, bOnlyOne)
                local bAddTag
                for _, aTagInfo in pairs(aList) do
                    bAddTag = true

                    if (aTagInfo.Status ~= false) then
                        if (aTagInfo.Type and iType ~= aTagInfo.type) then
                            bAddTag = false

                        elseif (aTagInfo.Condition) then
                            local bOk, sErr = pcall(hPlayer[aTagInfo.Condition])
                            if (not bOk) then
                                self:LogError("Failed to execute Condition '%s' for Tag '%s'", aTagInfo.Condition, aTagInfo.Tag)
                                self:LogError("%s", ToString(sErr))
                                bAddTag = false
                            end

                            bAddTag = (sErr)
                        end
                    end

                    if (bAddTag) then
                        table.insert(aTags, Server.Logger:FormatTags(aTagInfo.Tag, {
                            Coords = sPlayerCoords
                        }))
                        if (bOnlyOne) then
                            return
                        end
                    end
                end
            end

            CheckTagList(tAnd)
            CheckTagList(tOr, true)



            local sTagParenthesis = table.concat()
            return sChatTag, sTag
        end,

        FilterMessage = function(self, hSender, hTarget, sMessage, iType, bSentByServer)

            local bLogMessage = true
            if (bSentByServer) then
                bLogMessage = false
            end

            if (bLogMessage) then
                self:LogChatMessage({
                    Type    = iType,
                    Sender  = hSender,
                    Target  = hTarget,
                    Message = sMessage
                })
            end
            return true
        end,

        OnChatMessage = function(self, hSenderID, hTargetID, sMessage, iType, iForcedTeam, bSentByServer)

            local hSender = Server.Utils:GetEntity(hSenderID)
            local hTarget = Server.Utils:GetEntity(hTargetID)

            -- This info gets sent back to the DLL
            local aInfo = { Ok = true, NewMessage = sMessage, NewType = iType, NewTarget = hTarget }

            if (hSender.IsPlayer) then

                if (not bSentByServer) then
                    if (Server.ChatCommands:CheckMessage(hSender, sMessage, iType)) then
                        aInfo.Ok = false

                    elseif (not self:FilterMessage(hSender, hTarget, sMessage, iType, bSentByServer)) then
                        aInfo.Ok = false

                    end
                end

                return aInfo
            end

            return aInfo
        end,

        SendWelcomeMessage = function(self, hPlayer)
            DebugLog("welcome message..")
        end,

    }
})