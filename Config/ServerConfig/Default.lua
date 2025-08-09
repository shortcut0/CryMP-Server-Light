-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- A Server Configuration file
-- ===================================================================================

Server.Config:Create({
    Active = true,
    Name = "Default",
    Body = {

        ------------------------------------------
        --- Console Variables
        Network = {

            -- A list of CVars which will be forced to specified value
            ForcedCVars = {
                SERVER_USE_HIT_QUEUE = 0,
            } ---< ForcedCVars

        }, ---< Network

        ------------------------------------------
        --- General Server Configuration
        Server = {

            -- The Name of Server
            ServerName = "CryMP ~~ {MapName} ~~",

            -- The Description which will appear on the Website
            ServerDescription = "CryMP-Server"

        }, ---< Server

        ------------------------------------------
        --- General Server Configuration
        Server = {
        }, ---< Server

        ------------------------------------------
        --- Game Configuration
        GameConfig = {

            -- Will skip the annoying Pre-Game!
            SkipPreGames = true,

        }, ---< GameConfig

        ------------------------------------------
        --- Map Configuration
        MapConfig = {

            -- A list of forbidden maps
            ForbiddenMaps = {
                PowerStruggle = {
                    "Shore"
                },
                InstantAction = {
                    DisableAll = true, -- This will disable all instant action maps at once
                },
            },

            -- The Map rotation the server will cycle through
            MapRotation = {

                -- The Default time limits for unspecific or unknown types
                DefaultTimeLimits = {

                    -- All others
                    Other = ONE_HOUR,

                    -- PS & IA
                    PowerStruggle = ONE_HOUR,
                    InstantAction = ONE_MINUTE * 30,
                }, ---< DefaultTimeLimits

                -- The Rotation will ignore all maps that do not have a download-link available
                IgnoreNonDownloadable = true,

                -- The Rotation will cycle through all available maps
                UseAvailableMaps = true,

                -- The Rotation will be shuffled each cycle
                ShuffleRotation = true,

                -- The list of Maps
                MapList = {
                    { Path = "Multiplayer/PS/Mesa",     TimeLimit = "5m", Enabled = true },
                    { Path = "Multiplayer/PS/Shore",    TimeLimit = "5m", Enabled = true },
                    { Path = "Multiplayer/PS/Beach",    TimeLimit = "5m", Enabled = true },
                    { Path = "Multiplayer/PS/Refinery", TimeLimit = "5m", Enabled = true },
                } ---< MapList

            },
        }, ---< MapConfig




    },
})