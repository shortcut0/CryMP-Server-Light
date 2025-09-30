-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- Super Simple AFK-Kicker Plugin
-- ===================================================================================

Server.Plugins:CreatePlugin("AFK-Kicker", {

    -- Disable/Enable the plugin here (or by prefixing the plugin name with a '!')
    PluginStatus = PLUGIN_DISABLED,

    -- Config
    PluginConfig = {
        { Config = "MaxAFKTime", Key = "MaxAFKTime", Default = FIVE_MINUTES },
    },

    -- Called when the plugin is being loaded
    Initialize = function(self)
    end,

    -- Called during post-initialization (when GameRules entity has spawned)
    PostInitialize = function(self)
    end,

    Event_OnActorTick = function(self, tPlayer)
        if (tPlayer.Timers.LastAction.Expired(FIVE_MINUTES)) then
            Server.Punisher:KickPlayer(Server:GetEntity(), tPlayer, "afk too long")
        end
    end,
})