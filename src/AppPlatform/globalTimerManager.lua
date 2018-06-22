
globalTimerManager = {}

local obj = cc.Director:getInstance():getScheduler()
obj.tmp_scheduleScriptFunc = obj.scheduleScriptFunc
obj.__externGlobalTimer = {}
--重写该函数来管控全局定时器，如果未定义user，则在为扩展游戏的全局定时器，在环境卸载时将会被清除
function obj:scheduleScriptFunc(a,b,c, user)
	release_print("-----------------------------------------------------------------------------")
	release_print("Warning: if not user of 'platform' type, then will be delete when delete externGame evn >>>")
	-- release_print(debug.traceback())
	local scheduleID = obj:tmp_scheduleScriptFunc(a,b,c)

	release_print("register global timer >", scheduleID, user)
	if user == "platform" then
	else
		self.__externGlobalTimer[scheduleID] = true
	end
	release_print("-----------------------------------------------------------------------------")
	return scheduleID
end

--清除外部扩展游戏的全局定时器
function globalTimerManager:delExternGlobalTimer()
	local obj = cc.Director:getInstance():getScheduler()
	for k,v in pairs(obj.__externGlobalTimer) do
		release_print("globalTimerManager:delExternGlobalTimer >", k)
		obj:unscheduleScriptEntry(k)
	end

	obj.__externGlobalTimer = {}
end
