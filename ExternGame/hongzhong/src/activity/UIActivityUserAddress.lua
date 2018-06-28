local uiActivityUserAddress = class("uiActivityUserAddress", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

uiActivityUserAddress.RESOURCE_FILENAME = "activity2/uiActivityUserAddress.csb"
uiActivityUserAddress.RESOURCE_BINDING = {
    ["editbox_phone"]     = {    ["varname"] = "editbox_phone"            },
    ["editbox_wechat"]    = {    ["varname"] = "editbox_wechat"           },
    ["editbox_name"]      = {    ["varname"] = "editbox_name"             },
    ["editbox_alipay"]    = {    ["varname"] = "editbox_alipay"           },
    ["btn_ok"]      = {    ["varname"] = "btn_ok"               ,  ["events"] = { {event = "click" ,  method ="onOK"       } }       },
    ["btn_change"]  = {    ["varname"] = "btn_change"           ,  ["events"] = { {event = "click" ,  method ="onOK"       } }       },
    ["btn_close"]   = {    ["varname"] = "btn_close"      		,  ["events"] = { {event = "click" ,  method ="onClose"    } }       },
    ["btn_cancel"]  = {    ["varname"] = "btn_cancel"           ,  ["events"] = { {event = "click" ,  method ="onCancel"   } }       },
}

function uiActivityUserAddress:onCreate()
    cclog("CREATE")
end

function uiActivityUserAddress:onEnter()
    cclog("ENTER")
    if ActivityMgr.ActivityUserInfo then 
    	local name = ActivityMgr.ActivityUserInfo.name 
    	local wechat = ActivityMgr.ActivityUserInfo.wechat
    	local phone = ActivityMgr.ActivityUserInfo.phone
        local alipay =ActivityMgr.ActivityUserInfo.alipay

    	self.editbox_name:setString(name)
		self.editbox_wechat:setString(wechat)
		self.editbox_phone:setString(phone)
        self.editbox_alipay:setString(alipay)

		self.btn_ok:setVisible(false)
		self.btn_change:setVisible(true)
   	end

   	CCXNotifyCenter:listen(self,function(self,obj,data) self:saveAddressInfoData() end ,"onUploadActivityUserInfo")
end

function uiActivityUserAddress:onExit()
    cclog("EXIT")
    CCXNotifyCenter:unListenByObj(self)
end

function uiActivityUserAddress:setData(data)
	if data then 
		self.data = data
		self.clubID = data.clubID
	end
end

function uiActivityUserAddress:saveAddressInfoData()
	local name   = self.editbox_name:getStringValue()
    local wechat = self.editbox_wechat:getStringValue()
    local phone  = self.editbox_phone:getStringValue()
    local alipay = self.editbox_alipay:getStringValue()

	ActivityMgr.ActivityUserInfo = { name= name ,wechat= wechat ,phone= phone ,alipay = alipay}
end

------ 按钮 -------
function uiActivityUserAddress:onOK()
    cclog("-------onOK")
    -- self:removeFromParent()
    local name   = self.editbox_name:getStringValue()
    local wechat = self.editbox_wechat:getStringValue()
    local phone  = self.editbox_phone:getStringValue()
    local alipay = self.editbox_alipay:getStringValue()

    if name == nil or name== "" then
    	ActivityMgr:showToast("姓名不能为空")
    	return
    end
    if wechat == nil or wechat== "" then
    	ActivityMgr:showToast("银行信息不能为空")
        return   
    end
    if alipay == nil or alipay== "" then 
        ActivityMgr:showToast("银行卡号不能为空")
        return
    end 
    if phone == nil or phone== "" then
    	ActivityMgr:showToast("手机号不能为空")
    	return
    elseif string.len(phone) ~= 11 then
    	ActivityMgr:showToast("无效的手机号")
    	return
    end

    local function callfunc()
        if ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_HALL then
            ActivityMgr:uploadActivityUserInfo(self.clubID, name ,wechat,phone ,alipay)
        elseif ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_CLUB then 
            ActivityMgr:uploadActivityUserInfoClub(self.clubID, name ,wechat,phone,alipay)
        end
    end
    ActivityMgr.ActivityUserInfoTemp = { name= name ,wechat= wechat ,phone= phone ,alipay = alipay}--临时存储
    ActivityMgr:showToast(string.format("请确认提交信息：\n姓名:%s\n银行卡号:%s\n银行信息:%s\n手机号:%s" ,name,alipay,wechat,phone ),callfunc)
end

function uiActivityUserAddress:onClose()
    cclog("-------onClose")
    self:removeFromParent()
end

function uiActivityUserAddress:onCancel()
	-- self.editbox_name:setString("")
	-- self.editbox_wechat:setString("")
	-- self.editbox_phone:setString("")
    cclog("-------onClose")
    self:removeFromParent()
end
return uiActivityUserAddress