-----------------------------------------------------------------------------------
-- Author: shortcut0
-- Description: general functions that might come in handy


-------------------
timer = {}

---------------------------
-- timer.new

timer.new = function(expiry)

	-----------
	local timer = timer
	local hNew = {}
	
	hNew.created = timer.init()
	hNew.timer = timer.init()
	hNew.expiry = expiry
	hNew.is_new = true

	--------
	hNew.setexpiry = function(i)
		if (IsNumber(i)) then
			hNew.expiry = i
		end
	end
	--------
	hNew.refresh = function(i)
		hNew.timer = timer.init()
		hNew.expiry = CheckVar(i, hNew.expiry)
	end
	--------
	hNew.expired = function(i)
		--if (hNew.is_new and i==nil) then
		--	hNew.is_new = false
		--	return true
		--end
		 --hNew.is_new = false
		return (timer.expired(hNew.timer, CheckNumber(i, hNew.expiry)))
	end
	--------
	hNew.expired_refresh = function(i)
		local expired = (timer.expired(hNew.timer, CheckNumber(i, hNew.expiry)))
		if (expired) then
			hNew.refresh(i)
			return true
		end
		return false
	end
	--------
	hNew.getexpiry = function()
		local i = (timer.diff(hNew.timer))
		return (hNew.expiry - i)
	end
	--------
	hNew.GetExpiry = hNew.getexpiry
	hNew.SetExpiry = hNew.setexpiry
	--------
	hNew.expire = function(ms)
		if (ms) then hNew.expiry = ms end
		hNew.timer = timer.init() - CheckNumber(hNew.expiry, 0)
	end
	--------
	hNew.diff_t = function(i) -- diff since creation
		return (timer.diff(hNew.created))
	end

	--------
	hNew.diff = function(i) -- diff since refresh (or creation)
		return (timer.diff(hNew.timer))
	end
	hNew.diff_refresh = function(i)
		local diff = (timer.diff(hNew.timer))
		hNew.refresh()
		return (diff)
	end

	-----------
	return hNew
end

---------------------------
-- luautils.init

timer.init = function()
	return (os.clock())
end

---------------------------
-- luautils.destroy

timer.destroy = function(hTimer)
	hTimer = nil
	return (nil)
end

---------------------------
-- timer.diff

timer.diff = function(hTimer)
	return (os.clock() - hTimer)
end

---------------------------
-- timer.check

timer.expired = function(hTimer, iTime)

	-----------
	if (not IsNumber(hTimer)) then
		return true end
		
	-----------
	if (not IsNumber(iTime)) then
		return true end
	
	-----------
	return (timer.diff(hTimer) >= iTime)
end

---------------------------
-- timer.sleep

timer.sleep = function(iMs)

	-----------
	if (not IsNumber(iMs)) then
		return end

	-----------
	local iMs = (iMs / 1000)

	-----------
	local hSleepStart = timer.init()
	repeat
		-- sleep well <3
	until (timer.expired(hSleepStart, iMs))
end

---------------------------
-- timer.sleep_call

timer.sleep_call = function(iMs, fCall, ...)

	-----------
	if (not fCall) then
		return timer.sleep(iMs) end

	-----------
	if (not IsNumber(iMs)) then
		return end

	-----------
	local iMs = (iMs / 1000)
	
	-----------
	local hSleepStart = timer.init()
	repeat
		-- sleep well <3
	until ((iMs ~= -1 and (timer.expired(hSleepStart, iMs))) or (fCall(...) == true))
end


-------------------
TimerNew	 = timer.new 		-- new timer instance
TimerInit 	 = timer.init		-- new time instance
TimerDestroy = timer.destroy	-- destroys a timer
TimerDiff 	 = timer.diff		-- different of a timer
TimerExpired = timer.expired	-- checks if a timer expired
Sleep 		 = timer.sleep		-- sleep function
SleepCall 	 = timer.sleep_call	-- sleep function with predicate

-------------------
return timer