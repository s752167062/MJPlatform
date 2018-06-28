--@单例管理类
--@Author 	sunfan
--@date 	2017/04/27
local SingleMgr = class("SingleMgr")

function SingleMgr:ctor(params)
	self._singles = {}
	self:_intLocks()
end

--初始化互斥锁(用于业务互斥)
function SingleMgr:_intLocks()
	self._locks = {}
end

--获取锁
function SingleMgr:getlock(key)
	if self._locks[key].value then
		return false
	else
		self._locks[key].value = true
		self._locks[key].change = true
		return true
	end
end

--查询锁有无发生变化
function SingleMgr:checkLockChange(key)
	if self._locks[key].change then
		self._locks[key].change = false
		return true
	else
		return false
	end
end

--查询锁状态
function SingleMgr:checkLock(key)
	return self._locks[key].value
end

--重置锁状态
function SingleMgr:resetLock(key)
	if self._locks[key] then
		self._locks[key].value = false
		self._locks[key].change = false
	end
end

--释放锁
function SingleMgr:unlock(key)
	if self._locks[key] then
		self._locks[key].change = true
	end
	self._locks[key].value = false
end

--@name  	单例类名
--@reName	别名
--@params	携带参数
function SingleMgr:register(name,reName,params)
	if self._singles[name] then
		dump("Register Fail,Exist Instance")
		return
	end
	self._singles[name] = require(name).new(params)
	platformExportMgr:registerGlobleValue(reName, self._singles[name])

	dump("register single "..name)
end

return SingleMgr