local btn_peng = class("btn_peng",function() 
    return cc.Node:create()
end)

local BaseMahjong = ex_fileMgr:loadLua("app.views.game.CSBMahjong")

function btn_peng:ctor(data)
    self.root = display.newCSNode("game/btn_peng.csb")
    self.root:addTo(self)
    
    self.outID = data.outID
    self.num = data.num
    local btn_ = self.root:getChildByName("btn_peng")
    btn_:addClickEventListener(function() self:onPeng() end)
    
    local tmp_d = {pos = 0,num = data.num,state = 4,player = nil}
    local newCard1 = BaseMahjong.new(tmp_d)
    newCard1:setScale(0.7)
    newCard1:setLightVisible(true)
    newCard1:setPosition(50,155)
    btn_:addChild(newCard1)



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

    self.btn = btn_
    self.base_color = btn_:getColor()
    CCXNotifyCenter:listen(self,function(obj,key,data) 
        if data.numb == self.num then
            btn_:setColor(cc.c3b(0,125,0))
        end
        end,"peng_btn_set_color")
end

function btn_peng:onEnter()
end

function btn_peng:onExit()
     CCXNotifyCenter:unListenByObj(self)
end

function btn_peng:onPeng()
    ex_roomHandler:userPeng(self.outID,GlobalFun:localCardToServerCard(self.num))
    CCXNotifyCenter:notify("BtnCleanAll",nil)
end

function btn_peng:resetColor()
    self.btn:setColor(self.base_color)
end

return btn_peng
