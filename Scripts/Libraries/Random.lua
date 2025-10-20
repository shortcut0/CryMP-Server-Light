-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- This file Contains Random number utilities
-- ===================================================================================

-- ===========================
--- @class Random a random number generator
Random = {
}

-- ===========================
Random.New = function(self, a, b, bIsInteger)

    local tInherit = {
        "Refresh",
        "GetIValue", "GetValue", "SetValue",
        "SetMin", "SetMax", "Set", "SetInt"
    }

    local tRandom = {
        Min = math.min(a, b),
        Max = math.max(a, b),
        Value = 0,
        IsInteger = (bIsInteger)
    }

    for _, sFunction in pairs(tInherit) do
        tRandom[sFunction] = Random[sFunction]
    end

    tRandom:Refresh() -- Initial refresh
    return tRandom
end

-- ===========================
Random.Refresh = function(self)
    local fVal = (self.Min + (self.Max - self.Min) * math.random())
    if (self.IsInteger) then
        fVal = math.floor(fVal + 0.5 * (fVal >= 0 and 1 or -1))
    end
    local fOldVal = self.Value
    self.Value = fVal
    return fVal, fOldVal
end

-- ===========================
Random.GetValue = function(self)
    return self.Value
end

-- ===========================
Random.GetValue_Refresh = function(self)
    local fTrash, fVal = self:Refresh()
    return fVal
end

-- ===========================
Random.GetIValue = function(self)
    return math.floor(self.Value + 0.5)
end

-- ===========================
Random.SetValue = function(self, n)
    self.Value = n
end

-- ===========================
Random.SetMin = function(self, min)
    self.Min = min
end

-- ===========================
Random.SetMax = function(self, max)
    self.Max = max
end

-- ===========================
Random.SetRange = function(self, a, b)
    self.Min = math.min(a, b)
    self.Max = math.max(a, b)
end

-- ===========================
Random.SetInt = function(self, bEnable)
    self.IsInteger = bEnable
end
