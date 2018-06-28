--ex_fileMgr:loadLua("app.Configure.Emoji_conf")
--ex_fileMgr:loadLua("app.Configure.SoundMsg_conf")
local item_speak = class("item_speak",function() return cc.Node:create() end)

function item_speak:ctor()
    cclog("new one Speak")
    self.root = display.newCSNode("game/item_speak.csb")
    self.root:addTo(self)
    
    self.bg = self.root:getChildByName("img_speakbg")
    self.label = self.root:getChildByName("txt")
    self.ctn_node = self.root:getChildByName("ctn_node")
    
    self:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)
       
end

function item_speak:onEnter()
	local p = self:convertToWorldSpace(cc.p(0,0))
	local size = self.bg:getContentSize()
    size = cc.size(size.width*0.7, size.height*0.7) 
    
	--位置确定
	local a = self:getPositionX()
	if display.width / 2 < p.x then
        self.bg:setFlippedX(true)
        self:setPositionX(self:getPositionX()-170)
	    if size.height + p.y > display.height then
            self.bg:setFlippedY(true)
            self.label:setPositionY(53)
            self.ctn_node:setPositionY(53)
            self:setPositionY( -180)
        end 
	end

end

function item_speak:onExit()
	if self.schedulerid ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerid)  
	end
end

function item_speak:setSpeakString(index , sex)
    cclog("item speak string " .. index)
    index = index * 1
    local soundMsg = SoundMsg_conf[index]
    if soundMsg ~= nil then
        local msg = soundMsg.msg
        local interval = soundMsg.interval
        self.label:setString(msg) 	
        self:createScheduleByInterval(interval)
        
        local effpath = string.format("sound/FuncVoice/voice%d%02d.mp3",sex,index)--"sound/FuncVoice/voice".. sex ..index ..".mp3"
        ex_audioMgr:playEffect(effpath,false)
    else
        self:removeFromParent()
    end
end

function item_speak:setEmoji(index)
    cclog("item speak emoji " .. index)
    index = index * 1
    local emoji = Emoji_conf[index]
    if emoji ~= nil then
        local frames = emoji.endFames   
        
        local eNode = display.newCSNode(string.format("game/emoji/emoji_%02d.csb",index)) --"effect/eff_hu.csb") --          
        self.ctn_node:addChild(eNode)
          
        local action = cc.CSLoader:createTimeline(string.format("game/emoji/emoji_%02d.csb",index))--"effect/eff_hu.csb")--
        action:play("a0",true) 

        -- action:setFrameEventCallFunc(function(frame) cclog(" ***  setFrameEventCallFunc() ***  "..type(frame) .. "  "..  frame:getEvent() .."  "..type(event)) end)
        
        eNode:runAction(action) 

        self:createScheduleByFrames(frames)
    else
        self:removeFromParent()
    end
end

function item_speak:speakVioce(interval , filename)
    local eNode = display.newCSNode("game/emoji/item_speakVoice.csb") 
    self.ctn_node:addChild(eNode)

    local action = cc.CSLoader:createTimeline("game/emoji/item_speakVoice.csb")
    action:play("a0",true) 

    eNode:runAction(action) 
    self:createScheduleByInterval(interval , filename)
    
end

function item_speak:createScheduleByInterval(interval , filename)
    local minterval = 0
    local function updatefunc(t)
        minterval = minterval + t
        if minterval >= interval then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerid)  
            self.schedulerid = nil
            self:removeFromParent()
            
            if filename ~= nil then
                cclog("DELETE FILE " .. filename)
                os.remove(filename)
            end
        end          
    end
    
    local scheduler = cc.Director:getInstance():getScheduler()
    self.schedulerid = scheduler:scheduleScriptFunc(updatefunc,0,false)    
end

function item_speak:createScheduleByFrames(frames)
	 local mframs = 0
    local function updatefunc(t)
        mframs = mframs + 1
        if mframs >= frames then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerid)  
            self.schedulerid = nil
            self:removeFromParent()
        end          
    end
    
    local scheduler = cc.Director:getInstance():getScheduler()
    self.schedulerid = scheduler:scheduleScriptFunc(updatefunc,0,false)    
end

return item_speak
