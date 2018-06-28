

local UI_SelectFace = class("UI_SelectFace", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_SelectFace:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_SelectFace.csb")
    self.root:addTo(self)

    UI_SelectFace.super.ctor(self)
    _w = self._childW
    
  
end

function UI_SelectFace:onEnter()
	self:setMainUI()
	
end

function UI_SelectFace:update(t)
    
end

function UI_SelectFace:onExit()
    
end

function UI_SelectFace:onUIClose()
    --self:removeFromParent()
end

function UI_SelectFace:onClick(_sender)
	local name = _sender:getName()
	if name == "btn_back" then
		--closeUI
		
	end
end

function UI_SelectFace:onTouch(_sender, _type)
	
end

--主设置
function UI_SelectFace:setMainUI()
	-- self.roundCount = UserDefault:getKeyValue("CURoundCount",self.roundCount)
   
    --local ctn_close = self.root:getChildByName("bg"):getChildByName("btn_close")
    --ctn_close:addClickEventListener(function() self:onUIClose() end)

	--[[
    self.updata_t = -1
    local function handler(t)
        self:update(t)
    end
    self:scheduleUpdateWithPriorityLua(handler,0)
    --]]
	
	
end

return UI_SelectFace
