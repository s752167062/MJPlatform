

local UI_ClubRenmingliebiao = class("UI_ClubRenmingliebiao", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_ClubRenmingliebiao:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_ClubRenmingliebiao.csb")
    self.root:addTo(self)

	UI_ClubRenmingliebiao.super.ctor(self)
	_w = self._childW
  
  	self:initUI()
	self:setMainUI()
end

function UI_ClubRenmingliebiao:initUI()
	-- body
	self.renmingList = _w["renmingList"]
    self.txt_onLineNum = _w["txt_onLineNum"]
end

--主设置
function UI_ClubRenmingliebiao:setMainUI()
    self.txt_onLineNum:setString("888人")
	self:resetRenmingList()
end

function UI_ClubRenmingliebiao:resetRenmingList()
	-- body
	local listview = self.renmingList
    listview:removeAllItems()

    for index = 1, 10 do
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(872,58))

        local item = display.newCSNode("club/Item_renming.csb")
        item:setPosition(cc.p(0,0))
        item:setTag(668)
        item:addTo(layout)

        local btn_renming = item:getChildByName("btn_renming") 
        btn_renming:addClickEventListener(function() self:agree(index) end)

        listview:pushBackCustomItem(layout)
    end
end

function UI_ClubRenmingliebiao:update(t)
    
end

function UI_ClubRenmingliebiao:onUIClose()
    self:removeFromParent()
end

function UI_ClubRenmingliebiao:onClick(_sender)
	local name = _sender:getName()
	if name == "btn_close" then
		self:onUIClose()
    elseif name == "btn_tips" then

    elseif name == "btn_sousuo" then

	end
end

function UI_ClubRenmingliebiao:onTouch(_sender, _type)
	
end

return UI_ClubRenmingliebiao
