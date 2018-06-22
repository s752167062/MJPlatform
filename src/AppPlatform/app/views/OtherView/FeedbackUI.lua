local FeedbackUI = class("FeedbackUI",cc.load("mvc").ViewBase)

FeedbackUI.RESOURCE_FILENAME =  __platformHomeDir .."ui/layout/OtherView/FeedbackUI.csb"

function FeedbackUI:onCreate()
    self:findChildByName("btn_close"):onClick(function ( event )  
        self:onClose()
    end)

    self.ctn_send = self:findChildByName("btn_send")
    self.ctn_send:onClick(function() self:onSend() end)

    self.txt_content = self:findChildByName("contentField")   
    -- self.txt_name = self:findChildByName("txt_name")
    -- self.txt_id = self:findChildByName("txt_id")
end

function FeedbackUI:onClose()
    viewMgr:close("OtherView.FeedbackUI")
end

function FeedbackUI:onExit()
    self:unregisterScriptHandler()--取消自身监听
end

function FeedbackUI:onSend()
    cclog("点击发送按钮")
    local text = self.txt_content:getStringValue()
    local count = string.len(text)
    if count > 0 and count < 200 then
        cclog("*** text = " .. comFunMgr:CATStringWithoutEmoji(text , 1 , count) .. ",count=" .. count)
        local content = comFunMgr:CATStringWithoutEmoji(text , 1 , count)
        -- local name = self.txt_name:getStringValue() or ""
        -- local id = self.txt_id:getStringValue() or ""
        hallSendMgr:sendFeedBack(content or "")
        self:onClose()
    else
        -- 提示
        if count >= 200 then
            msgMgr:showToast("反馈内容不超过200字")
        else
            msgMgr:showToast("反馈内容不能为空")
        end     
    end
end

return FeedbackUI