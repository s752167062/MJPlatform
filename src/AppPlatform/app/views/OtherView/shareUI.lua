local shareUI = class("shareUI",cc.load("mvc").ViewBase)

shareUI.RESOURCE_FILENAME =  __platformHomeDir .."ui/layout/OtherView/shareUI.csb"

-- function shareUI:ctor(data)


   
-- end

function shareUI:onEnter()
    local ctn_close = self:findChildByName("btn_close")
    ctn_close:addClickEventListener(function() 
        self:onClose()
     end)

    --DD
    local btn_dd = self:findChildByName("btn_dd")
    btn_dd:addClickEventListener(function() 
        self:onShare("DD")
     end)

    --WX
    local btn_wx = self:findChildByName("btn_wx")
    btn_wx:addClickEventListener(function() 
        self:onShare("WX")
     end)

    --WXZOO
    local btn_wxzoo = self:findChildByName("btn_wxzoo")
    btn_wxzoo:addClickEventListener(function() 
        self:onShare("WXZOO")
     end)
end


function shareUI:onExit()
    self:unregisterScriptHandler()
end

function shareUI:onClose()
    viewMgr:close("OtherView.shareUI")
end

function shareUI:onShare(sharetype)
    local title = msgMgr:getMsg("SHARE_TITLE") or ""
    local msg = string.format(msgMgr:getMsg("SHARE_MSG2"), gameConfMgr:getInfo("playerName")) or ""
    local url = gameConfMgr:getInfo("shareUrl") or ""
    if sharetype == "DD" then 
        if SDKMgr:ddClientExits() and SDKMgr:ddApiSupport() then 
            SDKMgr:ddsdkUrlShare(title , msg , url ,nil) 
        else
            platformMgr:open_APP_WebView("https://tms.dingtalk.com/markets/dingtalk/download?spm=a3140.8736650.2231602.9.75185c8ciA9Mkk&source=2202&lwfrom=2017120202092064209309201")
        end    
    elseif sharetype == "WX" and SDKMgr:checkWXAppExit() == true then 
        SDKMgr:sdkUrlShare( title, msg, url, WX_SHARE_TYPE.FRIENDS)
    else    
        SDKMgr:sdkUrlShare( title, msg, url, WX_SHARE_TYPE.TIME_LINE)
    end    
end




return shareUI
