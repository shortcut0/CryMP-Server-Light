--=======================================--=======================================--=======================================--
-- Author: shortcut0
-- Description: general functions that might come in handy


table.__NO__RECURSION__ = {}

---------------------------
table.toArray = function(t, d)

	-- t is nil
	if (t == nil) then
		-- d is not nil
		if (d ~= nil) then
			return d
		end

		-- d is nil, return empty table
		return {}
	end

	-- t is not a table, so we encapsulate it
	if (type(t) ~= "table") then
		return { t }
	end

	-- t is a table
	return t
end

---------------------------
-- table.setM

table.setM = function(t, m, param, only_if_nil)

	local c = (string.count(m, "%.") + 1)
	local i = 0
	for sm in string.gmatch(m, "([^%.]+)") do
		i = i + 1
		if (i == c) then
			if (only_if_nil) then
				if (t[sm] == nil) then
					t[sm] = param
				else
				end
			else
				t[sm] = param
			end
		else
			table.checkM(t, sm, {})
			t = t[sm]
		end
	end
end

---------------------------
-- table.getM

table.getM = function(t, m, def)

	local h = nil

	local c = (string.count(m, "%.") + 1)
	local i = 0
	for sm in string.gmatch(m, "([^%.]+)") do
		i = i + 1
		if (i == c) then
			h = t[sm]
		else
			t = t[sm]
			if (t == nil) then break end
		end
	end

	if (h == nil) then
		return def
	end
	return h
end


---------------------------
-- table.checkM (finish this)
--- t=table
--- m=member
--- d=default
table.checkM = function(t, m, d)
	if (not t[m]) then
		t[m] = d
	end
	return t
end
---------------------------
-- table.checkNestedM (finish this)
table.checkNestedM = function(t, nest, d)
	return table.setM(t, nest, d, true)
end


---------------------------
-- table.getnested (finish this)

table.getnested = function(t, val, default)
	local h = t
	local f, l, sf, sl
	for sMember in string.gmatch(val, "([^%.]+)") do
		h = h[sMember]
		if (f == nil) then
			f = h
			sf = sMember
		end
		l = h
		sl = sMember
		if (h == nil) then
			--ServerLog("nil at %s",sMember)
			return default, f, l, sf, sl
		end
	end
	return h, f, l, sf, sl
end

---------------------------
-- table.keep

table.keep = function(t, i_keep)
	local aArray = {}
	local i_count = 0
	for i, v in pairs(t) do
		i_count = i_count + 1
		if (i_count <= i_keep) then
			aArray[i] = v
		else
			break
		end
	end
	return aArray
end

---------------------------
-- table.ikeep

table.ikeep = function(t, i_keep)
	local aArray = {}
	local i_count = 0
	for i, v in pairs(t) do
		i_count = i_count + 1
		if (i_count <= i_keep) then
			table.insert(aArray, v)
		else
			break
		end
	end
	--t = aArray
	return aArray
end

---------------------------
-- table.getall

table.getall = function(t, sKey)
	
	local sAll = ""
	if (sKey) then
		for i, v in pairs(t) do
			sAll = sAll .. v[sKey]
		end
	else
		for i, v in pairs(t) do
			sAll = sAll .. v
		end
	end
	return sAll
	
end

---------------------------
-- table.insertFirst

table.insertFirst = function(t, add)
	for i = #t, 1, -1 do
		t[i + 1] = t[i]
	end
	t[1] = add
	return t
end

--[[table.insertFirst = function(t, add)
	local tNew = { add }
	for i, v in pairs(t) do
		table.insert(tNew, v)
	end

	local max = math.max(table.count(t), table.count(tNew))
	for i in pairs(t) do
		t[i] = nil -- overwrite
	end
	for i = 1, max do
		t[i] = tNew[i] -- add back
	end
	return tNew
end]]

---------------------------
-- table.insertAt

table.insertAt = function(t, index, add)
	local tNew = { }
	if (table.size(t) <= index) then
		table.insert(t, add)
		return (t) -- insert if index larger than t size
	end
	if (index == 1) then
		return table.insertFirst(t, add)
	end
	local c = 0
	for i, v in pairs(t) do
		c = c + 1
		if (c == index) then
			table.insert(tNew, add)
		end
		table.insert(tNew, v)
	end
	return tNew
end

---------------------------
-- table.lookup

table.lookup = function(t, val, tf)
	for k, v in pairs(t) do
		if (v == val) then
			if (tf) then
				return true
			end
			return k
		end
	end
	if (tf) then
		return false
	end
	return
end

---------------------------
-- table.lookupI

table.lookupI = function(t, val, index, tf)
	for k, v in pairs(t) do
		if (v[index] == val) then
			if (tf) then
				return true
			end
			return k
		end
	end
	if (tf) then
		return false
	end
	return
end

---------------------------
-- table.lookupRec

table.lookupRec = function(t, val, o, tf)
	for k, v in pairs(t) do
		if (v == val) then
			if (tf) then
				return true
			end
			return k 
		else
			if (table.isarray(v) and (o ~= v and o ~= _G)) then
				local t = table.lookupRec(v, val, t)
				if (t) then
					if (tf) then
						return true
					end
					return t
				end
			end
		end 
	end
	if (tf) then
		return false
	end
	return
end

---------------------------
-- table.lookupk

table.lookupK = function(t, key)
	for k, v in pairs(t) do
		if (key == k) then
			return v end end

	return
end

---------------------------
-- table.contains

table.contains = function(t, val, containsAll)
	if (type(val) == "table") then
		local bOk = true
		for _, v in pairs(val) do
			if (containsAll) then
				bOk = (bOk and table.lookup(t, v) ~= nil)
			else
				bOk = (bOk or  table.lookup(t, v) ~= nil)
			end
		end
		return bOk
	end
	return (table.lookup(t, val) ~= nil)
end

---------------------------
-- table.containsKey

table.containsK = function(t, val, containsAll)
	if (type(val) == "table") then
		local bOk = true
		for _, v in pairs(val) do
			if (containsAll) then
				bOk = (bOk and table.lookupK(t, v) ~= nil)
			else
				bOk = (bOk or  table.lookupK(t, v) ~= nil)
			end
		end
		return bOk
	end
	return (table.lookupK(t, val) ~= nil)
end

---------------------------
-- table.shallowClone

table.shallowClone = function(t)
	
	local aResult = {}
	for k, v in pairs(t or{}) do
		aResult[k] = v end

	return aResult
end

---------------------------
-- table.shallowClone

table.shallowCloneEx = function(t, pred)

	local aResult = {}
	for k, v in pairs(t or{}) do
		aResult[k] = pred(v) end

	return aResult
end

---------------------------
-- table.copy

table.copy = table.shallowClone
table.copyEx = table.shallowCloneEx

---------------------------
-- table.concatEx
table.CONCAT_PREDICATE_TYPES = function(value, index, counter)

	local s = ""
	if (vector.isvector(value)) then
		s = vector.tostring(value)
	elseif (IsArray(value)) then
		s = string.format("Array (%s)", table.tostringEx(value))
	else
		s = string.format("%s (%s)", type(value), ToString(value))
	end

	return s
end
table.concatEx = function(t, s, pred)

	if (pred == nil) then
		return table.concat(t, s)
	end

	local ret = ""
	local c = 0
	for _, v in pairs(t) do
		if (ret ~= "") then
			ret = ret .. s
		end
		c = c + 1
		ret = ret .. pred(v, _, c)
	end

	return ret
end

---------------------------
-- table.deepClone

table.deepClone = function(t)
	local aResult = {}
	for k, v in pairs(t) do
		if table.isarray(v) then
			aResult[k] = table.deepClone(v)
		else
			aResult[k] = v
		end
	end
	
	return aResult
end

---------------------------
-- table.deepCopy

table.deepCopy = function(t)
	return table.deepClone(t)
end

---------------------------
-- table.shallowMerge

table.shallowMerge = function(a, b, bOverwrite)
	
	local n = table.copy(a)
	for i, v in pairs(b) do
		if (bOverwrite) then
			n[i] = v
		elseif (n[i] == nil) then
			n[i] = v
		end
	end
	
	return n
end

---------------------------
-- table.shallowMerge

table.shallowMergeInsert = function(a, b, fPred)
	
	local n = table.copy(a)
	for i, v in pairs(b) do
		if (fPred == nil or (fPred(v) == true)) then
			table.insert(n, v)
		end
	end
	
	return n
end

---------------------------
-- table.deepMerge

table.deepMerge = function(a, b, bOverwrite)

	if (not table.isarray(a)) then
		return (table.isarray(b) and b or {})
	elseif (not table.isarray(b)) then
		return (table.isarray(a) and a or {})
	end

	local n = table.copy(a)
	for i, v in pairs(b) do
		if (bOverwrite) then
			if (table.isarray(v)) then
				n[i] = table.deepMerge(n[i], v, true)
			else
				n[i] = v
			end
		else
			if (table.isarray(v)) then
				if (n[i] == nil) then
					n[i] = v
				else
					n[i] = table.deepMerge(n[i], v, false)
				end
			elseif (n[i] == nil or (bOverwrite and n[i] ~= v)) then
				n[i] = v
			end
		end
	end
	
	return n
end

---------------------------
-- table.merge

table.merge = function(a, b, bOverwrite)
	return table.shallowMerge(a, b, bOverwrite)
end

---------------------------
-- table.mergeI

table.mergeI = function(a, b, fPred)
	return table.shallowMergeInsert(a, b, fPred)
end

---------------------------
-- table.isarray

table.isarray = function(t)
	return (type(t) == "table")
end

---------------------------
-- table.getmem

table.getmem = function(a, mem)
	local aArray = {}
	for k, v in pairs(a) do
		if (not IsNull(a[mem])) then
			aArray[k] = v end
	end
	return aArray
end

---------------------------
-- table.igetmem

table.igetmem = function(a, mem)
	local aArray = {}
	for k, v in pairs(a) do
		if (not IsNull(a[mem])) then
			table.insert(aArray, v) end
	end
	return aArray
end

---------------------------
-- table.select

table.select = function(t, pred)
	local aResult = {}
	for k, v in pairs(t) do
		if (pred(v)) then
			aResult[k] = v end
	end
	return aResult
end

---------------------------
-- table.iselect

table.iselect = function(t, pred)
	local aResult = {}
	for _, v in ipairs(t) do
		if (pred(v)) then
			table.insert(aResult, v) end
	end
	return aResult
end

---------------------------
-- table.one

table.one = function(t, pred)
	for _, v in pairs(t) do
		if (pred == nil or pred(v)) then
			return v end end
end

---------------------------
-- table.first

table.first = table.one

---------------------------
-- table.last

table.last = function(t, pred)

	local i = table.count(t)
	local c = 0
	for _, v in pairs(t) do
		c = c + 1
		if ((c >= i and pred == nil) or (IsFunc(pred) and pred(v, c))) then
			return v end end
end

---------------------------
-- table.last

table.lasti = function(t, pred)

	local i = table.count(t)
	local c = 0
	for _, v in pairs(t) do
		c = c + 1
		if ((c >= i and pred == nil) or (IsFunc(pred) and pred(v, c))) then
			return _ end end
end

---------------------------
-- table.random



---------------------------
-- table.count

table.count = function(t, pred)

	if (not table.isarray(t)) then
		return 0
	end

	local iCount = 0
	for _, v in pairs(t) do
		if (pred == nil or pred(v)) then
			iCount = iCount + 1
		end
	end
	return iCount
end

---------------------------
-- table.countdiff

table.countdiff = function(t, t2, pred)
	local a = table.count(t, pred)
	local b = table.count(t2, pred)
	return (a - b)
end

---------------------------
-- table.compS

table.compS = function(t, t2, pred)
	return (table.countdiff(t, t2, pred) == 0)
end

---------------------------
-- table.sortI

table.sortI = function(t)
	local keys = {}
	for k in pairs(t) do
		table.insert(keys, k)
	end
	table.sort(keys)
	local sortedTable = {}
	for _, k in ipairs(keys) do
		sortedTable[k] = t[k]
	end
	return sortedTable
end

---------------------------
-- table.getsize

table.getsize = table.count
table.size = table.count

---------------------------
-- table.countTypes

table.countTypes = function(t, bReturnCount)

	------------
	local sTypes = "%d Arrays, %d Floats, %d Strings, %d Booleans, %d Functions, %d Other Entires"
	if (not table.isarray(t)) then
		if (bReturnCount) then
			return 0, 0, 0, 0, 0, 0 end
			
		return string.format(sTypes, 0, 0, 0, 0, 0, 0)
	end

	------------
	local iArrays = 0
	local iFloats = 0
	local iStrings = 0
	local iBooleans = 0
	local iFunctions = 0
	local iOtherEntires = 0
	
	------------
	for _, v in pairs(t) do
		
		if (IsArray(v)) then
			local aRet = { table.countTypes(v, true) }
			iArrays = iArrays + aRet[1] + 1
			iFloats = iFloats + aRet[2]
			iStrings = iStrings + aRet[3]
			iBooleans = iBooleans + aRet[4]
			iFunctions = iFunctions + aRet[5]
			iOtherEntires = iOtherEntires + aRet[6]
			
		elseif (IsNumber(v)) then
			iFloats = iFloats + 1 elseif (isString(v)) then
			iStrings = iStrings + 1 elseif (isBoolean(v)) then
			iBooleans = iBooleans + 1 elseif (IsFunction(v)) then
			iFunctions = iFunctions + 1  else
			iOtherEntires = iOtherEntires + 1
		end
	end
	
	------------
	if (bReturnCount) then
		return iArrays, iFloats, iStrings, iBooleans, iFunctions, iOtherEntires end
	
	------------
	return string.format(sTypes, iArrays, iFloats, iStrings, iBooleans, iFunctions, iOtherEntires)
end

---------------------------
-- table.it

table.it = function(t, fPred)

	local x, s
	for i, v in pairs(t) do
		x, s = fPred(x, i, v)
		if (s) then break end
	end
	return x
end
---------------------------
-- table.itRec

table.itRec = function(t, pred)

	local x
	for i, v in pairs(t) do
		if (IsArray(v)) then
			x = table.itRec(v, pred)
		end
		x = pred(x, i, v)
	end
	return x
end

---------------------------
-- table.countRec

table.countRec = function(t, pred, iLevels, iLevel)

	if (not table.isarray(t)) then
		return 0
	end
	
	iLevel = CheckNumber(iLevel, 0)
	
	local bLevelOk = true
	if (IsNumber(iLevels)) then
		bLevelOk = iLevel < iLevels end

	local iCount = 0
	for _, v in pairs(t) do
		if (pred == nil or pred(_, v, iLevel)) then
			if (table.isarray(v) and bLevelOk) then
				iCount = iCount + table.countRec(v, pred, iLevels, (iLevel + 1))
			else
				iCount = iCount + 1
			end
		end
	end
	return iCount
end

---------------------------
-- table.removeWithPredicate

table.removeWithPredicate = function(t, pred)
	local k, v
	while true do
		k, v = next(t, k)
		if k == nil then
			break
		end
		if (pred(v)) then
			t[k] = nil
		end
	end
end

---------------------------
-- table.removeValue

table.removeValue = function(t, val)
	for k, v in pairs(t) do
		if (IsFunc(val)) then
			if (val(k, v)) then
				table.remove(t, k)
				return
			end
		else
			if (v == val) then
				table.remove(t, k)
				return
			end
		end
	end
end

---------------------------
-- table.popFirst

table.popV = table.removeValue
table.popPred = table.removeWithPredicate

---------------------------
-- table.popFirst

table.popFirst = function(t)
	local v = t[1]
	table.remove(t, 1)

	return v
end

---------------------------
-- table.popLast

table.popLast = function(t)
	local v = t[#t]
	table.remove(t, #t)

	return v
end

---------------------------
-- table.pop

table.pop = function(t, i)
	local v = t[i]
	table.remove(t, i)

	return v
end

---------------------------
-- table.empty

table.empty = function(t)
	return (table.count(t) == 0)
end

---------------------------
-- table.empty

table.emptyN = function(t)
	return not table.empty(t)
end

table.not_empty = table.emptyN

---------------------------
-- table.getmax

table.getmax = function(t, sKey)
	local iMax
	for i, v in pairs(t) do
		local iNumber = tonumber(v)
		if (IsArray(v) and v[sKey]) then
			iNumber = CheckNumber(tonumber(v[sKey]), 0) end
			
		if (IsNull(iMax) or (CheckNumber(iNumber, 0) > iMax)) then
			iMax = iNumber end
	end
	 
	return iMax
end

---------------------------
-- table.findp

table.findp = function(t, hPartial, bPrint)
	local c = 0
	local aArray = {}
	for i, v in pairs(t) do
		c = c + 1
		if (string.find(i, hPartial)) then
			table.insert(aArray, i)
			if (bPrint) then
				print(i)
			end
		end
	end
	 
	return aArray
end

---------------------------
-- table.findp

table.findp_rec = function(t, hPartial, bPrint, bStringFmt, sName, sTab, bRec, sStack, aVisited)

	sName = sName or ""
	sTab = sTab or ""
	sStack = sStack or table.getorigin(t)

	--[[
	if (bRec == nil) then
		table.__NO__RECURSION__ = {}
	elseif (table.__NO__RECURSION__[sArray] ~= nil) then
		return
	else
		table.__NO__RECURSION__[sArray] = 1
	end]]

	if (bRec == nil or aVisited == nil) then
		aVisited = {}
	end

	if (aVisited[t]) then
		return
	end

	aVisited[t] = true

	local aArray = {}
	local sString = sName
	for i, v in pairs(t) do


		if (IsArray(v)) then
			local r = (table.findp_rec(v, hPartial, bPrint, bStringFmt, nil, sTab.."   ", true, sStack .. "."..i, aVisited))
			if (not table.empty(r) or (bStringFmt and not string.empty(r))) then
				--table.insert(aArray, r)
				aArray[i] = r
				if (bStringFmt and string.find(r, hPartial)) then
					sString = sString .. sTab .. " -> " .. i .. " = { \n" .. r .. "\n" .. sTab .. "},\n"
				end
			elseif (string.find(i, hPartial)) then
				--table.insert(aArray, {})
				aArray[i] = {}
				sString = sString .. string.format("%-75s %12s[stack:%s]\n",  sTab .. " > " .. i, "(" .. type(v) .. ")", sStack)
			end
		elseif (string.find(i, hPartial)) then
			--table.insert(aArray, i)
			aArray[i] = v
			if (bStringFmt) then
				sString = sString .. string.format("%-75s %12s[stack:%s]\n",  sTab .. " > " .. i, "(" .. type(v) .. ")", sStack)
			end
			if (bPrint) then
				print(i)
			end
		end
	end

	--if (bRec == nil) then
	--	table.__NO__RECURSION__ = {}
	--end

	if (bStringFmt) then
		return sString
	end
	return aArray
end

---------------------------
-- table.getorigin_fromstring (MOVE TO UTILS LIBRARY?? HAS NOTHING TO DO WITH ARRAYS..)
-- "_G" -> returns global _G array
-- "_G.math" -> returns global math array
-- "math" -> returns global math array
-- "math.mod" -> returns global math.mod function

table.getorigin_fromstring = function(sObj)

	local hObj
	if (not string.find(sObj, "%.")) then
		return _G[sObj]
	end

	local aArray = {}
	for sPart in string.gmatch(sObj, "[^.]*") do
		if (string.len(sPart) > 0) then
			table.insert(aArray, sPart)
		end
	end

	hObj = ("return _G." .. table.concat(aArray, "."))

	local fLoad = (load or loadstring)
	return (fLoad(hObj)())
end

---------------------------
--- table.getorigin (MOVE TO UTILS LIBRARY?? NOT EXCLUSIVE TO ARRAYS ANYMORE..)
--- get the origin location of a variable
--- can be file, userdata, array or function. strings and numbers are NOT supported
table.getorigin = function(t, bFullStack, sOrigin, aCurrent, bRec, aVisited)

	aCurrent = aCurrent or _G
	sOrigin = sOrigin or "_G"
	if (bRec == nil and (t == _G or _G[t])) then
		return "_G"
	end

	--[[
	local sArray = string.gsub(tostring(aCurrent), "^table: ", "")
	if (bRec == nil) then
		table.__NO__RECURSION__ = {}
	elseif (table.__NO__RECURSION__[sArray] ~= nil) then
		return
	else
		table.__NO__RECURSION__[sArray] = 1
	end]]

	if (bRec == nil or aVisited == nil) then
		aVisited = {}
	end
	
	if (aVisited[aCurrent]) then
		return
	end
	
	aVisited[aCurrent] = true

	local sName
	local bFunction
	for i, v in pairs(aCurrent) do
		if (IsArray(v)) then
			if (v == t) then
				sName = i
				if (bFullStack) then
					sName = sOrigin .. "." .. i
				end
				break
			else
				--						 t-origin-search-rec
				local r = (table.getorigin(t, bFullStack, sOrigin .. "[" .. tostring(i) .. "]", v, true, aVisited))
				if (r) then
					sName = r
					break
				end
			end
		elseif (IsFunc(v) or IsUserdata(v) or IsFile(v)) then
			if (v == t) then
				sName = i
				if (bFullStack) then
					sName = sOrigin .. "." .. i
				end
				break
			end
		end
	end

	--[[
	if (bRec == nil) then
		table.__NO__RECURSION__ = {}
	end
	if (sName and bRec == nil) then
	end]]

	return sName
end

---------------------------
-- table.find

table.find = function(t, hFind, fPred)
	for i, v in pairs(t) do
		if (i == hFind or (fPred and fPred(i, hFind))) then
			return v
		end
	end

	return
end

---------------------------
-- table.findv

table.find_value = function(t, hFind)
	for i, v in pairs(t) do
		if (v == hFind) then
			return v
		end
	end
	 
	return
end

---------------------------
-- table.findex

table.findex = function(t, hFind)
	for i, v in pairs(t) do
		if (i == hFind or v == hFind) then
			return v
		end
	end
	 
	return
end

---------------------------
-- table.findall

table.findall = function(t, ...)

	local aFind = { ... }
	if (table.count(aFind) == 0) then
		return
	end

	for i, v in pairs(aFind) do
		if (not table.find(t, v)) then
			return false
		end
	end
	 
	return true
end

---------------------------
-- table.findany

table.FindAny = function(t, aFind, fPred)

	if (table.count(aFind) == 0) then
		return end

	for i, v in pairs(aFind) do
		local hFound = table.find(t, v)
		if (hFound) then
			return hFound end
	end
	 
	return
end

---------------------------
-- table.findany

table.FindAny_Key = function(t, aFind, fPred)

	if (table.count(aFind) == 0) then
		return
	end

	for i, v in pairs(aFind) do
		local hFound = table.find(t, v, fPred)
		if (hFound ~= nil) then
			return hFound
		end
	end

	return
end

---------------------------
-- table.index

table.index = function(t, iIndex)
	local c = 0
	for i, v in pairs(t) do
		c = c + 1
		if (c == iIndex) then
			return v end
	end
	 
	return
end

---------------------------
-- table.indexname

table.indexname = function(t, iIndex)
	local c = 0
	for i, v in pairs(t) do
		c = c + 1
		if (c == iIndex) then
			return i end
	end
	 
	return
end

---------------------------
--- table.append
--- Appends all arguments with an array
table.append = function(t1, ...)

	for _, t in pairs({ ... }) do
		for __, _t in pairs(t) do
			table.insert(t1, _t)
		end
	end

	-- for _, v in ipairs(t2) do
		-- table.insert(t1, v)
	-- end
	return t1
end

---------------------------
--- table.appendA
--- @Description: Appends two arrays
table.appendA = function(t1, t2)

	for _, t in pairs(t2) do
		table.insert(t1, t)
	end

	return t1
end

---------------------------
-- table.shuffle

table.shuffle = function(t1)

	if (not table.isarray(t1)) then
		return t1 end

	local tNew = {}
	local aIndexes = {}

	for i, v in pairs(t1) do
		table.insert(aIndexes, i) end
	
	for i = 1, table.count(t1) do
	
		local iNewIndex = GetRandom(1, table.count(aIndexes))
	
		table.insert(tNew, t1[aIndexes[iNewIndex]]) 
		table.remove(aIndexes, iNewIndex) 
	end
	
	return tNew
end

---------------------------
-- table.arrayShiftZero

table.arrayShiftZero = function(t1,t2)
	
	if (t2 == nil) then
		t2 = t1 end

	for i = 0, (#t1 - 1) do
		t2[i] = t1[i + 1] end
		
	t2[#t1] = nil
end

---------------------------
-- table.arrayShiftOne

table.arrayShiftOne = function(t1, t2)
	
	if (t2 == nil) then
		t2 = t1 end

	for i = #t1 + 1, 1, -1 do
		t2[i] = t1[i - 1] end
		
	t2[0] = nil
end

---------------------------
-- table.tostring (!!MESSY!!)

table.tostringEx = function(aArray, sTab, sName)
	return table.tostring(aArray, sTab, sName, false, true)
end

---------------------------
-- table.tostring (!!MESSY!!)

table.tostring = function(aArray, sTab, sName, bSubCall, bNoRecursion, iUnfoldDepth, iUnfoldLevel, aVisited)

	if (sTab == nil) then
		sTab = "" end
		
	if (sName == nil) then
		sName = tostring(aArray) .. " = " end
		
	--[[local sArray = string.gsub(tostring(aArray), "^table: ", "")
	--	if (bSubCall == nil) then
	--		table.__NO__RECURSION__ = {}
	--	elseif (table.__NO__RECURSION__[sArray] ~= nil) then
	--		return
	--	else
	--		table.__NO__RECURSION__[sArray] = 1
	--	end]]


	if (aVisited == nil) then
		aVisited = {}
	end

	if (aVisited[aArray]) then
		return
	end

	aVisited[aArray] = true

		
	local sRes = sTab .. sName .. "{\n"
	local sTabBefore = sTab
	sTab = sTab .. " "
	iUnfoldLevel = iUnfoldLevel or 1
	
	local bRec, sRec = false, ""
	
	for i, v in pairs(aArray or {}) do
	
		bRec, sRec = false, ""
		
		local vType = type(v)
		local vKey = "[" .. tostring(i) .. "] = "
		if (type(i) == "string") then
			vKey = "[\"" .. string.gsub(tostring(i), "\"", "\\\"") .. "\"] = "
		elseif (type(i) == "number") then
			vKey = "[" .. i .. "] = "
		end
				
		if (vType == "table" and not bNoRecursion) then
			local iKey = string.format("\"%s\"",ToString(i))
			if (type(i)=="number") then
				iKey=i
			end
			sRec = (table.tostring(v, sTab, "[" .. iKey .. "] = ", 1, nil, iUnfoldDepth, iUnfoldLevel + 1, aVisited))
			if (string.empty(sRec)) then
				bRec = true
			else
				if (iUnfoldDepth ~= nil and iUnfoldLevel > iUnfoldDepth) then
					sRec = string.gsub(sRec, "\n", " ")
					sRec = string.gsub(sRec, "\t", " ")
				end
				sRes = sRes .. sRec
			end
		elseif (vType == "number") then
			if (IsFloat(v)) then
				sRes = sRes .. sTab .. vKey .. string.format("%f", v)
			else
				sRes = sRes .. sTab .. vKey .. string.format("%d", v)
			end
		elseif (vType == "string") then
			sRes = sRes .. sTab .. vKey .. "\"" .. string.gsub(v, "\"", "\\\"") .. "\""
		else
			sRes = sRes .. sTab .. vKey .. tostring(v)
		end
		
		if (not bRec) then
			sRes = sRes .. ",\n"
		end
	end

	sRes = sRes .. sTabBefore .. "}"

	--if (bSubCall == nil) then
	--	table.__NO__RECURSION__ = {}
	--end
	return sRes
end