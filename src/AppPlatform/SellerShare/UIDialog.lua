local UIDialog = class("UIDialog", cc.load("mvc").ViewBase)

UIDialog.RESOURCE_FILENAME = "layout/SellerShare/UIDialog.csb"
UIDialog.RESOURCE_BINDING = {
    ["btn_close"]           = {    ["varname"] = "btn_close"            ,  ["events"] = { {event = "click" ,  method ="onBack"  } }     },
    ["btn_ok"]              = {    ["varname"] = "btn_ok"               ,  ["events"] = { {event = "click" ,  method ="onOK"  } }      },
    ["txt_msg"]             = {    ["varname"] = "txt_msg"                      },
    -- ["img_invite_faild"]    = {    ["varname"] = "img_invite_faild"             },
    -- ["img_invite_success"]  = {    ["varname"] = "img_invite_success"           },
    ["img_card"]            = {    ["varname"] = "img_card"                     }
}

function UIDialog:onCreate()
    dump("CREATE")
    self.okfunc = nil
end

function UIDialog:onEnter()
    dump("ENTER")
end

function UIDialog:onExit()
    dump("EXIT")
end

function UIDialog:showSuccess(msg)
    -- self.img_invite_success:setVisible(true)
    self.img_card:setVisible(true)
    self.txt_msg:setString(msg)
end

function UIDialog:showFailed(msg)
    -- self.img_invite_faild:setVisible(true)
    self.txt_msg:setString(msg)
end

function UIDialog:showMsg(msg, func)
    self.txt_msg:setString(msg)
    self.okfunc = func
    print("----- showMsg ",func)
end

------ 按钮 -------
function UIDialog:onBack()
    dump("-------onBack")
    self:removeFromParent()
end

function UIDialog:onOK()
    dump("-------onOK")
    if self.okfunc then 
        print("-- call ")
        self.okfunc()
    end    
    self:removeFromParent()
end


return UIDialog