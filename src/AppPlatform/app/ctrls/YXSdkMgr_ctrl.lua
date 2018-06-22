--1. 易信授权回来后 服务器下发标识 （易信）是否新用户 ： true  调用微信授权   发送易信标识（成功） -》下发标识是否绑定成功  （成功）  -》 大厅 （显示易信的，id是微信的）
																											-- （绑定失败）-》易信数据进入大厅
														      -- （失败、取消） -》 用易信的数据进入大厅（显示易信的）
--@YXSDK管理器
--@Author 	sunfan
--@date 	2017/05/12
local YXSDKMgr = class("YXSDKMgr")

function YXSDKMgr:ctor(params)
	release_print("  ssssssssss  ")
	self:yxInit()
end

------------------------------------------------------------------
--	  易信	
--

YXSDKMgr.YXSecret = "";  -- 易信
YXSDKMgr.YXAPPID  = ""; 
YXSDKMgr.isyxlogin  = false; 
YXSDKMgr.auto_token = "" 
YXSDKMgr.YXuuid = ""
YXSDKMgr.isbingwechat = false
YXSDKMgr.account_id = ""

YXSDKMgr.LOGIN = 1001
YXSDKMgr.SHARE = 1002
local targetPlatform = cc.Application:getInstance():getTargetPlatform()

--@初始化易信内容
function YXSDKMgr:yxInit()
	local context = cc.FileUtils:getInstance():getStringFromFile("cocos/properties.txt")
	if context == nil or context == "" then
		release_print(" //// YXSDKMgr --- 初始化易信内容失败")
		return
	end	
	local as_x , as_y = string.find(context , "#START_YXAPPID:"  , 1, true)
	local ae_x , ae_y = string.find(context , ":END_YXAPPID#"  , 1, true)
	local ss_x , ss_y = string.find(context , "#START_YXSECRET:"  , 1, true)
	local se_x , se_y = string.find(context , ":END_YXSECRET#"  , 1, true)

	local appid  = string.sub(context, as_y  + 1, ae_x -1)
	local secret = string.sub(context, ss_y  + 1, se_x -1)

	release_print(" //// YXSDKMgr --- 初始化易信 APPID  " .. tostring(appid ))
	release_print(" //// YXSDKMgr --- 初始化易信 SECRET " .. tostring(secret))
	
	-- gameConfMgr:setInfo("appId" ,appid)
	-- gameConfMgr:setInfo("secret",secret)

	YXSDKMgr.YXSecret = secret 
	YXSDKMgr.YXAPPID  = appid
end

function YXSDKMgr:getYXAPPID()
	return YXSDKMgr.YXAPPID
end
function YXSDKMgr:getYXSecret()
	return YXSDKMgr.YXSecret
end
function YXSDKMgr:setIsYXLogin(bool)
	YXSDKMgr.isyxlogin = bool
	release_print(" -- yixin auto bool ", YXSDKMgr.isyxlogin , bool )
end
function YXSDKMgr:isYXLogin()
	return YXSDKMgr.isyxlogin
end
function YXSDKMgr:setYXAuto_token(auto_token)
	YXSDKMgr.auto_token = auto_token
end
function YXSDKMgr:getYXAuto_token()
	return YXSDKMgr.auto_token
end
function YXSDKMgr:setYXRefresh_token(refresh_token)
	YXSDKMgr.refresh_token = refresh_token
	--write to data
end
function YXSDKMgr:getYXRefresh_token()
	--read from data
	return YXSDKMgr.refresh_token
end
function YXSDKMgr:getYXuuid()
	--read from data
	return YXSDKMgr.YXuuid
end
function YXSDKMgr:setYXbindingWechat(bool)
	YXSDKMgr.isbingwechat = bool
end
function YXSDKMgr:isYXbindingWechat()
	return YXSDKMgr.isbingwechat
end
function YXSDKMgr:setYXID_ACCOUNT(id)
	YXSDKMgr.account_id = id or ""
end
function YXSDKMgr:getYXID_ACCOUNT()
	return YXSDKMgr.account_id
end	


--@易信的TXT 分享
--@share_type --( 1 盆友圈 、 0 易信好友)		number
--@return  boolean	调用结果
function YXSDKMgr:isYXClientExit() 
	if targetPlatform == cc.PLATFORM_OS_ANDROID then --(1、安卓，2、IOS)
		local args = {}
        local packName = "com/pro/sdk/yixin/YXSDKLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_YXClientExit",args,"()Z")-- Ljava/lang/String;
		if not status then 
			release_print(" //// YXSDKMgr --JNI Jni_YXClientExit 调用失败 ")
			return false;
		end
		return bcak;
	else
		return cpp_YXClientExit()
	end
end

--@启动SDK
--@callback SDK获取完毕后回调 	function
function YXSDKMgr:sdkStart(callback)
	release_print(" /////  wechat login ----- ")
	local function default_callback(result)
		release_print(" ////	UR default_callback " ,result )
		self:yxCall_(result , callback , YXSDKMgr.LOGIN)
	end

	if targetPlatform == cc.PLATFORM_OS_ANDROID then --(1、安卓，2、IOS)
		local args = { default_callback }
        local packName = "com/pro/sdk/yixin/YXSDKLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_YXLogin",args,"(I)V")-- Ljava/lang/String;
		if not status then 
			release_print(" //// YXSDKMgr --JNI LOGIN 调用失败 ")
		end	
	else
		cpp_YXLogin(default_callback)
	end	
end

--@易信的TXT 分享
--@share_type --( 1 盆友圈 、 0 易信好友)		number
--@return  boolean	调用结果
function YXSDKMgr:sdkTxtShare(msg, share_type) 
	if targetPlatform == cc.PLATFORM_OS_ANDROID then --(1、安卓，2、IOS)
		local args = { msg, tonumber(share_type) }
        local packName = "com/pro/sdk/yixin/YXSDKLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_YXTxtShare",args,"(Ljava/lang/String;I)Z")-- Ljava/lang/String;
		if not status then 
			release_print(" //// YXSDKMgr --JNI TXT SHARE 调用失败 ")
			return false;
		end
		return bcak;
	else
		return cpp_YXTxtShare(msg, tonumber(share_type) )
	end
end

--@易信的URL 分享
--@share_type --( 1 盆友圈 、 0 易信好友)		number
--@callback 易信分享回调						function
function YXSDKMgr:sdkUrlShare(title_ , desc_ , url_ , share_type_ ,callback) 
	release_print(" xxxxx  ///// ",title_ , desc_ , url_ , share_type_)
	local title	= title_ or "null_title"
	local desc	= desc_ or "null_desc"
	local url	= url_ or "null_url"
	local share_type = share_type_ or 0
	local function default_callback(result)
		self:yxCall_(result , callback , YXSDKMgr.SHARE)
	end	

	if targetPlatform == cc.PLATFORM_OS_ANDROID then --(1、安卓，2、IOS)
		local args = { title , desc , url , tonumber(share_type) , default_callback }
        local packName = "com/pro/sdk/yixin/YXSDKLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_YXUrlShare",args,"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;II)V")-- Ljava/lang/String;
		if not status then 
			release_print(" //// YXSDKMgr --JNI URL SHARE 调用失败 ")
		end
	else
		cpp_YXUrlShare(title , desc , url , tonumber(share_type) ,default_callback)
	end
end

--@易信的图片 分享
--@share_type --( 1 盆友圈 、 0 易信好友)		number
--@callback 易信分享回调						function
function YXSDKMgr:sdkImageShare(file_full_path , share_type , callback)
	local function default_callback(result)
		self:yxCall_(result , callback , YXSDKMgr.SHARE)
	end	

	if targetPlatform == cc.PLATFORM_OS_ANDROID then --(1、安卓，2、IOS)
		local args = { file_full_path , tonumber(share_type) , default_callback }
        local packName = "com/pro/sdk/yixin/YXSDKLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_YXImageShare",args,"(Ljava/lang/String;II)V")-- Ljava/lang/String;
		if not status then 
			release_print(" //// YXSDKMgr --JNI IMAGE SHARE 调用失败 ")
		end
	else
		cpp_YXImageShare(file_full_path , tonumber(share_type) , default_callback)
	end
end

--@易信的合图 分享
--@share_type --( 1 盆友圈 、 0 易信好友)		number
--@callback 易信分享回调						function
--@point_x	,point_y  				在图片上的位置,右上角开始为0,0	  			number		
--@size_width	,size_height  		希望绘制的大小							number
--@bg_file_full_path  , img1_full_path 		背景图的完整地址, 合图的完整地址  	string
function YXSDKMgr:sdkMergeImageShare(bg_file_full_path , img1_full_path , point_x , point_y , size_width , size_height , share_type , callback)
	local function default_callback(result)
		self:yxCall_(result , callback , YXSDKMgr.SHARE)
	end	

	if targetPlatform == cc.PLATFORM_OS_ANDROID then --(1、安卓，2、IOS)
		local args = { bg_file_full_path , img1_full_path , tonumber(point_x) , tonumber(point_y) , tonumber(size_width) , tonumber(size_height) , tonumber(share_type) , default_callback }
        local packName = "com/pro/sdk/yixin/YXSDKLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_YXMergeImageShare",args,"(Ljava/lang/String;Ljava/lang/String;IIIIII)V")-- Ljava/lang/String;
		if not status then 
			release_print(" //// YXSDKMgr --JNI MERGE IMAGE SHARE 调用失败 ")
		end
	else
		cpp_YXImageMergeShare(bg_file_full_path , img1_full_path , tonumber(point_x) , tonumber(point_y) , tonumber(size_width) , tonumber(size_height) , tonumber(share_type) , default_callback)
	end
end

--@通过JSON数据易信的合图 分享
--@JSON_STR 合图的json 数据 					string  例如：[{"size_h":200,"p_y":310,"data":"xxx/x/xxx1","p_x":310,"type":0,"size_w":100,"color_code":"#ff0000","font_size":30}]
--@share_type --( 1 盆友圈 、 0 易信好友)		number
--@callback 易信分享回调						function
--[[
	参考代码：
	local data = {}
    data[1] = {type = IMAGE_MERGE_TYPE.IMAGE , data = "xxx/x/xxx1" , p_x = 310 , p_y = 310 , size_w = 100 , size_h = 200 , font_size = 30 , color_code = "#ff0000"}
    data[2] = {type = IMAGE_MERGE_TYPE.IMAGE , data = "xxx/xx/xx2" , p_x = 320 , p_y = 320 , size_w = 100 , size_h = 200 , font_size = 30 , color_code = "#ff0000"}
    data[3] = {type = IMAGE_MERGE_TYPE.TXT   , data = "xxx/xx/xx2" , p_x = 320 , p_y = 320 , size_w = 100 , size_h = 200 , font_size = 30 , color_code = "#ff0000"}
    release_print("JSON DATA :" ,json.encode(data))
    YXSDKMgr:sdkMergeImageShareByJSON(json.encode(data) , YX_SHARE_TYPE.TIME_LINE ,nil)
]]
function YXSDKMgr:sdkMergeImageShareByJSON( JSON_STR , share_type ,callback)
	local function default_callback(result)
		self:yxCall_(result , callback , YXSDKMgr.SHARE)
	end	

	if targetPlatform == cc.PLATFORM_OS_ANDROID then --(1、安卓，2、IOS)
		local args = { JSON_STR or "", share_type or 10 , default_callback }
        local packName = "com/pro/sdk/yixin/YXSDKLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_YXMergeImageShareByJSON",args,"(Ljava/lang/String;II)V")-- Ljava/lang/String;
		if not status then 
			release_print(" //// YXSDKMgr --JNI JSON MERGE IMAGE SHARE 调用失败 ")
		end
	else
		cpp_YXImageMergeShareByJSON(JSON_STR or "" , tonumber(share_type) , default_callback)
	end
end

--@易信客户端是否存在
--@ return bool
-- function YXSDKMgr:isYXClientExit()
-- 	if targetPlatform == cc.PLATFORM_OS_ANDROID then --(1、安卓，2、IOS)
-- 		-- local args = { }
--         -- local packName = "com/pro/sdk/yixin/YXSDKLua"
--         -- local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_YXClientExit",args,"()Z")-- Ljava/lang/String;
-- 		-- if not status then 
-- 			-- release_print(" //// YXSDKMgr --JNI MERGE IMAGE SHARE 调用失败 ")
-- 		-- end
-- 		--android 下只返回true
-- 		return true
-- 	else
-- 		if cpp_YXClientExit then
-- 			release_print(" call wecaht exit --? ")
-- 			return cpp_YXClientExit()
-- 		else
-- 			return false
-- 		end	
-- 	end
-- end

--@易信统一回调处理	function
function YXSDKMgr:yxCall_(result , callback , CALL_TYPE)
	release_print(" //// YXSDKMgr yxCall_ " ,result , callback , CALL_TYPE)
	if result == nil or result == "" then 		
		release_print(" //// YXSDKMgr yxCall_  --没有内容 --不正常的回调")
		return
	end

	local res_list = Util.split(result, ",") --comFunMgr:split(result, ",")
	print_r(res_list)
	local status = tonumber(res_list[1])
	local msg 	 = res_list[2] 

	if status == 1 then --  success
		if CALL_TYPE == YXSDKMgr.LOGIN then 
			release_print(" //// CALL_TYPE LOGIN ", msg)
			-- gameConfMgr:setInfo("code" , msg) -- 保存授权的code
			yxsdkMgr:setYXAuto_token(msg)
		end
			
		if callback ~= nil then 
			callback(msg) 
		end  
	elseif status == 2 then  -- 0 failed , 2 user_cancel , -1 code_failed
		if CALL_TYPE == YXSDKMgr.LOGIN then 
			-- timerMgr:registerTask("screenshot_share",timerMgr.TYPE_CALL_ONE, function()	 eventMgr:dispatchEvent("USER_CANCEL_YX_LOGIN",nil)  end , 1)
			release_print("USER_CANCEL_YX_LOGIN")
		end	
	end	
end


------------------------------------------------------------------
--	  易信_现在支付	
--
-- @pay_json string 
-- @callback function
--[[
	示例
	json 中 extr_data 作为扩展参数， 没有需要的时候 extr_data="" 

	local data = { name ="房卡" , price =tostring(price), userdata =tostring(id) , server_time =tostring(time) , goodsid=tostring(goodsid) , notifyUrl="" ,extr_data="" }
	YXSDKMgr:sdkNowPay(json.encode(data) ,function(...)  end) 
]]
-- function YXSDKMgr:sdkNowPay(pay_json ,callback)
-- 	local default_callback = function( ... )
-- 		release_print(" //// YXSDKMgr default_callback   =========================== ",...)	
-- 		msgMgr:showMsg(msgMgr:getText("GET_FANGKA_TIPS", 3))
-- 	end
-- 	if callback and type(callback) == "function" then 
-- 		default_callback = callback
-- 	end	
-- 	release_print(" //// JSON ", pay_json)

-- 	if targetPlatform == cc.PLATFORM_OS_ANDROID then --(1、安卓，2、IOS)
-- 		local args = { pay_json , default_callback }
--         local packName = "com/pro/nowpay/NowPaySDKLua"
--         local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_NowPay",args,"(Ljava/lang/String;I)V")-- Ljava/lang/String;
-- 		if not status then 
-- 			release_print(" //// YXSDKMgr --JNI Jni_NowPay 调用失败 ")
-- 		end	
-- 	else
-- 		cpp_NowPay(pay_json , default_callback)
-- 	end	
-- end


return YXSDKMgr
