

local UI_SwitchClub = class("UI_SwitchClub", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_SwitchClub:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_SwitchClub.csb")
    self.root:addTo(self)

    UI_SwitchClub.super.ctor(self)
    _w = self._childW
    
  
end

function UI_SwitchClub:onEnter()
	self:setMainUI()
	
end

function UI_SwitchClub:update(t)
    
end

function UI_SwitchClub:onExit()
    
end

function UI_SwitchClub:onUIClose()
    --self:removeFromParent()
end

function UI_SwitchClub:onClick(_sender)
	local name = _sender:getName()
	if name == "btn_back" then
		--closeUI
		
	end
end

function UI_SwitchClub:onTouch(_sender, _type)
	
end

--主设置
function UI_SwitchClub:setMainUI()
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


return UI_SwitchClub
