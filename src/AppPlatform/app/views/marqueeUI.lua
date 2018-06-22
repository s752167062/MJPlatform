--跑马灯
local MarqueeUI = class("MarqueeUI", require("app.common.NodeBase"))

function MarqueeUI:ctor()
    MarqueeUI.super.ctor(self,  __platformHomeDir .."ui/layout/MarqueeUI.csb")
    self.time = 0
    self.strindex = 1
    self.noticeList = {}
    self.text = self:findChildByName("content")
    self.text:setString("")
end

function MarqueeUI:onEnter()
    print("MarqueeUI:onEnter")
    self.text:setPosition(cc.p(630, 15))
    self:setVisible(false)
    
    self.canShow = true
    eventMgr:registerEventListener("canNotifyShow",handler(self,self.canNotifyShow),self)
    timerMgr:register(self)
end

function MarqueeUI:onExit()
    timerMgr:unRegister(self)
    eventMgr:removeEventListenerForTarget(self)
end

function MarqueeUI:canNotifyShow(bool)
    self.canShow = bool
    self:setVisible(bool)
end

function MarqueeUI:getNotice()
    -- body
    return self.noticeList
end

function MarqueeUI:addMsg(msg)
    -- body
    self.noticeList[#self.noticeList + 1] = msg
    self.canShow = true
end

function MarqueeUI:update(t)
    self.time = self.time + t
    if #self.noticeList > 0 then
        if self.canShow and self:isVisible() == false then
            self:setVisible(true)
            self.text:setText(self.noticeList[1] .. "")
            local x,y = 630,self.text:getPositionY()
            self.text:setPosition(cc.p(x-5,y))
            self.time = 0
            table.remove(self.noticeList,1)
        end
    end
    
    if self:isVisible() and string.len(self.text:getString()) > 1 and self.time > 0.025 then
        local x,y = self.text:getPosition()
        
        if x < -self.text:getContentSize().width-30 then
            if #self.noticeList < 1 then
                self:setVisible(false)
                return
            else
                self.text:setText(self.noticeList[1] .. "")
                x = 630
                table.remove(self.noticeList,1)
            end
        end
        self.text:setPosition(cc.p(x-2,y))
        self.time = 0
    end
end

return MarqueeUI