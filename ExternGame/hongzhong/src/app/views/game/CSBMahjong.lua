local CSBMahjong = class("CSBMahjong",function() 
    return cc.Node:create()
end)

function CSBMahjong:ctor(info)
    self.root = display.newCSNode(string.format("game/card/mahjong_%d_%02d.csb",info.pos,info.num))
    cclog("CSBMahjong:ctor >>>", info.pos,info.num)
    
    self.root:addTo(self)
    --self.info = info
    self.pos = info.pos
    self.state = info.state --1发牌阶段  2刚摸到的牌  3手牌  4打出过程  5打出的牌  
    self.changeT = 0
    self.cardnum = info.num
    self.player = info.player
    self:setScale(0.9)
    self.eatType = 0--区分明杠暗杠
    self.sortPt = info.num--排序的位置
    self.isgj = false --不是挂机
    self.isVideo = false--回放模式为false
    self.isWatch = false
    self.cover = nil
    self.pointer = nil

    if self.player and self.player.pos == 1 then
        self.root:getChildByName("ctn_1"):setScale(1.1)
        self.root:getChildByName("ctn_2"):setScale(1.1)
        self.root:getChildByName("ctn_3"):setScale(1.1)
        self.isgj = info.player.scene.isgj
    end
    if self.player then
        self.isVideo = self.player.scene.isVideo
        self.isWatch = self.player.scene.isWatch
    end
    self:setColorTouch(self.isgj)
    self:setCTNVisible()
    self.touchBeganT = -1
    self.mTouchBeganT = 0
    self:listenTouch()
    if self.pos == 0 and self.root:getChildByName("tile_tileLight_1") then
        self.root:getChildByName("tile_tileLight_1"):setVisible(false)
    end
    self:registerScriptHandler(function(state)
        if state == "enter" then
            --self:onEnter()
        elseif state == "exit" then
            self:onExit()
        elseif state == "enterTransitionFinish" then
            self:onEnterTransitionFinish()
        elseif state == "exitTransitionStart" then
        --self:onExitTransitionStart_()
        elseif state == "cleanup" then
        --self:onCleanup_()
        end
    end)
    self.mTouchBeganScreenPosX = 0
    self.mTouchBeganScreenPosY = 0
end

function CSBMahjong:onEnterTransitionFinish()
    -- cclog("CSBMahjong:onEnterTransitionFinish")
    if self.pos == 0 and self.cardnum == 99 then
        if self.isVideo then return end
        if self.isWatch then return end

        if GlobalData.curScene == SceneType_Game then
            local function ok ()
                cclog("sssss>>>")
                CCXNotifyCenter:notify("closeServerRoom",nil)
            end
            GlobalFun:showError("牌数据出错，点击确定，返回登陆界面重新登陆可正常进行游戏",ok, nil,1)
        end
    end
end

function CSBMahjong:listenTouch()
    self.listener = cc.EventListenerTouchOneByOne:create()


    local function onTouchBegan(touch,event)
        return self:onTouchBegan(touch,event)
    end

    local function onTouchMoved(touch,event)
        self:onTouchMoved(touch,event)
    end

    local function onTouchEnded(touch,event)
        self:onTouchEnded(touch,event)
    end

    self.listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    self.listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    self.listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)

    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener, self)
end

function CSBMahjong:unlistenTouch()
    self:getEventDispatcher():removeEventListener(self.listener)
end

function CSBMahjong:onTouchBegan(touch, event)
    if self.player == nil or self.isVideo or self.isgj or self.isWatch then
        return false
    end
    if self.pos ~= 0 then
        return false
    end
    local pt = touch:getLocation()
    local p1 = self:convertToWorldSpace(cc.p(0,0))--self:getPosition()
    local w,h = self:getWidthAndHeight()
    local rc = cc.rect(p1.x-w/2,p1.y-h/2,w,h)
    if self.state == 3 then --手牌
        local tmp_screen_p = self:convertToWorldSpace(cc.p(0,0))
        self.mTouchBeganScreenPosX = tmp_screen_p.x
        self.mTouchBeganScreenPosY = tmp_screen_p.y

        if cc.rectContainsPoint(rc,pt) then
            if self.mTouchBeganT - self.touchBeganT > 0.4 then
                self.touchBeganT = self.mTouchBeganT
            else
                if self.player.scene.flag == 1 then
                    self.player:reqOutCard(self:getTag(),self.cardnum)
                    self:hideCover()
                    return false
                end
            end
            self.org_x ,self.org_y = self:getPosition()
            self.org_zOrder = self:getLocalZOrder()
            self:setLocalZOrder(200)
            return true
        end
    end
    return false
end

function CSBMahjong:onTouchMoved(touch, event)
    local moveData = touch:getDelta()
    local x,y = self:getPosition()
    x = x + moveData.x
    y = y + moveData.y
    self:setPosition(x,y)
    
end

function CSBMahjong:onTouchEnded(touch, event)
    local screen_p = self:convertToWorldSpace(cc.p(0,0))
    local screen_pp = self:getParent():convertToWorldSpace(cc.p(0,0))
    if screen_p.y > screen_pp.y + (73 + 55) and self.player.scene.flag == 1 then --XIONG DEBUG 
        self.player:reqOutCard(self:getTag(),self.cardnum)
        --self:hideCover()
    --增加自己出牌,点击牌效果
    elseif screen_p.y < (screen_pp.y + 5) and screen_p.y > (screen_pp.y - 5) 
        and screen_p.x < (self.mTouchBeganScreenPosX + 5) and screen_p.x > (self.mTouchBeganScreenPosX - 5)
        and self.player.scene.flag == 1 then -- ==1即是自己出牌阶段 
        cclog("模拟点击一下")
        if self.state == 3 then
            --重新放位置
            cclog("self.player:handSort  self:getTag():"..self:getTag())
            self.player:handSort(self:getTag(),self:getPositionX())

            --选中即将出的牌
            self.player:notifyHighlightedCard(self.cardnum, true)

            self:showCover()
        end
    else
        if self.state == 3 then
            --重新放位置
            cclog("self.player:handSort  self:getTag():"..self:getTag())
            self.player:handSort(self:getTag(),self:getPositionX())
        end
    end
end

function CSBMahjong:serverAcceptOutCard()
    self:setState(4)
    local center_p = cc.p(display.width/2,display.height/2 - 75)
    local n_p = self:getParent():convertToNodeSpace(center_p)
    local ac1 = cc.MoveTo:create(0.06,n_p)
    local ac2 = cc.DelayTime:create(0.1)
    local ac3 = cc.CallFunc:create(function()
        --self.player:sortCard() 
        --self.player:reSetCardP()
        self:setState(5)
        ex_audioMgr:playEffect("sound/out.mp3")
        self.player:sortCard()
        self.player:reSetCardP()
        self.player:setPlayerFlagVisible(true)
    end)
    local ac4 = cc.ScaleTo:create(0.05,0.8)
    local ac5 = cc.ScaleTo:create(0.05,1)
    local ac6 = cc.CallFunc:create(function() self.player:reSetCardP() end)

    local seq = cc.Sequence:create({ac1,ac2,ac3,ac4,ac5,ac6})
    self:runAction(seq)
    self:setLocalZOrder(99)
end

function CSBMahjong:update(t)
    self.mTouchBeganT = self.mTouchBeganT + t
    self.changeT = self.changeT + t
    if self.player and self.player.bn == 0 and self:isVisible() == false and self.state > 1 then
        self:setVisible(true)
    end
    if self.state == 2 then
        if self.changeT >0.1 then
            self.changeT = 0
            
            self:setState(3)
        end
    elseif self.state == 3 then
        --[[if self.changeT > 2 then
            self:setState(4)
        end]]
    end
end

function CSBMahjong:setState(state)
    self.state = state
    if self.state == 2 then
        self.changeT = 0
    elseif self.state == 3 then
        self.changeT = 0
    elseif self.state == 4 then
        local soundnum = self.cardnum
        if self.cardnum < 30 then
            soundnum = (math.floor(self.cardnum/10)+2)%3*10 + self.cardnum%10            
        end
        
        local soundfile = string.format("sound/card/%d%02d.mp3",self.player.sex==0 and 2 or 1,soundnum)
        ex_audioMgr:playEffect(soundfile)
    end
    self:setCTNVisible()
end

function CSBMahjong:setCTNVisible()
    for i=1,6 do
        local str = string.format("ctn_%d",i)
        --cclog("pos " .. self.pos .. "   num  " .. self.cardnum)
        self.root:getChildByName(str):setVisible(self.state == i)

        if self.pos ~= 0 and self.isVideo == true then
            if self.state == 3 then
                self.state = 5
                self.root:getChildByName("ctn_3"):setVisible(false)
                self.root:getChildByName("ctn_5"):setVisible(true)
            end
        end
        
        if self.state == 3 then
            if self.player then
                if self.root:getChildByName("ctn_3"):getChildByName("img_corver") then
                    self.root:getChildByName("ctn_3"):getChildByName("img_corver"):setVisible(self.isWatch)
                end
            end
            if self.player and self.pos == 0 and self.player.id ~= PlayerInfo.playerUserID then
                self.root:getChildByName("ctn_1"):setVisible(true)
                self.root:getChildByName("ctn_1"):setZOrder(100000)
            end
        end
    end
end

function CSBMahjong:setColorTouch(isgj)
    self.isgj = isgj
    local c = cc.c3b(255,255,255)
    if self.isgj then
        c = cc.c3b(125,125,125)
    end
    
    local  ctn = self.root:getChildByName("ctn_3")
    
    for key,var in pairs(ctn:getChildren()) do
    	var:setColor(c)
    end
    
end

function CSBMahjong:getWidthAndHeight()
    if self.pos == 0 then
        if (self.state == 1 or self.state == 2 or self.state == 3) and self.player then
            return 76*0.95,100*0.95
        else
            return 76*0.85,100*0.85
        end
    elseif self.pos == 1 then
        return 24*0.85,61*0.85
    elseif self.pos == 2 then
        return 38*0.85,59*0.85
    elseif self.pos == 3 then
        return 25*0.85,61*0.85
    end
end

function CSBMahjong:setLightVisible(b)
    if self.pos == 0 and self.root:getChildByName("tile_tileLight_1") then
        self.root:getChildByName("tile_tileLight_1"):setVisible(b)
    end
end

function CSBMahjong:checkTouchMe(p)
    local p1 = self:convertToWorldSpace(cc.p(0,0))--self:getPosition()
    local w,h = self:getWidthAndHeight()
    local rc = cc.rect(p1.x-w/2,p1.y-h/2,w,h)
    if cc.rectContainsPoint(rc,p) then
        return true
    end
    return false
end


function CSBMahjong:getCardNum()
    return self.cardnum
end

--麻将显示遮罩
function CSBMahjong:showCover()
    if self.root:getChildByName("cover") ~= nil then 
        self.root:getChildByName("cover"):removeFromParent()
        self.cover = nil
    end

    self.cover = display.newCSNode("game/mjcover.csb"):getChildByName("cover")
    self.cover:removeFromParent()
    self.root:addChild(self.cover)
    self.cover:setVisible(true)

    if self.root:getChildByName("ctn_3"):isVisible() then
        local scale = self.root:getChildByName("ctn_3"):getScale() * self.root:getChildByName("ctn_3"):getChildByName("tileBase_me_6_3"):getScale()
        self.cover:setScale(scale)
        local size = self.root:getChildByName("ctn_3"):getChildByName("tileBase_me_6_3"):getContentSize()
        self.cover:setContentSize(size.width, size.height)
    elseif self.root:getChildByName("ctn_4"):isVisible() then
        local scale = self.root:getChildByName("ctn_4"):getScale() * self.root:getChildByName("ctn_4"):getChildByName("tileBase_me_6_3"):getScale()
        self.cover:setScale(scale)
        local size = self.root:getChildByName("ctn_4"):getChildByName("tileBase_me_6_3"):getContentSize()
        self.cover:setContentSize(size.width, size.height)
    elseif self.root:getChildByName("ctn_5"):isVisible() then
        local scale = self.root:getChildByName("ctn_5"):getScale() * self.root:getChildByName("ctn_5"):getChildByName("tileBaseFinish_me_6_5"):getScale()
        self.cover:setScale(scale)
        local size = self.root:getChildByName("ctn_5"):getChildByName("tileBaseFinish_me_6_5"):getContentSize()
        self.cover:setContentSize(size.width, size.height)
    end
    

end
--麻将隐藏遮罩
function CSBMahjong:hideCover()
    if self.cover ~= nil then
        self.cover:setVisible(false)
        self.cover:removeFromParent()
        self.cover = nil
    end
end


--麻将显示箭头
function CSBMahjong:showPointer()
    if self.root:getChildByName("pointer") ~= nil then 
        self.root:getChildByName("pointer"):removeFromParent()
        self.pointer = nil
    end
    self.pointer = display.newCSNode("game/mjcover.csb"):getChildByName("pointer")
    self.pointer:removeFromParent()
    self.root:addChild(self.pointer)
    self.pointer:setVisible(true)

    --create an action
    --[[
    local time = 0.2
    local distance = 4
    local x, y = self.pointer:getPosition()
    local action = cc.MoveTo:create(time, cc.p(x, y + distance))
    local action2 = cc.MoveTo:create(time, cc.p(x, y))
    local action3 = cc.MoveTo:create(time, cc.p(x, y - distance))
    local action4 = cc.MoveTo:create(time, cc.p(x, y))
    local action5 = cc.RepeatForever:create(cc.Sequence:create(action, action2, action3, action4))
    self.pointer:runAction(action5)
    --]]
end
--麻将隐藏遮罩
function CSBMahjong:hidePointer()
    if self.pointer ~= nil then
        self.pointer:setVisible(false)
        self.pointer:removeFromParent()
        self.pointer = nil
    end
end


function CSBMahjong:onExit()
    self:unlistenTouch()--取消触摸
    self:unregisterScriptHandler()--取消自身监听
end

return CSBMahjong
