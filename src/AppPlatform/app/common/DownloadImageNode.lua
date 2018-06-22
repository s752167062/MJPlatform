local md5 = require "Manager.md5"

local DownloadImageNode = class("DownloadImageNode", function() 
   return cc.Node:create()
end)





function DownloadImageNode:ctor()
    self:enableNodeEvents()


    self.DownloadImageNode_icon = nil


    self.DownloadImageNode_url = ""
end

function DownloadImageNode:onEnter()
    cclog("DownloadImageNode:onEnter >>>")
end

function DownloadImageNode:onExit()
    cclog("DownloadImageNode:onExit  >>>>")
    self:unregisterScriptHandler()
    eventMgr:removeEventListenerForTarget(self)
end

function DownloadImageNode:onCleanup()
    self:unregisterScriptHandler()
    eventMgr:removeEventListenerForTarget(self)
end


function DownloadImageNode:DownloadImageNode_setIconObj(iconObj)
     self.DownloadImageNode_icon = iconObj
end

function DownloadImageNode:DownloadImageNode_setDownloadDir(dir)
     self.DownloadImageNode_downloadDir = dir
end



function DownloadImageNode:DownloadImageNode_setIcon( url)

    self.DownloadImageNode_url = url or ""

    self:DownloadImageNode_resetIcon(url)
end

function DownloadImageNode:DownloadImageNode_resetIcon(url)
    -- body
    if self.DownloadImageNode_url == "" then
        return
    end
    self:DownloadImageNode_removeHeadImg()
    
 
    local url = self.DownloadImageNode_url

    local function get_md5(content)      
        return md5.sumhexa(content)
    end
    print("get_md5 = ", get_md5(self.DownloadImageNode_url))
    local pathName = get_md5(self.DownloadImageNode_url).."icon.png"
    local imagepath = self.DownloadImageNode_downloadDir ..pathName
    local image = cc.FileUtils:getInstance():isFileExist(imagepath)
    release_print("pathName = ",pathName)
    release_print("url = ",url)
    release_print("imagepath = ",imagepath)
    if image then
        local headsp =  cc.Sprite:create(imagepath)
        if headsp then
            headsp:setAnchorPoint(cc.p(0.5,0.5))
            release_print("show icon image")
            local Basesize = self.DownloadImageNode_icon:getContentSize()
            local Tsize = headsp:getContentSize()
            headsp:setPosition(Basesize.width/2, Basesize.height/2)
            headsp:setScale((Basesize.width) / Tsize.width ,(Basesize.height) / Tsize.height)
            self.DownloadImageNode_icon:addChild(headsp)
         
        end
    else
        local check_url = url
        local function callback()
            --检测闭包前的数据是否跟回调时的一致，不一致意味着闭包返回时，图片被重新设置了
            cclog("Download image ok")
            if check_url == self.DownloadImageNode_url then
                eventMgr:dispatchEvent(tostring(self))           
            end
        end
        -- eventMgr:removeEventListenerForTarget(self)

        eventMgr:removeAllEventListener(tostring(self))
        eventMgr:registerEventListener(tostring(self),handler(self,self.setDownloaded),self)
        comFunMgr:DownloadFile2(url , imagepath , callback)  
    end
end

function DownloadImageNode:setDownloaded()
	cclog("DownloadImageNode:setDownloaded >>>")
    eventMgr:removeAllEventListener(tostring(self))

    if self.DownloadImageNode_url == "" then
        return
    end

    
    local url = self.DownloadImageNode_url
    local function get_md5(content)      
        return md5.sumhexa(content)
    end
    print("get_md5 = ", get_md5(self.DownloadImageNode_url))
    local pathName = get_md5(self.DownloadImageNode_url).."icon.png"
    local imagepath = self.DownloadImageNode_downloadDir ..pathName
    local image = cc.FileUtils:getInstance():isFileExist(imagepath)
    release_print("pathName = ",pathName)
    release_print("url = ",url)
    release_print("imagepath = ",imagepath)
    if image then
        local headsp =  cc.Sprite:create(imagepath)
        if headsp and not tolua.isnull(self.DownloadImageNode_icon) then
            headsp:setAnchorPoint(cc.p(0.5,0.5))
            release_print("show icon image")
            local Basesize = self.DownloadImageNode_icon:getContentSize()
            local Tsize = headsp:getContentSize()
            headsp:setPosition(Basesize.width/2, Basesize.height/2)
            headsp:setScale((Basesize.width) / Tsize.width ,(Basesize.height) / Tsize.height)
            self.DownloadImageNode_icon:addChild(headsp)
            
        end
    end
end

function DownloadImageNode:DownloadImageNode_removeHeadImg()
    if not tolua.isnull(self.DownloadImageNode_icon) then
        self.DownloadImageNode_icon:removeAllChildren()
    end
end

return DownloadImageNode