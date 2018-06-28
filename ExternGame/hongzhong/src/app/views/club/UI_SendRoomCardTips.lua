
local UI_SendRoomCardTips = class("UI_SendRoomCardTips", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

function UI_SendRoomCardTips:ctor(data)
    self.app = data.app
    self.data = data.data
    self.root = display.newCSNode("club/UI_SendRoomCardTips.csb")
    self.root:addTo(self)

	UI_SendRoomCardTips.super.ctor(self)
    _w = self._childW
    
	self:initUI()
	self:setMainUI()
end

function UI_SendRoomCardTips:initUI()
	self.btn_close    		= _w["btn_close"]
	self.btn_left    		= _w["btn_left"]
	self.btn_right    		= _w["btn_right"]
	self.playIcon     		= _w["playIcon"]
	self.node_icon			= _w["node_icon"]
	self.playName    		= _w["playName"]
	self.playID    			= _w["playID"]
	self.input_num    		= _w["input_num"]

end

function UI_SendRoomCardTips:setMainUI()
	--CCXNotifyCenter:listen(self,function(obj,key,data) self:res_onRoomCardRecord(data) end, "S2C_onRoomCardRecord")
	print_r(self.data)
	--self.playIcon:setVisible(false)
	self.playName:setString(self.data.name)
	self.playID:setString(self.data.userID)
	self.input_num:setString("")

	local icon = ex_fileMgr:loadLua("app.views.club.PlayerIcon").new()
    self.node_icon:addChild(icon)
    icon:setIcon(self.data.userID, self.data.icon)

end


function UI_SendRoomCardTips:onEnter()


end

function UI_SendRoomCardTips:onExit(  )
	CCXNotifyCenter:unListenByObj(self)
end

function UI_SendRoomCardTips:onClick(_sender)
    -- body
    local name = _sender:getName()
    if name == "btn_close" then   
        self:closeUI()
    elseif name == "btn_left" then
    	local function sure( ... )
    		cclog("self:submit()")
    		self:submit()
    	end
    	local function cancel( ... )
    		-- body
    	end
    	local num = self.input_num:getString()
    	ClubGlobalFun:showError("是否对昵称:"..self.data.name..", ID:"..self.data.userID.." 发送"..num.."房卡", sure, cancel, 2)
 
    elseif name == "btn_right" then
    	self:closeUI()
    end
end

--提交请求
function UI_SendRoomCardTips:submit()
	local num = self.input_num:getString()
	cclog("submit num:"..num)
	local ret = tonumber(num)
	if ret ~= nil and ret > 0 then
		cclog("submit ret:"..ret)
		local clubID = ClubManager:getClubID()
        ex_clubHandler:toSendRoomCard(clubID, self.data.userID, ret)
    else
    	GlobalFun:showToast("格式错误，请正确填写大于0的数字", 3)
	end
end

function UI_SendRoomCardTips:checkRoomCardRecord(_index)
	cclog("_index:".._index)

end

return UI_SendRoomCardTips
