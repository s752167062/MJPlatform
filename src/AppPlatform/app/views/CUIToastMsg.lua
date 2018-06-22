local CUIToastMsg = class("CUIToastMsg",function() return cc.Node:create() end)

function CUIToastMsg:ctor()
    self.root = display.newCSNode(__platformHomeDir .."ui/layout/CUIToastMsg.csb")
    self.root:addTo(self)
    
    self:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)
    
end

function CUIToastMsg:onEnter()
	
end

function CUIToastMsg:onExit()
    timerMgr:clearTask("CUIToastMsg")
end

function CUIToastMsg:show(str , interval)
    local lens =  string.len(str)
    self:setMsgForAllChar(str)

    interval = interval or 3
    
    local label = self.root:getChildByName("Text")    
    local size = label:getContentSize()
    local offset = 30
    
    local bg = self.root:getChildByName("node")
    local node = comFunMgr:createRoundRectNode(size.width + offset  , size.height + offset , 10 , cc.c4b(180,180,180,180))
    bg:addChild(node)

    local time_out_callfunc = function ()
       timerMgr:clearTask("CUIToastMsg")
       viewMgr:close("CUIToastMsg")
    end

    timerMgr:clearTask("CUIToastMsg")
    timerMgr:registerTask("CUIToastMsg", timerMgr.TYPE_CALL_ONE, time_out_callfunc, interval)--开启超时定时器
end

function CUIToastMsg:setMsgForAllChar(msg)
    if msg == "" then
        return
    end
    local label = self.root:getChildByName("Text")
    label:setString(msg)  

    local size = label:getContentSize()
    local length = string.len(msg)
    local line = math.modf(size.width / 220) 

    local start = 1
    local newstr = ""
    for index = 1, line do
        local endp   =  math.modf((index * 200 / size.width)  * length)
        local offset = math.fmod(endp,2)
        if offset ~= 0 then
            endp = endp - offset
        end

        local str , offset = comFunMgr:CATString(msg,  start, endp) 
        newstr = newstr .. str 
        if index ~= line then
            newstr = newstr .."\n"
        end

        start = endp + 1
    end

    if start < length then
        if start == 1 then
            newstr = string.sub(msg, start, length);
        else
            newstr =  newstr .. "\n" .. comFunMgr:CATString(msg ,  start , length)  -- string.sub(msg, start  , length );
        end
    end

    label:setString(newstr)  
end

function CUIToastMsg:getContext()
    local label = self.root:getChildByName("Text")
    if label then
        return label:getString()
    end
    return ""
end

return CUIToastMsg
