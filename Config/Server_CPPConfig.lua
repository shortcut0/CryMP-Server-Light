-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- This is the DLL Configuration File
-- ===================================================================================

Server_CPPConfig = {

    -- The Main Server Script to load in Server::LoadScript()
    ServerScript = "\\Scripts\\Server.lua",

    -- The host for Script events (don't forget the dot at the end!)
    EventHost = "Server.Events.Callbacks.",

    -- If Server should always enforce HTTP on all Network Requests
    ForceHTTPOverHTTPs = false,

    -- If enabled, upon loading a script, the server will check if an identical file is present inside the overwrite folder
    -- if there is, that one will be loaded INSTEAD.
    UseAutomaticScriptRedirection = true,
}