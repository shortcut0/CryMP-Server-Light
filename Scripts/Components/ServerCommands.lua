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

            CommandPrefixList = {
                ".",
                "!",
                "/",
            }
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
        end,

        PostInitialize = function(self)

            self:RegisterCommands()

            local iCommandsLoaded = table.size(self.CommandMap)
            self:LogEvent({
                Event = self:GetName(),
                Recipients = Server.Utils:GetPlayers({ ByAccess = Server.AccessHandler:GetAdminLevel() }),
                Message = [[@commands_loaded]],
                MessageFormat = { Count = iCommandsLoaded },
            })
        end,

        Add = function(self, aInfo)
            table.insert(self.CollectedCommands, aInfo)
        end,

        RegisterCommands = function(self)
            for _, aInfo in pairs(self.CollectedCommands) do
                self:RegisterCommand(aInfo)
            end

            self.CollectedCommands = nil
        end,

        RegisterCommand = function(self, aInfo)
            local sName         = aInfo.Name
            local aArguments    = aInfo.Arguments
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

            if (not tProperties.Access) then
                self:LogWarning("No Access to ChatCommands:Add() %s, Assuming Lowest", sName)
                tProperties.Access = Server.AccessHandler:GetLowestAccess()
            end

            if (self.CommandMap[string.lower(sName)]) then
                self:LogError("Duplicated Command Name '%s'", sName)
                return
            end

            if (not tProperties) then
                tProperties = {}

            else
            end

            if (not aArguments) then
                aArguments = {}
            end

            self.CommandMap[string.lower(sName)] = self:BuildCommand(sName, aArguments, tProperties, hFunction)
        end,

        BuildCommand = function(self, sName, aArguments, tProperties, hFunction)

            local sNameLower = string.lower(sName)
            self.CommandMap[sNameLower] = {

                m_DisabledReason = "@admin_decision",
                m_IsDisabled = false,
                m_IsBroken   = false,
                m_IsHidden   = (tProperties.Hidden),

                CoolDowns = {
                },

                Name        = string.lower(sName),
                Access      = (tProperties.Access),
                Properties  = tProperties,
                Arguments   = aArguments,
                Function    = hFunction,

                -- Functions
                IsHidden    = function(this) return this.m_IsHidden  end,
                Hide        = function(this, bMode) this.m_IsHidden = bMode end,
                IsDisabled  = function(this) return this.m_IsDisabled end,
                Disable     = function(this, bMode) this.m_IsDisabled = bMode end,
                GetDisabledReason = function(this) local sReason = this.m_DisabledReason return CheckStringEx(sReason, "", " (" .. sReason .. ")") end,
                IsBroken    = function(this) return this.m_IsBroken end,
                Break       = function(this, bMode) this.m_IsBroken = bMode end,
                IsQuiet     = function(this) return this.Properties.IsQuiet  end,
                SetCoolDown = function(this, sId, iTimer) iTimer = iTimer or (this.Properties.CoolDown or 0) if (not this.CoolDowns[sId]) then this.CoolDowns[sId] = TimerNew(iTimer) end this.CoolDowns[sId].refresh() end,
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
                    elseif (string.match(sName, ("^" .. sCommandName))) then
                        table.insert(aResults, aCommand)
                    elseif (bGreedy and iCommandLength > 1) then
                        local iStepBack = math.GetMax(1, iCommandLength - 3)
                        for i = string.len(sCommandName), iStepBack, -1 do
                            local sGreedyMatch = string.sub(sCommandName, 1, i)
                            if (string.match(sName, ("^" .. sGreedyMatch))) then
                                table.insert(aResults, aCommand)
                                break
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

            local sCommandUpper = string.upper(tFormat.Name)
            local sPlayerName = hPlayer:GetName()
            local aLogRecipients = Server.Utils:GetPlayers({ NotById = hPlayer.id, ByAccess = hPlayer:GetAccess(Server.AccessHandler:GetAdminLevel()) })

            local sConsole_Log  -- Admins
            local sConsole_Msg  -- Player

            local sChat_Log -- Admins
            local sChat_Msg -- Player

            -- Yandere Dev made this, don't judge - rewrite pending..
            if (tMessage.Success) then
                if (tMessage.NoStatus) then

                    -- TEST : Open your Console to view the [ 3 ] Matches!
                    sConsole_Log = ("(%s{Gray})"):format(CRY_COLOR_GREEN .. tMessage.Message)
                    sConsole_Msg = CRY_COLOR_GREEN .. tMessage.Message
                    sChat_Log = CRY_COLOR_GREEN .. tMessage.Message
                    sChat_Msg = CRY_COLOR_GREEN .. tMessage.Message
                elseif (tMessage.NoMessage) then

                    -- return true
                    -- TEST : Success
                    sConsole_Log = CRY_COLOR_GREEN .. "@str_success"
                    sConsole_Msg = CRY_COLOR_GREEN .. "@str_success"
                    sChat_Log = CRY_COLOR_GREEN .. "@str_success"
                    sChat_Msg = ""
                else

                    -- return true, "Function Returned Ok!"
                    -- TEST : Function returned Ok!
                    sConsole_Log = ("(%s{Gray})"):format(CRY_COLOR_GREEN .. tMessage.Message)
                    sConsole_Msg = CRY_COLOR_GREEN .. tMessage.Message
                    sChat_Log = tMessage.Message
                    sChat_Msg = tMessage.Message
                end
            elseif (tMessage.NoFeedback) then
                if (tMessage.NoStatus) then

                    -- TEST : Open your Console to view the [ 3 ] Matches!
                    sConsole_Log = CRY_COLOR_ORANGE .. tMessage.Message
                    sConsole_Msg = CRY_COLOR_ORANGE .. tMessage.Message
                    sChat_Log = CRY_COLOR_ORANGE .. tMessage.Message
                    sChat_Msg = ""
                elseif (tMessage.NoMessage) then

                    -- return false
                    -- TEST : Failed
                    sConsole_Log = ("(%s{Gray})"):format(CRY_COLOR_ORANGE .. "@str_noFeedback")
                    sConsole_Msg = CRY_COLOR_ORANGE .. "@str_noFeedback"
                    sChat_Log = "@str_noFeedback"
                    sChat_Msg = "@str_noFeedback"
                else

                    -- return false, "Function Returned BAD!"
                    -- TEST : Error (Function returned BAD!)
                    sConsole_Log = CRY_COLOR_ORANGE .. "@str_noFeedback {Gray}({Orange}" .. tMessage.Message .. "{Gray})"
                    sConsole_Msg = CRY_COLOR_ORANGE .. "@str_noFeedback {Gray}({Orange}" .. tMessage.Message .. "{Gray})"
                    sChat_Log = "@str_noFeedback (" .. tMessage.Message .. ")"
                    sChat_Msg = "@str_noFeedback (" .. tMessage.Message .. ")"
                end
            else--if (tMessage.Failed) then
                if (tMessage.NoStatus) then

                    -- TEST : Open your Console to view the [ 3 ] Matches!
                    sConsole_Log = ("(%s{Gray})"):format(CRY_COLOR_RED .. tMessage.Message)
                    sConsole_Msg = CRY_COLOR_RED .. tMessage.Message
                    sChat_Log = CRY_COLOR_RED .. tMessage.Message
                elseif (tMessage.NoMessage) then

                    -- return false
                    -- TEST : Failed
                    sConsole_Log = ("(%s{Gray})"):format(CRY_COLOR_RED .. "@str_failed")
                    sConsole_Msg = CRY_COLOR_RED .. "@str_failed"
                    sChat_Log = "@str_failed"
                    sChat_Msg = "@str_failed"
                else

                    -- return false, "Function Returned BAD!"
                    -- TEST : Error (Function returned BAD!)
                    sConsole_Log = CRY_COLOR_RED .. "@str_failed {Gray}({Red}" .. tMessage.Message .. "{Gray})"
                    sConsole_Msg = CRY_COLOR_RED .. "@str_failed {Gray}({Red}" .. tMessage.Message .. "{Gray})"
                    sChat_Log = "@str_failed (" .. tMessage.Message .. ")"
                    sChat_Msg = "@str_failed (" .. tMessage.Message .. ")"
                end

            end

            -- Admins:
            if (string.emptyN(sChat_Log)) then
                Server.Chat:ChatMessage(hPlayer, aLogRecipients, ("(!%s  :  %s)"):format(sCommandUpper, sChat_Log), { tFormat, tFormat })
            end
            if (string.emptyN(sConsole_Log)) then
                self:LogEvent({
                    Event = self:GetFriendlyName(),
                    Recipients = aLogRecipients,
                    Message = "@command_consoleLog",
                    MessageFormat = { Name = hPlayer:GetName(), Command = sCommandUpper, Reply = sConsole_Log }
                })
                local sArguments = (tFormat.__Arguments__ or "<{Green}S{Gray}: {Green}Nomad{Gray}> <{Blue}N{Gray}: {Blue}669{Gray}>, <{Orange}P{Gray}: {Orange}Nomad{Gray}>, <{Yellow}Msg{Gray}: {Yellow}out of mana..{Gray}>, <{Red}?{Gray}: {Red}third!{Gray}>")
                if (string.emptyN(sArguments)) then
                    self:LogEvent({
                        Event = self:GetFriendlyName(),
                        Recipients = aLogRecipients,
                        Message = ("@str_arguments %s"):format(sArguments),
                        MessageFormat = {}
                    })
                end
            end
            -- Players:
            if (string.emptyN(sChat_Msg)) then
                Server.Chat:ChatMessage(Server:GetEntity(), hPlayer, ("%s  :  %s"):format(sCommandUpper, sChat_Msg), { tFormat, tFormat })
            end
            if (string.emptyN(sConsole_Msg)) then
                Server.Chat:ConsoleMessage(hPlayer, ("   (!%s: %s)"):format(sCommandUpper, sConsole_Msg), { tFormat, tFormat })
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
                self:ListCommands(hPlayer, aCommandList)
                return true -- Block Message
            end


            self:ProcessCommand(hPlayer, aCommandList[1], tArgs)
            return true -- Block Message
        end,

        ProcessCommand = function(self, hPlayer, aCommand, tArgs, iType)

            local sCommand = aCommand.Name
            local aCommandArgs   = aCommand.Arguments
            local iCommandAccess = aCommand.Access
            local sCommandAccess = Server.AccessHandler:GetAccessName(iCommandAccess)
            local iPremiumAccess = Server.AccessHandler:GetPremiumLevel()

            local bIsAdmin = hPlayer:IsAdministrator()
            local bIsDeveloper = hPlayer:IsDeveloper()
            local bInTestMode = (hPlayer:IsInTestMode() or hPlayer:IsServerOwner())
            local iPlayerAccess = hPlayer:GetAccess()
            local bInsufficientAccess = (iPlayerAccess < iCommandAccess)

            if (aCommand:IsBroken() and not bIsDeveloper) then
                self:SendMessage(hPlayer, self.Responses.Broken, { Name = sCommand })
                return
            end

            if (aCommand:IsDisabled() and not bIsDeveloper) then
                self:SendMessage(hPlayer, self.Responses.Disabled, { Name = sCommand, Reason = aCommand:GetDisabledReason() })
                return
            end

            if ((aCommand.Access == iPremiumAccess and bInsufficientAccess)) then
                self:SendMessage(hPlayer, self.Responses.Reserved, { Name = sCommand, Class = sCommandAccess })
                return
            end

            if (not bIsAdmin and bInsufficientAccess) then
                self:SendMessage(hPlayer, self.Responses.InsufficientAccess, { Name = sCommand })
                return
            end

            if (bInsufficientAccess) then
                self:SendMessage(hPlayer, self.Responses.NotFound, { Name = sCommand }, iType)
                return
            end

            local tProperties = aCommand.Properties
            local bProcessPayment = false

            local sGameRules  = tProperties.GameRules
            local bInVehicle  = tProperties.Vehicle
            local bInDoors    = tProperties.InDoors
            local bDead       = tProperties.Alive
            local bSpectating = tProperties.Spectating
            local iPrice      = tProperties.Price

            local bPlayerInVehicle  = hPlayer:IsInVehicle()
            local bPlayerInDoors    = hPlayer:IsInDoors()
            local bPlayerDead       = hPlayer:IsDead()
            local bPlayerSpectating = hPlayer:IsSpectating()
            local iPlayerPrestige   = hPlayer:GetPrestige()

            if (not bInTestMode) then

                if (sGameRules and sGameRules ~= g_gameRules.class) then
                    self:SendMessage(hPlayer, self.Responses.GameRules, { Name = sCommand, Class = sGameRules })
                    return
                end

                local bCooledDown, iExpiry = aCommand:GetCoolDown(hPlayer.id)
                if (not bCooledDown) then
                    self:SendMessage(hPlayer, self.Responses.CoolDown, { Name = sCommand, Time = Date:Format(iExpiry) })
                    return
                end

                if (bSpectating ~= nil) then
                    if (bSpectating ~= bPlayerSpectating) then
                        self:SendMessage(hPlayer, (bSpectating and self.Responses.Spectating or self.Responses.NotSpectating ), { Name = sCommand })
                        return
                    end
                end

                if (bDead ~= nil) then
                    if (bDead ~= bPlayerDead) then
                        self:SendMessage(hPlayer, (bDead and self.Responses.Dead or self.Responses.NotDead ), { Name = sCommand })
                        return
                    end
                end

                if (bInVehicle ~= nil) then
                    if (bInVehicle ~= bPlayerInVehicle) then
                        self:SendMessage(hPlayer, (bInVehicle and self.Responses.InVehicle or self.Responses.NotInVehicle ), { Name = sCommand })
                        return
                    end
                end

                if (bInDoors ~= nil) then
                    if (bInDoors ~= bPlayerInDoors) then
                        self:SendMessage(hPlayer, (bInDoors and self.Responses.InDoors or self.Responses.NotInDoors ), { Name = sCommand })
                        return
                    end
                end

                if (sGameRules == GameMode_PS) then
                    if (iPrice ~= nil) then
                        if (iPrice > iPlayerPrestige) then
                            self:SendMessage(hPlayer, self.Responses.InsufficientPrestige, { Name = sCommand })
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
                    table.insert(tPushArguments, CheckGlobal(pSelf))
                else
                    table.insert(tPushArguments, pSelf)
                end
                aCommand.This = tPushArguments[1] -- Cache for later
            end
            table.insert(tPushArguments, hPlayer)

            -- ===========================================================================
            -- Check Arguments

            local sUserArg, sUserArgLower

            for iArg, aCmdArg in pairs((aCommandArgs)) do

                sUserArg = tArgs[iArg]

                -- Assign default
                if (sUserArg == nil and aCmdArg.Default) then
                    sUserArg = aCmdArg.Default
                    tArgs[iArg] = aCmdArg.Default
                end

                -- Still empty!
                if (sUserArg == nil) then
                    if (aCmdArg.Required) then
                        local sIndex = ("<%d>"):format(iArg)
                        if (aCmdArg.Type ~= nil) then
                            sIndex = ("<%d (%s)>"):format(iArg, self:ConvertArgumentType(aCmdArg.Type))
                        end
                        self:SendMessage(hPlayer, {
                            Message = "@command_argNMissing",
                        }, { Index = sIndex, Name = sCommand })
                        return
                    end
                end
            end

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
                            self:SendMessage(hPlayer, {
                                Message = "@command_argPlayerNotFound",
                            }, { Player = sUserArg, Index = sArgIndex, Name = sCommand })
                            return
                        end
                    end

                    if (hArgReplacement ~= ALL_PLAYERS) then
                        if (aCmdArg.EqualAccess) then
                            if (hArgReplacement:GetAccess() > hPlayer:GetAccess()) then
                                self:SendMessage(hPlayer, self.Responses.InsufficientAccess, { Player = sUserArg, Index = sArgIndex, Name = sCommand })
                                return
                            end
                        elseif (aCmdArg.NotUser and hPlayer == hArgReplacement) then
                            self:SendMessage(hPlayer, {
                                Message = "@command_argNotSelf"
                            }, { Player = sUserArg, Index = sArgIndex, Name = sCommand })
                            return
                        end
                    end

                elseif (iArgType == CommandArg_TypeNumber) then
                    hArgReplacement = tonumber(sUserArg)
                    if (not hArgReplacement) then
                        self:SendMessage(hPlayer, {
                            Message = "@command_argNotNumber"
                        }, { Player = sUserArg, Index = sArgIndex, Name = sCommand })
                        return
                    end

                    if (iArgMax and hArgReplacement > iArgMax) then
                        if (aCmdArg.ForceLimit) then
                            hArgReplacement = iArgMax
                        else
                            self:SendMessage(hPlayer, {
                                Message = "@command_argTooHigh"
                            }, { Player = sUserArg, Index = sArgIndex, Name = sCommand })
                            return
                        end
                    end

                    if (iArgMin and hArgReplacement < iArgMin) then
                        if (aCmdArg.ForceLimit) then
                            hArgReplacement = iArgMin
                        else
                            self:SendMessage(hPlayer, {
                                Message = "@command_argTooLow"
                            }, { Player = sUserArg, Index = sArgIndex, Name = sCommand })
                            return
                        end
                    end

                elseif (iArgType == CommandArg_TypeTime) then

                    hArgReplacement = Date:ParseTime(sUserArg)
                    if (hArgReplacement < 1) then
                        self:SendMessage(hPlayer, {
                            Message = "@command_argInvalidTime"
                        }, { Player = sUserArg, Index = sArgIndex, Name = sCommand })
                        return
                    end

                    if (iArgMax and hArgReplacement > iArgMax) then
                        if (aCmdArg.ForceLimit) then
                            hArgReplacement = iArgMax
                        else
                            self:SendMessage(hPlayer, {
                                Message = "@command_argTooHigh"
                            }, { Player = sUserArg, Index = sArgIndex, Name = sCommand })
                            return
                        end
                    end

                    if (iArgMin and hArgReplacement < iArgMin) then
                        if (aCmdArg.ForceLimit) then
                            hArgReplacement = iArgMin
                        else
                            self:SendMessage(hPlayer, {
                                Message = "@command_argTooLow"
                            }, { Player = sUserArg, Index = sArgIndex, Name = sCommand })
                            return
                        end
                    end

                elseif (iArgType == CommandArg_TypeCVar) then

                    hArgReplacement = ({ Server.Utils:FindCVarByName(sUserArgLower, hPlayer) })
                    if (hArgReplacement[1]) then
                    elseif (IsArray(hArgReplacement[2])) then
                        self:SendMessage(hPlayer, {
                            Success = true,
                            NoStatus = true,
                            Message = hArgReplacement[3],
                        }, { CVar = sUserArgLower, Name = sCommand })
                        return
                    end

                    hArgReplacement = (hArgReplacement[2] or sUserArg)
                    if (not Server.Utils:GetCVar(hArgReplacement)) then
                        self:SendMessage(hPlayer, {
                            Message = "@command_argNotACVar"
                        }, { CVar = sUserArgLower, Name = sCommand })
                        return
                    end

                elseif (iArgType == CommandArg_TypeAccess) then
                    hArgReplacement = Server.AccessManager:FindAccessByNameOrId(sUserArgLower)
                    if (not hArgReplacement) then
                        self:SendMessage(hPlayer, {
                            Message = "@command_argNotAccess"
                        }, { Arg = sUserArgLower, Name = sCommand })
                        return
                    end

                    hArgReplacement = hArgReplacement.Level

                elseif (iArgType == CommandArg_TypeMessage) then

                    hArgReplacement = sUserArg
                    for i = (iArg + 1), table.size(aCommandArgs) do
                        hArgReplacement = (hArgReplacement .. " " .. aCommandArgs[i])
                    end
                    break

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
                self:SendMessage(hPlayer, self.Responses.ScriptError, { Name = sCommand })
                self:LogError("Failed to Execute Command '%s'", sCommand)
                self:LogError("Arguments: %s", (string.empty(sArguments, "<None>")))
                self:LogError("%s", ToString(aResponse[2]))
                return
            end

            local bOk = aResponse[2]
            local sReply = aResponse[3]

            if (bOk == false) then
                if (sReply) then
                    self:SendMessage(hPlayer, {
                        Message = sReply,
                    }, { Name = sCommand })
                else
                    self:SendMessage(hPlayer, self.Responses.Failed, { Name = sCommand })
                end
                return
            elseif (bOk == nil) then
                self:SendMessage(hPlayer, self.Responses.NoFeedback, { Name = sCommand })
            elseif (bOk == true) then
                if (sReply) then
                    self:SendMessage(hPlayer, {
                        Success = true,
                        Message = sReply,
                    }, { Name = sCommand })
                else
                    self:SendMessage(hPlayer, self.Responses.Success, { Name = sCommand })
                end
            end


            aCommand:SetCoolDown(hPlayer.id)
            if (bProcessPayment) then
                hPlayer:AddPrestige(-iPrice, ("@str_command !%s @str_used"):format(sCommand:upper()))
            end
        end,

        ConvertArgumentType = function(self, iType, bShort)
            local aTypeList = {
                [-1] = {
                    Long = "Unknown-Type",
                    Short = "?"
                },
                [CommandArg_TypeBoolean] = {
                    Long = "Boolean",
                    Short = "B"
                },
                [CommandArg_TypeNumber] = {
                    Long = "Number",
                    Short = "N"
                },
                [CommandArg_TypeTime] = {
                    Long = "Time",
                    Short = "T"
                },
                [CommandArg_TypeString] = {
                    Long = "String",
                    Short = "S"
                },
                [CommandArg_TypeAccess] = {
                    Long = "Access",
                    Short = "A"
                },
                [CommandArg_TypePlayer] = {
                    Long = "Player",
                    Short = "P"
                },
                [CommandArg_TypeMessage] = {
                    Long = "Message",
                    Short = "C"
                },
                [CommandArg_TypeCVar] = {
                    Long = "CVar",
                    Short = "V"
                },
            }

            return (aTypeList[iType] or aTypeList[-1])[(bShort and "Short" or "Long")]
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

            local iCmdCount = 0
            local sCmdLine  = ""

            local bPS = (g_gameRules.class == POWER_STRUGGLE)

            for _, aCommands in pairs(aCommandList) do

                sRank      = Server.AccessHandler:GetAccessName(_)
                sRankColor = Server.AccessHandler:GetAccessColor(_)

                if (iPlayerAccess >= _ and table.count(aCommands) > 0) then
                    Server.Chat:ConsoleMessage(hPlayer, " ")
                    Server.Chat:ConsoleMessage(hPlayer, "$9" .. string.mspace((" [ " .. sRankColor .. sRank .. " $9($4" .. table.count(aCommands) .. "$9)" .. " $9] "), iLineWidth, 1, string.COLOR_CODE, "="))
                    Server.Chat:ConsoleMessage(hPlayer, " ")

                    sCmdLine = "    "
                    iCmdCount = 0
                    for __, aCmd in pairs(aCommands) do

                        if (not aCmd:IsHidden()) then
                            sCmdColor = CRY_COLOR_GRAY
                            if (aCmd:IsBroken() or aCmd:IsDisabled()) then
                                sCmdColor = CRY_COLOR_RED
                            end

                            sCmdLine = (sCmdLine .. string.rspace(CRY_COLOR_WHITE .. "!$9" .. sCmdColor .. aCmd.Name .. "", iCommandWidth, string.COLOR_CODE))
                            iCmdCount = (iCmdCount + 1)
                            if (iCmdCount % iItemsPerLine == 0) then
                                Server.Chat:ConsoleMessage(hPlayer, CRY_COLOR_GRAY .. sCmdLine)
                                sCmdLine = "    "
                            end
                        end
                    end

                    if (not string.empty(sCmdLine)) then
                        Server.Chat:ConsoleMessage(hPlayer, CRY_COLOR_GRAY .. sCmdLine)
                    end
                end
            end

            local sHelpLine1 = hPlayer:LocalizeText("@commandList_help_1")--string.mspace(hPlayer:LocalizeText("@commandList_help_1"), iLineWidth, nil, string.COLOR_CODE)
            Server.Chat:ConsoleMessage(hPlayer, " ")
            Server.Chat:ConsoleMessage(hPlayer, "      " .. sHelpLine1)
            Server.Chat:ConsoleMessage(hPlayer, "      " .. hPlayer:LocalizeText("@commandList_help_2"))
        end,
    }
})