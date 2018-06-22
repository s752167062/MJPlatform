local UIBuyCard = class("UIBuyCard", cc.load("mvc").ViewBase)

UIBuyCard.RESOURCE_FILENAME = "layout/SellerShare/UIBuyCard.csb"
UIBuyCard.RESOURCE_BINDING = {
    ["btn_close"]       = {    ["varname"] = "btn_close"            ,  ["events"] = { {event = "click" ,  method ="onBack"          } }     },
    ["btn_cancel"]      = {    ["varname"] = "btn_cancel"           ,  ["events"] = { {event = "click" ,  method ="onBack"          } }     },
    ["btn_buy"]         = {    ["varname"] = "btn_buy"              ,  ["events"] = { {event = "click" ,  method ="onBuy"           } }     },
    ["btn_exchange"]    = {    ["varname"] = "btn_exchange"         ,  ["events"] = { {event = "click" ,  method ="onExChange"      } }     },
    ["ctn_buy"]         = {    ["varname"] = "ctn_buy"                   },
    ["ctn_exchange"]    = {    ["varname"] = "ctn_exchange"              },
    ["editbox_num"]     = {    ["varname"] = "editbox_num"               }
}

function UIBuyCard:onCreate()
    dump("CREATE")
    self.product = nil
    self.product_ex = nil
end

function UIBuyCard:onEnter()
    dump("ENTER")
end

function UIBuyCard:onExit()
    dump("EXIT")
end

function UIBuyCard:showBuy(product)
    self.ctn_buy:setVisible(true)
    self.product = product
end

function UIBuyCard:shwoExChange(product_ex)
    self.ctn_exchange:setVisible(true)
    self.product_ex = product_ex
end

------ 按钮 -------
function UIBuyCard:onBack()
    dump("-------onBack")
    self:removeFromParent()
end

function UIBuyCard:onBuy()
    dump("-------onBuy " ,self.editbox_num:getStringValue())
    local value = self.editbox_num:getStringValue()
    if value and string.len(value) > 0 then 
        local n = tonumber(value)
        if n then
            local limit_num = self.product.buy_min_num or 0 -- 最少购买数量
            if n < limit_num then
                SellerShareMgr:showToast(string.format("最少购买%d张房卡" , limit_num))
                return 
            end 
            if self.product then 
                -- item.pid    -- 商品id
                -- item.platf  -- 0andoird 1ios
                -- item.type   -- 0房卡 1金币
                -- item.money  -- 价格 （price * 100)
                -- item.num 
                -- local notifyUrl = SDKController:getNotifyUrl(Game_conf.YYSType )
                -- SellerShareMgr:Pay("房卡" , self.product.money * n , SellerShareMgr._playerInfo_ss.union_id , SellerShareMgr._playerInfo_ss.IP , "", self.product.pid , SellerShareMgr._GAME_TYPE , notifyUrl)

                local notifyUrl = gameConfMgr:getInfo("pay_notifyUrl")
                SellerShareMgr:Pay("房卡" , self.product.money * n , SellerShareMgr._playerInfo_ss.union_id , SellerShareMgr._playerInfo_ss.IP , "", self.product.pid , SellerShareMgr._GAME_TYPE ,notifyUrl)

            end    
        else
            SellerShareMgr:showToast("请输入数字")
        end
    end    
end

function UIBuyCard:onExChange()
    dump("-------onExChange" , self.editbox_num:getStringValue())
    local value = self.editbox_num:getStringValue()
    if value and string.len(value) > 0 then 
        local n = tonumber(value)
        if n then
            print_r(" # product_ex ", self.product_ex)
            if self.product_ex then 
                dump(" ### 兑换")
                local exchange_min_num = self.product_ex.exchange_min_num or 1
                if n < exchange_min_num then 
                    SellerShareMgr:showToast("最少兑换"..exchange_min_num.."张房卡")
                else
                    SellerShareMgr:exchange_card(self.product_ex.exChange_pid , n)
                end 
            end    
        else
            SellerShareMgr:showToast("请输入数字")
        end
    end
end


return UIBuyCard