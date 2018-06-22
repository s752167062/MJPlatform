--@事件管理类
--@Author 	sunfan
--@date 	2017/05/20
local EventMgr = class("EventMgr")
function EventMgr:ctor(params)
	--所有监听的事件
	self._events = {}
	--所有被冻结的事件
	self._freezeEvent = {}
	--所有被冻结的待处理的事件数据
	self._freezeEventData = {}
	--等待被解冻的事件
	self._unfreezeEvent = {}
	--无主事件
	self._noHandlerEvent = {}
	timerMgr:register(self)
end

--注册事件
function EventMgr:registerEventListener(eventName,callBack,target)
	if self._events[eventName] and self._events[eventName].callBack == callBack and self._events[eventName].target == target then
		dump("##########double event register, name is:"..eventName)
	else
		if self._events[eventName] == nil then
			self._events[eventName] = {}
		end
		self._events[eventName][#self._events[eventName] + 1] = {callBack = callBack,target = target}
	end
end

--冻结某一事件
function EventMgr:freezeEvent(eventName)
	self._freezeEvent[eventName] = true
	self._unfreezeEvent[eventName] = nil
	printInfo("freezeEvent eventName = "..eventName)
end

--解冻某一事件
function EventMgr:unfreezeEvent(eventName)
	if not self._freezeEvent[eventName] then
		return
	end
	self._unfreezeEvent[eventName] = true
	printInfo("unfreezeEvent eventName = "..eventName)
end

--检查是否冻结事件
function EventMgr:_checkIsFreezeEvent(eventName)
	if self._freezeEvent[eventName] and self._freezeEvent[eventName] == true then
		return true
	end
	return false 
end

--处理冻结事件
function EventMgr:update(dt)
	--处理无主事件
	-- self:_handlerNoHandlerEvent(dt)
	
	for k,v in pairs(self._unfreezeEvent) do
		if self._unfreezeEvent[k] then--这个事件在等待解冻队列里面
			self._freezeEvent[k] = nil
			self._unfreezeEvent[k] = nil
		end
	end

	if #self._freezeEventData <= 0 then
		return
	end
	local remainEventData = {}
	for loop = 1,#self._freezeEventData do
		local event = self._freezeEventData[loop]
		local name = event.eventName	
		if self._freezeEvent[name] then--这个事件在冻结队列里面
			remainEventData[#remainEventData + 1] = {eventName = name,data = event.data}
		else
			self:dispatchEvent(name, event.data)
		end
	end
	self._freezeEventData = remainEventData
end

--处理无主事件
function EventMgr:_handlerNoHandlerEvent(dt)
	local remainEvent = {}
	for loop = 1,#self._noHandlerEvent do
		local eventData = self._noHandlerEvent[loop]
		if eventData then
			--判断是否冻结事件
			if self:_checkIsFreezeEvent(eventData.eventName) then
				self._freezeEventData[#self._freezeEventData + 1] = {eventName = eventData.eventName,data = eventData.data}
			else
				if self._events[eventData.eventName] then
					for loop = 1,#self._events[eventData.eventName] do
						if self._events[eventData.eventName][loop] then
							printInfo("dispatchEvent eventName = "..eventData.eventName)
							self._events[eventData.eventName][loop].callBack(eventData.data)
						end
					end
				else
					if eventData.delTime - dt > 0 then
						remainEvent[#remainEvent + 1] = {eventName = eventData.eventName,data = eventData.data,delTime = eventData.delTime - dt}
					else
						dump(msgMgr:getMsg("DELETE_NO_HANDLER_EVENT")..eventData.eventName)
					end
				end
			end
		end
	end
	self._noHandlerEvent = remainEvent
end

--投递事件
function EventMgr:dispatchEvent(eventName,data)
	if not eventName or eventName == "" then
		return
	end

	if self:_checkIsFreezeEvent(eventName) then--判断是否冻结事件
		self._freezeEventData[#self._freezeEventData + 1] = {eventName = eventName,data = data}
		printInfo("eventName = "..eventName.." is freezeing")
		return
	end
	
	if self._events[eventName] then
		for loop = 1,#self._events[eventName] do
			if self._events[eventName][loop] then
				printInfo("dispatchEvent eventName = "..eventName)
				self._events[eventName][loop].callBack(data)
			end
		end
	else
		--无主事件
		-- self._noHandlerEvent[#self._noHandlerEvent + 1] = {eventName = eventName,data = data,delTime = 5}
	end
end

--移除某一事件的全部监听者
function EventMgr:removeAllEventListener(eventName)
	self._events[eventName] = nil
end

--移除某一监听者的某一事件
function EventMgr:removeEventListenerForObject(eventName,target)
	if self._events[eventName] then
		local temp = {}
		for loop = 1,#self._events[eventName] do
			if self._events[eventName][loop].target ~= target then
				temp[#temp + 1] =  {target =  self._events[eventName][loop].target,callBack = self._events[eventName][loop].callBack}
			end
		end
		if #temp <= 0 then
			self._events[eventName] = nil
		else
			self._events[eventName] = temp
		end
	end
end

--移除某一监听者全部事件
function EventMgr:removeEventListenerForTarget(target)
	if not target then
		return
	end
	local remainEvent = {}
	for k,v in pairs(self._events) do
		local temp = {}
		for loop = 1,#v do
			if v[loop] then
				if not v[loop].target or (v[loop].target and v[loop].target ~= target) then
					temp[#temp + 1] = {target = v[loop].target,callBack = v[loop].callBack}
				else
					--移除target的全部事件
					self._freezeEvent[k] = nil
					self._unfreezeEvent[k] = nil
					local remainEventData = {}
					for loop = 1,#self._freezeEventData do
						local event = self._freezeEventData[loop]
						local name = event.eventName	
						if name ~= k then
							remainEventData[#remainEventData + 1] = {eventName = name,data = event.data}
						end
					end
					self._freezeEventData = remainEventData
				end 
			end 
		end
		if #temp > 0 then
			remainEvent[k] = temp
		end
	end
	self._events = remainEvent
end

return EventMgr