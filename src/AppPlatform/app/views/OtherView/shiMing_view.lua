

--实名认证界面
local shiMingView = class("shiMingView",cc.load("mvc").ViewBase)

shiMingView.RESOURCE_FILENAME =  __platformHomeDir .."ui/layout/OtherView/shiMingView.csb"

function shiMingView:onCreate()
    self.btn_quxiao = self:findChildByName("btn_quxiao")
    self.btn_quxiao:onClick(function() self:onClose() end)

    self.btn_close = self:findChildByName("btn_close")
    self.btn_close:onClick(function() self:onClose() end)
    
    self.txt_yirenzheng = self:findChildByName("txt_yirenzheng")

    self.btn_renzheng = self:findChildByName("btn_renzheng")
    self.btn_renzheng:onClick(function() self:onRenZheng() end)

    self.txt_name = self:findChildByName("txt_name")
    self.txt_id = self:findChildByName("txt_id")

    self.txt_yirenzheng:setVisible(false)
end

function shiMingView:onClose()
    viewMgr:close("OtherView.shiMing_view")
end

function shiMingView:onEnter()
    -- body
    self:showState()
    -- eventMgr:registerEventListener("onShiMing",handler(self,self.onShiMing),self)
end

function shiMingView:onExit()
    -- body
    timerMgr:unRegister(self)
    eventMgr:removeEventListenerForTarget(self)
end

function shiMingView:showState()
    -- body
    local isSuccess = comDataMgr:getInfo("shiming_success")

    if isSuccess then
        local name = comDataMgr:getInfo("shiming_name")
        local id = comDataMgr:getInfo("shiming_id")
        self.txt_name:setString(name)
        self.txt_id:setString(id)
    end

    self.txt_name:setEnabled(not isSuccess)
    self.txt_id:setEnabled(not isSuccess)
    self.txt_yirenzheng:setVisible(isSuccess)
    self.btn_renzheng:setVisible(not isSuccess)
    self.btn_quxiao:setVisible(not isSuccess)
end

function shiMingView:onShiMing(data)
    self:showState()
end

function shiMingView:onRenZheng()

    local name = self.txt_name:getString()
    local id = self.txt_id:getString()
    if name == "" or id == "" then
        msgMgr:showConfirmMsg(msgMgr:getMsg("SHIMING_TIPS"))
        return
    end
    hallSendMgr:shiMing(2, {name = name, id = id})
end

return shiMingView