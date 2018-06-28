--ex_fileMgr:loadLua("app.views.game.UserScoreFile")
--ex_fileMgr:loadLua("app.views.game.LocalDataFile")

local UI_ClubCombatGains = class("UI_ClubCombatGains",function() 
    return cc.Node:create()
end)

function UI_ClubCombatGains:ctor(data)
    self.root = display.newCSNode("club/UI_ClubCombatGains.csb")
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
    
    self.battleData = {} --战绩数据
end

function UI_ClubCombatGains:onEnter()
    self.ctn_close = self:findChildByName("btn_close") --关闭按钮
    self.ctn_close:addClickEventListener(function() self:onClose() end)
    self.ctn_close:setVisible(true)
    
    self.ctn_return = self:findChildByName("btn_return") --返回按钮
    self.ctn_return:addClickEventListener(function() self:onReturn() end)
    self.ctn_return:setVisible(false)
    
    self.listview = self:findChildByName("ListView") --列表
    self.listview:removeAllItems()
    
    self.tips = self:findChildByName("tips") --提示
    self.tips:setVisible(false)
    
    CCXNotifyCenter:listen(self,function(obj,key,data) self:showVideo(data) end,"showVideo")

    self.btn_help = self:findChildByName("btn_help") --帮助按钮
    self.btn_help:addClickEventListener(function() self:onHelp() end)


    local myinfo_node = self:findChildByName("bg_myInfo")
    local icon_node = myinfo_node:findChildByName("img_myIcon")
    local icon = ex_fileMgr:loadLua("app.views.club.PlayerIcon").new()
    -- icon:setScale(0.5)
    local size = icon_node:getContentSize()
    icon:setPosition(size.width/2, size.height/2)
    icon:setIcon(PlayerInfo.playerUserID, PlayerInfo.headimgurl)
    icon_node:addChild(icon)

    local name = myinfo_node:findChildByName("txt_myName")
    GlobalFun:uiTextCut(name)
    name:setString(PlayerInfo.nickname)

    local id = myinfo_node:findChildByName("txt_myId")
    id:setString("ID: " .. PlayerInfo.playerUserID)

    local fk = myinfo_node:findChildByName("txt_fangka")
    fk:setString(GlobalData.CartNum or 0)


    self.battleData = LocalDataFile:readData(UserScoreFile.originType_1, ClubManager:getClubSecndID())
    --显示总战绩界面
    self:showBigBattleUI()
end

function UI_ClubCombatGains:onExit()
    CCXNotifyCenter:unListenByObj(self)
    self:unregisterScriptHandler()--取消自身监听
end

function UI_ClubCombatGains:onReturn()
    self:showBigBattleUI()
end

function UI_ClubCombatGains:showBigBattleUI()
    if self.battleData == nil or not next(self.battleData) then --没有战绩，则显示提示
        self.tips:setVisible(true)
        return
    end
    
    self.ctn_return:setVisible(false)
    -- self.ctn_close:setVisible(true)
    self.listview:removeAllItems()

    for index = 1, table.getn(self.battleData) do
        -- if self.battleData[index].isFinish == true then


            local layout = ccui.Layout:create()
            local layout_size = cc.size(660,113)
            layout:setContentSize(layout_size)

            local item = ex_fileMgr:loadLua("app.views.club.item_CombatGains").new()
            -- item:setPosition(cc.p(10,-5))
            item:setTag(800)
            item:addTo(layout)

            local newbtn = ccui.Button:create("image/alpha.png" , "image/alpha.png")
            local size = newbtn:getContentSize()
            newbtn:setScale( layout_size.width/size.width , layout_size.height /size.height)
            newbtn:setPosition(cc.p(0,0))
            newbtn:setAnchorPoint(0,0)
            newbtn:addClickEventListener(function() self:onShowSmallUI(index) end)
            newbtn:addTo(layout)

            self.listview:pushBackCustomItem(layout)
        -- end
    end
    
    local listdata = self.listview:getItems()
    for index, item in pairs(listdata) do
        local p = self.battleData[index]
        local panel = item:getChildByTag(800).root:findChildByName("areaPanel")

        local text_game = panel:findChildByName("game");
        text_game:setString("红中麻将") -- 其他玩法的人，好自为之，自己弄

        local text_room = panel:findChildByName("room");
        local strRoom = "房间号：" .. p.roomID
        text_room:setString(strRoom or "房间号为空")

        local text_round = panel:findChildByName("round") 
        local numb = 0
        for k,v in pairs(p.name) do
            numb = numb+1
        end
        local strRound = numb .. "人/".. p.gameCnt .. "局"
        text_round:setString(strRound or "局数为空")


        local text_time = panel:findChildByName("time") 
        local strTime = "时间：" .. p.years .. "-".. p.month .. "-".. p.day .. " " .. p.gameTime
        text_time:setString(strTime or "时间为空")

        local text_name1  = panel:findChildByName("name1") 
        GlobalFun:uiTextCut(text_name1)
        text_name1:setString(p.name[1] or "")
        local text_name2  = panel:findChildByName("name2") 
        GlobalFun:uiTextCut(text_name2)
        text_name2:setString(p.name[2] or "")
        local text_name3  = panel:findChildByName("name3") 
        GlobalFun:uiTextCut(text_name3)
        text_name3:setString(p.name[3] or "")
        local text_name4  = panel:findChildByName("name4") 
        GlobalFun:uiTextCut(text_name4)
        text_name4:setString(p.name[4] or "")
        local text_score1  = panel:findChildByName("score1") 
        text_score1:setString("")
        local text_score2  = panel:findChildByName("score2") 
        text_score2:setString("")
        local text_score3  = panel:findChildByName("score3") 
        text_score3:setString("")
        local text_score4  = panel:findChildByName("score4") 
        text_score4:setString("")
        
        if p.summary ~= nil then
            if p.summary[1] and p.summary[1] > 0 then 
                text_score1:setString("+" ..p.summary[1])
                text_score1:setTextColor(cc.c3b(231,88,43))
            else
                text_score1:setString(p.summary[1] or "")
            end  

            local text_score2  = panel:findChildByName("score2") 
            if p.summary[2] and p.summary[2] > 0 then 
                text_score2:setString("+" ..p.summary[2])
                text_score2:setTextColor(cc.c3b(231,88,43))
            else
                text_score2:setString(p.summary[2] or "")
            end

            local text_score3  = panel:findChildByName("score3")
            if p.summary[3] and p.summary[3] > 0 then 
                text_score3:setString("+" ..p.summary[3])
                text_score3:setTextColor(cc.c3b(231,88,43))
            else 
                text_score3:setString(p.summary[3] or "")
            end
                
            local text_score4  = panel:findChildByName("score4")
            if p.summary[4] and p.summary[4] > 0 then 
                text_score4:setString("+" ..p.summary[4])
                text_score4:setTextColor(cc.c3b(231,88,43))
            else 
                text_score4:setString(p.summary[4] or "") 
            end    
        end
        local text_currentRound = panel:findChildByName("currentRound") 
        text_currentRound:setVisible(false) 
    end
end

function UI_ClubCombatGains:onShowSmallUI(round)
    if self.battleData[round].branch == nil or type(self.battleData[round].branch) ~= "table" then --没有战绩
        release_print("self.battleData[round].branch 为空")
        return
    end
    
    self.ctn_return:setVisible(true)
    -- self.ctn_close:setVisible(false)
    self.listview:removeAllItems()
    
    for index = 1, table.getn(self.battleData[round].branch) do
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(660,113))

        local item = ex_fileMgr:loadLua("app.views.club.item_CombatGains").new()
        
        local f = self.battleData[round]
        local p = f.branch[index]
        

        
        local vd = {roomid = f.roomID ,curr = p.currLevel,cnt = f.gameCnt,zhama = f.zhama, uniqueKey = f.uniqueKey, originKey = ClubManager:getClubSecndID(), originType = UserScoreFile.originType_1}
        item:setVideoData(vd)
        
        -- item:setPosition(cc.p(10,-5))
        item:setTag(900)
        item:addTo(layout)

        self.listview:pushBackCustomItem(layout)
    end
    
    local listdata = self.listview:getItems()
    for index, item in pairs(listdata) do
        local f = self.battleData[round]
        local p = f.branch[index]
        local panel = item:getChildByTag(900).root:findChildByName("areaPanel")
        panel:setSwallowTouches(false)

        local btn_video = panel:findChildByName("btn_video")
        btn_video:setVisible(true)
 
        local text_room = panel:findChildByName("room");
        text_room:setString("")
        local text_game = panel:findChildByName("game");
        text_game:setString("")
        local text_round  = panel:findChildByName("round") 
        text_round:setString("")
        local text_time = panel:findChildByName("time") 
        text_time:setString(p.currTime or "")
        -- text_time:setPositionX(370)
        -- local image_line = panel:getChildByName("line") 
        -- image_line:setVisible(false) 
        local text_name1 = panel:findChildByName("name1") 
        text_name1:setString(f.name[1] or "")
        local text_name2 = panel:findChildByName("name2") 
        text_name2:setString(f.name[2] or "")
        local text_name3 = panel:findChildByName("name3") 
        text_name3:setString(f.name[3] or "")
        local text_name4 = panel:findChildByName("name4") 
        text_name4:setString(f.name[4] or "")
        
        local text_score1 = panel:findChildByName("score1") 
        text_score1:setString("")
        local text_score2  = panel:findChildByName("score2") 
        text_score2:setString("")
        local text_score3  = panel:findChildByName("score3") 
        text_score3:setString("")
        local text_score4  = panel:findChildByName("score4") 
        text_score4:setString("")

        if p.score[1] and p.score[1] >0 then
            text_score1:setString("+" ..p.score[1])
            text_score1:setTextColor(cc.c3b(231,88,43))
        else    
            text_score1:setString(p.score[1] or "")
        end

        local text_score2 = panel:findChildByName("score2") 
        if p.score[2] and p.score[2] >0 then
            text_score2:setString("+" ..p.score[2])
            text_score2:setTextColor(cc.c3b(231,88,43))
        else
            text_score2:setString(p.score[2] or "")
        end

        local text_score3 = panel:findChildByName("score3") 
        if p.score[3] and p.score[3] >0 then
            text_score3:setString("+" ..p.score[3])
            text_score3:setTextColor(cc.c3b(231,88,43))
        else
            text_score3:setString(p.score[3] or "")
        end

        local text_score4 = panel:findChildByName("score4")
        if p.score[4] and p.score[4] >0 then
            text_score4:setString("+" ..p.score[4])
            text_score4:setTextColor(cc.c3b(231,88,43))
        else
            text_score4:setString(p.score[4] or "") 
        end

        local text_currentRound = panel:findChildByName("currentRound")
        text_currentRound:setString(p.currLevel)  
        text_currentRound:setVisible(true) 
    end
end

function UI_ClubCombatGains:showVideo(data)
    --local d = data
    local game = ex_fileMgr:loadLua("app.views.game.CUIGame").new()
    
    game:setLocalVideo(data)
    -- self:findChildByName("ctn_video"):addChild(game)
    self:addChild(game)
end

function UI_ClubCombatGains:onClose()
    self:removeFromParent()
end

function UI_ClubCombatGains:onHelp()
    local scene = cc.Director:getInstance():getRunningScene()
    local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubHelp")
    scene:addChild(ui.new({app = nil}))
end

return UI_ClubCombatGains