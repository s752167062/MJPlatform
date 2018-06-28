local btn_gang = class("btn_gang",function() 
    return cc.Node:create()
end)

local BaseMahjong = ex_fileMgr:loadLua("app.views.game.CSBMahjong")

function btn_gang:ctor(data)
    self.root = display.newCSNode("game/btn_gang.csb")
    self.root:addTo(self)

    self.outID = data.outID
    self.num = data.num
    self.gt = data.gt
    local btn_ = self.root:getChildByName("btn_gang")
    btn_:addClickEventListener(function() self:onGang() end)
    
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

    self.base_color = btn_:getColor()
    self.btn_ = btn_
    CCXNotifyCenter:listen(self,function(obj,key,data) 
        cclog("btn_gang >>>", data.numb, self.num)
        if data.numb == self.num then
            btn_:setColor(cc.c3b(0,125,0))
        end
        end,"gang_btn_set_color")
end

function btn_gang:onEnter()
end

function btn_gang:onExit()
     CCXNotifyCenter:unListenByObj(self)
end

function btn_gang:onGang()
    if self.gt ~= 1 then--明杠
        cclog("btn outID  "  .. self.outID)
        ex_roomHandler:userMingGang(self.outID,GlobalFun:localCardToServerCard(self.num))
    else
        ex_roomHandler:userAnGang(GlobalFun:localCardToServerCard(self.num))
    end
    CCXNotifyCenter:notify("BtnCleanAll",nil)
end

function btn_gang:resetColor()
    self.btn_:setColor(self.base_color)
end

return btn_gang
