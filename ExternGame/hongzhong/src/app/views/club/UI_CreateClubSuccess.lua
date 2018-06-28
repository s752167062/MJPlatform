

local UI_CreateClubSuccess = class("UI_CreateClubSuccess", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_CreateClubSuccess:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_CreateClubSuccess.csb")
    self.root:addTo(self)

    UI_CreateClubSuccess.super.ctor(self)
    _w = self._childW
    
    self.msg = data.msg or ""
    self.callBack = data.callBack
    self:initUI()
    self:setMainUI()
end

function UI_CreateClubSuccess:initUI()
    -- body
    self.txt_content = _w["txt_content"]
end

--主设置
function UI_CreateClubSuccess:setMainUI()
   self.txt_content:setString(self.msg)
end

function UI_CreateClubSuccess:onEnter()

end

function UI_CreateClubSuccess:onExit()
    
end

function UI_CreateClubSuccess:onUIClose()
    self:removeFromParent()
end

function UI_CreateClubSuccess:onClick(_sender)
	local name = _sender:getName()
    if name == "btn_close" then
        self:onUIClose()
    elseif name == "btn_enter" then
        if self.callBack then
            self.callBack()
        end
        self:onUIClose()
    elseif name == "btn_copyID" then
        local cn = ClubManager:getInfo("clubName")
        local cid = ClubManager:getClubID()
        -- local cmn = ClubManager:getInfo("clubQunzhuName")

        local data = {}
        data.msg = string.format("欢迎加入我新建的俱乐部(ID:%s)！", cid, cn)
        data.stype = "俱乐部"
        data.params = {cid, cn,GlobalData.game_product}
        local str = GlobalFun:makeCopyStr(data)
        SDKController:getInstance():copy_To_Clipboard(str or "ERR")
        GlobalFun:showToast("复制邀请成功",Game_conf.TOAST_SHORT)

    end  
end

return UI_CreateClubSuccess
