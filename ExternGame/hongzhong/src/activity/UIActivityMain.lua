local uiActivityMain = class("uiActivityMain", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

uiActivityMain.RESOURCE_FILENAME = "activity2/uiActivityMain.csb"
uiActivityMain.RESOURCE_BINDING = {
    ["btn_myreward"]     = {    ["varname"] = "btn_myreward"           ,  ["events"] = { {event = "click" ,  method ="onReward"  } }       },
    ["btn_canreward"]    = {    ["varname"] = "btn_canreward"          ,  ["events"] = { {event = "click" ,  method ="onReward"  } }       },
    ["btn_rule"]         = {    ["varname"] = "btn_rule"               ,  ["events"] = { {event = "click" ,  method ="onRule"    } }       },
    ["brn_close"]        = {    ["varname"] = "brn_close"              ,  ["events"] = { {event = "click" ,  method ="onBack"    } }       },
    ["brn_closeAll"]     = {    ["varname"] = "brn_closeAll"           ,  ["events"] = { {event = "click" ,  method ="onCloseAll"} }       },
}

function uiActivityMain:onCreate()
    cclog("CREATE")
end

function uiActivityMain:onEnter()
    cclog("ENTER")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:updateCanRewardsStatus() end ,"onGetActivityUserInfo")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:removeFromParent() end ,"ActivitysCloseAll")
    
    if ActivityMgr.ACTIVITY_STATUE == ActivityMgr.ACTIVITY_STATUE_REWARD then 
        self.btn_myreward:setVisible(false)
        self.btn_canreward:setVisible(true)

        if ActivityMgr.reward_status and ActivityMgr.ActivityUserInfo == nil then
            cc.SpriteFrameCache:getInstance():addSpriteFrames("image2/activity2/activity2.plist","image2/activity2/activity2.png")
            self:showCanRewardsAnimation()
        end
    end    
end

function uiActivityMain:onExit()
    cclog("EXIT")
    CCXNotifyCenter:unListenByObj(self)
end 

function uiActivityMain:showCanRewardsAnimation()
    local animate = ActivityMgr:getAnimateWithkey("activity_main_canreward" , "image2/activity2/eff_rewards%d.png" , 1 , 8 , 0.15)
    local spriteFrame = display.newSpriteFrame("image2/activity2/eff_rewards1.png")  
    local sprite = cc.Sprite:createWithSpriteFrame(spriteFrame) 
    sprite:runAction(cc.RepeatForever:create(animate))
    sprite:setScale(0.9)
    sprite:setPosition(cc.p(92.5,30))
            
    self.btn_canreward:addChild(sprite)
end

function uiActivityMain:updateCanRewardsStatus()
    cclog("remove  all eff ")
    self.btn_canreward:removeAllChildren()   
end

------ 按钮 -------
function uiActivityMain:onReward()
    cclog("-------onReward")
    -- self:removeFromParent()
    local dcenter = ex_fileMgr:loadLua("activity.UIActivityClubList").new()
    dcenter:setLocalZOrder(ActivityMgr.ZOrder_UI)
    dcenter:addTo(self:getParent())
end

function uiActivityMain:onRule()
    cclog("-------onRule")
    -- self:removeFromParent()
    local dcenter = ex_fileMgr:loadLua("activity.UIActivityRule").new()
    dcenter:setLocalZOrder(ActivityMgr.ZOrder_UI)
    dcenter:addTo(self:getParent())
end

function uiActivityMain:onBack()
    cclog("-------onBack")
    self:removeFromParent()
end

function uiActivityMain:onCloseAll()
    CCXNotifyCenter:notify("ActivitysCloseAll")
end

return uiActivityMain