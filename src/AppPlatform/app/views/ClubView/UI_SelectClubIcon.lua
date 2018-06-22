

local UI_SelectClubIcon = class("UI_SelectClubIcon", cc.load("mvc").ViewBase)

UI_SelectClubIcon.RESOURCE_FILENAME = __platformHomeDir .."ui/layout/ClubView/UI_SelectClubIcon.csb"

function UI_SelectClubIcon:init(data)
    



    self.curIndex = data.curIndex
    self.callBack = data.callBack  

end

function UI_SelectClubIcon:onEnter()

    self:initUI()
    self:setMainUI()
end

function UI_SelectClubIcon:onExit()
    self:unregisterScriptHandler()
    eventMgr:removeEventListenerForTarget(self)
end

function UI_SelectClubIcon:onUIClose()
    self:closeUI()
end

function UI_SelectClubIcon:closeUI()
    viewMgr:close("ClubView.UI_SelectClubIcon")
end


function UI_SelectClubIcon:initUI()
    -- body
    self.iconView = self:findChildByName("iconView")

    self.btn_close = self:findChildByName("btn_close")
    self.btn_close:onClick(function () self:closeUI() end)

    self.btn_sure = self:findChildByName("btn_sure")
    self.btn_sure:onClick(function () self:sure() end)
end

function UI_SelectClubIcon:setMainUI()
    -- body
    -- self.curIndex = ClubManager:getInfo("clubIcon")
    self.iconView:removeAllChildren()
    self.itemList = {}
    local contentSize = self.iconView:getContentSize()
    
    local data = clubMgr:getIconList()


    local num = #data
    local row = 5--排数
    local col = math.ceil(num/row)--行数
    local w, h = 104, 100
    local totalWidth = w * row--总宽度
    local totalHeight = h * col--总高度
    if totalHeight <= contentSize.height then
        totalHeight = contentSize.height
    end
    local offset_x, offset_y = w, h
    local uiIndex = 0
    local pos_x, pos_y = 0, totalHeight

    for index=1,num do
        if uiIndex%row == 0  then
            pos_x = 0 
            pos_y = pos_y - offset_y
        else
            pos_x = pos_x + offset_x
        end
        uiIndex = uiIndex + 1

        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(100,100))

        local item = display.newCSNode(__platformHomeDir .."ui/layout/ClubView/Item_selectIcon.csb")
      
        item:setPosition(cc.p(pos_x,pos_y))
        item:addTo(layout)

        local info = data[index]
        if info.id == self.curIndex then
            item:findChildByName("select"):setVisible(true)
        else
            item:findChildByName("select"):setVisible(false)
        end
        cclog(">>>", info.id, info.path)
        item:findChildByName("img"):loadTexture(info.path, 1)
        item:findChildByName("img"):setTouchEnabled(true)
        item:findChildByName("img"):addClickEventListener(function() self:selectIcon(info.id) end)
        self.iconView:addChild(layout)
        self.itemList[#self.itemList+1] = {id = info.id, w = item}
    end

    local innerSize = self.iconView:getInnerContainer():getContentSize()
    self.iconView:setInnerContainerSize(cc.size(innerSize.width,totalHeight))
end



function UI_SelectClubIcon:selectIcon(index)
    -- body
    self.curIndex = index
    cclog("selectIcon = ", index)
    for i=1,#self.itemList do
        local d = self.itemList[i]
        if d.id == index then
            d.w:findChildByName("select"):setVisible(true)
        else
            d.w:findChildByName("select"):setVisible(false)
        end
    end
end

function UI_SelectClubIcon:sure()
    if self.callBack then
        self.callBack(self.curIndex)
    end
    self:closeUI()
end


return UI_SelectClubIcon






