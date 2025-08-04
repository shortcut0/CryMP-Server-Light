-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- This is the Server Storage Component File
-- ===================================================================================

Server:CreateComponent({
    Name = "Storage",
    Body = {

        -- Put all keys that we wish to save & restore from Server{} inside here!!
        Protected = {
            ServerEntity = {},  -- The Server Entity which will be used to ban people!
        },

        Initialize = function(self)
            for sKey in pairs(self.Protected) do
                Server[sKey] = self[sKey]
            end
            self:Log("Synced %d Keys with the Server", table.count(self.Protected))
        end,

        PreInitialize = function(self)
            for sKey in pairs(self.Protected) do
                self[sKey] = Server[sKey]
                Server.ComponentData[self.Name][sKey] = self[sKey]
            end
        end,
    }
})