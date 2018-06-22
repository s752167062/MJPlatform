
local PlayerIcon = class("PlayerIcon", require("app.common.NodeBase"))
local md5 = require "Manager.md5"

function PlayerIcon:ctor()
    PlayerIcon.super.ctor(self, __platformHomeDir .."ui/layout/PlayerIcon.csb")
    self.icon = self:findChildByName("icon")
    self.panel = self:findChildByName("panel")

    self.id = ""
    self.url = ""
end

function PlayerIcon:onEnter()
    -- body
    
end

function PlayerIcon:onExit()
    -- body
    eventMgr:removeEventListenerForTarget(self)
end

function PlayerIcon:setIcon(id, url)
    self.id = id or ""
    self.url = url or ""
    release_print("setIcon = ",self.url)
    self:resetIcon(id, url)
end

function PlayerIcon:resetIcon(id, url)
    -- body
    if id == "" or url == "" then
        return
    end

    self.icon:removeAllChildren()

    local id = self.id
    local url = self.url

    local function get_md5(content)      
        return md5.sumhexa(content)
    end
    print("get_md5 = ", get_md5(self.url))
    local pathName = get_md5(self.url).."icon.png"
    local imagepath = writePathManager:getAppPlatformWritePath()..pathName
    local image = cc.FileUtils:getInstance():isFileExist(imagepath)
    release_print("pathName = ",pathName)
    release_print("url = ",url)
    release_print("imagepath = ",imagepath)
    if image then
        gameConfMgr:setInfo("headIconPath", imagepath)
        local headsp =  cc.Sprite:create(imagepath)
        if headsp then
            headsp:setAnchorPoint(cc.p(0.5,0.5))
            release_print("show icon image")
            local Basesize = self.icon:getContentSize()
            local Tsize = headsp:getContentSize()
            headsp:setPosition(Basesize.width/2, Basesize.height/2)
            headsp:setScale((Basesize.width) / Tsize.width ,(Basesize.height) / Tsize.height)
            self.icon:addChild(headsp)
        end
    else
        local check_id, check_url = id, url
        local function callback()
            --检测闭包前的数据是否跟回调时的一致，不一致意味着闭包返回时，图片被重新设置了
            if check_url == self.url and check_id == self.id then
                eventMgr:dispatchEvent("updateHeadImage")           
            end
        end
        eventMgr:removeEventListenerForTarget(self)
        eventMgr:registerEventListener("updateHeadImage",handler(self,self.setDownloaded),self)
        comFunMgr:DownloadFile(url , pathName , callback)  
    end
end

function PlayerIcon:setDownloaded()
    if self.id == "" and self.url == "" then
        return
    end

    local id = self.id
    local url = self.url
    local function get_md5(content)      
        return md5.sumhexa(content)
    end
    print("get_md5 = ", get_md5(self.url))
    local pathName = get_md5(self.url).."icon.png"
    local imagepath = writePathManager:getAppPlatformWritePath()..pathName
    local image = cc.FileUtils:getInstance():isFileExist(imagepath)
    release_print("pathName = ",pathName)
    release_print("url = ",url)
    release_print("imagepath = ",imagepath)
    if image then
        gameConfMgr:setInfo("headIconPath", imagepath)
        local headsp =  cc.Sprite:create(imagepath)
        if headsp and not tolua.isnull(self.icon) then
            headsp:setAnchorPoint(cc.p(0.5,0.5))
            release_print("show icon image")
            local Basesize = self.icon:getContentSize()
            local Tsize = headsp:getContentSize()
            headsp:setPosition(Basesize.width/2, Basesize.height/2)
            headsp:setScale((Basesize.width) / Tsize.width ,(Basesize.height) / Tsize.height)
            self.icon:addChild(headsp)
        end
    end
end

function PlayerIcon:setClickFunc(func)
    -- body
    self.panel:onClick(func)
end

return PlayerIcon
