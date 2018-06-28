
AOVMgr = {}

AOVMgr._2D = "2D"
AOVMgr._2_5D = "2_5D"

AOVMgr.GameMode = {[AOVMgr._2D] = true, [AOVMgr._2_5D] = false}

function AOVMgr:readGameMode() 
    local tb_str = UserDefault:setKeyValue("AOVMgr_GameMode", "")
    if tb_str ~= nil and tb_str ~= "" then
        --cclog("GameMode tb_str:"..tb_str)
        local tb = json.decode(tb_str)
        for i, v in pairs(tb) do
            if v == true then
                AOVMgr:setGameMode(i)
                break
            end
        end
    end
    AOVMgr:setGameMode(AOVMgr._2D)  --默认2D
end

--设置游戏模式
function AOVMgr:setGameMode(flag)    --"2d" "2_5d"
    if AOVMgr.GameMode[flag] == nil or AOVMgr.GameMode[flag] == true then return false end
    local oldMode = nil
    for i, v in pairs(AOVMgr.GameMode) do
        if v == true then oldMode = i end
        if i == flag then
            AOVMgr.GameMode[i] = true
        else
            AOVMgr.GameMode[i] = false
        end
    end
    local tb_str = json.encode(AOVMgr.GameMode)
    UserDefault:setKeyValue("AOVMgr_GameMode", tb_str)
    UserDefault:write()
    return true, oldMode
end
--获取游戏模式
function AOVMgr:getGameMode()
    for i, v in pairs(AOVMgr.GameMode) do
        if v == true then return i end
    end
end

function AOVMgr:is2D()
    return AOVMgr:getGameMode() == AOVMgr._2D
end

function AOVMgr:is2_5D()
    return AOVMgr:getGameMode() == AOVMgr._2_5D
end

--更换模式
function AOVMgr:switchGameMode(flag)
    local ret, mode = AOVMgr:setGameMode(flag)
    cclog("switchGameMode  ret:"..tostring(ret).."  mode:"..mode)   
    if ret == true then
        local res = {}
        res.oldMode = mode
        res.newMode = flag
        CCXNotifyCenter:notify("ModeHasChange", res)
    end
end

--===========================================




return AOVMgr
