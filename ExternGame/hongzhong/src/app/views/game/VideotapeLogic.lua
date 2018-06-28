VideotapeLogic = {}
VideotapeLogic.__index = VideotapeLogic

function VideotapeLogic:create(scene)
    local a = {}
    setmetatable(a,VideotapeLogic)
    a:init(scene)
    return a
end

function VideotapeLogic:init(scene)
    self.scene = scene
    self.interval = 0
    self.step = 1
    self.vd = scene.videoData
    math.randomseed(os.time())
    self.videoData = {}
    self.surplusNum = GlobalFun:getCardSum() - 4*13-1
    
    local v1 = self.vd[1]
    self.roomID = v1.roomid
    self.gamecnt = v1.cnt
    self.currPass = v1.curr
    self.zhama = v1.zhama or 2
    self.isQiXiaoDui = v1.isQiXiaoDui
    self.isMiLuoHongZhong = v1.isMiLuoHongZhong
    --self.playerNum = v1.playerNum or 4
    if v1.state ~= 0 then
        --视频解析出错
        local function back()
            CCXNotifyCenter:notify("VideoNotify",5)
        end
        GlobalFun:showError("录像解析出错",back,nil,1)
        return
    end
    self.player = {}
    
    
    for i=1,#v1.player do
        self.player[i] = {}
        self.player[i].discards = {}
        self.player[i].handcard = {}
        for j=1,#v1.player[i].handcard do
            self.player[i].handcard[j] = {}
            self.player[i].handcard[j].value = GlobalFun:ServerCardToLocalCard(v1.player[i].handcard[j])--self.cards[self.card_index]
            self.player[i].handcard[j].flag = 0
            --self.card_index = self.card_index + 1
        end

        self.player[i].iconURL = v1.player[i].imgurl
        self.player[i].id = v1.player[i].playerId 
        self.player[i].ipAddr = "0.0.0.0"
        self.player[i].isBanker = v1.player[i].playerId == v1.banker
        self.player[i].isLine = true
        self.player[i].isReady = true
        self.player[i].listencard = {}
        self.player[i].mingpai = {}
        self.player[i].name = v1.player[i].nickname
        self.player[i].pos = v1.player[i].pos or i
        self.player[i].score = v1.player[i].score or 0
        self.player[i].sex = 0
    end
    self.videoData[1] = {}
    self.videoData[1].id = 1
    self.videoData[1].time = 1
    
    local t = 5
    
    for i=2,#self.vd do
        local v = self.vd[i]
        self.videoData[#self.videoData+1] = {uid = v.userid, vst = v.state}



        if v.state == 0 then
            local function back()
                CCXNotifyCenter:notify("VideoNotify",5)
            end
            GlobalFun:showError("录像解析出错",back,nil,1)
            break
        elseif v.state == 1 then--chu
            t = t + 1
            self.videoData[#self.videoData].id = 2
            self.videoData[#self.videoData].player = {}
            self.videoData[#self.videoData].player.userid = v.userid
            self.videoData[#self.videoData].player.index = 1
            self.videoData[#self.videoData].player.value = v.value
            self.videoData[#self.videoData].time = t      
            if v.userid == PlayerInfo.playerUserID then
                self.videoData[#self.videoData+1] = {}
                self.videoData[#self.videoData].id = 8
                self.videoData[#self.videoData].player = {}
                self.videoData[#self.videoData].player.cards = v.listen or {}
                self.videoData[#self.videoData].time = t
            end
            
        elseif v.state == 2 then--mo
            t = t+0.5
            if v.userid == PlayerInfo.playerUserID then
                self.videoData[#self.videoData].id = 3
            else
                self.videoData[#self.videoData].id = 4
            end
            self.videoData[#self.videoData].player = {}
            self.videoData[#self.videoData].player.userid = v.userid
            self.videoData[#self.videoData].player.value = GlobalFun:ServerCardToLocalCard(v.value)
            self.videoData[#self.videoData].time = t
        elseif v.state == 3 then--peng
            t = t + 1
            if v.userid == PlayerInfo.playerUserID then
                self.videoData[#self.videoData].id = 9
                self.videoData[#self.videoData].player = {}
                self.videoData[#self.videoData].player.outid = v.outid
                self.videoData[#self.videoData].player.value = v.value
                self.videoData[#self.videoData].player.isHiglight = true
                self.videoData[#self.videoData].time = t
                self.videoData[#self.videoData+1] = {}
                t = t + 1
            end
            self.videoData[#self.videoData].id = 5
            self.videoData[#self.videoData].player = {}
            self.videoData[#self.videoData].player.pengid = v.userid
            self.videoData[#self.videoData].player.outid = v.outid
            self.videoData[#self.videoData].player.value = v.value--GlobalFun:localCardToServerCard(21)--201
            self.videoData[#self.videoData].time = t
        elseif v.state == 4 or v.state == 5 then--gang--minggang
            t = t + 1
            if v.userid == PlayerInfo.playerUserID then
                self.videoData[#self.videoData].id = 10
                self.videoData[#self.videoData].player = {}
                self.videoData[#self.videoData].player.outid = v.outid
                self.videoData[#self.videoData].player.value = v.value
                self.videoData[#self.videoData].player.isHiglight = true
                self.videoData[#self.videoData].time = t
                self.videoData[#self.videoData+1] = {}
                t = t + 1
            end
            self.videoData[#self.videoData].id = 6
            self.videoData[#self.videoData].player = {}
            self.videoData[#self.videoData].player.gangid = v.userid
            self.videoData[#self.videoData].player.outid = v.outid
            self.videoData[#self.videoData].player.value = v.value
            self.videoData[#self.videoData].time = t
        elseif v.state == 6 then--angang
            t = t + 1
            if v.userid == PlayerInfo.playerUserID then
                self.videoData[#self.videoData].id = 10
                self.videoData[#self.videoData].player = {}
                self.videoData[#self.videoData].player.outid = v.userid
                self.videoData[#self.videoData].player.value = v.value
                self.videoData[#self.videoData].player.isHiglight = true
                self.videoData[#self.videoData].time = t
                self.videoData[#self.videoData+1] = {}
                t = t + 1
            end
            self.videoData[#self.videoData].id = 6
            self.videoData[#self.videoData].player = {}
            self.videoData[#self.videoData].player.gangid = v.userid
            self.videoData[#self.videoData].player.outid = v.userid
            self.videoData[#self.videoData].player.value = v.value
            self.videoData[#self.videoData].time = t

        elseif v.state == 7 then--dian guo

            -- local hav = false
            -- if v.userid == PlayerInfo.playerUserID then
            --     local info = self.videoData[#self.videoData -1]
            --     if info and self:isNotifyBtn(info.id) then  --上一次是出现了 碰杠胡等按钮才能搞这个点过
            --         t = t+1
            --         local tmp = clone(info)

            --         self.videoData[#self.videoData] = tmp
            --         self.videoData[#self.videoData].id = 12
            --         self.videoData[#self.videoData].last_id = info.id
            --         if self.videoData[#self.videoData].player then
            --             self.videoData[#self.videoData].player.isPassHiglight = true
            --         end
            --         self.videoData[#self.videoData].isPassHiglight = true
            --         self.videoData[#self.videoData].time = t

            --         hav = true
            --     end
            -- end

            -- if not hav then
            --     table.remove(self.videoData, #self.videoData)
            -- end

            local hav = false
            if v.userid == PlayerInfo.playerUserID then
                hav = true
                t = t+1
                self.videoData[#self.videoData].id = 12
                self.videoData[#self.videoData].isHiglight = true
                self.videoData[#self.videoData].time = t

                t = t+1
                self.videoData[#self.videoData+1] = {}
                self.videoData[#self.videoData].id = 12
                self.videoData[#self.videoData].isClean = true
                self.videoData[#self.videoData].time = t
                t = t+1
            end

            if not hav then
                table.remove(self.videoData, #self.videoData)
            end

        elseif v.state == 8 then--jiesan
            self.videoData[#self.videoData] = nil
        elseif v.state == 9 then--liuju
            self.videoData[#self.videoData] = nil
        elseif v.state == 10 then--hu
            t = t + 1
            local tab = {}
            if type(v.userid) == "table" then
                tab = v.userid
            else
                tab[1] = v.userid
            end
            
            for aaa,bbb in pairs(tab) do
                if bbb == PlayerInfo.playerUserID then
                    self.videoData[#self.videoData].id = 11
                    self.videoData[#self.videoData].isHiglight = true
                    self.videoData[#self.videoData].time = t
                    self.videoData[#self.videoData+1] = {}
                    t = t + 1
                end
            end
            self.videoData[#self.videoData].id = 7
            self.videoData[#self.videoData].winid = tab
            self.videoData[#self.videoData].hu_types = v.hu_types
            self.videoData[#self.videoData].huPaiType = v.huPaiType
            self.videoData[#self.videoData].fangpao_player = v.fangpao_player
            self.videoData[#self.videoData].time = t
            
        elseif v.state == 11 then--qiangganghu

            t = t + 1

            local isme = false
            for k,v in pairs(v.winid) do
                if v == PlayerInfo.playerUserID then
                    isme = true
                    break
                end
            end

            if isme then
                self.videoData[#self.videoData].id = 11
                self.videoData[#self.videoData].isHiglight = true
                self.videoData[#self.videoData].time = t
                self.videoData[#self.videoData+1] = {}
                t = t + 1
            end
            self.videoData[#self.videoData].id = 7
            self.videoData[#self.videoData].winids = v.winid
            self.videoData[#self.videoData].time = t

        elseif v.state == 12 then -- can chi
            -- self.videoData[#self.videoData].id = 7
            -- self.videoData[#self.videoData].winids = v.winid
            -- self.videoData[#self.videoData].time = t


        elseif v.state == 13 then -- can peng

            if v.userid == PlayerInfo.playerUserID then
                self.videoData[#self.videoData].id = 9
                self.videoData[#self.videoData].player = {}
                self.videoData[#self.videoData].player.outid = v.outid
                self.videoData[#self.videoData].player.value = v.value
                self.videoData[#self.videoData].time = t
            else
                table.remove(self.videoData, #self.videoData)
            end

        elseif v.state == 14 then -- can gang

            if v.userid == PlayerInfo.playerUserID then
                self.videoData[#self.videoData].id = 10
                self.videoData[#self.videoData].player = {}
                self.videoData[#self.videoData].player.outid = v.outid
                self.videoData[#self.videoData].player.value = v.value
                self.videoData[#self.videoData].time = t
            else
                table.remove(self.videoData, #self.videoData)
            end

        elseif v.state == 15 then -- can hu

            if v.userid == PlayerInfo.playerUserID then
                self.videoData[#self.videoData].id = 11
                -- self.videoData[#self.videoData].winids = v.winid
                self.videoData[#self.videoData].time = t
            else
                table.remove(self.videoData, #self.videoData)
            end

        elseif v.state == 16 then -- feng hu

            if v.userid == PlayerInfo.playerUserID then
                self.videoData[#self.videoData].id = 13
                self.videoData[#self.videoData].feng_cards = v.feng_cards
                self.videoData[#self.videoData].time = t
            else
                table.remove(self.videoData, #self.videoData)
            end

        else
            table.remove(self.videoData, #self.videoData)
            break
        end
    end
end

function VideotapeLogic:update(t)
    if self.step <= #self.videoData then
        self.interval = self.interval + t
        if self.step <= 1 then
            self.interval = 0
            self.step = 1
            --播放数据
            self:splitData(self.videoData[self.step])

            self.step = self.step + 1
            
        else
            
            if self.videoData[self.step].time - self.videoData[self.step-1].time < self.interval then
                self.interval = 0
                --播放数据
                cclog("self.videoData[self.step].id  >>>>>>>>>>>>>>", self.videoData[self.step].vst, self.videoData[self.step].id, self.videoData[self.step].time, self.videoData[self.step].uid, PlayerInfo.playerUserID)
                self:splitData(self.videoData[self.step])

                self.step = self.step + 1
            end
        end
    end
end

function VideotapeLogic:MJInit(data)
    
    local res = {}
    res.roomID = self.roomID
    res.gamecnt = self.gamecnt
    res.currPass = self.currPass
    res.zhama = self.zhama
    res.surplusNum = self.surplusNum
    res.isQiXiaoDui = self.isQiXiaoDui
    res.isMiLuoHongZhong = self.isMiLuoHongZhong    
    res.disTime = 1000
    res.player = {}
    for i=1,#self.player do
        res.player[i] = clone(self.player[i])
        if res.player[i].isBanker then
            res.outCardID =  res.player[i].id
        end
    end
    
    self.scene:onUserEnterRoom(res)
    --res.outCardID = res.player[3].id
    
end

function VideotapeLogic:outCard(data,source)
    --local a = 10
    local res = {}
    res.userID = data.userid
    res.value = data.value
    res.index = data.index
    
    if source then
        for i=1,4 do
            if source.player[i] and source.player[i].id == data.userid then
                for k = 1 , #source.player[i].handcard do
                    if source.player[i].handcard[k].value == GlobalFun:ServerCardToLocalCard(data.value) then
                        table.remove(source.player[i].handcard,k)
                        source.player[i].discards[#source.player[i].discards + 1] = {}
                        source.player[i].discards[#source.player[i].discards].value = GlobalFun:ServerCardToLocalCard(data.value)
                        source.player[i].discards[#source.player[i].discards].flag = 0
                        break
                    end
                end
                break
            end
        end
        return
    end
    self.scene:onUserOutCard(res)
end

function VideotapeLogic:pickCardToOther(data,source)
    local res = {}
    res.userid = data.userid
    --cclog("pick  " .. data.value)
    if source then
        for i=1,4 do
            if source.player[i] and source.player[i].id == data.userid then
                source.outCardID = data.userid
                source.player[i].handcard[#source.player[i].handcard+1] = {}
                source.player[i].handcard[#source.player[i].handcard].flag = 0
                source.player[i].handcard[#source.player[i].handcard].value = data.value--GlobalFun:ServerCardToLocalCard(data.value)
                break
            end
        end
        return
    end
    self.scene:onServerNotifyUserPick(res,data.value)
end

function VideotapeLogic:pickCardToMe(data,source)
    local res = {}
    res.cardnum = GlobalFun:localCardToServerCard(data.value)
    if source then
        for i=1,4 do
            if source.player[i] and source.player[i].id == data.userid then
                source.outCardID = data.userid
                source.player[i].handcard[#source.player[i].handcard+1] = {}
                source.player[i].handcard[#source.player[i].handcard].flag = 0
                source.player[i].handcard[#source.player[i].handcard].value = data.value--GlobalFun:ServerCardToLocalCard(data.value)
                break
            end
        end
        return
    end
    self.scene:onServerPickCard(res)
end

function VideotapeLogic:userPeng(data,source)
    local res = {}
    res.value = data.value
    res.pengID = data.pengid
    res.outID = data.outid
    if source then
        source.outCardID = data.pengid
        for i=1,4 do
            if source.player[i] and source.player[i].id == data.pengid then
                local tb = {}
                for j=1,#source.player[i].handcard do--从手牌移除
                    if source.player[i].handcard[j].value ~= GlobalFun:ServerCardToLocalCard(data.value) then
                        tb[#tb + 1] = source.player[i].handcard[j]
                    end
                end
                source.player[i].handcard = tb
                
                source.player[i].mingpai[#source.player[i].mingpai+1] = {}
                for j=1,3 do
                    source.player[i].mingpai[#source.player[i].mingpai][j] = {}
                    source.player[i].mingpai[#source.player[i].mingpai][j].value = GlobalFun:ServerCardToLocalCard(data.value)
                    source.player[i].mingpai[#source.player[i].mingpai][j].flag = 0
                end
            end
            
            if source.player[i] and source.player[i].id == data.outid then
                for j=1,#source.player[i].discards do
                    if source.player[i].discards[j].value == GlobalFun:ServerCardToLocalCard(data.value) then
                        table.remove(source.player[i].discards,j)
                        break
                    end
                end
            end
        end
        return
    end
    cclog("VideotapeLogic:userPeng  >>>>>")
    print_r(res)
    self.scene:onUserPeng(res)
end

function VideotapeLogic:userGang(data,source)
    local res = {}
    res.cardnum = data.value
    res.gangID = data.gangid
    res.outID = data.outid
    if source then
        for i=1,4 do
            if source.player[i] and source.player[i].id == data.outid then
                local tb = {}
                for j=1,#source.player[i].discards do
                    if source.player[i].discards[j].value ~= GlobalFun:ServerCardToLocalCard(data.value) then
                        tb[#tb+1] = source.player[i].discards[j]
                    end
                end
                source.player[i].discards = tb
            end
            
            if source.player[i] and source.player[i].id == data.gangid then
                local tb = {}
                local cnt = 0
                for j=1,#source.player[i].handcard do
                    if source.player[i].handcard[j].value ~= GlobalFun:ServerCardToLocalCard(data.value) then
                        tb[#tb + 1] =  source.player[i].handcard[j]
                    else
                        cnt = cnt + 1
                    end
                end
                source.player[i].handcard = tb
                
                if cnt > 2 and data.gangid == data.outid then--暗杠
                    source.player[i].mingpai[#source.player[i].mingpai+1] = {}
                    for j=1,4 do
                        source.player[i].mingpai[#source.player[i].mingpai][j] = {}
                        source.player[i].mingpai[#source.player[i].mingpai][j].value = GlobalFun:ServerCardToLocalCard(data.value)
                        source.player[i].mingpai[#source.player[i].mingpai][j].flag = 1
                    end
                else
                    local m_f = false
                    for j = 1,#source.player[i].mingpai do
                        if source.player[i].mingpai[j][1].value == GlobalFun:ServerCardToLocalCard(data.value) then
                            source.player[i].mingpai[j][4] = {}
                            source.player[i].mingpai[j][4].value = GlobalFun:ServerCardToLocalCard(data.value)
                            source.player[i].mingpai[j][4].flag = 0
                            m_f = true
                            break
                        end
                    end
                    
                    if m_f == false then
                        source.player[i].mingpai[#source.player[i].mingpai+1] = {}
                        for j=1,4 do
                            source.player[i].mingpai[#source.player[i].mingpai][j] = {}
                            source.player[i].mingpai[#source.player[i].mingpai][j].value = GlobalFun:ServerCardToLocalCard(data.value)
                            source.player[i].mingpai[#source.player[i].mingpai][j].flag = 1
                        end
                    end
                end
            end
        end
        return
    end
    self.scene:onServerBrocastMingGang(res)
end

function VideotapeLogic:meCanPeng(data)

    local res = {}
    res.value = data.value
    res.userID = data.outid
    res.isHiglight = data.isHiglight
    res.isPassHiglight = data.isPassHiglight

    if res.isHiglight then
        CCXNotifyCenter:notify("peng_btn_set_color", {numb = GlobalFun:ServerCardToLocalCard(data.value)})
    end

    cclog("VideotapeLogic:meCanPeng >>>>", res.isHiglight, res.isPassHiglight)
    self.scene:onServerNotifyCanPeng(res)
end

function VideotapeLogic:meCanGang(data)

    local res = {}
    res.value = data.value
    res.userID = data.outid
    res.isHiglight = data.isHiglight
    res.isPassHiglight = data.isPassHiglight

    if res.isHiglight then
        CCXNotifyCenter:notify("gang_btn_set_color", {numb = GlobalFun:ServerCardToLocalCard(data.value)})
    end
    self.scene:onServerNotifyCanGang(res)
end

function VideotapeLogic:listenCard(data)
    self.scene:onListenCard(data,false)
end

function VideotapeLogic:hu(data)
    if data.winids then
        self.scene.winBean = data.winids
        self.scene:playQiangGanghu()
    else
        -- self.scene.winBean = {data.winid}
        -- if next(data.hu_types or {}) then
        --     for k,v in ipairs(data.hu_types) do
        --         if v == 0 then
        --             self.scene:playQiXiaoDui()
        --         end
        --     end
        -- else
        --     self.scene:playHuAction(nil,false,data.winid)
        -- end

        self.scene.winBean = data.winid
        local hav_type_eff = false
        if next(data.hu_types or {}) then
            for k,v in ipairs(data.hu_types) do
                if v == 0 then
                    self.scene:playQiXiaoDui()
                    hav_type_eff = true
                    break
                end
            end
        end
            
        if data.huPaiType == 3 then

            self.scene:processPao(data.winid, data.fangpao_player, hav_type_eff)


        else

            self.scene:playHuAction(nil,false,data.winid[1])
        end

    end

end

function VideotapeLogic:meCanHu(data)


    if data.isHiglight then
        CCXNotifyCenter:notify("hu_btn_set_color", {})
    end
    self.scene:onServerNotifyCanHu(data)
end

function VideotapeLogic:clickPass(data)


    cclog("VideotapeLogic:clickPass >>>>")
    if data.isHiglight then
        CCXNotifyCenter:notify("pass_btn_set_color", {})
    end

    if data.isClean then
        CCXNotifyCenter:notify("BtnCleanAll",nil)
    end

end

function VideotapeLogic:fengHu(data)
    self.scene:onFengHuCards(data.feng_cards)
end

function VideotapeLogic:isNotifyBtn(id)
    local flag = false
    local tab = {
        [9] = true,
        [10] = true,
        [11] = true,
    }
    if tab[id] then
        flag = true
    end
    return flag 
end

function VideotapeLogic:splitData(data,source)

    if data.id == 1 then--初始化人跟牌
        self:MJInit(data)
    elseif data.id == 2 then--玩家出牌
        CCXNotifyCenter:notify("BtnCleanAll",nil)
        self:outCard(data.player,source)
    elseif data.id == 3 then --自己摸了一张牌
        CCXNotifyCenter:notify("BtnCleanAll",nil)
        self:pickCardToMe(data.player,source)
    elseif data.id == 4 then --玩家摸了一张牌
        CCXNotifyCenter:notify("BtnCleanAll",nil)
        self:pickCardToOther(data.player,source)
    elseif data.id == 5 then --玩家碰牌
        self:userPeng(data.player,source)
    elseif data.id == 6 then --玩家杠牌
        self:userGang(data.player,source)
    elseif data.id == 7 then --胡牌
        CCXNotifyCenter:notify("BtnCleanAll",nil)
        self:hu(data)
    elseif data.id == 8 then --听牌通知
        self:listenCard(data.player)
    elseif data.id == 9 then --提示自己可以碰牌
        self:meCanPeng(data.player)
    elseif data.id == 10 then --提示自己可以杠牌
        self:meCanGang(data.player)
    elseif data.id == 11 then --提示可以自己可以胡牌
        self:meCanHu(data)
    elseif data.id == 12 then --点了过牌
        self:clickPass(data)
    elseif data.id == 13 then --封胡
        self:fengHu(data)
    end
end

function VideotapeLogic:setStep(step)
    if step > 0 and self.step >= #self.videoData then

        CCXNotifyCenter:notify("VideoNotify",2)
        return
    elseif self.step == 1 and step < 0 then
        CCXNotifyCenter:notify("VideoNotify",2)
        return
    end
    self.step = self.step + step
    if self.step < 1 then
        self.step = 2
    end
    if self.step > 1 then
        local res = {}
        res.roomID = self.roomID
        res.gamecnt = self.gamecnt
        res.currPass = self.currPass
        res.zhama = self.zhama
        res.surplusNum = self.surplusNum
        res.isQiXiaoDui = self.isQiXiaoDui
        res.isMiLuoHongZhong = self.isMiLuoHongZhong   
        res.disTime = 1000
        res.player = {}
        for i=1,#self.player do
            res.player[i] = clone(self.player[i])
            if res.player[i].isBanker then
                res.outCardID =  res.player[i].id
            end
        end
        
        for i = 2 , self.step - 1 do
            if i > #self.videoData then
                self.step = #self.videoData
                break
            end
            self:splitData(self.videoData[i],res)
        end
        
        cclog("self.step >>>>>>>", self.step)
        self.scene:onUserEnterRoom(res)
        CCXNotifyCenter:notify("VideoNotify",2)
    end


end
