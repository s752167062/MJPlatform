CCXNotifyCenter = {}

CCXNotifyCenter.keys = {}

function CCXNotifyCenter:listen(obj,fun,key)
    if self.keys[key] == nil then
    	self.keys[key] = {}
    end
    self.keys[key][obj] = {obj=obj,fun=fun}
end

function CCXNotifyCenter:unListenByObj(obj)
    for key, var in pairs(self.keys) do
    	var[obj] = nil
    end
end

function CCXNotifyCenter:unListenByKey(key)
    self.keys[key] = nil
end

function CCXNotifyCenter:unListen(obj,key)
    if self.keys[key] == nil then
        return
    end
    self.keys[key][obj] = nil
end

function CCXNotifyCenter:notify(key,data)
    if self.keys[key] == nil then
        return
    end
    for k,o in pairs(self.keys[key]) do
        o.fun(o.obj,key,data)
    end
end