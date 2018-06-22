-----------------------------------------   check and clean cache ---------------------------------------
---- 设置搜索路径之后
__G__TRACKBACK__2 = function(msg)
    release_print("----------------------------------------")
    release_print("LUA ERROR: " .. tostring(msg) .. "\n")
    release_print(debug.traceback())
    release_print("----------------------------------------")
    return msg
end
local function check_and_clean()

    local dkj = require("Manager/ManagerDkjson")
    local utils = cc.FileUtils:getInstance()
    local targetPlatform = cc.Application:getInstance():getTargetPlatform() 
    local app_version = "0.0.0"  --应用内版本号
    local update_version = "0.0.0"  --热更新版本号
    if targetPlatform == cc.PLATFORM_OS_ANDROID then

        local chunk = utils:getStringFromFile(__platformHomeDir .. "Manifests/project_android.manifest")
        local tab = dkj.decode(chunk)           
        app_version = tab.version
    else
        -- if utils:isFileExist("Manifests/project_ios.manifest") then
        local chunk = utils:getStringFromFile(__platformHomeDir .. "Manifests/project_ios.manifest")
        local tab = dkj.decode(chunk)
        app_version = tab.version
    end

    if utils:isFileExist("project.manifest") then
        local chunk = utils:getStringFromFile("project.manifest")
        local tab = dkj.decode(chunk)
        update_version = tab.version
    end

    local function split(str, delimiter)
        if str==nil or str=='' or delimiter==nil then
            return nil
        end
        
        local result = {}
        for match in (str..delimiter):gmatch("(.-)%"..delimiter) do
            table.insert(result, match)
        end
        return result
    end

    local a = split(app_version, ".")
    local u = split(update_version, ".")
    -- 除了第一段位外，其余每个段位只能支持4位数
    local tmp_a = a[3] + a[2]*10000 + a[1]*100000000
    local tmp_u = u[3] + u[2]*10000 + u[1]*100000000
    release_print("version compare >>>",tmp_a, tmp_u)
    -- 热更新的缓存版本号小于等于应用包内的版本号，则删除缓存
    if tmp_a >= tmp_u then
        local path = writePathManager:getAppPlatformWritePath() .. "update/"
        if cc.FileUtils:getInstance():isDirectoryExist(path) then
            if cc.FileUtils:getInstance():removeDirectory(path) then
                release_print("delete update success!")
            else
                release_print("delete update fail!")
            end
        end
    end

end

-- mac 和 windows开发的环境下不做容错处理
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
release_print("cc.PLATFORM_OS_MAC", cc.PLATFORM_OS_MAC) 
if targetPlatform == cc.PLATFORM_OS_MAC or targetPlatform == cc.PLATFORM_OS_WINDOWS then
    check_and_clean()
else
    xpcall(check_and_clean, __G__TRACKBACK__2)
end
-----------------------------------------   check and clean cache ---------------------------------------