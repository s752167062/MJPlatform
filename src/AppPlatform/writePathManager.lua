

writePathManager = {}

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
if targetPlatform == 0 then
	__writePath = cc.FileUtils:getInstance():getWritablePath() .. "wpd/"
else
	__writePath = cc.FileUtils:getInstance():getWritablePath()
end

local f = cc.FileUtils
function f:getWritablePath()
    -- release_print("Error: do not use cc.FileUtils:getInstance():getWritablePath() >>", 0)
    -- release_print(debug.traceback())

    error("Error: do not use cc.FileUtils:getInstance():getWritablePath() >>", 0)
    return ""
end


function writePathManager:getAppPlatformWritePath()
	return __writePath
end
