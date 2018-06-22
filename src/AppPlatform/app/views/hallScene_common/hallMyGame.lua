

local gameItem = require("app.views.gameListView.GameItem")

local HallMyGame = class("HallMyGame", function() return cc.Node:create() end)

function HallMyGame:ctor(root, list)
	cclog("HallMyGame:ctor >>>>", root, list)
	self.list_games = list

	list:setScrollBarEnabled(false)



	self:enableNodeEvents()
	root:addChild(self)
end

function HallMyGame:onEnter()
	cclog("HallMyGame:onEnter >>>>")
	hallSendMgr:sendMyGameList()

	self.common_tab = {}
	eventMgr:registerEventListener("HallProtocol.recvMyGameList",handler(self,self.recvMyGameList), self)
	-- eventMgr:registerEventListener("HallProtocol.recvEnterGame",handler(self,self.recvEnterGame), self)
    -- eventMgr:registerEventListener("HallProtocol.recvUpdateOrDownGame",handler(self,self.recvUpdateOrDownGame), self)


	-- self:recvMyGameList()
end

function HallMyGame:onExit()
    self:unregisterScriptHandler()
    eventMgr:removeEventListenerForTarget(self)
end






function HallMyGame:createGameCommon(res)
    if next(self.common_tab) then return end

    local contentSize = self.list_games:getContentSize()
    local data = res.data
    local num = res.curShowNum
    local row = 2--排数
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
            pos_x = pos_x + offset_x + 0
        end
        uiIndex = uiIndex + 1

        local layout = ccui.Layout:create()
        local size = cc.size(w +0, h +0)
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

function HallMyGame:showGamesCommonData(idx, info)
    local common = self.common_tab[idx]
    if info then
        if common then
            local icon = common.icon
            
            local item = common.item
            common.item:setVisible(true)
            icon:setName(info.name)
            icon:setIcon(info.name, self.url .. info.icon)
            icon:setVersionState(info.game, info.version)

            icon:setShowState(info.showState)
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

            icon:setShowState(0)
            common.data = nil

        end
    end
end

function HallMyGame:showGames(res)
    for k = 1, res.curShowNum do
        self:cleanGamesCommon(k)

        local info = res.data[k]
        self:showGamesCommonData(k, info)

    end
end

function HallMyGame:cleanGamesCommon(idx)
    self:showGamesCommonData(idx, nil)
end

function HallMyGame:recvMyGameList(res)
   cclog("HallMyGame:recvGameList >>>")
    -- local res = {
    --     curShowNum = 12,
    --     url = "http://192.168.1.200/zhuzhi_zhuzhijihe/ExternGameAssets/GameIcons/",
    --     data ={
    --         [1] = {name = "红中麻将", game = "hongzhong", icon = "hongzhong1.png", version = "1.0.1"},
    --         [2] = {name = "王麻将", game = "wangmajiang", icon = "wangmajiang1.png", version = "1.0.1"},
    --     }
    -- }

    res.curShowNum = #res.data

    if res.curShowNum ~= #self.common_tab then
        self.common_tab = {}
        self.list_games:removeAllChildren()
    end

    self.url = res.url
    self:createGameCommon(res)
    self:showGames(res)
    gameConfMgr:setInfo("myGameListData",res.data)
end


function HallMyGame:onClickGame(index)
    cclog("HallMyGame:onClickGame >>>", index)
    local common = self.common_tab[index]
    if common and common.data then
        cclog("common.data >>>>>")
        print_r(common.data)


        -- self:recvEnterGame({game = common.data.game})

        local version = externGameMgr:getGameVersionByName(common.data.game)
        -- hallSendMgr:sendEnterGame(common.data.product, version)
        externGameMgr:reqGotoGame(0, common.data.product)

        -- cclog("common.data.product version >>", common.data.product, version)
    end
end






return HallMyGame




