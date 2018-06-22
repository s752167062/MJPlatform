local UITipsBox = class("UITipsBox", cc.load("mvc").ViewBase)

UITipsBox.RESOURCE_FILENAME = "layout/SellerShare/UITipsBox.csb"
UITipsBox.RESOURCE_BINDING = {
    ["btn_close"]       = {    ["varname"] = "btn_close"            ,  ["events"] = { {event = "click" ,  method ="onBack"          } }     },
    ["btn_cancel"]      = {    ["varname"] = "btn_cancel"           ,  ["events"] = { {event = "click" ,  method ="onBack"          } }     },
    
    ["ctn_tips_base"]             = {    ["varname"] = "ctn_tips_base"                               },
    ["btn_base"]                  = {    ["varname"] = "btn_base"             ,  ["events"] = { {event = "click" ,  method ="onBase"                   } }     },

    ["ctn_tips_exchange_cards"]   = {    ["varname"] = "ctn_tips_exchange_cards"                     },
    ["txt_msg_exchange"]          = {    ["varname"] = "txt_msg_exchange"                            },
    ["editbox_exchange"]          = {    ["varname"] = "editbox_exchanges"                           },
    ["btn_exchange_cards"]        = {    ["varname"] = "btn_exchange_cards"   ,  ["events"] = { {event = "click" ,  method ="onExchangeCards"          } }     },

    ["ctn_tips_bill"]             = {    ["varname"] = "ctn_tips_bill"                               },
    ["txt_msg_bill"]              = {    ["varname"] = "txt_msg_bill"                                },
    ["editbox_phone"]             = {    ["varname"] = "editbox_phone"                               },
    ["editbox_password"]          = {    ["varname"] = "editbox_password"                            },
    ["btn_bill"]                  = {    ["varname"] = "btn_bill"             ,  ["events"] = { {event = "click" ,  method ="onBill"                   } }     },

    

}

function UITipsBox:onCreate()
    dump("CREATE")
    self.baseCall = nil
    self.exChangeCall = nil
    self.billCall = nil

    self.baseData = nil
    self.exChangeData = nil
    self.billData = nil
end

function UITipsBox:onEnter()
    dump("ENTER")

    -- CCXNotifyCenter:listen(self,function(obj,key,data)  self:onExchangeCards_(data) end,"Exchange_commodity")--兑换结果
    eventMgr:registerEventListener("Exchange_commodity"      ,handler(self,self.onExchangeCards_     ),"UITipsBox")

end

function UITipsBox:onExit()
    dump("EXIT")
    -- CCXNotifyCenter:unListenByObj(self)
    eventMgr:removeEventListenerForTarget("UITipsBox")
end

function UITipsBox:onExchangeCards_(data)
    if data then 
        local status = data.status 
        local over = data.over_
        
        if status == 0 then --值=0表示兑换成功，值=-1001密码错误 -1002红包余额不足
            self:playSuccessAni()
        elseif status == -1001 then 
            SellerShareMgr:showToast("密码错误，请重新输入")
        elseif status == -1002 then     
            SellerShareMgr:showToast("红包余额不足")
        end 
    end    
end


function UITipsBox:showTipsBase(data,callfunc)
    -- body
    self.ctn_tips_base:setVisible(true)
    self.ctn_tips_exchange_cards:setVisible(false)
    self.ctn_tips_bill:setVisible(false)

    self.baseData = data
    self.baseCall = callfunc
    --
end

function UITipsBox:showCardsExchange(data,callfunc)
    -- body
    self.ctn_tips_base:setVisible(false)
    self.ctn_tips_exchange_cards:setVisible(true)
    self.ctn_tips_bill:setVisible(false)

    self.exChangeData = data
    self.exChangeCall = callfunc
    if data then 
        self.txt_msg_exchange:setString(data.DESC or "")
    end    
end

function UITipsBox:showBillExchange(data,callfunc)
    -- body
    self.ctn_tips_base:setVisible(false)
    self.ctn_tips_exchange_cards:setVisible(false)
    self.ctn_tips_bill:setVisible(true)

    self.billData = data 
    self.billCall = callfunc
    if data then 
        self.txt_msg_bill:setString(data.DESC or "")
    end    
end


function UITipsBox:playSuccessAni()
    local ani =  display.newCSNode("layout/SellerShare/Ani_success.csb")
    ani:addTo(self)

    --播放动画
    local ac = cc.CSLoader:createTimeline("layout/SellerShare/Ani_success.csb")
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

function UITipsBox:playEndAni()
    self:removeFromParent()
end 


------ 按钮 -------
function UITipsBox:onBack()
    dump("-------onBack")
    self:removeFromParent()
end

function UITipsBox:onBase()
    -- CCXNotifyCenter:notify("MyReward" , self.baseData)
    eventMgr:dispatchEvent("MyReward" , self.baseData)
end

function UITipsBox:onExchangeCards()
    dump("-------onExchangeCards" ,self.editbox_exchanges:getStringValue())
    if self.exChangeData == nil then 
        return 
    end 
    local password = self.editbox_exchanges:getStringValue()
    if password and string.len(password) > 0 then 
        SellerShareMgr:exchange_commodity(self.exChangeData.ID , password ) 
    end  
end

function UITipsBox:onBill()
    dump("-------onBill" ,self.editbox_phone:getStringValue(),self.editbox_password:getStringValue())
    if self.billData == nil then 
        return 
    end    
    local phone    = self.editbox_phone:getStringValue()
    local password = self.editbox_password:getStringValue()
    if phone and string.len(phone) > 0 and password and string.len(password) > 0  then 
        dump("  onBill match : " , string.match(phone,"[1][3,4,5,7,8]%d%d%d%d%d%d%d%d%d"))
        if not (string.match(phone,"[1][3,4,5,7,8]%d%d%d%d%d%d%d%d%d") == phone) then
            SellerShareMgr:showToast("您所填写的手机号码有误，请重新输入")
            return 
        end    

        SellerShareMgr:exchange_commodity(self.billData.ID  , password , phone)
    end  
end    

return UITipsBox