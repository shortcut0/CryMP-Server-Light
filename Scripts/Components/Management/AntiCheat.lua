--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- Contains the Server Anti-Cheat Script-Side Component
-- ===================================================================================

Server:CreateComponent({

    Name = "AntiCheat",
    FriendlyName = "Defense",
    Body = {

        -- Automatic [Config] creation and loading
        ComponentConfig = {
            { Config = "AntiCheat.IsEnabled", Key = "Status", Default = true, Type = nil --[[ConfigType_Boolean]] }
        },

        Initialize = function(self)
            self:Log("Status: %s", string.bool(self.Config.Status))
        end,

        PostInitialize = function(self)
        end,

        OnCheat = function(self, tInfo)
        end,
    }
})