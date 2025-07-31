-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- This file Contains the Actor Handler Component
-- ===================================================================================

Server:CreateComponent({
    Name = "ActorHandler",
    Body = {

        Protected = {
        },

        Initialize = function(self)
        end,

        PostInitialize = function(self)
        end,

        OnActorSpawn = function(self, hActor)

            hActor.TimerInitialized = TimerNew()
            hActor.Initialized = true

            local bIsPlayer = hActor.actor:IsPlayer()
            local iChannel = hActor.actor:GetChannelId()

            hActor.Info = {

                IsPlayer  = bIsPlayer,
                ChannelId = iChannel,
                ProfileId = "0",
                IPAddress = "127.0.0.1",
                HostName  = "localhost",

                GeoData   = Server.Network:GetGeoInfo(iChannel)
            }

            if (bIsPlayer) then
                hActor.Info.IPAddress = ServerDLL.GetChannelIP(iChannel)
                hActor.Info.HostName  = ServerDLL.GetChannelName(iChannel)
            end

            self:AddActorFunctions(hActor)
        end,

        AddActorFunctions = function(self, hActor)

            if (hActor.Info.IsPlayer) then
            end

            hActor.GetIPAddress = function(this) return this.Info.IPAddress  end
            hActor.GetHostName  = function(this) return this.Info.HostName  end
            hActor.GetProfileId = function(this) return this.Info.ProfileId  end
            hActor.GetChannel   = function(this) return this.Info.ChannelId  end

            hActor.IsHuman      = function(this) return this.Info.IsPlayer  end
        end,
    }
})