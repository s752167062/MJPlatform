

local UI_ClubMsgHistory = class("UI_ClubMsgHistory", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_ClubMsgHistory:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_ClubMsgHistory.csb")
    self.root:addTo(self)

	UI_ClubMsgHistory.super.ctor(self)
	_w = self._childW
  
  	self.curIndex = 0
	self:initUI()
	self:setMainUI()
end

function UI_ClubMsgHistory:initUI()
	-- body
	self.btn_renyuan = _w["btn_renyuan"]
	self.btn_fangka  = _w["btn_fangka"]
	self.img_shuyu1 = _w["img_shuyu1"]
	self.img_shuyu2 = _w["img_shuyu2"]
	self.fangkaList = _w["fangkaList"]
	self.renyuanList = _w["renyuanList"]
end

function UI_ClubMsgHistory:setMainUI()
	self:onClickBtnIndex(self.curIndex)
end

function UI_ClubMsgHistory:update(t)
    
end

function UI_ClubMsgHistory:onUIClose()
    self:removeFromParent()
end

function UI_ClubMsgHistory:onClick(_sender)
	local name = _sender:getName()
	if name == "btn_close" then
		self:onUIClose()
	elseif name == "" then	--查询
	
	elseif name == "btn_renyuan" then	--人员流动信息
		self:onClickBtnIndex(0)
	elseif name == "btn_fangka" then	--房卡消耗信息
		self:onClickBtnIndex(1)
	elseif name == "" then	--上翻页
	
	elseif name == "" then	--下翻页
	
	end
end

function UI_ClubMsgHistory:onClickBtnIndex(index)
	-- body
	index = index or 0
	self.curIndex = index
	if index == 0 then
		self.btn_renyuan:setEnabled(false)
		self.btn_fangka:setEnabled(true)
		self.img_shuyu1:setVisible(true)
		self.img_shuyu2:setVisible(false)
		self.renyuanList:setVisible(true)
		self.fangkaList:setVisible(false)
		self:resetRenyuanMsgList()
	else
		self.btn_renyuan:setEnabled(true)
		self.btn_fangka:setEnabled(false)
		self.img_shuyu1:setVisible(false)
		self.img_shuyu2:setVisible(true)
		self.renyuanList:setVisible(false)
		self.fangkaList:setVisible(true)
	end
end

function UI_ClubMsgHistory:resetRenyuanMsgList()
	-- body
	local listview = self.renyuanList
    listview:removeAllItems()

    for index = 1, 10 do
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(620,40))

        local item = display.newCSNode("club/Item_lishixiaoxi.csb")
        item:setPosition(cc.p(0,0))
        item:setTag(668)
        item:addTo(layout)

        local desc = item:getChildByName("desc")
        listview:pushBackCustomItem(layout)
    end
end


function UI_ClubMsgHistory:onTouch(_sender, _type)
	
end

return UI_ClubMsgHistory
