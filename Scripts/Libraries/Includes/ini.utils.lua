-----------------------------------------------------------------------------------
-- Author: shortcut0
-- Description: general functions that might come in handy
--
-- For public use:
-- InitUtils.Write -> Writes a


-------------------
IniUtils = {}

------------------
IniUtils.file_exists = function(sFile)
	local hFile = io.open(sFile, "r")
	if (not hFile) then
		return false
	end

	hFile:close()
	return true
end

------------------
IniUtils.read_to_array = function(hFile, aData)
	local idLastSection
	for line in hFile:lines() do
		local section = string.match(tostring(line), "^%[([^%]]+)%]$")
		local key, val = string.match(tostring(line), "^(.*)%s-=%s-(.*)$")
		--local key, val = string.match(tostring(line), "^(%w+)%s-=%s-(.+)$")

		if (section) then

			if (aData[section] == nil) then
				aData[section] = {}
			end
			idLastSection = section
		elseif (idLastSection and (key and val)) then

			-- Value is a boolean
			if (val == "true" or val == "false") then
				aData[idLastSection][key] = (val == "true")
			elseif (tonumber(val)) then -- Value is a number
				aData[idLastSection][key] = tonumber(val)
			else -- Value is a string
				aData[idLastSection][key] = val
			end
		end
	end
end

------------------
IniUtils.write_from_array = function(hFile, aData)
	local idLastSection
	local idCurrent, idTotal = 0, IniUtils.get_array_size(aData)

	for sSection, aSection in pairs(aData) do
		
		-- Create the new section
		hFile:write(string.format("[%s]\n", sSection))
		
		-- Write everything from the section
		for sKey, sValue in pairs(aSection or {}) do
			hFile:write(string.format("%s=%s\n", tostring(sKey), tostring(sValue)))
		end
		
		-- Check if we need to write a newline
		idCurrent = idCurrent + 1
		if (idCurrent < idTotal) then
			-- End of Section
			hFile:write("\n")
		end
	end
end

------------------
IniUtils.get_array_size = function(aArray)
	local iSize = 0
	for i, v in pairs(aArray or {}) do
		iSize = iSize + 1 end
		
	return iSize
end

------------------
IniUtils.Read = function(idFile, sSection, sKey, sDefault)

	-- check parameters
	if (idFile == nil) then
		return sDefault end
		
	if (sKey == nil) then
		return sDefault end
	
	-------------------------
	local aIniData = {}
	
	-------------------------
	-- hFile is a file handle
	if (type(idFile) == "userdata") then
		IniUtils.read_to_array(idFile, aIniData)
	else
		---------------------------------
		-- idFile is the literal file path
		if (not IniUtils.file_exists(idFile)) then
			return sDefault end
		
		local hFile = io.open(idFile, "r")
		IniUtils.read_to_array(hFile, aIniData)
		hFile:close()
		
	end
	
	if (aIniData[sSection]) then
		local idResult = aIniData[sSection][sKey]
		if (idResult == nil) then
			return sDefault end
			
		return idResult
	end

	return sDefault
end

------------------
IniUtils.Write = function(sFile, sSection, sKey, sVal) -- WIP !!

	-- check parameters
	if (sFile == nil) then
		return false end

	if (sKey == nil) then
		return false end

	if (sVal == nil) then
		return false end

	-------------------------
	local aIniData = {}

	-------------------------
	local hFile
	if (iniutils.file_exists(sFile)) then
		hFile = io.open(sFile, "r")
		if (not hFile) then
			return false
		end
		iniutils.read_to_array(hFile, aIniData)
		hFile:close()
	end

	-------------------------
	if (aIniData[sSection] == nil) then
		aIniData[sSection] = {}
	end
	aIniData[sSection][sKey] = sVal

	if (hFile) then
		hFile:close()
	end

	hFile = io.open(sFile, "w+")
	if (not hFile) then
		return false
	end

	iniutils.write_from_array(hFile, aIniData)
	hFile:close()

	return true
end

------------------
IniUtils.WriteArray = function(sFile, aData, bEraseFileData) -- WIP !!

	-- check parameters
	if (sFile == nil) then
		return false end
	
	-------------------------
	local aIniData = {}
	
	-------------------------
	local hFile
	if (IniUtils.file_exists(sFile)) then
		hFile = io.open(sFile, "r")
		IniUtils.read_to_array(hFile, aIniData)
	end
		
	-------------------------
	if (bEraseFileData == true) then
		aIniData = {}
	end
		
	-------------------------
	for sSection, aSection in pairs(aData) do
		if (isArray(aSection)) then
			for sKey, hVal in pairs(aSection) do
				if (aIniData[tostring(sSection)] == nil) then
					aIniData[tostring(sSection)] = {}
				end
				
				aIniData[tostring(sSection)][tostring(sKey)] = hVal
			end
		end
	end
	
	if (hFile) then
		hFile:close() end
		
	hFile = io.open(sFile, "w+")
	IniUtils.write_from_array(hFile, aIniData)
	hFile:close()
	
	return true
end

------------------
IniRead = IniUtils.Read
IniWrite = IniUtils.Write
IniWriteArray = IniUtils.WriteArray

------------------
return IniUtils