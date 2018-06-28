local Player_flag = class("Player_flag",function() 
    return cc.Node:create()
end)

function Player_flag:ctor()
    self.root = display.newCSNode("game/Player_flag.csb")
    self.root:addTo(self)

    local ac = cc.CSLoader:createTimeline("game/Player_flag.csb")
    ac:play("a0",true)
    self:runAction(ac)
end


return Player_flag