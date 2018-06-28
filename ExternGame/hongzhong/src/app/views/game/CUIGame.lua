--ex_fileMgr:loadLua("app.views.game.LocalDataFile")
--ex_fileMgr:loadLua("NetWork.LogController")
--ex_fileMgr:loadLua("app.views.game.VideotapeLogic")
--ex_fileMgr:loadLua("app.Configure.Effect_conf")

local CUIGame = class("CUIGame", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

CUIGame.RESOURCE_FILENAME = "game/CUIGame.csb"

local BaseDeskCloth = ex_fileMgr:loadLua("app.views.game.BaseDeskCloth")
local BasePlayer = ex_fileMgr:loadLua("app.views.game.CUIPlayer")
local BaseBTN = ex_fileMgr:loadLua("app.views.game.CUIGame_btn")
local BaseOnce = ex_fileMgr:loadLua("app.Common.CUIPlayOnce")
local BaseHu = ex_fileMgr:loadLua("app.views.game.Effect_hu")
local BaseQGH = ex_fileMgr:loadLua("app.views.game.Effect_qiangganghu")
local BaseOK = ex_fileMgr:loadLua("app.views.game.CUIGame_OK")
local BaseQXD = ex_fileMgr:loadLua("app.views.game.Effect_qixiaodui")
local BaseDP = ex_fileMgr:loadLua("app.views.game.Effect_dianpao")
local BaseFP = ex_fileMgr:loadLua("app.views.game.Effect_fangpao")
local BaseGps = ex_fileMgr:loadLua("app.views.game.CUIGame_Gps")

local g_CUIPlayOnce_TAG = 10086
CUIGame.isEnd = false
--uploadVoideIsEndCallback = 0
--uploadVoide_name = nil
function CUIGame:onCreate()

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
    -- GlobalData.isRoomToHall = false
    self.isWatch = true --自己是否在观战
    --math.random(1,3)
    self.uploadVoideIsEnd = 0
    self.speakVoiceCount = 0
    self.speakVoiceListener = {}
    self.speakVoiceNameList = {}
    self.giflist = nil
    self.backType = 0  -- 0回大厅，1回俱乐部

    self.curHighLightCardNum = 0
end

function CUIGame:onEnter()
    if GlobalData.roomData then
        GlobalData.curScene = SceneType_Game
    end
    ex_audioMgr:playMusic("sound/bgm.mp3",true)
    --ex_audioMgr:setMusicVolume(0)
    self.root = self:getResourceNode()
    self.deskCloth = self.root:getChildByName("ctn_bg") --桌布
    self.ctn_win = self.root:getChildByName("ctn_win")
    self.ctn_eff = self.root:getChildByName("ctn_effect")
    self.reqCard = false
    local ctn_menu = self.root:getChildByName("ctn_menu")
    local btn_msg = ctn_menu:getChildByName("btn_msg")
    local btn_set = ctn_menu:getChildByName("btn_set")
    local btn_outroom = ctn_menu:getChildByName("btn_outroom")
    local btn_help = ctn_menu:getChildByName("btn_help")
    local btn_mcrophone = self.root:getChildByName("ctn_mcrophone"):getChildByName("btn_mcrophone")

    self.root:getChildByName("room_info"):setVisible(true)
    self.root:getChildByName("matchroom_info"):setVisible(false)
    
    local BaseListen = ex_fileMgr:loadLua("app.views.game.CUIGame_ListenCard")
    self.win_listen = BaseListen.new()
    self.root:getChildByName("ctn_listen"):addChild(self.win_listen)
    
     --显示可胡牌牌型
    local BaseListen = ex_fileMgr:loadLua("app.views.game.CUIGame_HuHandPatterns")
    self.canwin_listen = BaseListen.new()
    self.root:getChildByName("ctn_listen"):addChild(self.canwin_listen)

    local BasePre = ex_fileMgr:loadLua("app.views.game.CUIGame_Require")
    self.win_pre = BasePre.new(self)
    self.root:getChildByName("ctn_pre"):addChild(self.win_pre)
    

    self.win_btn = BaseBTN.new()
    self.ctn_win:addChild(self.win_btn)
    self.win_btn:setVisible(false)
    
    --version
    self.root:getChildByName("txt_version"):setString("V" .. Game_conf.Base_Version )
    
    --test
    self.root:getChildByName("txt_listen"):setVisible(false)
    
    btn_msg:addClickEventListener(function() self:onMsg() end)
    btn_set:addClickEventListener(function() self:onSet() end)
    btn_outroom:addClickEventListener(function() self:onOutRoom() end)
    btn_help:addClickEventListener(function() self:onHelp() end)
    btn_mcrophone:addTouchEventListener(function(touch, event) self:onMcrophone(touch,event) end)
    
    self.root:getChildByName("btn_gz_sit"):addClickEventListener(function() self:onGZSit() end)
    self.root:getChildByName("btn_gz_up"):addClickEventListener(function() self:onGZUp() end)
    self.root:getChildByName("btn_gz"):addClickEventListener(function() self:onGZ() end)
    
    local NewsSp = ex_fileMgr:loadLua("app.views.game.NEWSInfo")
    self.root:getChildByName("ctn_center"):addChild(NewsSp.new({csbfile = "game/NEWSInfo.csb",scene = self}))
    
    BaseDeskCloth.new("game/deskCloth01.csb",self.deskCloth)
    
    self.isUpVideo = false
    self.flag = 0--标示谁出牌
    self.light_flag = 0--指示灯
    self.offset = 0
    self.gameOpen = false--是否已经开始了游戏
    self.player = {}
    self.isReqMiss = false
    self.hT = 0
    self.currValue = nil
    self.sendReady = nil
    self.allSummaryData = nil
    CUIGame.isEnd = false--是否已经收到了解散房间消息
    
    self.sortT = 5 --双击排序时间
    
    self.oldCard = {}--原本自己手上的牌
    
    
    self.autoT = nil
    -- local ui = ex_fileMgr:loadLua("app.views.NotifyUI")
    -- self.root:addChild(ui.new())
    
    -- if GameClient.server ~= nil then
    --     GameClient.server.listener[self] = self
    -- end
    -- self:listenTouch()
    
    
    -- ex_timerMgr:register(self)
    CCXNotifyCenter:listen(self,function(obj,key,data) self:showGameBTN(data) end,"showGameBTN")
    CCXNotifyCenter:listen(self,function() self:showZhaMa() end,"ZhaMaNotify")
    CCXNotifyCenter:listen(self,function() self:showSmallSummary() end,"SmallSummaryNotify")
    CCXNotifyCenter:listen(self,function() self:showAllSummary() end,"AllSummaryNotify")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:closeServerRoom(data) end,"closeServerRoom")
    CCXNotifyCenter:listen(self,function() self:reOpen() end,"reOpen")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onUserEnterRoom(data) end,"onUserEnterRoom")
    CCXNotifyCenter:listen(self,function() self.hT = 0 end,"onGameHeart")
    CCXNotifyCenter:listen(self,function() self.hT = -1 end,"onGameTryConnect")

    CCXNotifyCenter:listen(self,function(obj,key,data) self:showGifList(data) end,"showGifList")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:hideGifList() end,"continueGame")

    --CCXNotifyCenter:listen(self,function() LocalDataFile:insertVideo(self.videoData,GameRule.MAX_GAMECNT,GameRule.ZhaMaCNT)  end,"retrySaveVideo")
    --local a = 10
    self.t = 0
    
    self.videoName = nil
    self.minterval = 0 
    self.canSend = false 
    self.minterval_speakNextVoice = 0
    self.schedulerID_speakNextVoice = nil
    self.minterval_uploadVoiceIsEnd = 0
    self.canSpeakNextVoice = true
    self.uploadVoice_time = 0
    self.speakVoice_time = 0
    self.speakVoiceIsEnd = 0
    self.watchPlayer = {}
    --self.videoT = -1
    
    CCXNotifyCenter:listen(self,function(obj,key,index) self:showSpeakVioce(index) end,"uploadVoiceCompled")
    CCXNotifyCenter:listen(self,function(obj,key,index) self:showMyEmoji(index) end,"ShowEmoji")
    CCXNotifyCenter:listen(self,function(obj,key,index) self:showMyEmojiVoice(index) end,"ShowEmojiVoice")
    CCXNotifyCenter:listen(self,function() self:retryConnectGame() end,"RetryGame")
    CCXNotifyCenter:listen(self,function()
        --UserDefault:setKeyValue("REFRESH_TOKEN",nil)
        UserDefault:write()
        self:getApp():enterScene("MainScene") end,"gotoLogin")
        CCXNotifyCenter:listen(self,function() 
        self.player[1]:IllegalOutCart()
        self.reqCard = true
        ex_roomHandler:notifyPlayerCard()
    end,"IllegalOutCart")--非法出牌给退回来

    CCXNotifyCenter:listen(self,function() self:RecodeSoundComp() end,"RecodeSoundComp")
    CCXNotifyCenter:listen(self,function() 
                                    self.isReqMiss = false
                                    if self.askFrame then
                                        self.askFrame:removeFromParent()
                                        self.askFrame = nil
                                    end
                                 end,"NotifyCloseAsk")
    CCXNotifyCenter:listen(self,function(obj,key,index) self:videoState(index) end,"VideoNotify")
    
    CCXNotifyCenter:listen(self,function() self:upVideoErr() end,"upVideo")



    CCXNotifyCenter:listen(self,function(obj,key,data) self:onFengHuCards(data) end, "onFengHuCards")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onServerGetAllPlayersGps(data) end, "onServerGetAllPlayersGps")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onRequestLocation(data) end, "onRequestLocation")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onRoomOwnerDimissRoom(data) end, "onRoomOwnerDimissRoom")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onHandUp(data) end, "onHandUp")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onCardUpdate(data) end, "onCardUpdate")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onGivePlayerGif(data) end, "onGivePlayerGif")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onGifList(data) end, "onGifList")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onNotifyInOrOutWatch(data) end, "onNotifyInOrOutWatch")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onExitWatch(data) end, "onExitWatch")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onWatchList(data) end, "onWatchList")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onMatchOver(data) end, "onMatchOver")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onCheckRankInfo(data) end, "onCheckRankInfo")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onWaitMatchOver(data) end, "onWaitMatchOver")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onNotifyHallGameStart(data) end, "onNotifyHallGameStart")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onServerNotifyTop(data) end, "onServerNotifyTop")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onNotifyBeganMatch(data) end, "onNotifyBeganMatch")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onUpdateMatchPeople(data) end, "onUpdateMatchPeople")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onWaitJoinMatch(data) end, "onWaitJoinMatch")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onEliminated(data) end, "onEliminated")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onJoinMatch(data) end, "onJoinMatch")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onVideoData(data) end, "onVideoData")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onRoomJoinBaseInfo(data) end, "onRoomJoinBaseInfo")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onNotifyPlayerCard(data) end, "onNotifyPlayerCard")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onNotifyString(data) end, "onNotifyString")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onUserRequireShowBNT(data) end, "onUserRequireShowBNT")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onUserPass(data) end, "onUserPass")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onNotifyUserOnAnOff(data) end, "onNotifyUserOnAnOff")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onNotifyQuitRoomUserID(data) end, "onNotifyQuitRoomUserID")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onUserRequestExit(data) end, "onUserRequestExit")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onNotifyUserDisMiss(data) end, "onNotifyUserDisMiss")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onNotifyUserRefusedDisMiss(data) end, "onNotifyUserRefusedDisMiss")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onRoomServerNotifyUserGang(data) end, "onRoomServerNotifyUserGang")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onSendEmoticon(data) end, "onSendEmoticon")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onServerNotifyCanHu(data) end, "onServerNotifyCanHu")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onServerBrocastDraw(data) end, "onServerBrocastDraw")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onServerBrocastPeng(data) end, "onServerBrocastPeng")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onServerBrocastMingGang(data) end, "onServerBrocastMingGang")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onServerBrocastAnGang(data) end, "onServerBrocastAnGang")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onAskDismissRoom(data) end, "onAskDismissRoom")
    --CCXNotifyCenter:listen(self,function(obj,key,data) self:onRequireDismissRoom(data) end, "onRequireDismissRoom")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onServerNotifyUserPick(data) end, "onServerNotifyUserPick")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onUserAnGang(data) end, "onUserAnGang")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onUserMingGang(data) end, "onUserMingGang")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onUserPeng(data) end, "onUserPeng")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onServerNotifyCanGang(data) end, "onServerNotifyCanGang")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onServerNotifyCanPeng(data) end, "onServerNotifyCanPeng")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onServerPickCard(data) end, "onServerPickCard")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onUserOutCard(data) end, "onUserOutCard")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onReadyState(data) end, "onReadyState")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onServerNotifyHU(data) end, "onServerNotifyHU")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onListenCard(data) end, "onListenCard")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onGameBeganNotify(data) end, "onGameBeganNotify")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onMahjongInit(data) end, "onMahjongInit")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onReConnectRoom(data) end, "onReConnectRoom")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onReqEnterRoom(data) end, "onReqEnterRoom")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onEnterRoomAndGetRoomID(data) end, "onEnterRoomAndGetRoomID")

    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onH5Pay(data) end, "onH5Pay") --h5支付 获取
    --========================================   club begin ==========================================
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:onChengYuanList(data) end, "onChengYuanList")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onClubRoomNotifyUserDisMiss(data) end, "onClubRoomNotifyUserDisMiss")
    --========================================   club end ==========================================
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onlistenCanHuCard(data) end, "onlistenCanHuCard")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onCanListenCard(data) end, "ROOM:onlistenCanHuCard")



    --[[
    if GlobalData.isRetryConnect == false then
        self.sendReady = 0
        ex_roomHandler:ReadyState()--通知服务器我已经准备好了
    end
    ]]

    --GlobalData.roomData = nil
    self.isVideo = GlobalData.roomData == nil
    --录像回放水印标签
    --self:VideoEnter()
    self.root:getChildByName("img_videoflag"):setVisible(false)
    if GlobalData.roomData then--不是回放
        self:onUserEnterRoom(GlobalData.roomData)
    else--录像回放
        self:VideoEnter()
    end
    
    GlobalData.roomData = nil
    
    if not self.isVideo and self.giflist == nil then
        ex_roomHandler:gifList()
    end

    ex_timerMgr:register(self) 
    
    if GameClient.server ~= nil then
        GameClient.server.listener = GameClient.server.listener or {}
        GameClient.server.listener[self] = self
    end
    
    self:listenTouch()
    local ui = ex_fileMgr:loadLua("app.views.NotifyUI")
    self.root:addChild(ui.new())


    --ActivityMgr
    ActivityMgr:setRoomRoot(self)
    ActivityMgr:initRoomUI()
end

function CUIGame:listenTouch()
    self.listener = cc.EventListenerTouchOneByOne:create()


    local function onTouchBegan(touch,event)
        return self:onTouchBegan(touch,event)
    end

    local function onTouchMoved(touch,event)
        self:onTouchMoved(touch,event)
    end

    local function onTouchEnded(touch,event)
        self:onTouchEnded(touch,event)
    end

    self.listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    self.listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    self.listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)

    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener, self)
end

function CUIGame:unlistenTouch()
    self:getEventDispatcher():removeEventListener(self.listener)
end

function CUIGame:onTouchBegan(touch, event)
    if self.sortT < 0.4 then
        --cclog("可以排序")
        if self.player[1] then
            self.player[1]:reSort(touch:getLocation())
        end
    end
    self.sortT = 0
    return true
end

function CUIGame:onTouchMoved(touch, event)
end

function CUIGame:onTouchEnded(touch, event)
    local point = touch:getLocation()
    --[[local data = {
        loginKey = "2000",
        userId = 10000000,
        name = "2000",
        account = "2000",
        password = "2000"
        }
    ex_roomHandler:TestMsg(data)]]
    --cclog("点击了我")   
end

function CUIGame:update(t)
    --cclog("game update")
        --显示当前时间
    self.root:getChildByName("txt_time"):setString(os.date("%H:%M"))

    -- if GameClient.server ~= nil and GameClient.server.listener and GameClient.server.listener[self] == nil then
    --     GameClient.server.listener[self] = self
    -- end

    self.sortT = self.sortT + t
    --[[
    if self.win_pre and self.win_pre.players[1].isReady == false then
    	if self.sendReady == nil then
    	   self.sendReady = 0
           ex_roomHandler:ReadyState()
    	else
            self.sendReady = self.sendReady + t
            if self.sendReady > 8 then
                self.sendReady = 0
                ex_roomHandler:ReadyState()
            end
    	end
    end
    ]]
    for i=1, 4 do
        if self.player[i] and self.player[i].isPeople then
            self.player[i]:update(t)
        end
    end

    
    if self.autoT ~= nil then
        self.autoT = self.autoT + t
        
        if self.autoT > 0.75 then
            self.autoT = nil
            if self.player and self.player[1] then
                if #self.player[1].mingpai*3 + #self.player[1].handcard == 14 then
                    local ran = math.random(1,#self.player[1].handcard)
                    local card = self.player[1].root:getChildByTag(self.player[1].handcard[ran])
                    self.player[1]:reqOutCard(card:getTag(),card.cardnum)
                end
            end
        end
    else
        if self.player and self.player[1] and #self.player[1].mingpai*3 + #self.player[1].handcard == 14 and Game_conf.auto then
            self.autoT = -1
        end
    end
    --[[
    if self.videoT >= 0 then
        self.videoT = self.videoT + t
        if self.videoT > 30 then
            self.videoT = -1
            if GameClient.server then
                CCXNotifyCenter:notify("onGameTryConnect",nil)
                GameClient:close()
                self.hT = -1
            end
        end
    end
    ]]
    self.t = self.t + t
    if self.t > 3 then
        self.t = -150
        --
    end
    
    if self.videoLogic and self.isVideoPlayer then
        self.videoLogic:update(t)
    end
    --用于上传声音完了后的回调
    if self.uploadVoideIsEnd == 1 then --正在上传声音
        self.uploadVoice_time = self.uploadVoice_time + t
        if self.uploadVoice_time > 0.1 then
            local num = cpp_uploadVoice_getEndFlag() --获取上传声音的结束标记
            if num ~= nil and num == 1 then --为1表示上传声音结束，等待Lua获取声音名字
                local name = cpp_uploadVoice_getName()
                cclog("sendEmoticon0:start sendEmoticon" .. name)
                if not CUIGame.isEnd and name ~= nil then
                    CCXNotifyCenter:notify("uploadVoiceCompled",name)
                end
                cpp_uploadVoice_resetEndFlag() --重置结束标记
                self.uploadVoideIsEnd = 0
            end
            self.uploadVoice_time = 0
        end
        --若上传声音出错，重新打开开关
        self.minterval_uploadVoiceIsEnd = self.minterval_uploadVoiceIsEnd + t
        if self.minterval_uploadVoiceIsEnd > 15 then
            self.uploadVoideIsEnd = 0
            self.minterval_uploadVoiceIsEnd = 0
        end
    else
        self.minterval_uploadVoiceIsEnd = 0
    end
    --用于语音按顺序播放
    if self.speakVoiceIsEnd == 1 then --正在说话
        self.speakVoice_time = self.speakVoice_time + t
        if self.speakVoice_time >= 0.1 then 
            if self:checkIsEndRound() == true then --这局结束了
                for i = 1, #self.speakVoiceListener do
                    if self.speakVoiceListener[i] ~= nil then
                        if self.speakVoiceNameList[i] ~= nil then --删除声音文件
                            os.remove(self.speakVoiceNameList[i])
                        end
                        self.speakVoiceListener[i] = nil
                    end
                end
                self.speakVoiceIsEnd = 0
            else --这局未结束
                if self:checkIsSpeaking() == false then --未正在播放语音
                    self:playSpeakVoice()
                end
            end
            self.speakVoice_time = 0
        end          
    end
end

function CUIGame:onMsg()
    --[[cclog("msg btn")
    if true then
        cpp_net_close(GameClient.server.sid)
        return
    end]]
    --Game_conf.auto = not Game_conf.auto

    local ui = ex_fileMgr:loadLua("app.views.EmoticonUI")
    self.root:addChild(ui.new())
    
    -- if AOVMgr:getGameMode() == AOVMgr._2D then
    --     AOVMgr:switchGameMode(AOVMgr._2_5D)
    -- elseif AOVMgr:getGameMode() == AOVMgr._2_5D then
    --     AOVMgr:switchGameMode(AOVMgr._2D)
    -- end
end

function CUIGame:onSet()
    cclog("set btn")
    local ui = ex_fileMgr:loadLua("app.views.SetUI")
    self.ctn_win:addChild(ui.new())
end

function CUIGame:onOutRoom()
    cclog("outroom btn")
    local ui = ex_fileMgr:loadLua("app.views.OutRoomUI") --isRoomOwner 是否房主，isStart 是否已开始摸牌
    local isBanker = false
    if self.isWatch == false then
        if self.win_pre then
            isBanker = self.win_pre.players[1].isBanker
        else
            isBanker = self.player[1].isBanker
        end
    else
        isBanker = GlobalData.roomCreateID == PlayerInfo.playerUserID
    end
    self.ctn_win:addChild(ui.new({scene = self, isRoomOwner = (GlobalData.roomCreateID == PlayerInfo.playerUserID), isStart = self.gameOpen}))
end


function CUIGame:onHelp()
    --[[if true then
        cpp_net_close(GameClient.server.sid)
        --UserDefault:writeFile("timeError.log",GlobalData.log)
        return 
    end]]
    if GlobalData.log == nil then
        GlobalData.log = ""
    end
    UserDefault:writeFile("timeError.log",GlobalData.log)
    local ui = ex_fileMgr:loadLua("app.views.RuleUI")
    self.root:addChild(ui.new())
end

function CUIGame:upVideoErr()
    if self.isUpVideo then
        GlobalFun:showToast("谢谢您的反馈",5)
        return
    end
    self.isUpVideo = true
    local filename = PlayerInfo.playerUserID .. "_" .. self.videoData[1].roomid .. "_" .. self.videoData[1].curr .. ".videofile"

    local path = ex_fileMgr:getWritablePath()-- .. "USFile_part" .. (math.floor((self.videoData.index-1)/3)+1)
    local wp = path .. filename
    local tableStr = json.encode(self.videoData)
    ccx_write(path .. filename,tableStr)
    cpp_uploadVoice("http://download.hongzhongmajiang.com/upload2.php",filename,path)
    cclog("上传了")
    GlobalFun:showToast("谢谢您的反馈",5)
end

function CUIGame:onMcrophone(touch,event)
    if event == TOUCH_EVENT_BEGAN then
        cclog("mcrophone began")
        if self.canSpeakNextVoice then
            self.videoName = os.time().. "a" ..PlayerInfo.playerUserID ..".amr" -- wav
            -- GlobalFun:startCreateAudio(self.videoName)
            platformExportMgr:startRecoder_audio(self.videoName , ex_fileMgr:getWritablePath()  , nil ,false)
            -- 显示
            self:createRecodschedule()
        else 
            GlobalFun:showToast("2次录音间隔过短" , Game_conf.TOAST_SHORT)
        end
    elseif event == TOUCH_EVENT_MOVED then
        cclog("mcrophone move")
    elseif event == TOUCH_EVENT_ENDED then
        cclog("mcrophone ended")
        if self.canSpeakNextVoice then
            self:endRecodschedule(not CUIGame.isEnd)
        end
    elseif event == TOUCH_EVENT_CANCELED then
        cclog("mcrophone canceled")
        self:endRecodschedule(false)
    end
end
----
function CUIGame:createRecodschedule()
    self.minterval = 0
    local scheduler = cc.Director:getInstance():getScheduler()  
    self.schedulerID = scheduler:scheduleScriptFunc(function(t)  
        self.minterval = self.minterval + t
        if self.minterval >= Game_conf.soundRecodTime then
            self:endRecodschedule(true)
        end
    end,0,false)
    
    --add
    self.ui_soundRecord = display.newCSNode("game/CUISoundRecord.csb") 
    self.root:addChild(self.ui_soundRecord)  

    local action = cc.CSLoader:createTimeline("game/CUISoundRecord.csb")
    action:play("a0",true)
    
    self.ui_soundRecord:runAction(action)   
end

function CUIGame:endRecodschedule(bool)
    if self.schedulerID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID) 
        self.schedulerID = nil
       
        self.canSend = false
        if bool and self.minterval >= 0.4 then
        	-- send
        	self.canSend = true 
        else
            GlobalFun:showToast("录音时间过短" , Game_conf.TOAST_SHORT)
        end
        -- GlobalFun:endCreteAudio(self.videoName)
        platformExportMgr:endRecoder_audio(function ( ... )
            cclog(" << endRecoder audio : " , ...)
            self:RecodeSoundComp()
        end , false);
        platformExportMgr:setAVAudioSessionCategoryAndMode(0,0)
        -- CCXNotifyCenter:notify("RecodeSoundComp",nil)
        
        self.ui_soundRecord:removeFromParent()
    end
end

function CUIGame:RecodeSoundComp()
    cclog("录音完全结束 检查等待发送 。。。。" , self.canSend , self.uploadVoideIsEnd )
    if self.canSend and self.uploadVoideIsEnd == 0 then
        local newname = string.sub( self.videoName , 1 , string.find( self.videoName , "." , 1 , true) - 1)
            .."_"..math.ceil(self.minterval) .. ".amr"
        cclog(" oldname "..self.videoName)
        cclog(" newname "..newname)
        local path = ex_fileMgr:getWritablePath() 
        cclog(" filexit check:", ex_fileMgr:isFileExist(path .. self.videoName), path .. self.videoName)
        os.rename(path .. self.videoName ,path .. newname)
        cclog(" filexit check:", ex_fileMgr:isFileExist(path .. newname), path .. newname)
        self.videoName = newname 
        
        --设置2次录音间隔
        self.canSpeakNextVoice = false
        self.minterval_speakNextVoice = 0
        local scheduler = cc.Director:getInstance():getScheduler()  
        self.schedulerID_speakNextVoice = scheduler:scheduleScriptFunc(function(t)  
            self.minterval_speakNextVoice = self.minterval_speakNextVoice + t
            if self.minterval_speakNextVoice >= 1 then
                self.canSpeakNextVoice = true
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID_speakNextVoice) 
                self.schedulerID_speakNextVoice = nil
            end
        end,0,false)
        
        --设置上传声音的开关(若上传声音出错，在update中重新打开开关)
        self.uploadVoideIsEnd = 1
        
        --test 
--        GlobalFun:playAudio(self.videoName)
        
        --上传语音文件
        cclog("上传语音:" .. self.videoName)
        cpp_uploadVoice("http://download.hongzhongmajiang.com/upload2.php",self.videoName,path)

    end
end

--下载声音
function CUIGame:downloadVoice(voiceName ,callfunc)
    self:downloadVoiceRequest(voiceName ,callfunc)
end

function CUIGame:downloadVoiceRequest(voiceName ,callfunc)
    cclog("开始下载文件 " .."http://download.hongzhongmajiang.com/voice/" .. voiceName)
    if true then
        local xhr = cc.XMLHttpRequest:new()
        xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER
        xhr:open("GET", "http://download.hongzhongmajiang.com/voice/" .. voiceName)
        local function onReadyStateChanged()
            if xhr.readyState == 4 and xhr.status == 200 then
                local response   = xhr.response
                local size     = table.getn(response)
                release_print("Http Status Code:" .. xhr.statusText .. ",size=" .. size)
                local file = io.open(ex_fileMgr:getWritablePath() .. voiceName,"wb")
                for i = 1, size do
                    file:write(string.char(response[i]))
                end
                file:close() 
                if callfunc then --开始播放语音并显示播放语音图标!!!!!!!!
                    callfunc() 
--                    self:addSpeakVoiceToList(voiceName, callfunc)
                end 
            else
                release_print("xhr.readyState is:" .. xhr.readyState .. ",xhr.status is: " .. xhr.status)
            end
            xhr:unregisterScriptHandler()
        end
        xhr:registerScriptHandler(onReadyStateChanged)
        xhr:send()
    end
end

function CUIGame:showSpeakVioce(filename)
    --cclog("文件上传完成 。。 通知玩家 ")
    --发送协议 type 0 emoji  ,  1 emojivoice   , 2 voice
    if filename ~= nil then
        cclog("文件上传完成 。。通知玩家  ok: filename=" .. filename)
        ex_roomHandler:sendEmoticon(2, filename)
    else
        cclog("文件上传完成 。。通知玩家  error: filename is nil!!!!!!!!!!!!!!!!")
    end
end

function CUIGame:addSpeakVoiceToList(voiceName, callfunc)
    self.speakVoiceCount = self.speakVoiceCount + 1
    self.speakVoiceListener[self.speakVoiceCount] = callfunc
    self.speakVoiceNameList[self.speakVoiceCount] = voiceName
    cclog("addSpeakVoiceToList1:voiceName=" .. voiceName)
    self.speakVoiceIsEnd = 1
end

function CUIGame:checkIsEndRound() --是否这局结束了
    local ret = false
    if CUIGame.isEnd == true then --房间已经解散/总结算界面显示
        ret = true
    else --房间未解散
        if self.smallSummary ~= nil then --小结界面显示
            ret = true
        end
    end
    return ret
end

function CUIGame:checkIsSpeaking() --检查当前是否有正在播放语音
    local ret = false
    --检查玩家头像区的语音图标
    for i =1, 4 do
        if self.player[i] ~= nill and self.player[i].pinfo ~= nill then
            if self.player[i].pinfo:getChildByTag(SPEAK_TAG) ~= nil then --对应item_speak.lua
                ret = true
            end
        end
    end
    --检查中心区上下左右的表情语音图标
    --[[if ret == false and self.win_pre ~= nill then
        for i =1, 4 do
            if self.win_pre.root:getChildByName("ctn_center"):getChildByName(string.format("ctn_%d",i)):getChildByTag(SPEAK_TAG) ~= nill then
                ret = true
            end
        end
    end]]
    --检查是否在上传录音中
    --[[if ret == false and self.uploadVoideIsEnd == 1 then
        ret = true
    end]]
    return ret
end

function CUIGame:playSpeakVoice() --播放语音
    for i =1, #self.speakVoiceListener do
        if self.speakVoiceListener[i] ~= nil then 
            self.speakVoiceListener[i]()
            self.speakVoiceListener[i] = nil
            break
        end
        if i == #self.speakVoiceListener then
            self.speakVoiceIsEnd = 0
        end
    end
end

function CUIGame:showMyEmoji(index)
    cclog("--- showMyEmoji ")
    if self.player[1] == nil then
        self.win_pre:ShowEmoji(1,index)
    else
        self.player[1]:ShowEmoji(index)
    end
    --发送协议 type 0 emoji  ,  1 emojivoice
    ex_roomHandler:sendEmoticon(0 ,index) 
end

function CUIGame:showMyEmojiVoice(index)
    cclog("--- showMyEmojiVoice ")
    if self.player[1] == nil then
        self.win_pre:ShowEmojiVoice(1,index)
    else
        self.player[1]:ShowEmojiVoice(index)
    end
    --发送协议
    ex_roomHandler:sendEmoticon( 1 ,index)
end

function CUIGame:setRoomRule()
    local txt = ""
    -- txt = GameRule.isMiLuoHongZhong == 1 and (txt == "" and txt .. "汨罗红中" or txt .. " 汨罗红中") or txt
    -- txt = GameRule.isQiXiaoDui == 1 and (txt == "" and txt .. "七小对" or txt .. " 七小对") or txt

    txt = GameRule:getRuleText(txt, true, self.isVideo)
    self.root:getChildByName("room_info"):getChildByName("rule_txt"):setString(txt)
end

function CUIGame:setRoomID()
    self.root:getChildByName("room_info"):getChildByName("room_id"):setString(string.format("%06d",GlobalData.roomID))
    self.root:getChildByName("room_info3"):getChildByName("room_id"):setString(string.format("%06d",GlobalData.roomID))
end

function CUIGame:setRoomZaMa()
    local str = ""
    -- if GameRule.ZhaMaCNT == 1 then
    --     str =  "一码全中"
    --     self.root:getChildByName("room_info"):getChildByName("room_zama"):setString(str)
    --     -- self.root:getChildByName("room_info3"):getChildByName("room_zama"):setString("一码全中")
    -- else
    --     str = string.format("扎%d个码",GameRule.ZhaMaCNT)
    --     self.root:getChildByName("room_info"):getChildByName("room_zama"):setString(str)
    --     -- self.root:getChildByName("room_info3"):getChildByName("room_zama"):setString(string.format("扎%d个码",GameRule.ZhaMaCNT))
    -- end

    -- if GameRule.isMiLuoHongZhong == 1 then
    --     local tmp = str ~= "" and " 汨罗红中" or "汨罗红中"
    --     str = str .. tmp
    -- end

    -- if GameRule.isQiXiaoDui == 1 then
    --     local tmp = str ~= "" and " 七小对" or "七小对"
    --     str = str .. tmp
    -- end

    local str = GameRule:getZhaMaText(GameRule.ZhaMaCNT, self.root:getChildByName("room_info"):isVisible())
    -- str = GameRule:getRuleText(str)
    self.root:getChildByName("room_info"):getChildByName("room_zama"):setString(str)


    -- self.root:getChildByName("room_info3"):getChildByName("room_zama"):setString(str)
    str = GameRule:getRuleText(str,nil, self.isVideo)
    self.root:getChildByName("room_info3"):getChildByName("room_zama"):setString(str)

end

function CUIGame:setRoomPass()
    self.root:getChildByName("room_info"):getChildByName("room_pass"):setString(string.format("%d/%d局",GameRule.cur_GameCNT,GameRule.MAX_GAMECNT))
    self.root:getChildByName("room_info3"):getChildByName("room_pass"):setString(string.format("%d/%d局",GameRule.cur_GameCNT,GameRule.MAX_GAMECNT))
end

function CUIGame:setRoomCardNum(num)
    self.root:getChildByName("room_info"):getChildByName("room_cardnum"):setString(string.format("剩%d张",num))
    self.root:getChildByName("room_info3"):getChildByName("room_cardnum"):setString(string.format("剩%d张",num))
end

function CUIGame:showGameBTN(data)
	--self.root:getChildByName("ctn_win"):addChild(BaseBTN.new(data))
    self.win_btn:setBtn(data)
end

function CUIGame:playHuAction(pos,flag,userid)
    ex_audioMgr:playEffect(string.format("sound/huwind.mp3"))

    if userid then
        pos = 1
        for i=1,4 do
            if self.player[i].openid == userid then
                pos = i
                break
            end
        end
    end
    
    local hu = BaseOnce.new(Effect_conf["eff_zimohu"])
    hu:setPosition(display.width/2,display.height/2)
    self.ctn_eff:addChild(hu, g_CUIPlayOnce_TAG)
    hu:setTag(g_CUIPlayOnce_TAG)
    
    local hu1 = BaseHu.new(pos,self,flag)
    hu1:setPosition(display.width/2,display.height/2)
    self.ctn_eff:addChild(hu1)
    
end

function CUIGame:playQiangGanghu()
    local qgh = BaseQGH.new(self)
    self.ctn_eff:addChild(qgh)
end

function CUIGame:showZhaMa()
    local BaseZM = ex_fileMgr:loadLua("app.views.game.CUIGame_ZhaMa")
    self.ctn_win:addChild(BaseZM.new(self.zhama))
end

function CUIGame:showSmallSummary()
    cclog("CUIGame:showSmallSummary >>>")
    cclog(debug.traceback())
    local BaseSS = ex_fileMgr:loadLua("app.views.game.CUIGame_SmallSummary")
    self.ctn_win:addChild(BaseSS.new(self.smallSummary,self))
end

function CUIGame:showAllSummary()
    local BassAs = ex_fileMgr:loadLua("app.views.game.CUIGame_AllSummary")
    self.ctn_win:addChild(BassAs.new(self))
end

function CUIGame:onTestMsg(res)
    local a = 10
end

function CUIGame:showGifList(data)
    local gif_list = ex_fileMgr:loadLua("app.views.watch.WatchGifArea").new()
    gif_list:initParams(data)
    gif_list:setName("gif_list")
    self.ctn_win:addChild(gif_list)
end

function CUIGame:hideGifList()
    local gif_list = self.ctn_win:getChildByName("gif_list")
    if gif_list ~= nil then
        gif_list:removeFromParent()
    end
end

--观战------------
function CUIGame:onGZSit()--坐下
    ex_roomHandler:changeSitOrUp(1)
end

function CUIGame:onGZUp()--站起
    ex_roomHandler:changeSitOrUp(0)
end

function CUIGame:onGZ()
    self:setGuangZhong(not self.root:getChildByName("ctn_gz"):isVisible())
end

function CUIGame:setSitBTNVisible(b)
    self.root:getChildByName("btn_gz_sit"):setVisible(b)
end

function CUIGame:setUpBTNVisible(b)
    self.root:getChildByName("btn_gz_up"):setVisible(b)
end

function CUIGame:setGZMSFlag(b)
    self.root:getChildByName("gzms_flag"):setVisible(b)
end

function CUIGame:setGuangZhong(b)
    self.root:getChildByName("ctn_gz"):setVisible(b)
    if b then
        
        local no = self.root:getChildByName("ctn_gz"):getChildByTag(100)
        if no == nil then
            no = ex_fileMgr:loadLua("app.views.watch.CUIWatchArea").new()
            self.root:getChildByName("ctn_gz"):addChild(no)
            no:setTag(100)
        end

        no:setWatchList(self.watchPlayer,self.isWatch)
    else
        self.root:getChildByName("ctn_gz"):removeAllChildren()
    end
end



--网络部分---------------------------------------------------------------------------
function CUIGame:dealSurplusNum(res)
    local num = GlobalFun:getCardSum()
    local gameOpen = false
    for i=1,4 do
        if res.player[i] then
            if res.player[i].handcard then
                num = num - #res.player[i].handcard
            end
            if res.player[i].discards then
                num = num - #res.player[i].discards
                if #res.player[i].discards > 0 then
                    gameOpen = true
                end
            end
            
            if res.player[i].mingpai then
                for j = 1,#res.player[i].mingpai do
                    num = num - #res.player[i].mingpai[j]
                    gameOpen = true
                end
            end
        end
    end
    return num,gameOpen
end

function CUIGame:dealWatchMode(res)
    self.isWatch = res.canWatch == 1--如果是不能观战模式 则一定不是在观战
    self.root:getChildByName("btn_gz"):setVisible(res.canWatch == 1)
    
    for i=1,4 do--看玩家列表里有没有自己
        if #res.player == 0 then
            self.isWatch = true
            break
        else
            if res.player[i] and res.player[i].id == PlayerInfo.playerUserID then--玩家列表有自己 不是在观战
                self.isWatch = false
                break
            end
        end
    end
    -- local isOpen = res.player[1] and #res.player[1].handcard ~= 0

    local isOpen = true
    for k = 1, self.playerNum do
        if not res.player[k] then
            isOpen = false
            break
        end
    end


    self:setSitBTNVisible(self.isWatch and isOpen ~= true)
    self:setUpBTNVisible(res.canWatch == 1 and not self.isWatch and isOpen ~= true)
    -- self:setGZMSFlag(self.isWatch)
    self:setGuangZhong(false)
    self.root:getChildByName("ctn_menu"):getChildByName("btn_msg"):setVisible(not self.isWatch)
    self.root:getChildByName("ctn_mcrophone"):getChildByName("btn_mcrophone"):setVisible(not self.isWatch)
end

--我是不是观众
function CUIGame:checkMeIsWatch()
    local i_am_watch = true
    for k,v in pairs(self.player or {}) do
        cclog("xxxx >>>>>>>>>", v.id, PlayerInfo.playerUserID)
        if v.id == PlayerInfo.playerUserID then
            i_am_watch = false
            break
        end
    end
    return i_am_watch
end

function CUIGame:onUserEnterRoom(res)

    if self.gameOpen == true and GlobalData.isRetryConnect == false and self.reqCard == false then
        --return
    end
    if GlobalData.isReqRoom and res.canWatch == 1 then--是自己主动请求的
        GlobalData.isReqRoom = false
        ex_roomHandler:watchList()
    end
    --self.videoT = -1
    cclog("CUIGame:onUserEnterRoom  >>>> res.canWatch >>>>>>>>>>>>>> " , res.canWatch)
    GameRule.ZhaMaCNT = res.zhama%10
    self.playerNum = (res.zhama-GameRule.ZhaMaCNT)/10

    --这个函数里面用了 playerNum
    self:dealWatchMode(res)

    self:showYaoQingChengYuan(res)
    
    self.reqCard = false
    GlobalData.isRetryConnect = false
    GlobalFun:closeNetWorkConnect()
    GlobalData.roomID = res.roomID
    GameRule.MAX_GAMECNT = res.gamecnt
    GameRule.cur_GameCNT = res.currPass
    GameRule.isQiXiaoDui = res.isQiXiaoDui
    GameRule.isMiLuoHongZhong = res.isMiLuoHongZhong
    -- GameRule.ZhaMaCNT = res.zhama%10
    -- self.playerNum = (res.zhama-GameRule.ZhaMaCNT)/10
    self.root:getChildByName("room_info"):setVisible(self.playerNum == 4)
    self.root:getChildByName("room_info3"):setVisible(self.playerNum == 3)

    self.tmp_gameOpen = ""
    self.disTime = res.disTime
    self:setRoomRule()
    self:setRoomID()
    self:setRoomZaMa()
    self:setRoomPass()
    self.surplusNum,self.tmp_gameOpen = self:dealSurplusNum(res)
    self:setRoomCardNum(self.surplusNum)
    if #res.player == 0 or (GameRule.cur_GameCNT == 1 and #res.player[1].handcard == 0)  then--新的开始
        --转化位置 让自己始终在1号位
    --    self.win_pre:cleanUser()
        for i =1,#res.player do
            if res.player[i].id == PlayerInfo.playerUserID then
                self.offset = res.player[i].pos-1
                if res.player[i].isReady == false then
                    --ex_roomHandler:ReadyState()
                end
                break
            end
        end
        
        for i=1,#res.player do
            self.win_pre:userEnter(res.player[i],self.offset)
        end
    else
        cclog("重进啦")
        if self.win_pre then
            self.win_pre:removeFromParent()
            self.win_pre = nil
        end
        self:setGZMSFlag(self.isWatch)
        
        self:onRetryEnterRoom(res)
    end

    --copy 按钮
    self.root:getChildByName("ctn_menu"):getChildByName("btn_copy"):addClickEventListener(function()
        local maStr = (GameRule.ZhaMaCNT or 0) > 0 and (" " .. GameRule:getZhaMaText(GameRule.ZhaMaCNT or 0)) or ""
        local str = string.format("房间号:\"%d\", %d局,%s", GlobalData.roomID or 0, GameRule.MAX_GAMECNT or 0, maStr)
        str = GameRule:getRuleText(str)
        str = str .. " " .. string.format("%d人房间",self.playerNum or 0) 
        
        local tb = {}
        tb.msg = str
        tb.stype = "房间"
        tb.params = {GlobalData.roomID , GlobalData.game_product}
        local str = GlobalFun:makeCopyStr(tb)

        SDKController:getInstance():copy_To_Clipboard(str)
        GlobalFun:showToast("复制房间号成功",Game_conf.TOAST_SHORT)
    end)

    if res.isGPS and not self.isWatch then 
        self:addGpsModel()
    else
        self.ctn_gps = self.root:getChildByName("ctn_gps")
    end
end

function CUIGame:onRetryEnterRoom(res)
    cclog("进入房间********************************************************")
    self.root:getChildByName("ctn_one"):removeAllChildren()
    self.root:getChildByName("ctn_two"):removeAllChildren()
    self.root:getChildByName("ctn_three"):removeAllChildren()
    self.root:getChildByName("ctn_four"):removeAllChildren()
    self.root:getChildByName("ctn_pre"):removeAllChildren()
    self.ctn_eff:removeAllChildren()
    self.ctn_win:removeAllChildren()
    self.smallSummary = nil
    self.askFrame = nil
    self.win_btn = nil
    self.win_ok = nil
    self.win_btn = BaseBTN.new()
    self.ctn_win:addChild(self.win_btn)
    self.win_btn:setVisible(false)
    self.listen_cards = nil
    self.canlisten_cards = nil

    self.win_listen:setVisible(false)
    self.canwin_listen:setVisible(false)

    self.gameOpen = true
    self.player = {}

    for i =1, 4 do
        self.player[i] = BasePlayer.new(self)
    end
    self.root:getChildByName("ctn_one"):addChild(self.player[1])
    self.root:getChildByName("ctn_two"):addChild(self.player[2])
    self.root:getChildByName("ctn_three"):addChild(self.player[3])
    self.root:getChildByName("ctn_four"):addChild(self.player[4])
    
    local tmp_players = {{},{},{},{}}
    for i =1,#res.player do
        if res.player[i].id == PlayerInfo.playerUserID then
            self.offset = res.player[i].pos-1
            break
        end
    end
    local isReadyState = false
    for i=1,#res.player do
        local showp = (res.player[i].pos - self.offset +3)%4+1
        if self.playerNum == 3 then
            if showp == 3 then
                if res.player[i].pos == 3 then
                    showp = 4
                elseif res.player[i].pos == 1 then
                    showp = 2
                end
            end
        end
        tmp_players[showp] = res.player[i]
        if res.player[i].isReady == false then
            isReadyState = true
        end
    end


    self:tryRecoveryMeCard(tmp_players[1].handcard)--尝试恢复重连前的牌
    
    if isReadyState then
        if tmp_players[1].isReady == false then
            --ex_roomHandler:ReadyState()
        end
    else
        if res.listen then
            tmp_players[1].listencard = res.listen
        end
        self:onListenCard(tmp_players[1].listencard,true)
    end
    
    for i=1,4 do
        local isPlayer = self.playerNum == 3 and i == 3
        if tmp_players[i] and not isPlayer then
        -- if tmp_players[i] then
            local cards = {}--tmp_players[i].handcard
            cclog("CUIGame:onRetryEnterRoom >>>", i, tmp_players[i].handcard)
            for j=1,#tmp_players[i].handcard do
                --cclog("服务器数据  " .. tmp_players[i].handcard[j].value .. "   本地数据  " .. GlobalFun:ServerCardToLocalCard(tmp_players[i].handcard[j].value))
                cards[#cards + 1] = tmp_players[i].handcard[j].value
                
            end
            cclog("")
            cclog("")
            local discards = {}-- tmp_players[i].discards
            for j= 1,#tmp_players[i].discards do
                discards[#discards + 1] = tmp_players[i].discards[j].value
            end
            local mingcards = tmp_players[i].mingpai
            if isReadyState then
                cards = {}
                discards = {}
                mingcards = {}
            else
                
            end
            local isStart = false
            local qsp = GlobalFun:getCardSum() - 13*self.playerNum - 1
            if self.surplusNum == qsp and self.tmp_gameOpen == false then
                isStart = true
            end
            self.player[i]:setBaseData({isStart = isStart,pos = i,cards = cards,discards=discards,mingpai = mingcards,playerinfo = tmp_players[i]})
            if isStart then
                self.player[i]:setOpen()
            end
        end
        
    end
    
    if #tmp_players[1].handcard == 0 or isReadyState then--准备阶段
        if self.win_ok == nil then
            self.win_ok = BaseOK.new()
            self.win_ok:setOKVisible(1,tmp_players[1].isReady)
            if tmp_players[1].isReady == false then
                ex_roomHandler:ReadyState()
            end
            self.root:getChildByName("ctn_pre"):addChild(self.win_ok)
        end
        for i=1,4 do
            self.win_ok:setOKVisible(i,tmp_players[i].isReady)
        end
        --self.isReady = 
    else
        for i=1,#tmp_players do
            if tmp_players[i].id == res.outCardID  then
                self.flag = i
                self.light_flag =  i
                if #tmp_players[i].handcard%3 ~= 2 then
                    self.flag = 0
                end
            end
        end
    end
    
    if self.isVideo == false then
        ex_roomHandler:userRequireShowBTN()
    end
    
    self:sendUpCard("重进初始化牌")
    --self:checkOtherCards()
    --self:checkHyalineCardNum()

    local value = MessageCache:popCache("ROOM:onAskDismissRoom")
    if value then
        self:onAskDismissRoom(value)
    end

    local value = MessageCache:popCache("ROOM:onNotifyUserRefusedDisMiss")
    cclog("value >>>>>>>>>>>")
    print_r(value)
    if value then
        self:onNotifyUserRefusedDisMiss(value)
    end

    local value = MessageCache:popCache("ROOM:onFengHuCards")
    if value then
        self:onFengHuCards(value)
    end

    self:refreshGpsUI()
end

function CUIGame:onReadyState(res)
    if true then
        --return
    end
    if self.win_pre == nil then
        if self.win_ok == nil then
            self.win_ok = BaseOK.new()
            --self.win_ok:setOKVisible(1,true)
            self.root:getChildByName("ctn_pre"):addChild(self.win_ok)
        end
        
        for i=1,4 do
            if self.player[i].openid == res.readyID then
                self.win_ok:setOKVisible(i,true)
                if self.smallSummary == nil and i ~= 1 then
                    --ex_roomHandler:ReadyState()--再发一次准备
                end
                break
            end
        end
    else
        self.win_pre:onUserReady(res.readyID)
        if self.win_pre.players[1].isReady == false and res.readyID ~= PlayerInfo.playerUserID then--不是自己的准备消息
            --ex_roomHandler:ReadyState()--再发一次准备
        end  
    end
end

function CUIGame:onMahjongInit(res)--麻将初始化
    if self.player and self.player[1] and #self.player[1].handcard > 0 then--如果收到2次初始化
        local n_c = {}
        for t = 1,#res.cards do
            n_c[t] = GlobalFun:ServerCardToLocalCard(res.cards[t])
        end
        if (#res.cards) % 3 == 2 then
            self.flag =  1
            self.light_flag = 1
        end
        self:onNotifyPlayerCard(n_c)
        return
    end
    if true or self.gameOpen == false then--重进的不处理这条消息
        self.gameOpen = true
        CCXNotifyCenter:notify("NotifyGameOpen",nil)
        if self.win_ok == nil then
            self.win_pre:notifyOpenGame(res)
        else
            for i=1,4 do
                self.player[i].isBanker = res.BankerID == self.player[i].openid
            self.player[i]:setZhuangVisible()
            end
            self.win_ok:removeFromParent()
            self.win_ok = nil
            self:basePlayers(res,1)
        end
        
        self.oldCard = {}
        for i=1,#res.cards do
            self.oldCard[i] = GlobalFun:ServerCardToLocalCard(res.cards[i])
        end
        
        
        self.surplusNum = GlobalFun:getCardSum() - 4*13 - 1
        self:setRoomCardNum(self.surplusNum)
    end
end

function CUIGame:basePlayers(res,enterFlag)

    local tmpcards = {}
    cclog("初始化...")
    
    
    
    for i=1,#res.cards do
        cclog("服务器下发的   " .. res.cards[i])
        tmpcards[#tmpcards+1] = GlobalFun:ServerCardToLocalCard(res.cards[i])
    end

    local cards = {tmpcards,{1,1,1,1,1,1,1,1,1,1,1,1,1},{1,1,1,1,1,1,1,1,1,1,1,1,1},{1,1,1,1,1,1,1,1,1,1,1,1,1}}
    
    if enterFlag == 0 then
        if res.players[2].isBanker then
            cards[2][#cards[2]+1] = 1
        elseif res.players[3].isBanker then
            cards[3][#cards[3]+1] = 1
        elseif res.players[4].isBanker then
            cards[4][#cards[4]+1] = 1
        end
    else
        if self.player[2].isBanker then
            cards[2][#cards[2]+1] = 1
        elseif self.player[3].isBanker then
            cards[3][#cards[3]+1] = 1
        elseif self.player[4].isBanker then
            cards[4][#cards[4]+1] = 1
        end
        
    end
    for i=1,4 do
        local t_p = nil
        if enterFlag == 0 then
            t_p = res.players[i]
        end
        self.player[i]:setBaseData({isStart = true,pos = i,cards = cards[i],playerinfo = t_p})
    end
    
    for i=1,4 do
        if self.player[i].isBanker == true then
            self.flag = i
            self.light_flag = i
        end
        self.player[i]:setOpen()
    end

    self:sendUpCard("麻将初始化")
    --self:checkHyalineCardNum()
    
end

function CUIGame:createUser(res)
    if self.win_pre then
        self.win_pre:removeFromParent()
        self.win_pre = nil
    end
    for i =1, 4 do
        self.player[i] = BasePlayer.new(self)
    end
    self.root:getChildByName("ctn_one"):addChild(self.player[1])
    self.root:getChildByName("ctn_two"):addChild(self.player[2])
    self.root:getChildByName("ctn_three"):addChild(self.player[3])
    self.root:getChildByName("ctn_four"):addChild(self.player[4])
    
    self:basePlayers(res,0)
    
end

function CUIGame:onGameBeganNotify(pid)--自己出牌
    self.flag = 1
    
    local num = #self.player[1].mingpai*3 + #self.player[1].handcard
    if num ~= 14 and not self.isWatch then
        ex_roomHandler:reqEnterRoom(GlobalData.roomKey)
    end

    if Game_conf.auto then
        self.autoT = -4
    end
    --[[
    if Game_conf.auto then
        self.hbScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(t)  
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.hbScheduler)
            self.hbScheduler = nil
            local card = self.player[1].root:getChildByTag(self.player[1].handcard[#self.player[1].handcard])
            self.player[1]:reqOutCard(card.tag,card.cardnum)
        end,1,false)
    end
    ]]
    
    --self.light_flag = 1
end

function CUIGame:onServerPickCard(res)--
    cclog("摸了一张牌")
    
    self.player[1].serverOutCartTag = nil
    self.player[1].serverOutCartValue = nil
    self.player[1]:serverSendCard({num = GlobalFun:ServerCardToLocalCard(res.cardnum)})
    
    self.oldCard[#self.oldCard + 1] =  GlobalFun:ServerCardToLocalCard(res.cardnum)
    
    self.surplusNum = self.surplusNum - 1
    self:setRoomCardNum(self.surplusNum)
    local num = #self.player[1].mingpai*3 + #self.player[1].handcard
    self.currValue = GlobalFun:ServerCardToLocalCard(res.cardnum)--新摸到的牌
    if num ~= 14 then
        --GlobalFun:showError("牌数不对",nil,nil,1)
        --GlobalFun:showToast("牌数不对" , Game_conf.TOAST_SHORT)
        ex_roomHandler:reqEnterRoom(GlobalData.roomKey)
        return
    end

    self:sendUpCard("服务器分发一张牌")
    --self:checkHyalineCardNum()
    self.flag = 1
    self.light_flag = 1
    if Game_conf.auto then
        self.autoT = 0
    end
    --[[
    if Game_conf.auto then
        local card = self.player[1].root:getChildByTag(self.player[1].handcard[#self.player[1].handcard])
        self.player[1]:reqOutCard(card.tag,card.cardnum)
    end
    ]]
end

function CUIGame:onServerNotifyUserPick(res,value)
--有玩家摸到一张牌
    local start = 2
    if self.isWatch then
        start = 1
    end
	for i=start,4 do
	   if self.player[i].openid == res.userid then
	        if self.isVideo == false or self.isVideo == nil or value == nil then
	           value = 1
	        end
            self.player[i]:serverSendCard({num = value})
            self.flag = i
            self.light_flag = i

            self.surplusNum = self.surplusNum - 1
            self:setRoomCardNum(self.surplusNum)
	   end
	end
end

function CUIGame:onUserOutCard(res)
--有玩家出牌
  self.canwin_listen:setVisible(false)
  self.player[1]:hidePointerOnCard()
  self:highlightedCard(0, false)

    for i=1,4 do
        if res.userID == self.player[i].openid then
            if i == 1 and self.isWatch ~= true then
                if self.isVideo then
                    self.player[1].serverOutCartTag = -100
                    self.player[1].serverOutCartValue = -10
                end
                local tmpcard = self.player[1].root:getChildByTag(self.player[1].serverOutCartTag)
                if tmpcard == nil or tmpcard.cardnum ~= GlobalFun:ServerCardToLocalCard(res.value) then--如果跟本地的对不上  以服务器的为准
                    self.player[1].serverOutCartTag = nil 
                    self.player[1].serverOutCartValue = nil
                    for t=1,#self.player[1].handcard do
                        local t_c = self.player[1].root:getChildByTag(self.player[1].handcard[t])
                        if t_c.cardnum == GlobalFun:ServerCardToLocalCard(res.value) then
                            self.player[1].serverOutCartTag = self.player[1].handcard[t]
                            self.player[1].serverOutCartValue = t_c.cardnum
                            break
                        end
                    end
                end
                
                if self.player[1].serverOutCartTag == nil or self.player[1].serverOutCartValue == nil then--牌错了
                    self.reqCard = true
                    ex_roomHandler:notifyPlayerCard()
                    return
                end        
                
                self.player[1]:outCard(self.player[1].serverOutCartTag,self.player[1].serverOutCartValue)
                
                for var=1,#self.oldCard do
                    if self.oldCard[var] == self.player[1].serverOutCartValue then
                        table.remove(self.oldCard,var)
                        break
                    end
                end
                self.player[1].serverOutCartTag = nil
                self.player[1].serverOutCartValue = nil
                self:sendUpCard("自己出了一张牌")
                --self:checkHyalineCardNum()
            else
                local lapnum = 14 - (#self.player[i].mingpai*3 + #self.player[i].handcard)
                if lapnum > 0 then
                    for m = 1,lapnum do
                        self:onServerNotifyUserPick({userid = self.player[i].openid})
                        cclog("补发了一张牌")
                    end
                end
                
                self.player[i]:moniOutCart({num = GlobalFun:ServerCardToLocalCard(res.value),pos = res.index})
                
                if #self.player[1].mingpai*3 + #self.player[1].handcard < 13 then--自己牌数不对
                    self.reqCard = true
                    ex_roomHandler:notifyPlayerCard()
                end
            end
            --self.light_flag = i
        end
    end
end

function CUIGame:onListenCard(res,hasTranslate)--听牌通知
    local tb = {}
    local str = ""
    if hasTranslate == true then
        tb = res
        for i=1,#res do
        	str = str .. GlobalFun:localCardToServerCard(res[i]) .. ","
        end
    else
        for i=1,#res.cards do
            tb[#tb + 1] = GlobalFun:ServerCardToLocalCard(res.cards[i])
            str = str .. res.cards[i] .. ","
        end
    end
    if str ~= "" then
        str = "服务器下发的数据:" .. str
        self.root:getChildByName("txt_listen"):setString(str)
    else
        self.root:getChildByName("txt_listen"):setString("")
    end
    --local tb = {}
    local tb1 = {}
    for i=1,#tb do
        local index = 1
        for j=1,#tb1 do
            index = #tb1 + 1
            if tb[i] < tb1[j] then
                index = j
                break
            end
        end
        table.insert(tb1,index,tb[i])
    end

    self.listen_cards = tb1
    self.win_listen:setShowCards(tb1)
end

function CUIGame:getListenCards()
    return self.listen_cards
end

function CUIGame:onCanListenCard(res)--听牌通知2
    self.canlisten_cards = res
    --print_r(self.canlisten_cards)
    --self.canwin_listen:setShowCards(tb1)
 
    --显示可点击查看可胡的牌的箭头
    self.player[1]:showPointerOnCard(self.canlisten_cards)
end

function CUIGame:getCanListenCards()
    return self.canlisten_cards
end

function CUIGame:onServerNotifyHU(res)--通知玩家胡牌
    cclog("*************************玩家胡牌")
    CCXNotifyCenter:notify("BtnCleanAll",nil)
    --cclog("小数据下发")
    self.winBean = res.winBean
    self.zhama = res.zhamaBean
    self.winValue = res.winValue
    self.smallSummary = {}
    self.smallSummary.p_data = res.player
    self.smallSummary.remaining = res.remaining
    self.huPaiType = res.huPaiType
    self.fangpao_player = res.fangpao_player
    self.player_hu_info = {}
    self.player_hu_info = res.player_hu_info
    --[[if res.winBean == nil or #res.winBean == 0 then--流局
        
    end
    ]]
    
    --写数据到配置文件
    local tmp_data = {}
    tmp_data.roomID = GlobalData.roomID
    tmp_data.gameCnt = GameRule.MAX_GAMECNT
    tmp_data.name = {self.player[1].name,self.player[2].name,self.player[3].name,self.player[4].name}
    tmp_data.curr = GameRule.cur_GameCNT
    tmp_data.zhama = GameRule.ZhaMaCNT
    tmp_data.score = {}
    --[[
    if self.videoData and self.videoData[1] and self.videoData[1].curr == GameRule.cur_GameCNT then
        --self.videoData[1].curr = nil
        --self.videoData[1].roomID = nil--
        tmp_data.videoData = self.videoData
    else
        tmp_data.videoData = nil
    end
    ]]
    for i=1,4 do
        local finduser = false
        for j=1,#res.player do
            if self.player[i].id == res.player[j].playerid then
                tmp_data.score[i] = res.player[j].score
                finduser = true
                break
            end
        end
        if finduser == false and self.player[i].isPeoPle == true then
            local sp ="小结算没找到对应id   " .. res.player[1].playerid .. " , " .. res.player[2].playerid .. " , " .. res.player[3].playerid .. "  ,  " .. res.player[4].playerid
            GlobalFun:showError(sp,nil,nil,1)
        end
    end


    cclog("res.huPaiType  >>>.",res.huPaiType)
    cclog(">>>>>>>>>>>>>>>> res.player_hu_info ")
    print_r(res.player_hu_info)
    local hav_hu_type = false

    if next(res.player_hu_info) then
        local tmp = {}
        for i =1, 4 do
            local id = self.player[i].openid
            if id then
                -- cclog("id >>>", id, type(id))
                tmp[id] = i
            end
        end


        for k,v in ipairs(res.player_hu_info) do
            cclog("tmp[v.userid] >>>>",tmp[v.userid], v.userid)
            local eff = false
            if tmp[v.userid] then
                for m,n in ipairs(v.info or {}) do
                    cclog("n.hu_type >>>>>>" ,n.hu_type)
                    
                    if n.hu_type == 0 then
                        -- self:playHuAction(tmp[v.userid], flag)
                        hav_hu_type = true
                        eff = true
                        self:playQiXiaoDui()
                        break
                    end

                end
            end
            if eff then break end
        end
    end

    --self.videoData = nil
    if res.huPaiType == 0 then --流局
        self:showSmallSummary()
    elseif res.huPaiType == 1 then


        if next(res.player_hu_info) then
        else
            --没有特殊牌型，只播放胡牌
            self:processBaseHuEffect()
        end

    elseif res.huPaiType == 3 then
        self:processPao(res.winBean, res.fangpao_player, hav_hu_type)
        
    else
        self:playQiangGanghu()
    end
    

    if self.isWatch ~= true then
        LocalDataFile:writeSmallScore(tmp_data, self.originType, self.originKey)
    end
    CCXNotifyCenter:notify("ActivitysStarGotLock", true) -- 活动任务显示上锁
end

function CUIGame:processBaseHuEffect()
     if not self.ctn_eff:getChildByTag(g_CUIPlayOnce_TAG) then
        local flag = true
        for i=1,#self.winBean do
            for j=1,4 do
                if self.winBean[i] == self.player[j].openid then
                    self:playHuAction(j,flag)
                    flag = false
                end
            end
        end
    end
end

function CUIGame:processPao(winBean, fangpao_player, hav_hu_type)
    for k,v in pairs(winBean) do
        for i = 1, 4 do
            if  self.player[i] and self.player[i].openid == v then
                self:playDianPao(self.player[i])
            end
        end
    end
    if fangpao_player > 0 then
        for i = 1, 4 do
            if  self.player[i] and self.player[i].openid == fangpao_player then
                self:playFangPao(self.player[i], hav_hu_type)
            end
        end
    end
end

function CUIGame:playDianPao(player)
    local dp = BaseDP.new(self,player)
    self.ctn_eff:addChild(dp)
end

function CUIGame:playFangPao(player, hav_hu_type)
    local fp = BaseFP.new(self,player, hav_hu_type)
    self.ctn_eff:addChild(fp)
end

function CUIGame:playQiXiaoDui()
    local qxd = BaseQXD.new(self)
    self.ctn_eff:addChild(qxd)
end

function CUIGame:onServerNotifyCanPeng(res)--通知玩家可以碰
    self.light_flag = 1
    self.player[1]:MeCanPeng(GlobalFun:ServerCardToLocalCard(res.value),res.userID)
end

function CUIGame:onServerNotifyCanGang(res)--通知玩家可以杠
    self.light_flag = 1
    self.player[1]:MeCanGang(GlobalFun:ServerCardToLocalCard(res.value),res.userID)
end

function CUIGame:onRoomServerNotifyUserGang(res)
    for i=1,#res.cards do
        self.player[1]:MeCanGang(res.cards[i],self.player[1].openid)
    end
end

function CUIGame:onUserPeng(res)--notifyPeng(res)--收到碰的消息
    local value = GlobalFun:ServerCardToLocalCard(res.value)
    local other_pos,peng_pos = 1,1
    for i=1,4 do
        --cclog(string.format("%d  opend = %d",i,self.player[i].openid))
        if self.player[i].openid == res.pengID then
            cclog("onUserPeng 111>>>> ",self.player[i].openid, res.pengID)
            peng_pos = i
        end
        
        if self.player[i].openid == res.outID then
            cclog("onUserPeng 111>>>> ",self.player[i].openid, res.outID)
            other_pos = i
        end
    end
    cclog("onUserPeng 222>>>> ",other_pos , peng_pos)
    for k,v in pairs(self.player) do
        cclog("sss >>>", v.openid, k)
    end


    if other_pos ~= peng_pos then --碰别人的牌才需要把这张牌从废弃牌堆里移走
        self.player[other_pos]:removeDisCard(value)
    end
    self.player[peng_pos]:PengCard(value,other_pos == peng_pos)
    if peng_pos == 1 then
        if self.isVideo then
            self.win_btn:cleanAll()
        end
        self:sendUpCard("客户端发生了碰牌")
    end
    self.flag = peng_pos
    self.light_flag = peng_pos
    
end

function CUIGame:onUserMingGang(res)--明杠的消息
--[[
    if data.other_pos ~= data.peng_pos then --碰别人的牌才需要把这张牌从废弃牌堆里移走
        self.player[data.other_pos]:removeDisCard(data.num)
    end
    self.player[data.peng_pos]:GangCard(data.num,data.other_pos == data.peng_pos)
    ]]
end

function CUIGame:onUserAnGang(res)--暗杠的消息
--[[
if data.other_pos ~= data.peng_pos then --碰别人的牌才需要把这张牌从废弃牌堆里移走
self.player[data.other_pos]:removeDisCard(data.num)
end
self.player[data.peng_pos]:GangCard(data.num,data.other_pos == data.peng_pos)
]]
end

function CUIGame:onServerBrocastPeng(res)
    self:onUserPeng(res)
end

function CUIGame:onServerBrocastMingGang(res)--明杠
    local num = GlobalFun:ServerCardToLocalCard(res.cardnum)
    local other_pos,gang_pos = 1,1
    for i=1,4 do
        if self.player[i].openid == res.gangID then
            gang_pos = i
        end
        
        if self.player[i].openid == res.outID then
            other_pos = i
        end
    end
    if other_pos ~= gang_pos then --碰别人的牌才需要把这张牌从废弃牌堆里移走
        self.player[other_pos]:removeDisCard(num)
    end
    self.flag = gang_pos
    self.light_flag = gang_pos
    self.player[gang_pos]:GangCard(num,other_pos == gang_pos)
    if gang_pos == 1 then
        self:sendUpCard("客户端发生了杠牌")
        if self.isVideo then
            self.win_btn:cleanAll()
        end
    end

    self.canwin_listen:setVisible(false)
    self.player[1]:hideFlagOnCardForGang()
end

function CUIGame:onServerBrocastAnGang(res)--暗杠
    local data = {}
    data.gangID = res.userID
    data.outID = res.userID
    data.cardnum = res.value
    self:onServerBrocastMingGang(data)
    
    self.canwin_listen:setVisible(false)
    self.player[1]:hideFlagOnCardForGang()
end

function CUIGame:onServerNotifyCanHu(res)
    CCXNotifyCenter:notify("showGameBTN",{{type = 1},{type = 4}})
end

function CUIGame:onAskDismissRoom(res)--询问是否解散房间
    -- if self.askFrame == nil then
    --     self.isReqMiss = true
    --     local BaseAsk = ex_fileMgr:loadLua("app.views.VoteUI")
    --     --isInitiator 是否发起人，initiatorIndex 发起人索引(1-4，默认第1个就是当前玩家)，playerName 4个玩家名字
    --     local info = {}
    --     local index = 1
    --     local is_watch = true
    --     for i=1,4 do
    --         if self.player[i].isPeople then
    --             info[#info + 1] = {}
    --             info[#info].name = self.player[i].name
    --             info[#info].id = self.player[i].id
    --             if self.player[i].id == res.reqID then
    --                 index = #info
    --             end
    --             if self.player[i].id == PlayerInfo.playerUserID then
    --                 is_watch = false
    --             end
    --         end
    --     end
    --     if self.disTime > 300 then
    --         self.disTime = 300
    --     end
    --     if self.disTime < 0 then
    --         return
    --     end
    --     self.askFrame = BaseAsk.new({app = self.app, isInitiator = index == 1, initiatorIndex = index, playerInfo = info,disTime = self.disTime, is_watch = is_watch})
    --     self.askFrame:setTag(VOTEUI_TAG)
    --     self.ctn_win:addChild(self.askFrame)
    --     self.disTime = 1000
    -- end

    MessageCache:popCache("ROOM:onAskDismissRoom")

    if self.askFrame == nil then
        self.isReqMiss = true
        local BaseAsk = ex_fileMgr:loadLua("app.views.VoteUI")
        --isInitiator 是否发起人，initiatorIndex 发起人索引(1-4，默认第1个就是当前玩家)，playerName 4个玩家名字
        local info = {}
        local index = 1
        local is_watch = true
        for i=1,4 do
            -- cclog("self.player[i].isLine >>>>", self.player[i].isLine)
            if self.player[i].isPeople then
                info[#info + 1] = {}
                info[#info].name = self.player[i].name
                info[#info].id = self.player[i].id
                info[#info].isLine = self.player[i].isLine
                info[#info].openid  = self.player[i].openid
                if self.player[i].id == res.reqID then
                    index = #info
                end
                if self.player[i].id == PlayerInfo.playerUserID then
                    is_watch = false
                end
            end
        end
        if self.disTime > 180 then
            self.disTime = 180
        end
        if self.disTime < 0 then
            return
        end

        self.askFrame = BaseAsk.new()
        self.askFrame:initParams({app = self.app, isInitiator = index == 1, initiatorIndex = index, playerInfo = info,disTime = self.disTime, is_watch = is_watch})
        self.askFrame:setTag(VOTEUI_TAG)
        self.ctn_win:addChild(self.askFrame)
        self.disTime = 1000
    end


end

function CUIGame:onSendEmoticon(res) -- 玩家发送了表情
    if res == nil and #res == 3 then
    	cclog("接受玩家表情 失败")
    	return 
    end
    cclog("收到玩家表情消息 "..res.emoid)
    local index = 1
    if self.player[1] ~= nil then
        --ziji 语音
        if self.player[1].openid == res.playid then
           if res.type == 2 then -- emoji
               self.player[1]:ShowSpeakVoice(res.emoid) 
           end
           return 
        end
        
        for index = 2 , 4 do
            if self.player[index].openid == res.playid then
                if res.type == 0 then -- emoji
                    self.player[index]:ShowEmoji(res.emoid)
                elseif res.type == 1 then 
                    self.player[index]:ShowEmojiVoice(res.emoid)
                else
                    local function Callback()
                    	cclog("Download Voice Callback ")
                        self.player[index]:ShowSpeakVoice(res.emoid)
                    end
                self:downloadVoice(res.emoid , Callback) 
                end
                break
            end
        end
    else
        local pre_player = self.win_pre.players
        --ziji 语音
        if pre_player[1] and pre_player[1].id == res.playid  then
            if res.type == 2 then -- emoji
                self.win_pre:ShowSpeakVoice(1,res.emoid)
            end
            return 
        end

        for index = 2 , 4 do
            if pre_player[index] and pre_player[index].id == res.playid then
                if res.type == 0 then -- emoji
                    self.win_pre:ShowEmoji(index,res.emoid)
                elseif res.type == 1 then 
                    self.win_pre:ShowEmojiVoice(index,res.emoid)
                else
                    local function Callback()
                        cclog("Download Voice Callback ")
                        if self.win_pre then
                            self.win_pre:ShowSpeakVoice(index,res.emoid)
                        else
                            self.player[index]:ShowSpeakVoice(res.emoid)
                        end
                    end
                    self:downloadVoice(res.emoid , Callback) 
                end        
                break
            end
        end
    end
end

function CUIGame:closeServerRoom(data)
    cclog("关闭服务器房间")
    -- cclog(debug.traceback())
    if data then
        GlobalData.CartNum = data.cart
    end
    -- GlobalFun:closeNetWorkConnect()
    -- GameClient:close()
    -- cclog ("CUIGame:closeServerRoom >>>1", self.gameOpen, self.backType, data)
    -- if self.gameOpen and data == "isCuiGameAllSummaryBackBtn" then
    --     if self.backType == 0 then
    --         ex_gameStateMgr:changeState(ex_gameStateMgr.GAMESTATE.STATE_HALL)
    --     elseif self.backType == 1 then
    --         ex_gameStateMgr:changeState(ex_gameStateMgr.GAMESTATE.STATE_CLUB)
    --     end
    -- else
    --     if self.backType == 0 then
    --         ex_gameStateMgr:changeState(ex_gameStateMgr.GAMESTATE.STATE_HALL)
    --     elseif self.backType == 1 then
    --         ex_gameStateMgr:changeState(ex_gameStateMgr.GAMESTATE.STATE_CLUB)
    --     end
    -- end
end

function CUIGame:reOpen()--重新开局
	self.flag = 0
	self.light_flag = 0
	self.currValue = nil
	self.smallSummary = nil
	self.player[1].isReady = false
	ex_audioMgr:playMusic("sound/bgm.mp3",true)
    GameRule.cur_GameCNT = GameRule.cur_GameCNT + 1

    self.win_btn:setVisible(false)
    self:setRoomPass()
    self.surplusNum = GlobalFun:getCardSum()
    self:setRoomCardNum(self.surplusNum)
	self.ctn_eff:removeAllChildren()
    self.win_listen:setVisible(false)
    self.canwin_listen:setVisible(false)
    self.player[1]:hidePointerOnCard()
    self:highlightedCard(0, false)

	for i=1,4 do
        self.player[i]:cleanAllData()
	end
	if self.win_ok == nil then
        self.win_ok = BaseOK.new()
        self.root:getChildByName("ctn_pre"):addChild(self.win_ok)
	end
    self.win_ok:setOKVisible(1,false)
    
    ex_roomHandler:ReadyState()--通知服务器准备好了
end

function CUIGame:retryConnectGame()--重连
    if GameClient.server ~= nil then
        GameClient.server.listener[self] = self
    end
end

function CUIGame:onNotifyUserRefusedDisMiss(res)--有人拒绝或者同意解散房间
    --local a = 10
    -- local tmp = 0
    -- for i=1,4 do
    --     if self.player[i].isPeople ~= true then
    --         tmp = 1
    --     end
    --     if self.player[i].openid == res.refusedID then
    --         if self.askFrame then
    --             self.askFrame:SetPlayerState(i-tmp,res.isAgree)
    --         end
    --     end
    -- end

    cclog("CUIGame:onNotifyUserRefusedDisMiss >>>>>>>>")
    -- cclog(debug.traceback())
    -- print_r(res)

    MessageCache:popCache("ROOM:onNotifyUserRefusedDisMiss")

    local tmp = 0
    for i=1,4 do
        if self.player[i].isPeople ~= true then
            tmp = 1
        end
        for k,v in pairs(res) do
            if self.player[i].openid == v.refusedID then
                if self.askFrame then
                    self.askFrame:SetPlayerState(i-tmp,v.isAgree)
                end
            end
        end
       
    end
end

function CUIGame:onNotifyUserDisMiss(res)--解散房间的结果
    cclog("*************************解散房间的结果")
    -- cclog(debug.traceback())

    self.backType = 0

    CUIGame.isEnd = true
    if self.askFrame then
        self.askFrame:removeFromParent()
        self.askFrame = nil
    end
    GlobalFun:closeNetWorkConnect()
    CCXNotifyCenter:notify("onGameTryConnect",nil)
    GameClient:close()
    --[[
    if GameClient.server and self.videoT == -2 then
        self.videoT = -1
    else
        self.videoT = 1
    end]]
    --UserDefault:writeTable(res)
    self.allSummaryData = res
    cclog("loginKey " .. res.loginKey)
    GlobalData.HallKey = res.loginKey
   
    --cclog("GlobalData.HallKey " .. GlobalData.HallKey)

    if self.gameOpen == false then--直接返回大厅
        -- GlobalData.isRoomToHall = true
        GlobalFun:showNetWorkConnect("返回大厅...")
        -- ex_hallHandler:connectCheck()
        platformExportMgr:returnAppPlatform()

    else
        GlobalData.suammaryToHall = true--房间到大厅
        -- GlobalData.isRoomToHall = true
        -- HallClient:open(GlobalData.HallIP,GlobalData.HallPort)
        --写数据到配置文件
        local tmp_data = {}
        tmp_data.roomID = GlobalData.roomID
        tmp_data.gameCnt = GameRule.MAX_GAMECNT
        tmp_data.name = {self.player[1].name,self.player[2].name,self.player[3].name,self.player[4].name}
        tmp_data.curr = GameRule.cur_GameCNT
        tmp_data.zhama = GameRule.ZhaMaCNT
        tmp_data.summary = {}
        for i=1,4 do
            local finduser = false
            for j=1,#res.players do
                if self.player[i].id == res.players[j].playerID then
                    tmp_data.summary[i] = res.players[j].score
                    finduser = true
                    break
                end
            end
            if self.player[i].isPeople ~= true then
                finduser = true
            end
            if finduser == false then
                local sp ="总结算没找到对应id   " .. res.player[1].playerid .. " , " .. res.player[2].playerid .. " , " .. res.player[3].playerid .. "  ,  " .. res.player[4].playerid
                GlobalFun:showError(sp,nil,nil,1)
            end
        end
        if self.isWatch ~= true then
            LocalDataFile:writeSummaryScore(tmp_data, self.originType, self.originKey)
        end

        -- local i_am_watch = self:checkMeIsWatch()
        
        -- cclog("CUIGame:onNotifyUserDisMiss >>>>>>>>>>", self.smallSummary, self.isWatch, i_am_watch)
        -- if self.smallSummary == nil or (self.isWatch and i_am_watch) then--self.isReqMiss then--如果是请求退出的  则直接显示结算界面
        if self.smallSummary == nil then
            self:showAllSummary()
        end
    end
end

function CUIGame:onUserRequestExit(res)--服务端是否同意退出房间
    if res.isQuit == false then
        GlobalFun:showToast("服务器拒绝了你的请求" , Game_conf.TOAST_SHORT)
        return
    end
    --CCXNotifyCenter:notify("onGameTryConnect",nil)

    if res.rtype == 0 then
        self.backType = 0
        -- GlobalData.HallKey = res.loginKey

        -- ex_hallHandler:connectCheck()
        platformExportMgr:returnAppPlatform()
    elseif res.rtype == 1 then
        self.backType = 1
        ex_clubHandler:connectCheck()
    end
end

function CUIGame:onNotifyQuitRoomUserID(res)--有人退出房间
    if res.quitID == PlayerInfo.playerUserID then
        self.isWatch = true
    end
    if self.win_pre then
        self.win_pre:userExit(res.quitID)
    end

    if PlayerInfo.playerUserID and PlayerInfo.playerUserID == res.quitID then
        self.offset = 0
    end

    self:refreshGpsUI()
end


function CUIGame:onNotifyString(res) --跑马灯信息
    cclog(" 跑马 " .. type(res))
    if res ~= nil then
        GlobalData.NotifyContexts[#GlobalData.NotifyContexts + 1] = res.msg
        --CCXNotifyCenter:notify("ShowNotify",true)
    end
end

function CUIGame:searchGangOutID(value)
    self.light_flag = 1
    local gOutID = self.player[1].openid
    for i=2,4 do
        if #self.player[i].discard > 0 then
            local card = self.player[i].root:getChildByTag(self.player[i].discard[#self.player[i].discard])
            if card.cardnum == value then
                gOutID = self.player[i].openid
                break
            end
        end
    end
    self.player[1]:MeCanGang(value,gOutID)
end

function CUIGame:onUserRequireShowBNT(res)--这个消息是针对自己重连之后的
    if res.pgvalue then
        self:searchGangOutID(GlobalFun:ServerCardToLocalCard(res.pgvalue))
    end
    
    if res.mgvalue then
        self.player[1]:MeCanGang(GlobalFun:ServerCardToLocalCard(res.mgvalue),res.mgoutID)
        --self:searchGangOutID(GlobalFun:ServerCardToLocalCard(res.mgvalue))
    end
    
    for i=1,#res.an do
        self.player[1]:MeCanGang(GlobalFun:ServerCardToLocalCard(res.an[i]),self.player[i].openid)
    end
    
    if res.hu then
        CCXNotifyCenter:notify("showGameBTN",{{type = 1},{type = 4}})
    end
    
    if res.pengvalue then
        self.light_flag = 1
        self.player[1]:MeCanPeng(GlobalFun:ServerCardToLocalCard(res.pengvalue),res.pengOutID)
    end
end

function CUIGame:onNotifyUserOnAnOff(res)
    for i=1,4 do
        if self.win_pre then
            self.win_pre:setHeadOnAnOff(res)
        else
            if self.player[i].openid == res.userid then
                self.player[i]:setHeadOnAnOff(res.flag)
                break
            end
        end
    end

    CCXNotifyCenter:notify("onNotifyUserOnAnOff_notify", res)
end

function CUIGame:sendUpCard(str)
    if Game_conf.upHandCard == false then
        return
    end
    if self.player[1] == nil or self.player[1].handcard == nil then
        return
    end
    local tmp_card = {}
    for n=1 , #self.player[1].handcard do
        local card = self.player[1].root:getChildByTag(self.player[1].handcard[n])
        tmp_card[#tmp_card + 1] = GlobalFun:localCardToServerCard(card.cardnum)
    end
    cclog(tmp_card)
    ex_roomHandler:clientUpLoadCards(str,tmp_card)
end

function CUIGame:checkOtherCards()--检测别的玩家的牌有没有有问题的
    if true then
        return
    end
    for i=1,4 do
        if self.player and self.player[i] then
            if self.player[i].mingpai then
                for j=1,#self.player[i].mingpai do
                    if #self.player[i].mingpai[j] < 3 then
                        self.reqCard = true
                        LogController.sendLog("loss ".. self.player[i].id .. " mingcard")
                        ex_roomHandler:notifyPlayerCard()
                        return
                    end
                end
            end
            if self.player[i].handcard == nil or #self.player[i].handcard == 0 then--没牌
                self.reqCard = true
                LogController.sendLog("loss ".. self.player[i].id .. " no handcard")
                ex_roomHandler:notifyPlayerCard()
                return
            else
                local mc =  0
                if self.player[i].mingpai then
                    mc = 3 * (#self.player[i].mingpai)
                end
                if #self.player[i].handcard + mc < 13 then-- 牌不足
                    self.reqCard = true
                    LogController.sendLog("loss ".. self.player[i].id .. " some handcard")
                    ex_roomHandler:notifyPlayerCard()
                    return
                end
            end
        else--玩家信息不全
            self.reqCard = true
            LogController.sendLog("loss player infomation")
            ex_roomHandler:notifyPlayerCard()
            return
        end
    end
end

function CUIGame:checkHyalineCardNum()--检测玩家能看到的牌的数量有没有超过4的情况
    if true then
        return
    end
    local tableCard = {}
    local tablehz = 0
    for i=1,30 do
        tableCard[i] = 0
    end
    if self.player[1] and self.player[1].handcard then
        local tmp_cnt = 0
        if self.player[1].mingpai then
            tmp_cnt = #self.player[1].mingpai*3
        end
        if tmp_cnt + #self.player[1].handcard < 13 then--牌数不对了
            self.reqCard = true
            ex_roomHandler:notifyPlayerCard()
            return
        end
    end
    for i=1,4 do
        if self.player[i] then
            if i == 1 then
                if self.player[i].handcard and #self.player[i].handcard > 0 then
                    for j = 1,#self.player[i].handcard do
                        local card = self.player[i].root:getChildByTag(self.player[i].handcard[j])
                        if card then
                            if card.cardnum == 31 then
                                tablehz = tablehz + 1
                            else
                                tableCard[card.cardnum] = tableCard[card.cardnum] + 1
                            end
                        end
                    end
                end
            end
            
            if self.player[i].discard and #self.player[i].discard > 0 then
                for j=1,#self.player[i].discard do
                    local card = self.player[i].root:getChildByTag(self.player[i].discard[j])
                    if card then
                        if card.cardnum == 31 then
                            tablehz = tablehz + 1
                        else
                            tableCard[card.cardnum] = tableCard[card.cardnum] + 1
                        end
                    end
                end
            end
            
            if self.player[i].mingpai and #self.player[i].mingpai > 0 then
                for j=1,#self.player[i].mingpai do
                    for k=1,#self.player[i].mingpai[j] do
                        local card = self.player[i].root:getChildByTag(self.player[i].mingpai[j][k])
                        if card then
                            if card.cardnum == 31 then
                                tablehz = tablehz + 1
                            else
                                tableCard[card.cardnum] = tableCard[card.cardnum] + 1
                            end
                        end
                    end
                end
            end
        end
    end
    
    if tablehz > 4 then
        self.reqCard = true
        ex_roomHandler:notifyPlayerCard()
        return
    end
    
    for i = 1,#tableCard do
        if tableCard[i] > 4 then
            self.reqCard = true
            ex_roomHandler:notifyPlayerCard()
            return
        end
    end
end

function CUIGame:onNotifyPlayerCard(cards)
    if self.player[1] then
    	self.player[1]:reDrawHandCard(cards)
    end
end

function CUIGame:tryRecoveryMeCard(newCards)--尝试把之前牌的位置恢复
    local function compareTable(tb1,tb2)
        local cnt = 0
        local newValue = nil
        local flag = true
        for i = 1,#tb1 do
            flag = true
            for j=1,#tb2 do
                if tb1[i] == tb2[j] then
                    cnt = cnt + 1
                    flag = false
                    break
                end
            end
            if flag then
                newValue = tb1[i]
            end
        end
        return #tb1 - cnt,newValue
    end
    
    if #newCards%3 == 2 then--自己出牌恢复才有意义
        local t_cnt,n_value = compareTable(newCards,self.oldCard)
        if #self.oldCard > 0 then
            if #newCards - #self.oldCard == 0 then
                if t_cnt == 0 then--最后一张就是刚刚摸到的
                    self.currValue = self.oldCard[#self.oldCard]
                end
            elseif #newCards - #self.oldCard == 1 then
                if t_cnt == 1 and n_value then--多出来的就是刚刚摸到的
                    self.currValue = n_value
                end
            end
        end
    end
end

function CUIGame:selfSitOrUp(b)
    if b then
        for i=1,#self.watchPlayer do
            if self.watchPlayer[i].id == PlayerInfo.playerUserID then
                table.remove(self.watchPlayer,i)
                break
            end
        end
        self.isWatch = false
    else
        self.isWatch = true
    end
    self:setSitBTNVisible(self.isWatch)
    self:setUpBTNVisible(not self.isWatch)
    -- self:setGZMSFlag(self.isWatch)
end

function CUIGame:onRoomJoinBaseInfo(res)

    if res.id == PlayerInfo.playerUserID then
        self.offset = res.pos-1
    end


    if res.id == PlayerInfo.playerUserID then--这个玩家是自己
        self:selfSitOrUp(true)
    end
    if self.win_pre then
        self.win_pre:onNewUserEnter(res)
    end

    self:refreshGpsUI()
end


--录像回放
function CUIGame:onVideoData(res)
    cclog("*************************录像数据")
    --cclog("录像数据下发")
    --self.videoData = res
    
    --检测补录
    --LocalDataFile:insertVideo(self.videoData,GameRule.MAX_GAMECNT,GameRule.ZhaMaCNT)
    --[[if self.videoT == -1 then
        self.videoT = -2
    elseif self.videoT > 0 then
        self.videoT = -1
        if GameClient.server then
            GameClient:close()
        end
    end]]
    if res == nil or #res == 0 then
        --GlobalFun:showToast("录像数据数据解析或下发出错",Game_conf.TOAST_LONG)
    else 
        --GlobalFun:showToast("收到录像数据",Game_conf.TOAST_LONG)
        res[1].cnt = GameRule.MAX_GAMECNT
        res[1].zhama = self.playerNum*10+GameRule.ZhaMaCNT
        --LocalDataFile:writeVideo(res)
        
        self.videoData = res
        --cclog("数据不为空")
    end
end

function CUIGame:setLocalVideo(data)
    self.videoData = data
end

function CUIGame:VideoEnter()
    self.isVideo = true
    self.isVideoPlayer = true
    self.root:getChildByName("ctn_video"):addChild(ex_fileMgr:loadLua("app.views.game.CUIVideo").new(self.isVideoPlayer))
    self.videoLogic = VideotapeLogic:create(self)
    
    
end

function CUIGame:videoState(index)
    --1快退  2播放  3暂停  4快进  5返回
    --cclog("game state " ..  index)
    if index == 1 then
        self.isVideoPlayer = false
        self.videoLogic:setStep(-10)
    elseif index == 2 then
        self.isVideoPlayer = true
    elseif index == 3 then
        self.isVideoPlayer = false
    elseif index == 4 then
        self.isVideoPlayer= false
        self.videoLogic:setStep(10)
    else
        self:removeFromParent()
    end
end


--观战---------------------------------------------
function CUIGame:onWatchList(res)--获取观战列表
    self.watchPlayer = res.watchList
end

function CUIGame:onExitWatch(res)--退出观战  返回大厅那种
   platformExportMgr:returnAppPlatform()          
   --直接返回平台 
    -- GlobalData.HallKey = res.key
   
    -- -- GlobalData.isRoomToHall = true
    -- GlobalFun:showNetWorkConnect("返回大厅...")
    -- HallClient:open(GlobalData.HallIP,GlobalData.HallPort)
end

function CUIGame:onNotifyInOrOutWatch(res)
    cclog("CUIGame:onNotifyInOrOutWatch >>>>>")

    if res.flag == 1 then--进入
        if res.id == PlayerInfo.playerUserID then
            self.isWatch = true
            self:selfSitOrUp(false)
            self:hideGpsBtnAndView()
        else
            local flag = false
            for i=1,#self.watchPlayer do
                if self.watchPlayer[i].id == res.id then
                    flag = true
                    break
                end
            end
            if flag == false then
                self.watchPlayer[#self.watchPlayer + 1] = {id = res.id,img = res.img}
            end
        end
    else--退出

        for i=1,#self.watchPlayer do
            if self.watchPlayer[i].id == res.id then
                table.remove(self.watchPlayer,i)
                break
            end
        end
        if res.id == PlayerInfo.playerUserID then
            self.isWatch = false
            self:showGpsBtn()
        end
    end
    
    --刷新列表
    self.root:getChildByName("ctn_menu"):getChildByName("btn_msg"):setVisible(not self.isWatch)
    self.root:getChildByName("ctn_mcrophone"):getChildByName("btn_mcrophone"):setVisible(not self.isWatch)
    self:setGuangZhong(self.root:getChildByName("ctn_gz"):isVisible())
end

function CUIGame:onGifList(res)
    self.giflist = res
end

function CUIGame:getRealPosition(id)
    local p = cc.p(-60,display.height+60)
    --self.gameObj:convertToWorldSpace(cc.p(0,0))
    if self.win_pre then
        p = self.win_pre:getRealPosition(id)
    else
        for i=1,4 do
            if self.player[i] and self.player[i].id == id then
                p = self.player[i]:getRealPosition()
                break
            end
        end
    end
    
    return p
end

function CUIGame:getGifList()
    return self.giflist
end

function CUIGame:onGivePlayerGif(res)
    -- if res.gifid > 6 or res.gifid < 0 then
    --     return
    -- end
    
    -- if res.giveid == PlayerInfo.playerUserID then--
    --     for i=1,#self.giflist do
    --         if self.giflist[i].id == res.gifid then
    --             PlayerInfo.goldnum = PlayerInfo.goldnum - self.giflist[i].price
    --             CCXNotifyCenter:notify("updateGold",PlayerInfo.goldnum)
    --             break
    --         end
    --     end
    -- end
    
    -- local p1 = self:getRealPosition(res.giveid)
    -- local p2 = self:getRealPosition(res.reciveid)
    
    
    -- local things = ex_fileMgr:loadLua("app.views.watch.CUIWatch_thingsicon").new(res.gifid)
    -- self.ctn_eff:addChild(things)
    -- things:setPosition(p1)
    -- local a1 = cc.MoveTo:create(0.8,p2)
    -- local a2 = cc.CallFunc:create(function() 
    --     local data = {file = string.format("watch/CUIWatch_eff%d.csb",res.gifid),time = 90/60,acname = "a0"}
    --     local tmp_eff = BaseOnce.new(data)
    --     tmp_eff:setPosition(p2)
    --     self.ctn_eff:addChild(tmp_eff)
        
    --     things:removeFromParent()
    
    --  end)
     
    --  things:runAction(cc.Sequence:create({a1,a2}))

    cclog("CUIGame:onGivePlayerGif  >>>>>>>", res.gifid)
    if res.gifid < 0 then
        return
    end
    
    if res.giveid == PlayerInfo.playerUserID then--
        for i=1,#self.giflist do
            if self.giflist[i].id == res.gifid then
                PlayerInfo.goldnum = PlayerInfo.goldnum - self.giflist[i].price
                CCXNotifyCenter:notify("updateGold",PlayerInfo.goldnum)
                break
            end
        end
    end
    
    local p1 = self:getRealPosition(res.giveid)
    local p2 = self:getRealPosition(res.reciveid)
    
    
    local things = ex_fileMgr:loadLua("app.views.watch.CUIWatch_thingsicon").new(res.gifid)
    self.ctn_eff:addChild(things)
    things:setPosition(p1)

    local speed = 1000
    local sec = cc.pGetDistance(p1,p2)/speed


    local a1 = cc.MoveTo:create(sec,p2)
    local a2 = cc.CallFunc:create(function() 
        local data = {file = string.format("watch/CUIWatch_eff%d.csb",res.gifid),time = 90/60,acname = "a0"}
        local tmp_eff = BaseOnce.new(data)
        tmp_eff:setPosition(p2)
        self.ctn_eff:addChild(tmp_eff)
        
        things:removeFromParent()
    
     end)

    local a3 = cc.CallFunc:create(function()
        ex_audioMgr:playEffect( string.format("sound/liwu/%d.mp3", res.gifid),false) 
        end)

    local tmp = cc.Spawn:create(a2,a3)
     
     things:runAction(cc.Sequence:create({a1, tmp}))
    
end

function CUIGame:onCardUpdate(res)--通知房卡更新
    cclog(" 房卡更新 ")
    local totalcard = res.currCard--当前卡总数
    local card = res.card --改变的卡数
    if res.type == 0 then
        GlobalData.CartNum = totalcard
    else
        PlayerInfo.goldnum = totalcard
        --通知
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

function CUIGame:onExit()
    ex_audioMgr:stopMusic()
    ex_timerMgr:unRegister(self)
    CCXNotifyCenter:unListenByObj(self)
    self:unlistenTouch()--取消触摸
    self:unregisterScriptHandler()--取消自身监听
    if GameClient.server ~= nil then
        GameClient.server.listener[self] = nil
    end
    if self.schedulerID_speakNextVoice ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID_speakNextVoice) 
        self.schedulerID_speakNextVoice = nil
    end

    GlobalFun:stopPlayAudio()--关闭录音播放
    cpp_uploadVoice_resetEndFlag() --重置结束标记
end

function CUIGame:onFengHuCards(cards)
    MessageCache:popCache("ROOM:onFengHuCards")
    if self.player and self.player[1] then
        self.player[1]:showFengHuCards(cards)
    end
end

--高亮指定的麻将牌
function CUIGame:highlightedCard(cardNum, flag)
    for i = 1, #(self.player) do
        --cclog("player index:"..i)
        self.player[i]:highlightedCard(cardNum, flag, i)
    end

    if flag == true then 
        self.curHighLightCardNum = cardNum
    else
        self.curHighLightCardNum = 0
    end

    --顺便判断是否显示可打出牌后的听牌
    self.canwin_listen:setVisible(false)
    if self.canlisten_cards ~= nil then
        cclog("check canlisten_cards...")
        for i = 1, (#self.canlisten_cards) do
            if cardNum == self.canlisten_cards[i].card then
                local tb = self.canlisten_cards[i].listenData
                self.canwin_listen:setShowCards(tb)
                self.canwin_listen:setVisible(true)
            end
        end
    end
end

--===============  club begin =============
function CUIGame:showYaoQingChengYuan(res)
    cclog("CUIGame:showYaoQingChengYuan >>>", self.isVideo, res.clubId)
    if self.isVideo then return end
    
    self.originType = res.originType
    self.originKey = res.originKey
    ClubManager:setInfo("clubID", res.clubId)


    self.btn_cy_yaoqing = self.root:getChildByName("btn_cy_yaoqing")
    ClubManager:cleanYaoQingJinFang()
    local isOpen = true
    for k = 1, self.playerNum do
        if not res.player[k] then
            isOpen = false
            break
        end
    end

    cclog("CUIGame:showYaoQingChengYuan >>>", res.isThisClub, isOpen)
    if res.isThisClub and not isOpen then
        self.btn_cy_yaoqing:setVisible(true)
    else
        self.btn_cy_yaoqing:setVisible(false)
    end

    
    
    self.btn_cy_yaoqing:addClickEventListener(function() 
        -- local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_MemberYaoQing")
        self.root:addChild(ui.new({app = nil}))
     end)
end

--返回俱乐部，有俱乐部服务器下发这条，没有俱乐部走原来的解散那条
function CUIGame:onClubRoomNotifyUserDisMiss(res)
    cclog("*************************解散房间的结果")

    self.backType = 1

    CUIGame.isEnd = true
    if self.askFrame then
        self.askFrame:removeFromParent()
        self.askFrame = nil
    end
    GlobalFun:closeNetWorkConnect()
    CCXNotifyCenter:notify("onGameTryConnect",nil)
    GameClient:close()

    self.allSummaryData = res
    cclog("loginKey " .. res.loginKey)
    GlobalData.HallKey = res.loginKey
   


    if self.gameOpen == false then--直接返回大厅

        GlobalFun:showNetWorkConnect("返回俱乐部...")
        -- ClubClient:open(ClubClient.ClubIP,ClubClient.ClubPort)
        ex_clubHandler:connectCheck()
    else
        GlobalData.suammaryToHall = true


        --写数据到配置文件
        local tmp_data = {}
        tmp_data.roomID = GlobalData.roomID
        tmp_data.gameCnt = GameRule.MAX_GAMECNT
        tmp_data.name = {self.player[1].name,self.player[2].name,self.player[3].name,self.player[4].name}
        tmp_data.curr = GameRule.cur_GameCNT
        tmp_data.zhama = GameRule.ZhaMaCNT
        tmp_data.summary = {}
        for i=1,4 do
            local finduser = false
            for j=1,#res.players do
                if self.player[i].id == res.players[j].playerID then
                    tmp_data.summary[i] = res.players[j].score
                    finduser = true
                    break
                end
            end
            if self.player[i].isPeople ~= true then
                finduser = true
            end
            if finduser == false then
                local sp ="总结算没找到对应id   " .. res.player[1].playerid .. " , " .. res.player[2].playerid .. " , " .. res.player[3].playerid .. "  ,  " .. res.player[4].playerid
                GlobalFun:showError(sp,nil,nil,1)
            end
        end
        if self.isWatch ~= true then
            LocalDataFile:writeSummaryScore(tmp_data, self.originType, self.originKey)
        end

        if self.smallSummary == nil then
            self:showAllSummary()
        end
    end
end


--===============  club end =============

----------------------GPS 部分 start-----------------
function CUIGame:addGpsModel()
    local function callfunc()
        self.ctn_gps = self.root:getChildByName("ctn_gps")
        local gpsView = self.ctn_gps:getChildByName("GPS_VIEW")
        if not gpsView then 
            gpsView = BaseGps.new()
            gpsView:setName("GPS_VIEW")
            self.ctn_gps:addChild(gpsView,100)

            self:refreshGpsUI()
        end
    end 
    GlobalFun:timeOutCallfunc(0.1 , callfunc)
end 

-- 关闭gps按钮
function CUIGame:closeGpsModel()
    local gpsView = self.ctn_gps:getChildByName("GPS_VIEW")
    if gpsView then 
        gpsView:removeFromParent()
    end 
end

function CUIGame:refreshGpsUI()
    local playerData = {}
    local players = {}
    if self.win_pre then 
        players = self.win_pre.players
    else
        players = self.player
    end 
    local curNum = 0
    for i = 1 , 4 do
        playerData[i] = {}
        if players[i] and players[i].name and players[i].id ~= 0 then 
            playerData[i].name = players[i].name
            playerData[i].id = players[i].id
            curNum = curNum + 1
        else
            playerData[i].name = ""
            playerData[i].id   = 0
        end 
    end 

    local isDelay = curNum == self.playerNum
    -- if self.playerNum == 2 then 
    --     playerData[3] = {name = playerData[2].name , id = playerData[2].id}
    --     playerData[2] = {name = "",id = 0}
    -- end 

    -- if self.playerNum == 3 then 
    --     playerData[4] = {name = playerData[3].name , id = playerData[3].id}
    --     playerData[3] = {name = "",id = 0}
    -- end 


    if not self.ctn_gps then return end
    local gpsView = self.ctn_gps:getChildByName("GPS_VIEW")
    if gpsView then 
        gpsView:refreshUI(playerData,isDelay)
    end 
end 

function CUIGame:showGpsMap()
    if not self.ctn_gps then return end
    local gpsView = self.ctn_gps:getChildByName("GPS_VIEW")
    if gpsView then 
        gpsView:showGpsMap()
    end
end

function CUIGame:closeGpsMap()
    if not self.ctn_gps then return end
    local gpsView = self.ctn_gps:getChildByName("GPS_VIEW")
    if gpsView then 
        gpsView:closeGpsMap()
    end
end

function CUIGame:hideGpsBtnAndView()
    if self.ctn_gps then 
        self.ctn_gps:setVisible(false)
        local gpsView = self.ctn_gps:getChildByName("GPS_VIEW")
        if gpsView then 
            gpsView:retrySocket(self.isWatch)
            gpsView:closeGpsMap()
        end 
    end
end

function CUIGame:showGpsBtn()
    if self.ctn_gps then 
        self.ctn_gps:setVisible(true)
        local gpsView = self.ctn_gps:getChildByName("GPS_VIEW")
        if gpsView then 
            gpsView:retrySocket(self.isWatch)
        else
            self:addGpsModel()
        end
    end
end
----------------------GPS 部分 end-----------------

return CUIGame
