local CUIGame_ZhaMa = class("CUIGame_ZhaMa",function() 
    return cc.Node:create()
end)

local BaseMahjong = ex_fileMgr:loadLua("app.views.game.CSBMahjong")

function CUIGame_ZhaMa:ctor(data)
    self.root = display.newCSNode("game/CUIGame_ZhaMa.csb")
    self.root:addTo(self)
    
    ex_audioMgr:playEffect("sound/za.mp3")
    self.ctn_win = self.root:getChildByName("ctn_win")
    self.cnt = #data
    
    local BASE_W = 76*0.85*1.2
    local BASE_CW = BASE_W*self.cnt + (self.cnt+1)*40
    self.root:getChildByName("ctn_win"):getChildByName("Image_4"):setContentSize(BASE_CW,200)
    
    self.Index = 0
    for i=1,#data do
        local tmp_d = {pos = 0,num = data[i],state = 1,player = nil}
        local newCard = BaseMahjong.new(tmp_d)
        newCard:setScale(1.2)
        local w = newCard:getWidthAndHeight()*1.2
        local lap = (BASE_CW - w*#data)/(#data+1)
        newCard:setPositionX(-BASE_CW/2+ lap+w/2 + (lap + w)*(i-1))
        
        newCard:setTag(10+i)
        self.ctn_win:addChild(newCard)
    end
    
    self.ctn_win:setScale(0.1)
    
    
    local ac1 = cc.ScaleTo:create(0.2,1)
    local ac2 = cc.CallFunc:create(function()
        self.Index = 1
     end)
    local ac3 = cc.DelayTime:create(3)
    local ac4 = cc.ScaleTo:create(0.2,0.1)
    local ac5 = cc.CallFunc:create(function() 
        --发消息弹出结算界面
        CCXNotifyCenter:notify("SmallSummaryNotify",nil)
        self:removeFromParent()
    end)
    
    local seq = cc.Sequence:create({ac1,ac2,ac3,ac4,ac5})
    self.ctn_win:runAction(seq)
    
    ex_timerMgr:register(self)
    self.mInterval = 0
    self:registerScriptHandler(function(state)
        if state == "enter" then
        --self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)
end

function CUIGame_ZhaMa:update(t)
    self.mInterval = self.mInterval + t
    
    for i = 1,self.cnt do
        self.ctn_win:getChildByTag(10+i):update(t)
    end
    
    if self.Index > 0 then
        if self.mInterval > 0.3 then
            self.mInterval = 0
            self.ctn_win:getChildByTag(10+self.Index):setState(2)
            self.Index = self.Index + 1
            if self.Index > self.cnt then
                self.Index = 0
            end
        end
    end
end

function CUIGame_ZhaMa:onExit()
    ex_timerMgr:unRegister(self)
    self:unregisterScriptHandler()
end

return CUIGame_ZhaMa