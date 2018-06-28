

local UI_SelectClubIcon = class("UI_SelectClubIcon", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_SelectClubIcon:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_SelectClubIcon.csb")
    self.root:addTo(self)

    UI_SelectClubIcon.super.ctor(self)
    _w = self._childW
    
    self.curIndex = ClubManager:getInfo("clubIcon")
    self.callBack = data.callBack  
    self:initUI()
    self:setMainUI()
end

function UI_SelectClubIcon:initUI()
    -- body
    self.iconView = _w["iconView"]
end

function UI_SelectClubIcon:setMainUI()
    -- body
    self.iconView:removeAllChildren()
    self.itemList = {}
    local contentSize = self.iconView:getContentSize()
    local data = ClubManager.iconTable
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
            pos_x = -5
            pos_y = pos_y - offset_y -10
        else
            pos_x = pos_x + offset_x
        end
        uiIndex = uiIndex + 1

        local layout = ccui.Layout:create()
        local size = cc.size(w +2, h +2)
        layout:setContentSize(size)
        layout:setPosition(pos_x, pos_y)

        local item = display.newCSNode("club/Item_selectIcon.csb")
        local _itemW = self:loadChildrenWidget(item)
        item:setPosition(size.width/2, size.height/2)
        item:addTo(layout)

        local info = data[index]
        if tonumber(info.id) == tonumber(self.curIndex) then
            _itemW["select"]:setVisible(true)
        else
            _itemW["select"]:setVisible(false)
        end
        _itemW["img"]:loadTexture(info.v, 1)
        _itemW["img"]:setTouchEnabled(true)
        _itemW["img"]:addClickEventListener(function() self:selectIcon(info.id) end)
        self.iconView:addChild(layout)
        self.itemList[#self.itemList+1] = {id = info.id, w = _itemW}
    end

    local innerSize = self.iconView:getInnerContainer():getContentSize()
    self.iconView:setInnerContainerSize(cc.size(innerSize.width,totalHeight))
end

function UI_SelectClubIcon:onEnter()

 
end

function UI_SelectClubIcon:onExit()
    
end

function UI_SelectClubIcon:onUIClose()
    --self:removeFromParent()
end

function UI_SelectClubIcon:selectIcon(index)
    -- body
    self.curIndex = index
    cclog("selectIcon = ", index)
    for i=1,#self.itemList do
        local d = self.itemList[i]
        if d.id == index then
            d.w["select"]:setVisible(true)
        else
            d.w["select"]:setVisible(false)
        end
    end
end

function UI_SelectClubIcon:onClick(_sender)
	local name = _sender:getName()
    if name == "btn_close" then
        self:closeUI()
    elseif name == "btn_sure" then
        if self.callBack then
            cclog("callBack has exist")
            if self.callBack(self.curIndex) then
                self:closeUI()
            end
        else
            self:closeUI()
        end
    end
end

return UI_SelectClubIcon
