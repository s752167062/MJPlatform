
--@公共函数管理类
--@Author   sunfan
--@date     2017/04/27
local ComFunMgr = class("ComFunMgr")
local dkj = require("app.helper.dkjson")
    
function ComFunMgr:ctor(params)

end

-- local BaseError = require("app.Common.CUIMsgError")
-- local BaseError2 = require("app.Common.CUITiShi")
-- local BaseError3 = require("app.Common.CUITiShi_A")
-- local BaseConnectMSG = require("app.Common.CUIConnectMSG")
-- local BaseToastMSG = require("app.Common.CUIToastMsg")
local itemSpeak = require("app.views.chat.Item_Speak")


local SPEAK_TAG = 1002
local MSG_TAG = 1000
local NETConnect_TAG = 1001
local SPEAK_TAG = 1002
local localTOAST_TAG = 1003
local VOTEUI_TAG = 1004

-- 字符串切分成数组
function ComFunMgr:split(s, delim)
    if type(delim) ~= "string" or string.len(delim) <= 0 then
        return
    end

    local start = 1
    local t = {}
    while true do
        local pos = string.find (s, delim, start, true) -- plain find
        if not pos then
            break
        end

        table.insert (t, string.sub (s, start, pos - 1))
        start = pos + string.len (delim)
    end
    table.insert (t, string.sub (s, start))

    return t
end

-- 2017-12-27添加 字符串切分成数组, 和上面不同的是，这个当s == ""时返回一个{}, 上面返回的是 { [1]="",}
function ComFunMgr:splitToArray(s, delim)
    local t = {}
    if type(delim) ~= "string" or s == "" or string.len(delim) <= 0 then
        return t
    end

    local start = 1
    while true do
        local pos = string.find (s, delim, start, true) -- plain find
        if not pos then
            break
        end

        table.insert (t, string.sub (s, start, pos - 1))
        start = pos + string.len (delim)
    end
    table.insert (t, string.sub (s, start))

    return t
end


-- 字符串去除指定字符
function ComFunMgr:removeChar(s , char)
	if type(char) ~= "string" or string.len(char) <= 0  then
		return 
	end
	
	local start = 1 
	local newStr = ""
	while true do
		local pos = string.find(s,char,start,true) 
		if not pos then
			break
		end
		
        newStr = newStr .. string.sub(s, start, pos - 1)
        start = pos + string.len(char)
	end
    newStr = newStr .. string.sub (s, start)
    return newStr
end

function ComFunMgr:getCenter(s , startstr , endstr)
	if type(s) ~= "string" or string.len(s) <= 0  then
		return nil
	end
	
    local startp = string.find(s,startstr,1,true) + string.len(startstr)
    local endp   = string.find(s,endstr  ,1,true)
    if startp ~= nil and endp ~= nil then
        return string.sub(s,startp ,endp - 1)
    end
    return nil
end

function ComFunMgr:sort(list, key, desc)
    if list == nil or #list == 0 then
        dump("************** sort list nil")
        return list
    end

    local function sortFunc(a, b)
        dump("************** "..key .."   " .. a[key].."  "..type(a[key]))
        dump("************** "..key .."   " .. b[key].."  "..type(b[key]))
        if desc == true then
            return a[key] > b[key]
        end
        return a[key] < b[key]
    end

    table.sort(list,sortFunc)
    return list
end

-------------------------------------
--截取指定的位置 i ~ j
--@return 
--      s : 返回的string
--      offset : 返回偏移的 长度  (-  j  +)
function ComFunMgr:CATString(str , i , j)
    if str == nil or str == "" then
        return 
    end

    local s = ""
    local length = #str
    local offset = 0    
    for index = i, j  do
        local curByte = string.byte(str, index)
        local byteCount = 0;
        if curByte>0 and curByte<=127 then
            byteCount = 1
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
        elseif curByte>=224 and curByte<239 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        end

        local char = ""
        if byteCount > 0 then
            char = string.sub(str, index , index + byteCount - 1)
            index = index + byteCount - 1
        end
        s = s .. char
        offset = j - index
    end

    return s , offset
end

function ComFunMgr:CATStringWithoutEmoji(str , i , j)
    if str == nil or str == "" then
        return 
    end

    local s = ""
    local length = #str
    local offset = 0    
    for index = i, j  do
        local curByte = string.byte(str, index)
        local byteCount = 0;
        if curByte>0 and curByte<=127 then
            byteCount = 1
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
        elseif curByte>=224 and curByte<239 then
            byteCount = 3
--        elseif curByte>=240 and curByte<=247 then
--            byteCount = 4
        end

        local char = ""
        if byteCount > 0 then
            char = string.sub(str, index , index + byteCount - 1)
            index = index + byteCount - 1
        end
        s = s .. char
        offset = j - index
    end

    return s , offset
end

function ComFunMgr:to_utf8(a)  
    local n, r, u = tonumber(a)  
    if n<0x80 then                        -- 1 byte  
        return char(n)  
    elseif n<0x800 then                   -- 2 byte  
        u, n = tail(n, 1)  
        return char(n+0xc0) .. u  
    elseif n<0x10000 then                 -- 3 byte  
        u, n = tail(n, 2)  
        return char(n+0xe0) .. u  
    elseif n<0x200000 then                -- 4 byte  
        u, n = tail(n, 3)  
        return char(n+0xf0) .. u  
    elseif n<0x4000000 then               -- 5 byte  
        u, n = tail(n, 4)  
        return char(n+0xf8) .. u  
    else                                  -- 6 byte  
        u, n = tail(n, 5)  
        return char(n+0xfc) .. u  
    end  
end

function ComFunMgr:getMaxKey(t)
    local key = 0
    for k,v in pairs(t) do
        if type(k) == "number" then
            if key < k then
                key = k
            end
        end
    end
    return key
end
function ComFunMgr:getMinKey(t)
    local key = nil
    for k,v in pairs(t) do
        if type(k) == "number" then
            if key == nil then
                key = k
            end
            if key > k then
                key = k
            end
        end
    end
    return key
end

function ComFunMgr:pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do 
        table.insert(a, n) 
    end
    table.sort(a, f)
    local i = 0                 -- iterator variable
    local iter = function ()    -- iterator function
       i = i + 1
       if a[i] == nil then return nil
       else return a[i], t[a[i]]
       end
    end
    return iter
end

function ComFunMgr:frameIsExist(image_path)
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(image_path)
    if frame then
        return true
    else
        print("资源不存在或者未加载>>>>>>>>>>>>>>>>>",image_path)
        return false
    end
end

function ComFunMgr:sceneShake()
    local scene = cc.Director:getInstance():getRunningScene()
    if scene then
        local ac0 = cc.MoveTo:create(0.03,cc.p(10,0))
        local ac1 = cc.MoveTo:create(0.03,cc.p(0,10))
        local ac2 = cc.MoveTo:create(0.03,cc.p(-10,0))
        local ac3 = cc.MoveTo:create(0.03,cc.p(0,-10))
        local ac4 = cc.MoveTo:create(0.03,cc.p(0,0))
        
        local ac00 = cc.MoveTo:create(0.03,cc.p(10,0))
        local ac01 = cc.MoveTo:create(0.03,cc.p(0,10))
        local ac02 = cc.MoveTo:create(0.03,cc.p(-10,0))
        local ac03 = cc.MoveTo:create(0.03,cc.p(0,-10))
        local ac04 = cc.MoveTo:create(0.03,cc.p(0,0))
        
        local ac10 = cc.MoveTo:create(0.03,cc.p(10,0))
        local ac11 = cc.MoveTo:create(0.03,cc.p(0,10))
        local ac12 = cc.MoveTo:create(0.03,cc.p(-10,0))
        local ac13 = cc.MoveTo:create(0.03,cc.p(0,-10))
        local ac14 = cc.MoveTo:create(0.03,cc.p(0,0))
        
        local act1 = cc.Sequence:create({ ac0 , ac1 ,ac2 ,ac3 ,ac4 ,ac00 , ac01 , ac02 ,ac03 , ac04 , ac10 , ac11 , ac12 , ac13, ac14 })  
        scene:runAction(act1)
    end
end

----------------------------------
--  圆角矩形
--@param width   宽度 ：munber
--@param height  高度 ：munber
--@param radius  圆角半径 ：munber
--@param fillColor 填充的颜色 ：cc.c4b
--@return  
function ComFunMgr:createRoundRectNode( width , height , radius , fillColor)
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

function ComFunMgr:iconMakeRound( img, width , height , radius , offset)
    local sign = self:createRoundRectNode( width - offset, height - offset , radius , cc.c4b(145,145,145,145))
    sign:setPosition(cc.p(width /2 , height /2 ))
    local clip = cc.ClippingNode:create(sign);
    clip:addChild(img)
    
    return clip
end

function ComFunMgr:timeOutCallfunc(time , callfunc)
    local scheduler = cc.Director:getInstance():getScheduler()  
    local schedulerID = nil  
    schedulerID = scheduler:scheduleScriptFunc(function()  
        if callfunc then callfunc() end
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)   
    end,time,false, "platform")    
end

--间隔 interval 重复执行 times 次 callfunc ， 当 callfunc return true 结束循环
function ComFunMgr:IntervalTimesCall(times , interval , callfunc)
    if times > 0 and interval > 0 and callfunc ~= nil then
        local scheduler = cc.Director:getInstance():getScheduler()  
        local schedulerID = nil  
        local mtimes = 0
        schedulerID = scheduler:scheduleScriptFunc(function(t)  
            mtimes = mtimes + 1 
            if callfunc() or mtimes >= times then 
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)   
            end  
            
        end,interval,false, "platform") 
    end
    
end

--[[
    1-9 万
    11-19 筒
    21-29 条
    40，41，42，43，44，45，46 东、南、西、北、中、发、白
]]
function ComFunMgr:ServerCardToLocalCard(value)
    local localvalue = 0
    if value >= 101 and value <= 109 then
        localvalue = value%100+20
    elseif value >= 201 and value <= 209 then
        localvalue = value%100
    elseif value >= 301 and value <= 309 then
        localvalue = value%100+10
    elseif value == 400 then
        localvalue = 31
    elseif value > 400 and value <= 500 then
        localvalue = value/10-1
    end
    return localvalue
end

function ComFunMgr:localCardToServerCard(value)
    local servervalue = 0
    if value >0 and value < 10 then
        servervalue = (value)%10+200
    elseif value > 10 and value < 20 then
        servervalue = (value)%10 + 300
    elseif value > 20 and value < 30 then
        servervalue = (value)%10 + 100
    elseif value == 31 then
        servervalue = 400
    else
        servervalue = value*10+10
    end
    return servervalue
end

function ComFunMgr:NNShowSpeakEmoji(root , wpoint , index,sex,dir, needDownPos)
    if root ~= nil then
        local speak = root:getChildByTag(SPEAK_TAG)
        if speak ~= nil then
            speak:removeFromParent()
        end

        speak = itemSpeak.new(dir)
        speak:setPosition(wpoint)
        speak:setTag(SPEAK_TAG)
        speak:setEmoji(index)
        speak:setFlippe(needDownPos)
        speak:setScale(1 / root:getScale())  
        dump(" Scale .."..root:getScale())
        root:addChild(speak)
        
        local size = speak:getContentSize()
        speak:setContentSize(size.width * speak:getScale(),size.height * speak:getScale())
    end
end

function ComFunMgr:ShowSpeakEmoji(root , wpoint , index,sex,dir, pos)
    if root ~= nil then
        local speak = root:getChildByTag(SPEAK_TAG)
        if speak ~= nil then
            speak:removeFromParent()
        end

        speak = itemSpeak.new(dir, pos)
        speak:setPosition(wpoint)
        speak:setTag(SPEAK_TAG)
        speak:setEmoji(index)
        speak:setScale(1 / root:getScale())  
        dump(" Scale .."..root:getScale())
        root:addChild(speak)
        
        local size = speak:getContentSize()
        speak:setContentSize(size.width * speak:getScale(),size.height * speak:getScale())
    end
end

function ComFunMgr:ShowSpeakString(root , wpoint , index, sex ,dir, type, pos)  
    if root ~= nil then
        local speak = root:getChildByTag(SPEAK_TAG)
        if speak ~= nil then
            speak:removeFromParent()
        end

        speak = itemSpeak.new(dir, pos)
        speak:setPosition(wpoint)
        speak:setTag(SPEAK_TAG)
        speak:setSpeakString(index,sex,type)
        speak:setScale(1/ root:getScale())  dump(" Scale .."..root:getScale())
        root:addChild(speak)
        
        local size = speak:getContentSize()
        speak:setContentSize(size.width * speak:getScale(),size.height * speak:getScale())
    end 
end


--2017/11/22牛牛显示头像出现的字体
function ComFunMgr:NNShowSpeakString(root , wpoint , index , sex , dir, needDownPos)  
    if root ~= nil then
        local speak = root:getChildByTag(SPEAK_TAG)
        if speak ~= nil then
            speak:removeFromParent()
        end

        speak = itemSpeak.new(dir)
        speak:setPosition(wpoint)
        speak:setTag(SPEAK_TAG)
        speak:setSpeakString(index , sex ,3) --这里要留意的就是和之前的不一样命名2017/11/13
        speak:setFlippe(needDownPos)
        speak:setScale(1/ root:getScale())  dump(" Scale .."..root:getScale())
        root:addChild(speak)
        
        local size = speak:getContentSize()
        speak:setContentSize(size.width * speak:getScale(),size.height * speak:getScale())
    end 
end

--[[
    {
        playing  = false,
        interval = ,
        minterval= ,
        _root
        _wpoint
        _filename
        _sex
        _dir
        _pos
    }   
]]
ComFunMgr.voiceBuff={}
function ComFunMgr:PlayVoiceAndShow(_root ,_wpoint ,_filename ,_sex ,_dir, _pos)
    local root = _root
    local wpoint = _wpoint
    local filename = _filename
    local sex = _sex
    local dir = _dir
    local pos = _pos

    dump("获取文件 ShowPlay"..writePathManager:getAppPlatformWritePath()..filename);
    local path = writePathManager:getAppPlatformWritePath()..filename 
    if cc.FileUtils:getInstance():isFileExist(path) and filename ~= "" then 
        release_print("======== PlayVoiceAndShow args : ", tostring(root) ,filename ,sex ,dir , pos )
        print_r(wpoint)
        local interval = 5
        local start = string.find(filename,"_",1,true) + 1
        if start ~= nil then
            interval = string.sub(filename,start, string.find(filename,".",start ,true) - 1)
            dump("interval "..interval)
        end
        --添加到缓冲列表
        local item = { playing = false ,interval = tonumber(interval or 0) or 0 ,_root = root ,_wpoint = wpoint ,_filename = filename ,_sex = sex ,_dir = dir ,_pos = pos }
        --check same 
        local same = false
        for k,value in pairs(ComFunMgr.voiceBuff) do
            if value then 
                if value._filename == item._filename then 
                    same = true
                    break;
                end    
            end    
        end
        if same == false then 
            table.insert(ComFunMgr.voiceBuff , item )
        else
            dump("---- have same voicefile")
        end    
    else
        dump("文件不存在 ".. filename)
    end

    --启动任务顺序播放语音
    if timerMgr:isTaskExit("playVioce_List") == false then 
        local function callback_play()
            local frist_play = ComFunMgr.voiceBuff[1]
            if frist_play ~= nil then 
                --有内容
                if frist_play.playing == true then 
                    if frist_play.minterval >= frist_play.interval then 
                        --第一个播放结束了
                        table.remove(ComFunMgr.voiceBuff , 1) -- 移除第一个，后面的补上
                    else    
                        frist_play.minterval = frist_play.minterval + 0.5
                    end
                else
                    --没有正在播放的开始播放
                    local root     = frist_play._root 
                    local wpoint   = frist_play._wpoint
                    local filename = frist_play._filename
                    local sex      = frist_play._sex
                    local dir      = frist_play._dir
                    local pos      = frist_play._pos
                    local interval = frist_play.interval
                    --显示与播放
                    if root ~= nil then
                        local speak = root:getChildByTag(SPEAK_TAG)
                        if speak ~= nil then
                            speak:removeFromParent()
                        end

                        speak = itemSpeak.new(dir, pos)
                        speak:setPosition(wpoint)
                        speak:setTag(SPEAK_TAG)
                        speak:speakVioce(interval * 1 , filename)
                        root:addChild(speak)
                        speak:setScale(1/ root:getScale()) --cclog(" Scale .."..root:getScale())
                        
                        local size = speak:getContentSize()
                        speak:setContentSize(size.width * speak:getScale(),size.height * speak:getScale())
                    else
                        dump(" ===== voice root nil")
                    end 
                    platformMgr:play_audio(filename, writePathManager:getAppPlatformWritePath() ,nil)

                    --修改为播放状态
                    frist_play.playing   = true
                    frist_play.minterval = 0

                    if cc.SimpleAudioEngine:getInstance():isMusicPlaying() == true then 
                        cc.SimpleAudioEngine:getInstance():pauseMusic()
                        cc.SimpleAudioEngine:getInstance():pauseAllEffects()
                    end    

                    print_r(ComFunMgr.voiceBuff)
                end    
            else
                if cc.SimpleAudioEngine:getInstance():isMusicPlaying() == false then 
                    --没有可以播放的录音 恢复声音
                    release_print("#  ===== 恢复声音 ")
                    cc.SimpleAudioEngine:getInstance():resumeMusic()
                    cc.SimpleAudioEngine:getInstance():resumeAllEffects()
                end    
            end    
        end
        timerMgr:registerTask("playVioce_List" , timerMgr.TYPE_CALL_RE , callback_play , 0.5)
    end    
end

function ComFunMgr:showError(msg,ok,back,showmode)
    local _tmp = cc.Director:getInstance():getRunningScene():getChildByTag(MSG_TAG)
    if _tmp then
        cc.Director:getInstance():getRunningScene():removeChildByTag(MSG_TAG)
    end
   
    local data = {err = msg,flag = showmode,ok = ok,cancel=back}
    local err = BaseError.new(data)
    err:setTag(MSG_TAG)
    
    cc.Director:getInstance():getRunningScene():addChild(err,100)
end

function ComFunMgr:showError2(msg,ok,back,showmode)
    local _tmp = cc.Director:getInstance():getRunningScene():getChildByTag(MSG_TAG)
    if _tmp then
        cc.Director:getInstance():getRunningScene():removeChildByTag(MSG_TAG)
    end
   
    local data = {err = msg,ok = ok,cancel=back, wtype = showmode}
    local err = BaseError2.new(data)
    err:setTag(MSG_TAG)
    
    cc.Director:getInstance():getRunningScene():addChild(err,100)
end

function ComFunMgr:showError3(msg,ok,back,showmode)
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
function ComFunMgr:showToast(msg , interval)
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

function ComFunMgr:showNetWorkConnect(msg)
    local ccx = cc.Director:getInstance():getRunningScene():getChildByTag(NETConnect_TAG)
    if ccx then
        ComFunMgr:changeNetWorkInfo(msg)
    else
        ccx = BaseConnectMSG.new()
        ccx:setTag(NETConnect_TAG)
        ccx:setInfoString(msg)
        cc.Director:getInstance():getRunningScene():addChild(ccx,100)
    end
end

function ComFunMgr:changeNetWorkInfo(msg)
    local ccx = cc.Director:getInstance():getRunningScene():getChildByTag(NETConnect_TAG)
    if ccx then
        ccx:setInfoString(msg)
    else
        ComFunMgr:showNetWorkConnect(msg)
    end
end

function ComFunMgr:closeNetWorkConnect()
    local ccx = cc.Director:getInstance():getRunningScene():getChildByTag(NETConnect_TAG)
    if ccx then
        ccx:removeFromParent()
    end
end


function ComFunMgr:replayAudio()
    print("-重启音效器 ")
    print("comFunMgr:replayAudio")
    audioMgr:reInstanceAudioObj()--重启音效器
    local state = gameState:getState()
    if state == GAMESTATE.STATE_LOGO or state == GAMESTATE.STATE_LOGIN or state == GAMESTATE.STATE_UPDATE then 
        audioMgr:playMusic("loginMusic.mp3",true)
    elseif state == GAMESTATE.STATE_COMMHALL then
        audioMgr:playMusic("hallMusic.mp3",true)
    elseif state == GAMESTATE.STATE_ROOM then
        -- local game_code = RuleMgr:get_cur_rule_data("SERVER_MODEL")
        -- local category = RuleMgr:get_room_category_by_sever_model(game_code)
        -- local cato
        -- if game_code == "pdk" or game_code == "ddz" or game_code == "sdh" then
        --     local music_file_name = game_code.."_room.mp3"
        --     audioMgr:playMusic(music_file_name,true)
        -- elseif category == "phz" then
        --     audioMgr:playMusic("paohuzi/Music/bgFight.mp3",true)
        -- else
        --     local music_file_name = "mj_room.mp3"
        --     audioMgr:playMusic(music_file_name,true)
        -- end
    elseif state == GAMESTATE.STATE_CLUB then --俱乐部状态
        audioMgr:playMusic("hallMusic.mp3",true)
    else
        print(" else 状态",state)
    end 
end


--@截图分享
--@ filename  文件名(.jpg)       string 
--@ callback  回调函数     function
function ComFunMgr:shareScreenShot(filename_ , share_platform)
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
    
    local path = writePathManager:getAppPlatformWritePath()
    renderTexture:saveToFile(filename ,cc.IMAGE_FORMAT_PNG , true)
    
    --恢复屏幕尺寸
    scene:setScale(1);  
    scene:setAnchorPoint(point);

    local full_path = path.."/"..filename
    local function callback_time() 
        dump(" **** callback_time  ////  **** ")
        local isexit = cc.FileUtils:getInstance():isFileExist(full_path)
        if isexit then
            dump(" ----- 截图完成 :"..full_path)
            if share_platform == SHARE_PLATFORM_TYPE.DD then 
                SDKMgr:ddsdkImageShare(full_path, function( ... )
                        release_print("---- call dd sdk image share" , ...)
                    end) 
            else
                SDKMgr:sdkImageShare(full_path , WX_SHARE_TYPE.FRIENDS , nil)
            end 
        else
            dump(" ----- 截图 失败")
        end
    end
    timerMgr:registerTask("screenshot_share",timerMgr.TYPE_CALL_ONE, callback_time , 1)
end

--下载声音
function ComFunMgr:downloadVoice(voiceName ,callfunc)
    self:downloadVoiceRequest(voiceName ,callfunc)
end

function ComFunMgr:downloadVoiceRequest(voiceName ,callfunc)
    dump("开始下载文件 " .."http://download.hongzhongmajiang.com/voice/" .. voiceName)
    if true then
        local xhr = cc.XMLHttpRequest:new()
        xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER
        xhr:open("GET", "http://download.hongzhongmajiang.com/voice/" .. voiceName)
        local function onReadyStateChanged()
            if xhr.readyState == 4 and xhr.status == 200 then
                local response   = xhr.response
                local size     = table.getn(response)
                release_print("Http Status Code:" .. xhr.statusText .. ",size=" .. size)
                local file = io.open(writePathManager:getAppPlatformWritePath() .. voiceName,"wb")
                for i = 1, size do
                    file:write(string.char(response[i]))
                end
                file:close() 
                if callfunc then --开始播放语音并显示播放语音图标!!!!!!!!
                    callfunc() 
--                    self:addSpeakVoiceToList(voiceName, callfunc)
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
--@按钮点击是变大的处理
function ComFunMgr:setButtonPressState(btn)
    btn:onTouch(function(event)
            if event.name == "began" then
                btn:setScale(1.1)
            elseif event.name == "ended" or event.name == "cancelled" then
                btn:setScale(1)
            end
        end)
end

--@下载
--url@下载地址
--filename@下载后储存文件名
--callfunc@下载成功回调
function ComFunMgr:DownloadFile(url , filename , callfunc)
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
                local file = io.open(writePathManager:getAppPlatformWritePath().."/"..filename,"wb")
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

function ComFunMgr:DownloadFile2(url , filePath , callfunc)
    if url == nil or filePath == nil then
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
                local file = io.open(filePath,"wb")
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

--@分享
function ComFunMgr:Share(info)
    -- local share_view = viewMgr:show("share_view") -- 抛弃这种使用方式
    -- share_view:setShareInfo(info)


    local title = ""
    local msg   = "" 
    if info.share_scene == SHARE_SCENE.REQUEST then--邀请好友分享
        title = info.title or ""
        msg = info.msg or ""
        if title == "" and msg == "" then
            return
        end
        -- local area, block   = RuleMgr:get_cur_rule_name()
        -- local game_code     = RuleMgr:get_cur_rule_data("SERVER_MODEL")
        -- local category      = RuleMgr:get_room_category_by_sever_model(game_code)
        -- local roomId        = RuleMgr:getCurModel():getRoomID()
        -- local round         = RuleMgr:get_cur_rule_data("ROUND")
        -- local num           = RuleMgr:get_cur_rule_data("PLAYER_COUNT")

        -- title = msgMgr:getText("SHARE_ROOM_ID", roomId)
        -- if area == "斗牛" then
        --     if block == "斗公牛" then
        --         local lunzhang = RuleMgr:get_cur_rule_data("LUNZHUANG")
        --         msg = msgMgr:getText("SHARE_DOUGONGNIU", lunzhang, num, "牛牛", block)
        --     elseif block == "经典牛牛" then
        --         local gametype = RuleMgr:get_cur_rule_data("GAME_TYPE")
        --         if gametype < 0 or gametype > 6 then gametype = 1 end
        --         local typelist = {"轮流坐庄", "牛牛上庄", "自由抢庄", "明牌抢庄", "固定庄家", "通比牛牛"}
        --         msg = msgMgr:getText("SHARE_DOUNIU", round, num, block, typelist[gametype])
        --     else
        --         msg = msgMgr:getText("SHARE_DOUNIU", round, num, "牛牛", block)
        --     end
        -- else
        --     if category == "majiang" then
        --         local roomRule = RuleMgr:get_cur_room_rule_data()
        --         local _, ruleTxt = RuleMgr:getRoomInfoDesc(roomRule, "share")
        --         msg = "我在[湖南麻将]开了"..block..","..ruleTxt.."的房间，快来玩吧！"
        --     else
        --         msg = msgMgr:getText("SHARE_MSG", round, num, block)
        --     end
        -- end
    
    elseif info.share_scene == SHARE_SCENE.HALL then--大厅分享
        local playerName = gameConfMgr:getInfo("playerName")
        
        title = msgMgr:getMsg("SHARE_TITLE_DEFAULT")
        msg = string.format(msgMgr:getMsg("SHARE_DESC_DEFAULT") , gameConfMgr:getInfo("playerName")) 
    elseif info.share_scene == SHARE_SCENE.SUMMARY then--结算分享
        -- 截图分享 请使用 ComFunMgr:shareScreenShot(filename,callback) 

    elseif info.share_scene == SHARE_SCENE.NORMAL then --分享自定义文字
        title = info.title or ""
        msg   = info.msg   or ""
        if title == "" and msg == "" then
            return
        end
    else
        title = info.title or ""
        msg   = info.msg   or ""
        if title == "" and msg == "" then
            return
        end
    end

    print("///// share title =",title)
    print("///// share msg =",msg)

    local url = gameConfMgr:getInfo("shareUrl")
    if string.find(url,"http",0,true) == nil then 
        url = "http://" .. url
    end
    print("///// share url =",url)
    SDKMgr:sdkUrlShare( title, msg, url, WX_SHARE_TYPE.FRIENDS)
end

-- 金币数字长度控制
function ComFunMgr:num_length_ctrl(num)
    -- body
    print("num_length_ctrl num = ", num)
    local numStr = ""..num
    local length = string.len(numStr) 
    --print("coin len = "..length..", num = "..num)
    if length >= 5 and length < 9 then -- 千万 ～ 万
        local part1 =  string.sub(numStr, 1, length - 4)
        local part2 = string.sub(numStr, length - 3, length - 2)--精确到2位
        if tonumber(part2) <= 0 then
            numStr = part1.."万"
        else
            numStr = part1.."."..part2.."万"
        end  
    elseif length >= 9 then -- 千亿 ～ 亿
        local part1 =  string.sub(numStr, 1, length - 8)
        local part2 = string.sub(numStr, length - 7, length - 6)--精确到2位
        if tonumber(part2) <= 0 then
            numStr = part1 .. "亿"
        else
            numStr = part1 .. "." .. part2 .. "亿"
        end
    end
    print("num_length_ctrl str = ", numStr)
    return numStr
end

--表转为json字符串
function ComFunMgr:tabToStr(tab)
    -- body
    if tab then
        local json_str = dkj.encode(tab)
        return json_str
    end
    return ""
end

--json字符串转为表
function ComFunMgr:strToTab(string)
    -- body
    local tab = dkj.decode(string)
    return tab
end

function ComFunMgr:HexToRGB(color)
    local r,g,b = 255,255,255
    local color = string.gsub(color,"#","")
    r = "0x"..string.sub(color,1,2)
    g = "0x"..string.sub(color,3,4)
    b = "0x"..string.sub(color,5,6)

    r = string.format("%d",r)
    g = string.format("%d",g)
    b = string.format("%d",b)
    return cc.c3b(r,g,b)
end 

function ComFunMgr:createRichText(str, size, fontSize)
    local richtext= require("app.common.LLRichText").new()
    richtext:setSize(size)
    richtext:setFontSize(fontSize)
    richtext:setString(str)
    return richtext
end

function ComFunMgr:encodeBase64(source_str)  
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'  
    local s64 = ''  
    local str = source_str  
  
    while #str > 0 do  
        local bytes_num = 0  
        local buf = 0  
  
        for byte_cnt=1,3 do  
            buf = (buf * 256)  
            if #str > 0 then  
                buf = buf + string.byte(str, 1, 1)  
                str = string.sub(str, 2)  
                bytes_num = bytes_num + 1  
            end  
        end  
  
        for group_cnt=1,(bytes_num+1) do  
            local b64char = math.fmod(math.floor(buf/262144), 64) + 1  
            s64 = s64 .. string.sub(b64chars, b64char, b64char)  
            buf = buf * 64  
        end  
  
        for fill_cnt=1,(3-bytes_num) do  
            s64 = s64 .. '='  
        end  
    end  
  
    return s64  
end  
  
function ComFunMgr:decodeBase64(str64)  
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'  
    local temp={}  
    for i=1,64 do  
        temp[string.sub(b64chars,i,i)] = i  
    end  
    temp['=']=0  
    local str=""  
    for i=1,#str64,4 do  
        if i>#str64 then  
            break  
        end  
        local data = 0  
        local str_count=0  
        for j=0,3 do  
            local str1=string.sub(str64,i+j,i+j)  
            if not temp[str1] then  
                return  
            end  
            if temp[str1] < 1 then  
                data = data * 64  
            else  
                data = data * 64 + temp[str1]-1  
                str_count = str_count + 1  
            end  
        end  
        for j=16,0,-8 do  
            if str_count > 0 then  
                str=str..string.char(math.floor(data/math.pow(2,j)))  
                data=math.mod(data,math.pow(2,j))  
                str_count = str_count - 1  
            end  
        end  
    end  
  
    local last = tonumber(string.byte(str, string.len(str), string.len(str)))  
    if last == 0 then  
        str = string.sub(str, 1, string.len(str) - 1)  
    end  
    return str  
end  

--@ 跳转到App
--@ packName     string 包名 
--@ parame_data  string 透传的数据
--@ return  boolean 成功 or 失败
function ComFunMgr:jump2App(packName, parame_data)
    local ex_data = comFunMgr:encodeBase64(parame_data)-- base64 加密
    return platformMgr:jump2App(packName , ex_data)
end

--@ App 透传的参数监听 
function ComFunMgr:initJumperLisiener()
    local function callfunc(data)
        local ex_msg = comFunMgr:decodeBase64(data)-- base64 解密
        --操作
        
    end

    platformMgr:register_jumperCallback(callfunc)
end

--截取黑体的str的width长度的字符
-- str  需要截取的字符串
-- fontsize 字体大小
-- width 需要截取的像素长度
-- _str 截取后的字符串
-- fontsize 可选 默认22
-- fontName 可选 默认系统字库可截取表情哦
function ComFunMgr:cutStrByWidth(str , width ,fontsize ,fontName)
    fontsize = fontsize or 22
    fontName = fontName or nil
    local text = ccui.Text:create(str ,fontName ,fontsize)
    
    local size = text:getContentSize()      --str的大小
    local strNum  = text:getStringLength()  --str的utf-8个数
    local len     = string.len(str)          --str的字符数
    width = math.min(width,size.width)       --防止写的长度超过原本长度
    local index   = math.floor(width / size.width * strNum) / strNum  * len  -- 计算截取到第几个字符
    local _str    = self:cutUtfByLen(str,index)  --截取字符
    return _str
end 

--截取小于等于cutLen长度的字符串
function ComFunMgr:cutUtfByLen(input, cutLen)
    local len  = string.len(input)
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    local tmpLen = 0
    local outStr = ""
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end

        cnt = cnt + 1
        tmpLen = tmpLen + i
        if cutLen < tmpLen then
            tmpLen = tmpLen - i 
            break
        end
    end
    
    outStr = string.sub(input, 1,tmpLen)
    return outStr
end

--截断字符串（红中拿过来的）
function ComFunMgr:uiTextCut(uiTextObj)
    local uisize = uiTextObj:getContentSize()
    --cclog("GlobalFun:uiTextCut uisize>>>>", uisize.height, uisize.width)

    local rlabel = uiTextObj:getVirtualRenderer()
    local rlsize = rlabel:getContentSize()
    --cclog("GlobalFun:uiTextCut rlsize>>>>", rlsize.height, rlsize.width)

    -- --两个size不一样的，是否能拓展成显示省略号，就看情况了
    -- if rlsize.width > uisize.width then
    --     local tmp = uiTextObj:clone()
    --     -- local ap = uiTextObj:getAnchorPoint()
    --     tmp:setAnchorPoint(0,0)
    --     tmp:setPosition(uisize.width,0)
    --     tmp:setString("...")
    --     uiTextObj:addChild(tmp)
    -- end
    rlabel:setLineBreakWithoutSpace(true)
    rlabel:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_TOP)
end

function ComFunMgr:makeCopyStr(data)
    -- local str = string.format("【%s】\n复制这条信息打开�筑志红中麻将�##%s", data.msg, data.stype)
    local str = string.format("【%s】\n复制这条信息打开>>>趣牌湖南麻将<<< ##%s", data.msg, data.stype)
    for k,v in ipairs(data.params) do
        str = string.format("%s&%s", str, v)
    end 
    str = str .. "##"

    cclog("ComFunMgr:makeCopyStr >>>", str)
    return str
end

function ComFunMgr:parseCopyStr(str)
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

function ComFunMgr:getMyGameListItemByProduct(gameproduct)
    local data = gameConfMgr:getInfo("myGameListData")
    if data then 
        for k,item in pairs(data) do
            if item then 
                if item.product == gameproduct then 
                    return item
                end    
            end    
        end
    end    

    return nil
end

function ComFunMgr:checkEnterRoom()
    --检查是否自动连接到房间
    --因为剪切难免有参数bug，为避免报错导致程序无法继续执行，使用这个xpcall方式进行容错处理，如果剪切数据有异样，则无视剪切数据
    xpcall(function ()
        local targetPlatform = cc.Application:getInstance():getTargetPlatform() 
        if targetPlatform == cc.PLATFORM_OS_MAC then
            return
        end
        cclog(" ^^^^^ 检查剪贴板 ")
        local msg = platformMgr:parse_From_Clipboard()
        cclog(" ^^^^^ 检查剪贴板 msg ",msg)
        if msg ~= nil and msg ~= "" and msg ~= "null" then 
            if gameConfMgr:getInfo("mCopy_msg") == "" or gameConfMgr:getInfo("mCopy_msg") ~= msg then 

                platformMgr:copy_To_Clipboard("null") -- 操作一次就不要了

                local info = comFunMgr:parseCopyStr(msg)
                local stype = info[1]
                cclog("stype >>>", stype)

                if stype == "俱乐部" then -- 请求进入俱乐部
                    local clubId = info[2]
                    local clubName = info[3]
                    local gameproduct = info[3]
                    cclog("clubId >>>", clubId)
                    local tmp = ""
                    if clubName then
                        tmp = string.format("是否申请加入俱乐部【%s】(id:%s)", clubName, clubId)
                    else
                        tmp = string.format("是否申请加入俱乐部(id:%s)", clubId)
                    end
                    local function cb()
                        local state = gameState:getState()
                        if state == GAMESTATE.STATE_HALL then 
                        --     hallHandler:gotoJoinClub(clubId)
                        --     msgMgr:showMsg("已发送申请")
                        -- elseif state == GAMESTATE.STATE_CLUB then 
                        --     clubHandler:requestJoinClub(clubId)
                        --     msgMgr:showMsg("已发送申请")
                        end
                    end
                    msgMgr:showAskMsg(tmp,cb,nil)

                elseif stype == "房间" then
                    local roomId = info[2]
                    local gameproduct = info[3]
                    cclog("roomId >>>", roomId)

                    local itemdata = comFunMgr:getMyGameListItemByProduct(gameproduct)
                    if itemdata == nil then 
                        return 
                    end    

                    info.itemdata = itemdata
                    local function cb()
                        cclog(">>>>>> Copy enter game and room > ")
                        -- local state = gameState:getState()
                        -- if state == GAMESTATE.STATE_HALL then 
                            platformExportMgr:setEnterParams("enterRoom",{ roomId = roomId , gameProduct = gameproduct })
                            eventMgr:dispatchEvent("enterGameRoom",info)
                        -- elseif state == GAMESTATE.STATE_CLUB then 
                            -- eventMgr:dispatchEvent("enterGameRoom",info)
                        -- end
                    end
                    msgMgr:showAskMsg(string.format("是否进入%s房间(id:%s)",itemdata.name, roomId), cb, nil) 
                end
            else
                cclog("//// is mine mCopy_msg ")
            end    
        end    
    end, __G__TRACKBACK__)
end

return ComFunMgr
