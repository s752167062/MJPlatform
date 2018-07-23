

local Button = ccui.Button
Button.originScaleX = 1.0
Button.originScaleY = 1.0
Button.defaultScale = 0.1 

Button.defaultDelay = 0.3
Button.touchCount = 0
Button.touchDelay = Button.defaultDelay

--触摸按钮 没有点击反馈，没有点击限制
function Button:onTouch(callback, soundPath)
    self:addTouchEventListener(function(sender, state)
        local event = {x = 0, y = 0}
        if state == 0 then
            event.name = "began"
            -- if soundPath and soundPath ~= "" then
            --     audio.playSound(soundPath,false)
            -- else
            --     audio.playSound("sound/hit.mp3",false)
            -- end
            self.originScaleX = self:getScaleX()
            self.originScaleY = self:getScaleY()
            --self:setScaleX(self.originScaleX + self.defaultScale)
            --self:setScaleY(self.originScaleY + self.defaultScale)
        elseif state == 1 then
            event.name = "moved"
        elseif state == 2 then
            event.name = "ended"
            self:setScaleX(self.originScaleX)
            self:setScaleY(self.originScaleY)
        else
            event.name = "cancelled"
            self:setScaleX(self.originScaleX)
            self:setScaleY(self.originScaleY)
        end
        event.target = sender
        callback(event)
    end)
    return self
end

--触摸按钮 有点击反馈，没有点击限制
function Button:onTouchAction(callback, soundPath)
    self:addTouchEventListener(function(sender, state)
        local event = {x = 0, y = 0}
        if state == 0 then
            event.name = "began"
            -- if soundPath and soundPath ~= "" then
            --     audio.playSound(soundPath,false)
            -- else
            --     audio.playSound("sound/hit.mp3",false)
            -- end
            self.originScaleX = self:getScaleX()
            self.originScaleY = self:getScaleY()
            self:setScaleX(self.originScaleX + self.defaultScale)
            self:setScaleY(self.originScaleY + self.defaultScale)
        elseif state == 1 then
            event.name = "moved"
        elseif state == 2 then
            event.name = "ended"
            self:setScaleX(self.originScaleX)
            self:setScaleY(self.originScaleY)
        else
            event.name = "cancelled"
            self:setScaleX(self.originScaleX)
            self:setScaleY(self.originScaleY)
        end
        event.target = sender
        callback(event)
    end)
    return self
end

--点击按钮 有点击反馈，有点击限制
function Button:onClickAction(callback, soundPath, delay)
    self.touchDelay = delay or self.defaultDelay
    self:addTouchEventListener(function(sender, state)
        local event = {x = 0, y = 0}
        if state == 0 and not self:isLockedBtn() then
            self.touchCount = 1
            event.name = "began"
            -- if soundPath and soundPath ~= "" then
            --     audio.playSound(soundPath,false)
            -- else
            --     audio.playSound("sound/hit.mp3",false)
            -- end
            self.originScaleX = self:getScaleX()
            self.originScaleY = self:getScaleY()
            self:setScaleX(self.originScaleX + self.defaultScale)
            self:setScaleY(self.originScaleY + self.defaultScale)
        elseif state == 1 then
            event.name = "moved"
        elseif state == 2 then
            if self.touchCount == 1 then
                event.name = "ended"
                self:setScaleX(self.originScaleX)
                self:setScaleY(self.originScaleY)

                event.target = sender
                callback(sender, event) 
                self.touchCount = 0
            end
        else
            self.touchCount = 0
            event.name = "cancelled"
            self:setScaleX(self.originScaleX)
            self:setScaleY(self.originScaleY)
        end
    end)
    return self
end

--点击按钮 没有点击反馈，有点击限制
function Button:onClick(callback, soundPath, delay)
    self.touchDelay = delay or self.defaultDelay
    self:addClickEventListener(function(sender)
        if not self:isLockedBtn() then
            -- if soundPath and soundPath ~= "" then
            --     audio.playSound(soundPath,false)
            -- else
            --     audio.playSound("sound/hit.mp3",false)
            -- end
            callback(sender) 
        end
    end)
    return self
end

--锁按钮
function Button:isLockedBtn()
    if self._btnLockFlag == nil then
        self._btnLockFlag = false
    end
    if self._btnLockFlag == false then      
        self._btnLockFlag = true
        local callFunc = function()
            self._btnLockFlag = false
            cclog("test btn DelayTime")
        end
        local action = cc.Sequence:create(cc.DelayTime:create(self.touchDelay or self.defaultDelay), cc.CallFunc:create(callFunc))
        self:runAction(action)
        return false
    end 
    return true
end
