local RuleUI = class("RuleUI",function() 
    return cc.Node:create()
end)

function RuleUI:ctor(data)
    self.root = display.newCSNode("RuleUI.csb")
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

function RuleUI:onEnter()
    local ctn_close = self.root:getChildByName("bg"):getChildByName("btn_close")
    ctn_close:addClickEventListener(function() self:onClose() end)

end

function RuleUI:onExit()
    self:unregisterScriptHandler()--取消自身监听
end

function RuleUI:onClose()
    self:removeFromParent()
end

return RuleUI