--ex_fileMgr:loadLua("SDK.Product")

SDKObj_android = {}

function SDKObj_android:init()

end


-----------------------------
--      分享相关
-----------------------------
function SDKObj_android:share(res)
    -- if res ~= nil and #res >2 then
    -- 	local title = res[1] 
    -- 	local desc = res[2]
    -- 	local url = res[3]
    	
    --     local args = {"OnSDKShareComplete" , title , desc , url}
    --     local packName = "pro/wechar/sdk/SDKControler"
    --     local a,b = LuaJavaBridge.callStaticMethod(packName,"share",args,"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z")
    --     if a == true and b ~= nil then
    --         return b
    --     end
    -- end
    return false
end

function SDKObj_android:shareScreenShot(path)
	-- if path ~= nil then
 --        local args = {"OnShareScreenShotComp" , path }
 --        local packName = "pro/wechar/sdk/SDKControler"
 --        local a,b = LuaJavaBridge.callStaticMethod(packName,"shareScreenShot",args,"(Ljava/lang/String;Ljava/lang/String;)Z")
 --        if a == true and b ~= nil then
 --            return b
 --        end
	-- end
	return false
end

-----------------------------
--      登录相关
-----------------------------

function SDKObj_android:login()
    -- local args = {"OnSDKLoginComplete"}
    -- local packName = "pro/wechar/sdk/SDKControler"
    -- local a,b = LuaJavaBridge.callStaticMethod(packName,"login",args,"(Ljava/lang/String;)Z")
    -- if a == true and b ~= nil then
    --     return b
    -- end
    return false
end

-----------------------------
--      支付相关
-----------------------------
-- { pid , userData , ip}
function SDKObj_android:pay(res)
    -- if res ~= nil and #res >1 then
    --     local pid = res[1]
    --     local userData = res[2]
    --     local ip = res[3]
    --     local item = Product[pid]
    --     local startTime = "" 
    --     if res[4] then 
    --         startTime = res[4] --服务器时间（可选参数）
    --     end    
        
    --     local notifyurl = res[5]

    --     local args = {"OnPayResultCallBack" , item.name , item.price , userData , ip  ,startTime , item.goodsID , notifyurl}
    --     local packName = "pro/wechar/sdk/SDKControler"
    --     local a,b = LuaJavaBridge.callStaticMethod(packName,"pay",args,"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z")
    --     if a == true and b ~= nil then
    --         return b
    --     end
    -- end
    return false
end

function SDKObj_android:SetNotifyUrl(url)
    -- local args = { url }
    -- local packName = "pro/wechar/sdk/SDKControler"
    -- local a , b  = LuaJavaBridge.callStaticMethod(packName,"setNotifyUrl",args,"(Ljava/lang/String;)Z")
    -- if a == true and b ~= nil then
    --     return b
    -- end
    return false
end


function SDKObj_android:YUNbyGroupName(groupname ,uuid)
    -- local args = { groupname ,uuid }
    -- local packName = "pro/yun/sdk/YunCengControl"
    -- local bool , str =  LuaJavaBridge.callStaticMethod(packName,"getYUNByGroupName",args,"(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;") -- 别忘了 ;
    -- if bool and type(str) == "string" then
    --     return str
    -- else
    --     GlobalFun:showError("网络出现故障 False",nil,nil,1)
    -- end 
end


function SDKObj_android:MSGShare(msg)
    -- local args = {msg }
    -- local packName = "org/cocos2dx/util/AppGameShare"
    -- LuaJavaBridge.callStaticMethod(packName,"CallMagShare",args,"(Ljava/lang/String;)V")
end

function SDKObj_android:ImgShare(path)
    -- local args = {path }
    -- local packName = "org/cocos2dx/util/AppGameShare"
    -- LuaJavaBridge.callStaticMethod(packName,"CallImgShare",args,"(Ljava/lang/String;)V")
end

---------------------
--Umeng

function SDKObj_android:umengShareMsg(platform , msg)
    -- local args = { platform , msg }
    -- local packName = "pro/umeng/sdk/UmengControl"
    -- LuaJavaBridge.callStaticMethod(packName,"UmengShareMsg",args,"(Ljava/lang/String;Ljava/lang/String;)V")
end

function SDKObj_android:umengShareLocalImg(platform , sharepath , thumbpath)
    -- local args = { platform , sharepath , thumbpath }
    -- local packName = "pro/umeng/sdk/UmengControl"
    -- LuaJavaBridge.callStaticMethod(packName,"UmengShareLocalImg",args,"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end

function SDKObj_android:umengShareHttpUrl(platform , url , title , msg)
    -- local args = { platform , url , title , msg }
    -- local packName = "pro/umeng/sdk/UmengControl"
    -- LuaJavaBridge.callStaticMethod(packName,"UmengShareHTTPUrl",args,"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end


------------------------------------------------------------------
--    复制和黏贴 
--
--@msg 复制的文本 string
function SDKObj_android:copy_To_Clipboard(msg)
    -- local args = { msg }
    -- local packName = "org/cocos2dx/util/GameToolsController"--"com/pro/game/tools/GameToolsLua"
    -- local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_CopyToClipboard",args,"(Ljava/lang/String;)V")-- Ljava/lang/String;
    -- if not status then 
    --     dump(" //// SDKObj_android --JNI copy_To_Clipboard  调用失败 ")
    -- end
end

--@ return string or nil
function SDKObj_android:parse_From_Clipboard()
    -- local args = {}
    -- local packName = "org/cocos2dx/util/GameToolsController"--"com/pro/game/tools/GameToolsLua"
    -- local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_GetClipboardText",args,"()Ljava/lang/String;")-- Ljava/lang/String;
    -- if not status then 
    --     dump(" //// SDKObj_android --JNI parse_From_Clipboard  调用失败 ")
    --     return nil
    -- end

    -- return bcak
end

function SDKObj_android:YUNbyGroupName(groupname ,uuid)
    -- local args = { groupname ,uuid }
    -- local packName = "pro/yun/sdk/YunCengControl"
    -- local bool , str =  LuaJavaBridge.callStaticMethod(packName,"getYUNByGroupName",args,"(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;") -- 别忘了 ;
    -- if bool and type(str) == "string" then
    --     return str
    -- else
    --     GlobalFun:showError("网络出现故障 False",nil,nil,1)
    -- end 
end

function SDKObj_android:getYUNInfo_by_GroupName(groupname)
    -- local args = { groupname }
    -- local packName = "pro/yun/sdk/YunCengControl"
    -- local bool , str =  LuaJavaBridge.callStaticMethod(packName,"getYUNIP_Info_byGroupName",args,"(Ljava/lang/String;)Ljava/lang/String;") -- 别忘了 ;
    -- if bool and type(str) == "string" then
    --     return str
    -- else
    --     GlobalFun:showError("YUN 网络出现故障 False",nil,nil,1)
    -- end 
end

function SDKObj_android:GET_DEVICE_MIEI()
    -- local args = {}
    -- local packName = "org/cocos2dx/util/GameToolsController"--"com/pro/game/tools/GameToolsLua"
    -- local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_Get_DEVICE_MIEI",args,"()Ljava/lang/String;")-- Ljava/lang/String;
    -- if not status then 
    --     dump(" //// SDKObj_android --JNI GET_DEVICE_MIEI  调用失败 ")
    --     return nil
    -- end

    -- return bcak
end

----------------------
--GPS

function SDKObj_android:get_GPS_Location()
    cclog(" ********** SDKObj_android:GetGPS_Location ******* ")
    local default_ = "-1,-1"
    -- local args = {}
    -- local packName = "org/cocos2dx/util/GPSController"
    -- local status , bcak = LuaJavaBridge.callStaticMethod(packName,"getGPSLocation",args,"()Ljava/lang/String;")-- Ljava/lang/String;
    -- if not status then 
    --     dump(" //// SDKController --JNI getGPSLocation  调用失败 ")
    -- end
    return bcak or default_
end


function SDKObj_android:set_GPS_Location_Callfunc(callfunc)
    -- local default_callback = function( ... )
    --     dump(" //// SDKController --GPS_Location_Callfunc  默认回调 ",...)
    -- end

    -- if callfunc ~= nil then 
    --     default_callback = callfunc
    -- end 

    -- local args = { default_callback }
    -- local packName = "org/cocos2dx/util/GPSController"
    -- local status , bcak = LuaJavaBridge.callStaticMethod(packName,"setCallFunc",args,"(I)V")-- Ljava/lang/String;
    -- if not status then 
    --     dump(" //// SDKController --JNI setCallFunc  调用失败 ")
    -- end
end

-- @parame show_tips （boolean） 是否 （弹出需要提示用户 开启定位）
-- @return boolean
-- 检查GPS 服务是否可用
function SDKObj_android:get_GPS_Server_Status(show_tips)
    -- local args = {show_tips}
    -- local packName = "org/cocos2dx/util/GPSController"
    -- local status , bcak = LuaJavaBridge.callStaticMethod(packName,"getGps_status",args,"(Z)Z")-- Ljava/lang/String;
    -- if not status then 
    --     dump(" //// SDKController --JNI JNI_Get_GPS_Server_Status  调用失败 ")
    --     return false;
    -- end
    -- return bcak
end

-- 注册了 回调事件后在退出场景前需要调用 Stop_GPS 
function SDKObj_android:Stop_GPS()
    -- local args = {}
    -- local packName = "org/cocos2dx/util/GPSController"
    -- local status , bcak = LuaJavaBridge.callStaticMethod(packName,"stopGps",args,"()V")-- Ljava/lang/String;
    -- if not status then 
    --     dump(" //// SDKController --JNI stopGps  调用失败 ")
    -- end
end

function SDKObj_android:GET_DEVICE_ID()
    -- local args = {}
    -- local packName = "pro/aliPush/sdk/AliPushMain"
    -- local a,b = LuaJavaBridge.callStaticMethod(packName,"getDeviceId",args,"()Ljava/lang/String;")
    -- if a and b ~= nil then 
    --     return b
    -- end     
    return "";--error
end 