local CUIGame_OK = class("CUIGame_OK",function() 
    return cc.Node:create()
end)

function CUIGame_OK:ctor()
    self.root = display.newCSNode("game/CUIGame_OK.csb")
    self.root:addTo(self)
    
    for i=1,4 do
        self.root:getChildByName("ctn_center"):getChildByName(string.format("game_ok_%d",i)):setVisible(false)
    end
end

function CUIGame_OK:setOKVisible(index,b)
    if b == nil then
        return
    end
    self.root:getChildByName("ctn_center"):getChildByName(string.format("game_ok_%d",index)):setVisible(b)
end

return CUIGame_OK