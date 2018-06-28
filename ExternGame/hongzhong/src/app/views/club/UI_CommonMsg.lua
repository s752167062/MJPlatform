 

local UI_CommonMsg = class("UI_CommonMsg", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_CommonMsg:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_CommonMsg.csb")
    self.root:addTo(self)

	UI_CommonMsg.super.ctor(self)
	_w = self._childW
	
	self:initUI(data)
  	self:setMainUI()

end

function UI_CommonMsg:update(t)
    
end

function UI_CommonMsg:onUIClose()
    --self:removeFromParent()
end

function UI_CommonMsg:onClick(_sender)
	local name = _sender:getName()
	if name == "btn_close" then
		self:closeUI()
	elseif name == "btn_sure" then
	
	elseif name == "btn_cancel" then
	
	elseif name == "btn_ok" then
	
	end
end

function UI_CommonMsg:onTouch(_sender, _type)
	
end

function UI_CommonMsg:initUI(_data)
	local txt_info = self.root:findChildByName("txt_info")
    txt_info:setString(_data.err)
    local rlabel = txt_info:getVirtualRenderer()
    rlabel:setLineBreakWithoutSpace(true)
    
    self.root:getChildByName("ctn_01"):setVisible(1 == _data.flag)
    self.root:getChildByName("ctn_02"):setVisible(2 == _data.flag)
    self.ok = _data.ok
    self.cancel = _data.cancel
    
    self.root:getChildByName("ctn_01"):getChildByName("btn_01"):addClickEventListener(function() self:onSure() end)
    self.root:getChildByName("ctn_02"):getChildByName("btn_02"):addClickEventListener(function() self:onSure() end)
    self.root:getChildByName("ctn_02"):getChildByName("btn_03"):addClickEventListener(function() self:onCancel() end)
end

--主设置
function UI_CommonMsg:setMainUI()
	
end

function UI_CommonMsg:onSure()
    if self.ok then
        self.ok()
    end
    
    self:removeFromParent()
end

function UI_CommonMsg:onCancel()
    if self.cancel then
        self.cancel()
    end
    self:removeFromParent()
end

return UI_CommonMsg

--[[
function CUIMsgError:ctor(data)
    self.root = display.newCSNode("common/CUIMsgError.csb")
    self.root:addTo(self)
    
    self.root:getChildByName("base"):getChildByName("txt_info"):setString(data.err)
    local rlabel = self.root:getChildByName("base"):getChildByName("txt_info"):getVirtualRenderer()
    rlabel:setLineBreakWithoutSpace(true)
    
    self.root:getChildByName("ctn_01"):setVisible(1 == data.flag)
    self.root:getChildByName("ctn_02"):setVisible(2 == data.flag)
    self.ok = data.ok
    self.cancel = data.cancel
    
    self.root:getChildByName("ctn_01"):getChildByName("btn_01"):addClickEventListener(function() self:onSure() end)
    self.root:getChildByName("ctn_02"):getChildByName("btn_02"):addClickEventListener(function() self:onSure() end)
    self.root:getChildByName("ctn_02"):getChildByName("btn_03"):addClickEventListener(function() self:onCancel() end)
    
end

function CUIMsgError:onSure()
    if self.ok then
        self.ok()
    end
    
    self:removeFromParent()
end

function CUIMsgError:onCancel()
    if self.cancel then
        self.cancel()
    end
    self:removeFromParent()
end
--]]