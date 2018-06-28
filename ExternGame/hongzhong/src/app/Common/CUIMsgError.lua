local CUIMsgError = class("CUIMsgError",function() return cc.Node:create() end)

function CUIMsgError:ctor(data)
    self.root = display.newCSNode("common/CUIMsgError.csb")
    self.root:addTo(self)
    
    self.root:getChildByName("base"):getChildByName("txt_info"):setString(data.err)
    local rlabel = self.root:getChildByName("base"):getChildByName("txt_info"):getVirtualRenderer()
    rlabel:setLineBreakWithoutSpace(true)
    
    self.root:getChildByName("ctn_01"):setVisible(1 == data.flag)
    self.root:getChildByName("ctn_02"):setVisible(2 == data.flag)
    self.ok = data.ok
    self.cancel = data.cancel
    
    self.root:getChildByName("ctn_01"):getChildByName("btn_01"):addClickEventListener(function() self:onSure() end)
    self.root:getChildByName("ctn_02"):getChildByName("btn_02"):addClickEventListener(function() self:onSure() end)
    self.root:getChildByName("ctn_02"):getChildByName("btn_03"):addClickEventListener(function() self:onCancel() end)
    
end

function CUIMsgError:onSure()
    if self.ok then
        self.ok()
    end
    
    self:removeFromParent()
end

function CUIMsgError:onCancel()
    if self.cancel then
        self.cancel()
    end
    self:removeFromParent()
end

return CUIMsgError