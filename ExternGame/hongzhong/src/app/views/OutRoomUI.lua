local OutRoomUI = class("OutRoomUI",function() 
    return cc.Node:create()
end)

function OutRoomUI:ctor(data)
    if data then
        self.scene = data.scene
        self.isRoomOwner = data.isRoomOwner or false --是否房主 
        self.isStart = data.isStart or false --是否已开始摸牌
    end
    
    self.root = display.newCSNode("OutRoomUI.csb")
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
end

function OutRoomUI:onEnter()
    local ctn_close = self.root:getChildByName("bg"):getChildByName("btn_close")
    ctn_close:addClickEventListener(function() 

    if self.scene then
        self.scene.isReqMiss = false
    end
    self:onClose()
     end)

    --申请解散房间按钮
    local ctn_applyToDissolveRoom = self.root:getChildByName("bg"):getChildByName("btn_applyToDissolveRoom")
    ctn_applyToDissolveRoom:addClickEventListener(function() self:onApplyToDissolveRoom() end)

    --解散房间按钮
    local ctn_dissolveRoom = self.root:getChildByName("bg"):getChildByName("btn_dissolveRoom")
    ctn_dissolveRoom:addClickEventListener(function() self:onDissolveRoom() end)

    --离开房间按钮
    local ctn_exitRoom = self.root:getChildByName("bg"):getChildByName("btn_exitRoom")
    ctn_exitRoom:addClickEventListener(function() self:onExitRoom() end)
    
    CCXNotifyCenter:listen(self,function() self:gameOpen() end,"NotifyGameOpen")

    cclog("OutRoomUI >>>>", self.isRoomOwner, self.isStart, self.scene, self.scene.isWatch, GameRule.canDaiKai)

    if self.isRoomOwner == true then --房主
        if self.isStart == true then --已开始摸牌
            if self.scene and self.scene.isWatch then
                ctn_applyToDissolveRoom:setVisible(false)
                ctn_dissolveRoom:setVisible(false)
                ctn_exitRoom:setVisible(true)
            else
                ctn_applyToDissolveRoom:setVisible(true)
                ctn_dissolveRoom:setVisible(false)
                ctn_exitRoom:setVisible(false)
            end
        else
            local small_bg = self.root:getChildByName("bg"):getChildByName("bg_samll")
            local big_bg = self.root:getChildByName("bg"):getChildByName("bg_big")
            small_bg:setVisible(false)
            big_bg:setVisible(true);

            ctn_applyToDissolveRoom:setVisible(false)
            ctn_dissolveRoom:setVisible(true)
            ctn_exitRoom:setVisible(true)
            ctn_dissolveRoom:setPositionY(ctn_exitRoom:getPositionY() + 45)
            ctn_exitRoom:setPositionY(ctn_exitRoom:getPositionY() - 55)
        end
        if not GameRule.canDaiKai then
            local small_bg = self.root:getChildByName("bg"):getChildByName("bg_samll")
            local big_bg = self.root:getChildByName("bg"):getChildByName("bg_big")
            ctn_exitRoom:setVisible(false)
            small_bg:setVisible(true)
            big_bg:setVisible(false)
        end
    elseif self.isRoomOwner == false then --加入者
        if self.isStart == true then
            if self.scene and self.scene.isWatch then
                ctn_applyToDissolveRoom:setVisible(false)
                ctn_dissolveRoom:setVisible(false)
                ctn_exitRoom:setVisible(true)
            else
                ctn_applyToDissolveRoom:setVisible(true)
                ctn_dissolveRoom:setVisible(false)
                ctn_exitRoom:setVisible(false)
            end
        else
            ctn_applyToDissolveRoom:setVisible(false)
            ctn_dissolveRoom:setVisible(false)
            ctn_exitRoom:setVisible(true)
        end
    end
    if self.scene == nil then
        ctn_applyToDissolveRoom:setVisible(false)
        ctn_dissolveRoom:setVisible(false)
        ctn_exitRoom:setVisible(false)
    end
end

function OutRoomUI:gameOpen()--游戏开始了
    self.root:getChildByName("bg"):getChildByName("btn_applyToDissolveRoom"):setVisible(true)
    self.root:getChildByName("bg"):getChildByName("btn_dissolveRoom"):setVisible(false)
    self.root:getChildByName("bg"):getChildByName("btn_exitRoom"):setVisible(false)
end

function OutRoomUI:onExit()
    CCXNotifyCenter:unListenByObj(self)
    self:unregisterScriptHandler()--取消自身监听
end

function OutRoomUI:onClose()
    self:removeFromParent()
end

function OutRoomUI:onApplyToDissolveRoom()
    cclog("点击申请解散房间按钮")
    --向服务器发起申请解散房间请求
    
    --接收到服务器反馈，关闭本界面，打开投票界面(注意：是挂接到麻将桌界面)
    
    -- local ui = ex_fileMgr:loadLua("app.views.VoteUI")
    -- --isInitiator 是否发起人，initiatorIndex 发起人索引(1-4，默认第1个就是当前玩家)，playerName 4个玩家名字
    -- local info = {}
    -- for i=1,4 do
    --     if self.scene.player[i].isPeople then
    --         info[#info + 1] = {}
    --         info[#info].name = self.scene.player[i].name
    --         info[#info].id = self.scene.player[i].id
    --     end
    -- end
    -- self.scene.isReqMiss = true
    -- self.scene.askFrame = ui.new()
    -- self.scene.askFrame:initParams({app = self.app, isInitiator = index == 1, initiatorIndex = index, playerInfo = info,disTime = self.disTime, is_watch = is_watch})

    -- self.scene.askFrame:setTag(VOTEUI_TAG)
    -- self.scene.ctn_win:addChild(self.scene.askFrame)
    
    -- self.scene.isReqMiss = true
    ex_roomHandler:requireDismissRoom()
    
    self:onClose()
    
end

function OutRoomUI:onDissolveRoom()--解散房间
    GlobalFun:showNetWorkConnect("解散房间中...")
    self.scene.isReqMiss = true
    ex_roomHandler:requireDismissRoom()
end

function OutRoomUI:onExitRoom()--普通玩家没开局
    GlobalFun:showNetWorkConnect("正在退出房间...")
    self.scene.isReqMiss = true
    if self.scene and self.scene.isWatch then
        ex_roomHandler:exitWatch()
    else
        ex_roomHandler:userRequestExit()
    end
end

return OutRoomUI