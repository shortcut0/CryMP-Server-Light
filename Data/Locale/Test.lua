-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- ===================================================================================

Server.LocalizationManager:Add({
    {
        String = "test_locale",
        Extended = 60, -- Users of this rank can see the extended message!
        Languages = {
            English = {
                Regular = "regular string -- A1={Arg1} A1={Arg2}.",
                Extended = "extended string -- E1={Ext1} E2={Ext2} A1={Arg1} A1={Arg1}."
            }
        }
    },
    {
        String = "test_nested_locale",
        Extended = 60, -- Users of this rank can see the extended message!
        Languages = {
            English = "back to two.. {@test_nested_locale_2}"
        }
    },
    {
        String = "test_nested_locale_2",
        Extended = 60, -- Users of this rank can see the extended message!
        Languages = {
            English = "back to one.. {@test_nested_locale}"
        }
    },
    {
        String = "test_nested_locale_3",
        Extended = 60, -- Users of this rank can see the extended message!
        Languages = {
            English = "back to self.. {@test_nested_locale_3}"
        }
    },
})
