local Effect_qixiaodui = class("Effect_qixiaodui",function() 
    return cc.Node:create()
end)

function Effect_qixiaodui:ctor(scene)
    --     cclog("Effect_qixiaodui >>>")
    -- cclog(debug.traceback())
    
    self.root = display.newCSNode("effect/eff_qixiaodui.csb")
    self.root:addTo(self)
    self.mInterval = 0
    local ac = cc.CSLoader:createTimeline("effect/eff_qixiaodui.csb");
    ac:play("a0",false)
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

function Effect_qixiaodui:update(t)
    if self.isDead then
        return
    end
    self.mInterval = self.mInterval + t
    if self.mInterval > 90/60 then
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

function Effect_qixiaodui:onExit()
    ex_timerMgr:unRegister(self)
    self:unregisterScriptHandler()
end

return Effect_qixiaodui