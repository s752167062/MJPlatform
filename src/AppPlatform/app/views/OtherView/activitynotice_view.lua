--活动公告界面
local ActivityNoticeView = class("ActivityNoticeView",cc.load("mvc").ViewBase)
local md5 = require "Manager.md5"

ActivityNoticeView.RESOURCE_FILENAME = __platformHomeDir .."ui/layout/OtherView/ActivityNoticeView.csb"

function ActivityNoticeView:onCreate()
    self:getUIChild("btn_close"):onClick(function ( event )  
        self:onClose()
    end)

    self.btnList = self:findChildByName("btnList")
    self.btnList:setScrollBarOpacity(0)
    self.img_huodong = self:findChildByName("img_huodong")
    -- self.txt_content = self:findChildByName("txt_content")

    self.scrollView = self:findChildByName("scrollView")
    self.scrollView_size = self.scrollView:getContentSize()
    self.txt_content = cc.Label:createWithTTF("","AppPlatform/ui/font/LexusJianHei.TTF",20)
    self.txt_content:setColor(cc.c3b(70, 85, 90))
    self.txt_content:setAnchorPoint(cc.p(0,1))
    self.scrollView:addChild(self.txt_content,100)
    self.txt_content:setWidth(self.scrollView_size.width - 20)
    self.txt_content:setString("")

    self.img_huodong:setVisible(false)
end

function ActivityNoticeView:onEnter()
    cclog(">>>>>>>>>>>>>>>>>>>>> ActivityNoticeView onEnter ")
    hallSendMgr:gongGaoMsg(true)
    eventMgr:registerEventListener("onActivityNotice",handler(self,self.updateList),self)
    eventMgr:registerEventListener("updateHuodongImage",handler(self,self.updateList),self)
end

function ActivityNoticeView:onExit()
    -- body
    timerMgr:unRegister(self)
    eventMgr:removeEventListenerForTarget(self)
end

function ActivityNoticeView:onClose()
    viewMgr:close("OtherView.activitynotice_view")
end

function ActivityNoticeView:updateList(res)
    -- body
    if not res then return end
    if not res.noticeTab or (not next(res.noticeTab)) then return end
    local size = #res
    local listWeight = self.btnList
    listWeight:removeAllChildren()

    self.noticeTab = res.noticeTab
    self.btnTab = {}
    local itemLayout = display.newCSNode(__platformHomeDir .."ui/layout/OtherView/ActivityNoticeViewItem.csb"):getChildByName("itemLayout")
    local data = res.noticeTab
    local colNum = 1
    local item_w = 200
    local item_h = 90
    local lastLayout = nil
    for i, v in ipairs(data) do
        local item = itemLayout:clone()
        local index = (i-1)%colNum
        if index == 0 then
            lastLayout = ccui.Layout:create()
            lastLayout:setContentSize(cc.size(item_w*colNum, item_h))
            listWeight:pushBackCustomItem(lastLayout)            
        end 
        item:setPosition(cc.p(item_w * index +10,0))
        item:setTag(i)
        item:addTo(lastLayout)

        local txt = item:findChildByName("txt")
        local btn = item:findChildByName("btn")
        txt:setString(v.title)
        btn:addClickEventListener(function() self:showNotice(i) end)
        self.btnTab[i] = {btn = btn,txt = txt}
    end
    self:showNotice(1)
end

function ActivityNoticeView:showNotice(index)
    -- body
    index = tonumber(index)
    for i=1,#self.btnTab do
        if i == index then
            self.btnTab[i].btn:setEnabled(false)
            self.btnTab[i].txt:setTextColor(cc.c3b(239,253,226))
            -- self.btnTab[i].txt:enableOutline(cc.c3b(127,152,126), 2)
        else
            self.btnTab[i].btn:setEnabled(true)
            self.btnTab[i].txt:setTextColor(cc.c3b(116,90,54))
            self.btnTab[i].txt:disableEffect()
        end
    end

    local data = self.noticeTab[index]
    print("showNotice id = ",data.id)
    local t = tonumber(data.type)
    if t == 0 then--文字  
        self.img_huodong:setVisible(false)
        self.scrollView:setVisible(true)
        local msg = data.msg
        self:resetText(msg)
    elseif t == 1 then--图片
        self.img_huodong:setVisible(true)
        self.scrollView:setVisible(false)
        self:resetImg(data.id, data.msg)
    end
end

function ActivityNoticeView:resetText(msg)
    print("resetText msg = ",msg)
    self.txt_content:setString(msg)
    local size = self.txt_content:getContentSize()
    print("size.height = ",size.height)
    print("scrollView_size.height = ",self.scrollView_size.height)
    if size.height > self.scrollView_size.height then
        self.scrollView:setInnerContainerSize(cc.size(size.width,size.height))
        self.txt_content:setPosition(cc.p(0,size.height))
    else
        self.scrollView:setInnerContainerSize(cc.size(size.width,self.scrollView_size.height))
        self.txt_content:setPosition(cc.p(0,self.scrollView_size.height))
    end
    self.scrollView:scrollToTop(0, false)           
end

function ActivityNoticeView:resetImg(id, url)
    -- body
    if id == "" and url == "" then
        return
    end

    self.id = id or 0
    self.url = url or ""

    local function get_md5(content)      
        return md5.sumhexa(content)
    end
    print("get_md5 = ", get_md5(self.url))
    local pathName = get_md5(self.url).."huodong.png"
    local imagepath = cc.FileUtils:getInstance():getWritablePath().."/"..pathName

    local image = cc.FileUtils:getInstance():isFileExist(imagepath)
    release_print("pathName = "..pathName)
    release_print("url = "..url)
    if image then
        local headsp =  cc.Sprite:create(imagepath)
        if headsp then
            release_print("show huodong image")
            headsp:setAnchorPoint(cc.p(0.5,0.5))

            local Basesize = self.img_huodong:getContentSize()
            local Tsize = headsp:getContentSize()
            headsp:setPosition(Basesize.width/2, Basesize.height/2)
            headsp:setScale((Basesize.width) / Tsize.width ,(Basesize.height) / Tsize.height)
            self.img_huodong:addChild(headsp)
        end
    else
        local check_id, check_url = id, url
        local function callback()
            --检测闭包前的数据是否跟回调时的一致，不一致意味着闭包返回时，图片被重新设置了
            if check_url == self.url and check_id == self.id then
                eventMgr:dispatchEvent("updateHuodongImage")           
            end
        end
        eventMgr:removeEventListenerForTarget(self)

        eventMgr:registerEventListener("updateHuodongImage",handler(self,self.setDownloaded),self)
        comFunMgr:DownloadFile(url , pathName , callback)  
    end
end

function ActivityNoticeView:setDownloaded()
    if self.id == "" and self.url == "" then
        return
    end

    local id = self.id
    local url = self.url

    local function get_md5(content)      
        return md5.sumhexa(content)
    end
    print("get_md5 = ", get_md5(self.url))
    local pathName = get_md5(self.url).."huodong.png"
    local imagepath = cc.FileUtils:getInstance():getWritablePath().."/"..pathName
    local image = cc.FileUtils:getInstance():isFileExist(imagepath)
    release_print("pathName = "..pathName)
    release_print("url = "..url)
    if image then
        local headsp =  cc.Sprite:create(imagepath)
        if headsp then
            release_print("show huodong image")
            headsp:setAnchorPoint(cc.p(0.5,0.5))

            local Basesize = self.img_huodong:getContentSize()
            local Tsize = headsp:getContentSize()
            headsp:setPosition(Basesize.width/2, Basesize.height/2)
            headsp:setScale((Basesize.width) / Tsize.width ,(Basesize.height) / Tsize.height)
            self.img_huodong:addChild(headsp)
        end
    end
end

return ActivityNoticeView
