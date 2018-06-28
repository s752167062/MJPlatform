
local NumIcon = class("NumIcon", function() 
   return cc.Node:create()
end)

function NumIcon:ctor()
    self.root = display.newCSNode("club/NumIcon.csb")
    self.root:addTo(self)

    self:enableNodeEvents()
    self.bg = self.root:getChildByName("bg")
    self.panel = self.root:getChildByName("panel")
    self.defaultIcon = self.root:getChildByName("defaultIcon")

end

function NumIcon:onEnter()
    -- body
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setName("NumIcon")
    self.curNum = 0
    self.defaultIcon:setVisible(false)
    --self.bg:setVisible(false)

end

function NumIcon:onExit()
    -- body
    CCXNotifyCenter:unListenByObj(self)
end

function NumIcon:addTo(_parent)
    _parent:addChild(self)
    local size = _parent:getContentSize()
    self:setPosition(cc.p(size.width / 2, size.height / 2))
end

function NumIcon:setNum(_num)
    self.curNum = _num or 0
    if self.curNum < 0 then self.curNum = 0 end
    self.curNum = math.floor(self.curNum)

    cclog("curNum:"..self.curNum)
    local recordTb = {}
    while(true) do
        if self.curNum > 0 then
            local n = self.curNum % 10
            self.curNum = math.floor(self.curNum / 10)
            table.insert(recordTb, 1, n)
        else
            break
        end
    end
    
    local sum = tonumber(#recordTb)
    local defaultSize = self.defaultIcon:getContentSize()
    self.panel:setContentSize(cc.size(defaultSize.width * sum - (10 * (sum - 1)), defaultSize.height))
    self.panel:removeAllChildren()
    for i, v in ipairs(recordTb) do
        local newItem = self.defaultIcon:clone()
        newItem:loadTexture("image2/club/icon/num"..v..".png")
        newItem:setContentSize(cc.size(defaultSize.width, defaultSize.height))
        newItem:setPosition(cc.p((i - 1) * defaultSize.width, 0))
        if i > 1 then
            newItem:setPosition(cc.p((i - 1) * (defaultSize.width - 10), 0))
        end
        newItem:setVisible(true)
        self.panel:addChild(newItem)
    end

    self.bg:setVisible(false)
    if #recordTb == 1 then
        if recordTb[1] >= 1 and recordTb[1] <= 3 then
            cclog("recordTb[1]:"..recordTb[1])
            self.bg:loadTexture("image2/club/common/winicon"..recordTb[1]..".png")
            self.bg:setVisible(true)
        end
    end
end

function NumIcon:getNum()
    return self.curNum
end

function NumIcon:setClickFunc(func)
    -- body
    self.panel:addClickEventListener(func)
end

function NumIcon:setClickEnable(bool)
    self.panel:setTouchEnabled(bool)
end

return NumIcon
