
--断线重连等，当前ui数据必须重新请求
local ClubSelectGameView = class("ClubSelectGameView",cc.load("mvc").ViewBase)


local gameItem = ex_fileMgr:loadLua(PATH_CLUB_LUA.."GameItem")


ClubSelectGameView.RESOURCE_FILENAME = "club/ClubSelectGameView.csb"

function ClubSelectGameView:init(clubId)
    self.clubId = clubId




end

function ClubSelectGameView:onEnter()
    

    self.cur_pageIdx = 1
    self.max_pageIdx = 1000
    self.common_tab = {}

   



    self.list_games = self:findChildByName("list_games")
    self.list_games:setScrollBarEnabled(false)

    self.btn_return = self:findChildByName("btn_back") --返回按钮
    self.btn_return:onClick(function() self:onBack() end)




    self.cb_majiang = self:findChildByName("cb_majiang")
    self.cb_majiang:onEvent(function(event) self:setCheckBoxGroup(1) end)
    self.cb_puke = self:findChildByName("cb_puke")
    self.cb_puke:onEvent(function(event) self:setCheckBoxGroup(2) end)
    self.cb_zipai = self:findChildByName("cb_zipai")
    self.cb_zipai:onEvent(function(event) self:setCheckBoxGroup(3) end)

    self.checkBoxGroup = {
        {obj = self.cb_majiang, state = false, gameType = platformExportMgr:getGameClassifyType("mj")},
        {obj = self.cb_puke, state = false, gameType = platformExportMgr:getGameClassifyType("pk")},
        {obj = self.cb_zipai, state = false, gameType = platformExportMgr:getGameClassifyType("phz")},
    }

   

    self.txt_page = self:findChildByName("txt_page")
    self.btn_lastPage = self:findChildByName("btn_lastPage")
    self.btn_nextPage = self:findChildByName("btn_nextPage")
    self.btn_lastPage:onClick(function() self:onChangePage(1) end)
    self.btn_nextPage:onClick(function() self:onChangePage(2) end)
    
    

    CCXNotifyCenter:listen(self,function(obj,key,data) self:recvGameList(data) end, "ClubController.onGameList")



    self:setCheckBoxGroup(1)
    -- self:recvGameList()
end

function ClubSelectGameView:onExit()
    CCXNotifyCenter:unListenByObj(self)
    ex_timerMgr:unRegister(self)
end


function ClubSelectGameView:onChangePage(ctype)
    if ctype == 1 then -- left
        local idx = self.cur_pageIdx - 1
        if idx <= 0 then
        else
            ex_clubHandler:sendGameList(self.gtype, idx)
        end

    elseif ctype == 2 then  -- right
        local idx = self.cur_pageIdx + 1
        if idx > self.max_pageIdx then
        else
            ex_clubHandler:sendGameList(self.gtype, idx)
        end
    end
end




function ClubSelectGameView:onBack()
    self:removeFromParent()
end


function ClubSelectGameView:setCheckBoxGroup(ctype)

    for k,v in pairs(self.checkBoxGroup) do
        v.obj:setSelected(false)
        v.state = false
    end


    local tab = self.checkBoxGroup[ctype]
   
    tab.obj:setSelected(true)
    tab.state = true
    cclog("ClubSelectGameView:setCheckBoxGroup >>>", ctype)

    self.gtype = ctype
    ex_clubHandler:sendGameList(tab.gameType, 1)
end



function ClubSelectGameView:setPage(cur, max)
    self.txt_page:setString(string.format("%s/%s", cur, max))
    self.cur_pageIdx = cur
    self.max_pageIdx = max
    cclog("ClubSelectGameView:setPage >>>", cur, max)
end


function ClubSelectGameView:onMajiang()
end

function ClubSelectGameView:onPuke()
end

function ClubSelectGameView:onZipai()
end





function ClubSelectGameView:createGameCommon(res)
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
            pos_x = 0
            pos_y = pos_y - offset_y 
        else
            pos_x = pos_x + offset_x + 40
        end
        uiIndex = uiIndex + 1

        local layout = ccui.Layout:create()
        local size = cc.size(w +2, h +2)
        layout:setContentSize(size)
        layout:setPosition(cc.p(pos_x,pos_y))



        local icon = gameItem.new()
        
    

        icon:setPosition(size.width/2, size.height/2)
        icon:addTo(layout)




        icon:setClickFunc(function() self:onClickGame(index) end)
      

        
        self.list_games:addChild(layout)
        self.common_tab[index] = {item = layout, icon = icon, data = nil}
    end

   
    local innerSize = self.list_games:getInnerContainer():getContentSize()
    self.list_games:setInnerContainerSize(cc.size(innerSize.width,totalHeight))
     -- cclog("aa >",innerSize.width,totalHeight)
end

function ClubSelectGameView:showGamesCommonData(idx, info)
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

function ClubSelectGameView:showGames(res)
    for k = 1, res.curShowNum do
        self:cleanGamesCommon(k)

        local info = res.data[k]
        self:showGamesCommonData(k, info)

    end
end

function ClubSelectGameView:cleanGamesCommon(idx)
    self:showGamesCommonData(idx, nil)
end

function ClubSelectGameView:recvGameList(res)
    

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

    self.common_tab = {}
    self.list_games:removeAllChildren()

    if not next(res) then return end 
    res.curShowNum = res.curShowNum or 10

    -- if res.curShowNum ~= #self.common_tab then
    --     self.common_tab = {}
    --     self.list_games:removeAllChildren()
    -- end

    self:setPage(res.curPage, res.maxPage)
    self.url = res.url
    self:createGameCommon(res)
    self:showGames(res)
end


function ClubSelectGameView:onClickGame(index)
    cclog("ClubSelectGameView:onClickGame >>>", index)
    local common = self.common_tab[index]
    if common and common.data then
        cclog("common.data >>>>>")
        print_r(common.data)

        local version = platformExportMgr:doExternGameMgrgetGameVersionByName(common.data.game)
        cclog("common.data.product version >>", common.data.product, version)
     

        CCXNotifyCenter:listen(self,function(obj,key,data)
                                cclog("ClubSelectGameView:onClickGame >>> 222")
                              if data.isSucc then
                                    ex_clubHandler:sendPlayingList()
                                    self:onBack()
                              end   
                    end, "ClubController.onAddGamePlaying")

        
        ex_clubHandler:sendAddGamePlaying(self.clubId, common.data.product)
    end
end



return ClubSelectGameView










