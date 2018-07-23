--[[

Copyright (c) 2011-2014 chukong-inc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

local Widget = ccui.Widget

function Widget:onTouch(callback)
    self:addTouchEventListener(function(sender, state)
        local event = {x = 0, y = 0}
        if state == 0 then
            event.name = "began"
        elseif state == 1 then
            event.name = "moved"
        elseif state == 2 then
            event.name = "ended"
        else
            event.name = "cancelled"
        end
        event.target = sender
        callback(event)
    end)
    return self
end

function Widget:onClick(callback)
    self:addClickEventListener(function(sender)
        if self:isLockedBtn() == true then
            local event = {}
            event.target = sender
            callback(event) 
        end
    end)
    return self
end

--锁按钮
function Widget:isLockedBtn()
    if self._btnLockFlag == nil then
        self._btnLockFlag = false
    end
    if self._btnLockFlag == false then      
        self._btnLockFlag = true
        local callFunc = function()
            self._btnLockFlag = false
            cclog("test btn DelayTime")
        end
        local action = cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(callFunc))
        self:runAction(action)
        return true
    end 
    return false
end

-- 添加widget类的点击声音方法
function Widget:onClickBySound(callback,soundPath)
    self:addClickEventListener(function(sender)
        if soundPath and soundPath ~= "" then
            audio.playSound(soundPath,false)
        else
            audio.playSound("audio/hit.mp3",false)
        end
        callback(sender) 
    end)
    return self
end