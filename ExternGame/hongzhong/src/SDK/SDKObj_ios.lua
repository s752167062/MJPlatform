--ex_fileMgr:loadLua("SDK.Product")

SDKObj_ios = {}

function SDKObj_ios:init()

end


-----------------------------
--      分享相关
-----------------------------

--{ title , desc, url }
function SDKObj_ios:share(args)
    if args ~= nil and #args >2 then
        local title = args[1]
        local desc = args[2]
        local url = args[3]
        cpp_wecharShare("OnSDKShareComplete", title , desc, url)
        return true
    end
    return false
end

function SDKObj_ios:shareScreenShot(path)
    if path ~= nil then
        cpp_wecharShareScreenShot("OnShareScreenShotComp")
        return true
    end
    return false
end


-----------------------------
--      登录相关
-----------------------------
function SDKObj_ios:login()
    cpp_wecharLogin("OnSDKLoginComplete")
end


-----------------------------
--      支付相关
-----------------------------

-- { pid , userData , ip}
function SDKObj_ios:pay(args)
    if args ~= nil and #args > 1  then
        local pid = args[1]
        local userData = args[2]
        local ip = args[3]
        local item = Product[pid];
        local startTime = "" 
        if args[4] then 
            startTime = args[4] --服务器时间（可选参数）
        end 
        local notifyurl = args[5]
        
        local utfname = string.gsub(item.name, '&#(%d+);', Util.to_utf8 ) 
        cclog("Utf 8 name "..utfname)
        cpp_wecharPay("OnPayResultCallBack" , item.name , item.price , userData ,ip ,startTime ,item.goodsID ,notifyurl )  
        return true
    end
    return false
end

function SDKObj_ios:SetNotifyUrl(url)
    return cpp_setNotifyUrl(url)  
end


function SDKObj_ios:YUNbyGroupName(groupname , uuid)
    return cpp_getyunByGroupName(groupname ,uuid)
end


function SDKObj_ios:MSGShare(msg)
    cpp_AppShare(msg)
end

function SDKObj_ios:ImgShare(path)
	cpp_AppScreenShare()
end

-----------------------
--友盟

function SDKObj_ios:umengShareMsg(platform , msg)
    return cpp_UmengShareMsg(platform , msg)
end

function SDKObj_ios:umengShareLocalImg(platform , sharepath , thumbpath)
    return cpp_UmengShareLocalImg(platform)
end

function SDKObj_ios:umengShareHttpUrl(platform , url , title , msg)
    return cpp_UmengShareHttpUrl(platform , url , title , msg)
end


------------------------------------------------------------------
--    复制和黏贴 
--
--@msg 复制的文本 string
function SDKObj_ios:copy_To_Clipboard(msg)
    cpp_copyToSystem_Pasteboard(msg)
end

--@ return string or nil
function SDKObj_ios:parse_From_Clipboard()
    return cpp_getTextFromSyetm_Pasteboard()
end



function SDKObj_ios:YUNbyGroupName(groupname,uuid)
    return cpp_getyunByGroupName(groupname,uuid)
end

function SDKObj_ios:getYUNInfo_by_GroupName(groupname)
    return cpp_getYUNIPInfo_byGroup_name(groupname)
end

function SDKObj_ios:GET_DEVICE_MIEI()
    return cpp_GET_DEVICE_MIEI()
end

---------------------
--GPS

function SDKObj_ios:get_GPS_Location()
    cclog(" ********** SDKObj_ios:GetGPS_Location ******* ")
    local default_ = "-1,-1"
    if cpp_getGPS_Location then 
        return cpp_getGPS_Location() or default_
    else
        print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_getGPS_Location null function")
    end
    return default_
end


function SDKObj_ios:set_GPS_Location_Callfunc(callfunc)
    local default_callback = function( ... )
        dump(" //// SDKController --GPS_Location_Callfunc  默认回调 ",...)
    end

    if callfunc ~= nil then 
        default_callback = callfunc
    end 

    if cpp_setGPS_Location_callfun then 
        return cpp_setGPS_Location_callfun(default_callback)
    else
        print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_setGPS_Location_callfun null function")
    end
end

-- @parame show_tips （boolean） 是否 （弹出需要提示用户 开启定位）
-- @return boolean
-- 检查GPS 服务是否可用
function SDKObj_ios:get_GPS_Server_Status(show_tips)
    if cpp_getGPS_Server_Status then 
        return cpp_getGPS_Server_Status(show_tips or false)
    else
        print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_getGPS_Server_Status null function")
    end
    return false
end

-- 注册了 回调事件后在退出场景前需要调用 Stop_GPS 
function SDKObj_ios:Stop_GPS()
    if cpp_stop_GPS then 
        cpp_stop_GPS()
    else
        print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_stop_GPS null function")
    end
end

function SDKObj_ios:GET_DEVICE_ID()
    return cpp_GET_DEVICE_ID()
end 