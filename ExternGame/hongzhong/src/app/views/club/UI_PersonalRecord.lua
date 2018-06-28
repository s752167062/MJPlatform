

local UI_PersonalRecord = class("UI_PersonalRecord", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_PersonalRecord:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_PersonalRecord.csb")
    self.root:addTo(self)

	UI_PersonalRecord.super.ctor(self)
	_w = self._childW
  

  
  
end

function UI_PersonalRecord:onEnter()
	self:setMainUI()
	
end

-- function UI_PersonalRecord:update(t)
    
-- end

function UI_PersonalRecord:onExit()
    CCXNotifyCenter:unListenByObj(self)
end


function UI_PersonalRecord:onClick(_sender)
	local name = _sender:getName()
	if name == "btn_close" then
        self:closeUI()
	elseif name == "btn_down" then	--下拉
		local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubExit")
        scene:addChild(ui.new({app = nil}))
	elseif name == "btn_buy" then	--商城购买
		-- cclog("打开商店界面")
  --   	local ui = ex_fileMgr:loadLua("app.views.ShopUI")
  --   	self.root:addChild(ui.new())
	elseif name == "btn_share" then	--分享俱乐部

	elseif name == "btn_help" then	--btn_help
	
	end
end

function UI_PersonalRecord:onTouch(_sender, _type)
	
end

--主设置
function UI_PersonalRecord:setMainUI()

	
	self.list_view = _w["list_view"]
  	self.node_head = _w["node_head"]
  	self.txt_name = _w["txt_name"]
  	self.txt_id = _w["txt_id"]
  	self.txt_fangka = _w["txt_fangka"]
	
  	local icon = ex_fileMgr:loadLua("app.views.club.PlayerIcon").new()
    self.node_head:addChild(icon)
    icon:setIcon(PlayerInfo.playerUserID, PlayerInfo.headimgurl)

	self.txt_name:setString(PlayerInfo.nickname)
	self.txt_id:setString(PlayerInfo.playerUserID)
	self.txt_fangka:setString(GlobalData.CartNum)
end

return UI_PersonalRecord
