--@网络信息提示(弹出框)
--@Author   sunfan
--@date     2017/07/19
local NetMessage = class("NetMessage",cc.load("mvc").ViewBase)

NetMessage.RESOURCE_FILENAME = __platformHomeDir .."ui/layout/NetMessage.csb"

local EffectNet = require("app.common.CommonEffect")

function NetMessage:onCreate()
    self._msgMsg = self:getUIChild("net_str")
    self._msgPoint = self:getUIChild("net_str_point")
    self._msgPoint:setVisible(false)
    self._msgMsgPosition = {x = self._msgMsg:getPositionX(),y = self._msgMsg:getPositionY()}
    --所有信息
    self._msg = {}
    --当前显示字符串
    self._currentStr = ""
    --是否已经移除
    self._isRemove = false
end

function NetMessage:onEnter()
    timerMgr:register(self)
end

function NetMessage:update(dt)
    if #self._msg <= 0 then
        self:_closeView()
        return
    end
    self:_setMsg(self._msg[#self._msg].msg,self._msg[#self._msg].target)
end

function NetMessage:onExit()
    self._isRemove = true
    timerMgr:unRegister(self)
    effMgr:removeEffectWithTargetImmediately("netEffect")
end

function NetMessage:init(msg,target)
    if not msg or not target then
        return 
    end
    self._msg[#self._msg + 1] = {msg = msg,target = target}
    self:_setMsg(msg,target)
end

function NetMessage:_setMsg(msg,target)
    if self._msgMsg and self._currentStr ~= msg then
        self._currentStr = msg
        self:_setNetMsgEffect(target == "netJumpInfo")
        self._msgMsg:setString(msg)
    end
end

function NetMessage:addMsg(msg,target)
    if not msg or not target then
        return
    end
    if not self:_searchSameMsg(msg,target) then
        self._msg[#self._msg + 1] = {msg = msg,target = target}
    end
end

function NetMessage:_searchSameMsg(msg,target)
    if #self._msg <= 0 then
        return false
    end
    local index = -1
    local temp = {}
    for loop = 1,#self._msg do
        if self._msg[loop].msg == msg and self._msg[loop].target == target and index <= 0 then
            index = loop
        else
            temp[#temp + 1] = {target = self._msg[loop].target,msg = self._msg[loop].msg}
        end
    end
    if index > 0 then
        temp[#temp + 1] = {target = self._msg[index].target,msg = self._msg[index].msg}
    end
    self._msg = temp
    if index <= 0 then
        return false
    else
        return true
    end
end

function NetMessage:closeMsg(target)
    if not target then
        return
    end
    local temp = {}
    for loop = 1,#self._msg do
        if self._msg[loop].target ~= target then
            temp[#temp + 1] = {msg = self._msg[loop].msg,target = self._msg[loop].target}
        end
    end
    self._msg = temp
end

function NetMessage:_closeView()
    if self._isRemove then
        return
    end
    viewMgr:close("netMessage_view")
end

function NetMessage:_setNetMsgEffect(value)
    if value then
        local effectNet = EffectNet.new({acname = "a1", target = "netEffect", csb = __platformHomeDir .."ui/effect/WaitingLayer.csb"})
        effMgr:playEffect(effectNet,self)
        self._msgMsg:setPosition(cc.p(self._msgMsgPosition.x,self._msgMsgPosition.y - 60))
    else
        effMgr:removeEffectWithTargetImmediately("netEffect")
        self._msgMsg:setPosition(cc.p(self._msgMsgPosition.x,self._msgMsgPosition.y))
    end
end

return NetMessage
