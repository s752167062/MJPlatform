

local UI_xialaxuanze = class("UI_xialaxuanze", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_xialaxuanze:ctor(data)
    self.data = data
    self.root = display.newCSNode("club/UI_xialaxuanze.csb")
    self.root:addTo(self)

	UI_xialaxuanze.super.ctor(self)
	_w = self._childW
    
    self.callBack = data.callBack
  	self:initUI()
    self:initList()
end

function UI_xialaxuanze:initUI()
	-- body
    self.mask = _w["mask"]
    self.mask:setTouchEnabled(true)
    self.mask:addClickEventListener(function() self:onClick(self.mask) end)

    self.more_node = _w["more_node"]
	self.selectBtnList = _w["selectBtnList"]
    self.more_bg = _w["more_bg"]
    self.more_jiantou = _w["more_jiantou"]
end

function UI_xialaxuanze:initList()
	-- body
    --dump(self.data, "data")

    self.more_node:setPosition(self.data.posx, self.data.posy)
    local row = self.data.row--排数
    local col = math.ceil(#self.data.list/row)--行数
    local w = self.data.w
    local h = self.data.h
    local totalWidth = self.data.w * row--总宽度
    local totalHeight = self.data.h * col--总高度


    local h2 = (col >= 3) and (3 * h) or totalHeight 
    self.selectBtnList:setContentSize(totalWidth, h2)
    local uiIndex = 0
    local offset_x, offset_y = w, h
    local pos_x, pos_y = 0, totalHeight

    cclog("wtf self.data.curIndex:"..self.data.curIndex)

    for index=1,#self.data.list do
        if uiIndex%row == 0  then
            pos_x = 0 
            pos_y = pos_y - offset_y
        else
            pos_x = pos_x + offset_x
        end
        uiIndex = uiIndex + 1
        local item = display.newCSNode("club/Item_selectbtn.csb")
        item:setPosition(cc.p(pos_x,pos_y))

        local info = self.data.list[index]
        local btn = item:getChildByName("btn")

        --选中的按钮背景特殊设置
        --btn:loadTextureNormal("club/btn/btn_area1.png")
        if self.data.curIndex ~= nil and self.data.curIndex == index then
            btn:loadTextureNormal("image2/club/btn/btn_area.png")
        else
            btn:loadTextureNormal("image2/club/btn/btn_area2.png")
        end

        btn:setTitleText(info.v)
        btn:addClickEventListener(function() self:selectBtn(info.id) end)
        btn:setContentSize(w-20, h-10)
        self.selectBtnList:addChild(item)
    end
    
    local innerSize = self.selectBtnList:getInnerContainer():getContentSize()
    self.selectBtnList:setInnerContainerSize(cc.size(totalWidth,totalHeight))

    self.more_jiantou:setPosition(totalWidth*0.5, 0)
    self.more_bg:setContentSize(totalWidth+20, h2+20)
end

function UI_xialaxuanze:onUIClose()
    self:removeFromParent()
end

function UI_xialaxuanze:selectBtn(index)
    -- body
    if self.callBack then
        self.callBack(index)
    end
    self:onUIClose()
end

function UI_xialaxuanze:onClick(_sender)
    local name = _sender:getName()
    if name == "mask" then
        self:onUIClose()
    end
end

function UI_xialaxuanze:onTouch(_sender, _type)
    
end

return UI_xialaxuanze
