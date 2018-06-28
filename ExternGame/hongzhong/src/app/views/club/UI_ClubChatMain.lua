
local UI_ClubChatMain = class("UI_ClubChatMain", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_ClubChatMain:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_ClubChatMain.csb")
    self.root:addTo(self)
    
	UI_ClubChatMain.super.ctor(self)
	_w = self._childW

	self:initUI()
	self:setMainUI()
end

function UI_ClubChatMain:onEnter()
	-- body

	self.test = 0

end

function UI_ClubChatMain:onExit()
    CCXNotifyCenter:unListenByObj(self)
    
end

function UI_ClubChatMain:update(dt)

end


function UI_ClubChatMain:initUI()
	-- body
	self.img_clubIcon    = _w["img_clubIcon"]

end

--主设置
function UI_ClubChatMain:setMainUI()


end


function UI_ClubChatMain:onClick(_sender)
	local name = _sender:getName()
	cclog("UI_ClubChatMain:onClick name:"..name)
	if name == "btn_close" or name == "btn_back" then

	end
end

function UI_ClubChatMain:onTouch(_sender, _type)
	local name = _sender:getName()
--	cclog("UI_ClubChatMain:onTouch name:"..name.."  _type:".._type)
	if _type == 2 and name == "RoomCard_panel" then
		_w["RoomCard_panel"]:setVisible(false)
	end
end

function UI_ClubChatMain:onListViewEvent(_sender, _type)
	local name = _sender:getName()
	--cclog("UI_ClubChatMain:onListViewEvent name:"..name.."  _type:".._type)

end



return UI_ClubChatMain
