local CUITiShi_A = class("CUITiShi_A", function() return cc.Node:create() end)


function CUITiShi_A:ctor(data)
    self.root = display.newCSNode("common/tishi_a.csb")
    self.root:addTo(self)

    self.ok = data.ok
    self.cancel = data.cancel
    self.msg = data.err
    self.wtype = data.wtype

    -- self.root:getChildByName("btn_cancel"):addClickEventListener(function() self:onCancel() end)
    self.root:getChildByName("btn_close"):addClickEventListener(function() self:onClose() end)
    self.root:getChildByName("btn_sure"):addClickEventListener(function() self:onSure() end)

    self.Text_3 = self.root:getChildByName("Text_3")

    if  self.wtype == 1 then end

    self.Text_3:setString(self.msg or "")

end



function CUITiShi_A:onEnter()

  
end





function CUITiShi_A:onClose()
    self:removeFromParent()


end

function CUITiShi_A:onSure()
    if self.ok then
        self.ok()
    end
    
    self:removeFromParent()
end

-- function CUITiShi_A:onCancel()
--     if self.cancel then
--         self.cancel()
--     end
--     self:removeFromParent()
-- end








return CUITiShi_A
