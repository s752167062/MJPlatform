local UImyReward = class("UImyReward", cc.load("mvc").ViewBase)

UImyReward.RESOURCE_FILENAME = "layout/SellerShare/UImyReward.csb"
UImyReward.RESOURCE_BINDING = {
    ["btn_close"]       = {    ["varname"] = "btn_close"            ,  ["events"] = { {event = "click" ,  method ="onBack"              } }     },
    ["btn_getreward"]   = {    ["varname"] = "btn_getreward"        ,  ["events"] = { {event = "click" ,  method ="onGetReWard"         } }     },
    ["btn_share"]       = {    ["varname"] = "btn_share"            ,  ["events"] = { {event = "click" ,  method ="onShare"             } }     },

    ["Panel_1"]             = {    ["varname"] = "Panel_1"                  ,  ["events"] = { {event = "click" ,  method ="onQuestion0"             } }     },
    -- ["btn_question1"]       = {    ["varname"] = "btn_question1"            ,  ["events"] = { {event = "click" ,  method ="onQuestion1"             } }     },
    -- ["btn_question2"]       = {    ["varname"] = "btn_question2"            ,  ["events"] = { {event = "click" ,  method ="onQuestion2"             } }     },
    -- ["btn_question3"]       = {    ["varname"] = "btn_question3"            ,  ["events"] = { {event = "click" ,  method ="onQuestion3"             } }     },
    -- ["question_ans1"]       = {    ["varname"] = "question_ans1"                    },
    -- ["question_ans2"]       = {    ["varname"] = "question_ans2"                    },
    -- ["question_ans3"]       = {    ["varname"] = "question_ans3"                    },

    -- ["txt_money"]       = {    ["varname"] = "txt_money"                    },
    -- ["txt_money_0"]     = {    ["varname"] = "txt_money_0"                    },
    -- ["txt_promoAmount"] = {    ["varname"] = "txt_promoAmount"              },
    -- ["txt_gameAmount"]  = {    ["varname"] = "txt_gameAmount"               },
    -- ["txt_juniorAmount"]= {    ["varname"] = "txt_juniorAmount"               },
    -- ["Node_1"]          = {    ["varname"] = "Node_1"               }
    ["btn_received"]          = {    ["varname"] = "btn_received"               ,  ["events"] = { {event = "click" ,  method ="onReceived"              } }     },
    ["btn_question1_N"]       = {    ["varname"] = "btn_question1_N"            ,  ["events"] = { {event = "click" ,  method ="onQuestion1"             } }     },
    ["btn_question2_N"]       = {    ["varname"] = "btn_question2_N"            ,  ["events"] = { {event = "click" ,  method ="onQuestion2"             } }     },
    ["question_ans1_N"]       = {    ["varname"] = "question_ans1_N"                    },
    ["question_ans2_N"]       = {    ["varname"] = "question_ans2_N"                    },
    ["txt_totalAmount"]       = {    ["varname"] = "txt_totalAmount"                    },
    ["txt_canbe_receivedAmount"]     = {    ["varname"] = "txt_canbe_receivedAmount"                    },

}

function UImyReward:onCreate()
    dump("CREATE")
    self.status = 0; -- normal 
    self.reward_data = nil
    self.is_set_password = nil --是否设置了密码
    self.set_password_url= nil --设置密码的地址
end

function UImyReward:onEnter()
    dump("ENTER")
    -- -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onReceive_my_wallet(data) end,"Receive_my_wallet")
    -- -- CCXNotifyCenter:listen(self,function(obj,key,data) self:initData(data) end,"UpdateMyReward")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:initData_NEW(data) end,"UpdateMyReward_NEW")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onDo_received(data) end,"Do_received")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onCheckPassword(data) end,"CheckPassword")
    -- -- self:playTips();

    eventMgr:registerEventListener("UpdateMyReward_NEW"      ,handler(self,self.initData_NEW        ),"UImyReward")
    eventMgr:registerEventListener("Do_received"             ,handler(self,self.onDo_received       ),"UImyReward")
    eventMgr:registerEventListener("CheckPassword"           ,handler(self,self.onCheckPassword     ),"UImyReward")

    --检查是否设置了密码
    SellerShareMgr:checkPassword()
end

function UImyReward:onExit()
    dump("EXIT")
    eventMgr:removeEventListenerForTarget("UImyReward")
    -- CCXNotifyCenter:unListenByObj(self)
end

-- function UImyReward:onReceive_my_wallet(data)
--     self:playGetGoldAni(data.pickupAmount,data.walletAmount)
--     -- self:onBack()
-- end

-- function UImyReward:initData(data)
--     if data then 
--         self.reward_data = data
--         local total = data.promoAmount + data.gameAmount + data.juniorAmount
--         self.txt_money:setString(string.format("%.2f" ,total/ 100))
--         self.txt_money_0:setString(string.format("%.2f" ,total/ 100))
--         self.txt_promoAmount:setString("推广红包：" .. string.format("%.2f" , data.promoAmount / 100) )
--         self.txt_gameAmount:setString("游戏红包：" .. string.format("%.2f" , data.gameAmount / 100) )
--         self.txt_juniorAmount:setString("推广奖励：" .. string.format("%.2f" , data.juniorAmount / 100) )

--         if total > 0 then 
--             self:playTips()
--         else
--             self:playNormal()
--         end
            
--     end    
-- end

--设置数值
function UImyReward:initData_NEW(data)
    if data then 
        self.reward_data = data
        self.txt_totalAmount:setString(string.format("%.2f 元" ,data.totalAmount / 100))
        self.txt_canbe_receivedAmount:setString(string.format("%.2f 元" ,data.can_be_receivedAmount / 100))    
    end    
end

--领取结果
function UImyReward:onDo_received(data)
    if data then 
        SellerShareMgr:showToast(string.format("成功领取收益：%.2f \n总收益：%.2f",  data.receive_Amount / 100, data.totalAmount / 100))   
        
        local reflash_data = {}
        reflash_data.totalAmount            =    data.totalAmount
        reflash_data.can_be_receivedAmount  =    0
        self:initData_NEW(reflash_data) -- 刷新数据
        -- CCXNotifyCenter:notify("TIPS_GET" ,nil)
        eventMgr:dispatchEvent("TIPS_GET" ,nil)
    end    
end

--检查是否绑定
function UImyReward:onCheckPassword(data)
    if data then 
        self.is_set_password = data.status
        self.set_password_url= data.url_
    end    
end


function UImyReward:playTips()
    -- body
    if self.status ~= 1 then
        dump(" -- play tips ")
        self.status = 1
        --播放动画
        local ac = cc.CSLoader:createTimeline(UImyReward.RESOURCE_FILENAME)
        ac:play("a0",true)
        self:runAction(ac)
    end    
end

function UImyReward:playNormal()
    -- if self.status ~= 0 then
        self:stopAllActions()
        dump(" -- normal ")
        self.status = 0
        --播放动画
        local ac = cc.CSLoader:createTimeline(UImyReward.RESOURCE_FILENAME)
        ac:play("a1",false)
        self:runAction(ac)
    -- end  
end


-- function UImyReward:playGetGoldAni(pickupAmount,walletAmount)
--     self.Node_1:setVisible(false)
--     local ani =  display.newCSNode("SellerShare/Ani_coin2.csb")
--     ani:addTo(self)

--     --播放动画
--     local ac = cc.CSLoader:createTimeline("SellerShare/Ani_coin2.csb")
--     ac:play("a0",false)
--     ac:setFrameEventCallFunc(function(frame ,event) 
--         if frame:getEvent() == "end" then
--             if ani then
--                 ani:stopAllActions()
--                 ani:removeFromParent()
--             end
--             self:playEndAni(pickupAmount,walletAmount)
--         end
--     end)

--     ani:runAction(ac)

-- end

-- function UImyReward:playEndAni(pickupAmount,walletAmount)
--     CCXNotifyCenter:notify("TIPS_GET" ,nil)
--     self:removeFromParent()
--     SellerShareMgr:showToast(string.format("成功领取收益：%.2f \n剩余收益：%.2f",  pickupAmount / 100, walletAmount / 100))
-- end  

------ 按钮 -------
function UImyReward:onBack()
    dump("-------onBack")
    self:removeFromParent()
end

function UImyReward:onGetReWard()
    dump("-------onGetReWard")
    -- if self.reward_data then
    --     local total = self.reward_data.promoAmount + self.reward_data.gameAmount + self.reward_data.juniorAmount 
    --     if total > 0 then 
    --         SellerShareMgr:receive_my_wallet()
    --     end    
    -- else

    -- end    

    --NEW 
    if self.reward_data then 
        --显示界面
        if self.is_set_password  == true then 
            local uicash = require("SellerShare.UICash").new()
            uicash:setData(self.reward_data)
            uicash:addTo(self);
        else  
            SellerShareMgr:showTipsBox(SellerShareMgr.BASE_BOX,self.set_password_url,nil)
        end
    end
end

function UImyReward:onReceived()
    dump("-------onReceived")
    if self.reward_data and self.reward_data.can_be_receivedAmount > 0 then 
        --领取可领金额 协议
        SellerShareMgr:receive_my_wallet_NEW()
    end
end

function UImyReward:onShare()
    dump("-------SHARE")
    self:playNormal()

    local url = gameConfMgr:getInfo("shareUrl")
    if string.find(url,"http",0,true) == nil then 
        url = "http://" .. url
    end
    
    local res = {"一把趣牌，好运自来！", SellerShareMgr._playerInfo_ss.name .. "在趣牌湖南麻将等你来玩！", url , 0} 
    SDKMgr:sdkUrlShare("一把趣牌，好运自来！" , SellerShareMgr._playerInfo_ss.name .. "在趣牌湖南麻将等你来玩！" , url , 0 , nil) 
end

function UImyReward:onQuestion0()
    self:selectQuestion(0)
end
function UImyReward:onQuestion1()
    self:selectQuestion(1)
end

function UImyReward:onQuestion2()
    self:selectQuestion(2)
end

function UImyReward:onQuestion3()
    self:selectQuestion(3)
end

function UImyReward:selectQuestion(index)
    self.question_ans1_N:setVisible(index == 1)
    self.question_ans2_N:setVisible(index == 2)
end

return UImyReward