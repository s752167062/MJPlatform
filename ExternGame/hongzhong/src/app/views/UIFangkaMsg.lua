local UIFangkaMsg = class("UIFangkaMsg",ex_fileMgr:loadLua("packages.mvc.ViewBase"))
UIFangkaMsg.RESOURCE_FILENAME = "UIFangkaMsg.csb"
UIFangkaMsg.RESOURCE_BINDING = {
    --["text"] = {["varname"] = "text"},
    ["ScrollView"] 	= {		["varname"] = "ScrollView" },
    ["btn_close"]   = {     ["varname"] = "btn_close"   ,  ["events"] = { {event = "click" ,  method ="exitUI"  } }   },
}

function UIFangkaMsg:onEnter()
    cclog(" UIFangkaMsg enter")
	CCXNotifyCenter:listen(self,function(obj,key,data) self:setText(data or "暂无信息") end,"onMSGData")
	ex_hallHandler:msgData()--大厅房卡消息
end

function UIFangkaMsg:onExit()
	CCXNotifyCenter:unListenByObj(self)
end

function UIFangkaMsg:onCreate()
	self.text = cc.Label:createWithTTF("","font/LexusJianHei.TTF",18)
	self.text:setColor(cc.c3b(125,61,31))
    self.text:setAnchorPoint(cc.p(0,1))
    self.ScrollView:addChild(self.text,100)--添加到scrollview
    self.text:setLineHeight(24)
	self.text:setWidth(760)

	self.scrollView_size = self.ScrollView:getContentSize()
end

function UIFangkaMsg:setText(msg)
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

function UIFangkaMsg:exitUI()	
	self:removeFromParent()
end

return UIFangkaMsg