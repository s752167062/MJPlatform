--@平台管理器
--@IOS /Android 相关系统接口
local PlatformMgr = class("PlatformMgr")

function PlatformMgr:ctor(params)
	
end



------------------------------------------------------------------
--	  录音	
--

--@开始录制音频
--@filename 		文件名 .amr		string
--@filedirectory 	文件目录			string
--@default_callback 回调				function
function PlatformMgr:startRecoder_audio(filename ,filedirectory ,default_callback , ismp3)
	if default_callback == nil then
		default_callback = function(result) dump(" //// PlatformMgr Recoder 默认回调" .. tostring(result)) end
	end	
	if filename == nil or filename == "" or filedirectory == nil or filedirectory == "" then 
		dump(" //// PlatformMgr Recoder filename filedirectory ".. tostring(filename) .. tostring(filedirectory))
		default_callback(false)
		return 
	end

	--
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = { filename , filedirectory , default_callback }
        local packName = "com/pro/game/tools/GameToolsLua"
        local JNI_FUN = "JNI_RecoderVideo_Start"
        if ismp3 == true then 
        	JNI_FUN = "JNI_LAMERecoderVideo_Start"
        end	
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,JNI_FUN,args,"(Ljava/lang/String;Ljava/lang/String;I)V")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI Recoder S 调用失败 ")
		end
	else
		if ismp3 and cpp_LAMEStartReocde then 
			cpp_LAMEStartReocde(filename , filedirectory ,default_callback)
		elseif cpp_StartReocde then 
			cpp_StartReocde(filename , filedirectory ,default_callback)
		else	
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_StartReocde cpp_LAMEStartReocdenull function")
		end	
	end

end


--@结束录制音频
--@default_callback 回调 	function
function PlatformMgr:endRecoder_audio(default_callback , ismp3)
	if default_callback == nil then
		default_callback = function(result) dump(" //// PlatformMgr Recoder 默认回调" .. tostring(result)) end
	end

	--
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = { default_callback }
        local packName = "com/pro/game/tools/GameToolsLua"
        local JNI_FUN = "JNI_RecoderVideo_End"
        if ismp3 then 
        	JNI_FUN = "JNI_LAMERecoderVideo_End"
        end	
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,JNI_FUN,args,"(I)V")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI Recoder END 调用失败 ")
		end
	else
		if ismp3 and cpp_LAMEEndReocde then 
			cpp_LAMEEndReocde(default_callback)
		elseif cpp_EndReocde then 
			cpp_EndReocde(default_callback)
		else	
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_EndReocde cpp_LAMEEndReocde null function")
		end	
	end
end


--@开始播放音频
--@filename 		文件名			string
--@filedirectory 	文件目录			string
--@default_callback 结束or出错时回调	function
function PlatformMgr:play_audio(filename ,filedirectory ,default_callback)
	if default_callback == nil then
		default_callback = function(result) dump(" //// PlatformMgr Recoder 默认回调" .. tostring(result)) end
	end

	--
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = { filename , filedirectory , default_callback }
        local packName = "com/pro/game/tools/GameToolsLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_PlayVideo",args,"(Ljava/lang/String;Ljava/lang/String;I)V")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI Play_audio  调用失败 ")
		end
	else
		if cpp_PlayVideo then 
			cpp_PlayVideo(filename , filedirectory ,default_callback)
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_PlayVideo null function")
		end	
	end
end

--@结束播放音频
function PlatformMgr:stop_audio()
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = {}
        local packName = "com/pro/game/tools/GameToolsLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_StopVideo",args,"()V")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI JNI_StopVideo  调用失败 ")
		end
	else
		if cpp_StopPlayVideo then 
			cpp_StopPlayVideo()
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_StopPlayVideo null function")
		end	
	end
end

--@平台用，IOS用于玩法中设置读写目录，录音优先查找这个目录
function PlatformMgr:setGameDirectory(directory)
	if type(directory) == "string" and directory ~= "" then 
		if gameConfMgr:getInfo("platform") == 2 then --(1、安卓，2、IOS)
			if cpp_setGameVideoDirectory then
				cpp_setGameVideoDirectory(directory)
			end 
		end	
	end 
end

------------------------------------------------------------------
--	  下载	
--

--@下载APK (android 用)
--@URL 				URL地址 		string
--@filename 		文件名  		string
--@default_callback 回调			function
function PlatformMgr:download_APK(URL ,filename ,default_callback)
	if default_callback == nil then
		default_callback = function(result) dump(" //// PlatformMgr download_APK 默认回调" .. tostring(result)) end
	end

	if URL == nil or URL == "" then 
		dump(" //// PlatformMgr --JNI download_APK URL null ")
		return 
	end	
	--
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = { URL , filename , default_callback }
        local packName = "com/pro/game/tools/GameToolsLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_DownloadAPK",args,"(Ljava/lang/String;Ljava/lang/String;I)V")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI download_APK  调用失败 ")
		end
	-- else
		-- cpp_openSafari(URL)
	end
end


------------------------------------------------------------------
--	  复制和黏贴	
--
--@msg 复制的文本 string
function PlatformMgr:copy_To_Clipboard(msg)
	if msg == nil or msg == "" then 
		dump(" //// PlatformMgr --JNI copy_To_Clipboard msg null ")
		return 
	end	
	--
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		gameConfMgr:setInfo("mCopy_msg", msg)
		local args = { msg }
        local packName = "com/pro/game/tools/GameToolsLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_CopyToClipboard",args,"(Ljava/lang/String;)V")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI copy_To_Clipboard  调用失败 ")
		end
	else
		if cpp_copyToSystem_Pasteboard then 
			cpp_copyToSystem_Pasteboard(msg)
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_copyToSystem_Pasteboard null function")
		end	
	end
end

--@ return string or nil
function PlatformMgr:parse_From_Clipboard()
	--
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = {}
        local packName = "com/pro/game/tools/GameToolsLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_GetClipboardText",args,"()Ljava/lang/String;")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI parse_From_Clipboard  调用失败 ")
			return nil
		end

		return bcak
	else
		if cpp_getTextFromSyetm_Pasteboard then 
			return cpp_getTextFromSyetm_Pasteboard() 
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_getTextFromSyetm_Pasteboard null function")
		end	
		return ""
	end
end


------------------------------------------------------------------
--	  游戏遁	
--
--@group_name 游戏遁组名 	（nil or "" 时使用默认组名） 	string
--@uuid		  用户ID	 	（可选参数）				   	string
--@port       服务器端口   							string
--@return  ip， port (正确下返回的 prot 不会是0 ) 
function PlatformMgr:get_yunIp_by_groupName(group_name , uuid, port)
	local result = nil 
	--
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = {group_name , uuid or "" , port or "80"}
        local packName = "com/pro/game/tools/GameToolsLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_GetYunIP",args,"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI getYunIP  调用失败 ")
			result = nil
		end

		result = bcak
	else
		if cpp_getYunIP then 
			result = cpp_getYunIP(group_name, uuid or "" , port or "80") 
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_getYunIP null function")
		end	
	end

	--返回结果处理 
	if result ~= nil then 
		local res_list = comFunMgr:split(result, ",")
		local status = tonumber(res_list[1])
		local msg 	 = res_list[2] or ""
		if status == 1 then 
			dump(" //// PlatformMgr -- YUN SUCCESS :".. msg or "")
			local ipport_list = comFunMgr:split(msg, ":")
			return ipport_list[1] ,tonumber(ipport_list[2] or 0) or 0 
		else
			--提示错误
			dump(" //// PlatformMgr -- YUN ERR ".. msg or "")
		end	
	else
		--调用失败，无结果返回
		dump(" //// PlatformMgr -- YUN 调用失败，无结果返回 ")
	end	

	return nil
end


--@group_name 游戏遁组名 	 string  没有组名时直接返回 nil
--@return string(ip) , number(city_num) ,number(net_num)    (ip ,city_num 城市编号,net_num 运营商编号)
--[[
	城市 和 运营商编号 映射的位置和运营商 如下
	
	yun_info_city = { "default",      "安徽",       "北京", 
                        "福建",           "甘肃",       "广东", 
                        "广西",           "贵州",       "海南", 
                        "河北",           "黑龙江",  "河南", 
                        "湖北",           "湖南",       "江苏", 
                        "江西",           "吉林",       "辽宁", 
                        "内蒙古",      "宁夏",       "青海", 
                        "陕西",           "山东",       "上海", 
                        "山西",           "四川",       "天津", 
                        "西藏",           "新疆",       "云南", 
                        "浙江",           "重庆",       "其他"    }

	yun_info_Operator = { "电信",  "联通", "移动", "其他", "教育"}

]]
-- function PlatformMgr:get_yunIp_INFO_by_groupName(group_name)
-- 	if group_name == nil or group_name== "" then
-- 		return nil
-- 	end
	
-- 	local result = nil 
-- 	--
-- 	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
-- 		local args = { group_name }
--         local packName = "com/pro/game/tools/GameToolsLua"
--         local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_GetYunIP_INFO",args,"(Ljava/lang/String;)Ljava/lang/String;")-- Ljava/lang/String;
-- 		if not status then 
-- 			dump(" //// PlatformMgr --JNI GetYunIP_INFO  调用失败 ")
-- 			result = nil
-- 		end

-- 		result = bcak
-- 	else
-- 		if cpp_getYunIP_INFO then 
-- 			result = cpp_getYunIP_INFO(group_name) 
-- 		else
-- 			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_getYunIP_INFO null function")
-- 		end	
-- 	end

-- 	--返回结果处理  数据格式为 1,127.0.0.1:7#8#
-- 	if result ~= nil then 
-- 		local res_list = comFunMgr:split(result, ",")
-- 		local status = tonumber(res_list[1])
-- 		local msg 	 = res_list[2] 
-- 		if status == 1 then 
-- 			dump(" //// PlatformMgr -- YUN SUCCESS :".. msg or "")
-- 			--拆分数据
-- 			local info_list = comFunMgr:split(msg, ":")
-- 			local ip_value 		= info_list[1] 
-- 			local ip_info_value = info_list[2] or ""

-- 			local city_net = comFunMgr:split(ip_info_value, "#")
-- 			local city = tonumber(city_net[1] or 0)
-- 			local net_ = tonumber(city_net[2] or 0)
-- 			return ip_value ,city , net_
-- 		else
-- 			--提示错误
-- 			dump(" //// PlatformMgr -- YUN ERR ".. msg or "")
-- 		end	
-- 	else
-- 		--调用失败，无结果返回
-- 		dump(" //// PlatformMgr -- YUN 调用失败，无结果返回 ")
-- 	end	

-- 	return nil
-- end

--@ip   www.aliyun.com /高防地址 / ip
--@port 端口 （www.aliyun.com:80）
--[[
	1,{ "NetType":"WIFI", 
		"LocalIP":"192.168.2.242", 
		"Gateway":"fe80:e::", 
		"DnsServers":[{"1":"192.168.2.1"}], 
		"Domain":"www.aliyun.com", 
		"RemoteIP":"140.205.32.8", 
		"TraceRoute":[{"1":"192.168.2.1", "Delay":28},{"2":"113.67.224.1", "Delay":59},{"3":"183.56.31.53", "Delay":73},{"4":"183.56.31.173", "Delay":144},{"5":"202.101.63.49", "Delay":530},{"6":"0.0.0.0", "Delay":99999},{"7":"0.0.0.0", "Delay":99999},{"8":"101.95.211.118", "Delay":429},{"9":"0.0.0.0", "Delay":99999},{"10":"0.0.0.0", "Delay":99999},{"11":"0.0.0.0", "Delay":99999}], 
		"TcpCheck":{"max":585, "min":432, "avg":523}, 
		"end":1 }
]]

--"TcpCheck":{"max":437, "min":325, "avg":369 注意这些值不是ms，是0.1ms 、"max":437 这个实际是 43.7ms
--"TraceRoute"  单位0.1ms
--@ return table  (table 属性如上)
function PlatformMgr:yunNetCheck(ip , port , callfunc)
	if ip == nil or port == nil  then 
		dump(" //// yunNetCheck ip or port can not be nil !!!")
		if callfunc then
			callfunc(nil)
		end	
		return 
	end	

	local default_callback = function( msg )
		release_print(" //// yunNetCheck  default_callback : ", msg)
		if msg then
			local status = string.sub(msg, 1, 1) 
			local result = string.sub(msg, 3, string.len(msg))

			release_print(" status ",status)
			release_print(" result ",result)

			if callfunc then
				if tonumber(status) == 1 then 
					callfunc(result)
				else
					callfunc(nil)
				end	
			end	
		end	
	end

	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = {ip , port , default_callback}
        local packName = "com/pro/game/tools/GameToolsLua"
        local status   = LuaJavaBridge.callStaticMethod(packName,"JNI_yunCheckNetStatu",args,"(Ljava/lang/String;Ljava/lang/String;I)V")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI yunNetCheck  调用失败 ")
		end
	else 
		if cpp_yunCheckNetStatus then
			cpp_yunCheckNetStatus( ip, port, default_callback)
		end	
	end
end




------------------------------------------------------------------
--	  获取设备电量	
--

--@return number
function PlatformMgr:get_Device_Power()
	--
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = {}
        local packName = "com/pro/game/tools/GameToolsLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_GET_Device_Power",args,"()I")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI JNI_GET_Device_Power  调用失败 ")
		end
		return bcak
	else 
		if cpp_getDevicePower then 
			return cpp_getDevicePower()
		else
			if gameConfMgr:getInfo("platform") == 2 then
				--print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_getDevicePower null function")
			end
		end	
		return 1
	end
end


------------------------------------------------------------------
--	  获取设备唯一编号	
--
-- @return string  
function PlatformMgr:get_Device_IMEI()
	--
	local default_ = "000000000_default_lua"
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = {}
        local packName = "com/pro/game/tools/GameToolsLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_GET_DEVICE_IMEI",args,"()Ljava/lang/String;")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI JNI_GET_Device_Power  调用失败 ")
		end
		return bcak or default_
	else
		if cpp_getDevice_IMEI then 
			return cpp_getDevice_IMEI() or default_
		else
			dump(" ///// PlatformMgr 平台类型 2 没有 （获取 IMEI 号）的相关方法  ------ 默认随机返回")
			return math.random(0,100000)
		end	
	end
end



------------------------------------------------------------------
--	  网络监听相关接口	
--
--[[
//网路状态
typedef enum NET_STATE{
    NETM_STATE_DISABLE  = 1000 ,
    NETM_STATE_WIFI     = 1001 ,
    NETM_STATE_MOBILE   = 1002 ,
    NETM_STATE_DEFAULT  = 1003 ,
    NETM_STATE_ETHERNE  = 1004 , //有线网络
}NET_STATE;


//网络类型
typedef enum NET_TYPE{
    NETM_TYPE_NULL   	= 10000 ,
    NETM_TYPE_2G     	= 10002 ,
    NETM_TYPE_3G     	= 10003 ,
    NETM_TYPE_4G     	= 10004 ,
    NETM_TYPE_WIFI   	= 10010 ,
    NETM_TYPE_DEFAULT	= 10011 ,
    NETM_TYPE_ETHERNET  = 10012 , //有线网络
}NET_TYPE;

]]

PlatformMgr.HanderBuff = {}
local net_default_callback = function( ... )
	dump(" //// PlatformMgr default callback " ,...)
	for k,func in pairs(PlatformMgr.HanderBuff) do
		print(" //// net_default_callback item : " , k , type(func))
		if func then
			func(...)
		end	
	end

end

--注册网络监听器
--@ callback function 网络变更时的通知
function PlatformMgr:register_NetWork_Listener()
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = { net_default_callback }
        local packName = "com/pro/game/tools/GameToolsLua"
        local status  = LuaJavaBridge.callStaticMethod(packName,"JNI_RegisterNetStatus",args,"(I)V")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI JNI_RegisterNetStatus  调用失败 ")
			--回调调用失败
			net_default_callback(0)
		end
		
	else
		if cpp_registerNetWorkListener then 
			cpp_registerNetWorkListener( net_default_callback ) 
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_registerNetWorkListener null function")
		end	
	end
end

function PlatformMgr:add_NetWork_ListenerBykey( key,callback )
	print(" /// 添加到buff")
	if callback ~= nil and key ~= nil then
		PlatformMgr.HanderBuff[key] = callback
	end 
end

function PlatformMgr:remove_NetWork_ListenerBykey(key)
	print(" /// 从buff删除")
	if key ~= nil then
		PlatformMgr.HanderBuff[key] = nil
	end
	print_r(PlatformMgr.HanderBuff)	
end

--移除网络监听器
function PlatformMgr:un_register_NetWork_Listener()
	--
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = {}
        local packName = "com/pro/game/tools/GameToolsLua"
        local status = LuaJavaBridge.callStaticMethod(packName,"JNI_UNRegisterNetStatus",args,"()V")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI JNI_UNRegisterNetStatus  调用失败 ")
		end
		
	else
		if cpp_unregisterNetWorkListener then 
			cpp_unregisterNetWorkListener() 
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_unregisterNetWorkListener null function")
		end
	end

	--删除原本的回调事件
	for key,func in pairs(PlatformMgr.HanderBuff) do
		PlatformMgr.HanderBuff[key] = nil
	end
end

--检查网络是否可用
--@ return boolean
function PlatformMgr:check_Net_enable()
	--
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = {}
        local packName = "com/pro/game/tools/GameToolsLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_GET_NetStatus",args,"()Z")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI JNI_GET_NetStatus  调用失败 ")
		end
		return bcak 
	else
		if cpp_isNetEnable then 
			return cpp_isNetEnable() 
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_isNetEnable null function")
		end
		return true
	end
end

--获取当前网络类型 
--@ return number （具体数值对应的类型 参照上面注释的 枚举）
function PlatformMgr:get_Net_type()
	local default_ = 0
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = {}
        local packName = "com/pro/game/tools/GameToolsLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_GET_NetType",args,"()I")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI JNI_GET_NetType  调用失败 ")
		end
		return bcak or default_
	else
		if cpp_getNetWorkType then 
			return cpp_getNetWorkType() or default_
		else
			-- print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_getNetWorkType null function")
		end
		return default_
	end
end


------------------------------------------------------------------
--	  GPS相关接口	
--	1. 

--直接调用会进行初始化
--@return string  例如： "经度,纬度"
function PlatformMgr:get_GPS_Location()
	local default_ = "-1,-1"
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = {}
        local packName = "com/pro/game/tools/GameToolsLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_Get_GPS_Location",args,"()Ljava/lang/String;")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI JNI_Get_GPS_Location  调用失败 ")
		end
		return bcak or default_
	else
		if cpp_getGPS_Location then 
			return cpp_getGPS_Location() or default_
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_getGPS_Location null function")
		end
		return default_
	end
end

-- @parame callfunc （function）
-- 设置 GPS 位置更新的回调事件（需要在关闭场景前调用 Stop_GPS ） 
function PlatformMgr:set_GPS_Location_Callfunc(callfunc)
	local default_callback = function( ... )
		dump(" //// PlatformMgr --GPS_Location_Callfunc  默认回调 ",...)
	end
	if callfunc ~= nil then 
		default_callback = callfunc
	end	

	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = { default_callback }
        local packName = "com/pro/game/tools/GameToolsLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_Register_GPS_Location_Callfunc",args,"(I)V")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI JNI_Register_GPS_Location_Callfunc  调用失败 ")
		end
	else
		if cpp_setGPS_Location_callfun then 
			return cpp_setGPS_Location_callfun(default_callback)
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_setGPS_Location_callfun null function")
		end
	end
end

-- @parame show_tips （boolean） 是否 （弹出需要提示用户 开启定位）
-- @return boolean
-- 检查GPS 服务是否可用
function PlatformMgr:get_GPS_Server_Status(show_tips)
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = { show_tips or false}
        local packName = "com/pro/game/tools/GameToolsLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_Get_GPS_Server_Status",args,"(Z)Z")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI JNI_Get_GPS_Server_Status  调用失败 ")
			return false;
		end
		return bcak
	else
		if cpp_getGPS_Server_Status then 
			return cpp_getGPS_Server_Status(show_tips or false)
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_getGPS_Server_Status null function")
		end
		return false
	end
end

-- 注册了 回调事件后在退出场景前需要调用 Stop_GPS 
function PlatformMgr:Stop_GPS()
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = {}
        local packName = "com/pro/game/tools/GameToolsLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_Stop_GPS",args,"()V")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI JNI_Stop_GPS  调用失败 ")
		end
	else
		if cpp_stop_GPS then 
			cpp_stop_GPS()
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_stop_GPS null function")
		end
	end
end

-- 打开手机设置 GPS 开关界面
function PlatformMgr:Show_APP_GPS_Setting()
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = {}
        local packName = "com/pro/game/tools/GameToolsLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_Show_APP_GPS_Setting",args,"()V")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI JNI_Show_APP_GPS_Setting  调用失败 ")
		end
	else
		if cpp_show_App_GPS_Setting then 
			cpp_show_App_GPS_Setting()
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_show_App_GPS_Setting null function")
		end
	end
end

-- 设置 AudioSession详解 Category选择
--[[
category
	1 : AVAudioSessionCategoryAmbient
	2 : AVAudioSessionCategoryPlayback
	3 : AVAudioSessionCategoryRecord
	4 : AVAudioSessionCategoryPlayAndRecord
	default : AVAudioSessionCategorySoloAmbient

mode
	1 : AVAudioSessionModeVoiceChat
	2 : AVAudioSessionModeMoviePlayback
	3 : AVAudioSessionModeMeasurement
	4 : AVAudioSessionModeVideoRecording
	default : AVAudioSessionModeDefault
]]
function PlatformMgr:setAVAudioSessionCategoryAndMode(category,mode)
	local mode_c = mode
	if type(mode) ~= "number" then
		mode_c = 0
	end	

	local category_c = category
	if type(category) ~= "number" then
		category_c = 0
	end	
	if gameConfMgr:getInfo("platform") == 2 then --(1、安卓，2、IOS)
		if cpp_setAVAudioSessionCategory then 
			cpp_setAVAudioSessionCategory(category_c ,mode_c)
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_setAVAudioSessionCategory null function")
		end	
	end
end

------------------------------------------------------------------
--	  打开手机浏览器
--
-- @ return boolean 
function PlatformMgr:open_APP_WebView(URL)
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = { URL }
    	local packName = "org/cocos2dx/lib/Cocos2dxHelper"
    	local status,bcak = LuaJavaBridge.callStaticMethod(packName,"openURL",args,"(Ljava/lang/String;)Z")
	    return status 
	else
		cpp_openSafari(URL)
		return true
	end
end


------------------------------------------------------------------
--	  安装apk	（android 用）
--
-- @ return boolean 
function PlatformMgr:install_APK_(apk_path)
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = { apk_path }
        local packName = "com/pro/game/tools/GameToolsLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_Install_APK_",args,"(Ljava/lang/String;)V")-- Ljava/lang/String;
		return status;
	else
		dump(" 仅android可用此函数 install_APK_")
	end
end


------------------------------------------------------------------
--	  苹果应用内支付 IAP (IOS 用)	
--[[
	在有支付的场景，进入场景时注册 register_IAP_Callback 处理苹果服务器下发的凭证
	在退出场景时 unRegister_IAP_Callback 关闭回调处理

	在支付凭证成功发给服务器后 调用 clean_IAP_Receipt 清除本地的凭证 （凭证没做永久性的存储）
]]


-- @ GOODSID  string  	商品id ： 需要在 itunes connect 后台配好
function PlatformMgr:IAP_PAY(GOODSID)
	if gameConfMgr:getInfo("platform") == 2 then --(1、安卓，2、IOS)
		if cpp_IAP_PAY then 
			cpp_IAP_PAY(GOODSID)
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_IAP_PAY null function")
		end
	else
		dump(" 仅IOS可用此函数 IAP_PAY ")
	end
end

-- @ CALLBACK function  支付回调函数
function PlatformMgr:register_IAP_Callback(callback)
	if gameConfMgr:getInfo("platform") == 2 then --(1、安卓，2、IOS)
		if cpp_register_IAP_Callback then 
			cpp_register_IAP_Callback(callback)
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_register_IAP_Callback null function")
		end
	else
		dump(" 仅IOS可用此函数 register_IAP_Callback ")
	end
end

function PlatformMgr:unRegister_IAP_Callback()
	if gameConfMgr:getInfo("platform") == 2 then --(1、安卓，2、IOS)
		if cpp_unRegister_IAP_Callback then 
			cpp_unRegister_IAP_Callback()
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_unRegister_IAP_Callback null function")
		end
	else
		dump(" 仅IOS可用此函数 unRegister_IAP_Callback")
	end
end

function PlatformMgr:clean_IAP_Receipt()
	if gameConfMgr:getInfo("platform") == 2 then --(1、安卓，2、IOS)
		if cpp_clean_IAP_receipt then 
			cpp_clean_IAP_receipt()
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_clean_IAP_receipt null function")
		end
	else
		dump(" 仅IOS可用此函数 clean_IAP_Receipt")
	end
end

--@ app 跳转 
--@ package_name string 包名 com.xxx.xxx
--@ ex_data      string 透传数据
function PlatformMgr:jump2App(package_name , ex_data)
	if gameConfMgr:getInfo("platform") == 2 then --(1、安卓，2、IOS)
		if cpp_jump2App then 
			local scheme = package_name or "" -- string.gsub(package_name or "", "%.", "") 
			return cpp_jump2App( scheme , ex_data or "")
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_jump2App null function")
			return false
		end
	elseif gameConfMgr:getInfo("platform") == 1 then
		local args = {package_name or "" , ex_data or ""}
        local packName = "com/pro/game/tools/GameToolsLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_Jump2App",args,"(Ljava/lang/String;Ljava/lang/String;)Z")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI JNI_Jump2App  调用失败 ")
			return false
		end
		return bcak
	end
end

--@ callfunc 被其他app 启动透传过来的参数 回调
function PlatformMgr:register_jumperCallback(callfunc)
	local default_callback = function( ... )
		dump(" //// PlatformMgr --register_jumperCallback   默认回调 ", ...)
	end
	if callfunc ~= nil then 
		default_callback = callfunc
	end	

	if gameConfMgr:getInfo("platform") == 2 then --(1、安卓，2、IOS)
		if cpp_register_JumperCallback then 
			cpp_register_JumperCallback(default_callback)
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// cpp_register_JumperCallback null function")
		end
	elseif gameConfMgr:getInfo("platform") == 1 then
		local args = { default_callback }
        local packName = "com/pro/game/tools/GameToolsLua"
--        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"JNI_Register_JumperCallfunc",args,"(I)V")-- Ljava/lang/String;
		-- if not status then 
		-- 	dump(" //// PlatformMgr --JNI JNI_Register_JumperCallfunc  调用失败 ")
		-- end
	end
end


--@ 推送相关
function PlatformMgr:get_Device_ID()
	if gameConfMgr:getInfo("platform") == 2 then --(1、安卓，2、IOS)
		if cpp_GET_DEVICE_ID then 
			return cpp_GET_DEVICE_ID() or ""
		else
			print("///////////////////////////////////////////////////\n/////////////////////////////////////////////////// get_Device_ID null function")
			return ""
		end
	elseif gameConfMgr:getInfo("platform") == 1 then
		local args = {}
        local packName = "com/pro/sdk/aliPush/AliPushMain"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"getDeviceId",args,"()Ljava/lang/String;")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI getDeviceId  调用失败 ")
			return ""
		end
		return bcak
	else
		return ""
	end
end

function PlatformMgr:getPushMsgJson()
	local tb = {}
	tb.deviceId = self:get_Device_ID()
	if gameConfMgr:getInfo("platform") == 2 then --(1、安卓，2、IOS) 修改时请注意是不是企业包是不是appstore的包
		local flag = ""
		if cpp_getXcode_Preprocessor_Macros then 
			flag = cpp_getXcode_Preprocessor_Macros()
		end

		if flag == "IPHONE_INHOUS" then
			tb.app = "hnmj_enterprise_app"  -- 企业
		else
			tb.app = "hnmj_appstore_app"  -- appstore
		end
	else
		tb.app = "hnmj_android_app"
	end	
	
	local json = json.encode(tb)
    print("//// PlatformMgr push json:", json)
    return json
end

--（仅限Android用）Jni调用前都检查下是否有函数, 没有检查接口默认返回是true，兼容无此接口旧包
function PlatformMgr:JNI_CheckMethod(package,method,args_parme)
	if Jni_CheckMethod ~= nil then 
		return Jni_CheckMethod(package,method,args_parme)
	else
		return false 
	end	
end

--（仅限Android用）上传文件
function PlatformMgr:JNI_UploadFile(url ,name,filedirectory , callback)
	if gameConfMgr:getInfo("platform") == 1 then
		local call = function( ... )
			dump("JNI_UploadFile default_callback " , ...)
		end
		local args = { url ,name,filedirectory , callback or call}
        local packName = "com/pro/game/tools/GameToolsLua"
        local status = LuaJavaBridge.callStaticMethod(packName,"JNI_UploadFile",args,"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")-- Ljava/lang/String;
		if not status then 
			dump(" //// PlatformMgr --JNI JNI_UploadFile  调用失败 ")
		end
	end	
end

------------------------------------------------------------------
--按钮KEY 
function Key_Event_Listener(event_keycode)
	dump(" //////////////// Key_Event_Listener " ..(event_keycode or "") )
	if event_keycode and event_keycode ~= "" then 
		local tb = comFunMgr:split(event_keycode, ":")
		if tb and #tb == 2 then 
			if tb[1] == "UP" and tb[2] == "4" then --DOWN
				dump(" /////// 点击了返回键 ///////")
				local function l_callbcak()
					os.exit(1)
				end
				eventMgr:dispatchEvent("CloseUIWebView",{}) -- 关闭webview
				msgMgr:closeAskMsg()
				msgMgr:showAskMsg("是否确定退出游戏",l_callbcak,nil, "确定", "取消")
			end	
		end	
	end	
end

------------------------------------------------------------------
-- APP 暂停
-- HOME 后台状态下收到此回调  （调用 applicationDidEnterBackground 的情况下也会调用 onGame_Paruse ）
function onGame_Paruse()
	dump(" //////////////// Game_Paruse ")
	gameConfMgr:writeAll()
	eventMgr:dispatchEvent("CloseUIWebView",{})
	platformExportMgr:dispathEvent(platformExportMgr.Events_AppPause)
end

function onGame_Resume()
	platformExportMgr:dispathEvent(platformExportMgr.Events_AppResume)
end

function applicationDidEnterBackground()
	dump(" //////////////// applicationDidEnterBackground ")
    eventMgr:dispatchEvent("CloseUIWebView",{})

    -- local state = gameState:getState()
    -- if state == GAMESTATE.STATE_ROOM then 
    -- 	local protocol = RuleMgr:getCurProtocol()
    -- 	if protocol and protocol.isEnterBackGround then 
    -- 		protocol:isEnterBackGround(false)
    -- 	end
    -- end

    platformExportMgr:dispathEvent(platformExportMgr.Events_DidEnterBackground)
end

function applicationWillEnterForeground()
	dump(" //////////////// applicationWillEnterForeground ")
	-- timerMgr:registerTask("replayAudio",timerMgr.TYPE_CALL_ONE, function() comFunMgr:replayAudio()	 end , 0.5)
	comFunMgr:replayAudio()

	-- local state = gameState:getState()-- 登录 、 平台大厅、 平台俱乐部 、游戏大厅、 游戏俱乐部、游戏中
	-- if state == GAMESTATE.STATE_COMMHALL then
	-- 	cclog(" >>> STATE_COMMHALL ")
	-- 	comFunMgr:checkEnterRoom()
	-- elseif state == GAMESTATE.STATE_CLUB then
	-- 	cclog(" >>> STATE_LOGIN ")
	-- 	comFunMgr:checkEnterRoom()
	-- end

	-- local state = gameState:getState()
    -- if state == GAMESTATE.STATE_ROOM then 
    	-- local protocol = RuleMgr:getCurProtocol()
    	-- if protocol and protocol.isEnterBackGround then 
    	-- 	protocol:isEnterBackGround(true)
    	-- end
    	-- eventMgr:dispatchEvent("applicationWillEnterForeground",{})
    -- end	
    platformExportMgr:dispathEvent(platformExportMgr.Events_WillEnterForeground)
end	

--手机来电时的状态
function phoneRingOn()
	onGame_Paruse()
end

function phoneRingOff()
	onGame_Resume()
end
return PlatformMgr


