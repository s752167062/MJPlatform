local FeedbackUI = class("FeedbackUI",function() 
    return cc.Node:create()
end)

function FeedbackUI:ctor(data)
    self.root = display.newCSNode("FeedbackUI.csb")
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

function FeedbackUI:onEnter()
    local ctn_close = self.root:getChildByName("bg"):getChildByName("btn_close")
    ctn_close:addClickEventListener(function() self:onClose() end)

    self.ctn_send = self.root:getChildByName("bg"):getChildByName("btn_send")
    self.ctn_send:addClickEventListener(function() self:onSend() end)
    
    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = pSender
        local strFmt 
        if strEventName == "began" then
            
        elseif strEventName == "ended" then
            
        elseif strEventName == "return" then
           
        elseif strEventName == "changed" then

        end
    end
    
    ---last
    local txt_content = self.root:getChildByName("bg"):getChildByName("contentField")
    txt_content:setPlaceHolder("请勿超过200字")
    txt_content:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    txt_content:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    txt_content:registerScriptEditBoxHandler(editBoxTextEventHandle) 
end

function FeedbackUI:onExit()
    self:unregisterScriptHandler()--取消自身监听
end

function FeedbackUI:onClose()
    self:removeFromParent()
end

function FeedbackUI:onSend()
    cclog("点击发送按钮")
    local txt_content = self.root:getChildByName("bg"):getChildByName("contentField")
    local text = txt_content:getStringValue()
    local count = string.len(text)
    if count > 0 and count < 200 then
        cclog("*** text = " .. Util.CATStringWithoutEmoji(text , 1 , count) .. ",count=" .. count)
        ex_hallHandler:onSendFeedBack(Util.CATStringWithoutEmoji(text , 1 , count))
        self:onClose()
    else
        -- 提示
        if count >= 200 then
            GlobalFun:showToast("反馈内容不超过200字", Game_conf.TOAST_SHORT)
        else
            GlobalFun:showToast("反馈内容不能为空", Game_conf.TOAST_SHORT)
        end     
    end
end

return FeedbackUI