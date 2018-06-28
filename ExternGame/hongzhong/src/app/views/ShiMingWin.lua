local ShiMingWin = class("ShiMingWin", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

ShiMingWin.RESOURCE_FILENAME = "ShiMingWin.csb"
ShiMingWin.RESOURCE_BINDING = {
    ["btn_cancel"]       = {    ["varname"] = "btn_cancel"     ,  ["events"] = { {event = "click" ,  method ="onClose"        } }     },
    ["btn_close"]       = {    ["varname"] = "btn_close"     ,  ["events"] = { {event = "click" ,  method ="onClose"        } }     },
    ["btn_sure"]       = {    ["varname"] = "btn_sure"     ,  ["events"] = { {event = "click" ,  method ="onSure"        } }     },
    ["name"]       = {    ["varname"] = "name"        },
    ["id"]       = {    ["varname"] = "id"      },
    ["yirenzheng"]       = {    ["varname"] = "yirenzheng"      },
}


function ShiMingWin:onCreate()

    self.root = self:getResourceNode()
end

function ShiMingWin:onEnter()



    self.name:setTextVerticalAlignment(1)    
    self.id:setTextVerticalAlignment(1)    




    self:showState()


    CCXNotifyCenter:listen(self,function() self:onShiMing()  end, "onShiMing")
end


function ShiMingWin:onExit()
    -- cclog("ShiMingWin:onExit")
    CCXNotifyCenter:unListenByObj(self)

    --点关闭的时候键盘没有跟着一起收起来，只能这样收起来了
    self.name:didNotSelectSelf()
    self.id:didNotSelectSelf()
end



function ShiMingWin:onClose()
    self:removeFromParent()


end

function ShiMingWin:showState()


    local isSuccess = GlobalData.shiming_success 

    if isSuccess then
        self.name:setString(GlobalData.shiming_name)
        self.id:setString(GlobalData.shiming_id)
    end

    self.name:setEnabled(not isSuccess)
    self.id:setEnabled(not isSuccess)
    self.yirenzheng:setVisible(isSuccess)
    self.btn_cancel:setVisible(not isSuccess)
    self.btn_sure:setVisible(not isSuccess)
end

function ShiMingWin:onShiMing(data)

    self:showState()

end

function ShiMingWin:onSure()

    

    local name = self.name:getString()
    local id = self.id:getString()


    if name == "" or id == "" then
        GlobalFun:showError3("请填写正确信息", nil, nil, 1)
        return
    end


    ex_hallHandler:ShiMing(2, {name = name, id = id})
end






return ShiMingWin
