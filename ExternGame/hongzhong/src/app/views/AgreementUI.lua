local AgreementUI = class("AgreementUI",function() 
    return cc.Node:create()
end)

function AgreementUI:ctor(data)
    self.root = display.newCSNode("AgreementUI.csb")
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
end

function AgreementUI:onEnter()
    local ctn_close = self.root:getChildByName("bg"):getChildByName("btn_close")
    ctn_close:addClickEventListener(function() self:onClose() end)

end

function AgreementUI:onExit()
    self:unregisterScriptHandler()--取消自身监听
end

function AgreementUI:onClose()
    self:removeFromParent()
end

return AgreementUI