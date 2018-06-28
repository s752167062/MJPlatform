

local UI_CreateClubFail = class("UI_CreateClubFail", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_CreateClubFail:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_CreateClubFail.csb")
    self.root:addTo(self)

    UI_CreateClubFail.super.ctor(self)
    _w = self._childW
    
    self.msg = data.msg or ""
    self.callBack = data.callBack
    self:initUI()
    self:setMainUI()
end

function UI_CreateClubFail:initUI()
    -- body
    self.txt_content = _w["txt_content"]
end

--主设置
function UI_CreateClubFail:setMainUI()
   self.txt_content:setString(self.msg)
end

function UI_CreateClubFail:onEnter()

end

function UI_CreateClubFail:onExit()
    
end

function UI_CreateClubFail:onUIClose()
    self:removeFromParent()
end

function UI_CreateClubFail:onClick(_sender)
	local name = _sender:getName()
    if name == "btn_close" then
        self:closeUI()
    elseif name == "btn_sure" then
        self:closeUI()
    end  
end

return UI_CreateClubFail
