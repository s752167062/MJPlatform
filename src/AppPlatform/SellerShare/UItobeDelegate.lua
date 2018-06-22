local UItobeDelegate = class("UItobeDelegate", cc.load("mvc").ViewBase)

UItobeDelegate.RESOURCE_FILENAME = "layout/SellerShare/Chengweidaili.csb"
UItobeDelegate.RESOURCE_BINDING = {
    ["btn_close"]       = {    ["varname"] = "btn_close"            ,  ["events"] = { {event = "click" ,  method ="onBack"          } }     },
    -- ["btn_liuyan"]         = {    ["varname"] = "btn_liuyan"              ,  ["events"] = { {event = "click" ,  method ="onLiuYan"           } }     },
    ["btn_cancel"]      = {    ["varname"] = "btn_cancel"           ,  ["events"] = { {event = "click" ,  method ="onBack"          } }     },

    ["text2_0"]         = {    ["varname"] = "txt_msg"              }, --微信
    ["text2"]        = {    ["varname"] = "ctn_root"              }    --电话
}

function UItobeDelegate:onCreate()
    dump("CREATE")
    self.product = nil
end

function UItobeDelegate:onEnter()
    dump("ENTER")
end

function UItobeDelegate:onExit()
    dump("EXIT")
end

function UItobeDelegate:initProduct(product)
        -- product.pid    -- 商品id
        -- product.platf  -- 0andoird 1ios
        -- product.type   -- 0房卡 1金币
        -- product.money  -- 价格 （price * 100)
        -- product.num    -- 数量
    -- if product then 
    --     self.product = product
    --     local str = string.format("[size = 30,color = ##8F300B,font = LexusJianHei]一次性购买#br[size = 30,color = #AF1A1A,font = LexusJianHei]%d张房卡#br[size = 30,color = ##8F300B,font = LexusJianHei]即可成为代理,是否确定购买#br" ,product.num ) 
        
    --     release_print(" -------- ", require("SellerShare.SSRichText"))
    --     local richtext= require("SellerShare.SSRichText"):create(str,self.txt_msg:getContentSize())
    --     richtext:setPosition(self.txt_msg:getPosition())
    --     richtext:addTo(self.ctn_root)
    -- end    
end

------ 按钮 -------
function UItobeDelegate:onBack()
    dump("-------onBack")
    self:removeFromParent()
end

function UItobeDelegate:onBuy()
    dump("-------onBuy")
    -- if self.product then 
    --     local notifyUrl = gameConfMgr:getInfo("pay_notifyUrl")
    --     SellerShareMgr:Pay("房卡" , self.product.money , SellerShareMgr._playerInfo_ss.union_id , SellerShareMgr._playerInfo_ss.IP , "", self.product.pid , SellerShareMgr._GAME_TYPE ,notifyUrl)
    
    -- end    
end

function UItobeDelegate:onLiuYan()
    ComFunMgr:showToast("敬请期待",Game_conf.TOAST_SHORT)
end 

return UItobeDelegate