local btn_hu = class("btn_hu",function() 
    return cc.Node:create()
end)

function btn_hu:ctor(data)
    self.root = display.newCSNode("game/btn_hu.csb")
    self.root:addTo(self)
    self.btn = self.root:getChildByName("btn_hu")
    self.btn:addClickEventListener(function() self:onHu() end)


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
        end,"hu_btn_set_color")
end

function btn_hu:onEnter()
end

function btn_hu:onExit()
     CCXNotifyCenter:unListenByObj(self)
end

function btn_hu:onHu()
    ex_roomHandler:confirmHu(true)
    CCXNotifyCenter:notify("BtnCleanAll",nil)
end

function btn_hu:resetColor()
    self.btn:setColor(self.base_color)
end

return btn_hu
