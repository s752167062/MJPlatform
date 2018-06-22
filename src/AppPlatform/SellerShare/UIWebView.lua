local UIWebView = class("UIWebView", cc.load("mvc").ViewBase)

UIWebView.RESOURCE_FILENAME = "layout/SellerShare/UIWebView.csb"
UIWebView.RESOURCE_BINDING = {
    ["btn_close"]       = {    ["varname"] = "btn_close"     ,  ["events"] = { {event = "click" ,  method ="onBack"     } }     },
    ["btn_reload"]      = {    ["varname"] = "btn_reload"    ,  ["events"] = { {event = "click" ,  method ="onReload"   } }     },
    ["btn_goback"]      = {    ["varname"] = "btn_goback"    ,  ["events"] = { {event = "click" ,  method ="onGoBack"   } }     },
    ["btn_gohome"]      = {    ["varname"] = "btn_gohome"    ,  ["events"] = { {event = "click" ,  method ="onGoHome"   } }     },
    ["txt_tips"]        = {    ["varname"] = "txt_tips"             },
    ["web_bg"]          = {    ["varname"] = "web_bg"               },
    ["img_bg"]          = {    ["varname"] = "img_bg"               },
    ["web_logo"]        = {    ["varname"] = "web_logo"             },
    
    ["ctn_web"]         = {    ["varname"] = "ctn_web"                },
    ["ctn_payweb"]      = {    ["varname"] = "ctn_payweb"             },

    ["btn_payclose"]    = {    ["varname"] = "btn_payclose"     ,  ["events"] = { {event = "click" ,  method ="onBack"     } }     },
}

function UIWebView:onCreate()
    dump("UIWebView CREATE")
    self.web_height = -15
end

function UIWebView:onEnter()
    dump("UIWebView ENTER")
    eventMgr:registerEventListener("CloseUIWebView"      ,handler(self,self.onBack),self)
    gameConfMgr:setInfo("isShowWebView", true)
end

function UIWebView:onExit()
    dump("UIWebView EXIT")
    gameConfMgr:setInfo("isShowWebView", false)
    eventMgr:removeEventListenerForTarget(self)
end

function UIWebView:initData(url)
    print(" ------------------- URL ",url)
    self.url = url
    self:createWebView(url)
end

function UIWebView:reSizeForPay()
    self.ctn_web:setVisible(false)
    self.ctn_payweb:setVisible(true)

    self.img_bg:setContentSize(700,525) 
    self.img_bg:setPosition(cc.p(0, 0))
    self.web_height = 0
end

function UIWebView:createWebView(url)
    local size = self.img_bg:getContentSize() 

    self._webView = ccexp.WebView:create()
    self._webView:setPosition(cc.p(0,self.web_height))
    self._webView:setAnchorPoint(cc.p(0.5,0.5))
    self._webView:setContentSize(size.width,  size.height)
    self._webView:loadURL(url)
    self._webView:setScalesPageToFit(true)
    self.web_bg:addChild(self._webView)

    self._webView:setOnShouldStartLoading(function(sender, url)
        print(" >>>> onWebViewShouldStartLoading, url is ", url)
        self.txt_tips:setString("页面加载中...")
        return true
    end)
    self._webView:setOnDidFinishLoading(function(sender, url)
        print(" >>>> onWebViewDidFinishLoading, url is ", url)
        if gameConfMgr:getInfo("platform") == 1 then
            if url:find("wx.tenpay.com") then --安卓有bug，所以要这么加（第三方支付导致的）
                self._webView:setOnShouldStartLoading(function(sender, url)
                    return false
                end)
            end 
        end
    end)
    self._webView:setOnDidFailLoading(function(sender, url)
        print(" >>>> onWebViewDidFinishLoading, url is ", url)
        self.txt_tips:setString("页面失败")
    end)
end

------ 按钮 -------
function UIWebView:onBack()
    dump("UIWebView onBack")
    local function callfunc()
        self:removeFromParent()
    end

    eventMgr:dispatchEvent("requestAgentRedpoint",nil)
    eventMgr:removeEventListenerForTarget(self)
    --ios有bug，所以要这么加（第三方支付导致的）
    self._webView:setOnShouldStartLoading(function(sender, url)
        return false
    end)
    self._webView:setOnDidFinishLoading(function(sender, url)
    end)
    self._webView:setOnDidFailLoading(function(sender, url)
    end)
    self._webView:stopLoading()
    self:stopAllActions()
    local size = cc.Director:getInstance():getVisibleSize()
    local action = cc.MoveTo:create(0.3 , cc.p(0,size.height))
    local func   = cc.CallFunc:create(callfunc)
    local seq1   = transition.sequence({action, func})
    self:runAction(seq1)
end

function UIWebView:onReload()
    if self._webView then 
        self._webView:reload()
    end    
end   

function UIWebView:onGoBack()
    if self._webView and self._webView:canGoBack() then 
        self._webView:goBack()
    end
end 

function UIWebView:onGoHome()
    -- if self._webView and self._webView:canGoForward() then 
    --     self._webView:goForward()
    -- end
    if self.url and  self.url~= "" then 
        self._webView:loadURL(self.url)
    end    
end 

return UIWebView
