-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- This file Contains the Server Statistics Component
-- ===================================================================================

Server:CreateComponent({
    Name = "Statistics",
    FriendlyName = "Stats",
    Body = {

        ExternalData = {
            { Name = "Statistics.lua", Path = SERVER_DIR_DATA .. "Server\\", Key = "Statistics" }
        },

        Protected = {
            Statistics = {}
        },

        Initialize = function(self)
        end,

        PostInitialize = function(self)
        end,

        Event = function(self, hEvent, hValue)

            LuaUtils.Switch (hEvent,

                    -- Total Channels & Channel Records
                    { StatisticsEvent_OnNewChannel, {
                        { self.AddValue, self, StatisticsValue_ChannelCount, 1 },
                        { self.IncreaseValue, self, StatisticsValue_ChannelRecord, hValue }
                    } },

                    -- Server life time in seconds
                    { StatisticsEvent_ServerLifetime, { self.AddValue, self, StatisticsValue_ServerLifetime, hValue } }
            )
        end,

        GetValue = function(self, hStat, hDefault)
            local hValue = self.Statistics[hStat]
            if (hValue == nil) then
                return hDefault
            end
            return hValue
        end,

        SetValue = function(self, hStat, hValue)
            self:ModifyStat(hStat, hValue)
        end,

        AddValue = function(self, hStat, iAdd)
            self:ModifyStat(hStat, (self.Statistics[hStat] or 0) + iAdd)
        end,

        IncreaseValue = function(self, hStat, iNewValue)
            local iValue = self.Statistics[hStat]
            if (iValue == nil or (iNewValue > iValue)) then
                self:ModifyStat(hStat, iNewValue)
            end
        end,

        ModifyStat = function(self, hStat, hValue)
            self.Statistics[hStat] = hValue
        end,
    }
})
