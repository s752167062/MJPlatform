local CUIPlayerInfo = class("CUIPlayerInfo",function() 
    return cc.Node:create()
end)

function CUIPlayerInfo:ctor()
    self.root = display.newCSNode("PlayerInfoUI.csb")
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

function CUIPlayerInfo:onEnter()
    local bg = self.root:getChildByName("bg")
    local ctn_close = bg:getChildByName("btn_close")
    ctn_close:addClickEventListener(function() self:onUIClose() end)
    
    local ctn_exitLogin = bg:getChildByName("btn_exit")
    ctn_exitLogin:addClickEventListener(function() self:onExitLogin() end)
    
    local ctn_store = bg:getChildByName("goldArea"):getChildByName("btn_store")
    ctn_store:addClickEventListener(function() self:onStore() end)
    -- self.root:getChildByName("bg"):getChildByName("ctn_gif"):setVisible(false)
    local label_name = bg:getChildByName("name")
    local label_sex  = bg:getChildByName("sex")
    local label_id = bg:getChildByName("id")
    local label_ip = bg:getChildByName("ip")
    
    
    bg:getChildByName("goldArea"):setVisible(false)
    --
    local ctn_head = bg:getChildByName("icon_bg")
    
    
    self.label_name = label_name
    self.label_sex = label_sex
    self.label_id = label_id
    self.label_ip = label_ip
    self.ctn_head = ctn_head
    self.ctn_exitLogin = ctn_exitLogin
    self.label_gold = self.root:getChildByName("bg"):getChildByName("goldArea"):getChildByName("gold")
    self.label_gold:setString(PlayerInfo.goldnum)
    CCXNotifyCenter:listen(self,function(obj,key,data) self.label_gold:setString(data) end,"updateGold")
    --self:setGifList(nil)
end


-- function CUIPlayerInfo:setGifList(data)
--     if self.id == PlayerInfo.playerUserID then
--         self.root:getChildByName("bg"):getChildByName("ctn_gif"):setVisible(false)
--         self.root:getChildByName("bg"):getChildByName("goldArea"):setVisible(true)
--         return
--     end
--     self.root:getChildByName("bg"):getChildByName("ctn_gif"):setVisible(true)
--     local listview = self.root:getChildByName("bg"):getChildByName("ctn_gif"):getChildByName("gif_list")
--     -- data = {{id = 1,price = 10},{id = 2,price = 10},{id = 3,price = 10},{id = 4,price = 10},{id = 5,price = 10},{id = 6,price = 10}}
--     listview:removeAllItems()
--     for index = 1, #data do
--         local layout = ccui.Layout:create()
--         layout:setContentSize(cc.size(90,94))

--         local item = ex_fileMgr:loadLua("app.views.watch.CUIWatch_things").new({index = data[index].id,price = data[index].price})
--         item:setPosition(cc.p(0,0))
--         item:setTag(668)
--         item:addTo(layout)

--         local newbtn = ccui.Button:create("image/alpha.png" , "image/alpha.png")
--         local size = newbtn:getContentSize()
--         newbtn:setScale( 80/size.width , 94 /size.height)
--         newbtn:setPosition(cc.p(40,50))
--         newbtn:addClickEventListener(function() self:onGive(index,data[index].price) end)
--         newbtn:addTo(layout)

--         listview:pushBackCustomItem(layout)
--     end
-- end

-- function CUIPlayerInfo:onGive(index,price)
--     -- local tb = {"送玫瑰","送香吻","砸臭鸡蛋","砸便便","送鸡","送鱼"}
--     local function sure()
--         ex_roomHandler:givePlayerGif({playerid = self.id,gifid = index,num = 1})--赠送礼物

--         self:onUIClose()
--     end
--     local function goStore()
--         local ui = ex_fileMgr:loadLua("app.views.ShopUI")
--         self.root:addChild(ui.new())
--     end
--     if price <= PlayerInfo.goldnum then
--         --local str = "是否给玩家" ..self.label_name:getString() .. tb[index]
--         --GlobalFun:showError(str,sure,nil,2)
--         ex_roomHandler:givePlayerGif({playerid = self.id,gifid = index,num = 1})--赠送礼物
--         self:onUIClose()
--     else
--         local str = "金币不足，是否转跳充值界面?"
--         GlobalFun:showError(str,goStore,nil,2)
--     end
-- end

function CUIPlayerInfo:onStore()
    local ui = ex_fileMgr:loadLua("app.views.ShopUI")
    self.root:addChild(ui.new())
end

function CUIPlayerInfo:onExit()
    CCXNotifyCenter:unListenByObj(self)
    self:unregisterScriptHandler()--取消自身监听
end

function CUIPlayerInfo:onUIClose()
    self:removeFromParent()
end

function CUIPlayerInfo:setMyIcon(b)
    self.label_name:setString(PlayerInfo.nickname)
    if PlayerInfo.sex == 1 then
        --self.label_sex:setString("男")
        self.label_sex:loadTexture("image2/common/sex_nan.png")
    else
        --self.label_sex:setString("女") 
        self.label_sex:loadTexture("image2/common/sex_nv.png")   
    end
    self.label_id:setString(string.format("%06d",PlayerInfo.playerUserID))
    self.label_ip:setString(PlayerInfo.ip)

    self.label_gold:setString(PlayerInfo.goldnum)
    self.root:getChildByName("bg"):getChildByName("goldArea"):setVisible(true)
    
    if b == false then
        self.root:getChildByName("bg"):getChildByName("btn_exit"):setVisible(false)
    end
    
    local iconpath = platformExportMgr:doGameConfMgr_getInfo("headIconPath")--
    if iconpath and iconpath ~= "" then --PlayerInfo.imghead ~= "" then
        local path = iconpath-- --ex_fileMgr:getWritablePath().."/"..PlayerInfo.imghead
        local headsp =  cc.Sprite:create(path)
        if headsp == nil then
            cc.Director:getInstance():getTextureCache():reloadTexture(path);
            headsp =  cc.Sprite:create(path)
            if headsp == nil then
                return
            end
        end

        -- headsp:setAnchorPoint(cc.p(0,0))
        -- local Basesize = self.ctn_head:getContentSize()
        -- local Tsize = headsp:getContentSize()
        -- headsp:setScale(Basesize.width / Tsize.width ,Basesize.height / Tsize.height)
        GlobalFun:modifyAddNewIcon(self.ctn_head, headsp, 20, 20, "baseicon")
        self.ctn_head:addChild(headsp)
    end
end

function CUIPlayerInfo:onExitLogin()
    UserDefault:setKeyValue("REFRESH_TOKEN",nil);
    UserDefault:write()
    CCXNotifyCenter:notify("onHallTryConnect",nil)
    HallClient:close()
    GlobalData.isLoginOut = true
    CCXNotifyCenter:notify("LobbyToMain",nil)
end

--{ name , ip , iconName , sex , ID }
function CUIPlayerInfo:setGamePlayerInfo(data)
    -- self:showPlayerInfoNow(data)
    
	local name = data.name
    local ip = data.ip 
    local iconName = data.iconName
	local sex = data.sex
	local ID = data.ID 

    self.id = data.ID
    self.name = name
    self.label_name:setString(name)
    if sex == 1 then
        --self.label_sex:setString("男")
        self.label_sex:loadTexture("image2/common/sex_nan.png")
    else
        --self.label_sex:setString("女") 
        self.label_sex:loadTexture("image2/common/sex_nv.png")   
    end
    self.label_id:setString(string.format("%06d",ID))
    self.label_ip:setString(ip)

    if ip == "" or ip == nil or ip == "0.0.0.0" then 
        self.label_ip:setString("IP正在获取中...")
    end 


    self.ctn_exitLogin:setVisible(false)
    -- self:setGifList(data.scene and data.scene.giflist)
    if self.id == PlayerInfo.playerUserID then
        self.root:getChildByName("bg"):getChildByName("goldArea"):setVisible(true)
        -- return
    end
    
    if iconName ~= "" then
        local path = ex_fileMgr:getWritablePath().."/"..iconName
        if self.id == PlayerInfo.playerUserID then
            path = platformExportMgr:doGameConfMgr_getInfo("headIconPath")--
            cclog(" CUIPlayerInfo : headIconPath ",path)
        end    
        local headsp =  cc.Sprite:create(path)
        if headsp == nil then
            cc.Director:getInstance():getTextureCache():reloadTexture(path);
            headsp =  cc.Sprite:create(path)
            if headsp == nil then
                self.ctn_exitLogin:setVisible(false)
                return
            end
        end
        headsp:setAnchorPoint(cc.p(0,0))
        local Basesize = self.ctn_head:getContentSize()
        local Tsize = headsp:getContentSize()
        headsp:setScale(Basesize.width / Tsize.width ,Basesize.height / Tsize.height)
        self.ctn_head:addChild(headsp)
    end
end

return CUIPlayerInfo
