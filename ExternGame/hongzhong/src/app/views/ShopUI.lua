local ShopUI = class("ShopUI",function() 
    return cc.Node:create()
end)

function ShopUI:ctor(data)
    self.root = display.newCSNode("ShopUI.csb")
    self.root:addTo(self)

    self:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        elseif state == "enterTransitionFinish" then
        --self:onEnterTransitionFinish_()
        elseif state == "exitTransitionStart" then
        --self:onExitTransitionStart_()
        elseif state == "cleanup" then
        --self:onCleanup_()
        end
    end)
end

function ShopUI:onEnter()
    self.txt_jinbi = self.root:getChildByName("bg"):getChildByName("cardArea"):getChildByName("txt_jinbi")
    self.txt_card = self.root:getChildByName("bg"):getChildByName("cardArea_2"):getChildByName("txt_card") 

    self:updateNumber()
    CCXNotifyCenter:listen(self,function(self,obj,data) self:updateNumber() end,"onCardUpdate")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:updateNumber() end,"onConnectrefCard")

    local ctn_close = self.root:getChildByName("bg"):getChildByName("btn_close")
    ctn_close:addClickEventListener(function() self:onClose() end)

    local listview = self.root:getChildByName("bg"):getChildByName("ListView") 
    listview:removeAllItems()
    
    if GlobalData.curScene == SceneType_Hall then
        ex_hallHandler:GetProduct() -- 获取列表
    else
        ex_roomHandler:GetProduct() -- 获取列表
    end

    self.notifyUrl= SDKController:getInstance():getNotifyUrl(Game_conf.YYSType)

    --支付
    CCXNotifyCenter:listen(self,function(obj,key,data) self:openUrl(data)    end,"Hall_doH5Pay")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:removewebview()  end,"closeWebView")
    CCXNotifyCenter:listen(self,function(obj,key,data) self.payClick = false end,"ReSetPayClick")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onGetProduct(data) end, "onGetProduct")
    self.payClick = false

end

function ShopUI:onExit()
    self:unregisterScriptHandler()--取消自身监听
    CCXNotifyCenter:unListenByObj(self)
end

function ShopUI:updateNumber()
    cclog("ShopUI:updateNumber")
    self.txt_jinbi:setString(PlayerInfo.goldnum)
    self.txt_card:setString(GlobalData.CartNum)
end

function ShopUI:onGetProduct(res)
    if res ~= nil then
        GlobalFun:make_Product(res)
        cclog("Product >>>>>>>")
        print_r(Product)
        self:sortProduct()
        self:initItem()
    end
end

function ShopUI:sortProduct()
    if #Product < 1 then
    	return 
    end
    
    local newProduct = {}
	for index = 1 , #Product do
		for index2 = 1, #Product - index  do
			local p = Product[index2]
			local p2 = Product[index2 + 1]
			if p.price > p2.price then
				Product[index2] = p2
				Product[index2 + 1] = p
			end
		end
	end
end

function ShopUI:getUnitPrice()
    local item = { price = 0 , count = 100 }
    for key, var in pairs(Product) do
        if var.count < item.count then
    		item = var
    	end
    end
    return item.price / item.count
end

function ShopUI:initItem()
    local listview = self.root:getChildByName("bg"):getChildByName("ListView") 
    listview:removeAllItems()

    for index = 1, #Product do
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(246,320))

        local item = ex_fileMgr:loadLua("app.views.ShopUIItem").new()
        item:setPosition(cc.p(0,0))
        item:setTag(668)
        item:addTo(layout)

        local newbtn = ccui.Button:create("image/alpha.png" , "image/alpha.png")
        local size = newbtn:getContentSize()
        newbtn:setScale( 246/size.width , 320 /size.height)
        newbtn:setPosition(cc.p(100,200))
        newbtn:addClickEventListener(function() self:onPay(index) end)
        newbtn:addTo(layout)

        listview:pushBackCustomItem(layout)
    end

    local listdata = listview:getItems()
    for index, item in pairs(listdata) do
        local p = Product[index]
        local btn = item:getChildByTag(668):getChildByName("root"):getChildByName("Button")
        btn:setTouchEnabled(false)

        local disarea = btn:getChildByName("discountArea");
        local didtxt  = btn:getChildByName("discountText") 
        local cardcount  = btn:getChildByName("cardCount") 
        local price  = btn:getChildByName("price") 
        
        cclog("index:"..index.."  type:"..p.type)
        btn:getChildByName("cardIcon"):setVisible(p.type == 0 and index == 1)
        btn:getChildByName("cardIcon2"):setVisible(p.type == 0 and index >= 2)
        btn:getChildByName("goldIcon"):setVisible(p.type == 1)
        

        local unitprice = self:getUnitPrice()
        local discount = 10
        if p.type == 1 then  --金币不打折 暂时这样写，以后叫服务器给原价出来才能算折扣
            discount = 10
        else
            discount = 10 * p.price /( p.count * unitprice )
        end
        if discount == 10 then
            disarea:setVisible(false) 
            didtxt:setVisible(false) 
        else
            didtxt:setString(discount .. "折")
        end
        local extraStr = ""
        if p.type ~= 1 then
            extraStr = "张房卡"
            cardcount:setFontSize(21)
            cardcount:setTextColor(cc.c3b(229,229,229))
        else
            extraStr = "金币"
            cardcount:setFontSize(19)
            cardcount:setTextColor(cc.c3b(255,199,78))
        end
        cardcount:setString(p.count..extraStr)
        price:setString("￥"..  p.price * 0.01 )
    end
end

function ShopUI:onClose()
    self:removeFromParent()
end

function ShopUI:onPay(index)
    cclog("点击商品" .. index)-- { pid , userData , ip}
    -- SDKController:getInstance():pay({index , PlayerInfo.playerUserID , PlayerInfo.ip ,nil , self.notifyUrl }) --  "1", "119.131.77.243" }) --
    
    ---防止2次点击
    if self.payClick == true then 
        GlobalFun:showToast("正在请求支付，请稍后..." , 2)
        return
    end  

    self.payClick = true  
    local item = Product[index]
    if item and item.goodsID then 
        if GlobalData.curScene == SceneType_Hall then 
            ex_hallHandler:h5Pay("WXPAY" , item.goodsID ) -- item.goodsID  是商品id  （请各自项目确认在1007协议回复后对 全局table Product 赋值时使用的变量名 or 直接看SDKObj_android:pay 函数中的使用）
        elseif GlobalData.curScene == SceneType_Game then 
            ex_roomHandler:h5Pay("WXPAY" , item.goodsID )
        else
            GlobalFun:showError("异常: SCENE ? ",nil,nil,1)
        end    
    else
        GlobalFun:showError("异常: 空的商品",nil,nil,1)
    end    
end

-- 启动浏览器
function ShopUI:openUrl(url)
    if url and url ~= "" then 
        -- local targetPlatform = cc.Application:getInstance():getTargetPlatform()
        -- if targetPlatform == cc.PLATFORM_OS_ANDROID then
        --     --android
        --     local args = { url }
        --     local packName = "org/cocos2dx/lib/Cocos2dxHelper"
        --     local status,bcak = LuaJavaBridge.callStaticMethod(packName,"openURL",args,"(Ljava/lang/String;)Z")
        -- elseif targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
        --     --ios
        --     cpp_openSafari("DownPress" , url)
        -- end
        GlobalFun:showNetWorkConnect("正在请求支付，请稍后...")
        self:addwebview(url)
    else
        GlobalFun:showError("异常: 跳转地址不存在",nil,nil,1)
    end    
end

function ShopUI:addwebview(url)
    if url:find("weixin://wap/pay") or  url:find("platformapi/startApp") then  --请求支付宝和微信后 关闭UI
        cclog("------- 直接浏览器打开")
        platformExportMgr:open_APP_WebView(url)
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

function ShopUI:removewebview()
    GlobalFun:closeNetWorkConnect()
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
return ShopUI
