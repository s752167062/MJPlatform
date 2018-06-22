--@信息提示(弹出框)
--@Author   sunfan
--@date     2017/06/14
local Message = class("Message",cc.load("mvc").ViewBase)

Message.RESOURCE_FILENAME = __platformHomeDir .."ui/layout/Message.csb"

local showTime = 3
local speed = 3

function Message:onCreate()
    self._msgBg = self:getUIChild("msg_bg")
    self._label = cc.Label:createWithSystemFont("test",__platformHomeDir .."font/LexusJianHei.ttf", 36)
--    self._label:setAnchorPoint(cc.p(0,0))
--    self._label:setDimensions(450,400)
    self._label:setPositionY(28)
    self._label:setTextColor(cc.c3b(248,249,208))
    self:addChild(self._label)
    self._time = showTime
    self._destory = false
end

function Message:onEnter()
    timerMgr:register(self)
end

function Message:update(dt)
    self._time = self._time - dt
    if self._time <= 0 then
        if not self._destory then
            --针对跳场景极限问题
            viewMgr:closeWithObject("message_view",self)
        end
        return
    end
--    local alph = math.floor(self._time / showTime * 255)
--    if alph < 0 then
--        alph = 0
--    end
--    if alph > 255 then
--        alph = 255
--    end
--    self._msgBg:setOpacity(alph)
--    self._label:setOpacity(alph)
    self._msgBg:setPosition(self._msgBg:getPositionX(),self._msgBg:getPositionY() + speed)
    self._label:setPosition(self._label:getPositionX(),self._label:getPositionY() + speed)
end

function Message:onExit()
    self._destory = true
    timerMgr:unRegister(self)
end

function Message:init(msg)
    self._destory = false
    self._time = showTime
    self._label:setString(msg)
    local msgSize = self._label:getContentSize()
    if msgSize.width >= 700 then
        self._label:setWidth(700)
        self._label:setString(msg)
    end
    msgSize = self._label:getContentSize()
    self._msgBg:setContentSize(msgSize.width + 5,msgSize.height + 5)
    self._label:setPosition(self._msgBg:getPosition())
end
return Message
