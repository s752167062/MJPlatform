
--断线重连等，当前ui数据必须重新请求
local GameListViewA = class("GameListViewA",cc.load("mvc").ViewBase)


local gameItem = require("app.views.gameListView.GameItem")

GameListViewA.RESOURCE_FILENAME = __platformHomeDir .."ui/layout/GameListView/GameListViewA.csb"

function GameListViewA:init(gtype)
    cclog("GameListViewA:init >>>", gtype)
    self.gtype = gtype

    self:findChildByName("bg_majiang"):setVisible(gtype == externGameMgr.GameType_majiang)
    self:findChildByName("title_majiang"):setVisible(gtype == externGameMgr.GameType_majiang)

    self:findChildByName("bg_puke"):setVisible(gtype == externGameMgr.GameType_puke)
    self:findChildByName("title_puke"):setVisible(gtype == externGameMgr.GameType_puke)

    self:findChildByName("bg_zhipai"):setVisible(gtype == externGameMgr.GameType_paohuzi)
    self:findChildByName("title_zhipai"):setVisible(gtype == externGameMgr.GameType_paohuzi)



    hallSendMgr:sendGameList(self.gtype, 1)
end

function GameListViewA:onEnter()
    

    self.cur_pageIdx = 1
    self.max_pageIdx = 1000
    self.common_tab = {}

    self.txt_fangka = self:findChildByName("txt_fangka")
    self.txt_gold = self:findChildByName("txt_jinbi")
    self.txt_fangka:setString(gameConfMgr:getInfo("cards"))
    local gold = gameConfMgr:getInfo("gold")
    self.txt_gold:setString(comFunMgr:num_length_ctrl(gold))

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



    self.txt_page = self:findChildByName("txt_page")
    self.btn_left = self:findChildByName("btn_left")
    self.btn_right = self:findChildByName("btn_right")
    self.btn_left:onClick(function() self:onChangePage(1) end)
    self.btn_right:onClick(function() self:onChangePage(2) end)


    self.list_games = self:findChildByName("list_games")
    self.list_games:setScrollBarEnabled(false)

    self.btn_return = self:findChildByName("btn_back") --返回按钮
    self.btn_return:onClick(function() self:onBack() end)

    -- self.bg = self:findChildByName("bg") --
    -- self.bg:onClick(function() self:onClickBg() end)
    -- self.gameListBg = self:findChildByName("gameListBg") --
    -- self.gameListBg:onClick(function() self:onClickBg() end)
    
    self.btn_edit = self:findChildByName("btn_edit") --编辑按钮
    self.btn_edit:onClick(function() self:onClickEdit() end)
    self.btn_noedit = self:findChildByName("btn_noedit") --编辑按钮
    self.btn_noedit:onClick(function() self:onClickEdit() end)
    self.btn_noedit:setVisible(false)

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

    --@快速加入
    self.btn_kuaisujiaru = self:getUIChild("btn_kuaisujiaru")
    self.btn_kuaisujiaru:addClickEventListener(function ( event ) self:onKuaiSuJiaRu() end)


    self.touchTime = 0
    self.touchBegin = false
    self:onUpdate(function(dt) self:update(dt) end)

    eventMgr:registerEventListener("HallProtocol.recvGameList",handler(self,self.recvGameList), self)
    -- eventMgr:registerEventListener("HallProtocol.recvEnterGame",handler(self,self.recvEnterGame), self)
    -- eventMgr:registerEventListener("HallProtocol.recvUpdateOrDownGame",handler(self,self.recvUpdateOrDownGame), self)

    
    
    -- hallSendMgr:sendGameList(self.gtype, 1)
    -- self:recvGameList()
end

function GameListViewA:onExit()
    self:unregisterScriptHandler()
    eventMgr:removeEventListenerForTarget(self)
end

--商店界面
function GameListViewA:onShop()
    -- msgMgr:showToast("商店暂未开放", 3)
    viewMgr:show("OtherView.shop_view")
end
--反馈界面
function GameListViewA:onFeedback()
    -- msgMgr:showToast("反馈暂未开放", 3)
    viewMgr:show("OtherView.FeedbackUI")
end
--信息
function GameListViewA:onXinXi()
    msgMgr:showToast("信息暂未开放", 3)
end

--快速加入
function GameListViewA:onKuaiSuJiaRu()
    -- msgMgr:showToast("快速加入暂未开放", 3)
    viewMgr:show("OtherView.RoomNumberUI")
end


function GameListViewA:onHead()
    local view = viewMgr:show("OtherView.player_view")
    view:setMyInfo()
end    

function GameListViewA:onClickEdit()
    if self.isShake then
        
        self:stopShakeGameIcon()
    else
        self:shakeGameIcon()
    end
end

-- function GameListViewA:onClickBg()
--     self:stopShakeGameIcon()
-- end

function GameListViewA:onBack()
    viewMgr:close("gameListView.gameList_viewA")
end

function GameListViewA:setPage(cur, max)
    self.txt_page:setString(string.format("%s/%s", cur, max))
    self.cur_pageIdx = cur
    self.max_pageIdx = max

    self.btn_left:setEnabled(self.cur_pageIdx >1)
    self.btn_right:setEnabled(self.cur_pageIdx < self.max_pageIdx)
    cclog("GameListViewA:setPage >>>", cur, max)
end

function GameListViewA:onChangePage(ctype)
    if ctype == 1 then -- left
        local idx = self.cur_pageIdx - 1
        if idx <= 0 then
        else
            hallSendMgr:sendGameList(self.gtype, idx)
        end

    elseif ctype == 2 then  -- right
        local idx = self.cur_pageIdx + 1
        if idx > self.max_pageIdx then
        else
            hallSendMgr:sendGameList(self.gtype, idx)
        end
    end
end

function GameListViewA:update(dt)
    --长按删除方式目前不需要
    -- if self.touchBegin and not self.isShake then
        -- self.touchTime = self.touchTime +dt
        -- if self.touchTime >2 then
        --     self.touchBegin = false
        --     self.touchTime = 0
        --     self:shakeGameIcon()
        -- end
    -- end
end

function GameListViewA:shakeGameIcon()
    if self.isShake then return end

    self.isShake = true
    for k,v in pairs(self.common_tab) do
        local node = v.icon
        local t = 0.08
        local ro = 10
        node:setRotation(ro)
        local r1 = cc.RotateBy:create(t, -ro)
        local r2 = cc.RotateBy:create(t, -ro)
        local r3 = cc.RotateBy:create(t, ro)
        local r4 = cc.RotateBy:create(t, ro)
        local sequence = cc.Sequence:create(r1, r2, r3, r4)
       
        node:runAction(cc.RepeatForever:create(sequence))

        local data = v.data
        if data then
            node:setDelState(data.game, true)
        end
    end

    self.btn_noedit:setVisible(self.isShake)
    self.btn_edit:setVisible(not self.isShake)
end

function GameListViewA:stopShakeGameIcon()
    for k,v in pairs(self.common_tab) do
        local node = v.icon
        transition.stopTarget(node)
        node:setRotation(0)

        local data = v.data
        if data then
            node:setVersionState(data.game, data.version)
        end
    end
    self.isShake = false
    self.btn_noedit:setVisible(self.isShake)
    self.btn_edit:setVisible(not self.isShake)
end

function GameListViewA:cleanGame(index)




    local common = self.common_tab[index]
    if common and common.data then


        local function queding()
            local isok = externGameMgr:deleteGameDirByName(common.data.game)  --总是清理（绝对清理）
            cclog("GameListViewA:cleanGame isExist>>> ", isExist,isok, common.data.game, index)
            common.icon:setVersionState(common.data.game, common.data.version)
            hallSendMgr:sendMyGameList()
        end

        msgMgr:showAskMsg(string.format("是否要删除[%s]游戏", common.data.name), queding)


    end
end


function GameListViewA:createGameCommon(res)
    if next(self.common_tab) then return end

    local contentSize = self.list_games:getContentSize()
    local data = res.data
    local num = res.curShowNum
    local row = 5--排数
    local col = math.ceil(num/row)--行数
    local w, h = 140, 150
    local totalWidth = w * row--总宽度
    local totalHeight = h * col--总高度
    if totalHeight <= contentSize.height then
        totalHeight = contentSize.height
    end
    local offset_x, offset_y = w, h
    local uiIndex = 0
    local pos_x, pos_y = 0, totalHeight

    
    -- cclog("xxx >", num,row,col)

    for index = 1, num do

        if uiIndex%row == 0  then
            pos_x = 25
            pos_y = pos_y - offset_y -20
        else
            pos_x = pos_x + offset_x + 48
        end
        uiIndex = uiIndex + 1

        local layout = ccui.Layout:create()
        local size = cc.size(w +2, h +2)
        layout:setContentSize(size)
        layout:setPosition(cc.p(pos_x,pos_y))



        local icon = gameItem.new()
        
    

        icon:setPosition(size.width/2, size.height/2)
        icon:addTo(layout)




        -- cclog("b>", pos_x,pos_y, index)
      

        icon:setListenTouch(function(event) 
                cclog("touch >>>", index, event.name)
                if event.name == "began" then
                    self.touchBegin = true
                elseif event.name == "moved" then

                elseif event.name == "ended" then
                    if self.touchBegin and self.isShake then  --摇晃后再次点击,发生摇晃的那次触摸self.touchBegin已为false
                        cclog("icon:setListenTouch > shake click")
                        self:cleanGame(index)
                        
                    elseif not self.isShake then -- 不摇晃时点击
                        cclog("icon:setListenTouch > click")
                        self:onClickGame(index)
                        -- self:stopShakeGameIcon()
                    end
                    
                    self.touchBegin = false
                    self.touchTime = 0
                elseif event.name =="cancelled" then
                    self.touchBegin = false
                    self.touchTime = 0
                    -- self:stopShakeGameIcon()
                end 
            end)
        self.list_games:addChild(layout)
        self.common_tab[index] = {item = layout, icon = icon, data = nil}
    end

   
    local innerSize = self.list_games:getInnerContainer():getContentSize()
    self.list_games:setInnerContainerSize(cc.size(innerSize.width,totalHeight))
     -- cclog("aa >",innerSize.width,totalHeight)
end

function GameListViewA:showGamesCommonData(idx, info)
    local common = self.common_tab[idx]
    if info then
        if common then
            local icon = common.icon
            
            local item = common.item
            common.item:setVisible(true)
            icon:setName(info.name)
            icon:setIcon(info.name, self.url .. info.icon)
            icon:setVersionState(info.game, info.version)
            common.data = info
        end
    else
        if common then
            local icon = common.icon
       
            local item = common.item
            common.item:setVisible(false)
            icon:setName("")
            icon:removeHeadImg()
            icon:setVersionState()
            common.data = nil

        end
    end
end

function GameListViewA:showGames(res)
    for k = 1, res.curShowNum do
        self:cleanGamesCommon(k)

        local info = res.data[k]
        self:showGamesCommonData(k, info)

    end
end

function GameListViewA:cleanGamesCommon(idx)
    self:showGamesCommonData(idx, nil)
end

function GameListViewA:recvGameList(res)
    
    -- local res = {
    --     curShowNum = 12,
    --     url = "http://192.168.1.200/zhuzhi_zhuzhijihe/ExternGameAssets/GameIcons/",
    --     data ={
    --         [1] = {name = "红中麻将", game = "hongzhong", product = "hz", showState = 0, icon = "hongzhong1.png", version = "1.0.1"},
    --         [2] = {name = "王麻将", game = "wangmajiang", product = "wmj", showState = 0, icon = "wangmajiang1.png", version = "1.0.1"},
    --         [3] = {name = "红中麻将", game = "hongzhong", product = "hz", showState = 0, icon = "hongzhong1.png", version = "1.0.1"},
    --         [4] = {name = "王麻将", game = "wangmajiang", product = "wmj", showState = 0, icon = "wangmajiang1.png", version = "1.0.1"},
    --         [5] = {name = "红中麻将", game = "hongzhong", product = "hz", showState = 0, icon = "hongzhong1.png", version = "1.0.1"},
    --         [6] = {name = "王麻将", game = "wangmajiang", product = "wmj", showState = 0, icon = "wangmajiang1.png", version = "1.0.1"},
    --         [7] = {name = "红中麻将", game = "hongzhong", product = "hz", showState = 0, icon = "hongzhong1.png", version = "1.0.1"},
    --         [8] = {name = "王麻将", game = "wangmajiang", product = "wmj", showState = 0, icon = "wangmajiang1.png", version = "1.0.1"},
    --         [9] = {name = "红中麻将", game = "hongzhong", product = "hz", showState = 0, icon = "hongzhong1.png", version = "1.0.1"},
    --         [10] = {name = "王麻将", game = "wangmajiang", product ="wmj" , showState = 0, icon = "wangmajiang1.png", version = "1.0.1"},
    --     }
    -- }

    self:stopShakeGameIcon()
    self:setPage(res.curPage, res.maxPage)
    res.curShowNum = res.curShowNum or 10

    self.url = res.url
    self:createGameCommon(res)
    self:showGames(res)
end


function GameListViewA:onClickGame(index)
    cclog("GameListViewA:onClickGame >>>", index)
    local common = self.common_tab[index]
    if common and common.data then
        cclog("common.data >>>>>")
        print_r(common.data)


        -- self:recvEnterGame({game = common.data.game})

        local version = externGameMgr:getGameVersionByName(common.data.game)
        -- hallSendMgr:sendEnterGame(common.data.product, version)
        externGameMgr:reqGotoGame(0, common.data.product)

        cclog("common.data.product version >>", common.data.product, version)
    end
end




return GameListViewA










