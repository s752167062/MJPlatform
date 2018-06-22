local UICallService = class("UICallService", cc.load("mvc").ViewBase)

UICallService.RESOURCE_FILENAME = "layout/SellerShare/UICallService.csb"
UICallService.RESOURCE_BINDING = {
    ["btn_close"]       = {    ["varname"] = "btn_close"            ,  ["events"] = { {event = "click" ,  method ="onBack"          } }     },
    ["btn_submit"]      = {    ["varname"] = "btn_submit"           ,  ["events"] = { {event = "click" ,  method ="onSubmit"        } }     },
    ["txt_serviceMsg"]  = {    ["varname"] = "txt_serviceMsg"              },
    ["editbox"]         = {    ["varname"] = "editbox"                     }
}

function UICallService:onCreate()
    dump("CREATE")
end

function UICallService:onEnter()
    dump("ENTER")
    self.txt_serviceMsg:setString("趣牌公众号：趣牌互娱          客服微信：qupai111\n客服电话：4006978880")

    eventMgr:registerEventListener("on_SendMsg2Service"      ,handler(self,self.onBack     ),"UICallService")  
end

function UICallService:onExit()
    dump("EXIT")
    eventMgr:removeEventListenerForTarget("UICallService")
end

------ 按钮 -------
function UICallService:onBack()
    dump("-------onBack")
    self:removeFromParent()
end

function UICallService:onSubmit()
    dump("-------onSubmit" ,self.editbox:getStringValue())
    local value = self.editbox:getStringValue()
    if value and string.len(value) > 0 then 
        if string.len(value) > 140 * 3 then --中文长度 3 
            SellerShareMgr:showToast("字数超过140，请重新编辑")
        else
            SellerShareMgr:sendMsg2Service(value)
        end
    end    
end

return UICallService