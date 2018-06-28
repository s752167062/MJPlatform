

local UI_ClubPrivilege = class("UI_ClubPrivilege", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_ClubPrivilege:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_ClubPrivilege.csb")
    self.root:addTo(self)

    UI_ClubPrivilege.super.ctor(self)
    _w = self._childW
  
    self:setMainUI()
  
end

function UI_ClubPrivilege:update(t)
    
end

function UI_ClubPrivilege:onUIClose()
    --self:removeFromParent()
end

function UI_ClubPrivilege:onClick(_sender)
	local name = _sender:getName()

    if name == "btn_close" then
        self:closeUI()
    end    
end

function UI_ClubPrivilege:onTouch(_sender, _type)
	
end


--主设置
function UI_ClubPrivilege:setMainUI()

    
end

return UI_ClubPrivilege
