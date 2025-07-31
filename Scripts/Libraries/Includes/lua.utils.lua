--=======================================--=======================================--=======================================--
-- Author: shortcut0
-- Description: general functions that might come in handy

--- @class array_number
--- @class array_function_number

-------------------
--- @class luautils
luautils = {

    ERROR_HANDLER = nil
}


--=======================================
luautils.throw_error = function(sMessage)

    ERROR_THROWN = true

    local sMsg = string.format("Error Thrown (%s)\n\t%s", tostring(sMessage), tostring(TracebackEx()))
    local fHandle = (luautils.ERROR_HANDLER)
    if (fHandle) then
        fHandle(sMsg)
    end

    error(sMsg)
end

--=======================================
-- do any of the ... match parameter 'h'?
luautils.is_any = function(h, ...)

    local args = { ... }
    if (table.empty(args)) then
        return true -- ??
    end

    for _, x in pairs(args) do
        if (h == x) then
            return true
        end
    end

    return false
end

--=======================================
-- do all of the ... match parameter 'h'
luautils.is_all = function(h, ...)

    local args = { ... }
    if (table.empty(args)) then
        return true -- ??
    end

    for _, x in pairs(args) do
        if (h ~= x) then
            return false
        end
    end

    return true
end

--=======================================
luautils.isFunction = function(hParam)
    return (type(hParam) == "function")
end

--=======================================
luautils.isString = function(hParam)
    return type(hParam) == "string"
end

--=======================================
luautils.isNumber = function(hParam)
    return type(hParam) == "number"
end

--=======================================
luautils.isFloat = function(hParam)
    return (IsNumber(hParam) and string.match(ToString(hParam), "(%.%d+)") ~= nil)
end

--=======================================
luautils.isBoolean = function(hParam)
    return type(hParam) == "boolean"
end

--=======================================
luautils.isArray = function(hParam)
    return type(hParam) == "table"
end

--=======================================
luautils.isNull = function(hParam)
    return hParam == nil
end

--=======================================
luautils.isDead = function(hParam)
    return (IsNumber(hParam) and hParam == 0xDEAD)
end

--=======================================
luautils.isEntityId = function(hParam)
    return type(hParam) == "userdata"
end

--=======================================

---
--- luautils.random({1, 2, 3}, function(v) return v > 1 end) -- shuffle array, return first element where predicate true
--- luautils.random({1, 2, 3}, 2)  -- random element from array indices 1 to 2
--- luautils.random({1, 2, 3})     -- random element from whole array
--- luautils.random(5, 10)         -- random number between 5 and 10
--- luautils.random(10)            -- random number between 0 and 10
--- luautils.random(nil)           -- returns 0
--- luautils.random(5, 10, true)   -- random integer between 5 and 10 (floored)
--- @param min array_number minimum
--- @param max array_function_number maximum
--- @param floor boolean floor the result
luautils.random = function(hMin, hMax, bFlood)

    -------------
    if (IsArray(hMin)) then
        if (hMax and IsFunction(hMax) and table.not_empty(hMin)) then
            for i, hVal in pairs(table.shuffle(hMin)) do
                if (hMax(hVal) == true) then
                    return hVal
                end
            end
        else
            -- random element inside hMin
            return hMin[math.floor(math.random((hMax or table.count(hMin))))]
        end
    end

    -------------
    local iRandom
    if (hMax) then
        iRandom = math.random(hMin, hMax)
    elseif (hMin) then
        iRandom = math.random(0, hMin)
    else
        return 0
    end

    -------------
    if (bFlood) then
        iRandom = math.floor(iRandom)
    end

    -------------
    return iRandom
end

--=======================================
--- checks if a given parameter is a NUMBER type
--- @param iNumber any parameter to check
--- @param iDefault number the default value to resort to
luautils.checkNumber = function(iNumber, iDefault)

    if (not IsNumber(iNumber)) then
        return iDefault
    end

    return iNumber
end

--=======================================
--- CONVERTS and checks if a given parameter is a NUMBER type or CAN BE a number type!
--- @param iNumber any parameter to check
--- @param iDefault number the default value to resort to
luautils.checkNumberEx = function(iNumber, hDefault)

    local iCheck = tonumber(iNumber or "")
    if (not IsNumber(iCheck)) then
        return hDefault
    end

    return iCheck
end

--=======================================
--- Compares two numbers
--- Returns true if 'iNumber' is greater than 'iGtr'
--- @param iNumber number the first number
--- @param iGtr number the second number
luautils.compNumber = function(iNumber, iGtr)

    -------------
    if (not IsNumber(iNumber)) then
        return false end

    -------------
    if (not IsNumber(iGtr)) then
        return false end

    -------------
    return (iNumber >= iGtr)
end

--=======================================
--- Checks if parameter is nil
--- @param hVar any the first number
--- @param hDefault any the default value if hVar is NULL
luautils.CheckVar = function(hVar, hDefault)

    if (IsNull(hVar)) then
        return hDefault
    end

    return hVar
end

--=======================================
-- luautils.checkFunc

luautils.checkFunc = function(fFunc, hDefault, ...)

    -------------
    if (not IsFunc(fFunc)) then
        return hDefault
    end

    local hReturn = { fFunc(...) }
    if (table.not_empty(hReturn)) then
        return unpack(hReturn)
    end

    return hDefault
end

--=======================================
-- luautils.checkFuncEx

luautils.checkFuncEx = function(fFunc, hDefault)

    if (IsFunc(fFunc)) then
        return hDefault
    end

    return fFunc
end

--=======================================
--- luautils.checkArray
--- checkArray(nil, { "x" }) 	-> { "x"  }
--- checkArray(nil, "x") 		-> { "x"  }
--- checkArray(nil, nil) 		-> { nil  }
luautils.checkArray = function(aArray, hDefault)

    if (not IsArray(aArray)) then
        if (IsNull(hDefault)) then
            return { }
        elseif (IsArray(hDefault)) then
            return hDefault
        else
            return { hDefault }
        end
    end

    return aArray
end

--=======================================
--- luautils.checkArrayEx
---
--- does not force hDefault to be an
--- array and instead returns it as-is
luautils.checkArrayEx = function(aArray, hDefault)

    if (not IsArray(aArray)) then
        return hDefault
    end

    return aArray
end

--=======================================
--- luautils.checkString
--- Checks if a given parameter is a string
luautils.checkString = function(sString, hDefault)

    if (not IsString(sString)) then
        return hDefault
    end

    return sString
end

--=======================================
--- luautils.checkGlobal
--- MY_GLOBAL = "servus"
--- checkGlobal("_G", x)			-> _G
--- checkGlobal("MY_GLOBAL", x)		-> MY_GLOBAL "servus"
luautils.checkGlobal = function(hGlobal, hDefault, fCheck, pCheck)

    if (IsNull(hGlobal)) then
        return hDefault
    end

    local bOk, fFunc, sErr, sType, hValue
    if (IsString(hGlobal)) then

        local fLoad = (loadstring or load)
        local sFunc = string.format("return %s", CheckString(hGlobal, ""))

        -- load string
        bOk, fFunc = pcall(fLoad, sFunc)
        if (not bOk) then
            return hDefault
        end

        -- execute string
        bOk, sErr = pcall(fFunc)
        if (not bOk) then-- or string.findex(checkString(sErr), "attempt to index field", "attempt to index global", "attempt to index a nil value")) then
            return hDefault
        end

        -- it's undefined
        if (sErr == nil) then
            return hDefault
        end

        -- global value
        if (IsFunc(fCheck)) then
            return fCheck(sErr, CheckVar(pCheck, hDefault))
        end
        return sErr
    end

    return hDefault
end

--=======================================
--- luautils.traceback
---
--- Args
---  1. MyLogFunction <if nil, PRINT is used>,
---  2. sCleanPattern <the pattern to clean the line from (eg: "\t" to remove tabulators)>,
---  3. iSkipLines <the amount of lines to skip from the traceback>)
luautils.traceback = function(fLog, aGsub, iSkip)

    local fLogFunc = CheckFuncEx(fLog, function(sMsg)
        print(sMsg)
    end)

    -------------
    local sTraceback = debug.traceback()
    if (string.empty(sTraceback)) then
        fLogFunc("<Traceback Failed>")
        return
    end

    local nSkip = CheckNumber(iSkip, 0)
    for i, sLine in pairs(string.split(sTraceback, "\n")) do
        if (nSkip == 0 or (i > nSkip)) then
            fLogFunc(string.gsubex(sLine, CheckArray(aGsub, {}), ""))
        end
    end
end

--=======================================
--- luautils.tracebackex
---
--- Custom traceback, similar to build-in one
--- Args
---  1. sMessage <a message to append to the final traceback ("L:MESSAGE" to append it to the end of each line)>
luautils.tracebackex = function(sMessage, iLevel, sPrefix)

    iLevel = CheckNumber(iLevel, 1)
    local bAppendLine = (string.matchex(sMessage, "^L:(.*)$") ~= nil)
    local sTrace = (sPrefix or "stack traceback:")

    while (true) do

        local aInfo = debug.getinfo(iLevel, "Sln")
        if (not aInfo) then break end
        sTrace = (sTrace .. "\n\t" .. (aInfo.short_src or "C") .. ":" .. (aInfo.currentline or "?") .. ":")
        if (aInfo.name) then
            sTrace = (sTrace .. " in function '" .. aInfo.name .. "'") .. (bAppendLine and sMessage or "")
        end
        iLevel = iLevel + 1
    end
    if (sMessage and not bAppendLine) then
        sTrace = (sTrace .. "\n\t" .. sMessage)
    end
    return sTrace
end

--=======================================
--- luautils.getDummyFunc
luautils.getDummyFunc = function(throw)
    return function()
        if (throw) then
            throw_error("dummy function called!!")
        end
    end
end

--=======================================
--- luautils.getDummyFunc
luautils.getErrorDummy = function()

    return function(...)
        throw_error(string.format(
                "Dummy Called (Arguments: %s)",
                table.concatEx({ ... }, ", ", table.CONCAT_PREDICATE_TYPES)
        ))
    end
end
--=======================================
--- luautils.repeatargument
luautils.repeatargument = function(hArg, iSteps)

    local aArgs = { }
    for i = 1, iSteps do
        aArgs[i] = hArg
    end

    return luautils.unpack(aArgs)
end
--=======================================
--- luautils.unpack
luautils.unpack = function(t, i, j)

    i = (i or 1)
    j = (j or table.count(t))
    if (j < i) then
        return
    end

    local function unpackHelper(i, j)
        if (i <= j) then
            return t[i], unpackHelper((i + 1), j)
        end
    end

    return unpackHelper(i, j)
end

--=======================================
--- luautils.switch
---
--- luautils.switch("b")({
---    a = function() return "A" end,
---    b = function() return "B" end,
---    default = function() return "?" end
--- }) -> "B"
---
luautils.switch = function(value)
    return function(cases)
        local case = cases[value]
        local hDef = cases.default
        if (case) then
            if (IsFunc(case)) then
                return case()
            else
                return case
            end
        elseif (hDef) then
            if (IsFunc(hDef)) then
                return hDef()
            else
                return hDef
            end
        else
            throw_error("No case found for value: " .. tostring(value))
        end
    end
end

--=======================================
--- luautils.callAndExecute
--- calls a function and executes all tasks in 'calls'
--- Args
---  1. f, the function to call (eg: callAndExecute(timernew), NOT callAndExecute(timernew()) UNLESS that itself returns a function)
---  2. params, the parameters to pass to 'f'
---  3. calls, the array containing all the tasks where index_1 is the name of the function and index_2+
luautils.callAndExecute = function(f, params, calls)

    local aRet = { f(unpack(params)) }
    local hObj = aRet[1]

    if (IsArray(hObj)) then
        if (table.not_empty(calls)) then
            for _, aCall in pairs(calls) do
                local bOk, sErr = pcall(hObj[aCall[1]], luautils.unpack(aCall, 2))
                if (not bOk) then
                    error(sErr)
                end
            end
        end
    end

    return unpack(aRet)
end

--=======================================---

luautils.INCREASE = nil
luautils.INCREASE_ADD = nil
luautils.INCREASE_MULT = nil
luautils.INCREASE_DIV = nil

--=======================================
--- luautils.increase
luautils.EndInc = function(bKeepInc)
    luautils.INCREASE_ADD = nil
    luautils.INCREASE_MULT = nil
    luautils.INCREASE_DIV = nil
    luautils.INCREASE_SUB = nil
    if (not bKeepInc) then
        luautils.INCREASE = nil end
end

--=======================================
--- luautils.increase
luautils.StepInc = function()

    -- Add
    if (luautils.INCREASE_ADD) then
        luautils.INCREASE = (luautils.INCREASE + luautils.INCREASE_ADD)

        -- Mult
    elseif (luautils.INCREASE_MULT) then
        luautils.INCREASE = (luautils.INCREASE * luautils.INCREASE_MULT)

        -- Div
    elseif (luautils.INCREASE_DIV) then
        luautils.INCREASE = (luautils.INCREASE / luautils.INCREASE_DIV)

        -- Sub
    elseif (luautils.INCREASE_SUB) then
        luautils.INCREASE = (luautils.INCREASE - luautils.INCREASE_SUB)

    end
end

--=======================================
-- luautils.increase

luautils.SetupInc = function(i)

    --------
    if (string.match(i, "^%*")) then
        luautils.INCREASE_MULT = string.match(i, "(%d+)")
        print("mul " .. i)

    elseif (string.matchex(i, "^\\", "^/")) then
        luautils.INCREASE_DIV = string.match(i, "(%d+)")
        print("div " .. i)

    elseif (string.matchex(i, "^%-")) then
        luautils.INCREASE_SUB = string.match(i, "(%d+)")
        print("sub " .. i)

    else
        luautils.INCREASE_ADD = i
        print("add " .. i)
    end
end

--=======================================
-- luautils.increase
--
-- Args
--  1. Initial value (or 0)
--  2. Next value ( can be "/10" to DIVIDE, "*10" to MULTIPLY, "+10" to INCREMENT, or "-10" to DECREMENT - the Initital value )
-- Examples:
--  v = inc(1000, "+10") -> 1000 (No incrementing is done on the initial call)
--  w = inc(nil, "+15")  -> 1015 (Now +15)
--  x = inc()			 -> 1030 (+15)
--  y = inc()			 -> 1045 (+15)
--  z = inc("end")		 -> 1060 (+15 and stop inc())
--  	^ OR incEnd()	 -> 1060 (+15 and stop inc())

luautils.increase = function(start, add)

    local iAdd = CheckVar(add, 1)
    local bEnd = string.matchex(start, "end")
    if (start and not bEnd) then

        luautils.INCREASE = start
        luautils.EndInc(true)
        luautils.SetupInc(iAdd)


        return start
    end

    if (not luautils.INCREASE) then
        return
    end

    if (add) then
        luautils.EndInc(true)
        luautils.SetupInc(iAdd) -- dynamic update of the steps
    end

    luautils.StepInc()

    local r = luautils.INCREASE
    if (bEnd) then
        luautils.EndInc()
    end
    return r
end

-------------------

local function makeAny(f)
    return function(...)
        local a = { ... }
        if (table.count(a) < 1) then return end
        local bOk
        for i, hParam in pairs(a) do
            bOk = bOk or f(hParam)
        end
        return bOk
    end
end

local function makeAll(f)
    return function(...)
        local a = { ... }
        if (table.count(a) < 1) then return end
        local bOk = true
        for i, hParam in pairs(a) do
            bOk = bOk and f(hParam)
        end
        return bOk
    end
end

-------------------

IsAny = luautils.is_any
IsAll = luautils.is_all

CallAndExecute = luautils.callAndExecute
Inc = luautils.increase
IncEnd = function() return Inc("end")  end
unpack = (unpack or luautils.unpack)
GetRandom = luautils.random

IsNull = luautils.isNull
IsNullAny = makeAny(isNull)
IsNullAll = makeAll(isNull)

IsDead = luautils.isDead
IsDeadAny = makeAny(IsDead)
IsDeadAll = makeAll(IsDead)

IsNumber = luautils.isNumber
IsNumberAll = makeAll(isNumber)
IsNumberAny = makeAny(isNumber)
IsArray = luautils.isArray
IsBoolean = luautils.isBoolean
IsBool = luautils.isBoolean
IsString = luautils.isString
IsFloat = luautils.isFloat
IsFunction = luautils.isFunction
IsEntityId = luautils.isEntityId
IsUserdata = luautils.isEntityId

CheckVar = luautils.CheckVar
CheckFuncEx = luautils.checkFuncEx

CheckArray = luautils.checkArray
CheckGlobal = luautils.checkGlobal
CheckString = luautils.checkString

-- Numbers
CompareNumber = luautils.compNumber
CheckNumber = luautils.checkNumber
CheckNumberEx = luautils.checkNumberEx

GetDummyFunc = luautils.getDummyFunc
GetErrorDummy = luautils.getErrorDummy

RepeatArg = luautils.repeatargument
Switch = luautils.switch

Traceback = luautils.traceback
TracebackEx = luautils.tracebackex
throw_error = luautils.throw_error

-------------------
return luautils