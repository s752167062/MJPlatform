--@LOGO场景
--@Author   sunfan
--@date     2017/04/27
local LogoScene = class("LogoScene",cc.load("mvc").ViewBase)

LogoScene.RESOURCE_FILENAME = __platformHomeDir .."ui/layout/LogoScene.csb"

local show_time = 3

function LogoScene:onCreate()
    self._imgLogo = self:getUIChild("img_logo")
    self._cTime = 0
    self.show_dt = 255 / show_time
end

function LogoScene:onEnter()
    timerMgr:register(self)
end

function LogoScene:update(dt)
    self._cTime = self._cTime + dt
    if self._cTime >= show_time then
        gameState:changeState(GAMESTATE.STATE_LOGIN)
    end
    local a_ph = self.show_dt * self._cTime
    if a_ph > 255 then
        a_ph = 255
    end
    self._imgLogo:setOpacity(a_ph)
end

function LogoScene:onExit()
    timerMgr:unRegister(self)
end

return LogoScene
