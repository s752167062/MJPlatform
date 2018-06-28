

local UI_SystemMsg = class("UI_SystemMsg", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_SystemMsg:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_SystemMsg.csb")
    self.root:addTo(self)

    UI_SystemMsg.super.ctor(self)
    _w = self._childW
    
  
end

function UI_SystemMsg:onEnter()

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

function UI_SystemMsg:update(t)
    
end

function UI_SystemMsg:onExit()
    
end

function UI_SystemMsg:onUIClose()
    --self:removeFromParent()
end

function UI_SystemMsg:onClick(_sender)
	local name = _sender:getName()
	if name == "btn_close" then
		
	end
end

function UI_SystemMsg:onTouch(_sender, _type)
	
end

--主设置
function UI_SystemMsg:setMainUI()
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
	
	_w["content"]:setString()
	
	
end

return UI_SystemMsg
