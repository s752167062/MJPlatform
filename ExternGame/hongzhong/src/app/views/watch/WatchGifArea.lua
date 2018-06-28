local WatchGifArea = class("WatchGifArea", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

WatchGifArea.RESOURCE_FILENAME = "watch/CUIWatch_gif_area.csb"
WatchGifArea.RESOURCE_BINDING = {
    -- ["btn_cancel"]       = {    ["varname"] = "btn_cancel"     ,  ["events"] = { {event = "click" ,  method ="onClose"        } }     },
    
    ["bg"]       = {    ["varname"] = "bg"      },
    ["list_view"]       = {    ["varname"] = "list_view"      },
    ["list_view_bg"]       = {    ["varname"] = "list_view_bg"      },
}

function WatchGifArea:onCreate()

    self.root = self:getResourceNode()
    self.list_view:setScrollBarEnabled(false)
end


-- params {playerid, pos, w_xy, giflist}
function WatchGifArea:initParams(params)
	self.params = params
	self.playerid = params.playerid

	CCXNotifyCenter:listen(self,function(obj,key,data) 
			if self.playerid == data.playerid then
				self:onClose()
			end
		end,"clean_WatchGifArea")


	self:setListViewPos()

	self:createGifList()
end

function WatchGifArea:onEnter()


	self.bg:addClickEventListener(function() 
				self:onClose()
		end)

	if GameClient.server ~= nil then
        if GameClient.server.listener[self] then
            GameClient.server.listener[self] = nil
        end
        GameClient.server.listener[self] = self
    end

    --支付
    CCXNotifyCenter:listen(self,function(obj,key,data) self:openUrl(data)    end,"Hall_doH5Pay")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:removewebview()  end,"closeWebView")
    CCXNotifyCenter:listen(self,function(obj,key,data) self.payClick = false end,"ReSetPayClick")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onGetProduct(data) end, "onGetProduct")
    self.payClick = false

end

function WatchGifArea:onExit()
	CCXNotifyCenter:unListenByObj(self)
	self:unregisterScriptHandler()
	if GameClient.server ~= nil then
        GameClient.server.listener[self] = nil
    end
end

function WatchGifArea:onClose()
    self:removeFromParent()
end

function WatchGifArea:setListViewPos()
	local x = self.params.w_xy.x
	local y = self.params.w_xy.y
	local size = self.list_view_bg:getContentSize()

	local pos = self.params.pos
    if pos then 
        cclog("fuckfuckfuck setListViewPos:"..pos) 
    else
        cclog("fuckfuckfuck setListViewPos:nil")    
    end
	if pos == 1 then
		x = x +20
		y = y + 40
	elseif pos == 2 then
		-- x = x -size.width - 80
		-- y = y - 80
        x = x - size.width
        y = y - 120
	elseif pos == 4 then
		-- x = x + 80
		-- y = y - 80
        x = x 
        y = y - 120
	elseif pos == nil then
		-- x = x - 30
		-- y = y + 30
        x = x - 70
        y = y - 30
	end




	self.list_view_bg:setPosition(x,y)

end

function WatchGifArea:createGifList()
	local giflist = self.params.giflist
    cclog("WatchGifArea:createGifList")
    print_r(self.params)

	if not giflist or not next(giflist) then
		return 
	end

	local listview = self.list_view
	listview:removeAllItems()

	local gif_info = ex_fileMgr:loadLua("app.views.watch.CUIWatch_things")
	for k,v in ipairs(giflist) do

		local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(80,110))
        layout:setTouchEnabled(true)
        -- layout:setSwallowTouches(false)

		local item = gif_info.new({index = v.id,price = v.price})
		item:setPosition(0, 5)
		item:addTo(layout)

		layout:addClickEventListener(function () self:onGive(v.id , v.price) end)

        listview:pushBackCustomItem(layout)

	end
end

function WatchGifArea:onGetProduct(res)
    cclog("WatchGifArea:onGetProduct")
    print_r(res)
    
	if not  self.isReqProduct then return end 

	GlobalFun:make_Product(res)
	self.isReqProduct = false
	local item = nil
	local index = 0
    for k,v in pairs(res) do
    	if v.type == 1 then
    		item = v
    		index = k
    		break
    	end
    end

    local function payGold()
    	cclog(">>>>>>>>>>>>>>>",index, item.name)
    	print_r(item)
        cclog("item.goodsID"  , item.thingsid)
		-- local notifyUrl = SDKController:getInstance():getNotifyUrl(Game_conf.YYSType)
		-- SDKController:getInstance():pay({index , PlayerInfo.playerUserID , PlayerInfo.ip ,nil , notifyUrl })
		ex_roomHandler:h5Pay("WXPAY" , item.thingsid )
    end

    local function goStore()
        local ui = ex_fileMgr:loadLua("app.views.ShopUI")
        self.root:addChild(ui.new())

    end


    if self.give_price <= PlayerInfo.goldnum then
        --local str = "是否给玩家" ..self.label_name:getString() .. tb[index]
        --GlobalFun:showError(str,sure,nil,2)

        cclog( "WatchGifArea:onGive >>>",self.playerid,  self.give_index)
        ex_roomHandler:givePlayerGif({playerid = self.playerid, gifid = self.give_index,num = 1})--赠送礼物
        self:onClose()
    else

    	if item then 
	        local str = string.format("金币不足，您是否花费%s元购买%s金币", tostring(item.money * 0.01), tostring(item.card) )
	        GlobalFun:showError2(str,payGold,nil,1)
	    else
	    	local str = "金币不足，是否转跳充值界面?"
	        GlobalFun:showError2(str,goStore,nil,1)
	    end
    end

end

function WatchGifArea:onGive(index,price)
    -- local tb = {"送玫瑰","送香吻","砸臭鸡蛋","砸便便","送鸡","送鱼"}

    -- local function sure()
    --     ex_roomHandler:givePlayerGif({playerid = self.playerid ,gifid = index,num = 1})--赠送礼物

    --     self:onClose()
    -- end
    cclog(">>>>>> give ", index,price , not self.isReqProduct)
    self.give_index = index
    self.give_price = price

    if not self.isReqProduct then
        cclog(">>>>>> GetProduct ")
    	self.isReqProduct = true
   	 	ex_roomHandler:GetProduct()
   	 end

    
end

-- 启动浏览器
function WatchGifArea:openUrl(url)
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

function WatchGifArea:addwebview(url)
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

function WatchGifArea:removewebview()
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



return WatchGifArea








