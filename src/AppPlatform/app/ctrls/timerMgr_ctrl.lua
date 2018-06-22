--@时间管理类
--@Author 	sunfan
--@date 	2017/04/27
local TimerMgr = class("TimerMgr")

TimerMgr.TYPE_CALL_ONE = 1
TimerMgr.TYPE_CALL_RE  = 2

function TimerMgr:ctor(params)
	if self._scheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduler)
	end
	self._scheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (dt) self:_update(dt) end,0,false, "platform")
	self._register = {}
	self._tasks = {}
end

function TimerMgr:_update(dt)
	for k,v in pairs(self._register) do
		if v and v.update then
			v:update(dt)
		end
	end
	for k,v in pairs(self._tasks) do
		if k and v then
			if v.remove then
				self._tasks[k] = nil
			else
				if v.taskType == TimerMgr.TYPE_CALL_ONE then
					v.c_dt = v.c_dt + dt
					if v.c_dt >= v.time then
						v.callback()
						v.remove = true
					end
				elseif v.taskType == TimerMgr.TYPE_CALL_RE then
					v.c_dt = v.c_dt + dt
					if v.c_dt >= v.time then
						v.c_dt = v.c_dt - v.time
						v.callback()
					end
				else
					dump("Unknow Task Type!")
				end
			end
		end
	end
end

--注册update对象
function TimerMgr:register(object)
	self._register[object] = object
end

function TimerMgr:unRegister(object)
	self._register[object] = nil
end

--@注册计时器任务
--@taskName 任务名字
--@taskType 任务类型:
--						timerMgr.TYPE_CALL_ONE	:在time后只执行一次
--						timerMgr.TYPE_CALL_RE 	:每隔time时间执行一次
--@callBack 任务回调
--@time 	任务时间(根据任务类型有不同定义),单位:秒(支持小数)
function TimerMgr:registerTask(taskName,taskType,callBack,time)
	local task = {}
	task.taskName = taskName
	task.taskType = taskType
	task.callback = callBack
	task.time = time
	task.c_dt = 0
	task.remove = false
	if self._tasks[taskName] then
		dump("register fail ,exist task! " ..taskName)
		return
	end
	self._tasks[taskName] = task
end

--@移除任务
--@taskName 任务名
function TimerMgr:clearTask(taskName)
	self._tasks[taskName] = nil
end

--@报错移除所有任务
function TimerMgr:clearAllTask()
	self._register = {}
	self._tasks = {}
end

--@检查任务是否在
function TimerMgr:isTaskExit(taskName)
	if self._tasks[taskName] then 
		return true
	end	
	return false
end
return TimerMgr
