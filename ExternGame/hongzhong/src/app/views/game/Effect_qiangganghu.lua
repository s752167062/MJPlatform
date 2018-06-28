local Effect_qiangganghu = class("Effect_qiangganghu",function() 
    return cc.Node:create()
end)

function Effect_qiangganghu:ctor(scene)
    self.root = display.newCSNode("effect/eff_qiangganghu.csb")
    self.root:addTo(self)
    self.mInterval = 0
    local ac = cc.CSLoader:createTimeline("effect/eff_qiangganghu.csb");
    ac:play("a1",false)
    self:runAction(ac)
    
    self:setScale(0.8)
    self.scene = scene
    self.isDead = false
    self:setPosition(display.width/2,display.height/2)
    ex_timerMgr:register(self)
    self:registerScriptHandler(function(state)
        if state == "enter" then
        --self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)
end

function Effect_qiangganghu:update(t)
    if self.isDead then
        return
    end
    self.mInterval = self.mInterval + t
    if self.mInterval > 85/60 then
        self.isDead = true
        -- local flag = true
        -- for i=1,#self.scene.winBean do
        --     for j=1,4 do
        --         if self.scene.winBean[i] == self.scene.player[j].openid then
        --             self.scene:playHuAction(j,flag)
        --             flag = false
        --         end
        --     end
        -- end

        self.scene:processBaseHuEffect()
        
        self:removeFromParent()
    end
    
end

function Effect_qiangganghu:onExit()
    ex_timerMgr:unRegister(self)
    self:unregisterScriptHandler()
end

return Effect_qiangganghu
