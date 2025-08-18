-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
--                    This is the Server Chat Command Component
-- ===================================================================================

Server:CreateComponent({
    Name = "ChatCommands",
    FriendlyName = "Commands",
    Body = {

        ExternalData = {
            { Name = "", NamePattern = "%.lua$", Path = (SERVER_DIR_COMMANDS), Recursive = true, ReadOnly = true }
        },

        Properties = {

            -- send a sound feedback when executing commands
            SendSoundFeedback = true,

            CommandPrefixList = {
                ".",
                "!",
                "/",
            }
        },

        ChatEntities = {
            Info = "iNFO",
        },

        CollectedCommands = {},
        CommandMap = {},

        Responses = {

            Success = {
                NoMessage = true,
                Success = true,
            },
            Failed = {
                NoMessage = true,
            },
            NoFeedback = {
                NoMessage = true,
                NoFeedback = true,
            },
            NotFound = {
                NoStatus = true,
                Message = "@command_notFound"
            },
            ListFound = {
                Success = true,
                NoStatus = true,
                NoAdminLog = true,
                Message = "@command_listFound"
            },
            InsufficientAccess = {
                Message = "@insufficientAccess"
            },
            InsufficientPrestige = {
                Message = "@insufficientPrestige"
            },
            Broken = {
                Message = "@command_broken"
            },
            Disabled = {
                Message = "@command_disabled"
            },
            Reserved = {
                Message = "@command_reserved"
            },
            GameRules = {
                Message = "@command_gameRules"
            },
            InVehicle = {
                Message = "@command_inVehicle"
            },
            NotInVehicle = {
                Message = "@command_notInVehicle"
            },
            InDoors = {
                Message = "@command_inDoors"
            },
            NotInDoors = {
                Message = "@command_notInDoors"
            },
            Spectating = {
                Message = "@command_spectating"
            },
            NotSpectating = {
                Message = "@command_notSpectating"
            },
            Dead = {
                Message = "@command_onlyDead"
            },
            NotDead = {
                Message = "@command_onlyAlive"
            },
            CoolDown = {
                Message = "@command_coolDown"
            },
            ScriptError = {
                Message = "@command_scriptError"
            },

        },

        Initialize = function(self)
            self:RegisterCommands()

            local iCommandsLoaded = table.size(self.CommandMap)
            self:LogEvent({
                Event = self:GetName(),
                Recipients = Server.Utils:GetPlayers({ ByAccess = Server.AccessHandler:GetAdminLevel() }),
                Message = [[@commands_loaded]],
                MessageFormat = { Count = iCommandsLoaded },
            })
        end,

        PostInitialize = function(self)

        end,

        Add = function(self, aInfo)
            table.insert(self.CollectedCommands, aInfo)
        end,

        RegisterCommands = function(self)
            for _, aInfo in pairs(self.CollectedCommands) do
                self:RegisterCommand(aInfo)
            end
        end,

        RegisterCommand = function(self, aInfo)

            if (table.IsRecursive(aInfo)) then
                for _, tInfo in pairs(aInfo) do
                    self:RegisterCommand(tInfo)
                end
                return
            end

            local sName         = aInfo.Name
            local aArguments    = (aInfo.Arguments or {})
            local tProperties   = (aInfo.Properties or {})
            local hFunction     = aInfo.Function

            if (not IsString(sName) or string.empty(sName) or not string.match(sName, "^[%w_]+$")) then
                self:LogError("Invalid Command Name to ChatCommands:Add() %s", ToString(sName))
                return
            end

            if (not hFunction) then
                self:LogError("No Function to ChatCommands:Add() %s", sName)
                return
            end

            if (not aInfo.Access) then
                self:LogWarning("No Access to ChatCommands:Add() %s, Assuming Lowest", sName)
                aInfo.Access = Server.AccessHandler:GetLowestAccess()
            end

            if (self.CommandMap[string.lower(sName)]) then
                self:LogError("Duplicated Command Name '%s'", sName)
                return
            end

            self:BuildCommand(sName, aArguments, tProperties, hFunction, aInfo.Access)
        end,

        BuildCommand = function(self, sName, aArguments, tProperties, hFunction, iAccessLevel)

            local sNameLower = string.lower(sName)
            self.CommandMap[sNameLower] = {

                m_DisabledReason = "@admin_decision",
                m_IsDisabled = false,
                m_IsBroken   = false,
                m_IsHidden   = (tProperties.Hidden or tProperties.IsHidden),

                CoolDowns = {
                },

                Name        = string.lower(sName),
                RealName    = sName,
                Access      = (iAccessLevel),
                Properties  = tProperties,
                Arguments   = aArguments,
                Function    = hFunction,

                -- Functions
                GetName     = function(this) return this.RealName  end,
                IsHidden    = function(this) return this.m_IsHidden  end,
                Hide        = function(this, bMode) this.m_IsHidden = bMode end,
                IsDisabled  = function(this) return this.m_IsDisabled end,
                Disable     = function(this, bMode) this.m_IsDisabled = bMode end,
                GetDisabledReason = function(this) local sReason = this.m_DisabledReason return CheckStringEx(sReason, "", " (" .. sReason .. ")") end,
                IsBroken    = function(this) return this.m_IsBroken end,
                Break       = function(this, bMode) this.m_IsBroken = bMode end,
                IsQuiet     = function(this) return this.Properties.IsQuiet  end,
                SetCoolDown = function(this, sId, iTimer) iTimer = iTimer or (this.Properties.CoolDown or 0) if (not this.CoolDowns[sId]) then this.CoolDowns[sId] = TimerNew(iTimer)this.CoolDowns[sId].expire() else this.CoolDowns[sId].refresh() end end,
                GetCoolDown = function(this, sId, iTimer) if (not this.CoolDowns[sId]) then this:SetCoolDown(sId, iTimer) end return this.CoolDowns[sId].expired(), this.CoolDowns[sId].getexpiry() end,
                GetGameRules= function(this, sComp) local sRules = this.Properties.GameRules if (sComp) then return sComp == sRules end return sRules  end
            }

            return self.CommandMap[sNameLower]
        end,

        ParseCommand = function(self, sMessage, sDetectedPrefix)
            local tArgs = {}
            for sWord in sMessage:gmatch("%S+") do
                table.insert(tArgs, sWord)
            end

            if (table.empty(tArgs)) then
                return
            end

            -- Remove detected prefix from the Command
            local sCommand = (table.remove(tArgs, 1):gsub(("^(%s)"):format(sDetectedPrefix), ""))
            return sCommand, tArgs
        end,

        FindCommand = function(self, sCommandName, iAccessLevel, bGreedy)

            local iCommandLength = string.len(sCommandName)
            iAccessLevel = (iAccessLevel or Server.AccessHandler:GetHighestAccess())
            sCommandName = string.lower(sCommandName)

            local aResults = {}
            for _, aCommand in pairs(self.CommandMap) do
                local sName = string.lower(aCommand.Name)
                if (string.len(sCommandName) >= 1) then
                    if (sName == sCommandName) then
                        aResults = { aCommand }
                        break

                    -- ris:
                    -- don't autocomplete on disabled or hidden commands
                    elseif (not aCommand:IsHidden() and not aCommand:IsDisabled()) then
                        if (string.match(sName, ("^" .. sCommandName))) then
                            table.insert(aResults, aCommand)
                        elseif (bGreedy and iCommandLength > 1) then
                            local iStepBack = math.GetMax(3, iCommandLength - 3)
                            for i = string.len(sCommandName), iStepBack, -1 do
                                local sGreedyMatch = string.sub(sCommandName, 1, i)
                                if (string.match(sName, ("^" .. sGreedyMatch))) then
                                    table.insert(aResults, aCommand)
                                    break
                                end
                            end
                        end
                    end
                elseif (sName == string.lower(sCommandName)) then
                    aResults = { aCommand }
                    break
                end
            end

            if (table.empty(aResults) and not bGreedy) then
                return self:FindCommand(sCommandName, iAccessLevel, true)
            end

            local aResultsAccessible = {}
            for _, aCommand in pairs(aResults) do
                if (aCommand.Access <= iAccessLevel) then
                    table.insert(aResultsAccessible, aCommand)
                end
            end
            return aResultsAccessible
        end,

        SendMessage = function(self, hPlayer, tMessage, tFormat, iMessageType)

            local sCommandUpper = string.lower(tFormat.Name)
            local tCommand = self.CommandMap[sCommandUpper:lower()]
            if (tCommand) then
                -- Devs don't need to see this either, just bloats console
                local bShowMessage = false -- hPlayer:HasAccess(ServerAccess_Developer)
                if (tCommand:IsQuiet() and not bShowMessage) then
                    return
                end
            end

            local sArguments = (tFormat.__Arguments__)-- or "<{Green}S{Gray}: {Green}Nomad{Gray}> <{Blue}N{Gray}: {Blue}669{Gray}>, <{Orange}P{Gray}: {Orange}Nomad{Gray}>, <{Yellow}Msg{Gray}: {Yellow}out of mana..{Gray}>, <{Red}?{Gray}: {Red}third!{Gray}>")

            local sPlayerName = hPlayer:GetName()
            local aLogRecipients = Server.Utils:GetPlayers({ NotById = hPlayer.id, ByAccess = hPlayer:GetAccess(Server.AccessHandler:GetAdminLevel()) })
            local aChatLogRecipients = table.copy(aLogRecipients)

            local sMessage = Server.Logger:RidColors(hPlayer:LocalizeText(tMessage.Message or "", tFormat   ))
            local sAdminMessage = Server.Logger:RidColors(hPlayer:LocalizeText((tMessage.AdminMessage or sMessage or ""), tFormat))

            local sConsole_Log  -- Admins
            local sConsole_Msg  -- Player

            local sChat_Log -- Admins
            local sChat_Msg -- Player

            -- Yandere Dev made this, don't judge - rewrite pending..
            if (tMessage.Success) then
                if (tMessage.NoStatus) then

                    -- TEST : Open your Console to view the [ 3 ] Matches!
                    sConsole_Log = ("(%s{Gray})"):format(CRY_COLOR_GREEN .. sAdminMessage)
                    sConsole_Msg = CRY_COLOR_GREEN .. sMessage
                    sChat_Log = CRY_COLOR_GREEN .. sAdminMessage
                    sChat_Msg = CRY_COLOR_GREEN .. sMessage
                elseif (tMessage.NoMessage) then

                    -- return true
                    -- TEST : Success
                    -- TEST : Success
                    tFormat = { {}, tFormat }
                    sConsole_Log = CRY_COLOR_GREEN .. "@str_success"
                    sConsole_Msg = CRY_COLOR_GREEN .. "@str_success"
                    sChat_Log = CRY_COLOR_GREEN .. "@str_success"
                    sChat_Msg = ""
                else

                    -- return true, "Function Returned Ok!"
                    -- TEST : Function returned Ok!
                    sConsole_Log = ("(%s{Gray})"):format(CRY_COLOR_GREEN .. sAdminMessage)
                    sConsole_Msg = CRY_COLOR_GREEN .. sMessage
                    sChat_Log = sAdminMessage
                    sChat_Msg = sMessage
                end
            elseif (tMessage.NoFeedback) then
                if (tMessage.NoStatus) then

                    -- TEST : Open your Console to view the [ 3 ] Matches!
                    sConsole_Log = CRY_COLOR_ORANGE .. sAdminMessage
                    sConsole_Msg = CRY_COLOR_ORANGE .. sMessage
                    sChat_Log = CRY_COLOR_ORANGE .. sAdminMessage
                    sChat_Msg = ""
                elseif (tMessage.NoMessage) then

                    -- return false
                    -- TEST : Failed
                    -- TEST : Success
                    tFormat = { {}, tFormat }
                    sConsole_Log = ("(%s{Gray})"):format(CRY_COLOR_ORANGE .. "@str_noFeedback")
                    sConsole_Msg = CRY_COLOR_ORANGE .. "@str_noFeedback"
                    sChat_Log = "@str_noFeedback"
                    sChat_Msg = ""
                else

                    -- return false, "Function Returned BAD!"
                    -- TEST : Error (Function returned BAD!)
                    -- TEST : Success
                    tFormat = { {}, tFormat }
                    sConsole_Log = CRY_COLOR_ORANGE .. "@str_noFeedback {Gray}({Orange}" .. sAdminMessage .. "{Gray})"
                    sConsole_Msg = CRY_COLOR_ORANGE .. "@str_noFeedback {Gray}({Orange}" .. sMessage .. "{Gray})"
                    sChat_Log = "@str_noFeedback (" .. sAdminMessage .. ")"
                    sChat_Msg = "@str_noFeedback (" .. sMessage .. ")"
                end
            else--if (tMessage.Failed) then
                if (tMessage.NoStatus) then

                    -- TEST : Open your Console to view the [ 3 ] Matches!
                    sConsole_Log = ("(%s{Gray})"):format(CRY_COLOR_RED .. sAdminMessage)
                    sConsole_Msg = CRY_COLOR_RED .. sMessage
                    sChat_Log = CRY_COLOR_RED .. sAdminMessage
                    sChat_Msg = CRY_COLOR_RED .. sMessage
                elseif (tMessage.NoMessage) then

                    -- return false
                    -- TEST : Failed
                    -- TEST : Success
                    tFormat = { {}, tFormat }
                    sConsole_Log = ("(%s{Gray})"):format(CRY_COLOR_RED .. "@str_failed")
                    sConsole_Msg = CRY_COLOR_RED .. "@str_failed"
                    sChat_Log = "@str_failed"
                    sChat_Msg = "@str_failed"
                else

                    -- return false, "Function Returned BAD!"
                    -- TEST : Error (Function returned BAD!)
                    -- TEST : Success
                    tFormat = { {}, tFormat }
                    sConsole_Log = CRY_COLOR_RED .. "@str_failed {Gray}({Red}" .. sAdminMessage .. "{Gray})"
                    sConsole_Msg = CRY_COLOR_RED .. "@str_failed {Gray}({Red}" .. sMessage .. "{Gray})"
                    sChat_Log = "@str_failed (" .. sAdminMessage .. ")"
                    sChat_Msg = "@str_failed (" .. sMessage .. ")"
                end

                local sErrorFeedback = "Sounds/interface:menu:buy_error"
                if (self.Properties.SendSoundFeedback) then
                    if (g_gameRules.IS_PS) then
                        g_gameRules.onClient:ClBuyError(hPlayer:GetChannel(), "nnn")
                    else
                        Server.ClientMod:ExecuteCode({ Code = "CryMP_Client:PSE(nil,'" .. sErrorFeedback .. "')", Clients = hPlayer })
                    end
                end
            end

            -- Don't log invalid command attempts to admins!
            if (tMessage == self.Responses.NotFound) then
                sChat_Log = nil
                sConsole_Log = nil
            end

            if (tMessage.ChatOnly) then
                sConsole_Msg = ""
            end

            -- Admins:
            if (not tMessage.NoAdminLog) then
                if (string.emptyN(sChat_Log)) then
                    Server.Chat:ChatMessage(hPlayer, aChatLogRecipients, ("< !%s >  %s{Gray}"):format(sCommandUpper, sChat_Log), tFormat)
                end
                if (string.emptyN(sConsole_Log)) then
                    self:LogEvent({
                        Event = self:GetFriendlyName(),
                        Recipients = aLogRecipients,
                        Message = "@command_consoleLog",
                        MessageFormat = { { Name = hPlayer:GetName(), Command = string.capitalN(sCommandUpper, 1), Reply = sConsole_Log }, tFormat  }
                    })
                    if (string.emptyN(sArguments)) then
                        self:LogEvent({
                            Event = self:GetFriendlyName(),
                            Recipients = aLogRecipients,
                            Message = ("@str_arguments %s"):format(sArguments),
                            MessageFormat = {}
                        })
                    end
                end
            end

            -- Players:
            if (string.emptyN(sChat_Msg)) then
                local sCommandPrefix = ("< !%s > "):format(sCommandUpper)
                if (tMessage.RawMessage) then
                    sCommandPrefix = ""
                end
                Server.Chat:ChatMessage(self.ChatEntities.Info, hPlayer, ("%s%s"):format(sCommandPrefix, sChat_Msg), tFormat)
            end
            if (string.emptyN(sConsole_Msg)) then
                -- So, we only do the normal log if the user used the "say" console command
                -- Otherwise, we will just insert the user to the admin log recipients
                local bSayConsoleLog = true

                if (not bSayConsoleLog and iMessageType ~= ChatToTarget) then
                    self:LogEvent({
                        Event = self:GetFriendlyName(),
                        Recipients = { hPlayer },
                        Message = ("> {White}!{Gray}%s {Gray}%s"):format(sCommandUpper, (sAdminMessage ~= sMessage and ((sConsole_Log):gsub(sAdminMessage, sMessage, 1)) or sConsole_Log)),
                        MessageFormat = tFormat
                    })
                else
                    Server.Chat:ConsoleMessage(hPlayer, ("   (!%s: %s{Gray})"):format(sCommandUpper, sConsole_Msg), tFormat)
                end
            end
        end,




        CheckMessage = function(self, hPlayer, sMessage, iType)

            if (not IsAny(iType, ChatToAll, ChatToTeam)) then
            --    return false
            end

            local bPrefixOk = false
            local sDetectedPrefix
            for _, sPrefix in pairs(self.Properties.CommandPrefixList) do

                local sPrefixEscaped = sPrefix:gsub("(%W)", "%%%1")
                if (string.sub(sMessage, 1, #sPrefix) == sPrefix) then

                    --local sPattern = ("^%s[%%w_%%-]+"):format(sPrefixEscaped)
                    local sPattern = ("^%s%%S+"):format(sPrefixEscaped)
                    if (not string.matchex(sMessage, (sPattern .. "$"), (sPattern .. "%s+"))) then
                        return false
                    end

                    sDetectedPrefix = sPrefix
                    bPrefixOk = true
                    break
                end
            end

            if (not bPrefixOk) then
                return false
            end

            local sCommand, tArgs = self:ParseCommand(sMessage, sDetectedPrefix)
            if (not sCommand) then
                return false
            end

            local aCommandList = self:FindCommand(sCommand)
            local iCommandCount = table.count(aCommandList)
            if (iCommandCount == 0) then
                self:SendMessage(hPlayer, self.Responses.NotFound, { Name = sCommand }, iType)
                return true -- Block Message

            elseif (iCommandCount > 1) then
                self:SendMessage(hPlayer, self.Responses.ListFound, { Name = sCommand, Count = iCommandCount }, iType)
                self:ListCommands(hPlayer, aCommandList, string.lower(sCommand))
                return true -- Block Message
            end

            self:ProcessCommand(hPlayer, aCommandList[1], tArgs, iType)
            return true -- Block Message
        end,

        SendHelp = function(self, hPlayer, aCommand)
            -- Misc
            local sAllPrefixes = CRY_COLOR_WHITE .. table.concat(self.Properties.CommandPrefixList, "$9, $1")
            local sSpace = "      "

            -- Cmd
            local aCopied   = table.copy(aCommand)
            local hArgs     = aCopied.Arguments
            local iAccess   = aCopied.Access
            local sDesc     = (aCopied.Description or "@no_description")
            local sName     = aCopied.Name

            -- Client
            local sLang = hPlayer:GetPreferredLanguage()

            -- Print
            local iBoxWidth = 100
            local iMaxArgLen = 0
            local sArgsLine = ""
            local sBracketColor = CRY_COLOR_GRAY
            local hArgsLocalized = table.it(hArgs, function(x, i, v)
                v.Name = hPlayer:LocalizeText(v.Name) -- Name
                v.Desc = hPlayer:LocalizeText((v.Desc or "@no_description")) -- Desc

                sBracketColor = CRY_COLOR_GRAY
                if (v.Required) then
                    sBracketColor = CRY_COLOR_RED
                else--if (v.Optional) then
                    sBracketColor = CRY_COLOR_BLUE
                end

                iMaxArgLen = math.max(iMaxArgLen, string.len(v.Name))
                if (sArgsLine == "") then
                    sArgsLine = string.format("%s<%s%s%s>%s", sBracketColor, CRY_COLOR_YELLOW, v.Name, sBracketColor, CRY_COLOR_GRAY)
                else
                    sArgsLine = string.format("%s, %s<%s%s%s>", sArgsLine, sBracketColor, CRY_COLOR_YELLOW, v.Name, sBracketColor, CRY_COLOR_GRAY)
                end
            end)
            local sCmdBanner    = string.format("== [ $1!%s%s$9 ] ", Server.AccessHandler:GetAccessColor(iAccess), string.upper(sName))
            local sDescBanner   = string.format("%s", hPlayer:LocalizeText(sDesc))

            local sLPrefix = hPlayer:LocalizeText("@str_prefixes")
            local sLAccess = hPlayer:LocalizeText("@arg_access")
            local sLUsage  = hPlayer:LocalizeText("@str_usage")

            local iMaxInfoLen   = math.max(string.len(sLPrefix), string.len(sLAccess), string.len(sLUsage))

            local sCommandLine  =  string.capitalN(sName)
            if (sArgsLine ~= "") then
                sCommandLine = sCommandLine .. ","
            end
            local iCommandLineLen = iMaxInfoLen + string.len(sCommandLine)

            local sPrefixLine   = string.format("%s: %s", string.rspace(sLPrefix, iMaxInfoLen, string.COLOR_CODE), sAllPrefixes)
            local sAccessLine   = string.format("%s: %s", string.rspace(sLAccess, iMaxInfoLen, string.COLOR_CODE), Server.AccessHandler:GetAccessName(iAccess))
            local sUsageLine    = string.format("%s: %s %s", string.rspace((sLUsage), iMaxInfoLen, string.COLOR_CODE),  sCommandLine, sArgsLine)

            -- Send All
            Server.Chat:ConsoleMessage(hPlayer, sSpace .. CRY_COLOR_GRAY .. string.rspace(sCmdBanner, iBoxWidth, string.COLOR_CODE, "="))
            Server.Chat:ConsoleMessage(hPlayer, sSpace .. CRY_COLOR_GRAY .. string.format("[ %s ]", string.mspace((hPlayer:LocalizeText("@str_description") .. ":"), iBoxWidth - 4, 1, string.COLOR_CODE)))
            Server.Chat:ConsoleMessage(hPlayer, sSpace .. CRY_COLOR_GRAY .. string.format("[ %s ]", string.mspace(sDescBanner, iBoxWidth - 4, 1, string.COLOR_CODE)))
            Server.Chat:ConsoleMessage(hPlayer, sSpace .. CRY_COLOR_GRAY .. string.format("[ %s ]", string.mspace("", iBoxWidth - 4)))
            Server.Chat:ConsoleMessage(hPlayer, sSpace .. CRY_COLOR_GRAY .. "[ " .. string.rspace(sPrefixLine, iBoxWidth - 4, string.COLOR_CODE) .. CRY_COLOR_GRAY .. " ]")
            Server.Chat:ConsoleMessage(hPlayer, sSpace .. CRY_COLOR_GRAY .. "[ " .. string.rspace(sAccessLine, iBoxWidth - 4, string.COLOR_CODE) .. CRY_COLOR_GRAY .. " ]")
            Server.Chat:ConsoleMessage(hPlayer, sSpace .. CRY_COLOR_GRAY .. "[ " .. string.rspace(sUsageLine,  iBoxWidth - 4, string.COLOR_CODE) .. CRY_COLOR_GRAY .. " ]")

            local iArgsStart = (iMaxArgLen + 3 + string.len(sCommandLine))
            local iArgMaxName = iMaxArgLen--table.it(hArgs, function(x, i, v) return math.max((x or 0), v.Name)  end)

            local sArgType = ""
            local sArgLine
            for _, aArg in pairs(hArgs) do

                sArgType = self:ConvertArgumentType(aArg.Type or CommandArg_TypeString, "Locale")

                sBracketColor = CRY_COLOR_GRAY
                if (aArg.Required) then
                    sBracketColor = CRY_COLOR_RED
                else--if (aArg.Optional) then
                    sBracketColor = CRY_COLOR_BLUE
                end

                sArgType = string.format("%s(%s%s%s)", CRY_COLOR_GRAY, CRY_COLOR_WHITE, hPlayer:LocalizeText(sArgType), CRY_COLOR_GRAY)
                -- Debug(aArg.Desc,"==",hPlayer:LocalizeText((aArg.Desc or "@l_ui_nodescription")))
                sArgLine = string.rep(" ", (iMaxInfoLen + 2 + string.len(sName) + 2)) .. string.rspace(string.format("%s<%s%s %s%s>%s", sBracketColor, CRY_COLOR_YELLOW, string.rspace(hPlayer:LocalizeText(aArg.Name), iArgMaxName, string.COLOR_CODE), sArgType, sBracketColor, CRY_COLOR_GRAY), 30, string.COLOR_CODE) .. " - " .. CRY_COLOR_WHITE .. hPlayer:LocalizeText((aArg.Desc or "@no_description"))


                Server.Chat:ConsoleMessage(hPlayer, sSpace .. CRY_COLOR_GRAY .. string.format("[ %s ]", string.rspace(sArgLine .. CRY_COLOR_GRAY, iBoxWidth - 4, string.COLOR_CODE)))

            end
            Server.Chat:ConsoleMessage(hPlayer, sSpace .. CRY_COLOR_GRAY .. "[ " .. string.rspace("",  iBoxWidth - 4, string.COLOR_CODE) .. CRY_COLOR_GRAY .. " ]")

            local sInfoHelp = hPlayer:LocalizeText("@arg_consoleHelpLine1")
            --sInfoHelp = string.format("%s", Logger.Format(sInfoHelp))

            Server.Chat:ConsoleMessage(hPlayer, sSpace .. CRY_COLOR_GRAY .. "[ " .. string.mspace(sInfoHelp .. CRY_COLOR_GRAY, iBoxWidth - 4, nil, string.COLOR_CODE) .. " ]")
            Server.Chat:ConsoleMessage(hPlayer, sSpace .. CRY_COLOR_GRAY .. string.rspace("", iBoxWidth, string.COLOR_CODE, "="))

            Server.Chat:ChatMessage(ChatEntity_Server, hPlayer, hPlayer:LocalizeText("< !" .. sName:lower() .. " > @commandHelp_Chat"))--, { Name = string.lower(sName) }))

            local x = {
                "== [ Commands ] ===================================================================================",
                "[                                         Description:                                            ]",
                "[                         Displays all available commands to your Console!                        ]",
                "[                                                                                                 ]",
                "[ Prefixes: !, /, \\                                                                               ]",
                "[ Access:   Developer                                                                             ]",
                "[ Usage :   !Commands, <Rank>, <Count>                                                            ]",
                "[                      <Rank  (String)>     - The Target Rank                                     ]",
                "[                      <Count (Number)>     - The Number                                          ]",
                "[                                                                                                 ]",
                "[                          RED Arguments are Required, Blue are Optional                          ]",
                "===================================================================================================",
            }
        end,

        CollectAndColorArguments = function(self, tCommandArgs, tUserArgs)

            local sArgs = ""
            local iUserArgs = #tUserArgs
            local iCommandArgs = #tCommandArgs

            if (iUserArgs == 0) then
                return
            end

            --"<{Green}S{Gray}: {Green}Nomad{Gray}> <{Blue}N{Gray}: {Blue}669{Gray}>, <{Orange}P{Gray}: {Orange}Nomad{Gray}>, <{Yellow}Msg{Gray}: {Yellow}out of mana..{Gray}>, <{Red}?{Gray}: {Red}third!{Gray}>")
            for _, sUserArg in pairs(tUserArgs) do
                local tCmdArg = (tCommandArgs[_] or { Type = -1 })
                local iArgType = (tCmdArg.Type or -1)
                local tArgInfo = self:ConvertArgumentType(iArgType)
                --sArgs = sArgs .. (sArgs ~= "" and ", " or "") .. ("<%s%s{Gray}: %s%s{Gray}>"):format(tArgInfo.Color, tArgInfo.Locale, tArgInfo.Color, sUserArg)
                sArgs = sArgs .. (sArgs ~= "" and ", " or "") .. ("%s%s{Gray}:%s%s{Gray}"):format(tArgInfo.Color, tArgInfo[(tCmdArg.Type ~= -1 and "Locale" or "Short")], tArgInfo.Color, sUserArg)
            end
            return sArgs
        end,

        ProcessCommand = function(self, hPlayer, aCommand, tArgs, iType)

            Server.Statistics:Event(StatisticsEvent_OnCommandUsed)

            local sCommand = aCommand.Name
            local aCommandArgs   = aCommand.Arguments
            local iCommandAccess = aCommand.Access
            local sCommandAccess = Server.AccessHandler:GetAccessName(iCommandAccess)
            local iPremiumAccess = Server.AccessHandler:GetPremiumLevel()

            local bIsAdmin = hPlayer:IsAdministrator()
            local bIsDeveloper = hPlayer:IsDeveloper()
            local bInTestMode = (hPlayer:IsInTestMode())-- or hPlayer:IsServerOwner())
            local iPlayerAccess = hPlayer:GetAccess()
            local bInsufficientAccess = (iPlayerAccess < iCommandAccess)

            local tUserArgs = table.copy(tArgs)
            local function SendMessage(tMessage, tFormat)
                tFormat.__Arguments__ = self:CollectAndColorArguments(aCommandArgs, tUserArgs)
                self:SendMessage(hPlayer, tMessage, tFormat, iType)
            end

            if (aCommand:IsBroken() and not bIsDeveloper) then
                SendMessage(self.Responses.Broken, { Name = sCommand })
                return
            end

            if (aCommand:IsDisabled() and not bIsDeveloper) then
                SendMessage(self.Responses.Disabled, { Name = sCommand, Reason = aCommand:GetDisabledReason() })
                return
            end

            if ((aCommand.Access == iPremiumAccess and bInsufficientAccess)) then
                SendMessage(self.Responses.Reserved, { Name = sCommand, Class = sCommandAccess })
                return
            end

            if (not bIsAdmin and bInsufficientAccess) then
                SendMessage({
                    NoStatus = true,
                    Message = "@command_notFound",
                    AdminMessage = "@insufficientAccess"
                }, { Name = sCommand })
                return
            end

            if (bInsufficientAccess) then
                SendMessage(self.Responses.InsufficientAccess, { Name = sCommand })
                return
            end

            local tProperties = aCommand.Properties
            local bProcessPayment = false

            local sGameRules  = tProperties.GameRules
            local bInVehicle  = tProperties.Vehicle
            local bInDoors    = tProperties.InDoors
            local bAlive      = tProperties.Alive
            local bSpectating = tProperties.Spectating
            local iPrice      = tProperties.Price

            local bPlayerInVehicle  = hPlayer:IsInVehicle()
            local bPlayerInDoors    = hPlayer:IsInDoors()
            local bPlayerAlive      = hPlayer:IsAlive()
            local bPlayerSpectating = hPlayer:IsSpectating()
            local iPlayerPrestige   = hPlayer:GetPrestige()


            if (IsAny(tArgs[1] or "", "-?", "--?", "-help", "--help")) then
                self:SendHelp(hPlayer, aCommand)
                return true -- Block message
            end

            if (not bInTestMode) then

                if (sGameRules and sGameRules ~= g_gameRules.class) then
                    SendMessage(self.Responses.GameRules, { Name = sCommand, Class = sGameRules })
                    return
                end

                local bCooledDown, iExpiry = aCommand:GetCoolDown(hPlayer.id)
                if (not bCooledDown) then
                    SendMessage(self.Responses.CoolDown, { Name = sCommand, Time = Date:Format(iExpiry) })
                    return
                end

                if (bSpectating ~= nil) then
                    if (bSpectating ~= bPlayerSpectating) then
                        SendMessage((bSpectating and self.Responses.Spectating or self.Responses.NotSpectating ), { Name = sCommand })
                        return
                    end
                end

                if (bAlive ~= nil) then
                    if (bAlive ~= bPlayerAlive) then
                        SendMessage((not bAlive and self.Responses.Dead or self.Responses.NotDead ), { Name = sCommand })
                        return
                    end
                end

                if (bInVehicle ~= nil) then
                    if (bInVehicle ~= bPlayerInVehicle) then
                        SendMessage((bInVehicle and self.Responses.InVehicle or self.Responses.NotInVehicle ), { Name = sCommand })
                        return
                    end
                end

                if (bInDoors ~= nil) then
                    if (bInDoors ~= bPlayerInDoors) then
                        SendMessage((bInDoors and self.Responses.InDoors or self.Responses.NotInDoors ), { Name = sCommand })
                        return
                    end
                end

                if (g_gameRules.class == GameMode_PS) then
                    if (iPrice ~= nil) then
                        if (iPrice > iPlayerPrestige) then
                            SendMessage(self.Responses.InsufficientPrestige, { Name = sCommand })
                            return
                        end
                        bProcessPayment = true
                    end
                end
            end

            local tPushArguments = {}
            local pSelf = (aCommand.This or aCommand.Properties.This)
            if (pSelf) then
                if (IsString(pSelf)) then
                    pSelf = CheckGlobal(pSelf)
                    table.insert(tPushArguments, pSelf)
                else
                    table.insert(tPushArguments, pSelf)
                end
                if (not aCommand.This) then -- Cache for later
                    aCommand.This = pSelf
                end
            end

            table.insert(tPushArguments, hPlayer)

            -- ===========================================================================
            -- Check Arguments

            local sUserArg, sUserArgLower
            self.CommandEvaluateTemp = nil
            for iArg, aCmdArg in pairs((aCommandArgs)) do

                sUserArg = tArgs[iArg]

                -- Assign default
                if (sUserArg == nil) then
                    if (aCmdArg.Default) then
                        sUserArg = tostring(aCmdArg.Default)
                        tArgs[iArg] = tostring(aCmdArg.Default)
                    elseif (aCmdArg.DefaultEval) then
                        self.CommandEvaluateTemp = {
                            Player = hPlayer,
                            Command = aCommand,
                            Argument = aCmdArg
                        }
                        local sEvalCode =
                        "local Player = Server.ChatCommands.CommandEvaluateTemp.Player;" ..
                        "local Command = Server.ChatCommands.CommandEvaluateTemp.Command;" ..
                        "local Argument = Server.ChatCommands.CommandEvaluateTemp.Argument;" ..
                        aCmdArg.DefaultEval

                        local function reader()
                            local s = sEvalCode
                            sEvalCode = nil
                            return s
                        end

                        -- Crysis lua 'load' will only accept a function that returns a chunk, not a chunk directly..
                        local bOk, sError = load(reader)
                        if (not bOk) then
                            aCommand:Break()
                            SendMessage(self.Responses.ScriptError, { Name = sCommand })
                            self:LogError("Failed to Load DefaultEvaluation for Command '%s' for Argument [%d]'%s'", aCommand:GetName(), iArg, (aCmdArg.Name or "<Null>"))
                            self:LogError("%s", sError or "<Null>")
                            return
                        end

                        bOk, sError = pcall(bOk)
                        if (not bOk) then
                            aCommand:Break()
                            SendMessage(self.Responses.ScriptError, { Name = sCommand })
                            self:LogError("Failed to Execute DefaultEvaluation for Command '%s' for Argument [%d]'%s'", aCommand:GetName(), iArg, (aCmdArg.Name or "<Null>"))
                            self:LogError("%s", sError or "<Null>")
                            return
                        end
                        sUserArg = tostring(sError)
                        tArgs[iArg] = tostring(sError)
                    end
                end

                -- Still empty!
                if (sUserArg == nil) then
                    if (aCmdArg.Required) then
                        local sIndex = ("<%s>"):format(aCmdArg.Name)
                        if (aCmdArg.Type ~= nil) then
                            --sIndex = ("<%d (%s)>"):format(iArg, (self:ConvertArgumentType(aCmdArg.Type)))
                            sIndex = ("<(%s)>"):format(aCmdArg.Name)
                        end
                        SendMessage({
                            Message = "@command_argNMissing",
                        }, { Index = sIndex, Name = sCommand })
                        return
                    end
                end
            end

            local bBreak
            local iArgPlus = 0
            for iArg, aCmdArg in pairs(aCommandArgs) do

                sUserArg = tArgs[iArg]
                if (not sUserArg) then
                    break -- end of user arguments!
                end

                sUserArgLower = sUserArg:lower()

                local sArgIndex = ("<%d>"):format(iArg)
                local iArgType = aCmdArg.Type
                local iArgMin = aCmdArg.Minimum
                local iArgMax = aCmdArg.Maximum
                local hArgReplacement

                if (iArgType == CommandArg_TypePlayer) then
                    hArgReplacement = Server.Utils:FindPlayerByName(sUserArg)
                    if (not hArgReplacement) then
                        -- TODO: Accept mulitple?
                        -- !kick Nomad+PirateSoftware+shortcut0 GET OUT!

                        if ((aCmdArg.SelfOk or aCmdArg.AcceptSelf) and IsAny(sUserArgLower, "self")) then
                            hArgReplacement = hPlayer
                        elseif ((aCmdArg.AllOk or aCmdArg.AcceptAll) and IsAny(sUserArgLower, "all", "everyone")) then
                            hArgReplacement = ALL_PLAYERS
                        else
                            SendMessage({
                                Message = "@command_argPlayerNotFound",
                            }, { Player = sUserArg, Index = sArgIndex, Name = sCommand })
                            return
                        end
                    end

                    if (hArgReplacement ~= ALL_PLAYERS) then
                        if (aCmdArg.EqualAccess) then
                            if (hArgReplacement:GetAccess() > hPlayer:GetAccess()) then
                                SendMessage(self.Responses.InsufficientAccess, { Player = sUserArg, Index = sArgIndex, Name = sCommand })
                                return
                            end
                        elseif ((aCmdArg.NotUser or aCmdArg.NotSelf) and hPlayer == hArgReplacement) then
                            SendMessage({
                                Message = "@command_argNotSelf"
                            }, { Player = sUserArg, Index = sArgIndex, Name = sCommand })
                            return
                        end
                    end

                elseif (iArgType == CommandArg_TypeNumber) then
                    hArgReplacement = tonumber(sUserArg)
                    if (not hArgReplacement) then
                        SendMessage({
                            Message = "@command_argNotNumber"
                        }, { Player = sUserArg, Index = sArgIndex, Name = sCommand })
                        return
                    end

                    if (iArgMax and hArgReplacement > iArgMax) then
                        if (aCmdArg.ForceLimit) then
                            hArgReplacement = iArgMax
                        else
                            SendMessage({
                                Message = "@command_argTooHigh"
                            }, { Player = sUserArg, Index = sArgIndex, Name = sCommand })
                            return
                        end
                    end

                    if (iArgMin and hArgReplacement < iArgMin) then
                        if (aCmdArg.ForceLimit) then
                            hArgReplacement = iArgMin
                        else
                            SendMessage({
                                Message = "@command_argTooLow"
                            }, { Player = sUserArg, Index = sArgIndex, Name = sCommand })
                            return
                        end
                    end

                elseif (iArgType == CommandArg_TypeTime) then

                    hArgReplacement = Date:ParseTime(sUserArg)
                    if (aCmdArg.AcceptInvalidTime and (sUserArgLower == "-1" or sUserArgLower == "never")) then
                        hArgReplacement = -1

                    elseif (hArgReplacement < 1) then
                        SendMessage({
                            Message = "@command_argInvalidTime"
                        }, { Player = sUserArg, Index = sArgIndex, Name = sCommand })
                        return
                    end

                    if (iArgMax and hArgReplacement > iArgMax) then
                        if (aCmdArg.ForceLimit) then
                            hArgReplacement = iArgMax
                        else
                            SendMessage({
                                Message = "@command_argTooHigh"
                            }, { Player = sUserArg, Index = sArgIndex, Name = sCommand })
                            return
                        end
                    end

                    if (iArgMin and hArgReplacement < iArgMin) then
                        if (aCmdArg.ForceLimit) then
                            hArgReplacement = iArgMin
                        else
                            SendMessage({
                                Message = "@command_argTooLow"
                            }, { Player = sUserArg, Index = sArgIndex, Name = sCommand })
                            return
                        end
                    end

                elseif (iArgType == CommandArg_TypeTeam) then
                    hArgReplacement = Server.Utils:GetTeam_Number(sUserArgLower)
                    if (not hArgReplacement) then
                        SendMessage({
                            Message = "@command_argInvalidTeam"
                        }, { Team = sUserArgLower, Name = sCommand })
                        return
                    end

                elseif (iArgType == CommandArg_TypeCVar) then

                    hArgReplacement = ({ Server.Utils:FindCVarByName(sUserArgLower, hPlayer) })
                    if (hArgReplacement[1]) then
                    elseif (IsArray(hArgReplacement[2])) then
                        SendMessage({
                            Success = true,
                            NoStatus = true,
                            Message = hArgReplacement[3],
                        }, { CVar = sUserArgLower, Name = sCommand })
                        return
                    end

                    hArgReplacement = (hArgReplacement[2] or sUserArg)
                    if (not Server.Utils:GetCVar(hArgReplacement)) then
                        SendMessage({
                            Message = "@command_argNotACVar"
                        }, { CVar = sUserArgLower, Name = sCommand })
                        return
                    end

                elseif (iArgType == CommandArg_TypeAccess) then
                    hArgReplacement = Server.AccessManager:FindAccessByNameOrId(sUserArgLower)
                    if (not hArgReplacement) then
                        SendMessage({
                            Message = "@command_argNotAccess"
                        }, { Arg = sUserArgLower, Name = sCommand })
                        return
                    end

                    hArgReplacement = hArgReplacement.Level

                elseif (iArgType == CommandArg_TypeMessage) then

                    -- TODO: Concat ONLY up to the point of a required argument??
                    --- to make THIS possible !rename PirateSoftware im out of mana <ADMIN DECISION>
                    --- so we will treat REASON argument as the stop for concatenation ??
                    ---

                    hArgReplacement = sUserArg
                    for i = (iArg + 1), table.size(tArgs) do
                        hArgReplacement = (hArgReplacement .. " " .. (tArgs[i] or ""))
                    end
                    hArgReplacement = hArgReplacement:gsub("(%s+)$", "")
                    bBreak = true

                elseif (iArgType == CommandArg_TypeString) then
                elseif (iArgType == CommandArg_TypeBoolean) then

                    hArgReplacement = true
                    if (IsAny(sUserArgLower, "0", "false", "no")) then
                        hArgReplacement = false
                    end

                end

                if (hArgReplacement ~= nil) then
                    tArgs[iArg] = hArgReplacement
                end

                if (bBreak) then
                    break
                end
            end

            -- ===========================================================================

            for _, sArg in pairs(tArgs) do
                table.insert(tPushArguments, sArg)
            end

            local sArguments = table.it(tArgs, function(x, i, v) return (x or "") .. (i>0 and ", " or "") .. tostring(v)  end)
            local hFunction = aCommand.Function
            local aResponse = { pcall(hFunction, unpack(tPushArguments)) }
            if (not aResponse[1]) then
                aCommand:Break()
                SendMessage(self.Responses.ScriptError, { Name = sCommand })
                self:LogError("Failed to Execute Command '%s'", sCommand)
                self:LogError("Arguments: %s", (string.empty(sArguments) and "<None>" or sArguments))
                self:LogError("%s", tostring(aResponse[2]))
                return
            end

            local bOk = aResponse[2]
            local sReply = aResponse[3]

            -- Sound Response!
            local bSoundFeedback = self.Properties.SendSoundFeedback
            local sFeedback      = "sounds/interface:hud:pda_update"

            if (bOk == false) then
                if (sReply) then
                    SendMessage({
                        Message = sReply,
                    }, { Name = sCommand })
                else
                    SendMessage(self.Responses.Failed, { Name = sCommand })
                end

                return
            elseif (bOk == nil) then
                SendMessage(self.Responses.NoFeedback, { Name = sCommand })
            elseif (bOk == true or bOk == CmdResp_Success) then
                if (sReply) then
                    SendMessage({
                        Success = true,
                        Message = sReply,
                    }, { Name = sCommand })
                else
                    SendMessage(self.Responses.Success, { Name = sCommand })
                end
            elseif (bOk == CmdResp_SuccessQuiet) then
                if (sReply) then
                    SendMessage({
                        Success = true,
                        Message = sReply,
                        ChatOnly = true
                    }, { Name = sCommand })
                else
                    SendMessage(self.Responses.Success, { Name = sCommand })
                end

            elseif (bOk == CmdResp_RawMessage) then
                if (sReply) then
                    SendMessage({
                        Success = true,
                        Message = sReply,
                        ChatOnly = true,
                        RawMessage = true,
                    }, { Name = sCommand })
                else
                    SendMessage(self.Responses.Success, { Name = sCommand })
                end
            end

            if (bSoundFeedback) then
                if (g_gameRules.IS_PS) then
                    g_gameRules.onClient:ClBuyOk(hPlayer:GetChannel(), "nnn")
                else
                    Server.ClientMod:ExecuteCode({ Code = "CryMP_Client:PSE(nil,'" .. sFeedback .. "')", Clients = hPlayer })
                end
            end

            aCommand:SetCoolDown(hPlayer.id)
            if (bProcessPayment) then
               -- hPlayer:AddPrestige(-iPrice, ("@str_command !%s @str_used"):format(sCommand:upper()))
                g_gameRules:PrestigeEvent(hPlayer.id, -iPrice, ("@str_command !%s @str_used"):format(sCommand:upper()))
            end

            -- XP
            Server.PlayerRanks:XPEvent(hPlayer, XPEvent_CommandUsed)
        end,

        ConvertArgumentType = function(self, iType, sKey)
            local aTypeList = {
                [-1] = {
                    Long = "Unknown-Type",
                    Short = "?",
                    Locale = "@arg_unknown",
                    Color = CRY_COLOR_RED,
                },
                [CommandArg_TypeBoolean] = {
                    Long = "Boolean",
                    Short = "B",
                    Locale = "@arg_boolean",
                    Color = CRY_COLOR_BLUE,
                },
                [CommandArg_TypeNumber] = {
                    Long = "Number",
                    Short = "N",
                    Locale = "@arg_number",
                    Color = CRY_COLOR_ORANGE,
                },
                [CommandArg_TypeTime] = {
                    Long = "Time",
                    Short = "T",
                    Locale = "@arg_time",
                    Color = CRY_COLOR_ORANGE,
                },
                [CommandArg_TypeString] = {
                    Long = "String",
                    Short = "S",
                    Locale = "@arg_string",
                    Color = CRY_COLOR_WHITE,
                },
                [CommandArg_TypeAccess] = {
                    Long = "Access",
                    Short = "A",
                    Locale = "@arg_access",
                    Color = CRY_COLOR_YELLOW,
                },
                [CommandArg_TypePlayer] = {
                    Long = "Player",
                    Short = "P",
                    Locale = "@player",
                    Color = CRY_COLOR_GREEN
                },
                [CommandArg_TypeMessage] = {
                    Long = "Message",
                    Short = "C",
                    Locale = "@arg_message",
                    Color = CRY_COLOR_WHITE,
                },
                [CommandArg_TypeCVar] = {
                    Long = "CVar",
                    Short = "V",
                    Locale = "@arg_cvar",
                    Color = CRY_COLOR_WHITE,
                },
                [CommandArg_TypeTeam] = {
                    Long = "Team",
                    Short = "T",
                    Locale = "@team",
                    Color = CRY_COLOR_WHITE,
                },
            }

            local tInfo = (aTypeList[iType] or aTypeList[-1])
            if (sKey) then
                return tInfo[sKey]
            end
            return tInfo
        end,

        SortCommands = function(self, aList)

            -- Fill in User Groups
            local aSorted = {}
            for i = Server.AccessHandler:GetLowestAccess(), Server.AccessHandler:GetHighestAccess() do
                aSorted[i] = {}
            end

            local iAccess
            for _, aCommand in pairs(aList) do

                iAccess = aCommand.Access
                table.insert(aSorted[iAccess], aCommand)
            end

            for _ in pairs(aSorted) do
                table.sort(aSorted[_], function(a, b) return (a.Name < b.Name)  end)
            end

            -- Remove Empty templates
            for i, v in pairs(aSorted) do
                if (table.empty(v)) then
                    aSorted[i] = nil
                end
            end

            return aSorted
        end,

        ListCommands = function(self, hPlayer, aCustomList, sFilter)

            local aCommandList   = self:SortCommands(table.copy(aCustomList or self.Commands))
            local iItemsPerLine  = 5
            local iCommandWidth  = 20  -- Fixed item width for command names
            local iCommandCount  = table.count(aCommandList)
            local iLineWidth     = Server.Chat:GetConsoleWidth()

            local iPlayerAccess  = hPlayer:GetAccess()

            local sRank, sRankColor
            local sCmdColor

            local iTotalDisplayed = 0
            local iDisplayed = 0
            local iCmdCount = 0
            local sCmdLine  = ""

            local bPS = (g_gameRules.class == POWER_STRUGGLE)

            --for _, aCommands in pairs(aCommandList) do
            for _ = Server.AccessHandler:GetLowestAccess(), Server.AccessHandler:GetHighestAccess() do

                local aCommands = aCommandList[_]

                sRank      = Server.AccessHandler:GetAccessName(_)
                sRankColor = Server.AccessHandler:GetAccessColor(_)

                if (iPlayerAccess >= _ and table.count(aCommands) > 0) then
                    Server.Chat:ConsoleMessage(hPlayer, " ")
                    Server.Chat:ConsoleMessage(hPlayer, "$9===" .. string.rspace((" [ " .. sRankColor .. sRank .. " $9($1" .. table.count(aCommands) .. "$9)" .. " $9] "), iLineWidth, string.COLOR_CODE, "="))
                    ---Server.Chat:ConsoleMessage(hPlayer, "$9" .. string.mspace((" [ " .. sRankColor .. sRank .. " $9($1" .. table.count(aCommands) .. "$9)" .. " $9] "), iLineWidth, 1, string.COLOR_CODE, "="))
                    Server.Chat:ConsoleMessage(hPlayer, " ")

                    sCmdLine = "    "
                    iCmdCount = 0
                    iDisplayed = 0
                    for __, aCmd in pairs(aCommands) do

                        local sCmdName = aCmd.Name
                        if (not aCmd:IsHidden() and (not sFilter or string.match(sCmdName:lower(), sFilter:lower()))) then
                            sCmdColor = CRY_COLOR_GRAY
                            if (sFilter) then
                                local iStart, iEnd = string.find(string.lower(sCmdName), string.lower(sFilter), 1, true)
                                if (iStart) then
                                    sCmdName = ("$9%s$6%s$9%s"):format((sCmdName:sub(1, iStart - 1)), (sCmdName:sub(iStart, iEnd)):upper(), (sCmdName:sub(iEnd + 1)))
                                end
                            end
                            if (aCmd:IsBroken() or aCmd:IsDisabled()) then
                                sCmdColor = CRY_COLOR_RED
                            end

                            sCmdLine = (sCmdLine .. string.rspace(CRY_COLOR_WHITE .. "!$9" .. sCmdColor .. sCmdName .. "", iCommandWidth, string.COLOR_CODE))
                            iCmdCount = (iCmdCount + 1)
                            iTotalDisplayed = iTotalDisplayed + 1
                            if (iCmdCount % iItemsPerLine == 0) then
                                Server.Chat:ConsoleMessage(hPlayer, CRY_COLOR_GRAY .. sCmdLine)
                                iDisplayed = iDisplayed + 1
                                sCmdLine = "    "
                            end
                        end
                    end

                    if (not string.empty(sCmdLine)) then
                        Server.Chat:ConsoleMessage(hPlayer, CRY_COLOR_GRAY .. sCmdLine)
                        iDisplayed = iDisplayed + 1
                    end

                    if (iDisplayed == 0 and sFilter) then
                        Server.Chat:ConsoleMessage(hPlayer, "      {Gray}@command_noFilterMatch", { Filter = sFilter })
                    end
                end
            end

            local sHelpLine1 = hPlayer:LocalizeText("@commandList_help_1")--string.mspace(hPlayer:LocalizeText("@commandList_help_1"), iLineWidth, nil, string.COLOR_CODE)
            Server.Chat:ConsoleMessage(hPlayer, " ")
            Server.Chat:ConsoleMessage(hPlayer, "      " .. sHelpLine1)
            Server.Chat:ConsoleMessage(hPlayer, "      " .. hPlayer:LocalizeText("@commandList_help_2"))

            return true, hPlayer:LocalizeText("@entitiesListedInConsole", { Class = "@commands", Count = iTotalDisplayed })
        end,
    }
})