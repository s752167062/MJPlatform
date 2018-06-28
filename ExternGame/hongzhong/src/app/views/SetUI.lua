local SetUI = class("SetUI",function() 
    return cc.Node:create()
end)

function SetUI:ctor(data)
    if data then
        self.scene = data.scene
        -- self.isRoomOwner = data.isRoomOwner or false --是否房主 
        -- self.isStart = data.isStart or false --是否已开始摸牌
    end
    
    self.root = display.newCSNode("SetUI.csb")
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

function SetUI:onEnter()
    local ctn_close = self.root:getChildByName("bg"):getChildByName("btn_close")
    ctn_close:addClickEventListener(function() 

    if self.scene then
        self.scene.isReqMiss = false
    end
    self:onClose()
     end)

    --音效
    self.ctn_sound = self.root:getChildByName("bg"):getChildByName("soundSlider")
    --ex_audioMgr:setEffectsVolume(GlobalData.EffectsVolume)
    self.ctn_sound:setPercent(platformExportMgr:doGameConfMgr_getInfo("voiceEffect") * 100)
    self.ctn_sound:addTouchEventListener(function() self:onSoundChanged() end)
    --音乐
    self.ctn_music = self.root:getChildByName("bg"):getChildByName("musicSlider")
    --ex_audioMgr:setMusicVolume(GlobalData.MusicVolume)
    self.ctn_music:setPercent(platformExportMgr:doGameConfMgr_getInfo("voiceValue") * 100)
    self.ctn_music:addTouchEventListener(function() self:onMusicChanged() end)

    -- --申请解散房间按钮
    -- local ctn_applyToDissolveRoom = self.root:getChildByName("bg"):getChildByName("btn_applyToDissolveRoom")
    -- ctn_applyToDissolveRoom:addClickEventListener(function() self:onApplyToDissolveRoom() end)

    -- --解散房间按钮
    -- local ctn_dissolveRoom = self.root:getChildByName("bg"):getChildByName("btn_dissolveRoom")
    -- ctn_dissolveRoom:addClickEventListener(function() self:onDissolveRoom() end)

    -- --离开房间按钮
    -- local ctn_exitRoom = self.root:getChildByName("bg"):getChildByName("btn_exitRoom")
    -- ctn_exitRoom:addClickEventListener(function() self:onExitRoom() end)
    
    -- CCXNotifyCenter:listen(self,function() self:gameOpen() end,"NotifyGameOpen")


end

-- function SetUI:gameOpen()--游戏开始了
--     self.root:getChildByName("bg"):getChildByName("btn_applyToDissolveRoom"):setVisible(true)
--     self.root:getChildByName("bg"):getChildByName("btn_dissolveRoom"):setVisible(false)
--     self.root:getChildByName("bg"):getChildByName("btn_exitRoom"):setVisible(false)
-- end

function SetUI:onExit()
    CCXNotifyCenter:unListenByObj(self)
    self:unregisterScriptHandler()--取消自身监听
end

function SetUI:onClose()
    self:removeFromParent()
end

function SetUI:onSoundChanged()
    local value1 = self.ctn_sound:getPercent()
    cclog("value1=" .. value1)
    ex_audioMgr:setEffectsVolume(value1)
    -- GlobalData.EffectsVolume = value1 / 100.0
    -- UserDefault:setKeyValue("EffectsVolume",GlobalData.EffectsVolume)
    -- UserDefault:write()
end

function SetUI:onMusicChanged()
    local value2 = self.ctn_music:getPercent()
    cclog("value2=" .. value2)
    ex_audioMgr:setMusicVolume(value2)
    -- GlobalData.MusicVolume = value2 / 100.0
    -- UserDefault:setKeyValue("MusicVolume",GlobalData.MusicVolume)
    -- UserDefault:write()
end





return SetUI
