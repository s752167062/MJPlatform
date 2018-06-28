local VoteUiPlayerInfo = class("VoteUiPlayerInfo", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

VoteUiPlayerInfo.RESOURCE_FILENAME = "VoteUiPlayerInfo.csb"
VoteUiPlayerInfo.RESOURCE_BINDING = {
    -- ["btn_cancel"]       = {    ["varname"] = "btn_cancel"     ,  ["events"] = { {event = "click" ,  method ="onNotAgree"        } }     },


    ["icon_bg"]       = {    ["varname"] = "icon_bg"      },
    ["line_state"]       = {    ["varname"] = "line_state"      },
    ["sel_state"]       = {    ["varname"] = "sel_state"      },
    ["sel_state_img"]       = {    ["varname"] = "sel_state_img"      },
    ["name"]       = {    ["varname"] = "name"     },
    ["name_mask"]       = {    ["varname"] = "name_mask"     },
}

function VoteUiPlayerInfo:onCreate()

    self.root = self:getResourceNode()
end

function VoteUiPlayerInfo:initParams(params)
	local player_info = params.player_info
	self.player_info = player_info
	self:setInitInfo(player_info)

	CCXNotifyCenter:listen(self,function(obj,key,data) 
			if player_info.openid == data.userid then
				local isLine = data.flag == 1
				cclog("CCXNotifyCenter:listen onNotifyUserOnAnOff_notify >>>>")
				obj:setLineState(isLine)
			end
		end,"onNotifyUserOnAnOff_notify")
end


function VoteUiPlayerInfo:onEnter()
end

function VoteUiPlayerInfo:onExit()
	-- self:unregisterScriptHandler()
	CCXNotifyCenter:unListenByObj(self)
end


function VoteUiPlayerInfo:setInitInfo(player_info)
	self:setName(player_info.name)
	self:setLineState(player_info.isLine == 1)
	self:setPicture(player_info.id)

end

function VoteUiPlayerInfo:setName(name)
	self.name:setString(name or "")
	local mask_size = self.name_mask:getContentSize()
	local name_size = self.name:getContentSize()
	if name_size.width > mask_size.width then
		self.name:setAnchorPoint(cc.p(0, 0.5))
		self.name:setPositionX(0)
	else
		self.name:setAnchorPoint(cc.p(0.5, 0.5))
		self.name:setPositionX(mask_size.width/2)
	end
end

function VoteUiPlayerInfo:setLineState(isOnLine)
	if isOnLine then
		self.line_state:setColor(cc.c3b(255,139,96))
		self.line_state:setString("在线")
	else
		self.line_state:setColor(cc.c3b(198,198,198))
		self.line_state:setString("离线中")
	end
end

function VoteUiPlayerInfo:setAgreeState(isAgree)
	if isAgree then
		self.sel_state:setColor(cc.c3b(144,238,144))
		self.sel_state:setString("同意")
		
		self.sel_state:setVisible(false)
		self.sel_state_img:setVisible(true)
	else
		self.sel_state:setColor(cc.c3b(255,0,0))
		self.sel_state:setString("不同意")

		self.sel_state:setVisible(true)
		self.sel_state_img:setVisible(false)
	end
	--self.sel_state:setVisible(true)
end


function VoteUiPlayerInfo:setPicture(id)
	local filename = id .. "icon.png"
	local path = ex_fileMgr:getWritablePath().."/".. filename
	cc.Director:getInstance():getTextureCache():reloadTexture(path)
	local headsp = cc.Sprite:create(path)
	if headsp then

		-- local size = self.icon_bg:getContentSize()
		-- local tmp_size = headsp:getContentSize()
		-- headsp:setScale(size.width/tmp_size.width)
		-- headsp:setPosition(cc.p(size.width/2, size.height/2))

		GlobalFun:modifyAddNewIcon(self.icon_bg, headsp, 10, 10, "baseicon")
		self.icon_bg:addChild(headsp)
	end
end

return VoteUiPlayerInfo








