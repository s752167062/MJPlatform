--@大厅协议处理类
--@Author 	sunfan
--@date 	2018/04/04
-- local Write = require("app.ctrls.socket.Write")
local dkj = require("app.helper.dkjson")

local HallProtocol = class("HallProtocol")
local print = _G.print
function HallProtocol:ctor(params)
	self:inItProtocol()
end

function HallProtocol:receiveMsg(obj)
    self:handlerProtocol(obj:getProId(),obj)
end

function HallProtocol:changeServerId(id)
    self:changeScene(id)
end

function HallProtocol:changeScene(params)
    local obj = Write.new(10000)
    obj:writeString(gameConfMgr:getInfo("hostKey"))
    obj:writeString(gameConfMgr:getInfo("version"))

    obj:writeLong(gameConfMgr:getInfo("userId"))
    obj:writeString(gameConfMgr:getInfo("playerName"))
    obj:writeString(gameConfMgr:getInfo("playerHeadURL"))
    cclog("HallProtocol:changeScene >>>", gameConfMgr:getInfo("userId"))
    cclog("HallProtocol:changeScene >>>", gameConfMgr:getInfo("hostKey"))
    local json = platformMgr:getPushMsgJson()
    obj:writeString(json)
    obj:send()
end

--协议处理
function HallProtocol:handlerProtocol(proId,obj)
	proId = tonumber(proId)
	if self._proFuns[proId] then
		self._proFuns[proId](obj)
	else
		dump("error,non-existent protocol ID:"..proId)
	end
end

--协议注册
function HallProtocol:inItProtocol()
	self._proFuns = {}
	self._proFuns[999] = handler(self,self.onError)
	self._proFuns[10000] = handler(self,self.onConnectCheck)
    self._proFuns[1100] = handler(self,self.recvMyGameList)
    self._proFuns[1101] = handler(self,self.recvGameList)
    -- self._proFuns[1102] = handler(self,self.recvEnterGame)
    self._proFuns[1103] = handler(self,self.recvUpdateOrDownGame)

    self._proFuns[1104] = handler(self,self.onClubList)
    self._proFuns[1105] = handler(self,self.onClubData)
    self._proFuns[1106] = handler(self,self.onCreateClub)
    self._proFuns[1108] = handler(self,self.onJoinClub)
    self._proFuns[1109] = handler(self,self.onAddClubGame)
    self._proFuns[1118] = handler(self,self.onSearchClub)
    -- self._proFuns[1110] = handler(self,self.onCheckGameVersion)

    self._proFuns[1201] = handler(self,self.onShiMing)          --实名
    self._proFuns[1202] = handler(self,self.onGetProduct)       --商店商品列表
    self._proFuns[1203] = handler(self,self.onH5PayCheck )      --检查支付类型
    self._proFuns[1204] = handler(self,self.onH5Pay)            --H5支付地址
    -- self._proFuns[1050] = handler(self,self.onSendIAPReceipt)   --appstore 支付结果
    self._proFuns[1205] = handler(self,self.onCardUpdate)       --房卡更新

    self._proFuns[1207] = handler(self,self.onNotice)
    self._proFuns[1206] = handler(self,self.onActivityNotice)   --公告板
    -- self._proFuns[1207] = handler(self,self.showCommonMsg)   --文字提示
    self._proFuns[1208] = handler(self,self.onMsgData)          --房卡消息
    self._proFuns[1209] = handler(self,self.onSendFeedBack)     --反馈

    self._proFuns[1127] = handler(self,self.onRemovePlaying)        --删除玩法
    self._proFuns[1128] = handler(self,self.onUpdatePlayingList)        --更新玩法列表
end

function  HallProtocol:onConnectCheck(obj)
    cclog("HallProtocol:onConnectCheck >>>>>")
    local res = {}
    --昵称
    res.playerId    = obj:readLong()
    --昵称
    res.nickname    = obj:readString()
    --昵称
    res.headUrl    = obj:readString()
    --房卡数量
    res.cart        = obj:readLong()
    --金币数量
    res.goldnum     = obj:readLong()
    --是否在房间
    res.isRoom      = obj:readBoolean()
    --是否在房间
    res.roomId      = obj:readInt()
    -- gameConfMgr:setInfo("playerName",res.nickname)
    gameConfMgr:setInfo("cards",res.cart)
    gameConfMgr:setInfo("gold",res.goldnum)
    -- gameConfMgr:setInfo("playerId",res.playerId)
    gameConfMgr:setInfo("headUrl",res.headUrl)


    print_r(res)
    if res.isRoom then
        --如果在房间
        -- local roomKey = obj:readString()
        externGameMgr:reqGotoGame(1, res.roomId )
    else
        gameState:changeState(GAMESTATE.STATE_COMMHALL)
    end
    
end

--服务器错误推送
function  HallProtocol:onError(obj)
    local res = {}
    res.errorCode =  obj:readByte()
    res.closeNetWork = obj:readBoolean()
    res.msg_err = obj:readString()
    if res.msg_err ~= "" then--优先使用服务器发来的文本提示内容
        msgMgr:showError(res.msg_err)
    else
        msgMgr:showError(res.errorCode)
    end
end





--我的游戏列表 1100
function HallProtocol:recvMyGameList(obj)
    cclog("HallProtocol:recvMyGameList >>>")
    local res = {}

    res.url = obj:readString()
    local count = obj:readShort()
    res.data = {}
    for i =1, count do
        local tab = {}
        obj:readShort()
        tab.product = obj:readString()
        tab.name = obj:readString()
        tab.game = obj:readString()
        tab.icon = obj:readString()
        tab.version = obj:readString()
        tab.showState = obj:readInt() -- 1热门 2推荐
        res.data[i] = tab
    end

    print_r(res)


    eventMgr:dispatchEvent("HallProtocol.recvMyGameList",res) 
end



--某类游戏列表 1101
function HallProtocol:recvGameList(obj)
    cclog("HallProtocol:recvGameList >>>")
    local res = {}

    res.url = obj:readString()

    res.curPage = obj:readInt()
    res.maxPage = obj:readInt()
    res.curShowNum = obj:readInt()
    res.totalCount = obj:readInt()

    local count = obj:readShort()
    res.data = {}
    for i =1, count do
        local tab = {}
        obj:readShort()
        tab.product = obj:readString()
        tab.name = obj:readString()
        tab.game = obj:readString()
        tab.icon = obj:readString()
        tab.version = obj:readString()
        tab.showState = obj:readInt() -- 1热门 2推荐
        res.data[i] = tab
    end

    print_r(res)
    eventMgr:dispatchEvent("HallProtocol.recvGameList",res) 
end


-- --进入某个游戏 1102
function HallProtocol:recvEnterGame(obj)
    -- cclog("HallProtocol:recvEnterGame  >>>>>>>>")
    -- local res = {}
    -- res.key = obj:readString()
    -- res.product = obj:readString()
    -- res.version = obj:readString()
    -- res.game = obj:readString()
    -- res.userId = obj:readLong()  --玩家平台id
    -- cclog("res.userId >>>", res.userId)

    -- -- eventMgr:dispatchEvent("HallProtocol.recvEnterGame",res) 
    -- local function callback() 

    --     lua_load("gameStar").new(res)
    -- end
    -- externGameMgr:enterGameByName(res.game, callback)
end

--更新下载某个游戏 1103
function HallProtocol:recvUpdateOrDownGame(obj)
    -- cclog("HallProtocol:recvUpdateOrDownGame >>>>")
    -- obj:readShort()
    -- local res = {}
    -- res.product = obj:readString()
    -- res.productType = obj:readString()
    -- res.name = obj:readString()
    -- res.game = obj:readString()
    -- res.version = obj:readString()
    -- res.icon = obj:readString()
    -- res.update_android = obj:readString()
    -- res.update_ios = obj:readString()
    -- res.shareUrl = obj:readString()
    -- res.roomId = obj:readInt()

    -- local targetPlatform = cc.Application:getInstance():getTargetPlatform() 
    -- if targetPlatform == cc.PLATFORM_OS_ANDROID or targetPlatform == cc.PLATFORM_OS_WINDOWS  then
    --     res.hotUpdate = res.update_android
    -- elseif targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD or targetPlatform == cc.PLATFORM_OS_MAC then
    --     res.hotUpdate = res.update_ios
    -- end

    -- res.download = ""  --没有真正意义的整更

    -- print_r(res)
    -- -- eventMgr:dispatchEvent("HallProtocol.recvUpdateOrDownGame",res) 
    res.hotUpdate = "192.168.1.57/zhuzhi_zhuzhijihe/ExternGameAssets/hongzhong/hotUpdate/1.0.0a"
    res.version = "1.0.0"
    -- local function callback_func(params) 
    --     local version = externGameMgr:getGameVersionByName(res.game)
    --     cclog("ClubGameView:recvUpdateOrDownGame update finish>>>", res.game, res.product, version)

    --     local tmp = {}
    --     tmp.product = res.product
    --     tmp.game = res.game
    --     tmp.name = res.name
    --     tmp.version = version
    --     tmp.icon = res.icon
    --     tmp.productType = res.productType
    --     externGameMgr:saveGameToLocalGameList(tmp)
    --     if res.roomId > 0 then 
    --         cclog("--- quick enter roomId", res.roomId)
    --         hallSendMgr:quickEnterRoom(res.roomId,false ,version) --返回 1102
    --     else                                                    
    --         hallSendMgr:sendEnterGame(res.product, version)
    --     end   
    -- end

    -- local baseVersion = externGameMgr:getGameVersionByName(res.game)
    -- if baseVersion == res.version then 
    --     callback_func()
    -- else
    --     local function tips_func()
    --         launcherSceneMgr:setManage(downGameMgr)
    --         downGameMgr:updateStart(res.game, {down_url = res.download,updata_url = res.hotUpdate, server_version = res.version},
    --                     --更新完的回调函数
    --                     callback_func)
    --     end
    --     if platformMgr:get_Net_type() == 10010 then 
    --         tips_func()
    --     else
    --         msgMgr:showAskMsg("当前网络不是Wifi，是否消耗流量下载",tips_func,nil, "确定", "取消")
    --     end    
    -- end
end





--创建俱乐部返回
function HallProtocol:onCreateClub(obj)
    cclog("HallProtocol:onCreateClub >>>>")

    local str = obj:readString()
   
    local res = dkj.decode(str)
    print_r(res)

    msgMgr:showToast(res.msg or "", 3)
    eventMgr:dispatchEvent("HallProtocol.onCreateClub",res) 


end

--俱乐部列表
function HallProtocol:onClubList(obj)
    cclog("HallProtocol:onClubList >>>")
    local res = {}

    local numb = obj:readByte()

    for i =1, numb do
        local tab = {}
        tab.clubId = obj:readLong()
        tab.clubName = obj:readString()
        tab.clubIconId = obj:readString()
        tab.clubQunzhuID = obj:readLong()
        tab.clubQunzhu = obj:readString()
        tab.isClubQunzhu = obj:readBoolean()

        res[i] = tab
    end

    
    print_r(res)
    eventMgr:dispatchEvent("HallProtocol.onClubList",res) 
end

function HallProtocol:onClubData(obj)
    cclog("HallProtocol:onClubData >>>>")
    local res = {}
    
    res.clubName = obj:readString()
    res.clubId = obj:readLong()  --俱乐部id，俱乐部包含各种游戏玩法（也可以说是小俱乐部）
    res.clubIconId = obj:readString()
    res.clubCurMan = obj:readShort()
    res.clubMaxMan = obj:readShort()
    res.canSetNumb = obj:readByte()
    
    res.huiZhangId = obj:readLong()
    res.huiZhangName = obj:readString()
        
    res.guanLiYuanId = obj:readLong()
    res.guanLiYuanName = obj:readString()
    

    clubMgr:setInfo("clubName", res.clubName)
    clubMgr:setInfo("clubId", res.clubId)
    clubMgr:setInfo("huiZhangName", res.huiZhangName)
    clubMgr:setInfo("huiZhangId", res.huiZhangId)
    clubMgr:setInfo("guanLiYuanName", res.guanLiYuanName)
    clubMgr:setInfo("guanLiYuanId", res.guanLiYuanId)


    res.gameList = {}
    local numb = obj:readByte()
    for i =1, numb do
        local tab = {}
        tab.clubSecndId = obj:readLong()  --游戏玩法规则id(也可以说是小俱乐部)
        tab.product = obj:readString()
        tab.name = obj:readString()
        tab.game = obj:readString()
        tab.version = obj:readString()

        res.gameList[i] = tab
    end

    print_r(res)

    eventMgr:dispatchEvent("HallProtocol.onClubData",res) 
end


-- function HallProtocol:onCheckGameVersion(obj)
--     cclog("HallProtocol:onCheckGameVersion >>>>")

--     local res = {}

--     eventMgr:dispatchEvent("HallProtocol.onCheckGameVersion",res) 
-- end

function HallProtocol:onJoinClub(obj)
    local str = obj:readString()
    local res = dkj.decode(str)
    msgMgr:showToast(res.msg or "", 3)
end

function HallProtocol:onSearchClub(obj)
    local str = obj:readString()
    local res = dkj.decode(str)
    print_r(res)
    eventMgr:dispatchEvent("HallProtocol.onSearchClub",res)
end


function HallProtocol:onAddClubGame(obj)
    cclog("HallProtocol:onAddClubGame >>>")
    
    local res = {}

    local str = obj:readString()
    res = dkj.decode(str)

    print_r(res)
    msgMgr:showToast(res.msg or "", 3)
    eventMgr:dispatchEvent("HallProtocol.onAddClubGame",res) 
end


--@返回商店商品列表
function HallProtocol:onGetProduct(obj)
    local res = {}
    local size = obj:readShort()
    for index = 1 , size do
        local data = {}
        data.pid   = obj:readInt() -- 商品id
        data.platf = obj:readInt() -- 0 andoird ，1ios
        data.type  = obj:readInt() -- 0 房卡 ，1金币
        data.money = obj:readInt() -- 价格 （price * 100)
        data.num   = obj:readInt() -- 数量
        res[#res +1] = data
    end
    eventMgr:dispatchEvent("HallProtocol.onGetProduct",res)
end

function HallProtocol:onShiMing(obj)
    cclog(" >>>> onShiMing")
    local reqType   = obj:readByte()
    local isSuccess = obj:readByte() == 1 and true
    comDataMgr:setInfo("shiming_success", isSuccess)

    --reqType  1获取数据  2 请求保存
    if reqType == 1 then
        local name = obj:readString()
        local id = obj:readString()
        comDataMgr:setInfo("shiming_name", name)
        comDataMgr:setInfo("shiming_id", id)
    elseif reqType == 2 then
        local msg = obj:readString()
        if isSuccess then
            local name = obj:readString()
            local id = obj:readString()
            comDataMgr:setInfo("shiming_name", name)
            comDataMgr:setInfo("shiming_id", id)
        end
        msgMgr:showError(msg or "")
    end
    printInfo("shiming_success   >>>", reqType, isSuccess)
    eventMgr:dispatchEvent("onShiMing")
end

function HallProtocol:onH5PayCheck(obj)
    local PAYTYPE    = obj:readString(pid) 
    local H5P_STATUS = (PAYTYPE == "H5" or PAYTYPE == "h5")
    local H5P_URL    = obj:readString()
    cclog(" >>> check pay ", H5P_STATUS, H5P_URL)
    gameConfMgr:setInfo("H5P_STATUS",H5P_STATUS)
    gameConfMgr:setInfo("H5P_URL",   H5P_URL)
end


function HallProtocol:onH5Pay(obj)
    local bool= obj:readBoolean()
    cclog(" ------ bool pay url" , bool)
    if bool then      
        local url = obj:readString()
        if url and url ~= "" then 
            eventMgr:dispatchEvent("onH5Pay",url)
        else
            msgMgr:showError("缺少支付地址" or "")
        end  
    else
        local msg = obj:readString()
        msgMgr:showError(msg or "")
    end  
end

function HallProtocol:onSendIAPReceipt(obj)
    local code = obj:readByte()
    timerMgr:clearTask("sendIAPReceipt_update")
    platformMgr:clean_IAP_Receipt() -- 清除凭证
    print("IAP支付 回调"..(code or ""))
end

function HallProtocol:onCardUpdate(obj)--通知房卡更新
    cclog(" Hall Client 通知房卡更新")
    local res = {}
    res.type = obj:readByte()
    res.card = obj:readInt()     --改变的卡
    res.currCard = obj:readInt() --当前卡总数
        
    local str = "获得"
    if res.type == 0 then --更新房卡
        str = str .. "房卡" .. res.card .. "张"
        gameConfMgr:setInfo("cards", res.currCard)
    elseif res.type == 1 then
        str = str .. "金币" .. math.floor(res.card / 10000) .. "万"
        gameConfMgr:setInfo("gold", res.currCard)
    end 

    eventMgr:dispatchEvent("update_card_gold",nil)
    if res.card > 0 and not gameConfMgr:getInfo("isShowWebView") then 
        msgMgr:showConfirmMsg(str , nil)
    end
end


--跑马灯
function HallProtocol:onNotice(obj)
    local res = {}
    res.msg = obj:readString()
    eventMgr:dispatchEvent("addMarqueeMsg",res.msg)
end
--公告信息
function HallProtocol:onActivityNotice(obj)
    local res = {}
    res.size = obj:readShort()
    local noticeTab = {}
    for i=1,res.size do
        noticeTab[i] = {}
        noticeTab[i].id   = obj:readInt()--id
        noticeTab[i].type = obj:readByte()--0文字1图片
        noticeTab[i].title= obj:readString()--标题
        noticeTab[i].msg  = obj:readString()--公告内容
    end
    res.noticeTab = noticeTab
    dump(res,"onActivityNotice")
    eventMgr:dispatchEvent("onActivityNotice",res)
end
--消息
function HallProtocol:onMsgData(obj)
    local num = obj:readShort()
    local data = {}
    for i=1,num do
        obj:readShort()
        local msg = obj:readString() -- 不能用\t
        data[#data +1] = msg
    end
    eventMgr:dispatchEvent("onMSGData",table.concat( data, "\n", 1, #data ))
end


function HallProtocol:onSendFeedBack(obj)
    cclog(">>>>> onSendFeedBack ")
    local bool = obj:readBoolean()
    eventMgr:dispatchEvent("onSendFeedBack",bool)
end

function HallProtocol:onRemovePlaying(obj)
    local str = obj:readString()
    cclog("HallProtocol:onRemovePlaying >>>", str)
    local res = dkj.decode(str)
    msgMgr:showToast(res.msg or "", 3)
end

function HallProtocol:onUpdatePlayingList(obj)
    local res = {}
    res.gameList = {}
    res.canSetNumb = obj:readByte()
    local numb = obj:readByte()
    for i =1, numb do
        local tab = {}
        tab.clubSecndId = obj:readLong()  --游戏玩法规则id(也可以说是小俱乐部)
        tab.product = obj:readString()
        tab.name = obj:readString()
        tab.game = obj:readString()
        tab.version = obj:readString()

        res.gameList[i] = tab
    end

    print_r(res)

    eventMgr:dispatchEvent("HallProtocol.onUpdatePlayingList",res) 
end


return HallProtocol






