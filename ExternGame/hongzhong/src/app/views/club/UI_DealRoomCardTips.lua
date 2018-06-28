
local UI_DealRoomCardTips = class("UI_DealRoomCardTips", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

function UI_DealRoomCardTips:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_DealRoomCardTips.csb")
    self.root:addTo(self)

	UI_DealRoomCardTips.super.ctor(self)
    _w = self._childW
    
	self:initUI()
	self:setMainUI()
end

function UI_DealRoomCardTips:initUI()
	self.btn_close    		= _w["btn_close"]
	self.btn_left    		= _w["btn_left"]
	self.btn_right    		= _w["btn_right"]
	self.playIcon     		= _w["playIcon"]
	self.playName    		= _w["playName"]
	self.playID    			= _w["playID"]
	self.targetClubName    	= _w["targetClubName"]
	self.targetPlayName    	= _w["targetPlayName"]
	self.content 			= _w["content"]

end

function UI_DealRoomCardTips:setMainUI()
	--CCXNotifyCenter:listen(self,function(obj,key,data) self:res_onRoomCardRecord(data) end, "S2C_onRoomCardRecord")
	
	self.playName:setString("")
	self.playID:setString("")
	self.targetClubName:setString("【xxxxx】")
	self.targetPlayName:setString("【xxxxx】")
	self.content:setString("正在申请0张房卡，请及时处理。")

end


function UI_DealRoomCardTips:onEnter()


end

function UI_DealRoomCardTips:onExit(  )
	CCXNotifyCenter:unListenByObj(self)
end

function UI_DealRoomCardTips:onClick(_sender)
    -- body
    local name = _sender:getName()
    if name == "btn_close" then   
        self:closeUI()
    elseif name == "btn_left" then
    	self:submit()
    elseif name == "btn_right" then
    	
    end
end

--提交请求
function UI_DealRoomCardTips:submit()
	
end

function UI_DealRoomCardTips:checkRoomCardRecord(_index)
	cclog("_index:".._index)

end

return UI_DealRoomCardTips
