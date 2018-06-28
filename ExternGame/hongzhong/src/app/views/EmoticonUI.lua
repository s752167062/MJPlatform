local EmoticonUI = class("EmoticonUI",function() 
    return cc.Node:create()
end)

function EmoticonUI:ctor(data)
    self.root = display.newCSNode("EmoticonUI.csb")
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
    
    self.btn_face = {} --表情按钮
    self.btn_voice = {} --语音按钮
end

function EmoticonUI:onEnter()

    local ctn_close = self.root:getChildByName("bg"):getChildByName("btn_close")
    ctn_close:addClickEventListener(function() self:onClose() end)

    self.ctn_face = self.root:getChildByName("bg"):getChildByName("btn_face") --表情分页按钮
    self.ctn_face:addClickEventListener(function() self:onPageBtn(1) end)
    
    self.ctn_voice = self.root:getChildByName("bg"):getChildByName("btn_voice") --语音分页按钮
    self.ctn_voice:addClickEventListener(function() self:onPageBtn(2) end)

    self.scrollview_face = self.root:getChildByName("bg"):getChildByName("ScrollView_face") --表情分页
    self.scrollview_voice = self.root:getChildByName("bg"):getChildByName("ScrollView_voice") --语音分页
    self:onPageBtn(1) --默认显示表情页面

    for i = 1,12,1 do
        self:CreateFaceBtn(i) --表情按钮
    end
    
    for i = 1,10,1 do
        self:CreateVoiceBtn(i) --语音按钮
    end

end

function EmoticonUI:onExit()
    self:unregisterScriptHandler()--取消自身监听
end

function EmoticonUI:onClose()
    self:removeFromParent()
end

function EmoticonUI:onPageBtn(index) 
    if index == 1 then
        self.ctn_face:setEnabled(false)
        self.ctn_voice:setEnabled(true)
        self.scrollview_face:setVisible(true)
        self.scrollview_voice:setVisible(false)
    elseif index == 2 then
        self.ctn_face:setEnabled(true)
        self.ctn_voice:setEnabled(false)
        self.scrollview_face:setVisible(false)
        self.scrollview_voice:setVisible(true)
    end
end

function EmoticonUI:CreateFaceBtn(index)
    if index < 1 or index > 12 then
        return
    end
    local btn = self.root:getChildByName("bg"):getChildByName("ScrollView_face"):getChildByName("btn_face" .. index)
    btn:addClickEventListener(function() self:onFaceBtn(index) end)
    self.btn_face[index] = btn
end

function EmoticonUI:CreateVoiceBtn(index)
    if index < 1 or index > 10 then
        return
    end
    local btn = self.root:getChildByName("bg"):getChildByName("ScrollView_voice"):getChildByName("panel" .. index):getChildByName("btn_voice" .. index)
    btn:addClickEventListener(function() self:onVoiceBtn(index) end)
    self.btn_voice[index] = btn
end

function EmoticonUI:onFaceBtn(index)
    cclog("点击表情按钮" .. index)
    --在麻将桌界面显示自己的表情
    --向服务器请求发送表情索引
    CCXNotifyCenter:notify("ShowEmoji",index)
    self:removeFromParent()
end

function EmoticonUI:onVoiceBtn(index)
    cclog("点击语音按钮" .. index)
    --在麻将桌界面显示自己的语音
    --向服务器请求发送语音索引
    CCXNotifyCenter:notify("ShowEmojiVoice",index)
    self:removeFromParent()
end

return EmoticonUI
