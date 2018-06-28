
local PlayerIcon = class("PlayerIcon", function() 
   return cc.Node:create()
end)

function PlayerIcon:ctor()
    self.root = display.newCSNode("club/PlayerIcon.csb")
    self.root:addTo(self)

    self:enableNodeEvents()

    self.icon = self.root:findChildByName("icon")
    self.s_lixian = self.root:findChildByName("s_lixian")
    self.s_youxi = self.root:findChildByName("s_youxi")
    self.s_zaixian = self.root:findChildByName("s_zaixian")
    self.s_xuanzhong = self.root:findChildByName("s_xuanzhong")
    self.s_yiyaoqing = self.root:findChildByName("s_yiyaoqing")
    self.h_guanliyuan = self.root:findChildByName("h_guanliyuan")
    self.h_qunzhu = self.root:findChildByName("h_qunzhu")
    self.h_guanliyuan:setVisible(false)
    self.h_qunzhu:setVisible(false)

    self.panel = self.root:findChildByName("defaultIcon")
    self.btn_add = self.root:findChildByName("btn_add")
    self.img_heimingdan = self.root:findChildByName("img_heimingdan")
    self.name = self.root:findChildByName("name")
    self.name:setVisible(false)
    self.btn_add:setVisible(false)
    self.img_heimingdan:setVisible(false)

    self:setPlayerStatus(-1)
    self:showSelect(false)
    self:showYiYaoQing(false)


    self.id = ""
    self.url = ""
end

function PlayerIcon:onEnter()
    -- body
end

function PlayerIcon:onExit()
    -- body
    CCXNotifyCenter:unListenByObj(self)
end

function PlayerIcon:setIcon(id, url)
    self.id = id or ""
    self.url = url or ""
    self:resetIcon(id, url)
end

function PlayerIcon:resetIcon(id, url)
    -- body
    if self.id == "" or self.url == "" then
        return
    end
    self.icon:removeAllChildren()

    local id = self.id
    local url = self.url
    local iconName = id.."icon.png"
    local imagepath = ex_fileMgr:getWritablePath().."/"..iconName
    local image = ex_fileMgr:isFileExist(imagepath)
    release_print("iconName = "..iconName)
    release_print("url = "..url)
    if image then
        local headsp =  cc.Sprite:create(imagepath)
        if headsp then
            headsp:setAnchorPoint(cc.p(0.5,0.5))

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
                CCXNotifyCenter:notify("ICONdownloaded", nil)
            end
        end
        CCXNotifyCenter:unListenByObj(self)
        CCXNotifyCenter:listen(self,function(obj,key,data) self:setDownloaded() end, "ICONdownloaded")
        -- cpp_downloader("DownloadCallBack" , iconName , url)



        GlobalFun:DownloadFile(url , iconName , callback)  
    end
end

function PlayerIcon:setDownloaded()
    if self.id == "" or self.url == "" then
        return
    end

    local id = self.id
    local url = self.url
    local iconName = id.."icon.png"
    local imagepath = ex_fileMgr:getWritablePath().."/"..iconName
    local image = ex_fileMgr:isFileExist(imagepath)
    release_print("iconName = "..iconName)
    release_print("url = "..url)
    if image then
        local headsp =  cc.Sprite:create(imagepath)
        if headsp and not tolua.isnull(self.icon) then
            headsp:setAnchorPoint(cc.p(0.5,0.5))

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
    self.panel:addClickEventListener(func)
end

function PlayerIcon:setClickEnable(bool)
    self.panel:setTouchEnabled(bool)
end

function PlayerIcon:removeHeadImg()
    if not tolua.isnull(self.icon) then
        self.icon:removeAllChildren()
    end
end

function PlayerIcon:showSelect(isSel)
    self.s_xuanzhong:setVisible(isSel)
end

function PlayerIcon:setPlayerStatus(sid)

    if sid == -1 then
        self.s_lixian:setVisible(false)
        self.s_youxi:setVisible(false)
        self.s_zaixian:setVisible(false)
    else
        self.s_lixian:setVisible(sid == 0)
        self.s_youxi:setVisible(sid == 2)
        self.s_zaixian:setVisible(sid == 1)
    end

end

function PlayerIcon:showYiYaoQing(isShow)
    self.s_yiyaoqing:setVisible(isShow)
end

--更换背景图
function PlayerIcon:getRootView()
    return self.root
end

function PlayerIcon:showZhiWei(playerId)
    local zhiwei = ClubManager:getZhiWei(playerId)
    cclog("PlayerIcon:showZhiWei >>>", zhiwei)
    self.h_guanliyuan:setVisible(zhiwei == 2)
    self.h_qunzhu:setVisible(zhiwei == 1)
end

return PlayerIcon
