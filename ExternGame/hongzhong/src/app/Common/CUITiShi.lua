local CUITiShi = class("CUITiShi",function() return cc.Node:create() end)

function CUITiShi:ctor(data)
    self.root = display.newCSNode("common/tishi2.csb")
    self.root:addTo(self)
    
    self.root:getChildByName("bg"):getChildByName("txt_msg"):setString(data.err)
    self.ok = data.ok
    self.cancel = data.cancel
    self.root:getChildByName("bg"):getChildByName("btn_close"):addClickEventListener(function() self:onClose() end)

    self.wtype = data.wtype or 1

    self.node_type1 = self.root:getChildByName("bg"):getChildByName("type1")
    self.node_type2 = self.root:getChildByName("bg"):getChildByName("type2")
    self.node_type1:setVisible(false)
    self.node_type2:setVisible(false)
    if self.wtype == 1 then
        self.node_type1:getChildByName("btn_shi"):addClickEventListener(function() self:onSure() end)
        self.node_type1:getChildByName("btn_fou"):addClickEventListener(function() self:onCancel() end)
        self.node_type1:setVisible(true)
    elseif self.wtype == 2 then
        self.node_type2:getChildByName("btn_sure"):addClickEventListener(function() self:onSure() end)
        self.node_type2:setVisible(true)
    end
end

function CUITiShi:onSure()
    if self.ok then
        self.ok()
    end
    self:removeFromParent()
end

function CUITiShi:onCancel()
    if self.cancel then
        self.cancel()
    end
    self:removeFromParent()
end

function CUITiShi:onClose()
    self:removeFromParent()
end

return CUITiShi