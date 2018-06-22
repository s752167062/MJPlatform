
__G__TRACKBACK__2 = function(msg)
    release_print("----------------------------------------")
    release_print("LUA ERROR: " .. tostring(msg) .. "\n")
    release_print(debug.traceback())
    release_print("----------------------------------------")
    return msg
end


appPlatformGlobalManager = {}

__appPlatformGV = {}
__appPlatformExternGV = {}


--打印添加数据会卡死哦~！~！~！~！

function appPlatformGlobalManager:init()


	setmetatable(__appPlatformGV, {
			__index = function(tab, key)
				return __appPlatformExternGV[key]
			end
		})

	local __g = _G
 	setmetatable(__g, {
        __newindex = function(_, name, value)
        	__appPlatformGV[name] = value
        end,
        __index = function(tab, key)
        	return __appPlatformGV[key]
       	end
    })
end

function appPlatformGlobalManager:disableGlobalValue()
	local __g = _G
 	setmetatable(__g, {
        __newindex = function(_, name, value)

        	if rawget(__appPlatformGV, name) ~= nil then
        		error(string.format("Error: disableGlobalValue __appPlatformGV do not edit >> %s", name), 0)
        	elseif rawget(__appPlatformExternGV, name) ~= nil then
        		rawset(__appPlatformExternGV, name, value)
        	else
        		error(string.format("Error: appPlatformGlobalManager:disableGlobalValue >> %s", name), 0)
        	end

        	
        end,
        __index = function(tab, key)
        	return __appPlatformGV[key]

        -- 	if __isExternEvn then
        -- 		local extern_value = rawget(__appPlatformExternGV, key) 
        --         -- release_print("aab 1>", extern_value, key)
        --         -- release_print(debug.traceback())
        -- 		if extern_value ~= nil then
        -- 			return extern_value
        -- 		else
        -- 			return rawget(__appPlatformGV, key)
        -- 		end

        -- 	else
        --         -- release_print("aab 22>", key)
        --         -- release_print(debug.traceback())
        -- 		return rawget(__appPlatformGV, key)
        -- 	end
       	end
    })
end

-- 重要全局变量全局函数包含列表
local appPlatformProtect = {
	lua_load = true,
	externGameEnvMgr = true,
	externGameMgr = true,
	platformExportMgr = true,
	isRequireExtern = true,
	__isExternEvn = true,
	__platformHomeDir = true,
	backup_require = true,
	G_WRITEABLEPATH = true,
	G_WorkPath = true,
	__writePath = true,
    writePathManager = true,
    globalTimerManager = true,
    applicationDidEnterBackground = true,
    applicationWillEnterForeground = true,
}

function appPlatformGlobalManager:externGlobalAble()
	-- __appPlatformExternGV = externTab
	local __g = _G
 	setmetatable(__g, {
        __newindex = function(_, name, value)
        	release_print("externGlobalAble >>>111", name)
        	if rawget(__appPlatformGV, name) ~= nil then
        		error(string.format("Error: value of __appPlatformGV do not edit >> %s", name), 0)
        		return
        	end
        	release_print("externGlobalAble >>>222", name)
        	rawset(__appPlatformExternGV, name, value)



        	-- if appPlatformProtect[name] then
        	-- 	error(string.format("Error: is platform global value >> %s", name), 0)
        	-- 	return 
        	-- end
        	-- rawset(__appPlatformExternGV, name, value)
        	

        end,

        __index = function(tab, key)
        	return __appPlatformGV[key]

        -- 	if __isExternEvn then
        -- 		local extern_value = rawget(__appPlatformExternGV, key) 
        -- 		if extern_value ~= nil then
        -- 			return extern_value
        -- 		else
        -- 			return rawget(__appPlatformGV, key)
        -- 		end

        -- 	else
        --         -- release_print("aab 3>", key)
        -- 		return rawget(__appPlatformGV, key)
        -- 	end
       	end
    })
end

function appPlatformGlobalManager:cleanExternGV()
	__appPlatformExternGV = {}
end


local function xxx()
	appPlatformGlobalManager:init()
end





local status, msg = xpcall(xxx, __G__TRACKBACK__2)
if not status then
    print(msg)
end