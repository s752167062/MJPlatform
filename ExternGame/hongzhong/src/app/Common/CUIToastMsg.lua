local CUIToastMsg = class("CUIToastMsg",function() return cc.Node:create() end)

function CUIToastMsg:ctor()
    self.root = display.newCSNode("common/CUIToastMsg.csb")
    self.root:addTo(self)
    
    self:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" or state == "cleanup" then
            self:onExit()
        end
    end)
    
end

function CUIToastMsg:onEnter()
	
end

function CUIToastMsg:onExit()
    self:unregisterScriptHandler()
    if self.schedulerID  then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID) 
        self.schedulerID = nil
    end
end


function CUIToastMsg:show(str , interval)
    cclog("Interval "..interval)
    local lens =  string.len(str)
--    local newString  = str
--    if lens > 30 then
--        cclog(" size " .. math.modf(lens / 30))
--    	newString = ""
--    	for index = 1 , math.modf(lens / 30) do
--    		newString = newString .. string.sub(str, (index - 1)* 30 + 1 ,  index * 30)  .. "\n"
--    	end
--    	if lens >  math.modf(lens / 30) * 30 then
--    		newString = newString .. string.sub(str, math.modf(lens / 30) * 30 + 1 ,  lens) 
--    	end
--    end
    self:setMsgForAllChar(str)
    
    local label = self.root:getChildByName("Text")
--    label:setString(newString)
    
    local size = label:getContentSize()
    local offset = 30
    
    local bg = self.root:getChildByName("node")
    local node = GlobalFun:createRoundRectNode( size.width + offset  , size.height + offset , 10 , cc.c4b(180,180,180,180))
    bg:addChild(node)
   
    
    local scheduler = cc.Director:getInstance():getScheduler()  
    --local schedulerID = nil 
    local minterval = 0 
    self.schedulerID = scheduler:scheduleScriptFunc(function(t)  
        minterval = minterval + t 
        if minterval >= interval then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID) 
            self.schedulerID = nil
            self:removeFromParent()
            
        end
         
    end,0,false)  

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

        local str , offset = Util.CATString(msg ,  start , endp) 
        newstr = newstr .. str 
        if index ~= line then
            newstr = newstr .."\n"
        end

        start = endp + 1 --  + offset
    end

    if start < length then
        if start == 1 then
            newstr = string.sub(msg, start  , length );
        else
            newstr =  newstr .. "\n" .. Util.CATString(msg ,  start , length)  -- string.sub(msg, start  , length );
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
