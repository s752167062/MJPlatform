--ex_fileMgr:loadLua("GlobalData")
--ex_fileMgr:loadLua("app.views.LoginLogic")

local LobbyScene = class("LobbyScene", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

LobbyScene.RESOURCE_FILENAME = "LobbyScene.csb"

function LobbyScene:onCreate()
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
    GlobalData.curScene = SceneType_Hall
    cclog("GlobalData.curScene=" .. GlobalData.curScene)
end

function LobbyScene:onEnter()
    cclog("LobbyScene:onEnter >>>>")


    self.root = self:getResourceNode()
    GlobalData.curScene = SceneType_Hall
    GlobalData.isRetryConnect =  false

    self:onHongZhongMaJiang()--
    
    self.quickCreateRoom_btn = self.root:getChildByName("btn_quickCreateRoom")
    self.quickCreateRoom_btn:addClickEventListener(function() self:onQuickCreateRoom() end)

    self.setting_btn = self.root:getChildByName("btn_setting")
    self.setting_btn:addClickEventListener(function() self:onSet() end)

    self.shiming_btn = self.root:getChildByName("shiming_btn")
    self.shiming_btn:addClickEventListener(function() self:onShiMing() end)

    self.ctn_head = self.root:getChildByName("headPanel"):getChildByName("icon_bg") --头像按钮
    self.ctn_head:addClickEventListener(function() self:onHead() end)
    
    local ctn_buy = self.root:getChildByName("btn_buy") --购买按钮
    ctn_buy:addClickEventListener(function() self:onBuy() end)

    local cardArea = self.root:getChildByName("cardArea") --购买按钮
    cardArea:addClickEventListener(function() self:onBuy() end)

    local cardArea_2 = self.root:getChildByName("cardArea_2") --购买按钮
    cardArea_2:addClickEventListener(function() self:onBuy() end)

--    ctn_buy:setVisible(GlobalData.canShop)    --- ****!!!!
    
    local ctn_awards = self.root:getChildByName("btn_awards") --奖励按钮
    --ctn_awards:setVisible(false)
    
    local ctn_combatGains = self.root:getChildByName("btn_combatGains") --战绩按钮
    ctn_combatGains:addClickEventListener(function() self:onCombatGains() end)
    
    local ctn_feedback = self.root:getChildByName("btn_feedback") --反馈按钮
    ctn_feedback:addClickEventListener(function() self:onFeedback() end)
    
    local btn_exitgame = self.root:getChildByName("btn_exitgame") --退出
    btn_exitgame:addClickEventListener(function() self:ShowExitUI() end)

    local ctn_rule = self.root:getChildByName("btn_rule") --玩法按钮
    ctn_rule:addClickEventListener(function() self:onRule() end)

    local btn_msg = self.root:getChildByName("btn_msg")--房卡信息记录
    btn_msg:addClickEventListener(function() self:onFangkaMsg() end)
    
    local ctn_hongZhongMaJiang = self.root:getChildByName("btn_hongZhongMaJiang") --红中麻将按钮
    ctn_hongZhongMaJiang:addClickEventListener(function() self:onHongZhongMaJiang() end)

    local btn_joinRoom = self.root:getChildByName("btn_joinRoom") --红中麻将按钮
    btn_joinRoom:addClickEventListener(function() self:onJoinRoom() end)
    
    self.root:getChildByName("btn_match"):addClickEventListener(function() self:onMaJiangMatch() end)--麻将比赛
    if false then
        self.root:getChildByName("btn_pingJiangFan"):setVisible(true)
        self.root:getChildByName("btn_match"):setVisible(false)
    end
    
    self.root:getChildByName("ctn_activity"):getChildByName("btn_activity"):addClickEventListener(function() self:onActivity() end)

    self.root:getChildByName("txt_version"):setString("V" .. Game_conf.Base_Version )
    
	
    --setPerson info
    local name = self.root:getChildByName("name")  
    GlobalFun:uiTextCut(name)
    name:setString(PlayerInfo.nickname)
    local txt_playerId = self.root:getChildByName("txt_playerId")
    txt_playerId:setString(string.format("(ID:%s)", PlayerInfo.playerUserID))
    
    self.carnum = self.root:getChildByName("cardArea_2"):getChildByName("card")
    self.carnum:setString(GlobalData.CartNum)
    self.txt_jinbi = self.root:getChildByName("cardArea"):getChildByName("txt_jinbi")
    self.txt_jinbi:setString(PlayerInfo.goldnum)
    
    
    self:setIcon()
    
    ex_audioMgr:playMusic("sound/bgmlogin.mp3",true)
   
    
    -- local ui = ex_fileMgr:loadLua("app.views.NotifyUI")
    -- self.root:addChild(ui.new(),100)
    self.hT = 0

    self.matchNotifyT = 61

    CCXNotifyCenter:listen(self,function() 
        cclog("jinfangjian")
        -- self:getApp():enterScene("game/CUIGame") 
         ex_gameStateMgr:changeState(ex_gameStateMgr.GAMESTATE.STATE_ROOM)
    end,"CanEnterRoom")

    --UserDefault:setKeyValue("REFRESH_TOKEN",nil)
    --UserDefault:write()
    
    CCXNotifyCenter:listen(self,function() self.hT = 0  end,"onHallHeart")
    -- CCXNotifyCenter:listen(self,function() self.hT = -1 end,"onHallTryConnect")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:onCardUpdate(data) end,"onCardUpdate")
    CCXNotifyCenter:listen(self,function(self,obj,data) self.carnum:setString(GlobalData.CartNum) end,"onConnectrefCard")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:onNotifyMsgUpdate(data) end,"onMSGDataUpdate")

    CCXNotifyCenter:listen(self,function(self,obj,data) self:onGotoRoom(data) end,"onGotoRoom")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:onAcceptRoom(data) end,"AcceptRoom")

    -- self:setKeyBackListener()
    
--[[
    CCXNotifyCenter:listen(self,function()
    local gameScene = ex_fileMgr:loadLua("app.views.game.CUIGame") 
    --self:getApp():enterScene("game/CUIGame")
    --cc.Director:getInstance():replaceScene(gameScene.new())
     end,"AcceptEnterRoom")]]
    ex_timerMgr:register(self)
  
    --Shop control
    ex_hallHandler:CanShopping()
    
    -- ex_hallHandler:getMatchTime()
    
    --ActivityManager:set_host_root(self.root,self.root:getChildByName("ctn_activity"):getChildByName("eff_active"), {lobby_bg = self.root:getChildByName("bg")})
    
    -- local ac = cc.CSLoader:createTimeline("LobbyScene.csb");
    -- ac:play("a0",true)
    -- self:runAction(ac)
    
    -- ExternalManager:listen(self, function(event, data)
    --     if event == ExternalManagerEvent.SHARE_TO_QQ then
    --         GlobalFun:ShareWeCharScreenShot("YX")
    --     elseif event == ExternalManagerEvent.SHARE_TO_WX then
    --         GlobalFun:ShareWeCharScreenShot()
    --     elseif event == ExternalManagerEvent.SHARE_TO_ZFB then
    --         GlobalFun:ShareWeCharScreenShot("ALIPAY")
    --     end

    -- end)
    -- GlobalFun:checkEnterRoom()--检查自动进入房间


    -- --俱乐部-------------------------------------------------------------------------------
    -- local scene = cc.Director:getInstance():getRunningScene()
    -- local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubEntry_Hall")
    -- self.root:addChild(ui.new())

    -- --跳转俱乐部
    -- -- local btn_entryClub = self.root:getChildByName("btn_entryClub")
    -- -- btn_entryClub:addClickEventListener(function() 
        
    -- --     --ex_hallHandler:gotoClub()
    -- --     ex_hallHandler:toClubList() 
    -- -- end)
    -- ex_hallHandler:toClubList() 
    -- CCXNotifyCenter:listen(self,function() 
    --     cclog("canGotoClub")
    --     -- self:getApp():enterScene("club/ClubScene") 
    --     ex_gameStateMgr:changeState(ex_gameStateMgr.GAMESTATE.STATE_CLUB)
    -- end,"canGotoClub")







    -- --ActivityMgr
    -- local activity_node =  cc.Node:create()
    -- self.root:addChild(activity_node) 
    -- ActivityMgr:setHallRootAndBg(self , self.root:getChildByName("bg") , activity_node)
    -- ActivityMgr:checkActivityStatus()
    -- ActivityMgr:getActivityUserInfo()

    local ui = ex_fileMgr:loadLua("app.views.NotifyUI")
    self.root:addChild(ui.new(),100)

    AOVMgr:readGameMode()   --读取上一次配置
end

---****** !!!! ******
function LobbyScene:onCanShopping(res)
--    cclog("******* on Can Shopping "..type(res))
--    if res.canShop == 1 then
--        cclog("******* Can Shopping "..res.canShop)
--		GlobalData.canShop = true
--        local ctn_buy = self.root:getChildByName("btn_buy") --购买按钮
--        ctn_buy:setVisible(GlobalData.canShop)
--	else
--        cclog("******* Can Shopping "..res.canShop)
--	end
end

function LobbyScene:setKeyBackListener()
    local function onKeyReleased(keyCode, event)
        local label = event:getCurrentTarget()
        if keyCode == cc.KeyCode.KEY_BACK then
            cclog(" ** Exit key ")
            self:ShowExitUI()
        end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )

    local eventDispatcher = self.root:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.root)
end

function LobbyScene:setIcon()	 
    if true then
        local path = platformExportMgr:doGameConfMgr_getInfo("headIconPath") or "" --ex_fileMgr:getWritablePath().."/"..PlayerInfo.imghead
        cclog("imghead path "..path)
        local headsp =  cc.Sprite:create(path)
        if headsp == nil then
            cc.Director:getInstance():getTextureCache():reloadTexture(path);
            headsp =  cc.Sprite:create(path)
            if headsp == nil then
                CCXNotifyCenter:listen(self,function() self:setIcon() end, "ShowIcon")
                return
            end
        end

        -- headsp:setAnchorPoint(cc.p(0,0))
        -- local Basesize = self.ctn_head:getContentSize()
        -- local Tsize = headsp:getContentSize()
        -- headsp:setScale(Basesize.width / Tsize.width ,Basesize.height / Tsize.height)
        GlobalFun:modifyAddNewIcon(self.ctn_head, headsp, 10, 10, "baseicon")
        self.ctn_head:addChild(headsp)  
    else
        CCXNotifyCenter:listen(self,function() self:setIcon() end, "ShowIcon")
    end
end

function LobbyScene:update(t)
 
    self.matchNotifyT = self.matchNotifyT + t
    if self.matchNotifyT > 60 and GlobalData.iszcbs then
        self.matchNotifyT = 0
        GlobalFun:productMatchNotify()
    end

end

function LobbyScene:onExit()
    CCXNotifyCenter:unListenByObj(self)
    self:unregisterScriptHandler()--取消自身监听
    ex_timerMgr:unRegister(self)

   
    cclog("清理工作")
end

function LobbyScene:onCardUpdate(res)--通知房卡更新
    cclog(" 房卡更新 ")
    local totalcard = res.currCard--当前卡总数
    local card = res.card --改变的卡数
    cclog("类型....   " , res.type)
    if res.type == 0 then
        GlobalData.CartNum = totalcard
        self.carnum:setString(GlobalData.CartNum)
    else
        PlayerInfo.goldnum = totalcard
        self.txt_jinbi:setString(PlayerInfo.goldnum)
        --通知
        cclog("总金币为    ",totalcard)
        CCXNotifyCenter:notify("updateGold",totalcard)
    end
    if card > 0 then
        if res.type == 0 then
            local str = "获得房卡 :" ..  card .. "张" 
    
            GlobalFun:showToast(str , Game_conf.TOAST_LONG)
        else
            local str = "获得金币 :" ..  card .. "个" 

            GlobalFun:showToast(str , Game_conf.TOAST_LONG)
        end
    end
end

function LobbyScene:onNotifyString(res) --跑马灯信息
    cclog(" 跑马 " .. type(res))
    if res ~= nil then 
        GlobalData.NotifyContexts[#GlobalData.NotifyContexts + 1] = res.msg
        --CCXNotifyCenter:notify("ShowNotify",true)
    end
end

function LobbyScene:onHead()

    cclog("打开头像信息界面")
    local pinfo = ex_fileMgr:loadLua("app.views.game.CUIPlayerInfo").new()
    self.root:addChild(pinfo)
    pinfo:setMyIcon()
end

function LobbyScene:onBuy()
    cclog("打开商店界面")
    local ui = ex_fileMgr:loadLua("app.views.ShopUI")
    self.root:addChild(ui.new())
end

function LobbyScene:onCombatGains()
    cclog("打开战绩界面")
    local ui = ex_fileMgr:loadLua("app.views.CombatGainsUI")
    self.root:addChild(ui.new())
end

function LobbyScene:onFeedback()
    cclog("打开反馈界面")
    local ui = ex_fileMgr:loadLua("app.views.FeedbackUI")
    self.root:addChild(ui.new())
end

function LobbyScene:onRule()
    cclog("打开玩法界面")
    local ui = ex_fileMgr:loadLua("app.views.RuleUI")
    self.root:addChild(ui.new())
end

function LobbyScene:onFangkaMsg()
    cclog("打开房卡记录信息")
    local ui = ex_fileMgr:loadLua("app.views.UIFangkaMsg")
    self.root:addChild(ui.new())

    local ctn_tips = self.root:getChildByName("btn_msg"):getChildByName("ctn_tips")
    ctn_tips:setVisible(false)
end

function LobbyScene:onNotifyMsgUpdate(data)
    cclog(" ------- GENXIN --------")
    --显示提示
    local ctn_tips = self.root:getChildByName("btn_msg"):getChildByName("ctn_tips")
    ctn_tips:setVisible(true)
end    

function LobbyScene:onGetMatchTime(res)
    GlobalData.matchTime = res
end

function LobbyScene:ShowExitUI()
	cclog("打开是否退出")
    -- local ui = ex_fileMgr:loadLua("app.views.ExitUI").new()
    -- ui:setTag(639)
    -- if self.root:getChildByTag(639) then
    --     self.root:getChildByTag(639):removeFromParent()
    -- else
    --     self.root:addChild(ui)
    -- end

    -- platformExportMgr:exitGameByName()
    -- ex_hallHandler:gotoAppPlatform()
    -- local obj = Write.new(1500)
    -- obj:send()

    platformExportMgr:returnAppPlatform()
end

--创建房间
function LobbyScene:onHongZhongMaJiang(flag)
    --cclog("打开红中麻将房间界面")
    --[[GlobalFun:showNetWorkConnect("网络请求中...")
    ex_hallHandler:createRoom()]]

    -- local ui = ex_fileMgr:loadLua("app.views.RoomUI")
    -- self.root:addChild(ui.new({app = self:getApp()}))
    cclog("打开创建房间界面")
    local ui = ex_fileMgr:loadLua("app.views.CreateRoomUI")
    self.root:addChild(ui.new({app = self.app, quickFlag = flag}))
end
--加入房间
function LobbyScene:onJoinRoom()
    cclog("打开房间号界面")
    local ui = ex_fileMgr:loadLua("app.views.RoomNumberUI")
    self.root:addChild(ui.new({app = self.app}))
end

function LobbyScene:onMaJiangMatch()
    cclog("麻将大赛")
    if GlobalData.iszcbs ~= true then
        GlobalFun:showToast("敬请期待...",3)
        return
    end
end


function LobbyScene:onActivity()
    --ActivityManager:on_ac_btn()
end

function LobbyScene:onShiMing()
    -- local ui = ex_fileMgr:loadLua("app.views.ShiMingWin")
    -- self.root:addChild(ui.new())

    -- local targetPlatform = cc.Application:getInstance():getTargetPlatform()  
    -- if targetPlatform == cc.PLATFORM_OS_ANDROID then
    --     local args = { "http://www.12306.cn/mormhweb/" }
    --     local packName = "org/cocos2dx/lib/Cocos2dxHelper"
    --     local status,bcak = LuaJavaBridge.callStaticMethod(packName,"openURL",args,"(Ljava/lang/String;)Z")
    --     return status 
    -- elseif targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD or targetPlatform == cc.PLATFORM_OS_MAC then
    --     cpp_openSafari("xxx" , "http://www.12306.cn/mormhweb/")
    -- end

    ex_gameStateMgr:changeState(ex_gameStateMgr.GAMESTATE.STATE_CLUB)
end

function LobbyScene:onSet()
    cclog("set btn")
    local ui = ex_fileMgr:loadLua("app.views.SetUI")
    self.root:addChild(ui.new())
end

function LobbyScene:onQuickCreateRoom()
    self:onHongZhongMaJiang(true)
end

function LobbyScene:onGotoRoom(res)
    -- body
    print_r(res, "LobbyScene onGotoRoom")
    GlobalData.roomKey = res.roomKey

    ex_roomHandler:reqEnterRoom(res.roomKey)
end

function LobbyScene:onAcceptRoom(res)
    -- body
    cclog("大厅网络关闭")
    ex_gameStateMgr:changeState(ex_gameStateMgr.GAMESTATE.STATE_ROOM) 
end

return LobbyScene
