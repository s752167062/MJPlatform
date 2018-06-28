--@单例管理类
--@Author 	sunfan
--@date 	2017/04/27
local FileMgr = class("FileMgr")

function FileMgr:ctor(params)
	
end

function FileMgr:loadLua(path)
	-- body
	return lua_load(path)
end

function FileMgr:getWritablePath()
    -- body
    return platformExportMgr:getGameWriteDirPath("hongzhong")
end

function FileMgr:isFileExist(path)
    -- body
    return cc.FileUtils:getInstance():isFileExist(path)
end

function FileMgr:isDirectoryExist(path)
    -- body
    return cc.FileUtils:getInstance():isDirectoryExist(path)
end

function FileMgr:createDirectory(path)
    -- body
    return cc.FileUtils:getInstance():createDirectory(path)
end

function FileMgr:removeFile(path)
    -- body
    cc.FileUtils:getInstance():removeFile(path)
end

function FileMgr:getStringFromFile(path)
    -- body
    return cc.FileUtils:getInstance():getStringFromFile(path)
end

function FileMgr:removeDirectory(path)
    -- body
    cc.FileUtils:getInstance():removeDirectory(path)
end

return FileMgr