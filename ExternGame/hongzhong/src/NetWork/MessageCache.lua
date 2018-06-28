MessageCache = {}
MessageCache.cache_list = {}


function MessageCache:setCache(key, value)
	self.cache_list[key] = value
end

function MessageCache:popCache(key)
	local value = self.cache_list[key]
	self.cache_list[key] = nil
	return value
end



function MessageCache:chearCache()
	self.cache_list = {}
end

