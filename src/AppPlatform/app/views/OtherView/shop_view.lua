--商场界面
--zhhf
local ShopView = class("ShopView",cc.load("mvc").ViewBase)


ShopView.RESOURCE_FILENAME = __platformHomeDir .."ui/layout/ShopView/ShopView.csb"

function ShopView:onCreate()
	self._product = {} -- 商品列表
	self._apple_product = {} --appstore
    self._type = comDataMgr.SHOP_TYPE.FANGKA--金币

    self:getUIChild("btn_close"):onClick(function ( event )
        self:onClose()
    end)
    self.ListView = self:findChildByName("ListView")
    self.ListView:setScrollBarOpacity(0)
end
function ShopView:onClose()
    viewMgr:close("OtherView.shop_view")
end

function ShopView:onEnter()
    self.h5status = gameConfMgr:getInfo("H5P_STATUS")
    self.url    = gameConfMgr:getInfo("H5P_URL")
    local type_ = 1 --H5 
    -- if self.h5status == false then --暂时只传1
    --     type_ = 2 --APPSTORE 
    -- end 

    hallSendMgr:GetProduct(type_) -- 获取列表 现代(appstore 也走一样的内容) 

    eventMgr:registerEventListener("HallProtocol.onGetProduct",handler(self,self.onGetProduct),"shop_view")
    eventMgr:registerEventListener("onH5Pay",handler(self,self.addwebview),"shop_view")
end

function ShopView:onExit()
	eventMgr:removeEventListenerForTarget("shop_view")
end

function ShopView:update_product()
    hallSendMgr:GetProduct()
end

--设置房卡 金币信息
function ShopView:setInfo()
    -- self.cardArea:getChildByName("card"):setString(GlobalData.CartNum)
    -- self.goldArea:getChildByName("gold"):setString(PlayerInfo.goldNum)
end

function ShopView:setType(value)
    -- body
    -- local t = value or comDataMgr.SHOP_TYPE.FANGKA
    -- self._type = t
    -- if self._type == comDataMgr.SHOP_TYPE.FANGKA then
    --     self:onClickFangKaBtn()
    -- else
    --     self:onClickGoldBtn()
    -- end
    --hallHandler:GetProduct()
end

function ShopView:onGetProduct(res)
    print_r(res,"onGetProduct")
    if res ~= nil then 
        self._product = res
        self:initItem(self._product)
    end
end  

function ShopView:sortProduct(tb)
    table.sort(tb, function (A,B)
        local isSort = false
        local type_a = tonumber(A.type)
        local type_b = tonumber(B.type)
        local pid_a = tonumber(A.pid)
        local pid_b = tonumber(B.pid)
        if type_a == type_b then
            if pid_a < pid_b then
                isSort = true
            else
                isSort = false
            end
        else
            if type_a < type_b then
                isSort = true
            else
                isSort = false
            end  
        end
        return isSort

        end )
	return tb
end 

function ShopView:initItem(product)
    local listWeight = self.ListView
    listWeight:removeAllItems()
    local Product = self:sortProduct(product)
    local itemLayout = display.newCSNode(__platformHomeDir .."ui/layout/ShopView/ShopViewItem.csb"):getChildByName("itemLayout")

    local item_w = 230
    local item_h = 330
    local lastLayout = nil
    local colNum  = 3
    for k,productInfo in comFunMgr:pairsByKeys(Product) do
        local item = itemLayout:clone()
        local index = (k-1)%colNum
        if index == 0 then
            lastLayout = ccui.Layout:create()
            lastLayout:setContentSize(cc.size(item_w*colNum, item_h)) 
            listWeight:pushBackCustomItem(lastLayout)            
        end 
        item:setPosition(cc.p(item_w * index+15,0))
        item:addTo(lastLayout)
    

    	local iconImg = item:findChildByName("img_vip")
    	local btn = item:findChildByName("btn_Item")
    	local price = item:findChildByName("price")
    	-- local info = item:findChildByName("txt_text")
        -- info:setVisible(false)
        local txt_name = item:findChildByName("txt_name")
        -- local imagecold = item:findChildByName("Image")
        local Image_0 = item:findChildByName("Image_0")
        local Image_1 = item:findChildByName("Image_1")
        local Image_2 = item:findChildByName("Image_2")
        local Image_3 = item:findChildByName("Image_3")
        -- local txt_name2 = item:findChildByName("txt_name2")
        -- txt_name2:setString("")

        -- if index%colNum == 0 then
        --     Image_4:setVisible(true)
        -- end
        -- Image_2:setPosition(cc.p(102,110))
        -- Image_2:setScale(0.6)

    	price:setString(string.format("%d元",productInfo.money / 100))
        -- local size = price:getContentSize()
        -- imagecold:setPositionX(price:getPositionX()-size.width*0.5)

        if productInfo.type == 0 then--房卡
            -- if productInfo.givenNum and tonumber(productInfo.givenNum) > 0 then
            --     txt_name2:setString(string.format("赠送%d张房卡",productInfo.givenNum))
            --     Image_2:setPosition(cc.p(102,122))
            --     Image_2:setScale(0.45)
            -- end
            txt_name:setString(string.format("房卡%d张",productInfo.num))
            if productInfo.num == 1 then 
                Image_0:setVisible(true)
            else
                Image_1:setVisible(true)
            end 
            -- info:setString(msgMgr:getMsg("SHOP_ITEM_INFO"))
            -- Image_2:loadTexture("image/common2/fangka.png",1)
        else--金币卡
            local jinbiNum =  comFunMgr:num_length_ctrl(productInfo.num)
            txt_name:setString(string.format("金币"..jinbiNum))
            Image_3:setVisible(true)
            -- info:setString(msgMgr:getMsg("SHOP_GOLD_INFO"))
            -- Image_2:loadTexture("image/common2/jinbika.png",1)
        end
        btn:setTouchEnabled(false)
        iconImg:setTouchEnabled(true)
        iconImg:onClick(function()
            self:onPay(productInfo.pid)
        end)   	
    end
end


function ShopView:onPay(index)
    local pro_ = nil
    for i=1,#self._product do
        local item = self._product[i]
        if item and item.pid == index then 
            pro_ = item
            break 
        end    
    end
    if pro_ == nil then 
        return 
    end    
    print_r(pro_)

    if self.h5status == true then
        --H5 支付
        hallSendMgr:h5Pay("WXPAY" , pro_.pid)
    else
        platformMgr:IAP_PAY(pro_.pid)
    end
end

function ShopView:cardGoldUpdate()
    self:setInfo()
end 

-- 启动浏览器
function ShopView:openUrl(url)
    if url and url ~= "" then 
        msgMgr:showNetMsg("正在请求支付，请稍后...","paywait")
        self:addwebview(url)
    else
        msgMgr:showError("异常: 跳转地址不存在")
    end    
end

function ShopView:addwebview(url)
    if url:find("weixin://wap/pay") or  url:find("platformapi/startApp") then  --请求支付宝和微信后 关闭UI
        cclog("------- 直接浏览器打开")
        platformMgr:open_APP_WebView(url)
        return nil
    end

    self._webView = ccexp.WebView:create()
    self._webView:setPosition(cc.p(-200,-200))
    self._webView:setAnchorPoint(cc.p(0.5,0.5))
    self._webView:setContentSize(100,  100)
    self._webView:loadURL(url)
    self._webView:setScalesPageToFit(true)
    self.startload = true 

    self._webView:setOnShouldStartLoading(function(sender, url)
        print(" >>>> onWebViewShouldStartLoading, url is ", url , self.startload)
        return self.startload
    end)
    self._webView:setOnDidFinishLoading(function(sender, url)
        print(" >>>> onWebViewDidFinishLoading, url is ", url)
        if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID and url:find("wx.tenpay.com") then --安卓有bug，所以要这么加（第三方支付导致的）
            self.startload = false
        end 
            
        if url:find("weixin://wap/pay") or  url:find("platformapi/startApp") then  --请求支付宝和微信后 关闭UI
            self:removewebview()
        end
    end)
    self._webView:setOnDidFailLoading(function(sender, url)
        self:removewebview()
    end)

    self:addChild(self._webView)
end

function ShopView:removewebview()
    msgMgr:closeNetMsg("paywait")
    if self._webView then 
        -- self._webView:loadURL("www.bing.com")
        -- self._webView:stopLoading()
        -- self._webView:removeFromParent()
        -- self._webView  = nil
        -- self.startload = false
    else
        cclog(" _webView null ")
    end 
end


return ShopView
