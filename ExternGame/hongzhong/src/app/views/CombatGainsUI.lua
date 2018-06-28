--ex_fileMgr:loadLua("app.views.game.UserScoreFile")
--ex_fileMgr:loadLua("app.views.game.LocalDataFile")

local CombatGainsUI = class("CombatGainsUI",function() 
    return cc.Node:create()
end)

function CombatGainsUI:ctor(data)
    self.root = display.newCSNode("CombatGainsUI.csb")
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

function CombatGainsUI:onEnter()
    local ctn_close = self.root:getChildByName("bg"):getChildByName("btn_close") --关闭按钮
    ctn_close:addClickEventListener(function() self:onClose() end)
    
    self.ctn_return = self.root:getChildByName("bg"):getChildByName("btn_return") --返回按钮
    self.ctn_return:addClickEventListener(function() self:onReturn() end)
    self.ctn_return:setVisible(false)
    
    self.listview = self.root:getChildByName("bg"):getChildByName("ListView") --列表
    self.listview:removeAllItems()
    
    self.tips = self.root:getChildByName("bg"):getChildByName("tips") --提示
    self.tips:setVisible(false)
    
    CCXNotifyCenter:listen(self,function(obj,key,data) self:showVideo(data) end,"showVideo")

    self.battleData = LocalDataFile:readData(UserScoreFile.originType_0, 0)
    --显示总战绩界面
    self:showBigBattleUI()
end

function CombatGainsUI:onExit()
    CCXNotifyCenter:unListenByObj(self)
    self:unregisterScriptHandler()--取消自身监听
end

function CombatGainsUI:onReturn()
    self:showBigBattleUI()
end

function CombatGainsUI:showBigBattleUI()
    if self.battleData == nil or not next(self.battleData) then --没有战绩，则显示提示
        self.tips:setVisible(true)
        return
    end
    
    self.ctn_return:setVisible(false)
    self.listview:removeAllItems()

    for index = 1, table.getn(self.battleData) do
        -- if self.battleData[index].isFinish == true then


            local layout = ccui.Layout:create()
            layout:setContentSize(cc.size(818,113))

            local item = ex_fileMgr:loadLua("app.views.CombatGainsItem").new()
            item:setPosition(cc.p(10,-5))
            item:setTag(800)
            item:addTo(layout)

            local newbtn = ccui.Button:create("image/alpha.png" , "image/alpha.png")
            local size = newbtn:getContentSize()
            newbtn:setScale( 818/size.width , 155 /size.height)
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
        local panel = item:getChildByTag(800).root:getChildByName("areaPanel")

        local text_room = panel:getChildByName("room");
        local strRoom = "房间号：" .. p.roomID
        text_room:setString(strRoom or "房间号为空")
        local text_round = panel:getChildByName("round") 
        local strRound = p.gameCnt .. "局"
        text_round:setString(strRound or "局数为空")
        local text_time = panel:getChildByName("time") 
        local p_month = tonumber(p.month) < 10 and "0"..p.month or p.month
        local strTime = --[["时间：" ..--]] p.years .. "-".. p_month .. "-".. p.day .. "  " .. p.gameTime
        text_time:setString(strTime or "时间为空")
        local image_line = panel:getChildByName("line") 
        image_line:setVisible(true) 
        local text_name1  = panel:getChildByName("name1") 
        text_name1:setString(p.name[1] or "")
        local text_name2  = panel:getChildByName("name2") 
        text_name2:setString(p.name[2] or "")
        local text_name3  = panel:getChildByName("name3") 
        text_name3:setString(p.name[3] or "")
        local text_name4  = panel:getChildByName("name4") 
        text_name4:setString(p.name[4] or "")
        local text_score1  = panel:getChildByName("score1") 
        
        if p.summary ~= nil then
            if p.summary[1] and p.summary[1] > 0 then 
                text_score1:setString("+" ..p.summary[1])
                text_score1:setTextColor(cc.c3b(231,88,43))
            else
                text_score1:setString(p.summary[1] or "")
            end  

            local text_score2  = panel:getChildByName("score2") 
            if p.summary[2] and p.summary[2] > 0 then 
                text_score2:setString("+" ..p.summary[2])
                text_score2:setTextColor(cc.c3b(231,88,43))
            else
                text_score2:setString(p.summary[2] or "")
            end

            local text_score3  = panel:getChildByName("score3")
            if p.summary[3] and p.summary[3] > 0 then 
                text_score3:setString("+" ..p.summary[3])
                text_score3:setTextColor(cc.c3b(231,88,43))
            else 
                text_score3:setString(p.summary[3] or "")
            end
                
            local text_score4  = panel:getChildByName("score4")
            if p.summary[4] and p.summary[4] > 0 then 
                text_score4:setString("+" ..p.summary[4])
                text_score4:setTextColor(cc.c3b(231,88,43))
            else 
                text_score4:setString(p.summary[4] or "") 
            end    
        end
        local text_currentRound = panel:getChildByName("currentRound")
        text_currentRound:setString(index)
        text_currentRound:setVisible(true) 

    end
end

function CombatGainsUI:onShowSmallUI(round)
    if self.battleData[round].branch == nil or type(self.battleData[round].branch) ~= "table" then --没有战绩
        release_print("self.battleData[round].branch 为空")
        return
    end
    
    self.ctn_return:setVisible(true)
    self.listview:removeAllItems()
    
    for index = 1, table.getn(self.battleData[round].branch) do
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(818,113))

        local item = ex_fileMgr:loadLua("app.views.CombatGainsItem").new()
        
        local f = self.battleData[round]
        local p = f.branch[index]
        
        -- local v_index =  nil
        -- local v_tb = UserScoreFile:getKeyValue("video",{})
        -- for i=1,#v_tb do
        --     if v_tb[i].roomid == f.roomID then
        --         for j=1,#v_tb[i].sv do
        --             if p.currLevel == v_tb[i].sv[j].curr then
        --                 v_index = v_tb[i].sv[j].index
        --                 break
        --             end
        --         end
        --         break
        --     end
        -- end
        
        local vd = {roomid = f.roomID ,curr = p.currLevel,cnt = f.gameCnt,zhama = f.zhama, uniqueKey = f.uniqueKey, originKey = 0, originType = UserScoreFile.originType_0}
        item:setVideoData(vd)
        
        item:setPosition(cc.p(10,-5))
        item:setTag(900)
        item:addTo(layout)

        self.listview:pushBackCustomItem(layout)
    end
    
    local listdata = self.listview:getItems()
    for index, item in pairs(listdata) do
        local f = self.battleData[round]
        local p = f.branch[index]
        local panel = item:getChildByTag(900).root:getChildByName("areaPanel")
        panel:setSwallowTouches(false)

        local btn_video = panel:getChildByName("btn_video")
        btn_video:setVisible(true)
        
        local ctn_btn = panel:getChildByName("btn")
        ctn_btn:setSwallowTouches(false)
        local text_room = panel:getChildByName("room");
        text_room:setString("")
        local text_round  = panel:getChildByName("round") 
        text_round:setString("")
        local text_time = panel:getChildByName("time") 
        text_time:setString(p.currTime or "")
        --text_time:setPosition(cc.p(370,90))
        local image_line = panel:getChildByName("line") 
        image_line:setVisible(false) 
        local text_name1 = panel:getChildByName("name1") 
        text_name1:setString(f.name[1] or "")
        local text_name2 = panel:getChildByName("name2") 
        text_name2:setString(f.name[2] or "")
        local text_name3 = panel:getChildByName("name3") 
        text_name3:setString(f.name[3] or "")
        local text_name4 = panel:getChildByName("name4") 
        text_name4:setString(f.name[4] or "")
        
        local text_score1 = panel:getChildByName("score1") 
        if p.score[1] and p.score[1] >0 then
            text_score1:setString("+" ..p.score[1])
            text_score1:setTextColor(cc.c3b(231,88,43))
        else    
            text_score1:setString(p.score[1] or "")
        end

        local text_score2 = panel:getChildByName("score2") 
        if p.score[2] and p.score[2] >0 then
            text_score2:setString("+" ..p.score[2])
            text_score2:setTextColor(cc.c3b(231,88,43))
        else
            text_score2:setString(p.score[2] or "")
        end

        local text_score3 = panel:getChildByName("score3") 
        if p.score[3] and p.score[3] >0 then
            text_score3:setString("+" ..p.score[3])
            text_score3:setTextColor(cc.c3b(231,88,43))
        else
            text_score3:setString(p.score[3] or "")
        end

        local text_score4 = panel:getChildByName("score4")
        if p.score[4] and p.score[4] >0 then
            text_score4:setString("+" ..p.score[4])
            text_score4:setTextColor(cc.c3b(231,88,43))
        else
            text_score4:setString(p.score[4] or "") 
        end

        local text_currentRound = panel:getChildByName("currentRound")
        text_currentRound:setString(p.currLevel)  
        text_currentRound:setVisible(true) 
    end
end

function CombatGainsUI:showVideo(data)
    --local d = data
    local game = ex_fileMgr:loadLua("app.views.game.CUIGame").new()
    
    game:setLocalVideo(data)
    self.root:getChildByName("ctn_video"):addChild(game)
end

function CombatGainsUI:onClose()
    self:removeFromParent()
end

return CombatGainsUI