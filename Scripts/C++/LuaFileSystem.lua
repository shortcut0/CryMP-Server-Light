-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- A dummy file to demonstrate the functions provided by the LuaFileSystem C++ Implementation
-- ===================================================================================

---@class ServerLFS
LuaFileSystem = {}

-- ============================================================
-- File functions
-- ============================================================

---Checks if the given path is a valid file.
---@param file string Path to file
---@return boolean
---Usage:
---```lua
---if LuaFileSystem.FileIsFile("data/test.txt") then
---    print("It's a file")
---end
---```
LuaFileSystem.FileIsFile = function(file)
end

---Returns the file name without the path.
---@param file string Path to file
---@return string
---Usage:
---```lua
---local name = LuaFileSystem.FileGetName("data/test.txt")
---print(name) -- "test.txt"
---```
LuaFileSystem.FileGetName = function(file)
end

---Returns the path portion of a file.
---@param file string Path to file
---@return string
---Usage:
---```lua
---local path = LuaFileSystem.FileGetPath("data/test.txt")
---print(path) -- "data/"
---```
LuaFileSystem.FileGetPath = function(file)
end

---Checks if a file exists at the given path.
---@param file string Path to file
---@return boolean
---Usage:
---```lua
---if LuaFileSystem.FileExists("data/test.txt") then
---    print("File exists")
---end
---```
LuaFileSystem.FileExists = function(file)
end

---Deletes a file at the given path.
---@param file string Path to file
---@return boolean success
---Usage:
---```lua
---if LuaFileSystem.FileDelete("data/test.txt") then
---    print("File deleted")
---end
---```
LuaFileSystem.FileDelete = function(file)
end

---Returns the size of a file in bytes.
---@param file string Path to file
---@return number size
---Usage:
---```lua
---local size = LuaFileSystem.FileGetSize("data/test.txt")
---print("Size: " .. size .. " bytes")
---```
LuaFileSystem.FileGetSize = function(file)
end


-- ============================================================
-- Directory functions
-- ============================================================

---Returns the name of the directory.
---@param path string Directory path
---@return string
---Usage:
---```lua
---local name = LuaFileSystem.DirGetName("data/config")
---print(name) -- "config"
---```
LuaFileSystem.DirGetName = function(path)
end

---Checks if the path is a directory.
---@param path string Directory path
---@return boolean
---Usage:
---```lua
---if LuaFileSystem.DirIsDir("data/config") then
---    print("It's a directory")
---end
---```
LuaFileSystem.DirIsDir = function(path)
end

---Checks if the directory exists.
---@param path string Directory path
---@return boolean
---Usage:
---```lua
---if LuaFileSystem.DirExists("data/config") then
---    print("Directory exists")
---end
---```
LuaFileSystem.DirExists = function(path)
end

---Creates a directory at the given path.
---@param path string Directory path
---@return boolean success
---Usage:
---```lua
---if LuaFileSystem.DirCreate("data/newdir") then
---    print("Directory created")
---end
---```
LuaFileSystem.DirCreate = function(path)
end

---Returns the size of all files in the directory (recursive).
---@param path string Directory path
---@return number size
---Usage:
---```lua
---local size = LuaFileSystem.DirGetSize("data/config")
---print("Dir size: " .. size .. " bytes")
---```
LuaFileSystem.DirGetSize = function(path)
end

---Returns a list of files in the directory.
---@param path string Directory path
---@param type string Filter type (2 = "files", 1 = "dirs", 0 = "all")
---@return string[] files
---Usage:
---```lua
---local files = LuaFileSystem.DirGetFiles("data/config", "files")
---for _, f in ipairs(files) do
---    print("File: " .. f)
---end
---```
LuaFileSystem.DirGetFiles = function(path, type)
end
