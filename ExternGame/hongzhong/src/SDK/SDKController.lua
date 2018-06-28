--ex_fileMgr:loadLua("app.helper.UserDefault")
--ex_fileMgr:loadLua("SDK.SDKObj_android")
--ex_fileMgr:loadLua("SDK.SDKObj_ios")
--ex_fileMgr:loadLua("app.helper.Util")
--ex_fileMgr:loadLua("app.views.game.PlayerInfo")
--ex_fileMgr:loadLua("app.views.LoginLogic")

SDKController = {}
SDKController.isInit = false;

SDKController.Secret = "b92cb14b7f5f908bac0b2e8baa99a12a";  -- 红中
SDKController.APPID  = "wxf54deb78ec37ea11"; 

SDKController.OTYDNotifyUrl = "http://hzmj-h-h2.hongzhongmajiang.com:8005/Charge_now"
SDKController.LTNotifyUrl   = "http://hzmj-h-h1.hongzhongmajiang.com:8005/Charge_now"
SDKController.DXNotifyUrl   = "http://hzmj-h-h2.hongzhongmajiang.com:8005/Charge_now"

function SDKController:getInstance()
	if SDKController.isInit == false then
	   SDKController:init()
	   SDKController.isInit = true;
	end
	return SDKController
end

function SDKController:init()
    -- self.sdkObj = nil
    -- self.isSwitchAccount = false
    
    -- local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    -- if targetPlatform == cc.PLATFORM_OS_ANDROID then
    --     self.sdkObj = SDKObj_android
    -- elseif targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD or targetPlatform == cc.PLATFORM_OS_MAC then
    --     self.sdkObj = SDKObj_ios
    -- end
    -- if self.sdkObj then
    --     self.sdkObj:init()
    -- end
end


--{ title , desc, url }
--------------------------------------------------
--"房间号【"+MJPlayers.desk.desk+"】 【"+SelectSvr.SvrName+"】"
--"http://download.hongzhongmajiang.com/hongzhong/"
--"我在[红中麻将]"+SelectSvr.SvrName+"开了 "+MJPlayers.desk.round+"局,"+MJPlayers.desk.horse+"个码的房间，快来一起玩吧"
--------------------------------------------------
function SDKController:share(res)
    -- GlobalFun:showNetWorkConnect("请稍后...")
    -- local t = res or { "房间号【".. GlobalData.roomID .. "】 【".. GlobalData.serverID .."】"
    --                             ,"我在[筑志红中麻将]"..GlobalData.serverID.."开了 ".. "x" .."局,".. "y" .."个码的房间，快来一起玩吧" 
    --                             , GlobalFun:dealStr(LoginLogic.shareURL)} 
    -- local bool = self.sdkObj:share(t)
    -- if bool == false then
    --     GlobalFun:closeNetWorkConnect()
    --     cclog(" *** close")
    -- end
    -- return bool
end

function OnSDKShareComplete(res)
    -- cclog(" LUA 分享回调 "..res)
    -- GlobalFun:closeNetWorkConnect()
    -- local p = Util.split(res,",")
    -- if p ~= nil and #p > 1 then
    -- 	local code = p[1]
    -- 	local msg = p[2]
    --     if code ~= "1" then
    --         cclog("LUA 分享失败")
    --         return 
    --     end
    -- end
end



function SDKController:shareScreenShot(res)
    -- GlobalFun:showNetWorkConnect("请稍后...")

    -- local bool = self.sdkObj:shareScreenShot(res)
    -- if bool == false then
    --     GlobalFun:closeNetWorkConnect()
    -- end
    -- return bool
end

local count = 1 
function OnShareScreenShotComp(res)
	-- cclog(" LUA 截屏分享回调 "..res)
 --    GlobalFun:closeNetWorkConnect()
	-- local p = Util.split(res,",")
	-- if p~= nil and #p >1 then
	-- 	local code = p[1]
	-- 	local msg  = p[2]
	-- 	if code ~= "1" then
	-- 		cclog("LUA 截图分享失败")
	-- 		if count > 20 then
	-- 			count = 1 
	-- 		else
	-- 		    count = count + 1
 --                GlobalFun:ShareWeCharScreenShot()
	-- 		end
	-- 		return
	-- 	end 
	-- end
end

-----------------------------
--      登录相关
-----------------------------
function SDKController:login()
    -- yxsdkMgr:setIsYXLogin(false) --设置不是易信登录状态
    -- GlobalData.isLoginOut = false
    -- GlobalFun:showNetWorkConnect("请稍后...")
    -- return self.sdkObj:login()
end

function SDKController:checkToken()
--     SDKController.refresh_token = UserDefault:getKeyValue("REFRESH_TOKEN",nil);
--     if SDKController.refresh_token == nil or GlobalData.isLoginOut then
--         return false  
--     else
-- --        cclog(" ** ** 已授权 ** ** " .. SDKController.refresh_token);
-- --        GetTokenMore(SDKController.refresh_token);
--         LoginLogic:onStart()
--         return true
--     end
end

function OnSDKLoginComplete(res)
--     cclog(" LUA 登录回调 " .. res)
--     GlobalFun:closeNetWorkConnect()
--     local p = Util.split(res,",")
--     if p~= nil and #p >1 then
--         local code = p[1]
--         local token = p[2]
--         if code ~= "1" then
--             cclog("LUA 授权失败")
--             CCXNotifyCenter:notify("ShowWecharLoginBtn",true);
--             SDKController.showScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(t)  
--                     local token_msg = token or ""
--                     GlobalFun:showError("授权失败,请重新授权登录 err :1001   " .. res,nil,nil,1)
--                     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(SDKController.showScheduler)
--                     SDKController.showScheduler = nil
--             end,0.3,false)
--             return 
--         end

--         if token ~= nil  and token ~= "" then
--             CCXNotifyCenter:notify("ShowWecharLoginBtn",false);
--             local CODE = token 
-- --            local url = string.format("https://api.weixin.qq.com/sns/oauth2/access_token?appid=%s&secret=%s&code=%s&grant_type=authorization_code",SDKController.APPID , SDKController.Secret , CODE)
-- --            GlobalData.doAgainURL  = url 
-- --            Util.getJSONFromUrl(url,function(response , state , errspone) GetToken1(response , state, errspone) end,true)            
--             SDKController.auto_token = token      

--             cclog("请求登录。。。。。。。。。。。。。。。")  
--             LoginLogic:onStart()  
--         else
--             cclog("OnSDKLoginComplete no result");
--             CCXNotifyCenter:notify("ShowWecharLoginBtn",true);
--             SDKController.showScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(t)  
                    
--                     GlobalFun:showError("授权失败,请重新授权登录 err :1002",nil,nil,1)
--                     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(SDKController.showScheduler)
--                     SDKController.showScheduler = nil

--             end,0.3,false)
--         end

--     else
--         cclog("null token and code ")
--         CCXNotifyCenter:notify("ShowTipsMsg","CODE NULL")
--         CCXNotifyCenter:notify("ShowWecharLoginBtn",true);
--     end
end

function catResultCenter(response , startStr , endStr)

end

function DownloadCallBack(code , filename)
    -- cclog("callback ");
    -- if code == 1 then
    --     CCXNotifyCenter:notify("ICONdownloaded",filename)

    --     if filename == PlayerInfo.imghead then
    --         CCXNotifyCenter:notify("ShowIcon",nil)
    --     end
    --     --      local path = ex_fileMgr:getWritablePath().."/"..filename
    --     --      local isexit = ex_fileMgr:isFileExist(path);
    --     --      if isexit then
    --     --          cc.Director:getInstance():getTextureCache():reloadTexture(path);
    --     --          local sp = cc.Sprite:create(path);
    --     --          if sp ~= nil then
    --     --              cc.Director:getInstance():getRunningScene():addChild(sp);
    --     --          end
    --     --          return
    --     --      end
    --     --      cclog(filename .. " 文件不存在")
    -- else
    -- --        PlayerInfo.imghead = ""
    -- end
end


-----------------------------
--      支付相关
-----------------------------

function SDKController:pay(res)
    -- GlobalFun:showNetWorkConnect("请稍后...")

    -- local bool = self.sdkObj:pay(res)
    -- if bool == false then
    --     GlobalFun:closeNetWorkConnect()
    -- end
    -- return bool
end

--支付结果回调
function OnPayResultCallBack(res)
    -- cclog(" LUA 支付回调 " ..res)
    -- GlobalFun:closeNetWorkConnect()
    -- local p = Util.split(res,",")
    -- if p~= nil and #p > 1 then
    --     local code = p[1]
    --     local msg = p[2]
    --     if code ~= "1" then
    --         cclog("LUA 支付失败")
    --         return 
    --     end

    -- end

end

function SDKController:SetNotifyUrl(type)--3其他  2电信  1联通
    -- local url = GlobalFun:getYunIP() 
    -- if url ~= nil and url ~= "" then 
    --     local q = Util.split(url,".")
    --     if #q > 3 then
    --         local data = Util.split(url,",")-- 1,
    --         if #data < 2 then 
    --             url =  "http://" .. url .. ":8005/Charge_now"  
    --         else
    --             url = SDKController.OTYDNotifyUrl
    --         end 

    --     else
    --         if type == 1 then
    --             url = SDKController.LTNotifyUrl
    --         elseif type == 2 then
    --             url = SDKController.DXNotifyUrl
    --         else
    --             url = SDKController.OTYDNotifyUrl
    --         end
    --     end
    --     cclog(" .. YJur " .. url)
    --     local bool = self.sdkObj:SetNotifyUrl(url)
    --     if bool == false then
    --         cclog(" SET NOTIFYURL FALSE ");
    --         for i = 1 , 10 do
    --             cclog("pay url:",url)
    --             if self.sdkObj:SetNotifyUrl(url) then
    --                 return 
    --             end
    --         end
    --         GlobalFun:showError("NOTIFYURL 异常 2036",nil,nil,1)
    --     end
    -- end
end

function SDKController:getNotifyUrl(type)

    -- -- if true then
    -- --     return "http://120.76.233.100:10000/Charge_now" 
    -- --     -- return "http://yourui.imwork.net:51660/Charge_now" 
    -- -- end



    -- local url = GlobalFun:getYunIP();
    -- if url ~= nil and url ~= "" then 
    --     local q = Util.split(url,".")
    --     if #q > 3 then
    --         url =  "http://" .. url .. ":8005/Charge_now" 
    --         return url
    --     end
    -- end 

    -- if type == 1 then
    --     url = SDKController.LTNotifyUrl
    -- elseif type == 2 then
    --     url = SDKController.DXNotifyUrl
    -- else
    --     url = SDKController.OTYDNotifyUrl
    -- end

    -- return url
end




-------------------------------
--YUN
--0,err   0,NILVaule   1,cip
--0,errcode    1,cip
-------------------------------
function SDKController:getYUNbyGroupName(groupname)
--     local uuid = PlayerInfo.openid
--     if uuid == nil then
--         uuid = ""
--     end
--     return self.sdkObj:YUNbyGroupName(groupname ,uuid) -- 1,ip   0,errcode
    
-- --    local uuid = PlayerInfo.openid
-- --    if uuid == nil then
-- --    	uuid = ""
-- --    end
-- --    local str = self.sdkObj:YUNbyGroupName(groupname ,uuid) -- 1,ip   0,errcode
-- --    if str ~= "" and str ~= nil then
-- --        local data = Util.split(str,",")
-- --        if data ~= nil and #data == 2 then
-- --            local code = data[1] * 1 
-- --            if code == 1 then 
-- --                return data[2]
-- --            end
-- --            -- 获取IP 失败
-- --            --GlobalFun:showError("网络出现故障 " .. data[2],nil,nil,1) 
-- --        end
-- --        return ""
-- --    end
-- --    
-- --    GlobalFun:showError("网络出现故障 null",nil,nil,1)
-- --    return ""
end


------------------------------
--系统分享
------------------------------
function SDKController:MSGShare(msg)
    --return self.sdkObj:MSGShare(msg)
end

function SDKController:ImgShare(path)
    -- return self.sdkObj:ImgShare(path) 
end


------------------------------
--友盟
------------------------------
function SDKController:umengShareMsg(platform , msg)
    -- return self.sdkObj:umengShareMsg(platform , msg)
end

function SDKController:umengShareLocalImg(platform , sharepath , thumbpath)
    -- return self.sdkObj:umengShareLocalImg(platform , sharepath , thumbpath)
end

function SDKController:umengShareHttpUrl(platform , url , title , msg)
    -- return self.sdkObj:umengShareHttpUrl(platform , url , title , msg)
end

------------------------------------------------------------------
--    复制和黏贴 
--
--@msg 复制的文本 string
function SDKController:copy_To_Clipboard(msg)
    -- if msg == nil or msg == "" then 
    --     dump(" //// SDKController --JNI copy_To_Clipboard msg null ")
    --     return nil
    -- end 
    -- GlobalData.mCopy_msg = msg
    -- return self.sdkObj:copy_To_Clipboard(msg)
    platformExportMgr:copy_To_Clipboard(msg)
end

--@ return string or nil
function SDKController:parse_From_Clipboard()
    -- return self.sdkObj:parse_From_Clipboard()
    return platformExportMgr:parse_From_Clipboard()
end

------------------------------------------------------------------
--    GPS相关接口   
--直接调用会进行初始化
--@return string  例如： "经度,纬度"
function SDKController:get_GPS_Location()
    -- return self.sdkObj:get_GPS_Location()
end

-- @parame callfunc （function）
-- 设置 GPS 位置更新的回调事件（需要在关闭场景前调用 Stop_GPS ） 
function SDKController:set_GPS_Location_Callfunc(callfunc)
    -- self.sdkObj:set_GPS_Location_Callfunc(callfunc)
end

-- @parame show_tips （boolean） 是否 （弹出需要提示用户 开启定位）
-- @return boolean
-- 检查GPS 服务是否可用
function SDKController:get_GPS_Server_Status(show_tips)
    -- return self.sdkObj:get_GPS_Server_Status(show_tips)
end

-- 注册了 回调事件后在退出场景前需要调用 Stop_GPS 
function SDKController:Stop_GPS()
    -- self.sdkObj:Stop_GPS()
end

-------------------------------
--YUN
--0,err   0,NILVaule   1,cip
--0,errcode    1,cip
-------------------------------
function SDKController:getYUNbyGroupName(groupname)
    -- local uuid = PlayerInfo.openid
    -- if uuid == nil then
    --     uuid = ""
    -- end
    -- return self.sdkObj:YUNbyGroupName(groupname ,uuid) -- 1,ip   0,errcode
end

function SDKController:getYUNInfo_by_GroupName(groupname , errcallback)
    -- if groupname == nil or string.len(groupname) ==0 then 
    --     if errcallback then 
    --         errcallback("LUA_GROUP_NAME_NULL")
    --     end    
    --     return
    -- end    

    -- return self.sdkObj:getYUNInfo_by_GroupName(groupname)
end

------------------------------
--IMEI
------------------------------
function SDKController:GET_DEVICE_MIEI()
    --return self.sdkObj:GET_DEVICE_MIEI() or "xxxxxxxxx" 
end

-- 推送 拿设备ID
function SDKController:GET_DEVICE_ID()
    -- return self.sdkObj:GET_DEVICE_ID()
end 

--获取推送信息
function SDKController:getPushMsgJson()
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    local tb = {}

    if targetPlatform == cc.PLATFORM_OS_ANDROID or targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
        tb.deviceId = SDKController:getInstance():GET_DEVICE_ID()
    else
        tb.deviceId = ""
    end

    if targetPlatform == cc.PLATFORM_OS_ANDROID then --(1、安卓，2、IOS)
        tb.app = "hz_android_app"
    elseif targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD or targetPlatform == cc.PLATFORM_OS_MAC then
        tb.app = "hz_enterprise_app"
        --tb.app = "hz_appstore_app"
    end

    local json = json.encode(tb)
    cclog("push json:"..json)
    return json
end