local uiActivityDialog = class("uiActivityDialog", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

uiActivityDialog.RESOURCE_FILENAME = "activity2/uiActivityDialog.csb"
uiActivityDialog.RESOURCE_BINDING = {
    ["txt_msg"]     = {    ["varname"] = "txt_msg"           },
    ["btn_ok"]      = {    ["varname"] = "btn_ok"               ,  ["events"] = { {event = "click" ,  method ="onOK"    } }       },
    ["btn_cancel"]  = {    ["varname"] = "btn_cancel"           ,  ["events"] = { {event = "click" ,  method ="onClose"    } }       },
    ["btn_close"]   = {    ["varname"] = "btn_close"            ,  ["events"] = { {event = "click" ,  method ="onClose"    } }       },
}

function uiActivityDialog:onCreate()
    cclog("CREATE")
    self.callfunc = nil
end

function uiActivityDialog:onEnter()
    cclog("ENTER")
end

function uiActivityDialog:onExit()
    cclog("EXIT")
end

function uiActivityDialog:showMsg(MSG , func)
    self.txt_msg:setString(MSG or "")
    self.callfunc = func
end

------ 按钮 -------
function uiActivityDialog:onOK()
    cclog("-------onOK")
    if self.callfunc then 
    	self.callfunc()
    end	
    self:removeFromParent()
end

function uiActivityDialog:onClose()
	cclog("-------onClose")
	self:removeFromParent()
end

return uiActivityDialog