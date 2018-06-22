local UIBandingTips = class("UIBandingTips", cc.load("mvc").ViewBase)

UIBandingTips.RESOURCE_FILENAME = "layout/SellerShare/UIBandingTips.csb"
UIBandingTips.RESOURCE_BINDING = {
    ["btn_close"]           = {    ["varname"] = "btn_close"            ,  ["events"] = { {event = "click" ,  method ="onBack"  } }      },
    ["btn_showbanding"]     = {    ["varname"] = "btn_showbanding"      ,  ["events"] = { {event = "click" ,  method ="onOK"    } }      },
    ["txt_msg"]             = {    ["varname"] = "txt_msg"          },
    ["txt_tipsmsg"]         = {    ["varname"] = "txt_tipsmsg"      },
}

function UIBandingTips:onCreate()
    dump("CREATE")
    self.okfunc = nil
end

function UIBandingTips:onEnter()
    dump("ENTER")
    local msg= gameConfMgr:getInfo("delegate_tipsmsg")
    print("--- base bind tips", msg)
    if msg == nil or msg == "" then 
        msg = "绑定邀请码享受充值优惠,\n详情请联系群主、代理或官方客服"
    else
        msg = string.gsub(msg,"<br>","\n")  
    end    
    self.txt_msg:setString(msg)
end

function UIBandingTips:onExit()
    dump("EXIT")
end

function UIBandingTips:setBtnFunc(func)
    self.okfunc = func
end

------ 按钮 -------
function UIBandingTips:onBack()
    dump("-------onBack")
    self:removeFromParent()
end

function UIBandingTips:onOK()
    dump("-------onOK")
    if self.okfunc then 
        print("-- call ")
        self.okfunc()
    end    
    self:removeFromParent()
end


return UIBandingTips