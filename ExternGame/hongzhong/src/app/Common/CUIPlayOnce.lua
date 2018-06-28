local CUIPlayOnce = class("CUIPlayOnce",function() 
    return cc.Node:create()
end)

function CUIPlayOnce:ctor(data,delay)
    self.root = display.newCSNode(data.file)
    self.root:addTo(self)
    self.data = data
    
    ex_timerMgr:register(self)
    self:setVisible(false)
    if delay == nil then
        delay = 0
    end
    self.delay = delay
    self.EndTime = data.time + delay
    self.Interval = 0
    self.isDead = false
    self:registerScriptHandler(function(state)
        if state == "enter" then
        --self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)
end

function CUIPlayOnce:update(t)
    if self.isDead then
        return
    end
    self.Interval = self.Interval + t
    if self.Interval > self.delay then
        if self:isVisible() == false then
            self:setVisible(true)

            --播放动画
            local ac = cc.CSLoader:createTimeline(self.data.file)
            ac:play(self.data.acname,false)
            self:runAction(ac)
        end
    end
    if self.Interval > self.EndTime then
        self.isDead = true
        self:removeFromParent()
    end
end

function CUIPlayOnce:onExit()
    ex_timerMgr:unRegister(self)
    self:unregisterScriptHandler()
end

return CUIPlayOnce