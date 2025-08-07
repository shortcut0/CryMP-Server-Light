-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- This file Contains Date-Formatting Utilities
-- ===================================================================================

--------------
ONE_YEAR         = 31536000  -- 60 * 60 * 24 * 365
ONE_MONTH        = 2592000   -- 60 * 60 * 24 * 30
ONE_WEEK         = 604800    -- 60 * 60 * 24 * 7
ONE_DAY          = 86400     -- 60 * 60 * 24
THREE_HOURS      = 10800     -- 60 * 60 * 3
ONE_HOUR         = 3600      -- 60 * 60
HALF_HOUR        = 1800      -- 60 * 30
FIFTEEN_MINUTES  = 900       -- 60 * 15
TEN_MINUTES      = 600       -- 60 * 10
FIVE_MINUTES     = 300       -- 60 * 5
ONE_MINUTE       = 60        -- 60
ONE_SECOND       = 1         -- 1

DateFormat_Days = 2
DateFormat_Hours = 4
DateFormat_Minutes = 8
DateFormat_Cramped = 16
DateFormat_Comma = 32

--------------
Date = {
    __type = { "date" }, --"date",
}

--------------
Date.Init = function(self)

    --[[
    local sometime = math.random(1000,99999)
    local future = math.random(1000,99999)

    local hTest = self:New("10d")
    local hTest2 = self:New(ONE_DAY * 20)
    local hTest3 = self:New(os.date("*t"))

    local hTest_SOMETIME = self:New(sometime)
    local DATE_FUTURE=self:New(future)
    local DATE_past=self:New(-future)

    DebugLog("Now    :", self:New():ToSeconds())
    DebugLog("Diff Now and 10d  :",hTest:DiffNow(),hTest:DiffNowFmt())
    DebugLog("test1_expired     :", hTest:Expired())
    DebugLog("Diff Now and 20d  :",hTest2:DiffNow(),hTest2:DiffNowFmt())
    DebugLog("test1_expired     :", hTest2:Expired())
    DebugLog("Diff Now and *t   :",hTest3:DiffNow(),hTest3:DiffNowFmt())
    DebugLog("test1_expired     :", hTest3:Expired())
    DebugLog("Diff Now and somet:",hTest_SOMETIME:DiffNow(),hTest_SOMETIME:DiffNowFmt())
    DebugLog("test1_expired     :", hTest_SOMETIME:Expired())
    DebugLog("futureand now     :",DATE_FUTURE:DiffNow(),DATE_FUTURE:DiffNowFmt())
    DebugLog("test1_expired     :", DATE_FUTURE:Expired())
    DebugLog("past      now     :",DATE_past:DiffNow(),DATE_past:DiffNowFmt())
    DebugLog("test1_expired     :", DATE_past:Expired())
    DebugLog("diff OLD and FUT  :",DATE_FUTURE:Diff(DATE_past))

    DebugLog(Date:Format(math.random(9,99)))
    DebugLog(Date:Format(math.random(99,999)))
    DebugLog(Date:Format(math.random(999,9999)))
    DebugLog(Date:Format(math.random(9999,99999)))
    DebugLog(Date:Format(math.random(99999,999999)))
    DebugLog(Date:Format(math.random(999999,9999999)))
    ]]

end

--------------
Date.New = function(self, hTime)

    local iSeconds = self:GetTimestamp()
    if (IsString(hTime)) then
        iSeconds = iSeconds + self:ParseTime(hTime)
    elseif (IsNumber(hTime)) then
        iSeconds = iSeconds + hTime
    elseif (self:IsDate(hTime)) then
        iSeconds = iSeconds + hTime:ToSeconds()
    elseif (self:IsOSDate(hTime)) then
    end


    if (not IsNumber(iSeconds)) then
        error("invalid time identifier specified")
    end

    local hDate = {
        __type = self.__type,
        __date = os.date("*t", iSeconds),
    }

    hDate.Format = function(this, iTime, iType) -- difference between this and now
        if (iTime == nil) then
            iTime = os.time(this.__date)
        end
        if (iType == nil) then
            iType = 1
        end
        return Date:Format(iTime, iType)
    end

    -- Returns the difference in seconds between the date handle and now
    hDate.Validate = function(this, hTime)
        if (hTime < 0) then
            hTime = 0
        end
        return hTime
    end

    -- Returns the time in seconds since EPOCH to this date
    hDate.ToSeconds = function(this)
        return (os.time(this.__date))
    end

    -- Returns true if this date has expired
    hDate.Expired = function(this)
        return (this:DiffNow() > 0)
    end

    -- Returns the difference in seconds between the date handle and now
    hDate.DiffNow = function(this)
        return (os.time() - os.time(this.__date))
    end

    -- Returns the formatted difference in seconds between the date handle and now
    hDate.DiffNowFmt = function(this, iType)
        return this:Format(this:DiffNow(), iType)
    end

    -- Returns the difference in seconds between this and another date handle (or time in seconds)
    hDate.Diff = function(this, hDiff)
        local iDiff = hDiff
        if (Date:IsDate(hDiff)) then
            iDiff = os.time(hDiff.__date)
        end
        return (os.time(this.__date) - iDiff)
    end

    -- Returns the formatted difference in seconds between this and another date handle
    hDate.DiffFmt = function(this, hDiff)
        return this:Format(this:Diff(hDiff))
    end

    -- Adds more time in seconds to this date handle
    hDate.AddTime = function(this, hAdd)
        this.__date = os.date("*t", this:Validate(os.time(this.__date) + hAdd))
    end

    -- Subtracts time in seconds from this date handle
    hDate.SubTime = function(this, hSub)
        this.__date = os.date("*t", this:Validate(os.time(this.__date) - hSub))
    end

    return hDate
end

--------------
Date.IsOSDate = function(self, hDate)
    local bContainsAll = true
    local aContainsKeys = { "year", "month", "day", "hour", "min", "sec", "wday", "yday", "isdst" }
    return (IsArray(hDate) and table.containsK(hDate, aContainsKeys, bContainsAll))
end

--------------
Date.IsDate = function(self, hDate)
    return (IsArray(hDate) and hDate.__type == self.__type)
end

--------------
Date.GetTimestamp = function(self)
    return os.time()
end

--------------
Date.Colorize = function(self, sDate, sNumberColor, sDotColor)

    sNumberColor = sNumberColor or CRY_COLOR_RED
    sDotColor = sDotColor or CRY_COLOR_GRAY

    return string.gsub(sDate, "(%d+)", sNumberColor .. "%1" .. sDotColor)
end

--------------
Date.Format = function(self, iTime, iType, iUnitLimit)

    local bFuture = (iTime < 0)
    if (bFuture) then
        iTime = (iTime * -1)
    end

    if (iTime < 1) then
        return ("%dms"):format(iTime * 1000)
    end

    local aUnits = {
        { Name = "y", 		  Value = 86400 * 365 },      				-- Years
        { Name = "d", 		  Value = 86400 },           			 	-- Days
        { Name = "h", 		  Value = 3600, PadZero = true },            				-- Hours
        { Name = "m", 		  Value = 60, PadZero = true },               			 	-- Minutes
        { Name = "s", 		  Value = 1, PadZero = true },                			    -- Seconds
    }

    iType = iType or 0
    if (BitAND(iType, DateFormat_Days) ~= 0) then
        table.remove(aUnits,#aUnits)
        table.remove(aUnits,#aUnits)
        table.remove(aUnits,#aUnits)
    elseif (BitAND(iType, DateFormat_Hours) ~= 0) then
        table.remove(aUnits,#aUnits)
        table.remove(aUnits,#aUnits)

    elseif (BitAND(iType, DateFormat_Minutes) ~= 0) then
        table.remove(aUnits,#aUnits)
    end

    local iUnits = table.size(aUnits)
    if (iUnitLimit) then
        while (iUnits > 1 and iUnits > iUnitLimit) do
            table.popFirst(aUnits)
            iUnits = table.count(aUnits)
        end
    end

    local aResult = {}

    for _, aUnit in ipairs(aUnits) do
        local aUnitInfo = { math.floor(iTime / aUnit.Value), iTime % aUnit.Value }
        table.insert(aResult, { Name = aUnit.Name, Value = aUnitInfo[1] })
        iTime = aUnitInfo[2]
    end

    local function Format(iStyle)

        local aFormatted = {}
        local iFirstNonZero = #aResult

        for i, aUnit in ipairs(aResult) do
            if (aUnit.Value > 0) then
                iFirstNonZero = i
                break
            end
        end
        for i = iFirstNonZero, #aResult do
            table.insert(aFormatted, string.format("%" .. (aResult[i].PadZero and "02" or "") .. "d%s", aResult[i].Value, aResult[i].Name))
        end

        if (BitAND(iStyle, DateFormat_Comma) ~= 0) then
            return table.concat(aFormatted, ", ")
        elseif (BitAND(iStyle, DateFormat_Cramped) ~= 0) then
            return table.concat(aFormatted, ":")
        end
        return table.concat(aFormatted, ": ")

        --[[

        local aFormatted = {}
        local bIncludeNext = false
        for i, aUnit in ipairs(aResult) do
            if (aUnit.Value > 0) then
                bIncludeNext = true
            end
            if (bIncludeNext or i == #aResult) then
                table.insert(aFormatted, string.format("%d%s", aUnit.Value, aUnit.Name))
            end
        end
        local sForced4 = string.match(table.concat(aFormatted, ": "), "^(%d+%w+:?%s+%d+%w+:?%s+%d+%w+:?%s+%d+%w+).*")
        local sForced3 = string.match(table.concat(aFormatted, ": "), "^(%d+%w+:?%s+%d+%w+:?%s+%d+%w+).*")
        local sForced2 = string.match(table.concat(aFormatted, ": "), "^(%d+%w+:?%s+%d+%w+).*")

        if (iStyle == DateFormat_Array) then -- { 0, 3, 53 }
            return table.CleanArray(aFormatted, { "Value" })

        elseif (iStyle == DateFormat_Comma) then -- 0d, 3h, 53m
            return table.concat(aFormatted, ", ")

        elseif (iStyle == DateFormat_Spaced) then -- 0d: 3h: 53m
            return table.concat(aFormatted, ": ")

        elseif (iStyle == DateFormat_Forced4) then -- 0y: 0d: 3h: 53m
            return sForced4

        elseif (iStyle == DateFormat_Forced3) then -- 0d: 3h: 53m
            return sForced3

        elseif (iStyle == DateFormat_Forced2) then -- 0h: 53m
            return sForced2

        else
            return table.concat(aFormatted, ": ")
        end
        --]]
    end

    -- TODO
    -- FIXME
    local bNoAttachments = true
    if (bNoAttachments) then
        return Format(iType)
    end
    return ((bFuture and "In " or "") .. Format(iType) .. (not bFuture and " Ago" or ""))
end

--------------
Date.ParseTime = function(self, sInput)

    if (not sInput) then
        return 0
    elseif (string.sub(sInput, -1) == "m") then
        sInput = sInput .. "0" -- hax for fixing string.match getting confused over 'mo' and 'm'
    end

    if (string.match(ToString(sInput),"^%d+$")) then
        return tonumber(sInput)
    end

    local sTime = string.gsub(sInput, "%s", "")

    -- for randomizing times, eg: 10m-1h (random time between 10 mins and 1 hour)
    local sPre, sPost = string.match(sInput, "^(.*)%-(.*)$")
    if (sPre and sPost) then
        local iPre = self:ParseTime(sPre)
        local iPost = self:ParseTime(sPost)
        return math.random(iPre, iPost)
    end

    local aParsed = {
        tonumber(string.match(sTime, "(%d+)y")      or 0) * ONE_YEAR,   -- Years
        tonumber(string.match(sTime, "(%d+)mo")     or 0) * ONE_MONTH,  -- Months
        tonumber(string.match(sTime, "(%d+)w")      or 0) * ONE_WEEK,   -- Weeks
        tonumber(string.match(sTime, "(%d+)d")      or 0) * ONE_DAY,    -- Days
        tonumber(string.match(sTime, "(%d+)h")      or 0) * ONE_HOUR,   -- Hours
        tonumber(string.match(sTime, "(%d+)m[^o]")  or 0) * ONE_MINUTE, -- Minutes
        tonumber(string.match(sTime, "(%d+)s")      or 0) * ONE_SECOND, -- Seconds
    }

    return table.it(aParsed, function(x, i, v) return ((x or 0) + v)  end)
end

--------------
Date:Init()