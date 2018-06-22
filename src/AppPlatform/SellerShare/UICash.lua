local UICash = class("UICash", cc.load("mvc").ViewBase)

UICash.RESOURCE_FILENAME = "layout/SellerShare/UICash.csb"
UICash.RESOURCE_BINDING = {
    ["btn_close"]       = {    ["varname"] = "btn_close"            ,  ["events"] = { {event = "click" ,  method ="onBack"          } }     },

    ["btn_exchange_cards"]      = {    ["varname"] = "btn_exchange_cards"           ,  ["events"] = { {event = "click" ,  method ="onExchangeCards"        } }     },
    ["btn_exchange_cash"]       = {    ["varname"] = "btn_exchange_cash"            ,  ["events"] = { {event = "click" ,  method ="onExchangeCash"         } }     },
    ["btn_merge_to"]            = {    ["varname"] = "btn_merge_to"                 ,  ["events"] = { {event = "click" ,  method ="onMerge"                } }     },
    ["btn_cash"]                = {    ["varname"] = "btn_cash"                     ,  ["events"] = { {event = "click" ,  method ="onCash"                 } }     },
    
    ["txt_card"]    = {    ["varname"] = "txt_card"              },
    ["txt_cash"]    = {    ["varname"] = "txt_cash"              },
    ["txt_merge"]   = {    ["varname"] = "txt_merge"             },
    ["txt_normal_merge"]   = {    ["varname"] = "txt_normal_merge"             },

    ["editbox_cash"]   = {    ["varname"] = "editbox_cash"                     }
}

function UICash:onCreate()
    dump("CREATE")
    self.product_data = nil
    self.url_ = nil
end

function UICash:onEnter()
    dump("ENTER")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onMerge_cash(data) end,"Merge_cash")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onReceive_List(data) end,"Receive_List")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:setData(data) end,"UpdateMyReward_NEW") -- 更新

    eventMgr:registerEventListener("Merge_cash"           ,handler(self,self.onMerge_cash       ),"UICash")
    eventMgr:registerEventListener("Receive_List"         ,handler(self,self.onReceive_List     ),"UICash")
    eventMgr:registerEventListener("UpdateMyReward_NEW"   ,handler(self,self.setData     ),"UICash")

    SellerShareMgr:receive_List() --请求列表
end

function UICash:onExit()
    dump("EXIT")
    eventMgr:removeEventListenerForTarget("UICash")
    -- CCXNotifyCenter:unListenByObj(self)
end

function UICash:createRichText(str)
    local richtext= require("SellerShare.SSRichText"):create(str,cc.size(600,70))
    richtext:setPosition(cc.p(0,0))
    richtext:setAnchorPoint(cc.p(0,0.5))
    richtext:addTo(self.txt_normal_merge)   

    self.txt_merge_rich = richtext 
end

function UICash:setData(data)
    self.merge_money = data.totalAmount or 0

    local str = string.format("[size = 30,color = #743719,font = LexusJianHei]红包收益 #br[size = 30,color = #970706,font = LexusJianHei]%.2f 元 #br[size = 30,color = #743719,font = LexusJianHei]合并至返利收益中#br" ,self.merge_money / 100 ) 
    if self.txt_merge_rich then
        self.txt_merge_rich:removeFromParent()   
    end
    self:createRichText(str)
end

function UICash:onMerge_cash(data)
    if data then 
        if data.status then 
            self:playSuccessAni()
        else
            if data.err_msg ~= nil and data.err_msg ~= "" then 
                SellerShareMgr:showToast(data.err_msg)
            else
                SellerShareMgr:showToast("合并收益失败")
            end    
        end    
    end    
end

function UICash:onReceive_List(data)
    --设置其他数据
    self.product_data = data.res
    self.url_         = data.url_
    if self.product_data and #self.product_data >= 2 then
        self.txt_card:setString(self.product_data[1].DESC or "")
        self.txt_cash:setString(self.product_data[2].DESC or "")
    end    
end

--ani 
function UICash:playSuccessAni()
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

function UICash:playEndAni()
    -- self:removeFromParent()
end 

------ 按钮 -------
function UICash:onBack()
    dump("-------onBack")
    self:removeFromParent()
end


function UICash:onExchangeCards()
    if self.product_data and self.product_data[1] then 
        SellerShareMgr:showTipsBox(SellerShareMgr.EXCHANGE_CARD_BOX,self.product_data[1],nil)
    end
end

function UICash:onExchangeCash()
    if self.product_data and self.product_data[2] then 
        SellerShareMgr:showTipsBox(SellerShareMgr.EXCHANGE_BILL_BOX,self.product_data[2],nil)
    end    
end

function UICash:onMerge()
    if self.merge_money >0 then 
        SellerShareMgr:merge_cash()--合并  
    end    
end

function UICash:onCash()
    dump("-------onCash" ,self.editbox_cash:getStringValue() , " URL ",self.url_)
    local value = self.editbox_cash:getStringValue()
    if value and string.len(value) > 0 then 
        --判断
        local number_value = tonumber(value)
        if number_value == nil or number_value <= 0 then
            SellerShareMgr:showToast("填写金额不得为负数、0或者含有字母及特殊符号，请重新输入")
            return 
        end

        -- if number_value > (tonumber(self.merge_money) or 0 )then
        --     SellerShareMgr:showToast("您所提现金额大于总收益余额，请重新输入")
        --     return 
        -- end    

        -- if number_value < 30 then
        --     SellerShareMgr:showToast("提现金额必须为大于30，请重新输入")
        --     return 
        -- end

        --true 显示H5
        if self.url_ then 
            local URL = string.format("%s&money=%s"  ,self.url_   ,value)
            -- CCXNotifyCenter:notify("MyReward" ,URL)
            eventMgr:dispatchEvent("MyReward" ,URL)
        end
    end    
end

return UICash