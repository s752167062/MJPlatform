

local UI_CreateClub = class("UI_CreateClub", cc.load("mvc").ViewBase)

UI_CreateClub.RESOURCE_FILENAME = __platformHomeDir .."ui/layout/ClubView/UI_CreateClub.csb"


function UI_CreateClub:onExit()
    self:unregisterScriptHandler()
    eventMgr:removeEventListenerForTarget(self)
end

function UI_CreateClub:onEnter()
    self:initUI()


    eventMgr:registerEventListener("HallProtocol.onCreateClub",handler(self,self.onCreateClub),self)
end

function UI_CreateClub:onUIClose()
    self:closeUI()
end

function UI_CreateClub:closeUI()
   viewMgr:close("ClubView.UI_CreateClub")
end

function UI_CreateClub:initUI()
    -- body
    -- self.img_icon = self:findChildByName("img_icon")
    -- self.img_icon:setTouchEnabled(true)
    -- self.img_icon:addClickEventListener(function () self:changeIcon() end)
   
    self.curIndex = 1

    self.textField_name = self:findChildByName("textField_name")
    self.textField_name:setEnabled(true)


    self.btn_close = self:findChildByName("btn_close")
    self.btn_close:onClick(function () self:onUIClose() end)

    -- self.btn_changeIcon = self:findChildByName("btn_changeIcon")
    -- self.btn_changeIcon:onClick(function () self:changeIcon() end)

    self.btn_sure = self:findChildByName("btn_sure")
    self.btn_sure:onClick(function () self:createClub() end)

    self.btn_cancel = self:findChildByName("btn_cancel")
    self.btn_cancel:onClick(function () self:onUIClose() end)

    -- self:setClubIcon("1")


    self.iconView = self:findChildByName("iconView")
    self.iconView:setScrollBarEnabled(false)

    self:showIconList()
end





--申请创建俱乐部
function UI_CreateClub:createClub()
    local name = self.textField_name:getString()
    hallSendMgr:createClub(name, self.curIndex)
end

function UI_CreateClub:onCreateClub(data)
    -- body
    cclog("UI_CreateClub:onCreateClub")
    self:closeUI()
end

-- function UI_CreateClub:setClubIcon(id)
--     self.curIndex = id
--     local path = clubMgr:getIconPathById(id)
--     self.img_icon:loadTexture(path,1)
-- end

-- function UI_CreateClub:changeIcon()
--     cclog("UI_CreateClub:changeIcon >>>>")

--     local ui = viewMgr:show("ClubView.UI_SelectClubIcon")

--     local function callBack(id)
--         self:setClubIcon(id)
--     end

--     ui:init({curIndex = self.curIndex, callBack = callBack})


-- end


function UI_CreateClub:showIconList()
    -- body
    -- self.curIndex = ClubManager:getInfo("clubIcon")
    self.iconView:removeAllChildren()
    self.itemList = {}
    local contentSize = self.iconView:getContentSize()
    
    local data = clubMgr:getIconList()


    local num = #data
    local row = 5--排数
    local col = math.ceil(num/row)--行数
    local w, h = 155, 135
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
        local size = cc.size(w +2, h +2)
        layout:setContentSize(size)
        layout:setPosition(pos_x, pos_y)

        local item = display.newCSNode(__platformHomeDir .."ui/layout/ClubView/Item_selectIcon.csb")
        -- item:setAnchorPoint(cc.p(0,0))
        item:setPosition(size.width/2, size.height/2)
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



function UI_CreateClub:selectIcon(index)
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

-- function UI_CreateClub:sure()
--     if self.callBack then
--         self.callBack(self.curIndex)
--     end
--     self:closeUI()
-- end






return UI_CreateClub
