local SetUI = class("SetUI",cc.load("mvc").ViewBase)

SetUI.RESOURCE_FILENAME =  __platformHomeDir .."ui/layout/OtherView/SetUI.csb"

-- function SetUI:ctor(data)


   
-- end

function SetUI:onEnter()
    local ctn_close = self:findChildByName("btn_close")
    ctn_close:addClickEventListener(function() 
        self:onClose()
     end)


    local btn_exit = self:findChildByName("btn_exit")
    btn_exit:addClickEventListener(function() 
        self:onExitGame()
     end)
    
    --音效
    self.soundSlider = self:findChildByName("soundSlider")

    self.soundSlider:setPercent(gameConfMgr:getInfo("voiceEffect") * 100)
    self.soundSlider:addTouchEventListener(function() self:onSoundChanged() end)
    --音乐
    self.musicSlider = self:findChildByName("musicSlider")

    self.musicSlider:setPercent(gameConfMgr:getInfo("voiceValue") * 100)
    self.musicSlider:addTouchEventListener(function() self:onMusicChanged() end)




end


function SetUI:onExit()
    self:unregisterScriptHandler()
end

function SetUI:onClose()
    viewMgr:close("OtherView.SetUI")
end

function SetUI:onExitGame()
    local function queding()
        os.exit(1)
    end
    msgMgr:showAskMsg("您是否要退出游戏", queding)
end

function SetUI:onSoundChanged()
    audioMgr:setEffectsVolume(self.soundSlider:getPercent())


end

function SetUI:onMusicChanged()
    audioMgr:setMusicVolume(self.musicSlider:getPercent())


end





return SetUI
