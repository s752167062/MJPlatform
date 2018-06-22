local PlatformExportEventMgr = class("PlatformExportEventMgr")

PlatformExportEventMgr.Listener = {}


function PlatformExportEventMgr:ctor(param)
	PlatformExportEventMgr.Listener = {}
end

function PlatformExportEventMgr:cleanListener()
	cclog("PlatformExportEventMgr:cleanListener >>>>")
	PlatformExportEventMgr.Listener = {}
end

function PlatformExportEventMgr:removeListenerByObj(obj)
	local tmp = {}
	for k,v in pairs(PlatformExportEventMgr.Listener) do
		
		local et = {}
		for i,j in ipairs(v) do
			
			if j.obj ~= obj then
				table.insert(et, j)
			end
		end
		tmp[k] = et
	end

	PlatformExportEventMgr.Listener = tmp
end

function PlatformExportEventMgr:removeListenerByEvent(eventType)
	PlatformExportEventMgr.Listener[eventType] = {}
end

function PlatformExportEventMgr:registerListener(eventType, obj, callback)
	cclog("PlatformExportEventMgr:registerListener >>>", eventType)
	-- cclog(">>>> ", self.Listener, platformExportMgr.Events_WillEnterForeground)
	if not PlatformExportEventMgr.Listener[eventType] then
		PlatformExportEventMgr.Listener[eventType] = {}
	end
	table.insert(PlatformExportEventMgr.Listener[eventType], {obj = obj, callback = callback})
end

function PlatformExportEventMgr:dispathEvent(eventType, data)
	local ls = PlatformExportEventMgr.Listener[eventType] or {}
	cclog("PlatformExportEventMgr:dispathEvent >>>", eventType)
	for k,v in ipairs(ls) do
		cclog("PlatformExportEventMgr:dispathEvent 11>>>", eventType)
		v.callback(v.obj, data)
	end
end


return PlatformExportEventMgr





