local uiActivityRule = class("uiActivityRule", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

uiActivityRule.RESOURCE_FILENAME = "activity2/uiActivityRule.csb"
uiActivityRule.RESOURCE_BINDING = {
    ["btn_close"]        = {    ["varname"] = "btn_close"              ,  ["events"] = { {event = "click" ,  method ="onBack"    } }       },
    ["btn_closeAll"]     = {    ["varname"] = "btn_closeAll"           ,  ["events"] = { {event = "click" ,  method ="onCloseAll"} }       },
}

function uiActivityRule:onCreate()
    cclog("CREATE")
end

function uiActivityRule:onEnter()
    cclog("ENTER")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:removeFromParent() end ,"ActivitysCloseAll")
end

function uiActivityRule:onExit()
    cclog("EXIT")
    CCXNotifyCenter:unListenByObj(self)
end



------ 按钮 -------

function uiActivityRule:onBack()
    cclog("-------onBack")
    self:removeFromParent()
end

function uiActivityRule:onCloseAll()
	CCXNotifyCenter:notify("ActivitysCloseAll")
end


return uiActivityRule