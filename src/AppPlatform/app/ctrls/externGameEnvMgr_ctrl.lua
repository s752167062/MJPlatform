--扩展展游戏环境管理器

local ExternGameEnvMgr = class("ExternGameEnvMgr")
ExternGameEnvMgr.dir = "ExternGame/"
ExternGameEnvMgr.externHomeDir = ""  -- 扩展游戏的src或res都应该在里面有这个目录，并且所有的资源和代码都存放于这个目录
ExternGameEnvMgr.lua_loaded = {}
-- ExternGameEnvMgr.externGloble = {}

--游戏环境的lua使用这个函数加载
lua_load = function(str)
			--默认添加home的路径
			str = ExternGameEnvMgr.externHomeDir .. str

			local tmp = string.gsub(str,"%.","/")
			local utils = cc.FileUtils:getInstance()
			local path = utils:fullPathForFilename(tmp .. ".lua")
			if not path or path == "" then
                path = utils:fullPathForFilename(tmp .. ".luac")
            end

			-- cclog("lua_load path>>", path)
			-- 禁止load ExternGameEnvMgr.dir目录以外的脚本
			if string.match(path, "/" .. ExternGameEnvMgr.dir) then
				ExternGameEnvMgr.lua_loaded[str] = true
			    return backup_require(str)
			else
				cclog("Error: lua_load >", str)
				error("Error:lua_load load file path not 'ExternGame/' dir >>>")

			end
		end

isRequireExtern = function(fullPath, str)
			if string.match(fullPath, "/" .. ExternGameEnvMgr.dir) then
				cclog("Error: require >", str)
				error("Error: require do not load 'ExternGame/' dir >>>>")
				return false
			else
				return true
			end
		end




function ExternGameEnvMgr:split(str, delimiter)
    if str==nil or str=='' or delimiter==nil then
        return nil
    end
    
    local result = {}
    for match in (str..delimiter):gmatch("(.-)%"..delimiter) do
        table.insert(result, match)
    end
    return result
end

function ExternGameEnvMgr:ctor(params)
	local utils = cc.FileUtils:getInstance()
	local wp = writePathManager:getAppPlatformWritePath()
	if not utils:isDirectoryExist(wp .. ExternGameEnvMgr.dir) then
        utils:createDirectory(wp .. ExternGameEnvMgr.dir)
    end


	local tab = {}
	for k,v in ipairs(G_WRITEABLEPATH) do
		if not string.match(v, ExternGameEnvMgr.dir) then
			table.insert(tab, v)
		end
	end
	G_WRITEABLEPATH = tab

	table.insert(G_WRITEABLEPATH, writePathManager:getAppPlatformWritePath() .. ExternGameEnvMgr.dir) --优先可写路径
	table.insert(G_WRITEABLEPATH, G_WorkPath .. ExternGameEnvMgr.dir)
	

	cclog("ExternGameEnvMgr:ctor >>>>")
	print_r(G_WRITEABLEPATH)
end

function ExternGameEnvMgr:init()

end

--添加扩展游戏环境
function ExternGameEnvMgr:addEnv(envName)
	self:delEnv()
	__isExternEvn = true
	cclog("ExternGameEnvMgr:addEnv >>>>", envName)
	if not envName then return end
	

	for k,v in ipairs(G_WRITEABLEPATH) do

	    local writePath = v
	    if string.match(v, ExternGameEnvMgr.dir) then

		    local tb = cc.FileUtils:getInstance():getSearchPaths()
		    table.insert(tb, writePath .. envName .. "/")
		    table.insert(tb, writePath .. envName .. "/update/")
		    table.insert(tb, writePath .. envName .. "/update/src/")
		    table.insert(tb, writePath .. envName .. "/update/res/")
		    table.insert(tb, writePath .. envName .. "/update/res/ui") --适应编辑器的输出目录搜索路径
		    table.insert(tb, writePath .. envName .. "/src/")
		    table.insert(tb, writePath .. envName .. "/res/")
		    table.insert(tb, writePath .. envName .. "/res/ui") --适应编辑器的输出目录搜索路径
		    cc.FileUtils:getInstance():setSearchPaths(tb)
		end
	end

	local tb = cc.FileUtils:getInstance():getSearchPaths()
	-- print_r(tb)

	-- self:lockRequire(true)
	-- self:externGameGlobleValue()
end


--在进入或者回到平台时，总是应该调用这个函数，清除外部游戏的搜索环境
function ExternGameEnvMgr:delEnv()
	platformExportMgr:cleanListener()
	appPlatformGlobalManager:cleanExternGV()
	__isExternEvn = false
	gameNetMgr:removeReceiveHandler()
	-- self:lockRequire(false)
	-- ExternGameEnvMgr.externGloble = {}
	
	--清搜索路径
	cclog("ExternGameEnvMgr:delEnv >>>>")
	local tb = cc.FileUtils:getInstance():getSearchPaths()
	local tab = {}
	for k,v in ipairs(tb) do
		if not string.match(v, ExternGameEnvMgr.dir) then
			table.insert(tab, v)
		end
	end
	cc.FileUtils:getInstance():setSearchPaths(tab)

	-- print_r(tab)



	--清lua
	cc.FileUtils:getInstance():purgeCachedEntries()
    for k,v in pairs(ExternGameEnvMgr.lua_loaded) do
    	-- cclog("delEnv  >>", k)
    	package.loaded[k] = nil
	end
	ExternGameEnvMgr.lua_loaded = {}

 --    cclog("ExternGameEnvMgr:delEnv >>>>package.loaded")
	-- for k,v in pairs(package.loaded) do
	-- 	cclog(k,v)
	-- end
    
    cc.AnimationCache:destroyInstance()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    -- cc.SpriteFrameCache:getInstance():removeSpriteFrames()
    -- cc.Director:getInstance():getTextureCache():removeAllTextures()
end

--锁住、放开 require方法（扩展游戏不能用require）
-- function ExternGameEnvMgr:lockRequire(flag)
	-- if flag then
	-- 	require = function()
	-- 		cclog("Error: require do not use in 'ExternGame/' dir >>>>")
	-- 		error(debug.traceback())
	-- 	end
	-- else
	-- 	require = tmp_require
	-- end
-- end

--注册扩展游戏的全局变量
-- function ExternGameEnvMgr:registerExternGameGlobleValue(key, value)
	
-- 	ExternGameEnvMgr.externGloble[key] = value
-- end

-- --扩展游戏全局变量获取管制
-- function ExternGameEnvMgr:externGameGlobleValue()
-- 	local __g = _G
--  	setmetatable(__g, {
--         __newindex = function(_, name, value)
--         	cclog(debug.traceback())
--             error(string.format("USE \" cc.exports.%s = value \" INSTEAD OF SET GLOBAL VARIABLE", name), 0)
--         end,
--         __index = function(tab, key)
--         	cclog("__index >>", key)
--         	return ExternGameEnvMgr.externGloble[key]
--        	end
--     })
-- end

function ExternGameEnvMgr:externGameGlobalValue(callback)
	-- --开放全局变量注册，并且扩展包只注册到一个表里
	-- local __g = _G
	-- local tmp_tab = {}
	-- _G = tmp_tab
 -- 	setmetatable(tmp_tab, {
 -- 		--全局变量的添加和赋值
 --        __newindex = function(_, name, value)
 --        	if __g[name] then
 --        		--不允许你覆盖全局表的平台全局变量,不允许你与全局变量同名
 --        		error(string.format("Error: G table is exist key=%s", name), 0)
 --        	else
 --        		ExternGameEnvMgr.externGloble[name] = value
 --        	end
 --        end,

 --        --全局变量的索引
 --        __index = function(tab, key)
 --        	if __g[key] then
 --        		return __g[key]
 --        	else
 --        		return ExternGameEnvMgr.externGloble[key]
 --        	end
 --    	end
 --    })

 -- 	--安全调用，callback的报错不影响我全局表的还原
 -- 	-- xpcall(function () callback() end, __G__TRACKBACK__)
 -- 	callback()
	
	-- _G = __g

	-- --关闭全局变量注册
	-- local __g = _G
 -- 	setmetatable(__g, {
 --        __newindex = function(_, name, value)

 --            error(string.format("USE \" cc.exports.%s = value \" INSTEAD OF SET GLOBAL VARIABLE 111", name), 0)
 --        end,
 --        __index = function(tab, key)
 --        	cclog("__index >>", key)
 --        	return ExternGameEnvMgr.externGloble[key]
 --       	end
 --    })

	appPlatformGlobalManager:externGlobalAble(ExternGameEnvMgr.externGloble)
	xpcall(function () callback() end,
			 function (msg) 
			 	appPlatformGlobalManager:cleanExternGV()
			 	__G__TRACKBACK__(msg) 
			 end)
	appPlatformGlobalManager:disableGlobalValue()
end



return ExternGameEnvMgr























