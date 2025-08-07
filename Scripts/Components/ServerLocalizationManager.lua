-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
--          This file contains the Server's Localization Manager and translator
-- ===================================================================================

Server:CreateComponent({
    Name = "LocalizationManager",
    FriendlyName = "Locale",
    Body = {

        ComponentPriority = PRIORITY_LOWER,

        ExternalData = {
            { Name = "", NamePattern = "%.lua$", Path = (SERVER_DIR_DATA .. "Locale"), Recursive = true, ReadOnly = true }
        },

        LocalizationList = {
        },

        RussianEnglishMap = {
            ["А"] = "A", ["а"] = "a",
            ["Б"] = "6", ["б"] = "6",
            ["В"] = "B", ["в"] = "B",
            ["Г"] = "r", ["г"] = "r",
            ["Д"] = "D", ["д"] = "d",
            ["Е"] = "E", ["е"] = "e",
            ["Ё"] = "E", ["ё"] = "e",
            ["Ж"] = "X", ["ж"] = "x",
            ["З"] = "3", ["з"] = "3",
            ["И"] = "N", ["и"] = "n",
            ["Й"] = "N", ["й"] = "n",
            ["К"] = "K", ["к"] = "k",
            ["Л"] = "n", ["л"] = "n",
            ["М"] = "M", ["м"] = "m",
            ["Н"] = "H", ["н"] = "h",
            ["О"] = "O", ["о"] = "o",
            ["П"] = "Π", ["п"] = "n",
            ["Р"] = "P", ["р"] = "p",
            ["С"] = "C", ["с"] = "c",
            ["Т"] = "T", ["т"] = "t",
            ["У"] = "Y", ["у"] = "y",
            ["Ф"] = "O", ["o"] = "f",
            ["Х"] = "X", ["х"] = "x",
            ["Ц"] = "u", ["ц"] = "u",
            ["Ч"] = "Y", ["ч"] = "Y",
            ["Ш"] = "W", ["ш"] = "w",
            ["Щ"] = "W", ["щ"] = "w",
            ["Ъ"] = "b", ["ъ"] = "b",
            ["Ы"] = "bI",["ы"] = "bI",
            ["Ь"] = "b", ["ь"] = "b",
            ["Э"] = "3", ["э"] = "3",
            ["Ю"] = "IO",["ю"] = "io",
            ["Я"] = "R", ["я"] = "R",
        },

        Initialize = function(self)
            self:Log("Registered %d Strings with %d Localizations", table.size(self.LocalizationList), table.countRec(self.LocalizationList, function(_, v)
                return ((_ == "Languages") and table.size(v) or 0)
            end))
        end,

        PostInitialize = function(self)

            --[[
            ServerRank_Moderator=60
            ServerLog(self:LocalizeMessage("@test_locale HellO!!!", Language_English, {{Arg1="aaa",Arg2="bbb"}}, 59))
            ServerLog(self:LocalizeMessage("@test_locale HellO!!!", Language_English, {{Ext1="ccc",Ext2="ddd",Arg1="aaa",Arg2="bbb"}}, 60))
            ServerLog(self:LocalizeMessage("@test_nested_locale", Language_English, {}, 60))
            ServerLog(self:LocalizeMessage("@test_nested_locale_3", Language_English, {}, 60))
            ]]
        end,

        -- A series of strings, e.g "Hello! @test_locale World? @test_locale"
        LocalizeForPlayer = function(self, hPlayer, sMessage, tFormat)

            local sLanguage = hPlayer:GetLanguage()
            local iExtended = hPlayer:GetAccess()

            return self:LocalizeMessage(sMessage, sLanguage, tFormat, iExtended)
        end,

        -- A series of strings, e.g "Hello! @test_locale World? @test_locale"
        LocalizeMessage = function(self, sMessage, sLanguage, tFormat, iExtended)

            if (not string.find(sMessage, "@")) then
                return Server.Logger:FormatTags(sMessage)
            end

            if (not table.IsRecursive(tFormat)) then
                tFormat = { tFormat }
            end

            local iDepth = 1
            local iMaxDepth = 10
            local sNextLocale
            local sNextLocalized
            local sLocalizedMessage = sMessage

            while (iDepth <= iMaxDepth) do
                sNextLocale = string.match(sLocalizedMessage, "(@[%w_]+)")
                if (not sNextLocale) then
                    break -- all processed!
                end

                sNextLocalized = self:LocalizeString(sNextLocale:sub(2), sLanguage, tFormat[iDepth], iExtended)
                sLocalizedMessage = string.gsub(sLocalizedMessage, sNextLocale, sNextLocalized)

                iDepth = (iDepth + 1)
            end

            if (iDepth >= iMaxDepth) then
                self:LogWarning("Localization Recursion too deep! Message is '%s'", sMessage)
            end

            return Server.Logger:FormatTags(sLocalizedMessage)
        end,

        -- A singular string, e.g "test_locale"
        LocalizeString = function(self, sString, sLanguage, tFormat, iExtended)

            local aLocaleInfo = self:GetLocaleInfo(sString)
            if (not aLocaleInfo) then
                self:LogWarning("Localization Info for String '%s' not found!", sString)
                return ("{missing_%s}"):format(sString)
            end

            local sLocalized = aLocaleInfo.Languages[string.lower(sLanguage)]
            if (not sLocalized) then
                if (sLanguage ~= Language_None) then
                    self:LogWarning("Language %s not found for String %s. Reverting to English", sLanguage, sString)
                end
                sLocalized = aLocaleInfo.Languages[string.lower(Language_English)]
            end

            if (IsTable(sLocalized)) then
                if (sLanguage.Extended and (iExtended == true or (sLocalized.Extended and (iExtended and iExtended >= aLocaleInfo.Extended)))) then
                    sLocalized = sLocalized.Extended
                else
                    sLocalized = sLocalized.Regular
                end
            end

            if (not sLocalized) then
                self:LogWarning("Failed to Resolve Language '%s' for String %s.", sLanguage, sString)
                sLocalized = aLocaleInfo.Languages[string.lower(Language_English)]
            end

            if (table.emptyN(tFormat)) then
                for sFind, sReplace in pairs(tFormat) do
                    sLocalized = string.gsub(sLocalized, "{" .. sFind .. "}", sReplace)
                end
            else
            --    self:LogWarning("No format provided for String '%s'", sString)
            end

            sLocalized = Server.Logger:FormatTags(sLocalized)
            return sLocalized
        end,

        GetLocaleInfo = function(self, sId)
            return self.LocalizationList[string.lower(sId)]
        end,

        --[[         --- Reference ----
        Server.LocalizationManager:Add({
            String = "test_locale",
            Extended = ServerRank_Moderator,
            Languages = {
                English = {
                    Standard = "translated to english - standard {Arg_One}",
                    Extended = "translated to english - extended {Arg_Ext]",
                },
                English = "translated to english {Arg_Two}",
            }
        })]]

        Add = function(self, tLocaleInfo)

            if (table.IsRecursive(tLocaleInfo)) then
                for _, aInfo in pairs(tLocaleInfo) do
                    self:Add(aInfo)
                end
                return
            end

            local sId = string.lower(tLocaleInfo.String)
            local tExistingLocale = self:GetLocaleInfo(sId)

            local aLanguages = {}
            for sLang, hValue in pairs(tLocaleInfo.Languages) do
                aLanguages[string.lower(sLang)] = hValue
            end

            if (tExistingLocale) then
                tExistingLocale.Languages = table.Merge(tExistingLocale.Languages, aLanguages or {})
                self:LogWarning("Duplicated Locale Information for '%s'! Merging Languages", sId)
                return
            end

            tLocaleInfo.Languages = aLanguages
            self.LocalizationList[sId] = tLocaleInfo
        end
    }
})