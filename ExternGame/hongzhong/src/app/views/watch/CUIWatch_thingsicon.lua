local CUIWatch_thingsicon = class("CUIWatch_thingsicon",function() 
    return cc.Node:create()
end)

function CUIWatch_thingsicon:ctor(index)
    self.root = display.newCSNode("watch/CUIWatch_thingsicon.csb")
    self.root:addTo(self)

 	local icon = self.root:getChildByName(string.format("img%d",index))
    if icon then
    	icon:setVisible(true)
    end

end

return CUIWatch_thingsicon