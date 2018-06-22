local XinxiUI = class("XinxiUI",cc.load("mvc").ViewBase)

XinxiUI.RESOURCE_FILENAME =  __platformHomeDir .."ui/layout/OtherView/XinxiUI.csb"
XinxiUI.RESOURCE_BINDING = {
    ["ScrollView"] 	= {		["varname"] = "ScrollView" },
    ["btn_close"]   = {     ["varname"] = "btn_close"   ,  ["events"] = { {event = "click" ,  method ="onClose"  } }   },
}

function XinxiUI:onCreate()
    eventMgr:registerEventListener("onMSGData",handler(self,self.setText),"hallSendMgr")
    hallSendMgr:msgData()--大厅房卡消息
    self.text = cc.Label:createWithTTF("","AppPlatform/ui/font/LexusJianHei.TTF",17)
	self.text:setColor(cc.c3b(125,61,31))
    self.text:setAnchorPoint(cc.p(0,1))
    self.ScrollView:addChild(self.text,100)--添加到scrollview
    self.text:setLineHeight(24)
	self.text:setWidth(760)

	self.scrollView_size = self.ScrollView:getContentSize()
end

function XinxiUI:onClose()
    viewMgr:close("OtherView.XinxiUI")
end

function XinxiUI:onExit()
    self:unregisterScriptHandler()--取消自身监听
    eventMgr:removeEventListenerForTarget("hallSendMgr")
end

function XinxiUI:setText(msg)
	self.text:setString(msg)
    local size = self.text:getContentSize()
    if size.height > self.scrollView_size.height then
        self.ScrollView:setInnerContainerSize(cc.size(size.width,size.height))
        self.text:setPosition(cc.p(0,size.height))
    else
    	self.ScrollView:setInnerContainerSize(cc.size(size.width,self.scrollView_size.height))
        self.text:setPosition(cc.p(0,self.scrollView_size.height))
    end
end

return XinxiUI