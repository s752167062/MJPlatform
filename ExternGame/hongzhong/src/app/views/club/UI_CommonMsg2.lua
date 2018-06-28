 

local UI_CommonMsg2 = class("UI_CommonMsg2", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_CommonMsg2:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_CommonMsg2.csb")
    self.root:addTo(self)

	UI_CommonMsg2.super.ctor(self)
	_w = self._childW
	
    self.socketType = data.socketType
    self.fromClubID = data.clubID
    self.fromUserID = data.userID
	self:initUI(data)

end

function UI_CommonMsg2:update(t)
    
end

function UI_CommonMsg2:onUIClose()
    --self:removeFromParent()
end

function UI_CommonMsg2:onClick(_sender)
	local name = _sender:getName()
	if name == "btn_close" then
		self:closeUI()
	elseif name == "btn_left" then
	   if self.leftFunc then self.leftFunc() end
       self:eventLeft() --暂时写死
       self:closeUI()
	elseif name == "btn_centre" then
	   if self.centreFunc then self.centreFunc() end
       self:closeUI()
	elseif name == "btn_right" then
	   if self.rightFunc then self.rightFunc() end
       self:eventRight() --暂时写死
       self:closeUI()
	end
end

function UI_CommonMsg2:onTouch(_sender, _type)
	
end

function UI_CommonMsg2:initUI(_data)
    --[[
        俱乐部:筑志游戏俱乐部(id555555)
        会长:筑志玩家xxx(id555555)
        位置:xxxxx
        诚意邀请你加入俱乐部。
    --]]
    local content = "俱乐部:%s(ID%d)\n会长:%s(ID%d)\n诚意邀请你加入俱乐部。"
    local newContent = string.format(content, _data.clubName, _data.clubID, _data.userName, _data.userID)

	self.root:getChildByName("base"):getChildByName("txt_info"):setString(newContent)
    if _data.type then
        if _data.type == 1 then     --邀请信息
            self.root:getChildByName("base"):getChildByName("title"):loadTexture("image2/club/title/title_yaoqingchengyuan.png")
        elseif _data.type == 2 then --待定
            
        end
    end
    local rlabel = self.root:getChildByName("base"):getChildByName("txt_info"):getVirtualRenderer()
    rlabel:setLineBreakWithoutSpace(true)
    
    self.root:getChildByName("ctn_01"):setVisible(1 == _data.btnType)
    --self.root:getChildByName("ctn_02"):setVisible(2 == _data.btnType)

    self.leftFunc = _data.leftFunc
    self.centreFunc = _data.centreFunc
    self.rightFunc = _data.rightFunc
end

function UI_CommonMsg2:eventLeft()  
    cclog("UI_CommonMsg2:eventLeft")
    if self.socketType == "Hall" then
        ex_hallHandler:toYaoQingJinJuLeBuTiShi(self.fromClubID, self.fromUserID, 0)
    elseif self.socketType == "Club" then
        ex_clubHandler:toYaoQingJinJuLeBuTiShi(self.fromClubID, self.fromUserID, 0)
    end
end

function UI_CommonMsg2:eventRight()
    cclog("UI_CommonMsg2:eventRight")
    if self.socketType == "Hall" then
        ex_hallHandler:toYaoQingJinJuLeBuTiShi(self.fromClubID, self.fromUserID, 1)
    elseif self.socketType == "Club" then
        ex_clubHandler:toYaoQingJinJuLeBuTiShi(self.fromClubID, self.fromUserID, 1)
    end
end

return UI_CommonMsg2
