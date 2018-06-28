--ex_fileMgr:loadLua("app.Configure.Effect_conf")

local CUIPlayer = class("CUIPlayer",function() 
    return cc.Node:create()
end)

local BaseMahjong = ex_fileMgr:loadLua("app.views.game.CSBMahjong")
local BasePlayerInfo = ex_fileMgr:loadLua("app.views.game.CUIGame_playerinfo")
local BaseOnce = ex_fileMgr:loadLua("app.Common.CUIPlayOnce")
local BaseFlag = ex_fileMgr:loadLua("app.views.game.Player_flag")
local LouHuNode = ex_fileMgr:loadLua("app.views.game.LouHuNode")

local EXTRA_HEIGHT = 30
local PAIDUI_LAP = 25
local UP_WIDTH = 65
local LR_HEIGHT = 40
local EXTRA_P3 = 40


local HEIGHT_P3 = 30
local HEIGHT_P2 = 25
local START_P1 =45



local EFF_ZORDER = 2000

function CUIPlayer:ctor(scene)
    self.root = display.newCSNode("game/CUIPlayer.csb")
    self.root:addTo(self)
    self.bn = 0
    self.scene = scene
    self.tag = 10
    self.discard = {}--弃牌
    self.handcard = {}
    self.mingpai = {}
    self.hongzhong = 0
    self.everycardnum = {}
    self.sex = 1 --1男  2女
    
    self.outline = self.root:getChildByName("ui_outline_1")
    self.outline:setLocalZOrder(100)
    self.outline:setVisible(false)
    
    self.playerFlag = BaseFlag.new()
    self.root:addChild(self.playerFlag,1500)
    self:setPlayerFlagVisible(false)
    --self.playerFlag:setVisible(false)
    
    self.isFinishShowCard = false -- 发牌结束
    self.callBuff = {} -- 消息缓存
    self.isOpen = false
    self.infomation = nil
    --self.info_pt = {0,0}
    
    self:registerScriptHandler(function(state)
        if state == "enter" then
        --self:onEnter()
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

    
end

function CUIPlayer:setMyInfomation()
    local x,y = 0,0
    self.pinfo = BasePlayerInfo.new(self.scene, BasePlayerInfo.UTYPE_1)
    local w,h = self.pinfo:getWidthAndHeight()
    if self.pos == 1 then
        x,y = -display.width/2+w/2+20,156
    elseif self.pos == 2 then
        x,y = w +10,h-5
    elseif self.pos == 3 then
        x,y = 1*(38*0.85)*(13 - 1)/2 - EXTRA_P3 + w,80-h/2
    else
        x,y = -w-10,h-5
    end
    self.pinfo:setPosition(x,y)
    if self.pos > 1 then
        self.pinfo:setLocalZOrder(1500)
    end
    self.root:addChild(self.pinfo)
end

function CUIPlayer:setScore(num)
    self.score = self.score + num
    self.pinfo:setPlayerScore(self.score)
end

function CUIPlayer:setZhuangVisible()
    self.pinfo:setZhuangVisible(self.isBanker)
end

function CUIPlayer:setBaseData(data)
    self.pos = data.pos
    self.isPeople = true
    if data.playerinfo then
        self:setMyInfomation()
    
        self.openid = data.playerinfo.id
        self.id = self.openid
        self.isBanker = data.playerinfo.isBanker
        self.name = data.playerinfo.name
        self.sex = data.playerinfo.sex
        self.score = data.playerinfo.score
        self.imgURL = data.playerinfo.iconURL
        self.iconURL = self.imgURL
        self.ipAddr = data.playerinfo.ipAddr
        self.isLine = data.playerinfo.isLine
        self.isReady = data.playerinfo.isReady
        self.serverPos = data.playerinfo.pos
    end
    cclog("------- CUI PLAYER --------")
    self.pinfo:setBaseGameData(self)
    self.pinfo:setHolder(data.playerinfo.pos,self.pos,1,self.scene.isMatch , self.openid)
    self.pinfo:setPlayerName(self.name)
    self:setZhuangVisible()
    self:setHeadOnAnOff(self.isLine and 1 or 0)
    self.pinfo:setPlayerScore(self.score)
    -- self.pinfo:showIPTips(self.pinfo.player,data.pos,self.scene.isVideo)
    
    self.serverOutCartTag = nil
    self.serverOutCartValue = nil
    
    for i = 1,#data.cards do
        local state = 1
        local v = false
        if data.isStart == false then
            state = 3
            v = true
        end
        local tmp_d = {pos = data.pos-1,num = data.cards[i],state = state,player = self}
        local newCard = BaseMahjong.new(tmp_d)
        --cclog("newCard.cardnum " .. newCard.cardnum)
        newCard:setVisible(v)
        newCard:setTag(self:newTag(self.handcard))
        self.root:addChild(newCard)

        -- if i == #data.cards then
        --     self:clientBtnCheck({num = data.cards[i]})
        -- end
    end
    
    if data.discards then
        for i=1,#data.discards do
            local tmp_d = {pos = data.pos-1,num = data.discards[i],state = 5,player = self}
            local newCard = BaseMahjong.new(tmp_d)
            newCard:setTag(self:newTag(self.discard))
            self.root:addChild(newCard)
        end
    end
    
    if data.mingpai then
        for i = 1,#data.mingpai do
            self.mingpai[#self.mingpai +1] = {}
            for j = 1,#data.mingpai[i] do
                local tmp_d = {pos = data.pos-1,num = data.mingpai[i][j].value,state = 5,player = self}
                local newCard = BaseMahjong.new(tmp_d)
                if data.mingpai[i][j].flag == 1 then
                    newCard.eatType = 1
                end
                newCard:setTag(self:newTag(self.mingpai[#self.mingpai]))
                self.root:addChild(newCard)
            end
        end
    end
    self.mSendCardT = 0
    self:sortCard()
    if data.isStart == false then
        self.isOpen = true
        self.bn = 0
        self:reSetCardP()
    end
    --self:reSetCardP()

    -- if isReconnect then 
    --     self.isFinishShowCard = true
    --     --显示ganxxx
    --     if self.callBuff ~= nil and #self.callBuff > 0 then 
    --         for i=1,#self.callBuff do
    --             local callfunc = self.callBuff[i]
    --             callfunc() -- 调用
    --         end
    --     end   
    -- end    

end

function CUIPlayer:setOpen()
    self.isOpen = true
    self.bn = 1
    self:reSetCardP()
end

function CUIPlayer:newTag(tb)
    self.tag = self.tag + 1
    tb[#tb +1] = self.tag
    --self.handcard[#self.handcard + 1] = self.tag
    return self.tag
end

function CUIPlayer:update(t)
    if self.isOpen == false then
        return
    end
    if self.bn >= 1 and self.bn < 13 then
        self.mSendCardT = self.mSendCardT + t
        if self.mSendCardT > 0.1 then
            self.bn = self.bn + 1
            self.mSendCardT = 0
            self:reSetCardP()
        end
    elseif self.bn == 13 then
        self.bn = 0
        if #self.handcard > 13 then
            for k = 14,#self.handcard do
                self.root:getChildByTag(self.handcard[k]):setVisible(true)
            end
        end
        for i = 1,#self.handcard do
            self.root:getChildByTag(self.handcard[i]):setState(2)
        end
        --self:reSetCardP()
        if #self.handcard > 13 then
            self:reSetCardP()
        end

        --发牌结束
        self.isFinishShowCard = true
        --显示ganxxx
        if self.callBuff ~= nil and #self.callBuff > 0 then 
            for i=1,#self.callBuff do
                local callfunc = self.callBuff[i]
                callfunc() -- 调用
            end
        end    
    end
    
    self.outline:setVisible(self.pos == 1 and self.scene.flag == 1 and self.scene.isWatch == false)
    
    if self.bn == 0 then
        --local cnt = self.root:getChildrenCount()
        for key, var in pairs(self.root:getChildren()) do
            var:update(t)
            --[[if self.bn == 0 and var:isVisible() == false and var:getTag() >= 10 then--如果牌有没显示出来的帮助其显示
                var:setVisible(true)
            end]]
        end
    end
end

function CUIPlayer:reSetCardP()
    if self.bn ~= 0 then
        cclog("pos = "  .. self.pos .. "     bn = " .. self.bn)
        self.root:getChildByTag(self.handcard[self.bn]):setVisible(true)
        local for_start = 1
        local for_end = self.bn
        local for_step = 1
        local c_zorder = 0
        if self.pos == 4 then
            for_start = self.bn
            for_end = 1
            for_step = -1
        end
        for i=for_start,for_end,for_step do
            c_zorder = c_zorder + 1
            local myCard = self.root:getChildByTag(self.handcard[i])
            myCard:setLocalZOrder(c_zorder)
            local w,h = myCard:getWidthAndHeight()
            h = 22
            local lap_p = 0
            if self.pos == 1 or self.pos == 3 then
                local e_x = 0
                if self.pos == 3 then
                    e_x = - EXTRA_P3
                    myCard:setPositionY(HEIGHT_P3)
                else
                    w = w*1.07
                    myCard:setScale(0.96)
                    lap_p = START_P1
                end
                myCard:setPositionX(-1*(self.bn-1)*w/2 + w*(i-1) + e_x - lap_p)
            elseif self.pos == 2 then
                myCard:setPositionY(1*(self.bn-1)*h/2 - h*(i-1) + HEIGHT_P2)
            else
                myCard:setPositionY(-1*(self.bn-1)*h/2 + h*(i-1) + EXTRA_HEIGHT + 20+HEIGHT_P2)
            end
        end
    else
        local for_start = 1
        local for_end = #self.handcard
        local for_step = 1
        local c_zorder = 0

        if self.pos == 2 then
            for_start = #self.handcard
            for_end = 1
            for_step = -1
        end
        for i=for_start,for_end,for_step do
            c_zorder = c_zorder + 1
            local myCard = self.root:getChildByTag(self.handcard[i])
            --myCard:stopAllActions()
            myCard:setLightVisible(false)
            myCard:setLocalZOrder(c_zorder)
            local w,h = myCard:getWidthAndHeight()
            h = 22
            --判断牌是不是多于13张
            local cardnum = #self.mingpai*3 + #self.handcard
            if self.pos == 1 then
                w = w*1.07
                myCard:setScale(0.96)
                local start_x = -1*(13 - 1)*w/2  + #self.mingpai*3*(w*1.2)/2 + #self.mingpai*PAIDUI_LAP - START_P1
                if cardnum > 13 and i == #self.handcard then
                    myCard:setLightVisible(true)
                    myCard:setPosition(start_x + w*(i-1) + 17,0)
                else
                    myCard:setPosition(start_x + w*(i-1),0)
                end
            elseif self.pos == 2 then
                local start_y = -1*(13-1)*h/2 + #self.mingpai*3*LR_HEIGHT/2 + #self.mingpai*(PAIDUI_LAP - 9)
                if cardnum > 13 and i == #self.handcard then
                    myCard:setPositionY(start_y + h*(i-1) + 17+HEIGHT_P2)
                else
                    myCard:setPositionY(start_y + h*(i-1)+HEIGHT_P2)
                end
            elseif self.pos == 3 then
                local start_x = 1*(13 - 1)*w/2  - #self.mingpai*3*UP_WIDTH/2 - #self.mingpai*(PAIDUI_LAP-4)+13 - EXTRA_P3
                if cardnum > 13 and i == #self.handcard then
                    myCard:setPositionX(start_x - w*(i-1) - 17)
                else
                    myCard:setPositionX(start_x - w*(i-1))
                end
                myCard:setPositionY(HEIGHT_P3)
            else
                local start_y = 1*(13 - 1)*h/2  - #self.mingpai*3*LR_HEIGHT/2 - #self.mingpai*(PAIDUI_LAP - 9) + EXTRA_HEIGHT + 20+HEIGHT_P2
                if cardnum > 13 and i == #self.handcard then
                    myCard:setPositionY(start_y - h*(i-1) - 17)
                else
                    myCard:setPositionY(start_y - h*(i-1))
                end
            end
        end
        
        if self.pos == 2 then
            for_start = #self.handcard
            for_end = 1
            for_step = -1
        end
        c_zorder = 0
        for i=1,#self.mingpai do
            for j =1,#self.mingpai[i] do
                if self.pos == 2 then
                    if j == 1 then
                        c_zorder = c_zorder + 3
                    elseif j == 4 then
                        c_zorder = c_zorder + 2
                    else
                        c_zorder = c_zorder - 1
                    end
                else
                    c_zorder = c_zorder + 1
                end
                local myCard = self.root:getChildByTag(self.mingpai[i][j])
                --myCard:stopAllActions()
                myCard:setLightVisible(false)
                myCard:setLocalZOrder(c_zorder)
                local w,h = myCard:getWidthAndHeight()
                h = 22
                if self.pos == 1 then
                    myCard:setScale(1.1)
                    local w1 = w/0.9
                    local cx = -1*(13 - 1)*w1/2 + (i-1)*3*(w*1.2)/2 -w*1.2*0.25 + (w*1.2)*0.5*(j-1) + (i-1)*PAIDUI_LAP - START_P1-15
                    local cy = 0
                    if j == 1 or j == 2 or j == 3 then
                        if myCard.eatType == 1 then
                            myCard:setState(6)
                        end
                    elseif j == 4 then
                        cx = -1*(13 - 1)*w1/2 + (i-1)*3*(w*1.2)/2 -w*1.2*0.25 + (w*1.2)*0.5*(2-1) + (i-1)*PAIDUI_LAP - START_P1-15
                        cy = 14
                    end
                    myCard:setPosition(cx,cy)
                elseif self.pos == 2 then
                    --1*(13-1)*h/2 + #self.mingpai*3*h/2 + #self.mingpai*15 + EXTRA_HEIGHT
                    local cy = -1*(13 - 1)*h/2 + (i-1)*3*LR_HEIGHT/2 -LR_HEIGHT*0.25 + LR_HEIGHT*0.5*(j-1) + (i-1)*(PAIDUI_LAP - 9) + HEIGHT_P2
                    local cx = 0
                    if j == 1 or j == 2 or j == 3 then
                        if myCard.eatType == 1 then
                            myCard:setState(6)
                        end
                    elseif j== 4 then
                        cy = -1*(13 - 1)*h/2 + (i-1)*3*LR_HEIGHT/2 -LR_HEIGHT*0.25 + LR_HEIGHT*0.5*(2-1) + (i-1)*(PAIDUI_LAP - 9)+9+ HEIGHT_P2
                        cx = 0
                    end
                    myCard:setPosition(cx,cy)
                elseif self.pos == 3 then
                    local cx = 1*(13 - 1)*w/2 - (i-1)*3*UP_WIDTH/2 +UP_WIDTH*0.25 - UP_WIDTH*0.5*(j-1) - (i-1)*(PAIDUI_LAP-4) - EXTRA_P3
                    local cy = 0
                    if j == 1 or j == 2 or j == 3 then
                        if myCard.eatType == 1 then
                            myCard:setState(6)
                        end
                    elseif j == 4 then
                        cx = 1*(13 - 1)*w/2 - (i-1)*3*UP_WIDTH/2 +UP_WIDTH*0.25 - UP_WIDTH*0.5*(2-1) - (i-1)*PAIDUI_LAP - EXTRA_P3
                        cy = 12
                    end
                    myCard:setPosition(cx,cy+HEIGHT_P3)
                else
                    local cy = 1*(13 - 1)*h/2 - (i-1)*3*LR_HEIGHT/2 +LR_HEIGHT*0.25 - LR_HEIGHT*0.5*(j-1) - (i-1)*(PAIDUI_LAP - 9)+HEIGHT_P2
                    local cx = 0
                    if j == 1 or j == 2 or j == 3 then
                        if myCard.eatType == 1 then
                            myCard:setState(6)
                        end
                    elseif j == 4 then
                        cy = 1*(13 - 1)*h/2 - (i-1)*3*LR_HEIGHT/2 + LR_HEIGHT*0.25 - LR_HEIGHT*0.5*(2-1) - (i-1)*(PAIDUI_LAP - 9)+HEIGHT_P2
                        --cx = -12
                        cy = cy + 12
                    end
                    myCard:setPosition(cx,cy + EXTRA_HEIGHT + 20)
                end
                
            end
        end
        
        
        --丢弃的牌绘制
        if self.pos == 1 then
            local center_p = cc.p(display.width/2,display.height/2 - 75)
            local n_p = self:convertToNodeSpace(center_p)
            for i = 1,#self.discard do
                local myCard = self.root:getChildByTag(self.discard[i])
                --myCard:stopAllActions()
                myCard:setLightVisible(false)
                myCard:setScale(1.0)
                local m_w,m_h =  myCard:getWidthAndHeight()
                if myCard.state == 5 then
                    local f = math.floor(((i-1)%18)/9)
                    local cx = -150/2-m_w*0.5/2+((i-1)%9+1)*(m_w+8)*0.5 - 13
                    local cy = n_p.y - m_h*0.5*0.5 - f*(m_h-10)*0.5+12*math.floor(((i-1)/18)) -25
                    myCard:setPosition(cx,cy)
                end
            end
        elseif self.pos == 2 then
            local center_p = cc.p(display.width/2 + 75,display.height/2)
            local n_p = self:convertToNodeSpace(center_p)
            local c_zorder = 0
            local line_num = 6
            local ceng_num = line_num*2
            for i = 1,#self.discard do
                local myCard = self.root:getChildByTag(self.discard[i])
                --myCard:stopAllActions()
                c_zorder = ceng_num*math.floor((i-1)/ceng_num)+ceng_num-i
                myCard:setLocalZOrder(c_zorder)
                local m_w,m_h =  UP_WIDTH*0.8,LR_HEIGHT*0.8
                if myCard.state == 5 then
                    myCard:setScale(1.1)
                    m_w = m_w*1.1
                    m_h = m_h*1.1
                    local f = math.floor(((i-1)%ceng_num)/line_num)
                    local cy = -150/2-(m_h)*0.5/2+((i-1)%line_num+1)*(m_h-7) +11*math.floor(((i-1)/ceng_num)) -8
                    local cx = n_p.x + (m_w)*0.5*0.5 + f*(m_w+25)*0.5 + 27
                    myCard:setPosition(cx,cy)
                end
            end
        elseif self.pos == 3 then
            local center_p = cc.p(display.width/2,display.height/2 + 75)
            local n_p = self:convertToNodeSpace(center_p)
            local c_zorder = 0
            for i = 1,#self.discard do
                local myCard = self.root:getChildByTag(self.discard[i])
                --myCard:stopAllActions()
                local m_w,m_h =  76*0.85,100*0.85--myCard:getWidthAndHeight()
                c_zorder = 18*math.floor((i-1)/18)+18-i
                myCard:setLocalZOrder(c_zorder)
                if myCard.state == 5 then
                    local f = math.floor(((i-1)%18)/9)
                    local cx = 150/2+m_w*0.5/2-((i-1)%9+1)*(m_w)*0.5 + 13
                    local cy = n_p.y + m_h*0.5*0.5 + f*(m_h-10)*0.5+13*math.floor(((i-1)/18)) +23
                    myCard:setPosition(cx,cy)
                end
            end
        else
            local center_p = cc.p(display.width/2 - 75,display.height/2)
            local n_p = self:convertToNodeSpace(center_p)
            local c_zorder = 0
            local line_num = 6
            local ceng_num = line_num*2
            for i = 1,#self.discard do
                local myCard = self.root:getChildByTag(self.discard[i])
                --myCard:stopAllActions()
                c_zorder = c_zorder + 1
                myCard:setLocalZOrder(c_zorder)
                local m_w,m_h =  UP_WIDTH*0.8,LR_HEIGHT*0.8
                if myCard.state == 5 then
                    myCard:setScale(1.1)
                    m_w = m_w*1.1
                    m_h = m_h*1.1
                    local f = math.floor(((i-1)%ceng_num)/line_num)
                    local cy = 150/2+(m_h)*0.5/2-((i-1)%line_num+1)*(m_h-7) + 8+11*math.floor(((i-1)/ceng_num))
                    local cx = n_p.x - m_w*0.5*0.5 - f*(m_w+25)*0.5 - 27
                    myCard:setPosition(cx,cy)
                end
            end
        end
    end
    
end

function CUIPlayer:tableSort(tb)
    for i = 1,#tb-1 do
        for j = i+1,#tb do
            local card1 = self.root:getChildByTag(tb[i])
            local card2 = self.root:getChildByTag(tb[j])
            if card1.sortPt > card2.sortPt then
                local tmp = tb[i]
                tb[i] = tb[j]
                tb[j] = tmp
            end
        end
    end
    return tb
end

function CUIPlayer:changeCard(tb,cardnum,num,ch_num)
    local tmpcn = 0
    for j=1,#self.handcard do
        if self.handcard[j] ~= 0 then
            local card = self.root:getChildByTag(self.handcard[j])
            if card.cardnum == cardnum then
                card.sortPt = ch_num
                tb[#tb +1] = self.handcard[j]
                self.handcard[j] = 0
                if cardnum == 31 then
                    self.hongzhong = self.hongzhong - 1
                else
                    self.everycardnum[cardnum] = self.everycardnum[cardnum] - 1
                end
                tmpcn = tmpcn + 1
                if tmpcn >= num then
                    return
                end
            end
        end
    end
end

function CUIPlayer:Find34(tb)
    for i = 1,#self.everycardnum do
        if self.everycardnum[i] >= 3 then
            self:changeCard(tb,i,self.everycardnum[i],i)
        end
    end
end

function CUIPlayer:FindABC(tb)
	for i = 2, #self.everycardnum - 1 do
	   if self.everycardnum[i -1] > 0 and self.everycardnum[i] > 0 and self.everycardnum[i+1] > 0 then
	       self:changeCard(tb,i-1,1,i-1)
           self:changeCard(tb,i,1,i)
           self:changeCard(tb,i+1,1,i+1)
	   end
	end
end

function CUIPlayer:FindABA0(tb)
	for i = 2 , #self.everycardnum - 1 do
	   if self.hongzhong > 0 and self.everycardnum[i] == 0 and i ~= 10 and i~= 20 then
	       if self.everycardnum[i-1] == 1 and self.everycardnum[i+1] == 1 then
	           self:changeCard(tb,i-1,1,i-1)
	           self:changeCard(tb,31,1,i)
	           self:changeCard(tb,i+1,1,i+1)
	       end
	   end
	end
end

function CUIPlayer:FindABA(tb)
    for i = 2,#self.everycardnum - 1 do
        if self.hongzhong > 0 and self.everycardnum[i] == 0 and i~= 10 and i~= 20 then
            if self.everycardnum[i-1] > 0 and self.everycardnum[i+1] > 0 then
                self:changeCard(tb,i-1,1,i-1)
                self:changeCard(tb,31,1,i)
                self:changeCard(tb,i+1,1,i+1)
            end
        end
    end
end

function CUIPlayer:FindBAA(tb)
    for i = 2,#self.everycardnum - 1 do
        if self.hongzhong > 0 and self.everycardnum[i] > 0 and i-1 ~= 10 and i-1 ~= 20 then
            if self.everycardnum[i+1] > 0 then
                self:changeCard(tb,31,1,i-1)
                self:changeCard(tb,i,1,i)
                self:changeCard(tb,i+1,1,i+1)
            end
        end
    end
end

function CUIPlayer:FindAAB(tb)
    for i = 2,#self.everycardnum - 1 do
        if self.hongzhong > 0 and self.everycardnum[i] > 0 and i+1 ~= 10 and i+1 ~= 20 then
            if self.everycardnum[i-1] > 0 then
                self:changeCard(tb,i-1,1,i-1)
                self:changeCard(tb,i,1,i)
                self:changeCard(tb,31,1,i+1)
            end
        end
    end
end

function CUIPlayer:Find2(tb)
    for i = 1,#self.everycardnum do
        if self.hongzhong > 0 and self.everycardnum[i] == 2 then
            self:changeCard(tb,i,1,i)
            self:changeCard(tb,i,1,i)
            self:changeCard(tb,31,1,i)
        end
    end
end

function CUIPlayer:FindA(tb)
    for i = 1,#self.everycardnum do
        if self.hongzhong > 0 and self.everycardnum[i] == 1 then
            self:changeCard(tb,i,1,i)
            self:changeCard(tb,31,self.hongzhong,i)
        end
        --[[for (int i = 1; i < hongWTT.Length; i++) {
            if(hongzhong>0&&hongWTT[i]==1)
            {
                hongWTT[i]--;
                SetUnHongZhong(i);
                for (int x = 0; x < hongzhong; x++) {
                    hongzhong--;
                    SetHongZhong(i);
                }
            }
        }]]
    end
end

function CUIPlayer:sortCard()--对牌排序
    --万 1~9    筒 11~19    条 21~29  红中 31
    --单纯对卡牌排序
    self.hongzhong = 0
    for i = 0,99 do
        self.everycardnum[i] = 0
    end
    local objTag = nil
    if #self.mingpai*3+#self.handcard > 13 and self.scene.currValue then--多一张牌
        for i = 1,#self.handcard do
            local card = self.root:getChildByTag(self.handcard[i])
            if card.cardnum == self.scene.currValue then
                objTag = self.handcard[i]
                table.remove(self.handcard,i)
                break
            end
        end
    end
    --得到具体每张牌的数量
    for i=1,#self.handcard do
        local card = self.root:getChildByTag(self.handcard[i])
        local cn = card.cardnum
        card.sortPt = cn
        if cn == 31 then
            self.hongzhong = self.hongzhong + 1
        else
            --cclog("cn   " .. cn)
            self.everycardnum[cn] = self.everycardnum[cn] + 1
        end
    end
    if self.hongzhong == 0 then--单纯排序
        self.handcard = self:tableSort(self.handcard)
    else--把红中插到手牌里
        if true then
            --return
        end
        local tmphand = {}
        self:Find34(tmphand)--刻子除开
        self:FindABC(tmphand)--句子除开
        self:FindABA0(tmphand)--中间插牌
        if self.hongzhong>0 then
            self:FindABA(tmphand)--跳张（两边可以有双张）
        end
        if self.hongzhong>0 then
            self:FindBAA(tmphand)--组顺子
        end
        if self.hongzhong>0 then
            self:FindAAB(tmphand)--组顺子
        end
        if self.hongzhong>0 then
            self:Find2(tmphand)--找两张的
        end
        if self.hongzhong>0 then
            self:FindA(tmphand)--给单张补红中
        end
           
        for i =1,#self.everycardnum do
            if self.everycardnum[i] > 0 then
                self:changeCard(tmphand,i,self.everycardnum[i],i)
            end 
        end
           
        if self.hongzhong > 0 then
            self:changeCard(tmphand,31,self.hongzhong,0)
        end
           
        self.handcard = nil
        self.handcard = self:tableSort(tmphand)
    end
    
    if objTag then
        table.insert(self.handcard,#self.handcard + 1,objTag)
    end
end


function CUIPlayer:testMingPai(cardnum)
    for i = 1,#self.mingpai do
        local myCard = self.root:getChildByTag(self.mingpai[i][1])
        if myCard.cardnum == cardnum then--此为暗杠
            return true
        end
    end
    return false
end

function CUIPlayer:outCard(tag,num)--出牌
    self.discard[#self.discard + 1] = tag
    local c_p = -1
    for i=1,#self.handcard do
        if self.handcard[i] == tag then
            c_p = i
            table.remove(self.handcard,i)
            break
        end
    end
    
    if self.pos == 1 then
        local card = self.root:getChildByTag(tag)
        card:serverAcceptOutCard()
    end
    --[[
    if c_p == -1 then
        cclog("程序错误")
    else
        if self.pos == 1 then
            CCXNotifyCenter:notify("BtnCleanAll",nil)
            ex_roomHandler:userOutCard(c_p,GlobalFun:localCardToServerCard(num))
        end
    end
    ]]
    self.scene.flag = 0
    
end

function CUIPlayer:reqOutCard(tag,num)

    print("CUIPlayer reqOutCard(tag,num)",tag..","..num)
    if self.serverOutCartTag ~= nil or self.serverOutCartValue ~= nil then
        --不给再出牌
        local card = self.root:getChildByTag(tag)
        self:handSort(tag,card:getPositionX())
        return
    end

    --判断是否属于8个红中玩法(红中不让打出)
    if GameRule.PLAY_EIGHT == true then
        --不给再出牌
        local card = self.root:getChildByTag(tag)
        cclog("CardNum:"..card:getCardNum())
        if card:getCardNum() == 31 then     --等于红中的话
            self:handSort(tag,card:getPositionX())
            GlobalFun:showToast("8个红中玩法不允许打出红中牌" , 2)
            return
        end
    end

    self.scene.flag = 0
    self.scene.currValue = nil --刚摸到的牌没了
    self.serverOutCartTag = tag
    self.serverOutCartValue = num
    local c_p = -1
    for i=1,#self.handcard do
        if self.handcard[i] == tag then
            c_p = i
            break
        end
    end
    CCXNotifyCenter:notify("BtnCleanAll",nil)
    ex_roomHandler:userOutCard(c_p,GlobalFun:localCardToServerCard(num))
end

function CUIPlayer:IllegalOutCart()
    if #self.handcard % 3 == 2 then
        self.scene.flag = 1--继续是自己出牌
    end
    --local card = self.root:getChildByTag(self.serverOutCartTag)
    --self:handSort(self.serverOutCartTag,card:getPositionX())
    self.serverOutCartTag = nil
    self.serverOutCartValue = nil
    self:sortCard()
    self:reSetCardP()
end

-- function CUIPlayer:newCardEvent(num)
--     if true then
--         return
--     end
--     if self.pos == 1 then
--         --判断能不能胡
--         local hu = false
--         if hu then--通知服务器这里判断到胡了
--             return 
--         end

--         --如果不能胡才判断其他
--         if hu == false then
--             local flag = 0 
--             --1代表碰 过
--             --2杠 碰 过
--             --3代表 杠 过



--             --判断能不能杠
--             local flag1 = self:checkGang(num) and 3 or 0

--             --判断能不能碰
--             local flag2 = self:checkPeng(num) and 1 or 0
--             local flag = flag1
--             if flag2 ~= 0 then
--                 flag = flag2
--             end
--             if flag1~=0 and flag2 ~= 0 then
--                 flag = 2
--             end
            
--             if flag == 0 then--查看原来的手牌能不能杠
--                 local check,num1 = self:checkHandGang()
--                 num = num1
--                 flag = check and 3 or 0
--             end
--             self.scene.flag = 0
--             --[[
--             if flag  > 0 then
--                 CCXNotifyCenter:notify("showGameBTN",{flag = flag,num = num,pos = 1})
--             end
--             ]]
--         end
--     end
-- end

--服务器发了牌下来
function CUIPlayer:serverSendCard(cards)
    --收到新牌后的事件
    -- self:newCardEvent(cards.num)
    self:clientBtnCheck({num = cards.num})
    
    local tmp_d = {pos = self.pos-1,num = cards.num,state = 2,player = self}
    local newCard = BaseMahjong.new(tmp_d)
    
    local w,h = newCard:getWidthAndHeight()
    h = 22
    local i = #self.handcard + 1
    if self.pos == 1 then
        w = w*1.07
        newCard:setScale(0.96)
        local start_x = -1*(13 - 1)*w/2  + #self.mingpai*3*(w*1.2)/2 + #self.mingpai*PAIDUI_LAP - START_P1
        newCard:setPosition(start_x + w*(i-1) + 17,20)
    elseif self.pos == 2 then
        local start_y = -1*(13-1)*h/2 + #self.mingpai*3*LR_HEIGHT/2 + #self.mingpai*(PAIDUI_LAP - 9)
        newCard:setPositionY(start_y + h*(i-1) + 17+HEIGHT_P2)
    elseif self.pos == 3 then
        local start_x = 1*(13 - 1)*w/2  - #self.mingpai*3*UP_WIDTH/2 - #self.mingpai*(PAIDUI_LAP-4)+13 - EXTRA_P3
        newCard:setPosition(start_x - w*(i-1) - 17,HEIGHT_P3)
    else
        local start_y = 1*(13 - 1)*h/2  - #self.mingpai*3*LR_HEIGHT/2 - #self.mingpai*(PAIDUI_LAP - 9) + EXTRA_HEIGHT + 20+HEIGHT_P2
        newCard:setLocalZOrder(100)
        newCard:setPositionY(start_y - h*(i-1) -17)
    end
    newCard:setLightVisible(true)
    newCard:setTag(self:newTag(self.handcard))
    if self.pos == 1 then
        local nx = newCard:getPositionX()
        local a1 = cc.MoveTo:create(0.1,cc.p(nx,0))
        local a2 = cc.MoveTo:create(0.05,cc.p(nx,10))
        local a3 = cc.MoveTo:create(0.05,cc.p(nx,0))
        local seq = cc.Sequence:create({a1,a2,a3})
        newCard:runAction(seq)
    end
    self.root:addChild(newCard)
    
    
end

function CUIPlayer:clientBtnCheck(info)

    if self.pos == 1 then
        self:clientCheckCanHu(info.num)
    end
end

--- 客户端自己通过下发听的牌检查显示 胡牌
function CUIPlayer:clientCheckCanHu(num)

    if not self.scene.isVideo then
        cclog("CUIPlayer:clientCheckCanHu >>>>")
        -- cclog(debug.traceback())
        local listen_cards = self.scene:getListenCards()
        cclog ("CUIPlayer:clientCheckHu >>>>>>>>>", listen_cards)
        if listen_cards and next(listen_cards) then
            for k,v in pairs(listen_cards) do
                if v == num then
                    cclog ("CUIPlayer:clientCheckHu call btn hu >>>>>>>>>", num)
                    CCXNotifyCenter:notify("showGameBTN",{{type = 1},{type = 4}})
                    break
                end
            end
        end
    end
end






function CUIPlayer:getEveryCardNumTable()
    local tb = {}
    local hz = 0
    for i = 1,99 do
        tb[i] = 0
    end
    
    --得到具体每张牌的数量
    for i=1,#self.handcard do
        local card = self.root:getChildByTag(self.handcard[i])
        local cn = card.cardnum
        if cn == 31 then
            hz = hz + 1
        else
            tb[cn] = tb[cn] + 1
        end
    end
    return tb,hz
end

-- function CUIPlayer:checkHandGang()
--     local tb,hz = self:getEveryCardNumTable()
--     if hz == 4 then
--         return true,31
--     end
    
--     for i=1,#tb do
--         if tb[i] >= 4 then
--             return true,i
--         end
--     end
--     return false,0
-- end

-- function CUIPlayer:checkGang(num)
--     local tb,hz = self:getEveryCardNumTable()
--     if num == 31 then
--         if hz == 3 then
--             return true
--         end
--     else
--         if tb[num] == 3 then
--             return true
--         end
--     end
    
--     for i =1 ,#self.mingpai do--明杠
--         local card = self.root:getChildByTag(self.mingpai[i][1])
--         if num == card.cardnum then
--             return true
--         end
--     end
--     return false
-- end

-- function CUIPlayer:checkPeng(num)
--     local tb,hz = self:getEveryCardNumTable()
--     if num == 31 then
--         if hz >= 2 then
--             return true
--         end
--     else
--         if tb[num] >= 2 then
--             return true
--         end
--     end
--     return false
-- end

-- function CUIPlayer:checkHu(num)
--     local tb,hz = self:getEveryCardNumTable()
--     return false
-- end

-- function CUIPlayer:serverSendOtherOutCard(data)--服务端发送别人打出的牌
--     self:setPlayerFlagVisible(false)
--     if true then
--         return
--     end
--     if self.pos == 1 then--自己才要做判断
    
--        local cards = data.card   
--        --判断能不能杠
--        local flag1 = self:checkGang(cards.num) and 3 or 0
       
--        --判断能不能碰
--        local flag2 = self:checkPeng(cards.num) and 1 or 0
--        local flag = flag2
--        if flag1 ~= 0 then
--            flag = flag1
--        end
       
--        if flag1 ~= 0 and flag2 ~= 0 then
--            flag = 2
--        end
--        --[[
--        if flag  > 0 then
--             CCXNotifyCenter:notify("showGameBTN",{flag = flag,num = cards.num,pos = data.pos})
--        else
--            --把主动权发回给服务器
--        end
--        ]]
--     end
-- end

function CUIPlayer:moniOutCart(cards)--模拟出牌
    
    if self.handcard[cards.pos] == nil then
        cards.pos = 1
    end
    
    if self.scene.isVideo then
        local sel_card = self.root:getChildByTag(self.handcard[cards.pos])
        if sel_card.cardnum ~= cards.num then
            for i=1,#self.handcard do
                sel_card = self.root:getChildByTag(self.handcard[i])
                if sel_card.cardnum == cards.num then
                    cards.pos = i
                    break
                end
            end
        end
    end
    -- 生成一张新牌
    local tmp_d = {pos = self.pos-1,num = cards.num,state = 3,player = self}
    local myCard = BaseMahjong.new(tmp_d)
    if cards.pos > #self.handcard then
    --数据出错  重连一下
        cpp_net_close(GameClient.server.sid)
        return
    end
    myCard:setTag(self.handcard[cards.pos])
    self.root:removeChildByTag(self.handcard[cards.pos],true)
    self.root:addChild(myCard)
    self:outCard(myCard:getTag())
    myCard:setState(4)
    myCard:setLocalZOrder(100)
    local center_p = {}
    if self.pos == 1 then
        center_p.x,center_p.y = display.width/2,display.height/2-150
    elseif self.pos == 2 then
        center_p.x,center_p.y = display.width/2+150,display.height/2
    elseif self.pos == 3 then
        center_p.x,center_p.y = display.width/2,display.height/2 + 150
    elseif self.pos == 4 then
        center_p.x,center_p.y = display.width/2-150,display.height/2
    end
             
    local n_p = {}
    n_p.x,n_p.y = center_p.x-self:getParent():getPositionX(),center_p.y-self:getParent():getPositionY()--self:getParent():convertToWorldSpace(center_p)
    local ac1 = cc.MoveTo:create(0.2,n_p)
    local ac2 = cc.DelayTime:create(0.3)
    local ac3 = cc.CallFunc:create(function()
        myCard:setState(5)
        ex_audioMgr:playEffect("sound/out.mp3")
        self:sortCard()
        self:reSetCardP()
    end)
    local s = myCard:getScale()
    local ac4 = cc.ScaleTo:create(0.01,s*0.8)
    local ac5 = cc.ScaleTo:create(0.01,s)
            
    local ac6 = cc.CallFunc:create(function()
    self:reSetCardP()
    self:setPlayerFlagVisible(true)
    --self.playerFlag:setVisible(true)
    end)
    local seq = cc.Sequence:create({ac1,ac2,ac3,ac4,ac5,ac6})
    myCard:runAction(seq)

end

function CUIPlayer:removeDisCard(num)
    cclog("CUIPlayer:removeDisCard >>>>", self.discard[#self.discard], #self.discard)
    if not self.discard[#self.discard] then return end

	local card = self.root:getChildByTag(self.discard[#self.discard])
    self:setPlayerFlagVisible(false)
	if card.cardnum ~= num then
	   cclog("程序出错")
	else
        card:removeFromParent()
	   table.remove(self.discard,#self.discard)
	   self:reSetCardP()
	end
	
end

function CUIPlayer:CardEffect(file1,file2,lap_y,delay1,delay2)
    
    local x,y = 0,0
    local x1,y1 = self:getParent():getPosition()
    if self.pos == 1 then
        x,y = display.width/2 - x1,display.height/2-125-y1
    elseif self.pos == 2 then
        x,y = display.width/2 + 125 - x1,display.height/2-y1
    elseif self.pos == 3 then
        x,y = display.width/2 - x1,display.height/2+125-y1
    else
        x,y = display.width/2-125 - x1,display.height/2-y1
    end
    if file1 then
        local peng1 = BaseOnce.new(Effect_conf[file1],delay1)
        peng1:setPosition(x,y)
        self.root:addChild(peng1,EFF_ZORDER)
    end

    if file2 then
        local m_c = self.root:getChildByTag(self.mingpai[#self.mingpai][2])
        local peng = BaseOnce.new(Effect_conf[file2],delay2)
        peng:setScale(0.5)
        peng:setPosition(m_c:getPositionX(),m_c:getPositionY()+20+lap_y)
        self.root:addChild(peng,EFF_ZORDER)
    end
end

function CUIPlayer:PengCard(num,flag)
    --播放声音
    ex_audioMgr:playEffect(string.format("sound/%dpeng.mp3",self.sex==0 and 2 or 1))

    if flag == false then --碰别人的牌要先把这张牌创建出来
        local tmp_d = {pos = self.pos-1,num = num,state = 3,player = self}
        local newCard = BaseMahjong.new(tmp_d)
        newCard:setTag(self:newTag(self.handcard))
        self.root:addChild(newCard)
	end
	
	--把这牌变成明牌堆里的
	local tb = {}
	self.mingpai[#self.mingpai + 1] = {}
	for i = 1,#self.handcard do
        if (self.pos == 1 or self.scene.isVideo) and self.scene.isWatch ~= true then
    	   local card = self.root:getChildByTag(self.handcard[i])
    	   if card.cardnum == num then
    	       card:setState(5)
    	       self.mingpai[#self.mingpai][#self.mingpai[#self.mingpai]+1] = self.handcard[i]
    	       self.handcard[i]=0
    	       if #self.mingpai[#self.mingpai] == 3 then
    	           break
    	       end
    	   end
       else
           --其他玩家 头三张牌变成想要的牌
           self.root:removeChildByTag(self.handcard[i])
           local tmp_d = {pos = self.pos-1,num = num,state = 5,player = self}
           local newCard = BaseMahjong.new(tmp_d)
           newCard:setTag(self.handcard[i])
           self.root:addChild(newCard)
           self.mingpai[#self.mingpai][#self.mingpai[#self.mingpai]+1] = self.handcard[i]
           self.handcard[i]=0
           if #self.mingpai[#self.mingpai] == 3 then
               break
           end
           
	   end
	end
	for i = 1,#self.handcard do
	   if self.handcard[i] ~= 0 then
	       tb[#tb + 1] = self.handcard[i]
	   end
	end
	self.handcard = tb
	
	self:sortCard()
	self:reSetCardP()
	
	--播放动画
    self:CardEffect("eff_peng1","eff_peng",30,0,0.5)
    --[[
    if self.pos == 1 then
        local check,num = self:checkHandGang()
        
        local flag = check and 3 or 0

        if flag  > 0 then
            CCXNotifyCenter:notify("showGameBTN",{flag = flag,num = num,pos = 1})
        end
    end]]
end

function CUIPlayer:GangCard(num,flag)
    --播放声音
    ex_audioMgr:playEffect(string.format("sound/%dgang.mp3",self.sex==0 and 2 or 1))
    if flag == false or self.scene.isWatch == true then --杠别人的牌要先把这张牌创建出来
        if flag == true then--杠自己的牌  把自己手上的牌给移掉
            local card = self.root:getChildByTag(self.handcard[#self.handcard])
            card:removeFromParent()
            table.remove(self.handcard,#self.handcard)
        end
        local tmp_d = {pos = self.pos-1,num = num,state = 3,player = self}
        local newCard = BaseMahjong.new(tmp_d)
        newCard:setTag(self:newTag(self.handcard))
        self.root:addChild(newCard)
    end
    
    --确定在明牌堆里有没有这数的牌
    local mIndex = #self.mingpai + 1
    for i = 1,#self.mingpai do
        local oldCard = self.root:getChildByTag(self.mingpai[i][1])
        if oldCard.cardnum == num then
            mIndex = i
            break
        end
    end
    
    --把这牌变成明牌堆里的
    local tb = {}
    local eatType = 0
    if mIndex > #self.mingpai then
        self.mingpai[mIndex] = {}
        if flag then--自己摸的 且所有牌在手牌里为暗杠
            eatType = 1
        end
    end
    for i = 1,#self.handcard do-- 
        if (self.pos == 1 or self.scene.isVideo) and self.scene.isWatch ~= true then
            local card = self.root:getChildByTag(self.handcard[i])
            if card.cardnum == num then
                card.eatType = eatType
                card:setState(5)
                self.mingpai[mIndex][#self.mingpai[mIndex]+1] = self.handcard[i]
                self.handcard[i]=0
                if #self.mingpai[mIndex] == 4 then
                    break
                end
            end
        else
            --其他玩家
            self.root:removeChildByTag(self.handcard[i])
            local tmp_d = {pos = self.pos-1,num = num,state = 5,player = self}
            local newCard = BaseMahjong.new(tmp_d)
            newCard.eatType = eatType
            newCard:setTag(self.handcard[i])
            self.root:addChild(newCard)
            self.mingpai[mIndex][#self.mingpai[mIndex]+1] = self.handcard[i]
            self.handcard[i]=0
            if #self.mingpai[mIndex] == 4 then
                break
            end
        end
    end
    for i = 1,#self.handcard do
        if self.handcard[i] ~= 0 then
            tb[#tb + 1] = self.handcard[i]
        end
    end
    self.handcard = tb

    self:sortCard()
    self:reSetCardP()
    
    if eatType == 0 then
        self:CardEffect("eff_gonggang","eff_gang",45,0,1)
    else
        self:CardEffect("eff_angang","eff_gang",45,0,1)
    end
    
end

function CUIPlayer:setPlayerFlagVisible(b)
    self.playerFlag:setVisible(b)
    if #self.discard < 1 then
        self.playerFlag:setVisible(false)
    else
        local x,y = self.root:getChildByTag(self.discard[#self.discard]):getPosition()
        self.playerFlag:setPosition(x,y+20)
    end
    
    if self.playerFlag:isVisible() then
        for i=1,4 do
            if i ~= self.pos then
                self.scene.player[i]:setPlayerFlagVisible(false)
            end
        end
    end
end
--[[
function CUIPlayer:playHuAction()--播放胡牌动画
    ex_audioMgr:playEffect(string.format("sound/huwind.mp3"))
    
    local hu = BaseOnce.new(Effect_conf["eff_zimohu"])
    hu:setPosition(display.width/2-self:getParent():getPositionX(),display.height/2 - self:getParent():getPositionY())
    self.root:addChild(hu,EFF_ZORDER)
end
]]

function CUIPlayer:handSort(tag,p_x)
    local insert_p = #self.handcard+1--默认插最后
    local tag_index = 0
    for i=1,#self.handcard do
        if self.handcard[i] ~= tag then
            local card = self.root:getChildByTag(self.handcard[i])
            if card:getPositionX() > p_x and insert_p == #self.handcard+1 then--取代这个位置
                insert_p = i
            end
        else
            self.handcard[i] = 0
        end
    end
    table.insert(self.handcard,insert_p,tag)
    local tb = {}
    for i=1,#self.handcard do
        if self.handcard[i] ~= 0 then
            tb[#tb+1] = self.handcard[i]
        end
    end
    self.handcard = tb
    
    self:reSetCardP()
end

function CUIPlayer:MeCanPeng(num,userID)
    local data ={{type = 3,num = num,outID = userID},{type = 4}}
    CCXNotifyCenter:notify("showGameBTN",data)
end

function CUIPlayer:MeCanGang(num,userID)
    local flag = 1
    local tb,hz = self:getEveryCardNumTable()
    local gt = 0
    if num == 31 then
        if hz > 2 then--可以碰
            flag = 2
            if userID == self.openid then--暗杠
                gt = 1
                flag = 1--是暗杠不能碰
            end
        end
    else
        if tb[num] > 2 then
            flag = 2
            if userID == self.openid then--暗杠
                gt = 1
                flag = 1--是暗杠不能碰
            end
        end
    end
    cclog("player gangtype  " .. gt)
    local data = {{type = 2,gt=gt,num = num,outID = userID},{type = 4}}
    if flag == 2 then--可以碰
        data[#data+1] = {type = 3,num = num,outID=userID}--增加一个碰的按钮
    end
    --ganxxx
    -- if self.isFinishShowCard then 
    --     CCXNotifyCenter:notify("showGameBTN",data)
    -- else
    --     cclog(" ------------ buff gan ")
    --     local function callfunc()
    --         CCXNotifyCenter:notify("showGameBTN",data)
    --     end
    --     self.callBuff[#self.callBuff + 1] = callfunc
    -- end    
    CCXNotifyCenter:notify("showGameBTN",data)
end

function CUIPlayer:cleanAllData()
    self.outline:setVisible(false)
    self:setPlayerFlagVisible(false)
    self.isOpen = false
    self.isFinishShowCard = false
    self.callBuff = {}

    for i=1,#self.handcard do
        self.root:removeChildByTag(self.handcard[i],true)
    end
    self.handcard = {}
    
    for i=1,#self.discard do
        self.root:removeChildByTag(self.discard[i],true)
    end
    self.discard = {}
    
    for i=1,#self.mingpai do
        for j=1,#self.mingpai[i] do
            self.root:removeChildByTag(self.mingpai[i][j])
        end
    end
    self.mingpai = {}
    self.tag = 10
end

--语音表情
function CUIPlayer:ShowEmojiVoice(index)
    local tmp_x = 0
    if self.pos == 2 or self.pos == 3 then
        tmp_x = -155
    end
    GlobalFun:ShowSpeakString(self.pinfo , cc.p(tmp_x,0) , index)
end

--表情
function CUIPlayer:ShowEmoji(index)
    local tmp_x = 0
    if self.pos == 2 or self.pos == 3 then
        tmp_x = -155
    end
    GlobalFun:ShowSpeakEmoji(self.pinfo , cc.p(tmp_x,0) , index);
end

--语音
function CUIPlayer:ShowSpeakVoice(filename)
    cclog(" GUIPlayer ShowSpeakVoice "..filename)
    GlobalFun:PlayVoiceAndShow(self.pinfo ,cc.p(0,0) , filename)  
end

function CUIPlayer:reDrawHandCard(cards)    
    for i=1,#self.handcard do
        self.root:removeChildByTag(self.handcard[i])
    end
    self.handcard = nil
    self.handcard = {}
    for i=1,#cards do
        local tmp_d = {pos = 0,num = cards[i],state = 3,player = self}
        local newCard = BaseMahjong.new(tmp_d)
        newCard:setTag(self:newTag(self.handcard))
        self.root:addChild(newCard)
    end
    
    self:sortCard()
    self:reSetCardP()
end

function CUIPlayer:setHeadOnAnOff(flag)
    self.pinfo.txt_offline:setVisible(flag ~= 1)
    self.isLine = flag
end

function CUIPlayer:reSort(p)
    if #self.handcard > 0 then
        for i=1,#self.handcard do
            local card = self.root:getChildByTag(self.handcard[i])
            if card:checkTouchMe(p) then
                return
            end
        end
    end
    cclog("重新排序了一遍")
    self:sortCard()
    self:reSetCardP()
end

function CUIPlayer:setColorTouch(isgj)
    for i=1,#self.handcard do
        local card = self.root:getChildByTag(self.handcard[i])
        card:setColorTouch(isgj)
    end
end

function CUIPlayer:getRealPosition()
    return self.pinfo:convertToWorldSpace(cc.p(0,0))
end

function CUIPlayer:onExit()
    self:unregisterScriptHandler()--取消自身监听
end


--通知桌子类处理高亮
function CUIPlayer:notifyHighlightedCard(cardNum, flag)
    --拿到每个玩家
    self.scene:highlightedCard(cardNum, flag)
end

--高亮选中的牌
function CUIPlayer:highlightedCard(cardNum, flag, index)
    --玩家自己处理需高亮牌

    if index == 1 then
        for i = 1, #(self.handcard) do
            local myCard = self.root:getChildByTag(self.handcard[i])
            if flag == true and myCard:getCardNum() == cardNum then
                myCard:showCover()
            else
                myCard:hideCover()
            end
        end
    end

    for i = 1, #(self.mingpai) do
        for j = 1, #(self.mingpai[i]) do
            local myCard = self.root:getChildByTag(self.mingpai[i][j])
            if flag == true and myCard:getCardNum() == cardNum then
                myCard:showCover()
            else
                myCard:hideCover()
            end
        end
    end

    for i = 1, #(self.discard) do
        local myCard = self.root:getChildByTag(self.discard[i])
        if flag == true and myCard:getCardNum() == cardNum then
            myCard:showCover()
        else
            myCard:hideCover()
        end
    end
end


--小箭头标记可听牌的牌(仅限自己)
function CUIPlayer:showPointerOnCard(cardData)
    cclog("CUIPlayer:showPointerOnCard  #cardData:"..#cardData)
    --print_r(cardData)

    self:hidePointerOnCard()

    local function check(num)
        --cclog("check num:"..num)
        for i = 1, #cardData do
            if num == cardData[i].card then
                return true
            end
        end
    end

    for i = 1, #(self.handcard) do
        local myCard = self.root:getChildByTag(self.handcard[i])
        if check(myCard:getCardNum()) == true then
            myCard:showPointer()
        else
            myCard:hidePointer()
        end
    end
end
function CUIPlayer:hidePointerOnCard()
    for i = 1, #(self.handcard) do
        local myCard = self.root:getChildByTag(self.handcard[i])
        myCard:hidePointer()
    end

    for i = 1, #(self.mingpai) do
        for j = 1, #(self.mingpai[i]) do
            local myCard = self.root:getChildByTag(self.mingpai[i][j])
            myCard:hidePointer()
        end
    end
    
    for i = 1, #(self.discard) do
        local myCard = self.root:getChildByTag(self.discard[i])
        myCard:hidePointer()
    end
end

function CUIPlayer:hideFlagOnCardForGang()
    for i = 1, #(self.handcard) do
        local myCard = self.root:getChildByTag(self.handcard[i])
        myCard:hideCover()
    end

    for i = 1, #(self.mingpai) do
        for j = 1, #(self.mingpai[i]) do
            local myCard = self.root:getChildByTag(self.mingpai[i][j])
            myCard:hidePointer()
            myCard:hideCover()
        end
    end
end

function CUIPlayer:showFengHu(isVisible)
    if self.id == PlayerInfo.playerUserID then
        if not self.isFengHuCreated then
            self.isFengHuCreated = true
            
            self.fengHuNode = LouHuNode.new()
            self.fengHuNode:setPosition(90,-195)
            self.fengHuNode:setScale(2)
            self.pinfo:addChild(self.fengHuNode)
        end
        self.fengHuNode:setVisible(isVisible)
    end
end

function CUIPlayer:showFengHuCards(cards)
    if cards and next(cards) then
        self:showFengHu(true)
        if self.fengHuNode then
            self.fengHuNode:setCards({cards = cards or {}})
        end
    else
        self:showFengHu(false)
    end

    
end

return CUIPlayer
