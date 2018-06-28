local Effect_fangpao = class("Effect_fangpao",function() 
    return cc.Node:create()
end)

function Effect_fangpao:ctor(scene, player, hav_hu_type)
    self.root = display.newCSNode("effect/eff_fangpao.csb")
    self.root:addTo(self)
    self.mInterval = 0
    self.hav_hu_type = hav_hu_type
    local ac = cc.CSLoader:createTimeline("effect/eff_fangpao.csb");
    ac:play("a0",false)
    self:runAction(ac)
    
    self:setScale(0.8)
    self.scene = scene
    self.isDead = false
    
    -- local x,y = player:getPosition()
    local x,y = 0,0
    if player.pos == 1 then
        x,y = 568,80
    elseif player.pos == 2 then
        x,y = 906,320
    elseif player.pos == 3 then
        x,y = 568,560
    elseif player.pos == 4 then
        x,y = 230,320
    end

    self:setPosition(x,y)

    ex_timerMgr:register(self)
    self:registerScriptHandler(function(state)
        if state == "enter" then
        --self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)
end

function Effect_fangpao:update(t)
    if self.isDead then
        return
    end
    self.mInterval = self.mInterval + t
    if self.mInterval > 60/60 then
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
        if not self.hav_hu_type then
            self.scene:processBaseHuEffect()
        end
        
        self:removeFromParent()
    end
    
end

function Effect_fangpao:onExit()
    ex_timerMgr:unRegister(self)
    self:unregisterScriptHandler()
end

return Effect_fangpao