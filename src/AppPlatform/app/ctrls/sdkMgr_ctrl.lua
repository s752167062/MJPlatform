--@SDK管理器
--@Author 	sunfan
--@date 	2017/05/12
local SDKMgr = class("SDKMgr")

function SDKMgr:ctor(params)
	self:wxInit()
end

------------------------------------------------------------------
--	  微信	
--

SDKMgr.LOGIN = 1001
SDKMgr.SHARE = 1002

--@初始化微信内容
function SDKMgr:wxInit()
	if gameConfMgr:getInfo("platform") == 0 then
		--WINDOWS平台不初始化
		return
	end
	local context = cc.FileUtils:getInstance():getStringFromFile(__platformHomeDir .."cocos/properties.txt")
	if context == nil or context == "" then
		dump(" //// SDKMgr --- 初始化微信内容失败")
		return
	end	

	local appid = ""
	local secret= ""
    print(" //// SDKMgr cpp_getXcode_Preprocessor_Macros ",cpp_getXcode_Preprocessor_Macros)
	if cpp_getXcode_Preprocessor_Macros and cpp_getXcode_Preprocessor_Macros() == "IPHONE_INHOUS" then 
		print("//// SDKMgr IPHONE_INHOUS")
		local as_x , as_y = string.find(context , "#START_WXAPPID_INHOUS:"  , 1, true)
		local ae_x , ae_y = string.find(context , ":END_WXAPPID_INHOUS#"  , 1, true)
		local ss_x , ss_y = string.find(context , "#START_WXSECRET_INHOUS:"  , 1, true)
		local se_x , se_y = string.find(context , ":END_WXSECRET_INHOUS#"  , 1, true)

		appid  = string.sub(context, as_y  + 1, ae_x -1)
		secret = string.sub(context, ss_y  + 1, se_x -1)
	else
		print("//// SDKMgr IPHONE_APP")
		local as_x , as_y = string.find(context , "#START_WXAPPID:"  , 1, true)
		local ae_x , ae_y = string.find(context , ":END_WXAPPID#"  , 1, true)
		local ss_x , ss_y = string.find(context , "#START_WXSECRET:"  , 1, true)
		local se_x , se_y = string.find(context , ":END_WXSECRET#"  , 1, true)

		appid  = string.sub(context, as_y  + 1, ae_x -1)
		secret = string.sub(context, ss_y  + 1, se_x -1)
	end	
	
	dump(" //// SDKMgr --- 初始化微信 APPID  " .. tostring(appid ))
	dump(" //// SDKMgr --- 初始化微信 SECRET " .. tostring(secret))
	
	gameConfMgr:setInfo("appId" ,appid)
	gameConfMgr:setInfo("secret",secret)
end

--@启动SDK
--@callback SDK获取完毕后回调 	function
function SDKMgr:sdkStart(callback)
	release_print(" /////  wechat login ----- ")
	local function default_callback(result)
		release_print(" ////	UR default_callback " ,result )
		self:wxCall_(result , callback , SDKMgr.LOGIN)
	end

	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = { default_callback }
        local packName = "com/pro/sdk/wechat/WeChatSDKLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_WeChatLogin",args,"(I)V")-- Ljava/lang/String;
		if not status then 
			dump(" //// SDKMgr --JNI LOGIN 调用失败 ")
		end	
	else
		cpp_WeChatLogin(default_callback)
	end	
end

--@微信的TXT 分享
--@share_type --( 1 盆友圈 、 0 微信好友)		number
--@return  boolean	调用结果
function SDKMgr:sdkTxtShare(msg, share_type) 
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = { msg, tonumber(share_type) }
        local packName = "com/pro/sdk/wechat/WeChatSDKLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_WeChatTxtShare",args,"(Ljava/lang/String;I)Z")-- Ljava/lang/String;
		if not status then 
			dump(" //// SDKMgr --JNI TXT SHARE 调用失败 ")
			return false;
		end
		return bcak;
	else
		return cpp_WeChatTxtShare(msg, tonumber(share_type) )
	end
end

--@微信的URL 分享
--@share_type --( 1 盆友圈 、 0 微信好友)		number
--@callback 微信分享回调						function
function SDKMgr:sdkUrlShare(title_ , desc_ , url_ , share_type_ ,callback) 
	release_print(" xxxxx  ///// ",title_ , desc_ , url_ , share_type_)
	local title	= title_ or "null_title"
	local desc	= desc_ or "null_desc"
	local url	= url_ or "null_url"
	local share_type = share_type_ or 0
	local function default_callback(result)
		self:wxCall_(result , callback , SDKMgr.SHARE)
	end	

	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = { title , desc , url , tonumber(share_type) , default_callback }
        local packName = "com/pro/sdk/wechat/WeChatSDKLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_WeChatUrlShare",args,"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;II)V")-- Ljava/lang/String;
		if not status then 
			dump(" //// SDKMgr --JNI URL SHARE 调用失败 ")
		end
	else
		if cpp_WeChatUrlShare then
			cpp_WeChatUrlShare(title , desc , url , tonumber(share_type) ,default_callback)
		end
	end
end

--@微信的图片 分享
--@share_type --( 1 盆友圈 、 0 微信好友)		number
--@callback 微信分享回调						function
function SDKMgr:sdkImageShare(file_full_path , share_type , callback)
	local function default_callback(result)
		self:wxCall_(result , callback , SDKMgr.SHARE)
	end	

	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = { file_full_path , tonumber(share_type) , default_callback }
        local packName = "com/pro/sdk/wechat/WeChatSDKLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_WeChatImageShare",args,"(Ljava/lang/String;II)V")-- Ljava/lang/String;
		if not status then 
			dump(" //// SDKMgr --JNI IMAGE SHARE 调用失败 ")
		end
	else
		if cpp_WeChatImageShare then 
			cpp_WeChatImageShare(file_full_path , tonumber(share_type) , default_callback)
		end
	end
end

--@微信的合图 分享
--@share_type --( 1 盆友圈 、 0 微信好友)		number
--@callback 微信分享回调						function
--@point_x	,point_y  				在图片上的位置,右上角开始为0,0	  			number		
--@size_width	,size_height  		希望绘制的大小							number
--@bg_file_full_path  , img1_full_path 		背景图的完整地址, 合图的完整地址  	string
function SDKMgr:sdkMergeImageShare(bg_file_full_path , img1_full_path , point_x , point_y , size_width , size_height , share_type , callback)
	local function default_callback(result)
		self:wxCall_(result , callback , SDKMgr.SHARE)
	end	

	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = { bg_file_full_path , img1_full_path , tonumber(point_x) , tonumber(point_y) , tonumber(size_width) , tonumber(size_height) , tonumber(share_type) , default_callback }
        local packName = "com/pro/sdk/wechat/WeChatSDKLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_WeChatMergeImageShare",args,"(Ljava/lang/String;Ljava/lang/String;IIIIII)V")-- Ljava/lang/String;
		if not status then 
			dump(" //// SDKMgr --JNI MERGE IMAGE SHARE 调用失败 ")
		end
	else
		cpp_WeChatImageMergeShare(bg_file_full_path , img1_full_path , tonumber(point_x) , tonumber(point_y) , tonumber(size_width) , tonumber(size_height) , tonumber(share_type) , default_callback)
	end
end

--@通过JSON数据微信的合图 分享
--@JSON_STR 合图的json 数据 					string  例如：[{"size_h":200,"p_y":310,"data":"xxx/x/xxx1","p_x":310,"type":0,"size_w":100,"color_code":"#ff0000","font_size":30}]
--@share_type --( 1 盆友圈 、 0 微信好友)		number
--@callback 微信分享回调						function
--[[
	参考代码：
	local data = {}
    data[1] = {type = IMAGE_MERGE_TYPE.IMAGE , data = "xxx/x/xxx1" , p_x = 310 , p_y = 310 , size_w = 100 , size_h = 200 , font_size = 30 , color_code = "#ff0000"}
    data[2] = {type = IMAGE_MERGE_TYPE.IMAGE , data = "xxx/xx/xx2" , p_x = 320 , p_y = 320 , size_w = 100 , size_h = 200 , font_size = 30 , color_code = "#ff0000"}
    data[3] = {type = IMAGE_MERGE_TYPE.TXT   , data = "xxx/xx/xx2" , p_x = 320 , p_y = 320 , size_w = 100 , size_h = 200 , font_size = 30 , color_code = "#ff0000"}
    release_print("JSON DATA :" ,json.encode(data))
    SDKMgr:sdkMergeImageShareByJSON(json.encode(data) , WX_SHARE_TYPE.TIME_LINE ,nil)
]]
function SDKMgr:sdkMergeImageShareByJSON( JSON_STR , share_type ,callback)
	local function default_callback(result)
		self:wxCall_(result , callback , SDKMgr.SHARE)
	end	

	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = { JSON_STR or "", share_type or 10 , default_callback }
        local packName = "com/pro/sdk/wechat/WeChatSDKLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_WeChatMergeImageShareByJSON",args,"(Ljava/lang/String;II)V")-- Ljava/lang/String;
		if not status then 
			dump(" //// SDKMgr --JNI JSON MERGE IMAGE SHARE 调用失败 ")
		end
	else
		cpp_WeChatImageMergeShareByJSON(JSON_STR or "" , tonumber(share_type) , default_callback)
	end
end

--@微信客户端分享小程序
--@share_data 分享信息的数据  table 例如: {"webUrl":"下载地址","path":"小程序的页面_后面可能不同玩法不同的页面","parament":"页面路径参数内容","title":"小程序卡片标题","desc":"小程序卡片描述的内容","image":"本地的图片地址", "mergeData":"jsonarray"}
--			  parament 页面路径参数内容 string 例如: ?msg={"roominfo":"asdasd","roomid":"22312","roomtime":"2017-01-01"}
--			  可选的 wx_miniBase 字段（小程序原始ID）检测没有的话 默认用本地的
--			  可选的 mergeData 字段 table (小卡片图片的合并) 没有的话就不操作
--[[
	使用实例：
	local data = {}
    data.webUrl = "www.douban.com"    --下载地址
    data.path = "pages/index/index"   --小程序的页面地址
    data.parament = "?msg={\"roominfo\":\"湖南麻将默认玩法—辣椒玩法\",\"roomOwnerid\":\"88888\",\"roomOwnername\":\"玩家名字七个字\",\"roomid\":\"654321\",\"roomtime\":\"2018-01-01 12:00:00\"}"
    data.title = "湖南麻将"
    data.desc  = "默认玩法—辣椒玩法"
    data.image = cc.FileUtils:getInstance():fullPathForFilename("ui/image/chat/beijingluyin.png") --需要全路径地址
    data.mergeData = {} --需要绘制到image的图片or文字 
    data.mergeData[1] = {type = IMAGE_MERGE_TYPE.IMAGE , data = cc.FileUtils:getInstance():fullPathForFilename("ui/image/chat/btn_yeqian_yuyin1.png") , p_x = 20 , p_y = 20 , size_w = 50 , size_h = 50 , font_size = 30 , color_code = "#ff0000"}
    data.mergeData[2] = {type = IMAGE_MERGE_TYPE.TXT   , data = "超级玩法" , p_x = 20 , p_y = 40 , size_w = 50 , size_h = 50 , font_size = 30 , color_code = "#ff0000"}
    SDKMgr:sdkShareMiniProject(data,nil)
]]
function SDKMgr:sdkShareMiniProject(share_data,callback)
	local function default_callback(result)
		self:wxCall_(result , callback , SDKMgr.SHARE)
	end	

 	if share_data == nil then 
 		dump(" //// SDKMgr -- 分享的数据空")
 		return
 	end	

 	if share_data.wx_miniBase == nil or share_data.wx_miniBase == "" then 
 		share_data.wx_miniBase = "gh_a11dc548cb9b"
 	end	
 	if share_data.mergeData == nil then 
 		share_data.mergeData = {}
 	end	

 	local json = require("app.helper.dkjson")
 	local strdata = json.encode(share_data)
 	 dump(" //// SDKMgr -- 数据:" , strdata)
 	if strdata ~= nil then 
 		if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
			local args = { strdata , default_callback }
	        local packName = "com/pro/sdk/wechat/WeChatSDKLua"
	        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_WeChatMiniProjectShareByJSON",args,"(Ljava/lang/String;I)V")-- Ljava/lang/String;
			if not status then 
				dump(" //// SDKMgr --JNI MINI PROJECT SHARE 调用失败 ")
			end
		elseif cpp_WeChatMiniProjectShare then 
			cpp_WeChatMiniProjectShare(strdata , default_callback)
		end
 	end	
 end 

--@微信小程序启动APP后传递的数据--正常只在大厅、俱乐部场景中调用就行
function SDKMgr:setWXLaunchCallBack( callback )
	local function default_callback(result)
		if callback then 
			callback(result)
		end	
	end	

	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = { default_callback }
        local packName = "com/pro/sdk/wechat/WeChatSDKLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_WeChatSetLaunchCallback",args,"(I)V")-- Ljava/lang/String;
		if not status then 
			dump(" //// SDKMgr --JNI SET LAUNCH CALLBACK 调用失败 ")
			return nil
		end
	elseif cpp_WeChatSetLaunchCallback then 
		return cpp_WeChatSetLaunchCallback(default_callback)
	end
end
 --@App启动检查是否有小程序过来的数据
 -- function SDKMgr:sdkCheckLaunchData()
 -- 	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
	-- 	local args = {}
 --        local packName = "com/pro/sdk/wechat/WeChatSDKLua"
 --        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_WeChatCheckLaunchData",args,"()Ljava/lang/String;")-- Ljava/lang/String;
	-- 	if not status then 
	-- 		dump(" //// SDKMgr --JNI CHECK LAUNCH DATA 调用失败 ")
	-- 		return nil
	-- 	end
	-- 	return bcak
	-- elseif cpp_WeChatCheckLaunchData then 
	-- 	return cpp_WeChatCheckLaunchData()
	-- end
	-- return nil
 -- end


 --@清除小程序过来的数据
 -- function SDKMgr:sdkCleanLaunchData()
 -- 	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
	-- 	local args = {}
 --        local packName = "com/pro/sdk/wechat/WeChatSDKLua"
 --        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_WeChatCleanLaunchData",args,"()V")-- Ljava/lang/String;
	-- 	if not status then 
	-- 		dump(" //// SDKMgr --JNI CHECK LAUNCH DATA 调用失败 ")
	-- 	end
	-- elseif cpp_WeChatCleanLaunchData then 
	-- 	cpp_WeChatCleanLaunchData()
	-- end

 -- end


--@微信客户端是否存在
--@ return bool
function SDKMgr:isWeChatClientExit()
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = { }
        local packName = "com/pro/sdk/wechat/WeChatSDKLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_WeChatClientExit",args,"()Z")-- Ljava/lang/String;
		if not status then 
			dump(" //// SDKMgr --JNI MERGE IMAGE SHARE 调用失败 ")
		end
		--android 下只返回true
		return bcak
	else
		if cpp_WeChatClientExit then
			dump(" call wecaht exit --? ")
			return cpp_WeChatClientExit()
		else
			return false
		end	
	end
end

function SDKMgr:checkWXAppExit()
	if SDKMgr:isWeChatClientExit() == false then 
		platformMgr:open_APP_WebView("https://weixin.qq.com")
		return false
	end	
	return true
end

--@微信统一回调处理	function
function SDKMgr:wxCall_(result , callback , CALL_TYPE)
	release_print(" //// SDKMgr wxCall_ " ,result , callback , CALL_TYPE)
	if result == nil or result == "" then 		
		dump(" //// SDKMgr wxCall_  --没有内容 --不正常的回调")
		return
	end

	local res_list = comFunMgr:split(result, ",")
	local status = tonumber(res_list[1])
	local msg 	 = res_list[2] 

	if status == 1 then --  success
		if CALL_TYPE == SDKMgr.LOGIN then 
			dump(" //// CALL_TYPE LOGIN ", msg)
			gameConfMgr:setInfo("code" , msg) -- 保存授权的code
		end
			
		if callback ~= nil then 
			callback(msg) 
		end  
	elseif status == 2 then  -- 0 failed , 2 user_cancel , -1 code_failed
		if CALL_TYPE == SDKMgr.LOGIN then 
			timerMgr:registerTask("screenshot_share",timerMgr.TYPE_CALL_ONE, function()	 eventMgr:dispatchEvent("USER_CANCEL_WX_LOGIN",nil)  end , 1)
		end	
	end	
end


------------------------------------------------------------------
--	  微信_现在支付	
--
-- @pay_json string 
-- @callback function
--[[
	示例
	json 中 extr_data 作为扩展参数， 没有需要的时候 extr_data="" 

	local data = { name ="房卡" , price =tostring(price), userdata =tostring(id) , server_time =tostring(time) , goodsid=tostring(goodsid) , notifyUrl="" ,extr_data="" }
	SDKMgr:sdkNowPay(json.encode(data) ,function(...)  end) 
]]
function SDKMgr:sdkNowPay(pay_json ,callback)
	local default_callback = function( ... )
		dump(" //// SDKMgr default_callback   =========================== ",...)	
		msgMgr:showMsg(msgMgr:getText("GET_FANGKA_TIPS", 3))
	end
	if callback and type(callback) == "function" then 
		default_callback = callback
	end	
	dump(" //// JSON ", pay_json)

	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = { pay_json , default_callback }
        local packName = "com/pro/nowpay/NowPaySDKLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_NowPay",args,"(Ljava/lang/String;I)V")-- Ljava/lang/String;
		if not status then 
			dump(" //// SDKMgr --JNI Jni_NowPay 调用失败 ")
		end	
	else
		cpp_NowPay(pay_json , default_callback)
	end	
end



--######## 钉钉 ########--
--@DD的URL 分享
--@callback 微信分享回调						function
function SDKMgr:ddsdkUrlShare(title_ , desc_ , url_ ,callback) 
	release_print(" xxxxx  ///// ",title_ , desc_ , url_ )
	local title	= title_ or "null_title"
	local desc	= desc_ or "null_desc"
	local url	= url_ or "null_url"
	local share_type =  0 --不用的
	local function default_callback(result)
		self:ddCall_(result , callback , SDKMgr.SHARE)
	end	

	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = { title , desc , url , tonumber(share_type) , default_callback }
        local packName = "com/pro/sdk/dd/DDSDKLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_DDUrlShare",args,"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;II)V")-- Ljava/lang/String;
		if not status then 
			dump(" //// SDKMgr --JNI DD URL SHARE 调用失败 ")
		end
	else
		cpp_DDUrlShare(title , desc , url , tonumber(share_type) ,default_callback)
	end
end

--@DD的图片 分享
--@callback 微信分享回调						function
function SDKMgr:ddsdkImageShare(file_full_path  , callback)
	local function default_callback(result)
		self:ddCall_(result , callback , SDKMgr.SHARE)
	end	

	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = { file_full_path , tonumber(share_type) , default_callback }
        local packName = "com/pro/sdk/dd/DDSDKLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_DDImageShare",args,"(Ljava/lang/String;II)V")-- Ljava/lang/String;
		if not status then 
			dump(" //// SDKMgr --JNI DD IMAGE SHARE 调用失败 ")
		end
	else
		cpp_DDImageShare(file_full_path , tonumber(share_type) , default_callback)
	end
end

--@DD统一回调处理	function
function SDKMgr:ddCall_(result , callback , CALL_TYPE)
	release_print(" //// SDKMgr ddCall_ " ,result , callback , CALL_TYPE)
	if result == nil or result == "" then 		
		dump(" //// SDKMgr ddCall_  --没有内容 --不正常的回调")
		return
	end

	local res_list = comFunMgr:split(result, ",")
	local status = tonumber(res_list[1])
	local msg 	 = res_list[2] 

	if status == 1 then --  success
		if callback ~= nil then 
			callback(msg) 
		end  
	elseif status == 2 then  -- 0 failed , 2 user_cancel , -1 code_failed
		
	else

	end	
end

function SDKMgr:ddClientExits()
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = {}
        local packName = "com/pro/sdk/dd/DDSDKLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_DDCheckInstall",args,"()Z")
		if not status then 
			dump(" //// SDKMgr --JNI DD IMAGE SHARE 调用失败 ")
			return false
		end

		return bcak
	else
		if cpp_DDClientExit then 
			return cpp_DDClientExit()
		end	
	end
end

function SDKMgr:ddApiSupport()
	if gameConfMgr:getInfo("platform") == 1 then --(1、安卓，2、IOS)
		local args = {}
        local packName = "com/pro/sdk/dd/DDSDKLua"
        local status , bcak = LuaJavaBridge.callStaticMethod(packName,"Jni_DDCheckSupport",args,"()Z")
		if not status then 
			dump(" //// SDKMgr --JNI DD IMAGE SHARE 调用失败 ")
			return false
		end

		return bcak
	else
		if cpp_DDSupport then 
			return cpp_DDSupport()
		end	
	end
end


return SDKMgr
