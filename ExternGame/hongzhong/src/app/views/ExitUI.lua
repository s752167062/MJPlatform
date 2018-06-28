local ExitUI = class("ExitUI",function() 
    return cc.Node:create()
end)

function ExitUI:ctor(data)
    self.root = display.newCSNode("ExitUI.csb")
    self.root:addTo(self)
    if data then
        self.ok = data.ok
        self.root:getChildByName("node"):getChildByName("lable_msg"):setString(data.txt)
    end
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

function ExitUI:onEnter()

    local ctn_close = self.root:getChildByName("node"):getChildByName("btn_close")
    ctn_close:addClickEventListener(function() self:onClose() end)

    self.btn_exit = self.root:getChildByName("node"):getChildByName("btn_exit") --按钮
    self.btn_exit:addClickEventListener(function() self:onExitApp() end)
    
    self.btn_cancel = self.root:getChildByName("node"):getChildByName("btn_cancel") --按钮
    self.btn_cancel:addClickEventListener(function() self:onClose() end)
    
    self.label_msg = self.root:getChildByName("node"):getChildByName("lable_msg") --label
    
end

function ExitUI:onExit()
    self:unregisterScriptHandler()--取消自身监听
end

function ExitUI:onClose()
    self:removeFromParent()
end

function ExitUI:onExitApp()
    --cc.Director:getInstance():endToLua();
    if self.ok then
        self.ok()

        self:removeFromParent()
    else
        os.exit(1)
    end
end

return ExitUI