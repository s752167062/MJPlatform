local Effect_hu = class("Effect_hu",function() 
    return cc.Node:create()
end)

function Effect_hu:ctor(pos,scene,flag)
    -- cclog("Effect_hu >>>")
    -- cclog(debug.traceback())

    self.root = display.newCSNode("effect/eff_hu1.csb")
    self.root:addTo(self)
    
    self.flag = flag
    self.img_hu = self.root:getChildByName("hu_hu2_1")
    self.img_huword = self.root:getChildByName("hu_huword_2")
    self.img_hu:setVisible(false)
    
    self.img_huword:setOpacity(150)
    
    local ac = cc.CSLoader:createTimeline("effect/eff_hu1.csb");
    ac:play("a0",false)
    self:runAction(ac)
    
    self.mInterval = 0
    self.playAction =false
    self.scene = scene
    self.pos = pos
    ex_timerMgr:register(self)
    self:registerScriptHandler(function(state)
        if state == "enter" then
        --self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)
end

function Effect_hu:update(t)
    self.mInterval = self.mInterval + t
    if self.mInterval < 25/60 then
        self.img_huword:setOpacity(150*((25/60-self.mInterval)/(25/60)))
    elseif self.mInterval < 50/60 then
        local t1 = self.mInterval - 25/60
        self.img_huword:setOpacity(255*(t1/25*60))
        if self.isSound == nil or self.isSound == false then
            self.isSound = true
            --
        end
    else
        if self.mInterval > 135/60 then
            if self.playAction == false then
                self:stopAllActions()
                self.playAction = true
                local x,y =0,0
                if self.pos == 1 then
                    x,y = self.scene.root:getChildByName("ctn_one"):getPosition()
                    y = y + 30
                elseif self.pos == 2 then
                    x,y = self.scene.root:getChildByName("ctn_two"):getPosition()
                    x = x + 50
                elseif self.pos == 3 then
                    x,y = self.scene.root:getChildByName("ctn_three"):getPosition()
                    y = y - 10
                else
                    x,y = self.scene.root:getChildByName("ctn_four"):getPosition()
                    x = x - 50
                end
                x = x - display.width/2
                y = y - display.height/2
                --local ac0 = cc.DelayTime:create(0.5)
                ex_audioMgr:playEffect("sound/out.mp3")
                local ac1 = cc.MoveTo:create(0.3,cc.p(x,y))
                local ac2 = cc.CallFunc:create(function()
                    self.img_hu:setVisible(true)
                    self.img_hu:setPosition(cc.p(self.img_huword:getPositionX() - 15,self.img_huword:getPositionY()))
                    ex_audioMgr:playEffect(string.format("sound/%dhu.mp3",self.scene.player[self.pos or 1].sex==0 and 2 or 1))
                 end)
                 local ac3 = cc.DelayTime:create(0.5)
                 local ac4 = cc.CallFunc:create(function() if self.flag and self.scene.isVideo == false then CCXNotifyCenter:notify("ZhaMaNotify",nil) end end)
                
                local seq = cc.Sequence:create({ac1,ac2,ac3,ac4})
                self.img_huword:runAction(seq)
            end
        end
    end
end

function Effect_hu:onExit()
    ex_timerMgr:unRegister(self)
    self:unregisterScriptHandler()
end

return Effect_hu