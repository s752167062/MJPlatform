local btn_pass = class("btn_pass",function() 
    return cc.Node:create()
end)

function btn_pass:ctor(data)
    self.root = display.newCSNode("game/btn_pass.csb")
    self.root:addTo(self)
    self.btn = self.root:getChildByName("btn_pass")
    self.btn:addClickEventListener(function() self:onPass() end)


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

    self.base_color = self.btn:getColor()
    CCXNotifyCenter:listen(self,function(obj,key,data) 
        self.btn:setColor(cc.c3b(0,125,0))
        end,"pass_btn_set_color")
end

function btn_pass:onEnter()
end

function btn_pass:onExit()
     CCXNotifyCenter:unListenByObj(self)
end

function btn_pass:onPass()
    --ex_roomHandler:userMingGang(self.outID,0)
    CCXNotifyCenter:notify("PassNotify",nil)
    --CCXNotifyCenter:notify("BtnCleanAll",nil)
end

function btn_pass:resetColor()
    self.btn:setColor(self.base_color)
end

return btn_pass
