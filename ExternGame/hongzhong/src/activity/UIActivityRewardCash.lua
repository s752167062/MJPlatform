local uiActivityRewardCash = class("uiActivityRewardCash", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

uiActivityRewardCash.RESOURCE_FILENAME = "activity2/uiActivityRewardCash.csb"
uiActivityRewardCash.RESOURCE_BINDING = {
    ["btn_getreward"]  = {    ["varname"] = "btn_getreward"           ,  ["events"] = { {event = "click" ,  method ="onReward"    } }       },
    ["btn_share"]      = {    ["varname"] = "btn_share"               ,  ["events"] = { {event = "click" ,  method ="onShare"     } }       },
    ["btn_changeMsg"]  = {    ["varname"] = "btn_changeMsg"           ,  ["events"] = { {event = "click" ,  method ="onReward"    } }       },
    ["btn_close"]      = {    ["varname"] = "btn_close"               ,  ["events"] = { {event = "click" ,  method ="onClose"     } }       },
    ["txt_msg"]  	   = {    ["varname"] = "txt_msg"                  },

    ["txt_rank"]       = {    ["varname"] = "txt_rank"                 },
    ["txt_reward"]     = {    ["varname"] = "txt_reward"               },
}

function uiActivityRewardCash:onCreate()
    cclog("CREATE")
end

function uiActivityRewardCash:onEnter()
    cclog("ENTER")
    if ActivityMgr.ActivityUserInfo then
    	self.btn_changeMsg:setVisible(true)
    	self.btn_getreward:setVisible(false)
    end	
end

function uiActivityRewardCash:onExit()
    cclog("EXIT")
end

function uiActivityRewardCash:setItemData(data_)
	if data_ then 
		self.data = data_
        print_r(data_)
        local ney = string.gsub(data_.reward_status_msg or "", "%.", "_")
        self.txt_rank:setString(data_.ranking)
        self.txt_reward:setString(ney)
	end	
end


------ 按钮 -------
function uiActivityRewardCash:onReward()
    cclog("-------onReward")

    local dcenter = ex_fileMgr:loadLua("activity.UIActivityUserAddress").new()
    dcenter:setLocalZOrder(ActivityMgr.ZOrder_UI)
    dcenter:setData(self.data)
    dcenter:addTo(self:getParent())

    self:removeFromParent()
end

function uiActivityRewardCash:onShare()
    cclog("-------onShare")
    ActivityMgr:shareScreenRewards()
    -- self:removeFromParent()
end

function uiActivityRewardCash:onClose()
    self:removeFromParent()
end

return uiActivityRewardCash