--ex_fileMgr:loadLua("app.helper.CCXNotifyCenter")
--ex_fileMgr:loadLua("SDK.SDKController")
--ex_fileMgr:loadLua("app.Configure.Game_conf")

GlobalFun = {}
GlobalFun.cartSum = 112
local BaseError = ex_fileMgr:loadLua("app.Common.CUIMsgError")
local BaseError2 = ex_fileMgr:loadLua("app.Common.CUITiShi")
local BaseError3 = ex_fileMgr:loadLua("app.Common.CUITiShi_A")
local BaseConnectMSG = ex_fileMgr:loadLua("app.Common.CUIConnectMSG")
local BaseToastMSG = ex_fileMgr:loadLua("app.Common.CUIToastMsg")
local itemSpeak = ex_fileMgr:loadLua("app.views.game.item_speak")

MSG_TAG = 1000
NETConnect_TAG = 1001
SPEAK_TAG = 1002
TOAST_TAG = 1003
VOTEUI_TAG = 1004

function GlobalFun:make_Product(res)
    for index = 1, #res do
        local item = res[index]
        
        local data = {}
        data.goodsID = item.thingsid
        data.name = "房卡" 
        data.price = item.money   
        data.count = item.card
        data.thingsid = item.thingsid
        data.type = item.type
        if item.type == 1 then
            data.name = "金币"
        end
        cclog("价格  " .. data.price)
        Product[index] = data
    end
end

-- function GlobalFun:set_base_line_type(ltype)
--     cclog("GlobalFun:set_base_line_type  >>>>", ltype)

--     local pos = 0 
--     for k,v in pairs(Game_conf.YYSType_tab) do
--         if v.line_type == ltype then
--             for i,j in pairs(Game_conf.YYSType_tab) do
--                 j.is_base_line = false
--             end
--             pos = k
--             v.is_base_line = true
            
--             break
--         end
--     end


--     for k = pos, 1, -1 do
--         if k -1 >0 then
--             local tmp = Game_conf.YYSType_tab[k -1]
--             Game_conf.YYSType_tab[k -1] = Game_conf.YYSType_tab[k]
--             Game_conf.YYSType_tab[k] = tmp
--         end
--     end

--     Game_conf.YYSType = GlobalFun:get_line_from_tab()
--     print_r(Game_conf.YYSType_tab)
-- end

-- function GlobalFun:set_line_type_ok_state(is_ok)
--     cclog("GlobalFun:set_line_type_ok_state  >>>>", Game_conf.YYSType, is_ok)

--     for k,v in pairs(Game_conf.YYSType_tab) do
--         if v.line_type == Game_conf.YYSType then
--             v.is_ok = is_ok

--             if Game_conf.YYSType == 4 and v.is_try and v.utils and not is_ok then
--                 v.utils = is_ok
--             end
--             break
--         end
--     end

-- end

-- function GlobalFun:set_line_type_try_state(is_try)
--     cclog("GlobalFun:set_line_type_try_state  >>>>", Game_conf.YYSType, is_try)

--     for k,v in pairs(Game_conf.YYSType_tab) do
--         if v.line_type == Game_conf.YYSType then
--             v.is_try = is_try
--             break
--         end
--     end

-- end

-- function GlobalFun:get_line_from_tab()
--     cclog("GlobalFun:get_line_from_tab  >>>>>>>>>>>>")
--     print_r(Game_conf.YYSType_tab)
--     local ltype = 1
--     for k,v in ipairs(Game_conf.YYSType_tab) do
--         if v.is_ok then
--             ltype = v.line_type
--             cclog("GlobalFun:get_line_from_tab 11111 >>>>>>>>>>>>", ltype)
--             return ltype
--         else 
--             if not v.is_try then
--                 ltype = v.line_type
--                 cclog("GlobalFun:get_line_from_tab 333 >>>>>>>>>>>>", ltype)
--                 return ltype
--             end
--         end
--     end

--     for k,v in pairs(Game_conf.YYSType_tab) do
--         v.is_ok = true
--         v.is_try = false
--     end

--     ltype = Game_conf.YYSType_tab[1].line_type

--     cclog("GlobalFun:get_line_from_tab 222222 >>>>>>>>>>>>", ltype)
--     return ltype
-- end

-- function GlobalFun:reset_lint_tab()
--     Game_conf.YYSType_tab = {
--         {line_type = 4, is_ok = true, is_try = false, is_base_line = true, utils = true},
--         {line_type = 1, is_ok = true, is_try = false, is_base_line = false},
--         {line_type = 2, is_ok = true, is_try = false, is_base_line = false},
--         {line_type = 3, is_ok = true, is_try = false, is_base_line = false},
--     }
--     Game_conf.YYSType = GlobalFun:get_line_from_tab()
-- end

-- function GlobalFun:is_yxd_base_line_state()
--     if Game_conf.YYSType == 4 then
--         local info = GlobalFun:get_line_info_by_type(Game_conf.YYSType)
--         --  utils == false 该基础线路用过并且再次尝试过，不通
--         return info.utils
--     end
-- end

-- function GlobalFun:get_line_info_by_type(line_type)
--     for k,v in pairs(Game_conf.YYSType_tab) do
--         if v.line_type == line_type then
--             return v
--         end
--     end
-- end



-- function GlobalFun:getLine()
--     cclog("GlobalFun:getLine GlobalData.startLine >>>>>>>", GlobalData.startLine)
--     cclog(debug.traceback())

--     -- GlobalData.startLine = GlobalData.startLine + 1
--     -- Game_conf.YYSType = GlobalData.startLine%4 + 1
--     -- if GlobalData.startLine > 20 then
--     --     GlobalData.startLine = Game_conf.YYSType
--     --     return false
--     -- else
--     --     return true
--     -- end

--     Game_conf.YYSType = GlobalFun:get_line_from_tab()

--     if Game_conf.isWX == false then
--         Game_conf.YYSType = 1--免微信没有yxd
--     end
--     cclog("GlobalFun:getLine  Game_conf.YYSType>>>>>>>",Game_conf.YYSType)

--     GlobalData.startLine = GlobalData.startLine + 1
--     if GlobalData.startLine > 20 then
--         GlobalData.startLine = 0
--         return false
--     else
        
--         return true
--     end
       
-- end

-- function GlobalFun:getRoomLine()
--     cclog("GlobalFun:getRoomLine  >>>>>>>>>>>>>")
--     cclog(debug.traceback())
--     -- Game_conf.YYSType = Game_conf.YYSType%4 + 1
--     -- if Game_conf.isWX == false then
--     --     Game_conf.YYSType = 1--免微信没有yxd
--     -- end
--     -- if Game_conf.YYSType == 4 then
--     --     return GlobalFun:getYunIP()
--     -- else
--     --     cclog("GlobalFun:getRoomLine  >>>>>>")
--     --     cclog("GlobalData.lineNet  >>>>>>", GlobalData.lineNet)
--     --     local ip = Util.split(GlobalData.lineNet,";")
--     --     cclog("ip  >>>>>>", ip)
--     --     ip = Util.split(ip[Game_conf.YYSType],":")
--     --     return ip[1]
--     -- end




--     Game_conf.YYSType = GlobalFun:get_line_from_tab()
--     cclog("GlobalFun:getRoomLine Game_conf.YYSType >>>>>>>>>>>>>", Game_conf.YYSType)

--     if Game_conf.isWX == false then
--         Game_conf.YYSType = 1--免微信没有yxd
--     end

--     if Game_conf.YYSType == 4 then
--         return GlobalFun:getYunIP()
--     else
--         local ip = Util.split(GlobalData.lineNet,";")
--         cclog("ip  >>>>>>", ip)
--         ip = Util.split(ip[Game_conf.YYSType],":")
--         return ip[1]
--     end
-- end

function GlobalFun:showError(msg,ok,back,showmode)
    local _tmp = cc.Director:getInstance():getRunningScene():getChildByTag(MSG_TAG)
    if _tmp then
        cc.Director:getInstance():getRunningScene():removeChildByTag(MSG_TAG)
    end
   
    local data = {err = msg,flag = showmode,ok = ok,cancel=back}
    local err = BaseError.new(data)
    err:setTag(MSG_TAG)
    
    cc.Director:getInstance():getRunningScene():addChild(err,100)
end

function GlobalFun:showError2(msg,ok,back,showmode)
    local _tmp = cc.Director:getInstance():getRunningScene():getChildByTag(MSG_TAG)
    if _tmp then
        cc.Director:getInstance():getRunningScene():removeChildByTag(MSG_TAG)
    end
   
    local data = {err = msg,ok = ok,cancel=back, wtype = showmode}
    local err = BaseError2.new(data)
    err:setTag(MSG_TAG)
    
    cc.Director:getInstance():getRunningScene():addChild(err,100)
end

function GlobalFun:showError3(msg,ok,back,showmode)
    local _tmp = cc.Director:getInstance():getRunningScene():getChildByTag(MSG_TAG)
    if _tmp then
        cc.Director:getInstance():getRunningScene():removeChildByTag(MSG_TAG)
    end
   
    local data = {err = msg,ok = ok,cancel=back, wtype = showmode}
    local err = BaseError3.new(data)
    err:setTag(MSG_TAG)

    cc.Director:getInstance():getRunningScene():addChild(err,100)
end

--- interval =  Game_conf.TOAST_LONG   /  Game_conf.TOAST_SHORT
function GlobalFun:showToast(msg , interval)
    local ccx = cc.Director:getInstance():getRunningScene():getChildByTag(TOAST_TAG)
    if ccx ~= nil then
        if ccx:getContext() == msg then
        	return 
        end
        ccx:removeFromParent()
    end
    local toast = BaseToastMSG.new()
    toast:show(msg , interval)
    toast:setTag(TOAST_TAG)
    
    cc.Director:getInstance():getRunningScene():addChild(toast,100)
end

function GlobalFun:showNetWorkConnect(msg)
    local ccx = cc.Director:getInstance():getRunningScene():getChildByTag(NETConnect_TAG)
    if ccx then
        GlobalFun:changeNetWorkInfo(msg)
    else
        ccx = BaseConnectMSG.new()
        ccx:setTag(NETConnect_TAG)
        ccx:setInfoString(msg)
        cc.Director:getInstance():getRunningScene():addChild(ccx,100)
    end
end

function GlobalFun:changeNetWorkInfo(msg)
    local ccx = cc.Director:getInstance():getRunningScene():getChildByTag(NETConnect_TAG)
    if ccx then
        ccx:setInfoString(msg)
    else
        GlobalFun:showNetWorkConnect(msg)
    end
end

function GlobalFun:closeNetWorkConnect()
    local ccx = cc.Director:getInstance():getRunningScene():getChildByTag(NETConnect_TAG)
    if ccx then
        ccx:removeFromParent()
    end
end

function GlobalFun:productMatchNotify()
    if GlobalData.matchTime == nil then
        return
    end
    local t = tonumber(os.date("%w"))
    local h = tonumber(os.date("%H"))
    local m = tonumber(os.date("%M"))
    if t > 0 and t < 6 then
        local data1 = Util.split(GlobalData.matchTime.days[1],"~")
        data1 = Util.split(data1[1],":")
        data1 = tonumber(data1[1])*60 + tonumber(data1[2])

        local data2 = Util.split(GlobalData.matchTime.days[2],"~")
        data2 = Util.split(data2[1],":")
        data2 = tonumber(data2[1])*60 + tonumber(data2[2])
        local tm = data1 - h*60 - m
        if tm > 0 and tm < 6  then
            GlobalData.NotifyContexts[#GlobalData.NotifyContexts + 1] = "麻将比赛将在" .. tm .. "分钟后开始"
        end

        tm = data2 - h*60 - m
        if tm > 0 and tm < 6  then
            GlobalData.NotifyContexts[#GlobalData.NotifyContexts + 1] = "麻将比赛将在" .. tm .. "分钟后开始"
        end
    elseif t == 6 then
        local data = Util.split(GlobalData.matchTime.weeks[1],"~")
        data = Util.split(data[1],":")
        data = tonumber(data[1])*60 + tonumber(data[2])
        local tm = data - h*60 - m
        if tm > 0 and tm < 6  then
            GlobalData.NotifyContexts[#GlobalData.NotifyContexts + 1] = "麻将比赛将在" .. tm .. "分钟后开始"
        end
    elseif t == 0 then
        local data = Util.split(GlobalData.matchTime.weeks[1],"~")
        data = Util.split(data[1],":")
        data = tonumber(data[1])*60 + tonumber(data[2])
        local tm = data - h*60 - m
        if tm > 0 and tm < 6  then
            GlobalData.NotifyContexts[#GlobalData.NotifyContexts + 1] = "麻将比赛将在" .. tm .. "分钟后开始"
        end
    end
end

function GlobalFun:ServerCardToLocalCard(value)
-- value = 100000
    local localvalue = 31
    if value >= 100 and value <= 109 then
        localvalue = value%100+20
    elseif value >= 200 and value <= 209 then
        localvalue = value%100
    elseif value >= 300 and value <= 309 then
        localvalue = value%100+10
    elseif value == 400 then
        localvalue = 31
    else
        cclog("GlobalFun:ServerCardToLocalCard >>>>>", value)
        -- cclog(debug.traceback())
        localvalue = 99
    end
    return localvalue
end

function GlobalFun:localCardToServerCard(value)
    local servervalue = 400
    if value >0 and value < 10 then
        servervalue = (value)%10+200
    elseif value > 10 and value < 20 then
        servervalue = (value)%10 + 300
    elseif value > 20 and value < 30 then
        servervalue = (value)%10 + 100
    else
        servervalue = 400
    end
    return servervalue
end


function GlobalFun:ShowSpeakEmoji(root , wpoint , index)
    if root ~= nil then
        local speak = root:getChildByTag(SPEAK_TAG)
        if speak ~= nil then
            speak:removeFromParent()
        end

        speak = itemSpeak.new()
        speak:setPosition(wpoint)
        speak:setTag(SPEAK_TAG)
        speak:setEmoji(index)
        speak:setScale(1 / root:getScale())  cclog(" Scale .."..root:getScale())
        root:addChild(speak)
        
        local size = speak:getContentSize()
        speak:setContentSize(size.width * speak:getScale(),size.height * speak:getScale())
    end
	
end

function GlobalFun:ShowSpeakString(root , wpoint , index)  
    if root ~= nil then
        local speak = root:getChildByTag(SPEAK_TAG)
        if speak ~= nil then
            speak:removeFromParent()
        end

        speak = itemSpeak.new()
        speak:setPosition(wpoint)
        speak:setTag(SPEAK_TAG)
        speak:setSpeakString(index , root.player.sex)
        speak:setScale(1/ root:getScale())  cclog(" Scale .."..root:getScale())
        root:addChild(speak)
        
        local size = speak:getContentSize()
        speak:setContentSize(size.width * speak:getScale(),size.height * speak:getScale())
    end 
end

function GlobalFun:Change2Yun(loginURL)
    local loginu = loginURL
    local gname = UserDefault:getKeyValue("FRISTGN",nil)
    if gname == nil then
        gname = cpp_getFGroupName()
    end
    local url =  GlobalFun:getYunIP()  
    if url ~= nil and url ~= "" then 
        cclog(" Chaneg ".. gname .. "   " .. url)
        return Util.ChangeToYun(loginu , url) 
    end
    
    return loginu ;
end

function GlobalFun:timeOutCallfunc(time , callfunc)
    local scheduler = cc.Director:getInstance():getScheduler()  
    local schedulerID = nil  
    schedulerID = scheduler:scheduleScriptFunc(function()  
        if callfunc then callfunc() end
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)   
    end,time,false)    
end

--function GlobalFun:DoAgain(func)
--	if func then
--        -- do again
--        cclog("do again")
--        if GlobalData.dotimes < GlobalData.MAXTIMES and GlobalData.doAgainURL ~= nil and GlobalData.doAgainURL ~= "" then
--            GlobalData.dotimes = GlobalData.dotimes +1 
--            GlobalFun:timeOutCallfunc(1 , func)   
--            return true
--        end
--        GlobalData.dotimes = 0 
--        GlobalData.doAgainURL = nil
--        -- do again end
--	end
--	return false
--end

function GlobalFun:getYunIP()
    -- local gname = UserDefault:getKeyValue("FRISTGN",nil)

    -- if gname == nil then
    --     gname = LineMgr:get_yun_group()
    --     -- gname = cpp_getFGroupName()
    --     -- if gname then
    --     --     local tab = Util.split(gname,";")
    --     --     if tab and next(tab) then
    --     --         -- math.randomseed(os.time())
    --     --         -- local i = math.random(1,#tab)
    --     --         local miei = SDKController:getInstance():GET_DEVICE_MIEI()
    --     --         cclog("1111   imei : " , miei)
    --     --         local md5 = ex_fileMgr:loadLua("Manager.md5")
    --     --         if miei and type(miei) == "string" then
    --     --         else
    --     --             miei = "1"
    --     --         end
    --     --         miei = "1"

    --     --         local md5_miei = md5.sumhexa(miei )
    --     --         cclog("md5_miei >>>>>>", md5_miei)
    --     --         local total = 1
    --     --         for i = 1, string.len(md5_miei) do
    --     --             total = string.byte(md5_miei, i) +total
    --     --             cclog("total md5_miei >>>>", i)
    --     --         end
    --     --         local idx = total%3 +1
                
    --     --         cclog("miei md5 >>>",total, idx)
    --     --         gname = tab[idx]
    --     --     end
    --     -- end
    -- end

    -- local n = LineMgr:get_game_cloud_one_name()
    -- if n then gname = n end

    -- -- GlobalFun:showToast(gname , 3)

    -- cclog("GlobalFun:getYunIP >>>> gname",gname )
    -- cclog(debug.traceback())

    -- local tmp_url = nil
    -- for i = 1 , 6 do
    --     tmp_url =  SDKController:getInstance():getYUNbyGroupName(gname)   
    --     if tmp_url ~= nil and tmp_url ~= "" then 
    --         break 
    --     end
    -- end

    -- if tmp_url ~= "" and tmp_url ~= nil then
    --     local data = Util.split(tmp_url,",")
    --     local code = data[1]
    --     local code_data = data[2]
    --     if code * 1 == 1 then 
    --         return code_data
    --     else
    --         -- YUN err  NILvalue 空 ip  ， 1001 等 YUN错误信息
    --         if code_data then
    --             --GlobalFun:showError("YUN ERR : " .. code_data , nil , nil , 1)
    --             GlobalData.code_data = code_data
    --             tmp_url = nil
    --         end    
    --     end    

    -- end

    -- if tmp_url == nil then
    --     tmp_url = "yourui"
    -- end
    -- if tmp_url == "" then
    --     tmp_url = "yajing"
    -- end
    -- return tmp_url
end

-- -- return ip , info 
-- function GlobalFun:getYUNInfo_by_GroupName()
--     local gname = UserDefault:getKeyValue("FRISTGN",nil)
--     if gname == nil then
--         gname = cpp_getFGroupName()
--     end

--     local function errcallback(msg)
--         cclog(" YUN INFO ERR :" , msg)
--         GlobalFun:showToast((" YUN INFO ERR :" ..msg or " NULL" ) , 3)
--     end

--     local result = nil
--     local targetPlatform = cc.Application:getInstance():getTargetPlatform() 
--     if targetPlatform == cc.PLATFORM_OS_ANDROID or targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
--         result = SDKController:getInstance():getYUNInfo_by_GroupName(gname , errcallback) 
--     end 
--     if result ~= nil and result ~= "" then 
--         local data = Util.split(result,",")
--         local code = data[1]
--         local code_data = data[2]
--         if code * 1 == 1 then 
--             local _r_data = Util.split(result,":")
--             local ip = _r_data[1]
--             local ipinfo = _r_data[2]
--             return ip , ipinfo
--         else
--             if code_data then
--                 GlobalData.code_data = code_data
--                 errcallback(code_data)
--                 return nil , nil 
--             end    
--         end     
--     else
--         errcallback(" NO RESULT ")
--     end    
-- end

-- return ip , info 
function GlobalFun:getYUNInfo_by_GroupName()
    -- local gname = UserDefault:getKeyValue("FRISTGN",nil)
    -- if gname == nil then
    --     gname = LineMgr:get_yun_group()
    -- end

    -- local function errcallback(msg)
    --     cclog(" YUN INFO ERR :" , msg)
    --     GlobalFun:showToast((" YUN INFO ERR :" ..msg or " NULL" ) , 3)
    -- end

    -- local result = nil
    -- local targetPlatform = cc.Application:getInstance():getTargetPlatform() 
    -- if targetPlatform == cc.PLATFORM_OS_ANDROID or targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
    --     result = SDKController:getInstance():getYUNInfo_by_GroupName(gname , errcallback) 
    -- end

    -- if result ~= nil and result ~= "" then 
    --     local data = Util.split(result,",")
    --     local code = data[1]
    --     local code_data = data[2]
    --     if code * 1 == 1 then 
    --         local _r_data = Util.split(result,":")
    --         local ip = _r_data[1]
    --         local ipinfo = _r_data[2]
    --         return ip , ipinfo
    --     else
    --         if code_data then
    --             GlobalData.code_data = code_data
    --             errcallback(code_data)
    --             return nil , nil 
    --         end    
    --     end     
    -- else
    --     errcallback(" NO RESULT ")
    -- end    
end

function GlobalFun:PlayVoiceAndShow(root , wpoint , filename )
    cclog("获取文件 "..ex_fileMgr:getWritablePath()..filename);
    if ex_fileMgr:isFileExist(ex_fileMgr:getWritablePath()..filename) then 
        local interval = 5
        local start = string.find(filename,"_",1,true) + 1
        if start ~= nil then
        	interval = string.sub(filename,start, string.find(filename,".",start ,true) - 1)
        	cclog("interval "..interval)
        end
        if root ~= nil then
            local speak = root:getChildByTag(SPEAK_TAG)
            if speak ~= nil then
                speak:removeFromParent()
            end

            speak = itemSpeak.new()
            speak:setPosition(wpoint)
            speak:setTag(SPEAK_TAG)
            speak:speakVioce(interval * 1 , filename)
            root:addChild(speak)
            speak:setScale(1/ root:getScale())  cclog(" Scale .."..root:getScale())
            
            local size = speak:getContentSize()
            speak:setContentSize(size.width * speak:getScale(),size.height * speak:getScale())
        end 
        -- GlobalFun:playAudio(filename)
        platformExportMgr:play_audio(filename ,ex_fileMgr:getWritablePath() ,nil)
--        ex_audioMgr:setEffectsVolume(1); -- 脱离游戏的播声音
--        ex_audioMgr:playEffect(ex_fileMgr:getWritablePath()..filename,false)
    else
        cclog("文件不存在 ".. filename)
    end
end

------------------------------
--截图分享
------------------------------

function GlobalFun:ScreenShot(filename , scale)
	local size = cc.Director:getInstance():getVisibleSize()
    local renderTexture = cc.RenderTexture:create(size.width * scale, size.height * scale , cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, 0x88F0)--cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888
    
    local scene = cc.Director:getInstance():getRunningScene();
    local point = scene:getAnchorPoint()
    --渲染纹理捕捉
    renderTexture:begin()
    
    --缩小屏幕截屏区域
    scene:setScale(scale)
    scene:setAnchorPoint(cc.p(0,0))
    scene:visit()    --绘制场景
    
    renderTexture:endToLua()
    
    local path = ex_fileMgr:getWritablePath()
    local function callback(render , path) 
    	cclog(" **** callback **** ")
    end
    renderTexture:saveToFile(filename ,cc.IMAGE_FORMAT_PNG , true ,callback)
    
    --恢复屏幕尺寸
    scene:setScale(1);  
    scene:setAnchorPoint(point);

    if ex_fileMgr:isFileExist(path.."/"..filename) then
        cclog(" ----- 截图完成 "..path .. "    "..filename)
    end
end


--------***针对wechar 的截图***-------------
function GlobalFun:testScreenShot(filename , scale, _type)
    local size = cc.Director:getInstance():getVisibleSize()
    local renderTexture = cc.RenderTexture:create(size.width * scale, size.height * scale , cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888 , 0x88F0) 
    renderTexture:retain()
    local scene = cc.Director:getInstance():getRunningScene();
    local point = scene:getAnchorPoint()
    --渲染纹理捕捉
    renderTexture:begin()

    --缩小屏幕截屏区域
    scene:setScale(scale)
    scene:setAnchorPoint(cc.p(0,0))
    scene:visit()     --绘制场景

    local function name()
        renderTexture:endToLua()
        
        local path = ex_fileMgr:getWritablePath()
        renderTexture:saveToFile(filename ,cc.IMAGE_FORMAT_PNG )
        --恢复屏幕尺寸
        scene:setScale(1);  
        scene:setAnchorPoint(point);

        if ex_fileMgr:isFileExist(path.."/"..filename) then
            cclog(" ----- 截图完成 "..path .. "/"..filename)
        end
        if scale == 1 then
            ex_audioMgr:playEffect("sound/screenShot.mp3",false)
            GlobalFun:testScreenShot("thumb.png" , 240 / cc.Director:getInstance():getVisibleSize().width ,_type)
        else
            local function wecharShare()
                CCXNotifyCenter:notify("canNotifyShow",true)
                if ex_fileMgr:isFileExist(path.."/thumb.png") and ex_fileMgr:isFileExist(path.."/screenshot.png") then
                    --SDKController:getInstance():shareScreenShot(ex_fileMgr:getWritablePath())
                    if _type == nil then
                        -- SDKController:getInstance():shareScreenShot(ex_fileMgr:getWritablePath())
                        platformExportMgr:weChatShareImage(ex_fileMgr:isFileExist(path.."/screenshot.png") , 0 , nil)
                    -- elseif _type == "QQ" or _type == "ALIPAY" then
                    --     SDKController:getInstance():umengShareLocalImg(_type , path.."/screenshot.png" , path.."/thumb.png")
                    elseif _type == "DD" then 
                        -- yxsdkMgr:sdkImageShare(path.."/screenshot.png" , 0 , nil) 
                        if platformExportMgr:ddClientExits() and platformExportMgr:ddApiSupport() then 
                            platformExportMgr:ddShareImage(ex_fileMgr:isFileExist(path.."/screenshot.png")  , nil)
                        else
                            platformExportMgr:open_APP_WebView("https://tms.dingtalk.com/markets/dingtalk/download?spm=a3140.8736650.2231602.9.75185c8ciA9Mkk&source=2202&lwfrom=2017120202092064209309201")
                        end  
                    end
                else
                    cclog(" --- 截屏文件不全 ")
                    GlobalFun:showToast("截图失败",Game_conf.TOAST_SHORT)
                    OnShareScreenShotComp("0,文件不全")
                end
            end
            
            local ac = cc.DelayTime:create(scale)
            local ac2 = cc.CallFunc:create(wecharShare)  
            scene:runAction(cc.Sequence:create({ ac , ac2}))
        end     
    end

    local scheduler = cc.Director:getInstance():getScheduler()  
    local schedulerID = nil  
    schedulerID = scheduler:scheduleScriptFunc(function()  
        name()
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)   
    end,0,false)    
    
end

function GlobalFun:ShareWeCharScreenShot(type)
    -- local path = ex_fileMgr:getWritablePath()
    -- if ex_fileMgr:isFileExist(path.."/thumb.png") then
    --     os.rename(path.."/thumb.png", path.."/"..os.time()..".png")
    -- end
    -- if ex_fileMgr:isFileExist(path.."/screenshot.png") then
    --     os.rename(path.."/screenshot.png", path.."/"..os.time()..".png")
    -- end
    -- CCXNotifyCenter:notify("canNotifyShow",false)
    -- GlobalFun:testScreenShot("screenshot.png" , 1,type) -- 
    GlobalFun:shareScreenShot("screenshot.jpg" , type)
end

--@截图分享
--@ filename  文件名(.jpg)       string 
--@ callback  回调函数     function
function GlobalFun:shareScreenShot(filename_ , share_platform)
    local filename = os.time() .. filename_
    --.png默认存储了alpha通道，.jpg没有
    filename = string.gsub(filename, ".png" , ".jpg")
         
    dump(" **** filename **** " .. filename)
    local size = cc.Director:getInstance():getVisibleSize()
    local renderTexture = cc.RenderTexture:create(size.width , size.height , cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888 ,0x88F0 )
    
    local scene = cc.Director:getInstance():getRunningScene();
    local point = scene:getAnchorPoint()
    --渲染纹理捕捉
    renderTexture:begin()
    
    --缩小屏幕截屏区域
    scene:setScale(1)
    scene:setAnchorPoint(cc.p(0,0))
    scene:visit()    --绘制场景
    
    renderTexture:endToLua()
    
    local path = ex_fileMgr:getWritablePath()--writePathManager:getAppPlatformWritePath()
    local basepath = platformExportMgr:getBaseWritablePath()
    local expath = Util.removeChar(path , basepath) --string.gsub(path , basepath , "/") or ""

    cclog(">>>>> path :",path)
    cclog(">>>>> basepath :",basepath)
    cclog(">>>>> ",expath..filename)
    renderTexture:saveToFile(expath..filename ,cc.IMAGE_FORMAT_PNG , true)
    
    --恢复屏幕尺寸
    scene:setScale(1);  
    scene:setAnchorPoint(point);

    local full_path = path.."/"..filename
    local function callback_time() 
        dump(" **** callback_time  ////  **** ")
        local isexit = ex_fileMgr:isFileExist(full_path)
        if isexit then
            dump(" ----- 截图完成 :"..full_path)
            if share_platform == "DD" then      
                if platformExportMgr:ddClientExits() and platformExportMgr:ddApiSupport() then 
                    platformExportMgr:ddShareImage(full_path, nil) 
                else
                    platformExportMgr:open_APP_WebView("https://tms.dingtalk.com/markets/dingtalk/download?spm=a3140.8736650.2231602.9.75185c8ciA9Mkk&source=2202&lwfrom=2017120202092064209309201")
                end  
            else
                platformExportMgr:weChatShareImage(full_path , 0 , nil)
            end 
        else
            dump(" ----- 截图 失败")
        end
    end
    GlobalFun:timeOutCallfunc(1,callback_time )
    -- timerMgr:registerTask("screenshot_share",timerMgr.TYPE_CALL_ONE, callback_time , 1)
end

------------------------------
--录音回调  1 开始   0 结束
------------------------------
function createAudio(state)   
    cclog(" 回调 Lua createAudio "..state)
    if state == 1 or state == "1" then
        ex_audioMgr:pauseMusic()
        ex_audioMgr:pauseAllEffects();
        return 
    else
        CCXNotifyCenter:notify("RecodeSoundComp",nil)
    end
    ex_audioMgr:resumeMusic()
    ex_audioMgr:resumeAllEffects()
end 

function createAudioFail()
    cclog(" 回调 Lua createAudioFail ")
    ex_audioMgr:resumeMusic()
    ex_audioMgr:resumeAllEffects()
end

function GlobalFun:startCreateAudio(filename)
    -- local path = ex_fileMgr:getWritablePath() 
    -- local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    -- if targetPlatform == cc.PLATFORM_OS_ANDROID then
    --     local filename = string.sub(filename,1,string.find(filename,".",1,true) - 1)
    --     local args = {"createAudio" , "createAudioFail" ,filename , path}
    --     local packName = "org/cocos2dx/util/newAudioControl" --AudioController
    --     local a,b = LuaJavaBridge.callStaticMethod(packName,"CreateAudio",args,"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z")
    --     if a == true and b ~= nil then
    --         return b
    --     end
    -- elseif targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD or targetPlatform == cc.PLATFORM_OS_MAC then
    --     cpp_createAudio(filename)
    -- end
end

function GlobalFun:endCreteAudio(filename)
    -- local path = ex_fileMgr:getWritablePath()
    -- local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    -- if targetPlatform == cc.PLATFORM_OS_ANDROID then
    --     local filename = string.sub(filename,1,string.find(filename,".",1,true) - 1)
    --     local args = {"createAudio" , "createAudioFail" ,filename , path}
    --     local packName = "org/cocos2dx/util/newAudioControl" --AudioController
    --     local a,b = LuaJavaBridge.callStaticMethod(packName,"CreateAudioEnd",args,"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z")
    --     if a == true and b ~= nil then
    --         return b
    --     end
    -- elseif targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD or targetPlatform == cc.PLATFORM_OS_MAC then
    --     cpp_createAudioEnd(filename)
    --     ex_audioMgr:destroyInstance()
    --     ex_audioMgr:setEffectsVolume(GlobalData.EffectsVolume)
    --     ex_audioMgr:setMusicVolume(GlobalData.MusicVolume)
    --     ex_audioMgr:playMusic("sound/bgm.mp3",true)
    -- end
end

function GlobalFun:playAudio(filename)   
--     local path = ex_fileMgr:getWritablePath()
--     local targetPlatform = cc.Application:getInstance():getTargetPlatform()
--     if targetPlatform == cc.PLATFORM_OS_ANDROID then
--         local args = {filename , path}
--         local packName = "org/cocos2dx/util/newAudioControl" --AudioController
--         local a,b = LuaJavaBridge.callStaticMethod(packName,"PayAudio",args,"(Ljava/lang/String;Ljava/lang/String;)Z")
--         if a == true and b ~= nil then
--             return b
--         end
--     elseif targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD or targetPlatform == cc.PLATFORM_OS_MAC then
        
--         local path = ex_fileMgr:getWritablePath()
--         if ex_fileMgr:isFileExist(path..filename) then
-- --        	ex_audioMgr:playEffect(path..filename,false)
--             cpp_playAudio(filename)
--         	return
--         end
--         cclog("文件不存在")
--     end
end

function GlobalFun:stopPlayAudio()
    -- local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    -- if targetPlatform == cc.PLATFORM_OS_ANDROID then
    --     local args = {filename , path}
    --     local packName = "org/cocos2dx/util/newAudioControl" --AudioController
    --     local a,b = LuaJavaBridge.callStaticMethod(packName,"StopAudio",args,"()Z")
    --     if a == true and b ~= nil then
    --         return b
    --     end
    -- elseif targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
    --     cpp_stopAudio()--关闭录音播放
    -- end
end
--reyun 
function GlobalFun:RrYunLogin(uuid)
    cclog("!!热晕的登录 ",uuid)
    -- local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    -- if targetPlatform == cc.PLATFORM_OS_ANDROID then
    --     local args = { uuid }
    --     local packName = "org/cocos2dx/util/RYTrackControllrt" 
    --     local a,b = LuaJavaBridge.callStaticMethod(packName,"RYLogin",args,"(Ljava/lang/String;)V")
    --     if a == true and b ~= nil then
    --         return b
    --     end
    -- elseif targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD or targetPlatform == cc.PLATFORM_OS_MAC then
    --     cpp_ReYunLogin(uuid)
    -- end
end


function GlobalFun:getImei()
	-- local target = cc.Application:getInstance():getTargetPlatform()
 --    if target == cc.PLATFORM_OS_ANDROID then
 --        local packName = "org/cocos2dx/util/GameUtils"
 --        LuaJavaBridge.callStaticMethod(packName,"getImei",{},"()Z")
	-- end
end

function GlobalFun:dealStr(str)
    if str == nil or str == "" then 
        return str
    end
    -- local pid = cpp_buff_create()
    -- cpp_buffNew_writeString(pid,str)
    -- str = cpp_buffNew_readString(pid)

    -- cpp_buff_delete(pid)
    
    return str
end

function setLuaImei(res)
	if res ~= "" then
        Game_conf.imei = res
	end
end

function GlobalFun:SecToHMS(sec)
    local s = string.format("%d", sec%60)
    local m = string.format("%d",math.floor(sec/60))
    local h = string.format("%d",math.floor(sec/3600))
    return h..":"..m..":"..s
end

-------------------------
--  圆角矩形
--@param width   宽度 ：munber
--@param height  高度 ：munber
--@param radius 圆角半径 ：munber
--@param fillColor 填充的颜色 ：c4b
--@return  
function GlobalFun:createRoundRectNode( width , height , radius , fillColor)
    local drawNode = cc.DrawNode:create()
    local rect = cc.rect( - width / 2,height / 2,width,height) -- 位置 & 尺寸
    local borderWidth = 1  -- 边线宽度
    local color = cc.c4b(255,255,255,255) --线的颜色
    
    -- segments表示圆角的精细度，值越大越精细
    local segments    = 100
    local origin      = cc.p(rect.x, rect.y)
    local destination = cc.p(rect.x + rect.width, rect.y - rect.height)
    local points      = {}

    -- 算出1/4圆
    local coef     = math.pi / 2 / segments
    local vertices = {}

    for i=0, segments do
        local rads = (segments - i) * coef
        local x    = radius * math.sin(rads)
        local y    = radius * math.cos(rads)

        table.insert(vertices, cc.p(x, y))
    end

    local tagCenter      = cc.p(0, 0)
    local minX           = math.min(origin.x, destination.x)
    local maxX           = math.max(origin.x, destination.x)
    local minY           = math.min(origin.y, destination.y)
    local maxY           = math.max(origin.y, destination.y)
    local dwPolygonPtMax = (segments + 1) * 4
    local pPolygonPtArr  = {}

    -- 左上角
    tagCenter.x = minX + radius;
    tagCenter.y = maxY - radius;

    for i=0, segments do
        local x = tagCenter.x - vertices[i + 1].x
        local y = tagCenter.y + vertices[i + 1].y

        table.insert(pPolygonPtArr, cc.p(x, y))
    end

    -- 右上角
    tagCenter.x = maxX - radius;
    tagCenter.y = maxY - radius;

    for i=0, segments do
        local x = tagCenter.x + vertices[#vertices - i].x
        local y = tagCenter.y + vertices[#vertices - i].y

        table.insert(pPolygonPtArr, cc.p(x, y))
    end

    -- 右下角
    tagCenter.x = maxX - radius;
    tagCenter.y = minY + radius;

    for i=0, segments do
        local x = tagCenter.x + vertices[i + 1].x
        local y = tagCenter.y - vertices[i + 1].y

        table.insert(pPolygonPtArr, cc.p(x, y))
    end

    -- 左下角
    tagCenter.x = minX + radius;
    tagCenter.y = minY + radius;

    for i=0, segments do
        local x = tagCenter.x - vertices[#vertices - i].x
        local y = tagCenter.y - vertices[#vertices - i].y

        table.insert(pPolygonPtArr, cc.p(x, y))
    end

    if fillColor == nil then
        fillColor = cc.c4f(0, 0, 0, 0)
    end

    drawNode:drawPolygon(pPolygonPtArr, #pPolygonPtArr, fillColor, borderWidth, color)
    return drawNode 
end

--APP 暂停 HOME 后台状态下收到此回调  （调用 applicationDidEnterBackground 的情况下也会调用 onGame_Paruse ）
function GlobalFun:onGamePause()
    cclog("GlobalFun:onGamePause >>>")
end
function GlobalFun:onGameResume()
    
end    

function GlobalFun:applicationDidEnterBackground()
    cclog("GlobalFun:applicationDidEnterBackground >>>")
end

function GlobalFun:applicationWillEnterForeground()
    cclog("GlobalFun:applicationWillEnterForeground >>>")
    local ccx = cc.Director:getInstance():getRunningScene():getChildByTag(NETConnect_TAG)
    if ccx then
        if ccx:getInfoString() == "请稍后..." then
            ccx:removeFromParent()
        end
    end
    
    if GlobalData.curScene ~= nil and GlobalData.curScene ~= SceneType_None then
        cclog(" YJ SCENE NOT NULL ")
        -- GlobalData.EffectsVolume = UserDefault:getKeyValue("EffectsVolume" , GlobalData.EffectsVolume)
        -- GlobalData.MusicVolume = UserDefault:getKeyValue("MusicVolume" , GlobalData.MusicVolume)

        -- -- ex_audioMgr:destroyInstance()
        -- cclog("sadfasdf >>>", GlobalData.MusicVolume, GlobalData.EffectsVolume)
        ex_audioMgr:setMusicVolume(platformExportMgr:doGameConfMgr_getInfo("voiceValue") *100)
        ex_audioMgr:setEffectsVolume(platformExportMgr:doGameConfMgr_getInfo("voiceEffect") *100)
    end 

    if GlobalData.curScene == SceneType_Login then 
        cclog(" YJ SCENE SceneType_Login ")
        ex_audioMgr:playMusic("sound/bgmlogin.mp3",true)
    elseif GlobalData.curScene == SceneType_Hall then 
        ex_audioMgr:playMusic("sound/bgmlogin.mp3",true)

         --检查是否自动连接到房间
        GlobalFun:checkEnterRoom()
    elseif GlobalData.curScene == SceneType_Club then 
        ex_audioMgr:playMusic("sound/bgmlogin.mp3",true)

        GlobalFun:checkEnterRoom()
    elseif GlobalData.curScene == SceneType_Game or GlobalData.curScene == SceneType_Match then
        ex_audioMgr:playMusic("sound/bgm.mp3",true)
    end

    CCXNotifyCenter:notify("closeWebView")
end

function GlobalFun:checkEnterRoom()
    --检查是否自动连接到房间
    --因为剪切难免有参数bug，为避免报错导致程序无法继续执行，使用这个xpcall方式进行容错处理，如果剪切数据有异样，则无视剪切数据
    xpcall(function ()
        local targetPlatform = cc.Application:getInstance():getTargetPlatform() 
        if targetPlatform == cc.PLATFORM_OS_MAC then
            return
        end
        cclog(" ^^^^^ 检查剪贴板 ")
        local msg = SDKController:getInstance():parse_From_Clipboard()
        cclog(" ^^^^^ 检查剪贴板 msg ",msg)
        if msg ~= nil and msg ~= "" and msg ~= "null" then 
            -- cclog("//// parse_From_Clipboard ", msg , " match :", string.match(msg,"[#]%d%d%d%d%d%d[#]"))
            if  GlobalData.mCopy_msg == nil or GlobalData.mCopy_msg ~= msg then 

                SDKController:getInstance():copy_To_Clipboard("null") -- 操作一次就不要了

                local info = GlobalFun:parseCopyStr(msg)
                local stype = info[1]
                cclog("stype >>>", stype)

                if stype == "俱乐部" then -- 请求进入俱乐部
                    local clubId = info[2]
                    local clubName = info[3]
                    cclog("clubId >>>", clubId)
                    local function cb ()
                        
                        local tmp = ""
                        if clubName then
                            tmp = string.format("是否申请加入俱乐部【%s】(id:%s)", clubName, clubId)
                        else
                            tmp = string.format("是否申请加入俱乐部(id:%s)", clubId)
                        end
                        GlobalFun:showError( tmp, function () 
                                if GlobalData.curScene == SceneType_Hall then 
                                    ex_hallHandler:toJoinClub(clubId)
                                    GlobalFun:showToast("已发送申请", 2)
                                elseif GlobalData.curScene == SceneType_Club then 
                                    ex_clubHandler:requestJoinClub(clubId)
                                    GlobalFun:showToast("已发送申请", 2)
                                end
                                
                            end ,nil ,2)
                        
                    end
                    GlobalFun:timeOutCallfunc(1 , cb) 
                elseif stype == "房间" then
                    local roomId = info[2]
                    cclog("roomId >>>", roomId)
                    local function cb ()
                        
                        GlobalFun:showError(string.format("是否进入房间(id:%s)", roomId) , function () 
                                if GlobalData.curScene == SceneType_Hall then 
                                    ex_hallHandler:gotoRoom(roomId) 
                                elseif GlobalData.curScene == SceneType_Club then 
                                    ex_clubHandler:gotoRoom(roomId)
                                end
                            end ,nil ,2)
                        
                    end
                    GlobalFun:timeOutCallfunc(1 , cb) 
                end
            else
                cclog("//// is mine mCopy_msg ")
            end    
        end    
    end, __G__TRACKBACK__)
end


--截断
function GlobalFun:uiTextCut(uiTextObj)
    local uisize = uiTextObj:getSize()
    cclog("GlobalFun:uiTextCut uisize>>>>", uisize.height, uisize.width)


    local rlabel = uiTextObj:getVirtualRenderer()
    local rlsize = rlabel:getContentSize()
    cclog("GlobalFun:uiTextCut rlsize>>>>", rlsize.height, rlsize.width)

    -- --两个size不一样的，是否能拓展成显示省略号，就看情况了
    -- if rlsize.width > uisize.width then
    --     local tmp = uiTextObj:clone()
    --     -- local ap = uiTextObj:getAnchorPoint()
    --     tmp:setAnchorPoint(0,0)
    --     tmp:setPosition(uisize.width,0)
    --     tmp:setString("...")
    --     uiTextObj:addChild(tmp)
    -- end


    uiTextObj:setTextAreaSize(uisize)

    rlabel:setLineBreakWithoutSpace(true)
    rlabel:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_TOP)
end

function GlobalFun:DownloadFile(url , filename , callfunc)
    if url == nil or filename == nil then
        return 
    end

    if true then
        local xhr = cc.XMLHttpRequest:new()
        xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER
        xhr:open("GET", url)
        local function onReadyStateChanged()
            if xhr.readyState == 4 and xhr.status == 200 then
                local response = xhr.response
                local size     = table.getn(response)
                print("Http Status Code:" .. xhr.statusText .. ",size=" .. size)
                local file = io.open(ex_fileMgr:getWritablePath().."/"..filename,"wb")
                for i = 1, size do
                    file:write(string.char(response[i]))
                end
                file:close() 
                if callfunc then 
                    callfunc() 
                end 
            else
                release_print("xhr.readyState is:" .. xhr.readyState .. ",xhr.status is: " .. xhr.status)
            end
            xhr:unregisterScriptHandler()
        end
        xhr:registerScriptHandler(onReadyStateChanged)
        xhr:send()
    end
end


--【string】##stype&param1&param2&...##
-- data = {msg, stype, {p1,p2,p3}}
function GlobalFun:makeCopyStr(data)
    -- local str = string.format("【%s】\n复制这条信息打开�筑志红中麻将�##%s", data.msg, data.stype)
    local str = string.format("【%s】\n复制这条信息打开>>>筑志红中麻将<<< ##%s", data.msg, data.stype)
    for k,v in ipairs(data.params) do
        str = string.format("%s&%s", str, v)
    end 
    str = str .. "##"

    cclog("GlobalFun:makeCopyStr >>>", str)
    return str
end

function GlobalFun:parseCopyStr(str)
    local tab = {}
    local data_str = string.match(str, "[#][#].*[#][#]")
    cclog(data_str)
    local lua_str = string.gsub(data_str, "#", "")
    cclog(lua_str)

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

    local tab = split(lua_str, "&")
    print_r(tab)

    return tab
end

function GlobalFun:setCardSum(num)
    if num ~= nil then
        self.cartSum = num
    else
        self.cartSum = 112
    end
    cclog("curCardSum:"..self.cartSum)
end

function GlobalFun:addCardSum(num)
    if num ~= nil then
        self.cartSum = self.cartSum + num
        cclog("curCardSum:"..self.cartSum)
    end
end

function GlobalFun:getCardSum()
    return self.cartSum
end

function GlobalFun:strLenForTb(tb)
    local len = 0
    if tb == nil then return len end
    for i, v in pairs(tb) do
        len = len + 1
    end
    return len
end

function GlobalFun:copyFromTable(_t1, _t2)
    local function func(t1, t2)
        for key, var in pairs(t1) do
            if type(var) == "table" then
                t2[key] = {}
                func(var, t2[key])
            else    
                t2[key] = var
            end
        end
    end
    if _t2 == nil then _t2 = {} end
    func(_t1, _t2)
    return _t2
end

--子控件居中父控件
function GlobalFun:betweenTwoParties(parent, child)
    child:setAnchorPoint(cc.p(0.5,0.5))
    local parentSize = parent:getContentSize()
    child:setPosition(cc.p(parentSize.width / 2, parentSize.height / 2))
end

--新增头像居中父控件and修正边长在父控件内
function GlobalFun:modifyAddNewIcon(parent, child, offsetSWidth, offsetSHeight, removeObjName)
    if offsetSWidth == nil then offsetSWidth = 0 end
    if offsetSHeight == nil then offsetSHeight = 0 end
    GlobalFun:betweenTwoParties(parent, child)
    local parentSize = parent:getContentSize()
    local parentScaleX = parent:getScaleX()
    local parentScaleY = parent:getScaleY()
    local childSize = child:getContentSize()

    child:setScale((parentSize.width - offsetSWidth) / childSize.width * parentScaleX, 
        (parentSize.height - offsetSHeight) / childSize.height * parentScaleY)

    if removeObjName then parent:removeChildByName(removeObjName) end
end

function ExitApp()
    cclog("******** KEY BACK *********")
    CCXNotifyCenter:notify("DoExitApp",nil)
end


