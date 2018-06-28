local CUIShareType = class("CUIShareType",function() return cc.Node:create() end)

function CUIShareType:ctor(c,num,playerNum)
    self.root = display.newCSNode("common/CUIShareType.csb")
    self.root:addTo(self)
    
    self.c = c
    self.num = num
    self.playerNum = playerNum or 0
    
    self.root:getChildByName("ctn_share0"):getChildByName("btn_wx"):addClickEventListener(function() self.type = 0
        self:onSure() end)
    self.root:getChildByName("ctn_share0"):getChildByName("btn_qq"):addClickEventListener(function() self.type = 1
        self:onSure() end)
    self.root:getChildByName("ctn_share0"):getChildByName("btn_dd"):addClickEventListener(function() self.type = 2
        self:onSure() end)

    self.root:getChildByName("ctn_share1"):getChildByName("btn_wx"):addClickEventListener(function() self.type = 0
        self:onSure() end)
    self.root:getChildByName("ctn_share1"):getChildByName("btn_qq"):addClickEventListener(function() self.type = 1
        self:onSure() end)
    self.root:getChildByName("ctn_share1"):getChildByName("btn_dd"):addClickEventListener(function() self.type = 2
        self:onSure() end)

    self.root:getChildByName("ctn_share0"):setVisible(c == 0)
    self.root:getChildByName("ctn_share1"):setVisible(c == 1)
    
    self.root:getChildByName("btn_cancel"):addClickEventListener(function() self:onCancel() end)
    
end

function CUIShareType:getShareRootNode()
    if self.c == 0 then 
        return self.root:getChildByName("ctn_share0")
    end    
    return self.root:getChildByName("ctn_share1")
end

function CUIShareType:onSure()
    self:setVisible(false)
    if self.c == 0 then
        local title = "房间号【".. GlobalData.roomID .. "】" --.. " " .. self.playerNum .. "缺" .. (self.num - self.playerNum)
        -- local msg = "我在[筑志红中麻将]开了 ".. GameRule.MAX_GAMECNT .."局,".. GameRule.ZhaMaCNT .."个码" 
        -- if GameRule.isQiXiaoDui == 1 then
        --    msg = msg .. " 七小对"
        -- end
        -- if GameRule.isMiLuoHongZhong == 1 then
        --    msg = msg .. " 汨罗红中"
        -- end

        -- msg = msg .. "的".. self.num .. "人房间," .. "快来一起玩吧"
        cclog("self.playerNum:"..self.playerNum)
        local msg = GameRule:getShareText(self.num)
        cclog("msg:"..msg)
        local url = platformExportMgr:getShareUrl() --GlobalFun:dealStr(LoginLogic.shareURL)
        if string.find(url,"http",0,true) == nil then 
            url = "http://" .. url
        end
        cclog("shareURL  " .. url)
        
        if self.type ==  0 then
            -- local res =  { title, msg, url } 
            -- SDKController:share(res)
            platformExportMgr:weChatShareUrl(title , msg , url , 0 ,nil)
        -- elseif self.type == 1 then
            -- SDKController:getInstance():umengShareHttpUrl("QQ" , url , title , msg)
            -- if yxsdkMgr:isYXClientExit() then 
            --     yxsdkMgr:sdkUrlShare(title , msg , url , 0 ,nil) 
            -- else
            --     cpp_openSafari("openurl" , "http://www.yixin.im/m")
            -- end    
        else
            -- SDKController:getInstance():umengShareHttpUrl("ALIPAY" , url , title , msg)
            if platformExportMgr:ddClientExits() and platformExportMgr:ddApiSupport() then 
                platformExportMgr:ddShareUrl(title , msg , url ,nil)
            else
                platformExportMgr:open_APP_WebView("https://tms.dingtalk.com/markets/dingtalk/download?spm=a3140.8736650.2231602.9.75185c8ciA9Mkk&source=2202&lwfrom=2017120202092064209309201")
            end    
        end
    else
        if self.type ==  0 then 
            GlobalFun:timeOutCallfunc(0.6 , function()	GlobalFun:ShareWeCharScreenShot() end)
        -- elseif self.type == 1 then 
        --     if yxsdkMgr:isYXClientExit() then 
        --         GlobalFun:timeOutCallfunc(0.6 , function() GlobalFun:ShareWeCharScreenShot("YX") end)
        --     else
        --         cpp_openSafari("openurl" , "http://www.yixin.im/m")
        --     end  
        else
            GlobalFun:timeOutCallfunc(0.6 , function() GlobalFun:ShareWeCharScreenShot("DD") end)
        end
    end
    
    
    self:removeFromParent()
end

function CUIShareType:onCancel()
    self:removeFromParent()
end

return CUIShareType