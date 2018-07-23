--@登录场景
--@Author   sunfan
--@date     2018/04/04


local HallMyGame = require("app.views.hallScene_common.hallMyGame")
local HallClub = require("app.views.hallScene_common.hallClub")

local HallScene_view = class("HallScene_view", cc.load("mvc").ViewBase)
HallScene_view.RESOURCE_FILENAME = __platformHomeDir .."ui/layout/GeneralHallScene.csb"

function HallScene_view:ctor()
    cclog("HallScene_view:ctor")
    HallScene_view.super.ctor(self)

    

end

function HallScene_view:onCreate()
    --注册计时器
    timerMgr:register(self)


end

function HallScene_view:onEnter()
    externGameMgr:exitGameByName()




    self.txt_fangka = self:findChildByName("txt_fangka")
    self.txt_gold = self:findChildByName("txt_jinbi")
    self.txt_fangka:setString(gameConfMgr:getInfo("cards"))
    local gold = gameConfMgr:getInfo("gold")
    self.txt_gold:setString(comFunMgr:num_length_ctrl(gold))

    --@玩家名字
    self.ctn_playerName = self:getUIChild("txt_name")
    self.ctn_playerName:setStringByWidth(gameConfMgr:getInfo("playerName"), 170)


    self.txt_id = self:getUIChild("txt_id")
    self.txt_id:setStringByWidth("ID:" .. (gameConfMgr:getInfo("userId") or ""), 170)

    local head_url = gameConfMgr:getInfo("headUrl")
    self.img_head = self:getUIChild("img_head")
    local BasePlayerIcon = require("app.views.PlayerIcon")
    local playerIcon = BasePlayerIcon.new()
    playerIcon:setIcon(gameConfMgr:getInfo("userId"), head_url)
    self.img_head:addChild(playerIcon)
    local size = self.img_head:getContentSize()
    playerIcon:setScale(0.6)
    playerIcon:setPosition(size.width/2, size.height/2)
    playerIcon:setClickFunc(function() self:onHead() end)

    --@麻将
    self.ctn_buy = self:getUIChild("btn_majiang")
    self.ctn_buy:addClickEventListener(function ( event ) self:onClickMJ() end)

    --@扑克
    self.ctn_buy = self:getUIChild("btn_puke")
    self.ctn_buy:addClickEventListener(function ( event ) self:onClickPK() end)

    --@跑胡子
    self.ctn_buy = self:getUIChild("btn_paohuzi")
    self.ctn_buy:addClickEventListener(function ( event ) self:onClickPHZ() end)



    --@刷新
    self.btn_shuaxin = self:getUIChild("btn_shuaxin")
    self.btn_shuaxin:addClickEventListener(function ( event ) self:onShuaXin() end)

    --@实名
    self.btn_shiming = self:getUIChild("btn_shiming")
    self.btn_shiming:addClickEventListener(function ( event ) self:onShiMing() end)

    --@分享
    self.btn_fenxiang = self:getUIChild("btn_fenxiang")
    self.btn_fenxiang:addClickEventListener(function ( event ) self:onFenXiang() end)

    --@设置
    self.btn_setting = self:getUIChild("btn_setting")
    self.btn_setting:addClickEventListener(function ( event ) self:onSetting() end)


    --@商城
    self.btn_shop = self:getUIChild("btn_shop")
    self.btn_shop:addClickEventListener(function ( event ) self:onShop() end)

    self.btn_addjinbi = self:getUIChild("btn_addjinbi")
    self.btn_addjinbi:addClickEventListener(function ( event ) self:onShop() end)

    self.btn_addfangka = self:getUIChild("btn_addfangka")
    self.btn_addfangka:addClickEventListener(function ( event ) self:onShop() end)

    --@信息
    self.btn_xinxi = self:getUIChild("btn_xinxi")
    self.btn_xinxi:addClickEventListener(function ( event ) self:onXinXi() end)

    --@反馈
    self.btn_fankui = self:getUIChild("btn_fankui")
    self.btn_fankui:addClickEventListener(function ( event ) self:onFeedback() end)

    --@更多
    self.btn_gongao = self:getUIChild("btn_gongao")
    self.btn_gongao:addClickEventListener(function ( event ) self:onGongGao() end)

    --@玩法
    self.btn_wanfa = self:getUIChild("btn_wanfa")
    self.btn_wanfa:addClickEventListener(function ( event ) self:onWanFa() end)


    --@战绩
    self.btn_zhanji = self:getUIChild("btn_zhanji")
    self.btn_zhanji:addClickEventListener(function ( event ) self:onZhanJi() end)



    --@快速加入
    self.btn_kuaisujiaru = self:getUIChild("btn_kuaisujiaru")
    self.btn_kuaisujiaru:addClickEventListener(function ( event ) self:onKuaiSuJiaRu() end)





    --@创建俱乐部
    self.btn_createClub = self:getUIChild("btn_createClub")
    self.btn_createClub:addClickEventListener(function ( event ) self:onCreateClub() end)


    --@加入俱乐部
    self.btn_joinClub = self:getUIChild("btn_joinClub")
    self.btn_joinClub:addClickEventListener(function ( event ) self:onJoinClub() end)






-- 扩展节点必须写在所有getUIChild的最后面，因为扩展节点有同名的子节点会混淆根节点获取某个名字的控件
    self.game_list = self:getUIChild("game_list")
    HallMyGame.new(self, self.game_list)
  
    self.img_clubEmpty = self:getUIChild("img_clubEmpty")
    self.club_list = self:getUIChild("club_list")
    HallClub.new(self, self.club_list, self.img_clubEmpty)

    --后台启动登录到大厅 -- 如果是游戏过来的不处理
    -- local login2hall = gameConfMgr:getInfo("LoginView2HallView")
    -- if login2hall == true then 
    --     gameConfMgr:setInfo("LoginView2HallView", false)--清除
    --     comFunMgr:checkEnterRoom()
    -- end    
    if comDataMgr:getInfo("isFirstEnterHall") then
        if not gameConfMgr:getInfo("appstore_check") then
            viewMgr:show("OtherView.activitynotice_view",2)
        end
        comDataMgr:setInfo("isFirstEnterHall",false)
    end
    

    eventMgr:registerEventListener("update_card_gold",handler(self,self.onCardUpdate),"hall_scene")

    --check pay type
    hallSendMgr:H5PayCheck()
    platformMgr:register_IAP_Callback(function(result)
        if result then
            hallSendMgr:sendIAPReceipt(result , gameConfMgr:getInfo("appstore_check"))
            
            local function callfunc_iap()
                hallSendMgr:sendIAPReceipt(result , gameConfMgr:getInfo("appstore_check"))
            end
            timerMgr:registerTask("sendIAPReceipt_update",timerMgr.TYPE_CALL_RE,callfunc_iap,3)
        end    
    end)

    --
    marqueeMgr:changeScene()
end

function HallScene_view:update(t)

end

function HallScene_view:onExit()
    timerMgr:unRegister(self)
    eventMgr:removeEventListenerForTarget("hall_scene")
    eventMgr:removeEventListenerForTarget(self)

end

function HallScene_view:onClickMJ()
    LOG("麻将")
    local view = viewMgr:show("gameListView.gameList_viewA")
    view:init(externGameMgr.GameType_majiang)
end

function HallScene_view:onClickPK()
     -- msgMgr:showToast("扑克暂未开放", 3)
    local view = viewMgr:show("gameListView.gameList_viewA")
    view:init(externGameMgr.GameType_puke)
end

function HallScene_view:onClickPHZ()
    -- msgMgr:showToast("字牌暂未开放", 3)
    local view = viewMgr:show("gameListView.gameList_viewA")
    view:init(externGameMgr.GameType_paohuzi)
end



--头像信息
function HallScene_view:onHead()
    -- msgMgr:showToast("头像信息暂未开放", 3)
    local view = viewMgr:show("OtherView.player_view")
    view:setMyInfo()
end

--商店界面
function HallScene_view:onShop()
    -- msgMgr:showToast("商店暂未开放", 3)
    viewMgr:show("OtherView.shop_view")
end

--实名认证界面
function HallScene_view:onShiMing()
    -- msgMgr:showToast("实名暂未开放", 3)
    viewMgr:show("OtherView.shiMing_view")
end

--反馈界面
function HallScene_view:onFeedback()
    -- msgMgr:showToast("反馈暂未开放", 3)
    viewMgr:show("OtherView.FeedbackUI")
end


--分享
function HallScene_view:onFenXiang()
    -- msgMgr:showToast("分享暂未开放", 3)
    viewMgr:show("OtherView.shareUI")
end

--设置
function HallScene_view:onSetting()
    -- msgMgr:showToast("设置暂未开放", 3)
    viewMgr:show("OtherView.SetUI")
end

--信息
function HallScene_view:onXinXi()
    -- msgMgr:showToast("信息暂未开放", 3)
    viewMgr:show("OtherView.XinxiUI")
end

--公告
function HallScene_view:onGongGao()
    -- msgMgr:showToast("更多暂未开放", 3)
    viewMgr:show("OtherView.activitynotice_view",2)
end

--玩法
function HallScene_view:onWanFa()
    msgMgr:showToast("玩法暂未开放", 3)
end

--战绩
function HallScene_view:onZhanJi()
    msgMgr:showToast("战绩暂未开放", 3)
end

--快速加入
function HallScene_view:onKuaiSuJiaRu()
    viewMgr:show("OtherView.RoomNumberUI")
end

--创建俱乐部
function HallScene_view:onCreateClub()

    viewMgr:show("ClubView.UI_CreateClub")
end

--加入俱乐部
function HallScene_view:onJoinClub()

    viewMgr:show("ClubView.UI_JoinClub")
end

function HallScene_view:onShuaXin()
    hallSendMgr:sendClubList()

    -- if not self.shuaxin_lock then
    --         self.shuaxin_lock = true
    --         local schedulerID = false
    --         local scheduler = cc.Director:getInstance():getScheduler()
    --         local function cb(dt)
    --             cclog("self.shuaxin_lock  false")
    --             scheduler:unscheduleScriptEntry(schedulerID)
    --             self.shuaxin_lock = false
    --         end
    --         schedulerID = scheduler:scheduleScriptFunc(cb, 5,false) 
    --         ex_hallHandler:toClubList()
    --         GlobalFun:showToast("刷新成功" , 3)
    --         CCXNotifyCenter:notify("ActivitysReCheckActivity") -- 用于活动的刷新（活动结束后可以删除）
    --     else
    --         GlobalFun:showToast("刷新过于频繁，请稍后再刷新" , 3)
    --     end
end

function HallScene_view:onCardUpdate()
    self.txt_fangka:setString(gameConfMgr:getInfo("cards"))
    local gold = gameConfMgr:getInfo("gold")
    self.txt_gold:setString(comFunMgr:num_length_ctrl(gold))
end    

return HallScene_view






