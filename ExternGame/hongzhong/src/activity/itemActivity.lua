local itemActivity = class("itemActivity", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

itemActivity.RESOURCE_FILENAME = "activity2/itemActivity.csb"
itemActivity.RESOURCE_BINDING = {
    ["btn_activity"]  = {    ["varname"] = "btn_activity"       ,  ["events"] = { {event = "click" ,  method ="onActivity"    } }     },
}

function itemActivity:onCreate()
    cclog("CREATE")
end

function itemActivity:onEnter()
    cclog("ENTER")

end

function itemActivity:onExit()
    cclog("EXIT")
end

function itemActivity:setStatus(activity_status , reward_status)
    if activity_status == ActivityMgr.ACTIVITY_STATUE_OPENED then -- 进行中
        self:playTips()
    elseif activity_status == ActivityMgr.ACTIVITY_STATUE_REWARD then -- 活动结束领取中
        self:playNormal()
        if reward_status then
            -- 可以领取
        else
            -- 不可以领取
        end    
    end    

end


function itemActivity:playTips()
    -- body
    if self.status ~= 1 then
        cclog(" -- play tips ")
        self.status = 1
        --播放动画
        local ac = cc.CSLoader:createTimeline(itemActivity.RESOURCE_FILENAME)
        ac:play("ani0",true)
        self:runAction(ac)
    end    
end

function itemActivity:playNormal()
    self:stopAllActions()
    cclog(" -- normal ")
    self.status = 0
    --播放动画
    local ac = cc.CSLoader:createTimeline(itemActivity.RESOURCE_FILENAME)
    ac:play("ani1",false)
    self:runAction(ac)
end


------ 按钮 -------
function itemActivity:onActivity()
    cclog("--- onActivity ")
    -- local dcenter = ex_fileMgr:loadLua("activity.UIActivityClubList").new()
    -- dcenter:addTo(self:getParent())  
    ActivityMgr:showActivityMain()  
end


return itemActivity