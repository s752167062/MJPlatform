
--[[
function xxxx:insertDataToListView()
    --设置ui item
    local listWeight = self.parentList
    listWeight:removeAllChildren()

    local itemLayout = display.newCSNode("layout/CreateRoomUI/CreateRoomAreaItem.csb"):getChildByName("itemLayout")
    local data = {}
    local colNum = 2
    local item_w = 379
    local item_h = 100
    local lastLayout = nil
    for i, v in ipairs(data) do

        local item = itemLayout:clone()
        local index = (i-1)%colNum
        if index == 0 then
            lastLayout = ccui.Layout:create()
            lastLayout:setContentSize(cc.size(item_w*colNum, item_h))
            listWeight:pushBackCustomItem(lastLayout)            
        end 
        item:setPosition(cc.p(item_w * index,0))
        item:setTag(i)
        item:addTo(lastLayout)

        -- local _itemW = self:loadChildrenWidget(item)
        -- _itemW["itemLayout"]:setTouchEnabled(true)
        -- _itemW["itemLayout"]:setSwallowTouches(false)
        -- _itemW["itemLayout"]:addTouchEventListener(function(sender, type)
        -- end)

        --local info = data[i]
    end
end
--]]