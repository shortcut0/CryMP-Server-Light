-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- This is the Server Timer Component
-- ===================================================================================

Server:CreateComponent({
    Name = "Timers",
    Body = {

        ActiveTimers = {},

        Initialize = function(self)
        end,

        PostInitialize = function(self)
        end,

        CreateTimer = function(self, sTimer, iMs)
            self.ActiveTimers[sTimer] = TimerNew(iMs)
            return self.ActiveTimers[sTimer]
        end,

        Expired = function(self, sTimer, iMs)
            local hTimer = self.ActiveTimers[sTimer]
            if (hTimer == nil) then
                hTimer = self:CreateTimer(sTimer, iMs)
            end

            return hTimer.expired(iMs)
        end,

        Expired_Refresh = function(self, sTimer, iMs)
            local hTimer = self.ActiveTimers[sTimer]
            if (hTimer == nil) then
                hTimer = self:CreateTimer(sTimer, iMs)
            end

            return hTimer.expired_refresh(iMs)
        end,
    }
})