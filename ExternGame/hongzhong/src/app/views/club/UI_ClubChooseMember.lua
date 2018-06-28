
local UI_ClubChooseMember = class("UI_ClubChooseMember", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_ClubChooseMember:ctor(data)
    self.app = data.app
    self.memberData = data
    self.root = display.newCSNode("club/UI_ClubChooseMember.csb")
    self.root:addTo(self)
    
	UI_ClubChooseMember.super.ctor(self)
	_w = self._childW

	self:initUI()
	self:setMainUI()
end

function UI_ClubChooseMember:onEnter()
	-- body
	self.synchronousData = {}
	self.checkMan = {}
	self.chooseLimit = 5

	self.memberList:removeAllItems()
	self.txt_cNum:setString("(0/5)")
end

function UI_ClubChooseMember:onExit()
    CCXNotifyCenter:unListenByObj(self)
    
end

function UI_ClubChooseMember:update(dt)

end


function UI_ClubChooseMember:initUI()
	-- body
	self.title = _w["title"]
	self.txt_cNum = _w["txt_cNum"]
	self.memberList = _w["memberList"]

end

--主设置
function UI_ClubChooseMember:setMainUI()


end


function UI_ClubChooseMember:onClick(_sender)
	local name = _sender:getName()
	cclog("UI_ClubChooseMember:onClick name:"..name)
	if name == "btn_back" then
		self:_closeUI()
	elseif name == "btn_sure" then
		self:submit()
	end
end

function UI_ClubChooseMember:onTouch(_sender, _type)
	local name = _sender:getName()
--	cclog("UI_ClubChooseMember:onTouch name:"..name.."  _type:".._type)

end

function UI_ClubChooseMember:onListViewEvent(_sender, _type)
	local name = _sender:getName()
	--cclog("UI_ClubChooseMember:onListViewEvent name:"..name.."  _type:".._type)

end

function UI_ClubChooseMember:updateCheckCNum(_tag, _status)
	if _tag ~= nil and _status ~= nil then
		local lineData = self.synchronousData[_tag]
		if lineData == nil then return end
		if _status == true then
			self.checkMan[lineData.userID] = lineData
		else
			self.checkMan[lineData.userID] = nil
		end
	end
	local len = ClubGlobalFun:getLenForTb(self.checkMan)
	self.txt_cNum:setString("("..len.."/"..self.chooseLimit..")")
end

function UI_ClubChooseMember:isCanAddMember()
	local len = ClubGlobalFun:getLenForTb(self.checkMan)
	return len < self.chooseLimit
end

function UI_ClubChooseMember:setList(_tb)
	for i, v in ipairs(_tb) do
		self:pushMsg(self.memberList, v)
	end

end

function UI_ClubChooseMember:pushMsg(_listView, _lineData)

	local layout = ccui.Layout:create()
	local item = display.newCSNode("club/Item_chooseMember.csb")
	layout:setContentSize(cc.size(1100, 100))
    item:addTo(layout)

    local tag = self:getTag()
    self.synchronousData[tag] = self:copyTable(_lineData)
    layout:setTag(tag)
	layout:setTouchEnabled(true)
	layout:setSwallowTouches(false)
	layout:setAnchorPoint(cc.p(0, 0))

	--[[
	layout:addTouchEventListener(function(sender, type)
    	if type == 2 then
        	cclog("item type:"..type.. "   tag:"..sender:getTag())
        	local data = self.synchronousData[tag]
        	if data ~= nil then
        		print_r(data)
			    
        	else
        		cclog("数据为空,有问题!")
        	end
        end
    end)
	--]]

    local _itemW = self:loadChildrenWidget(item)
    --头像响应事件
    _itemW["icon"]:setTag(tag)
    _itemW["icon"]:setTouchEnabled(true)
    _itemW["icon"]:addTouchEventListener(function(sender, type)
    	if type == 0 then
    		
        elseif type == 2 then
        
        elseif type == 3 then
        	
        end
    end)

    --勾选框响应事件
    _itemW["check"]:setTag(tag)
    _itemW["check"]:setTouchEnabled(true)
    _itemW["check"]:addTouchEventListener(function(sender, type)
    	if type == 0 then
    		
        elseif type == 2 or type == 3 then
        	local tag = sender:getTag()
     		local status = sender:getSelected()
     		if status == true and self:isCanAddMember() == true then
	     		self:updateCheckCNum(tag, status)
	     	elseif status == true and self:isCanAddMember() == false then
	     		sender:setSelected(false)
	     		GlobalFun:showToast("超过限定人数,最多只能选择"..self.chooseLimit.."人", 2)
	     	elseif status == false then
	     		self:updateCheckCNum(tag, status)
	     	end
        end
    end)

    _itemW["name"]:setString(_lineData.userName)
	
 
    local iconSize = _itemW["icon"]:getContentSize()
    local icon = ex_fileMgr:loadLua("app.views.club.PlayerIcon").new()
    _itemW["node_icon"]:addChild(icon)

    local _itemW2 = self:loadChildrenWidget(icon:getRootView())
    _itemW2["defaultIcon"]:loadTexture("image2/club/icon/defaultIcon.png")
    _itemW2["icon"]:loadTexture("image2/club/icon/defaultIcon.png")
    _itemW2["defaultIcon"]:setContentSize(iconSize.width, iconSize.height)
    _itemW2["icon"]:setContentSize(iconSize.width + 10, iconSize.height + 10)
    _itemW2["panel"]:setTouchEnabled(false)
    icon:setIcon(_lineData.userID, _lineData.userIcon)

	_listView:pushBackCustomItem(layout)
	_listView:jumpToBottom()

end

--关闭ui
function UI_ClubChooseMember:_closeUI()
	--处理一些消息

	self:closeUI()
end

--发送消息
function UI_ClubChooseMember:submit()
	if self.memberData ~= nil and self.memberData.callFunc ~= nil then
		self.memberData.callFunc(self.checkMan)
	end
	self:_closeUI()
end

return UI_ClubChooseMember
