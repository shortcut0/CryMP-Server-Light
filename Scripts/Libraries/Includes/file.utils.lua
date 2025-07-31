-----------------------------------------------------------------------------------
-- Author: shortcut0
-- Description: general functions that might come in handy

-- REQUIRES lua.utils.lua

-------------------
fileutils = {
	LUA_5_3 = false
}

---------------------------

FO_READ = "r"
FO_READPLUS = "r+"
FO_WRITE = "w"
FO_OVERWRITE = "w+"
FO_APPEND = "a"

---------------------------
-- fileutils.fixpath

fileutils.fixpath = function(sFile, sSlash)

	------------
	local sFixed = string.new(sFile)
	sFixed = string.gsubex(sFixed, { "/", "\\" }, (sSlash or "/"))
	sFixed = string.ridtrailex(sFixed, "/", "\\")

	------------
	return sFixed
end

---------------------------
-- fileutils.close

fileutils.close = function(sFile)
	if (not fileutils.ishandle(sFile)) then
		return true end
	
	------------
	sFile:close()
	
	------------
	return true
end

---------------------------
-- fileutils.open

fileutils.open = function(sFile, iMode)
	local hFile, sErr = io.open(sFile, CheckVar(iMode, FO_READ))
	if (not hFile) then
		return nil, sErr end
	
	------------
	return hFile, sErr
end

---------------------------
-- fileutils.delete

fileutils.delete = function(sFile)

	------------
	if (fileutils.LFS) then
		return fileutils.LFS.FileDelete(sFile)
	end

	os.execute(string.format([[
		IF EXIST "%s" DEL "%s"
	]], sFile, sFile))
	
	------------
	return true
end

---------------------------
-- fileutils.ishandle

fileutils.ishandle = function(hParam)
	return (type(hParam) == "userdata" and string.match(tostring(hParam), "^file %((.+)%)$"))
end

---------------------------
-- fileutils.fileexists

fileutils.fileexists = function(sFile)
	
	if (not IsString(sFile)) then
		return false end
		
	----------
	local hFile = fileutils.open(sFile, FO_READ)
	if (hFile) then
		fileutils.close(hFile)
		return true end
	
	----------
	return false
end

---------------------------
-- fileutils.size

fileutils.size = function(sFile)
		
	---------
	if (fileutils.ishandle(sFile)) then
		return (sFile:seek("end")) end
	
	---------
	local hFile = fileutils.open(sFile, FO_READ)
	if (not hFile) then
		return 0 end
		
	---------
	local fSize = hFile:seek("end")
	fileutils.close(hFile)

	---------
	return (fSize)
end

---------------------------
-- fileutils.lines

fileutils.lines = function(sFile)
		
	---------
	if (fileutils.ishandle(sFile)) then
		return (fileutils.countlines(sFile)) end
	
	---------
	local hFile = fileutils.open(sFile, FO_READ)
	if (not hFile) then
		return 0 end
		
	---------
	local iLines = (fileutils.countlines(hFile))
	fileutils.close(hFile)

	---------
	return (iLines)
end

---------------------------
-- fileutils.countlines

fileutils.countlines = function(hFile)
		
	---------
	if (not fileutils.ishandle(hFile)) then
		return 0 end
	
	---------
	local iLines = 0
	for i in hFile:lines() do
		iLines = iLines + 1 end

	---------
	return (iLines)
end

---------------------------
-- fileutils.read

fileutils.read = function(sFile)
		
	---------
	if (fileutils.ishandle(sFile)) then
		return (sFile:read("*all")) end
	
	---------
	local hFile = fileutils.open(sFile, FO_READ)
	if (not hFile) then
		return nil end
		
	---------
	local sData = hFile:read("*all")
	hFile:close()

	---------
	return (sData)
end

---------------------------
-- fileutils.write

fileutils.write = function(sFile, sData, sMode)

	---------
	local hLFS = fileutils.LFS
	if (fileutils.ishandle(sFile)) then
		sFile:write(sData)
		return true
	end

	local sDir = FileGetPath(sFile)
	if (hLFS) then
		if (not hLFS.DirExists(sDir)) then
			hLFS.DirCreate(sDir)
		end
	end

	local hFile, sErr = fileutils.open(sFile, (sMode or FO_READ))
	if (not hFile) then
		return false
	end

	hFile:write(sData)
	fileutils.close(hFile)

	return true
end

---------------------------
-- fileutils.overwrite

fileutils.overwrite = function(sFile, sData)

	-- CryMP: hooked
	if (ServerDLL) then
		ServerDLL.SaveFile(sFile, sData)
	end

	return FileWrite(sFile, sData, FO_OVERWRITE)
end

---------------------------
-- fileutils.flush

fileutils.flush = function(sFile)
		
	if (not fileutils.fileexists(sFile)) then
		return false
	end
		
	local hFile = fileutils.open(sFile, FO_OVERWRITE)
	if (not hFile) then
		return nil
	end
		
	fileutils.close(hFile)
	return true
end

---------------------------
-- fileutils.getfiles

fileutils.getfiles = function(sPath)

	---------
	if (fileutils.LFS) then
		return fileutils.LFS.DirGetFiles(sPath, GETFILES_FILES, ".*")
	end

	---------
	sPath = CheckVar(sPath, string.getworkingdir())
	local sFiles = string.getval(string.format([[@FOR /f "tokens=*" %%a in ('DIR /B /ON /A-D "%s" 2^>NUL') do @ECHO %%a]], sPath), fileutils.LUA_5_3)

	---------
	if (string.find(sFiles, "%?dir_empty%?$") or string.empty(sFiles)) then
		return {}
	end

	return string.split(sFiles, "\n")
end

---------------------------
-- fileutils.getfiles

fileutils.getfolders = function(sPath)

	if (fileutils.LFS) then
		return fileutils.LFS.DirGetFiles(sPath, GETFILES_DIR, ".*")
	end

	---------
	local sPath = CheckVar(sPath, string.getworkingdir())
	local sFolders = string.getval(string.format("IF EXIST \"%s\\*\" DIR \"%s\" /B /ON /AD", sPath, sPath), fileutils.LUA_5_3)

	---------
	return string.split(sFolders, "\n")
end

---------------------------
-- fileutils.getdir

fileutils.getdir = function(sPath)

	if (fileutils.LFS) then
		return fileutils.LFS.DirGetFiles(sPath, GETFILES_ALL, ".*")
	end

	---------
	sPath = CheckVar(sPath, string.getworkingdir())
	local sFiles = string.getval(string.format("IF EXIST \"%s\\*\" DIR \"%s\" /B /ON", sPath, sPath), fileutils.LUA_5_3)
	return string.split(sFiles, "\n")
end

---------------------------
-- fileutils.pathexists

fileutils.pathexists = function(sPath)

	if (fileutils.LFS) then
		return fileutils.LFS.DirExists(sPath)
	end

	local bExists = (string.getval(string.format([[IF EXIST "%s" (ECHO 1 {file_out}) ELSE (ECHO 0 {file_out})]], sPath), fileutils.LUA_5_3, fileutils.LUA_5_3) == "1")
	return bExists
end

---------------------------
-- fileutils.getattrib

fileutils.getattrib = function(sPath)

	if (fileutils.LFS) then
		return fileutils.LFS.GetAttrib(sPath)
	end

	---------
	if (not fileutils.pathexists(sPath)) then
		return false end

	---------
	local sAttributes = string.getval(string.format([[
		ATTRIB "%s"
	]], sPath), fileutils.LUA_5_3)
	
	---------
	sAttributes = string.sub(sAttributes, 1, 21)
	sAttributes = string.gsub(sAttributes, "%s", "")
	return (sAttributes)
end

---------------------------
-- fileutils.isfile

fileutils.isfile = function(sPath)

	---------
	if (not fileutils.pathexists(sPath)) then
		return false
	end

	return (not fileutils.isdir(sPath))
end

---------------------------
-- fileutils.isdir

fileutils.isdir = function(sPath)

	if (fileutils.LFS) then
		return fileutils.LFS.DirIsDir(sPath)
	end

	---------
	if (not fileutils.pathexists(sPath)) then
		return false
	end

	---------
	local bDirectory = (string.getval(string.format([[IF EXIST "%s\*" (ECHO 1 {file_out}) ELSE (ECHO 0 {file_out})]], sPath), fileutils.LUA_5_3, fileutils.LUA_5_3) == "1")
	return bDirectory
end

---------------------------
-- fileutils.size_dir

fileutils.size_dir = function(sPath, bRecursive)

	if (fileutils.LFS) then
		return fileutils.LFS.DirGetSize(sPath)
	end
	
	---------
	local sPath = string.ridtrailex(sPath, "\\", "/")
	
	---------
	if (not fileutils.pathexists(sPath)) then
		return (0) end

	---------
	if (not fileutils.isdir(sPath)) then
		return fileutils.size(sPath) end

	---------
	local aFolders = fileutils.getfolders(sPath)
	local aFiles = fileutils.getfiles(sPath)
	
	---------
	local iTotalSize = 0
	if (bRecursive) then
		for i, sFolder in pairs(aFolders) do
			iTotalSize = (iTotalSize + (fileutils.size_dir(sPath .. "\\" .. sFolder, true)))
		end
	end
	
	---------
	for i, sFile in pairs(aFiles) do
		iTotalSize = (iTotalSize + fileutils.size(sPath .. "\\" .. sFile)) 
	end
	
	---------
	return (iTotalSize)
end

---------------------------
-- fileutils.getdir_tree

fileutils.getdir_tree = function(sPath, bFullPath)

	-- print("Dir-> " .. sPath)
	if (not sPath) then
		return end
	
	---------
	local sPath = fileutils.fixpath(sPath)
	if (not fileutils.pathexists(sPath)) then
		return {} end

	---------
	if (not fileutils.isdir(sPath)) then
		return { sPath } end

	---------
	local aFolders = fileutils.getfolders(sPath)
	local aFiles = fileutils.getfiles(sPath)
	
	---------
	local aFolderData = {}
	
	---------
	for i, sFile in pairs(aFiles) do
		-- print("File " .. sPath .. " -> " .. sFile)
		if (bFullPath) then
			table.insert(aFolderData, sPath .. "/" .. sFile) else
			table.insert(aFolderData, sFile) end
	end
	
	---------
	for i, sFolder in pairs(aFolders) do
		-- print("Folder " .. sPath .. " -> " .. sFolder)
		aFolderData[sFolder] = fileutils.getdir_tree((sPath .. "/" .. sFolder), true)
	end

	---------
	return aFolderData
end

---------------------------
-- fileutils.getname

fileutils.getname = function(sFile)

	---------
	--- "^.*\\(.*)", "^.*/(.*)"
	local sName = string.matchex(sFile, "([^\\/]+)%.([^%.]+)$")
	return sName
end

---------------------------
-- fileutils.getnameex

fileutils.getnameex = function(sFile)
	return (string.matchex(sFile, "^.*\\(.*)", "^.*/(.*)"))
end

---------------------------
-- fileutils.getextension

fileutils.getextension = function(sFile)
	local sName, sExtension = string.matchex(sFile, "([^\\/]+)%.([^%.]+)$")
	return CheckString(sExtension, "")
end

---------------------------
-- fileutils.getextension

fileutils.removeextension = function(sFile)
	local sName, sExtension = string.matchex(sFile, "([^\\/]+)%.([^%.]+)$")
	return CheckString(sName, "")
end

---------------------------
-- fileutils.getextension

fileutils.makefilename = function(sFile)
	local tempName = string.new(sFile)
	local ext = string.getfileextension(sFile)

	local tempFile = io.open(tempName, "r")

	local retries = 0
	while (tempFile)
	do
		retries = retries + 1
		tempFile:close()
		tempName = (fileutils.removeextension(sFile)) .. " (" .. retries .. ")" .. ext
		tempFile = io.open(tempName, "r")
	end

	if (tempFile) then
		tempFile:close() end

	return tempName
end

---------------------------
fileutils.getpath = function(sFile)
	return (CheckVar(string.matchex(sFile, "^(.*)\\.*", "^(.*)/.*"), sFile) .. "\\")
end

---------------------------
fileutils.set_lfs = function(hLFS)
	fileutils.LFS = hLFS
end

-------------------

IsFile = fileutils.ishandle

FileSetLFS = fileutils.set_lfs
FileGetExtension = fileutils.getextension
FileRemoveExtension = fileutils.removeextension
FileMakeName = fileutils.makefilename
FileGetName = fileutils.getname
FileGetNameEx = fileutils.getnameex
FileGetPath = fileutils.getpath
FileGetSize = fileutils.size
FileRead = fileutils.read
FileWrite = fileutils.write
FileOverwrite = fileutils.overwrite
FileFlush = fileutils.flush
FileIsFile = fileutils.isfile
FileDelete = fileutils.delete
FileExists = fileutils.fileexists
FileGetLines = fileutils.lines

PathExists = fileutils.pathexists
PathIsFile = fileutils.isfile
PathIsDir = fileutils.isdir

DirGetFiles = fileutils.getfiles
DirGetFolders = fileutils.getfolders
DirGetAll = fileutils.getdir
DirGetTree = fileutils.getdir_tree
DirGetSize = fileutils.size_dir

-------------------
return fileutils