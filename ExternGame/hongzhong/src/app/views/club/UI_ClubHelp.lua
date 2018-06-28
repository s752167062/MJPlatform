--公告界面
local UI_ClubHelp = class("UI_ClubHelp", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_ClubHelp:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_ClubHelp.csb")
    self.root:addTo(self)
    
    UI_ClubHelp.super.ctor(self)
    _w = self._childW

    self:initUI()
    self:setMainUI()
end

function UI_ClubHelp:initUI()
	self.scrollView = _w["scrollView"]
    self.scrollView_size = self.scrollView:getContentSize()

    self.text = cc.Label:createWithTTF("","font/LexusJianHei.TTF",24)
    self.text:setColor(cc.c3b(213,172,165))
    self.text:setAnchorPoint(cc.p(0,1))
    self.scrollView:addChild(self.text,100)
    -- self.text:setLineHeight(20)
    -- self.text:setLineSpacing(10)
    self.text:setWidth(self.scrollView_size.width - 20)
end

function UI_ClubHelp:setMainUI()
    -- body
    self:showHelp()
end

function UI_ClubHelp:getStrFromFile(filePath)
	local text = ex_fileMgr:getStringFromFile(filePath)
	return text
end

function UI_ClubHelp:showHelp()
	-- body
	
	local text = ex_fileMgr:loadLua("app.Configure.text_conf")
	if text and text.club_help then
		self:setText(text.club_help.text or "")
	end
end

function UI_ClubHelp:setText(msg)
	self.text:setString(msg)
    local size = self.text:getContentSize()
    if size.height > self.scrollView_size.height then
        self.scrollView:setInnerContainerSize(cc.size(size.width,size.height))
        self.text:setPosition(cc.p(0,size.height))
    else
    	self.scrollView:setInnerContainerSize(cc.size(size.width,self.scrollView_size.height))
        self.text:setPosition(cc.p(0,self.scrollView_size.height))
    end
    self.scrollView:scrollToTop(0, false)			
end

function UI_ClubHelp:onClick(_sender)
    -- body
    local name = _sender:getName()
    if name == "btn_close" or name == "btn_ok" then   
        self:closeUI()
    end
end

return UI_ClubHelp
