local CUIGame_AllSummary = class("CUIGame_AllSummary",function() 
    return cc.Node:create()
end)

function CUIGame_AllSummary:ctor(scene)
    self.root = display.newCSNode("game/CUIGame_AllSummary.csb")
    self.root:addTo(self)
    
    self.isSummary = true
    self.myData = nil
    self.scene = scene

    if scene and scene.allSummaryData then
        local players = scene.allSummaryData.players

        local id = nil
        local offset = nil
        for i=1,4 do
            if scene.player[i].serverPos == 1 then
                id = scene.player[i].id
                break
            end
        end
        if id then
            for i=1,4 do
                if players[i].playerID == id then
                    offset = i-1
                    break
                end
            end
        end
        if offset then
            local tmp_data = {}
            for i=1,4 do
                local tmp_index = i-offset
                if tmp_index < 1 then
                    tmp_index = tmp_index + 4
                end
                tmp_data[tmp_index] = players[i]
            end
            players = tmp_data
        end

        for i=1,3 do
            if players[i] == nil then
                players[i] = players[i+1]
                players[i+1] = nil
            end
        end
        
        local BaseItem = ex_fileMgr:loadLua("app.views.game.item_AllSummary")
        local maxscore = -20000
        for i=1,#players do
            if players[i].score > maxscore then
                maxscore = players[i].score
            end
        end
        
        for i=1,#players do
            for j=1,4 do
                if scene.player[j].openid == players[i].playerID then
                    players[i].name = scene.player[j].name
                    players[i].imgURL = scene.player[j].imgURL
                    break
                end
            end
            if players[i].score >= maxscore then
                players[i].bigwin = true
            else
                players[i].bigwin = false
            end
            --self.root:getChildByName(string.format("ctn_%d",i)):addChild(BaseItem.new(players[i],players[i].playerID == scene.player[1].openid,i,scene.isMatch))
        end

        --剔除自己
        for i, v in ipairs(players) do
            if players[i].playerID == PlayerInfo.playerUserID then
                cclog("fuckfuckfuck getValue")
                --self.myData = players[i]
                self.myData = GlobalFun:copyFromTable(players[i])
                table.remove(players, i)
                break
            end
        end

        for i=1,#players do
            self.root:getChildByName(string.format("ctn_%d",i)):addChild(BaseItem.new(players[i],players[i].playerID == scene.player[1].openid,i,scene.isMatch))
        end

    end
    
    if self.scene and self.scene.playerNum > 1 then
        self.root:getChildByName("ctn_1"):setPositionX(display.width*0.20)
        self.root:getChildByName("ctn_2"):setPositionX(display.width*0.49)
        self.root:getChildByName("ctn_3"):setPositionX(display.width*0.78)
    end
    
    if scene then scene.allSumaryDdata = nil end --清除掉 
    self.root:getChildByName("ctn_btn"):getChildByName("btn_share"):addClickEventListener(function() self:onShare() end)
    self.root:getChildByName("ctn_btn"):getChildByName("btn_hall"):addClickEventListener(function() self:onBackHall() end)
    self.root:getChildByName("ctn_btn"):getChildByName("btn_sure"):addClickEventListener(function() self:onBack() end)
    self.root:getChildByName("ctn_btn"):getChildByName("btn_back"):addClickEventListener(function() self:onBackHall() end)

    cclog("888888888888888888 ")
    local info = {}
     info.roommainid  = GlobalData.roomCreateID
     info.roomCreateImgUrl = GlobalData.roomCreateImgUrl
     info.roomCreateName  = GlobalData.roomCreateName
     info.roomID = GlobalData.roomID
    print_r(info)
    self:showRoomMainInfo(info)

    self:setMyInfo()
end

function CUIGame_AllSummary:ShowOpenRoomItemResult(data,info)

    print_r(data)
    if data then 
        local BaseItem = ex_fileMgr:loadLua("app.views.game.item_AllSummary")
        local maxscore = -20000
        for i=1,#data do
            if data[i].score > maxscore then
                maxscore = data[i].score
            end
        end

        for i=1,#data do
            local itemdata = data[i]

            if itemdata.score >= maxscore then
                data[i].bigwin = true
            else
                data[i].bigwin = false
            end
            cclog("--------- roommainid" , info.roommainid)
            self.root:getChildByName(string.format("ctn_%d",i)):addChild(BaseItem.new(data[i],roommainid ==data[i].playerID ,i,false))
            -- itemdata.playerID 
            -- itemdata.hpcnt 
            -- itemdata.mgcnt 
            -- itemdata.agcnt 
            -- itemdata.zmcnt 
            -- itemdata.score
            -- itemdata.name
        end

        if #data > 1 then
            self.root:getChildByName("ctn_1"):setPositionX(display.width*0.20)
            self.root:getChildByName("ctn_2"):setPositionX(display.width*0.49)
            self.root:getChildByName("ctn_3"):setPositionX(display.width*0.78)
        end
    end

    self.root:getChildByName("ctn_btn"):getChildByName("btn_share"):setVisible(false)
    self.root:getChildByName("ctn_btn"):getChildByName("btn_hall"):setVisible(false)
    self.root:getChildByName("ctn_btn"):getChildByName("btn_sure"):setVisible(true)
    self.root:getChildByName("ctn_btn"):getChildByName("btn_back"):setVisible(false)

    cclog("99999999999999999ßß ")
    print_r(info)
    self:showRoomMainInfo(info)
end

function CUIGame_AllSummary:showRoomMainInfo(info)
     local noderoom = self.root:getChildByName("nodeRoom")
     local icon = noderoom:getChildByName("icon_bg")
     local baseicon = icon:getChildByName("baseicon")
     local txt_roomid = noderoom:getChildByName("txt_roomid")
     local txt_roomname = noderoom:getChildByName("txt_roomname")
     local txt_roommainid = noderoom:getChildByName("txt_roommainid")
     local txt_roomtime = noderoom:getChildByName("txt_roomtime")
     local img_holder = noderoom:getChildByName("img_holder")

    cclog(" ********** 房主id " ,info.roommainid)
    cclog(" ********** 房主name " ,info.roomCreateName)
    cclog(" ********** 房主url " ,info.roomCreateImgUrl)

    img_holder:setVisible(info.roommainid == PlayerInfo.playerUserID)

     txt_roomid:setString(string.format("%s",info.roomID))
     --更改为本人名字
     --txt_roomname:setString(string.format("%s",info.roomCreateName))
     txt_roomname:setString(PlayerInfo.nickname)

     txt_roommainid:setString("ID:" .. info.roommainid)
     txt_roomtime:setString(os.date("%Y/%m/%d %H:%M:%S",os.time()))


    local function callfunc()
        local path = ex_fileMgr:getWritablePath()..info.roommainid .."rcImg.png"
        if ex_fileMgr:isFileExist(path) then 
            local headsp = cc.Sprite:create(path)
            if headsp == nil then
                cc.Director:getInstance():getTextureCache():reloadTexture(path)
            end

            headsp = cc.Sprite:create(path)
            if headsp ~= nil and self.isSummary then
                --[[
                headsp:setAnchorPoint(cc.p(0,0))
                local Basesize = baseicon:getContentSize()
                local Tsize = headsp:getContentSize()
                headsp:setScale(Basesize.width * baseicon:getScale() / Tsize.width ,Basesize.height * baseicon:getScale() / Tsize.height)
                --]]
                GlobalFun:modifyAddNewIcon(icon, headsp, 10, 10, "baseicon")
                icon:addChild(headsp) 
            end
        end    
    end
    
    Util.DownloadFile(info.roomCreateImgUrl  , info.roommainid .."rcImg.png" , callfunc)

end

function CUIGame_AllSummary:onEnter()
    self.isSummary = true
end

function CUIGame_AllSummary:onExit()
    self.isSummary = false
end

function CUIGame_AllSummary:onShare()
    cclog("on Share")
    --GlobalFun:ShareWeCharScreenShot()
    self.root:addChild(ex_fileMgr:loadLua("app/Common/CUIShareType").new(1))
end

function CUIGame_AllSummary:onBackHall()
    -- CCXNotifyCenter:notify("closeServerRoom",nil)


    if not self.backHall_lock then
        self.backHall_lock = true
        local schedulerID = false
        local scheduler = cc.Director:getInstance():getScheduler()
        local function cb(dt)
            cclog("self.backHall_lock  false")
            scheduler:unscheduleScriptEntry(schedulerID)
            self.backHall_lock = false
        end
        schedulerID = scheduler:scheduleScriptFunc(cb, 3,false) 
        -- CCXNotifyCenter:notify("closeServerRoom",nil)

        cclog("CUIGame_AllSummary:onBackHall >>>", self.scene.backType)
        local can_open = false
        if self.scene.backType == 0 then
            -- can_open = HallClient:open(GlobalData.HallIP,GlobalData.HallPort)
            -- ex_hallHandler:connectCheck()
            platformExportMgr:returnAppPlatform()
        elseif self.scene.backType == 1 then
            -- can_open = ClubClient:open(ClubClient.ClubIP,ClubClient.ClubPort)
            ex_clubHandler:connectCheck()
        else
             -- CCXNotifyCenter:notify("closeServerRoom",nil)
        end

        -- if not can_open then return end
        -- CCXNotifyCenter:notify("closeServerRoom","isCuiGameAllSummaryBackBtn")
    else
        -- GlobalFun:showToast("刷新过于频繁，请稍后再刷新" , 3)
    end



    --GameClient:close()
    --GlobalFun:showNetWorkConnect("返回大厅...")
    --HallClient:open(GlobalData.HallIP,GlobalData.HallPort)
    --cclog("on BackHall")
end

function CUIGame_AllSummary:setMyInfo()
    -- body
    local txt_hu = self.root:getChildByName("txt_hu")
    local txt_gonggang = self.root:getChildByName("txt_gonggang")
    local txt_angang = self.root:getChildByName("txt_angang")
    local txt_zhongma = self.root:getChildByName("txt_zhongma")
    local txt_myWinScore = self.root:getChildByName("nodeRoom"):getChildByName("txt_myWinScore")
    local txt_myLoseScore = self.root:getChildByName("nodeRoom"):getChildByName("txt_myLoseScore")
    local winFlag = self.root:getChildByName("nodeRoom"):getChildByName("winFlag")


    if self.myData ~= nil then
        txt_hu:setString(self.myData.hpcnt)
        txt_gonggang:setString(self.myData.mgcnt)
        txt_angang:setString(self.myData.agcnt)
        txt_zhongma:setString(self.myData.zmcnt)
        winFlag:setVisible(self.myData.bigwin)
        cclog("fuckfuckfuck winflag:"..tostring(self.myData.bigwin))
    else
        txt_hu:setString("")
        txt_gonggang:setString("")
        txt_angang:setString("")
        txt_zhongma:setString("")
        winFlag:setVisible(false)
    end

    if self.myData ~= nil then
        if self.myData.score > 0 then
            txt_myWinScore:setString(string.format("+%d",self.myData.score))
            txt_myLoseScore:setVisible(false)
        else
            txt_myLoseScore:setString(string.format("%d",self.myData.score))
            txt_myWinScore:setVisible(false)
        end
    else
        txt_myLoseScore:setVisible(false)
        txt_myWinScore:setVisible(false)
    end

end

function CUIGame_AllSummary:onBack()
    self:removeFromParent()
end

return CUIGame_AllSummary
