local UI_DeskInfo = class("UI_DeskInfo", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_DeskInfo:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_DeskInfo.csb")
    self.root:addTo(self)

    UI_DeskInfo.super.ctor(self)
    _w = self._childW
    
    self.desk = data.desk
    self:initUI()
end

function UI_DeskInfo:onExit()
    CCXNotifyCenter:unListenByObj(self)
end

function UI_DeskInfo:onEnter()

end

function UI_DeskInfo:onUIClose()
    self:removeFromParent()
end



function UI_DeskInfo:initUI()
    local data = self.desk.data
    print_r(data)
     
    if data.roomOwnerID == PlayerInfo.playerUserID or ClubManager:isGuanliyuan() then
        _w["btn_jiesan"]:setVisible(true)
        _w["btn_queding"]:setVisible(false)
    else
        _w["btn_jiesan"]:setVisible(false)
        _w["btn_queding"]:setVisible(true)
    end


    _w["txt_roomId"]:setString(string.format("%s", data.id))
    _w["txt_playerNumb"]:setString(string.format("%s/%s人", data.curPeopleNum, data.maxPeopleNum))
    _w["txt_ju"]:setString(string.format("%s/%s局", data.finishRoundNum, data.roundNum))
    GlobalFun:uiTextCut(_w["txt_kouName"])
    _w["txt_kouName"]:setString(string.format("%s", data.roomOwnerName))

    _w["txt_kouId"]:setString(string.format("(ID:%s)", data.roomOwnerID))
    _w["txt_chuangName"]:setString(string.format("%s", data.startDeskUserName))
    GlobalFun:uiTextCut(_w["txt_chuangName"])
    _w["txt_chuangId"]:setString(string.format("(ID:%s)", data.startDeskUserID))

    for i=1, 4 do
        local info = data.playerTb[i]
        if info then
            local icon = ex_fileMgr:loadLua("app.views.club.PlayerIcon").new()
            icon:setScale(0.6)
            icon:setClickEnable(false)
            _w["icon" .. i]:addChild(icon)
            local size = _w["icon" .. i]:getContentSize()
            icon:setPosition(size.width/2, size.height/2)
            GlobalFun:uiTextCut(_w["txt_name" .. i])
            _w["txt_name" .. i]:setString(info.playerName)
            _w["txt_id" .. i]:setString("ID:" .. info.playerID)
        else
            _w["icon" .. i]:setVisible(false)
        end
    end
end

function UI_DeskInfo:onClick(_sender)
    local name = _sender:getName()
    if name == "btn_queding" or name == "btn_close" then
        self:onUIClose()
    elseif name == "btn_jiesan" then
        self:jiesan()
    end
end

function UI_DeskInfo:jiesan()
    

    local function cb ()
         ex_clubHandler:dismissRoom(self.desk.data.id, self.desk.data.roomOwnerID)
        self:onUIClose()
     end
     ClubGlobalFun:showError(string.format("你要解散房间【%s】吗？", tostring(self.desk.data.id)),cb,nil,2)
end

return UI_DeskInfo