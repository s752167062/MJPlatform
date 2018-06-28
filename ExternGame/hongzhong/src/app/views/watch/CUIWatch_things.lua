local CUIWatch_things = class("CUIWatch_things",function() 
    return cc.Node:create()
end)

function CUIWatch_things:ctor(data)
    self.root = display.newCSNode("watch/CUIWatch_things.csb")
    self.root:addTo(self)
    


    local icon = self.root:getChildByName(string.format("img%d",data.index))
    if icon then
    	icon:setVisible(true)
    end
    
    
    self.root:getChildByName("txt_price"):setString(data.price)
end



return CUIWatch_things