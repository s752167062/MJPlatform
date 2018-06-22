--@游戏主函数、启动配置
--@Author   sunfan
--@date     2017/04/27



__isExternEvn = false
__platformHomeDir = "AppPlatform/"
if not backup_require then
    backup_require = require
end

--打印添加数据会卡死哦~！~！~！~！
require = function(str)
            --只有平台用require函数，平台默认添加一个文件夹，优先加载
            local tmp_str = __platformHomeDir .. str

            local tmp = string.gsub(tmp_str,"%.","/")

            local utils = cc.FileUtils:getInstance()
            local path = utils:fullPathForFilename(tmp .. ".lua")
            if not path or path == "" then
                path = utils:fullPathForFilename(tmp .. ".luac")
            end
            -- release_print("require path>>>", path)

            --如果是加载extern的文件则报错
            if isRequireExtern then
                -- release_print("require 22>>>", tmp)
                local exter_path = utils:fullPathForFilename(str .. ".lua")
                if not exter_path or exter_path == "" then
                    exter_path = utils:fullPathForFilename(str .. ".luac")
                end
                if not isRequireExtern(exter_path, str) then
                    return 
                end
            end

            --找到意味着加载平台文件
            if path and path ~= "" then
                return backup_require(tmp_str)
            end

            --未找到默认加载系统文件例如“math” “table” “mime”
            return backup_require(str)

        end


local app = cc.Application:getInstance()
G_WRITEABLEPATH = {}   -- insert他的顺序尤为重要，mac的路径要在update之前
G_WorkPath = ""
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
print("targetPlatform = "..targetPlatform)
if targetPlatform == 2 then
	--设置屏幕大小
	-- cc.Director:getInstance():getOpenGLView():setFrameSize(720,502)

    local is_ok = os.execute("pwd")
    print (cmd_str, is_ok)
    local full_path = nil
    if is_ok == 0 then

        local f = io.popen("pwd")
        full_path = f:read("*all")
        io.close(f)
        
    end
    if full_path then
    -- table.insert(G_WRITEABLEPATH, "/Users/liguangfeng/Documents/work/aaa/newProject/GameChess/")
        print (full_path)
        full_path = string.sub(full_path, 1, -2)
        local work_path = full_path .. "/../../../../../"
        print (work_path)
        table.insert(G_WRITEABLEPATH, work_path)
        G_WorkPath = work_path
        -- return
    end
elseif targetPlatform == 0 then
    --  为windows创建可写环境目录
    local f = cc.FileUtils
    f.wp = cc.FileUtils:getInstance():getWritablePath()
    if not cc.FileUtils:getInstance():isDirectoryExist(f.wp .. "wpd/") then
        cc.FileUtils:getInstance():createDirectory(f.wp .. "wpd/")
    end
    function f:getWritablePath()
        return f.wp .. "wpd/"
    end


end

table.insert(G_WRITEABLEPATH, cc.FileUtils:getInstance():getWritablePath().."update/")
-- print("G_WRITEABLEPATH = ", G_WRITEABLEPATH)

--保证能搜索到更新文件夹，main文件是不能热更的，只能使用gameInit来热更，要保证能搜索到update/src/gameInit.lua
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

-- 要用ipairs来遍历，才能使得后来的update路径居上
for k,v in ipairs(G_WRITEABLEPATH) do

    local writePath = v
    local tb = cc.FileUtils:getInstance():getSearchPaths()
    table.insert(tb, 1, writePath)
    table.insert(tb, 1, writePath .. "src/")
    table.insert(tb, 1, writePath .. "res/")
    cc.FileUtils:getInstance():setSearchPaths(tb)
end




-- cc.Director:getInstance():getOpenGLView():setFrameSize(650,400)


-- 必须早于所有require
require (__platformHomeDir .. "appPlatformGlobalManager")
require (__platformHomeDir .. "writePathManager")
require (__platformHomeDir .. "globalTimerManager")








require "config"
require "cocos.init"


require "UpdateCheck"

require "gameInit"
require "app.GLShader.shaderMgr"

local function main()
    collectgarbage("collect")
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    appStart()

    cclog("abcd >>>>")
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
