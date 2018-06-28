local NotifyUI = class("NotifyUI",function() 
    return cc.Node:create()
end)

function NotifyUI:ctor(data)
    self.root = display.newCSNode("NotifyUI.csb")
    self.root:addTo(self)

    self:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        elseif state == "enterTransitionFinish" then
        --self:onEnterTransitionFinish_()
        elseif state == "exitTransitionStart" then
        --self:onExitTransitionStart_()
        elseif state == "cleanup" then
        --self:onCleanup_()
        end
    end)
    
    self.time = 0
    self.strindex = 1
    local function handler(t)
        self:update(t)
    end
    self:scheduleUpdateWithPriorityLua(handler,0)
end

function NotifyUI:onEnter()
    self.text = self.root:getChildByName("bg"):getChildByName("maskPanel"):getChildByName("content")
    self.text:setPosition(cc.p(630, 17))
    self:setVisible(false)
    
    self.canShow = true; -- 
    CCXNotifyCenter:listen(self,function(obj,key,data) self:canNotifyShow(data) end,"canNotifyShow")
end

function NotifyUI:onExit()
    self:unregisterScriptHandler()--取消自身监听
    CCXNotifyCenter:unListenByObj(self)
end

function NotifyUI:canNotifyShow(bool)
    self.canShow = bool
    self:setVisible(bool)
end

function NotifyUI:update(t)
    self.time = self.time + t
    if #GlobalData.NotifyContexts > 0 then
        if self.canShow and self:isVisible() == false then
            self:setVisible(true)
            self.text:setText(GlobalData.NotifyContexts[1] .. "")
            local x,y = 630,self.text:getPositionY()
            self.text:setPosition(cc.p(x-5,y))
            self.time = 0
            table.remove(GlobalData.NotifyContexts,1)
        end
    end
    
    if self:isVisible() and string.len(self.text:getString()) > 1 and self.time > 0.025 then
        local x,y = self.text:getPosition()
        
        if x < -self.text:getContentSize().width-30 then
            if #GlobalData.NotifyContexts < 1 then
                self:setVisible(false)
                return
            else
                self.text:setText(GlobalData.NotifyContexts[1] .. "")
                x = 630
                table.remove(GlobalData.NotifyContexts,1)
            end
        end
        self.text:setPosition(cc.p(x-2,y))
        self.time = 0
    end
    --[[
    if string.len(self.text:getString()) > 1 and self.time > 0.1 and #GlobalData.NotifyContexts > 0 then
        local x, y = self.text:getPosition()
        if x < -string.len(self.text:getString()) * 22 then
        	x = 630
        	self.strindex = self.strindex + 1
            if self.strindex > #GlobalData.NotifyContexts then
                self.strindex = 1
                GlobalData.NotifyContexts = {}
                self:setVisible(false)
                return
        	end
            self.text:setText(GlobalData.NotifyContexts[self.strindex] .. "")
            
        end
        self.text:setPosition(cc.p(x - 5, y))
        self.time = 0
        --cclog("x=" .. x .. ",y=" .. y)
    end
    ]]
end

return NotifyUI