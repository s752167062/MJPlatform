local UINewUserReward = class("UINewUserReward", cc.load("mvc").ViewBase)

UINewUserReward.RESOURCE_FILENAME = "layout/SellerShare/UINewUserReward.csb"
UINewUserReward.RESOURCE_BINDING = {
    ["btn_ok"]          = {    ["varname"] = "btn_ok"    			    ,  ["events"] = { {event = "click" ,  method ="onOK"     } }     },
    ["btn_share"]       = {    ["varname"] = "btn_share"                ,  ["events"] = { {event = "click" ,  method ="onShare"  } }     },
    ["txt_money"]       = {    ["varname"] = "txt_money"                 },
    ["txt_money_big"]   = {    ["varname"] = "txt_money_big"             },
    ["ctn_root"]        = {    ["varname"] = "ctn_root"                  } 
}

function UINewUserReward:onCreate()
    dump("CREATE")
end

function UINewUserReward:onEnter()
    dump("ENTER")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onReceive(data) end,"Receive_my_newUser_red_envelopes")
    eventMgr:registerEventListener("Receive_my_newUser_red_envelopes"      ,handler(self,self.onReceive     ),"UINewUserReward")

    self:playAni()
end

function UINewUserReward:onExit()
    dump("EXIT")
    eventMgr:removeEventListenerForTarget("UINewUserReward")
    -- CCXNotifyCenter:unListenByObj(self)
end

function UINewUserReward:initData(money)
    self.txt_money_big:setString(string.format("%.2f" ,money /100))
    self.txt_money:setString(string.format("%d 元",money /100))
end

function UINewUserReward:onReceive(status)
	if status then 
        self:playGetGoldAni()
    else
        SellerShareMgr:showToast("领取失败")
    end    
end

function UINewUserReward:playAni()
    local ac = cc.CSLoader:createTimeline(UINewUserReward.RESOURCE_FILENAME)
    ac:play("a0",true)
    self:runAction(ac)
end

function UINewUserReward:playGetGoldAni()
    self.ctn_root:setVisible(false)
	local ani =  display.newCSNode("layout/SellerShare/Ani_coin.csb")
    ani:addTo(self)

    --播放动画
    local ac = cc.CSLoader:createTimeline("layout/SellerShare/Ani_coin.csb")
    ac:play("a0",false)
    ac:setFrameEventCallFunc(function(frame ,event) 
        if frame:getEvent() == "end" then
            if ani then
                ani:stopAllActions()
                ani:removeFromParent()
            end
            self:playEndAni()
        end
    end)

    ani:runAction(ac)

end

function UINewUserReward:playEndAni()
    dump("-- playEndAni")
    local action = cc.ScaleTo:create(0.2 , 0.5)
    local func   = cc.CallFunc:create(function()
        self:removeFromParent()
        -- CCXNotifyCenter:notify("TIPS_GET" ,nil)
        eventMgr:dispatchEvent("TIPS_GET" ,nil)
        SellerShareMgr:showToast("成功领取")
    end)
    local seq1   = transition.sequence({action, func})
    self.ctn_root:runAction(seq1)
end

------ 按钮 -------
function UINewUserReward:onOK()
    dump("-------onOK")
    SellerShareMgr:receive_my_newUser_red_envelopes()
end

function UINewUserReward:onShare()
    dump("-------SHARE")
    local url = gameConfMgr:getInfo("shareUrl")
    if string.find(url,"http",0,true) == nil then 
        url = "http://" .. url
    end
    
    local res = {"一把趣牌，好运自来！", SellerShareMgr._playerInfo_ss.name .. "在趣牌湖南麻将等你来玩！", url , 0} 
    SDKMgr:sdkUrlShare("一把趣牌，好运自来！" , SellerShareMgr._playerInfo_ss.name .. "在趣牌湖南麻将等你来玩！" , url , 0 , nil) 
end

return UINewUserReward