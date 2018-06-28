local uiActivityRewardCash_xczf = class("uiActivityRewardCash_xczf", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

uiActivityRewardCash_xczf.RESOURCE_FILENAME = "activity2/uiActivityRewardCash_xczf.csb"
uiActivityRewardCash_xczf.RESOURCE_BINDING = {
    ["btn_getreward"]  = {    ["varname"] = "btn_getreward"           ,  ["events"] = { {event = "click" ,  method ="onReward"    } }       },
    ["btn_share"]      = {    ["varname"] = "btn_share"               ,  ["events"] = { {event = "click" ,  method ="onShare"     } }       },
    ["btn_changeMsg"]  = {    ["varname"] = "btn_changeMsg"           ,  ["events"] = { {event = "click" ,  method ="onReward"    } }       },
    ["btn_close"]      = {    ["varname"] = "btn_close"               ,  ["events"] = { {event = "click" ,  method ="onClose"     } }       },
    ["txt_msg"]  	   = {    ["varname"] = "txt_msg"                  },

    ["txt_rank"]       = {    ["varname"] = "txt_rank"                 },
    ["txt_reward"]     = {    ["varname"] = "txt_reward"               },
}

function uiActivityRewardCash_xczf:onCreate()
    cclog("CREATE")
end

function uiActivityRewardCash_xczf:onEnter()
    cclog("ENTER")
    if ActivityMgr.ActivityUserInfo then
    	self.btn_changeMsg:setVisible(true)
    	self.btn_getreward:setVisible(false)
    end	
end

function uiActivityRewardCash_xczf:onExit()
    cclog("EXIT")
end

function uiActivityRewardCash_xczf:setItemData(money)
	if money then 
        local ney = string.gsub(money, "%.", "_")
        self.txt_reward:setString(ney)
	end	
end


------ 按钮 -------
function uiActivityRewardCash_xczf:onReward()
    cclog("-------onReward")

    local dcenter = ex_fileMgr:loadLua("activity.UIActivityUserAddress").new()
    dcenter:setLocalZOrder(ActivityMgr.ZOrder_UI)
    dcenter:setData(self.data)
    dcenter:addTo(self:getParent())

    self:removeFromParent()
end

function uiActivityRewardCash_xczf:onShare()
    cclog("-------onShare")
    ActivityMgr:shareScreenRewards()
    -- self:removeFromParent()
end

function uiActivityRewardCash_xczf:onClose()
    self:removeFromParent()
end

return uiActivityRewardCash_xczf