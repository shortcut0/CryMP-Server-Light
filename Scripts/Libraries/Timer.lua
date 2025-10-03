-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- This file Contains Timer Utilities
-- ===================================================================================

---@class Timer
---@field Creation number      -- Time the timer was created (os.clock)
---@field Timer number         -- Last refresh time (os.clock)
---@field Expiry number        -- Expiry duration in seconds
Timer = {}

-- ==================================
---@param self Timer
---@param iMs number|nil expiry duration in seconds (default: 0)
---@return Timer newTimer a new timer instance
Timer.New = function(self, iMs)

    if (type(self) == "number") then
        iMs = self
    end
    iMs = (iMs or 0)

    local tInherit = {
        "Expired", "Expire", "GetExpiry", "SetExpiry", "GetSetExpiry",
        "Refresh", "Expired_Refresh", "Diff", "Diff_C"
    }

    local tTimer = {
        Creation = os.clock(),
        Timer = os.clock(),
        Expiry = iMs,
    }

    for _, sFunction in pairs(tInherit) do
        tTimer[sFunction] = Timer[sFunction]
    end

    return tTimer
end

-- ==================================
---@param self Timer
---@param i number expiry duration in seconds
Timer.SetExpiry = function(self, i)
    assert(type(i) == "number")
    self.Expiry = i
end

-- ==================================
---@param self Timer
---@return number expiry original expiry duration that was set
Timer.GetSetExpiry = function(self)
    return self.Expiry
end

-- ==================================
---@param self Timer
---@param i number|nil optional new expiry duration
Timer.Refresh = function(self, i)
    self.Timer = os.clock()
    if (i) then
        self:SetExpiry(i)
    end
end

-- ==================================
---@param self Timer
---@param i number|nil optional override expiry duration
---@return boolean expired true if the timer has expired
Timer.Expired = function(self, i)
    return (self:Diff() >= (i or self.Expiry))
end

-- ==================================
---@param self Timer
---@param i number|nil optional override expiry duration
---@return boolean expired true if expired, and refreshes if so
Timer.Expired_Refresh = function(self, i)
    return (self:Expired(i) and (self:Refresh(i) or true) or false)
end

-- ==================================
---@param self Timer
---@return number remaining seconds until expiry (0 if no expiry set)
Timer.GetExpiry = function(self)
    if (not self.Expiry) then
        return 0
    end
    return (self.Expiry - self:Diff(self.Timer))
end

-- ==================================
---@param self Timer
---@param i number|nil optional new expiry duration
Timer.Expire = function(self, i)
    if (i) then
        self:SetExpiry(i)
    end
    self.Timer = os.clock() - (self.Expiry or 0)
end

-- ==================================
---@param self Timer
---@return number seconds since creation
Timer.Diff_C = function(self)
    return self:Diff(self.Creation)
end

-- ==================================
---@param self Timer
---@param t number|nil reference time (default: last refresh)
---@return number seconds since reference time
Timer.Diff = function(self, t)
    return (os.clock() - (t or self.Timer))
end

-- ==================================
---@param self Timer
---@return number diff seconds since last refresh
---@return nil always returns nil as second value (refresh side effect)
Timer.Diff_Refresh = function(self)
    return self:Diff(), self:Refresh()
end
