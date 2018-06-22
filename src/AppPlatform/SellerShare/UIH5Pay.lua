local UIH5Pay = class("UIH5Pay", cc.load("mvc").ViewBase)

UIH5Pay.RESOURCE_FILENAME = "layout/SellerShare/UIH5Pay.csb"
UIH5Pay.RESOURCE_BINDING = {
    ["btn_close"]      = {    ["varname"] = "btn_close"            ,  ["events"] = { {event = "click" ,  method ="onBack"  } }     },
    ["btn_wechat"]     = {    ["varname"] = "btn_wechat"           ,  ["events"] = { {event = "click" ,  method ="onPayWechat"  } }      },
    ["btn_alipay"]     = {    ["varname"] = "btn_alipay"           ,  ["events"] = { {event = "click" ,  method ="onPayAlipay"  } }      },
    
    ["txt_msg"]        = {    ["varname"] = "txt_msg"                     },
    ["editbox_id"]     = {    ["varname"] = "editbox_id"                  },
}

function UIH5Pay:onCreate()
    dump("CREATE")
end

function UIH5Pay:onEnter()
    dump("ENTER")
    self.paytype = 1
    self.delegateid = nil
    eventMgr:registerEventListener("onDelegateIDCheck"             ,handler(self,self.onDelegateIDCheck       ),"UIH5Pay")
end

function UIH5Pay:onExit()
    dump("EXIT")
    eventMgr:removeEventListenerForTarget("UIH5Pay")
end

function UIH5Pay:initProduct(product)
    if product then 
        self.product = product
        local money = product.money
        local cards = product.cards
        local pro_type = product.protype

        if pro_type == 0 then 
            self.txt_msg:setString(string.format("%d张房卡 = %.2f元", cards or 0 , (money or 0)/100  )) 
        else--if pro_type == 0 then 
            self.txt_msg:setString(string.format("%d金币 = %.2f元", cards or 0 , (money or 0)/100  )) 
        end

        self.delegateid = tonumber(gameConfMgr:getInfo("h5pay_delegateid") or 0)
        if self.delegateid and self.delegateid > 0 then 
            self.editbox_id:setString(self.delegateid)
            self.editbox_id:setEnabled(false)
        end
    end
end

function UIH5Pay:onDelegateIDCheck()
    --较验代理ID 正常
    local pid = self.product.pid
    local delegateid  = tonumber(self.editbox_id:getStringValue()) or 0

    SellerShareMgr:getPayUrl( delegateid , pid ,self.paytype) 
    gameConfMgr:setInfo("h5pay_delegateid" , self.delegateid) --内存保存id
end

------ 按钮 -------
function UIH5Pay:onBack()
    dump("-------onBack")
    self:removeFromParent()
end

function UIH5Pay:onPayWechat()
    if self.product then
        self.paytype = "WXPAY"
        -- self.delegateid = self.editbox_id:getStringValue()
        -- print(" ------ onPayWechat",self.editbox_id:getStringValue())
        -- SellerShareMgr:delegateIDCheck(self.editbox_id:getStringValue())
    
        SellerShareMgr:getPayUrl( 0 , self.product.pid ,self.paytype) 
    end    
end

function UIH5Pay:onPayAlipay()
    if self.product then
        self.paytype = "ALIPAY"
        -- self.delegateid = self.editbox_id:getStringValue()
        -- print(" ------ onPayAlipay",self.editbox_id:getStringValue())
        -- SellerShareMgr:delegateIDCheck(self.editbox_id:getStringValue())
        
        SellerShareMgr:getPayUrl( 0 , self.product.pid ,self.paytype)
    end
end


return UIH5Pay