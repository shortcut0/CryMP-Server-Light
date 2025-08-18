-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- Some trash Sandbox Component for testing interesting and funny crysis things
-- Not for Release version!! make sure to delete and ignore this file!!!
-- ===================================================================================

Server:CreateComponent({
    Name = "Sandbox",
    FriendlyName = "Sandbox",
    Body = {

        Protected = {
            States = {},
        },

        Initialize = function(self)
        end,

        PostInitialize = function(self)
        end,

        Event_OnUpdate = function(self)
        end,

        SetState = function(self, hIdState, hValue)
            self.States[hIdState] = hValue
        end,

        GetState = function(self, hIdState, hDefault)
            local hStateValue = self.States[hIdState]
            if (hStateValue == nil) then
                return hDefault
            end
            return hStateValue
        end,

        ToggleState = function(self, hIdState)
            local bIsEnabled = self.States[hIdState]
            if (not bIsEnabled) then
                bIsEnabled = true
            else
                bIsEnabled = false
            end
            self:SetState(hIdState, bIsEnabled)
            return bIsEnabled
        end,
    }
})