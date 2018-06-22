local UIBangDingDele = class("UIBangDingDele", cc.load("mvc").ViewBase)
local BasePlayerIcon = require("app.views.PlayerIcon")

UIBangDingDele.RESOURCE_FILENAME = "layout/SellerShare/UI_Bangdingdaili.csb"
UIBangDingDele.RESOURCE_BINDING = {
    ["btn_close"]           = {    ["varname"] = "btn_close"            ,  ["events"] = { {event = "click" ,  method ="onBack"  } }     },
    ["btn_close2"]           = {    ["varname"] = "btn_close2"            ,  ["events"] = { {event = "click" ,  method ="onBack"  } }     },

    ["panel_player"]        = {    ["varname"] = "panel_player"                     },
    ["txt_bindTime"]        = {    ["varname"] = "txt_bindTime"                     },
    ["node_icon"]          = {    ["varname"] = "node_icon"                         },
    ["txt_dailiName"]      = {    ["varname"] = "txt_dailiName"                     },
    ["txt_dailiID"]        = {    ["varname"] = "txt_dailiID"                       }, 
    ["Node_3"]             = {    ["varname"] = "Node_3"                            },   

    ["bg"]        = {    ["varname"] = "bg"                     },
    ["bg2"]        = {    ["varname"] = "bg2"                     },

    ["panel_number"]        = {    ["varname"] = "panel_number"                     },
    ["inputNumber"]        = {    ["varname"] = "inputNumber"   },
    ["yqwenben"]       = {    ["varname"] = "yqwenben"     },
    ["btn0"]           = {    ["varname"] = "btn0"          ,  ["events"] = { {event = "click" ,  method ="onNumTouch"   } }     },
    ["btn1"]           = {    ["varname"] = "btn1"          ,  ["events"] = { {event = "click" ,  method ="onNumTouch"   } }     },
    ["btn2"]           = {    ["varname"] = "btn2"          ,  ["events"] = { {event = "click" ,  method ="onNumTouch"   } }     },
    ["btn3"]           = {    ["varname"] = "btn3"          ,  ["events"] = { {event = "click" ,  method ="onNumTouch"   } }     },
    ["btn4"]           = {    ["varname"] = "btn4"          ,  ["events"] = { {event = "click" ,  method ="onNumTouch"   } }     },
    ["btn5"]           = {    ["varname"] = "btn5"          ,  ["events"] = { {event = "click" ,  method ="onNumTouch"   } }     },
    ["btn6"]           = {    ["varname"] = "btn6"          ,  ["events"] = { {event = "click" ,  method ="onNumTouch"   } }     },
    ["btn7"]           = {    ["varname"] = "btn7"          ,  ["events"] = { {event = "click" ,  method ="onNumTouch"   } }     },
    ["btn8"]           = {    ["varname"] = "btn8"          ,  ["events"] = { {event = "click" ,  method ="onNumTouch"   } }     },
    ["btn9"]           = {    ["varname"] = "btn9"          ,  ["events"] = { {event = "click" ,  method ="onNumTouch"   } }     },
    ["btn_backspace"]  = {    ["varname"] = "btn_backspace" ,  ["events"] = { {event = "click" ,  method ="onBackspace"   } }     },
    --["btn_reInput"]    = {    ["varname"] = "btn_reInput"   ,  ["events"] = { {event = "click" ,  method ="onReInput"   } }     },
    ["btn_ok"]    = {    ["varname"] = "btn_ok"   ,  ["events"] = { {event = "click" ,  method ="onBangding"   } }     },
}

function UIBangDingDele:onCreate()
    dump("CREATE")
    self.bg:setVisible(true)
    self.bg2:setVisible(false)
end

function UIBangDingDele:onEnter()
    dump("ENTER")
    eventMgr:registerEventListener("onDelegateIDCheck", handler(self,self.onDelegateIDCheck),self) -- 检查代理ID
    eventMgr:registerEventListener("onBindDelegate"   , handler(self,self.onBindDelegate),self) -- 
    eventMgr:registerEventListener("CheckDelegateStatus", handler(self,self.setData),self) -- 检查代理状态

    self.inputTab = {}
    self:refreshInputNumber()
    self.clickCount = 0--数字键点击次数
end

function UIBangDingDele:onExit()
    dump("EXIT")
    eventMgr:removeEventListenerForTarget(self)
end

function UIBangDingDele:setData(data)
    self.data = data
    dump(data, "UIBangDingDele:setData")
    if data then 
        local delegate_id = data.delegate_id
        local delegate_name = data.delegate_name
        local delegate_icon = data.delegate_icon
        local delegate_time = data.delegate_time

        if delegate_id ~= 0 then --自己不是代理且绑定了代理
            self.bg:setVisible(false)
            self.bg2:setVisible(true)

            self.txt_dailiName:setString(""..delegate_name or "")
            self.txt_dailiID:setString("ID："..delegate_id or "")
            self.txt_bindTime:setString("绑定时间："..delegate_time or "")

            self.playerIcon = BasePlayerIcon.new()
            self.playerIcon:setScale(0.85)
            self.node_icon:addChild(self.playerIcon)
            self.playerIcon:setIcon(delegate_id , delegate_icon)
        end    
    end    
end

function UIBangDingDele:onDelegateIDCheck(data)
    if data then 
        self.delegate_data = data 
        local delegate_id = data.delegate_id
        local delegate_name = data.delegate_name
        local delegate_icon = data.delegate_icon

        self.bg:setVisible(false)
        self.bg2:setVisible(true)

        self.txt_dailiName:setString(""..delegate_name or "")
        self.txt_dailiID:setString("ID："..delegate_id or "")

        self.playerIcon = BasePlayerIcon.new()
        self.playerIcon:setScale(0.85)
        self.node_icon:addChild(self.playerIcon)
        self.playerIcon:setIcon(delegate_id , delegate_icon)
    end    
end    

function UIBangDingDele:onBindDelegate()
    SellerShareMgr:showToast("绑定代理成功")
    SellerShareMgr:checkDelegateStatus() --设置绑定信息
end

------ 按钮 -------
function UIBangDingDele:onBack()
    dump("-------onBack")
    self:removeFromParent()
end

-- function UIBangDingDele:onSearch()
--     dump("-------onOK")
--     local id_str = self.textField_id:getStringValue()
--     if id_str and tonumber(id_str) then 
--         SellerShareMgr:delegateIDCheck(tonumber(id_str))
--     else
--         msgMgr:showMsg("请重新输入正确的ID")
--     end    
-- end

function UIBangDingDele:onBind()
    local function func()
        local id_str = self.textField_id:getStringValue()
        SellerShareMgr:bindDelegate(tonumber(id_str))
    end
    SellerShareMgr:showToast(string.format("您即将与 %s 绑定关系，请确定操作", self.delegate_data.delegate_name ), func)
end

-- function UIBangDingDele:onCancel()
--     self.Node_3:setVisible(false)
--     self.panel_player:setVisible(false)
--     self.textField_id:setString("")
-- end

---------------------------
function UIBangDingDele:refreshInputNumber()
    -- body
    self.inputNumber:setString("")
    local str = ""
    if #self.inputTab > 0 then
        for i,v in ipairs(self.inputTab) do
            str = str..v
        end
        self.inputNumber:setString(str)
        self.yqwenben:setVisible(false)
    else
        self.yqwenben:setVisible(true)
        self.inputNumber:setString("")
    end
end

function UIBangDingDele:onNumTouch(btn)
    local btnName = btn:getName()
    local index = string.sub(btnName, 4)
    if self.clickCount >= 12 then
        msgMgr:showToast("请重新输入正确的ID")
        return
    end 
    self.clickCount = self.clickCount + 1
    table.insert(self.inputTab, index)
    self:refreshInputNumber()
end

function UIBangDingDele:onBackspace()
    if self.clickCount < 1 then
        return
    end 
    table.remove(self.inputTab, self.clickCount)
    self:refreshInputNumber()
    self.clickCount = self.clickCount - 1
end

function UIBangDingDele:onReInput()
    self.inputTab = {}
    self:refreshInputNumber()
    self.clickCount = 0
end

function UIBangDingDele:onBangding()
    local id_str = self.inputNumber:getString()
    local function func()
        SellerShareMgr:bindDelegate(tonumber(id_str))
    end
    SellerShareMgr:showToast(string.format("您即将与 ID[%s] 绑定关系，请确定操作", id_str ), func)
end

return UIBangDingDele