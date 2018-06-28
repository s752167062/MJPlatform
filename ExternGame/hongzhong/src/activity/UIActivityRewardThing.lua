local uiActivityRewardThing = class("uiActivityRewardThing", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

uiActivityRewardThing.RESOURCE_FILENAME = "activity2/uiActivityRewardThing.csb"
uiActivityRewardThing.RESOURCE_BINDING = {
    ["btn_share"]      = {    ["varname"] = "btn_share"               ,  ["events"] = { {event = "click" ,  method ="onShare"    } }       },
    ["btn_getreward"]  = {    ["varname"] = "btn_getreward"           ,  ["events"] = { {event = "click" ,  method ="onReward"    } }       },
}

function uiActivityRewardThing:onCreate()
    cclog("CREATE")
end

function uiActivityRewardThing:onEnter()
    cclog("ENTER")
end

function uiActivityRewardThing:onExit()
    cclog("EXIT")
end

function uiActivityRewardThing:showMsg(MSG)
    self.txt_msg:setString(MSG or "")
end

------ 按钮 -------
function uiActivityRewardThing:onShare()
    cclog("-------onShare")
    -- self:removeFromParent()
end

function uiActivityRewardThing:onReward()
    cclog("-------onReward")
    -- self:removeFromParent()
end

return uiActivityRewardThing