local item_chest = class("item_chest", cc.load("mvc").ViewBase)

item_chest.RESOURCE_FILENAME = "layout/SellerShare/item_chest.csb"
item_chest.RESOURCE_BINDING = {
    ["btn_chest"]       = {    ["varname"] = "btn_chest"            ,  ["events"] = { {event = "click" ,  method ="onOpenChest"              } }     }
}

function item_chest:onCreate()
    dump("CREATE")
    self.status = -1; -- normal 
    self.data = nil
end

function item_chest:onEnter()
    dump("ENTER")
    -- -- CCXNotifyCenter:listen(self,function(obj,key,data) dump("####") self:rewardUpdate(data) end,"UpdateMyReward")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) dump("####") self:rewardUpdate_NEW(data) end,"UpdateMyReward_NEW")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) dump("####") self:playNormal() end,"Do_received")--领取之后
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:playTips()  end,"TIPS_GET")
    -- -- CCXNotifyCenter:listen(self,function(obj,key,data) dump("####") self:playNormal() end,"Receive_my_wallet")--领取之后

    eventMgr:registerEventListener("UpdateMyReward_NEW" ,handler(self,self.rewardUpdate_NEW     ),"item_chest")
    eventMgr:registerEventListener("Do_received"        ,handler(self,self.playNormal       ),"item_chest")
    eventMgr:registerEventListener("TIPS_GET"           ,handler(self,self.playTips     ),"item_chest")
    self:playNormal()
end

function item_chest:onExit()
    dump("EXIT")
    eventMgr:removeEventListenerForTarget("item_chest")
    -- CCXNotifyCenter:unListenByObj(self)
end

-- function item_chest:rewardUpdate(data)
--     self.data = data 
--     if data then
--         if data.promoAmount + data.gameAmount + data.juniorAmount  > 0 then 
--             self:playTips(); 
--         end    
--     end     
-- end

function item_chest:rewardUpdate_NEW(data)
    self.data = data 
    if data then
        if data.can_be_receivedAmount > 0 then 
            self:playTips(); 
        end    
    end     
end

function item_chest:playTips()
    -- body
    if self.status ~= 1 then
        dump(" -- play tips ")
        self.status = 1
        --播放动画
        local ac = cc.CSLoader:createTimeline(item_chest.RESOURCE_FILENAME)
        ac:play("a0",true)
        self:runAction(ac)
    end    
end

function item_chest:playNormal()
    -- if self.status ~= 0 then
        self:stopAllActions()
        dump(" -- normal ")
        self.status = 0
        --播放动画
        local ac = cc.CSLoader:createTimeline(item_chest.RESOURCE_FILENAME)
        ac:play("a1",false)
        self:runAction(ac)
    -- end  
end


------ 按钮 -------
function item_chest:onOpenChest()
    dump("-------onOpenChest")
    -- self:playNormal() --xxx
    SellerShareMgr:show_UI_wallet(self.data)
end

return item_chest