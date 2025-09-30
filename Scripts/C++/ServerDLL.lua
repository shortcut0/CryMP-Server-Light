-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- A dummy file to demonstrate the functions provided by the ServerDLL library
-- C++ Implementation
-- ===================================================================================

---@class ServerDLL
ServerDLL = {}

-- ================== Utility ==================
--- Returns current map name
--- @return string
function ServerDLL.GetMapName() end

--- Returns a random float between 0 and 1
--- @return number
function ServerDLL.Random() end

--- Sets a script callback
--- @param callback string
--- @param handler function
function ServerDLL.SetCallback(callback, handler) end

--- Returns SHA256 hash of text
--- @param text string
--- @return string
function ServerDLL.SHA256(text) end

--- URL-encodes a string
--- @param text string
--- @return string
function ServerDLL.URLEncode(text) end

--- Returns list of master servers
--- @return table
function ServerDLL.GetMasters() end

--- Returns model file path for given entity slot
--- @param entityId EntityId
--- @param slot number
--- @return string
function ServerDLL.GetModelFilePath(entityId, slot) end

--- Returns current LP value
function ServerDLL.GetLP() end

--- Returns number of variables
function ServerDLL.GetNumVars() end

--- Returns all registered variables
function ServerDLL.GetVars() end

--- Returns map maximum XY size
function ServerDLL.GetMapMaxSizeXY() end

--- Returns minimap bounding box for a level
--- @param mapName string
function ServerDLL.GetMiniMapBBox(mapName) end

--- Enables or disables script error logging
--- @param mode boolean
function ServerDLL.SetScriptErrorLog(mode) end

-- ================== Filesystem ==================
--- Returns server root path
function ServerDLL.GetRoot() end

--- Returns working directory
function ServerDLL.GetWorkingDir() end

--- Saves data into a file
--- @param file string
--- @param data string
function ServerDLL.SaveFile(file, data) end

-- ================== Server Modes ==================
--- Returns true if running dedicated server
function ServerDLL.IsDedicated() end

--- Returns true if multiplayer is enabled
function ServerDLL.IsMultiplayer() end

--- Returns true if running as client
function ServerDLL.IsClient() end

--- Sets dedicated mode
--- @param mode boolean
function ServerDLL.SetDedicated(mode) end

--- Sets multiplayer mode
--- @param mode boolean
function ServerDLL.SetMultiplayer(mode) end

--- Sets client mode
--- @param mode boolean
function ServerDLL.SetClient(mode) end

--- Sets server mode
--- @param mode boolean
function ServerDLL.SetServer(mode) end

--- Returns true if running as server
function ServerDLL.IsServer() end

--- Returns item category by item name
--- @param item string
function ServerDLL.GetItemCategory(item) end

--- Returns all available levels
function ServerDLL.GetLevels() end

--- Returns true if entity class is valid
--- @param class string
function ServerDLL.IsValidEntityClass(class) end

--- Returns true if item class is valid
--- @param class string
function ServerDLL.IsValidItemClass(class) end

--- Returns script path for entity class
--- @param class string
function ServerDLL.GetScriptPath(class) end

--- Returns all entity classes
function ServerDLL.GetEntityClasses() end

--- Returns all item classes
function ServerDLL.GetItemClasses() end

--- Returns all vehicle classes
function ServerDLL.GetVehicleClasses() end

--- Explodes a projectile
--- @param id EntityId
function ServerDLL.ExplodeProjectile(id) end

--- Returns projectile owner entity id
--- @param id EntityId
function ServerDLL.GetProjectileOwnerId(id) end

--- Returns projectile position
--- @param id EntityId
--- @return Vector3
function ServerDLL.GetProjectilePos(id) end

--- Sets projectile position
--- @param id number
--- @param pos Vector3
function ServerDLL.SetProjectilePos(id, pos) end

-- ================== Entities ==================
--- Initializes GameRules script tables
function ServerDLL.GameRulesInitScriptTables() end

--- Sets entity script update rate
--- @param id EntityId
--- @param rate number
function ServerDLL.SetEntityScriptUpdateRate(id, rate) end

-- ================== Physics ==================
--- RayWorldIntersection (crash-prone)
function ServerDLL.RayWorldIntersection() end

-- ================== Networking ==================
--- Sends a network request
--- @param params table
--- @param callback function
function ServerDLL.Request(params, callback) end

--- Returns master server API
function ServerDLL.GetMasterServerAPI() end

--- Sets channel nickname
--- @param channel number
--- @param name string
function ServerDLL.SetChannelNick(channel, name) end

--- Returns channel nickname
--- @param channel number
function ServerDLL.GetChannelNick(channel) end

--- Returns channel IP
--- @param channel number
function ServerDLL.GetChannelIP(channel) end

--- Returns channel name
--- @param channel number
function ServerDLL.GetChannelName(channel) end

--- Returns true if channel is on hold
--- @param channel number
function ServerDLL.IsChannelOnHold(channel) end

--- Returns true if channel exists
--- @param channel number
function ServerDLL.IsExistingChannel(channel) end

--- Returns channel network statistics
--- @param channel number
function ServerDLL.GetChannelNetStatistics(channel) end

--- Returns global network statistics
function ServerDLL.GetNetStatistics() end

--- Returns true if channel is local
--- @param channel number
function ServerDLL.IsChannelLocal(channel) end

--- Kicks a channel
--- @param type string
--- @param channel number
--- @param reason string
function ServerDLL.KickChannel(type, channel, reason) end

--- Updates GameSpy report
--- @param type string
--- @param key string
--- @param val string
function ServerDLL.UpdateGameSpyReport(type, key, val) end

--- Returns game version
function ServerDLL.GetGameVersion() end

-- ================== CVars ==================
--- Sets a console variable
--- @param cvar string
--- @param value any
function ServerDLL.FSetCVar(cvar, value) end

-- ================== Pathfinding ==================
--- Runs A* pathfinding
--- @param handle string
--- @param start Vector3
--- @param goal Vector3
--- @param callback function
function ServerDLL.AStar_Path(handle, start, goal, callback) end

-- ================== System ==================
--- Returns memory usage
function ServerDLL.GetMemUsage() end

--- Returns peak memory usage
function ServerDLL.GetMemPeak() end

--- Returns CPU usage
function ServerDLL.GetCPUUsage() end

--- Returns CPU name
function ServerDLL.GetCPUName() end

--- Returns PMC info
--- @param id number
function ServerDLL.GetPMCInfo(id) end
