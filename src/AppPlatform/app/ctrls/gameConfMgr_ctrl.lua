--@游戏配置类
--@Author 	sunfan
--@date 	2017/04/27
local GameConfigMgr = class("GameConfigMgr")

function GameConfigMgr:ctor(params)
	self._writeObj = cc.UserDefault:getInstance()
	self:_init()
	self:_initWrite()
	self:_readInfo()
end

--统计所有需要序列化的字段
function GameConfigMgr:_initWrite()
	self._writes = 
	{	"refreshToken",
		"voiceEffect",
		"voiceValue",
		"FRISTGN",
		"lastLoginUserID",
	}
end

function GameConfigMgr:deleteValueForKey(key)
	-- body
	self._writeObj:deleteValueForKey(key)
end

--
function GameConfigMgr:setStringForKey(key, value)
	-- body
	self._writeObj:setStringForKey(key,value)
	dump(key.."="..value, "setStringForKey")
end

--需要本地序列化的信息(所有,游戏结束前序列化)
function GameConfigMgr:writeAll()
	for loop = 1,#self._writes do
		if self._writes[loop] and self._config[self._writes[loop]] then
			if type(self._writes[loop]) == "boolean" then
				if self._config[self._writes[loop]] then
					self:setStringForKey(self._writes[loop],"1")
				else
					self:setStringForKey(self._writes[loop],"0")
				end
			else
				self:setStringForKey(self._writes[loop],""..self._config[self._writes[loop]])
			end
		end
	end
	self._writeObj:flush()
end

--指定序列化某个信息(立即序列化)
function GameConfigMgr:writeOne(key)
	if not self._config[key] then
		return
	end
	for loop = 1,#self._writes do
		if self._writes[loop] then
			if self._writes[loop] == key then
				if type(self._writes[loop]) == "boolean" then
					if self._config[self._writes[loop]] then
						self:setStringForKey(self._writes[loop],"1")
					else
						self:setStringForKey(self._writes[loop],"0")
					end
				else
					self:setStringForKey(self._writes[loop],""..self._config[self._writes[loop]])
				end
			else
				self:setStringForKey(self._writes[loop],""..self._writeObj:getStringForKey(self._writes[loop]))
			end
		end
	end
	self._writeObj:flush()
end

--读取序列化过的字段
function GameConfigMgr:_readInfo()
	for loop = 1,#self._writes do
		if self._writes[loop] then
			local info = self._writeObj:getStringForKey(self._writes[loop])
			if info and info ~= "" then
				printInfo(self._writes[loop].." = "..info)
				if type(self._writes[loop]) == "boolean" then
					if tonumber(info) == 1 then
						self._config[self._writes[loop]] = true
					else
						self._config[self._writes[loop]] = false
					end
				elseif type(self._writes[loop]) == "number" then
					self._config[self._writes[loop]] = tonumber(info)
				else
					self._config[self._writes[loop]] = info
				end
			else
				dump("no exist info:"..self._writes[loop])
			end
		end
	end
end

function GameConfigMgr:_init()
	self._config = {}

	--送审标记
	self._config["distribution"] = false

	self._config["server_type"] = 2 -- 1审核服 其他 正式服 ( 暂时没用 ,而是使用 appstore_check 判断是否提审 )
	--是否自动登录
	self._config["autoLogin"] = true
	--是否使用微信登录
	self._config["isWX"] = true
	--游戏登陆服地址
	self._config["loginURL"] = {}
 --     注释勿删 免微信地址修改勿提交 
 --  	[1] = {name = "内部测试服",url = "http://120.76.220.130:18888/Login_youruiTest"},
 --  	[2] = {name = "吴达任",url = "http://192.168.1.99:8888/Login_youruiTest"},
 --		[3] = {name = "林争强",url = "http://192.168.1.251:18888/Login_youruiTest"},
 -- 	[4] = {name = "吴坚洪",url = "http://192.168.1.216:8888/Login_youruiTest"},
 --  	[5] = {name = "微信登陆服",url =  "http://120.76.220.130:18888/Login"},
 -- 	[6] = {name = "付谦",url =  "http://192.168.1.60:8888/Login_youruiTest"},
 --     [7] = {name = "陈志旺",url =  "http://192.168.1.177:8888/Login_youruiTest"},
 --		[8]	= {name = "李庆东",url = "http://192.168.1.230:8888/Login_youruiTest"},
    --免微信地址 
	-- self._config["loginURL"][0] = "http://192.168.1.251:8888/Login_youruiTest"
	self._config["loginURL"][0] = "http://120.78.255.24:8888/Login_youruiTest"
	-- 军海
	-- self._config["loginURL"][0] = "http://10.10.0.199:18888/Login_youruiTest"
	-- 军海(外网)
	-- self._config["loginURL"][0] = "http://ngrok.aikola.cn:18888/Login_youruiTest"
	--联通
	self._config["loginURL"][GAME_NET_LINE.LINE_LIANTONG] = "http://120.78.255.24:8888/Login"--"http://hnmj-login-l1.hongzhongmajiang.com:20001/Login"
	--电信
	self._config["loginURL"][GAME_NET_LINE.LINE_DIANXIN]  = "http://120.78.255.24:8888/Login"--"http://hnmj-login-l2.hongzhongmajiang.com:20001/Login"
	--移动
	self._config["loginURL"][GAME_NET_LINE.LINE_YIDONG]   = "http://120.78.255.24:8888/Login"--"http://hnmj-login-l3.hongzhongmajiang.com:20001/Login"
	--游戏当前平台(1、安卓，2、IOS)
	self._config["platform"] = cc.Application:getInstance():getTargetPlatform()
	--音效
	self._config["voiceEffect"] = 0.5
	--音量
	self._config["voiceValue"] = 0.5
	--玩家当前公网IP
	self._config["Ip"] = ""
	--玩家当前网络所属运营商(1、联通，2、电信，3、其他)
	self._config["netLine"] = GAME_NET_LINE.LINE_NO
	--当前用户所使用的登录线路(默认无线路)
	self._config["loginUseLine"] = GAME_NET_LINE.LINE_NO
	--当前用户所使用的IP线路(默认无线路)
	self._config["ipUseLine"] = GAME_NET_LINE.LINE_NO
	--是否使用游戏遁
	self._config["useYXD"] = false
	--当前渠道ID(默认为1)
	self._config["channelID"] = 1
	--微信公众号APPID
	self._config["appId"] = ""
	--微信登录参数secret
	self._config["secret"] = ""
	--微信登录参数code
	self._config["code"] = ""
	--微信登录参数refreshToken
	self._config["refreshToken"] = ""
	--信息是否加密
	self._config["encode"] = 1
	--分享地址
	self._config["shareUrl"] = ""
	--FRISTGN(阿里云SDK要用,游戏盾组名)
	self._config["FRISTGN"] = ""
	--录音时长
	self._config["soundRecodTime"] = 10

	self._config["soundRecodNextTime"] = 1
	self._config["soundRecodLameMp3"] = false
	--心跳输出
	self._config["heartLog"] = true
	--appstore支付
	self._config["IAPPay"] = false 
	self._config["appstore_check"] = false -- 是否提审
	-- H5 支付状态
	self._config["H5P_STATUS"] = false 
	self._config["H5P_URL"] = ""
	--支付回调地址
	self._config["pay_notifyUrl"] = ""
	--游戏遁组名
	self._config["gameyun_groupname"] = "qupai60.8hNPzJwB92.ftnormal01ah.com" -- ;first2.Odk2q169ji.aliyungf.com;first3.E9j5161G2i.aliyungf.com
	--游戏基础端口
	self._config["base_gamePort"] = "20001"
	--大厅类型
	self._config["hallType"] = "hallScene_view"
	--产品名称
	self._config["productName"] = ""
	self._config["productName"] = "hnmj"

	self._config["hostKey"] = ""
--@#####################玩家信息部分#####################
	--玩家唯一标识ID
	math.randomseed(os.time())
	self._config["userId"] = math.random(0,100000)
	--性别
	self._config["playerSex"] = ""
	--头像URL
	self._config["playerHeadURL"] = ""
	--头像图片名字
	self._config["playerHeadName"] = ""

	--跟userId一样的
	math.randomseed(os.time())
	self._config["account"] = math.random(0,100000)

	--这个是分销id
	self._config["accountId"] = ""

	--玩家昵称
	self._config["playerName"] = "Eternal Blue"
	--玩家房卡数量
	self._config["cards"] = "0"
	--玩家金币数量
	self._config["gold"] = "0"
	--城市
	self._config["city"] = "Guangzhou"
	--国家
	self._config["country"] = "China"
	--省份
	self._config["province"] = "Guangdong"
	--玩家显示ip
	self._config["playerIP"] = ""

--@#####################玩家信息部分#####################

--@######################跑得快######################
	self._config["UIMode"] = 0
--@######################跑得快#########################
	
	-- IP警报 GPS提醒功能
	self._config["IPSwitch"] = false
	self._config["GPSSwitch"] = false

	--调试用
	self._config["testUserName"] = ""
	self._config["tmpUserAccountID"] = 0
	self._config["lastLoginUserID"] = 0

	self._config["recentPlayId"] = 0
	self._config["recentPlayJson"] = ""
	self._config["mCopy_msg"] = ""

	--使用春节UI(大厅,俱乐部主界面)
	self._config["chunjieOpen"] = false

end

--获取当前大厅场景
function GameConfigMgr:getCurrentHallScene()
	return self._config["hallType"]
end

--获取登录地址
function GameConfigMgr:getLoginURL(line,isWX)
	if isWX then
		return self._config["loginURL"][line]
	else
		return self._config["loginURL"][0]
	end
end

--获取当前客户端版本
function GameConfigMgr:getVersion()
	return updateMgr:getCurVersion()
end

--获取渠道ID
function GameConfigMgr:getChannelID()
    local FILENAME = "channelFile.txt"
    if cc.FileUtils:getInstance():isFileExist(FILENAME) == true then
        local channelFile = cc.FileUtils:getInstance():fullPathForFilename(FILENAME)
        local data = cc.FileUtils:getInstance():getStringFromFile(channelFile)
        if data ~= nil and data ~= "" then 
            local list = Util.split(data,";")
            local channel = list[1]
            if channel ~= nil and channel ~= "" then
                self._config["channelID"] = channel
            end    
        end
    end
    return self._config["channelID"]
end

--获取信息
function GameConfigMgr:getInfo(key)
	--客户端版本要从manifest拿
	if key and key == "version" then
		return self:getVersion()
	end
	if key and key == "platform" then
		return self:_getPlatform()
	end
	return self._config[key]
end

function GameConfigMgr:getShowVersion()
	-- body
	local str = self:getVersion()
	if testConfig.TestMode ~= 0 then
        str = str.." test"
    end
	return str
end

function GameConfigMgr:_getPlatform()
--[[
	引擎平台枚举,索引0开始
    enum class Platform
    {
        OS_WINDOWS,/** Windows */
        OS_LINUX,/** Linux */
        OS_MAC,/** Mac*/
        OS_ANDROID,/** Android */
        OS_IPHONE,/** Iphone */
        OS_IPAD,/** Ipad */
        OS_BLACKBERRY,/** BLACKBERRY */
        OS_NACL,/** Nacl */
        OS_EMSCRIPTEN,/** Emscripten */
        OS_TIZEN,/** Tizen */
        OS_WINRT,/** Windows Store Applications */
        OS_WP8/** Windows Phone Applications */
    };
]]
	if self._config["platform"] == 3 then
		--安卓
		return 1
	elseif self._config["platform"] == 0 then
		--OS_WINDOWS
		return 0
	else
		--其余默认为IOS平台
		return 2
	end
end

--设置信息
function GameConfigMgr:setInfo(key,info)
	dump(info,"setInfo:"..key)
	self._config[key] = info
end

--清除所有信息
function GameConfigMgr:clearAll()
	self:_init()
end

--清除指定信息
function GameConfigMgr:clearOne(key)
	if self._config[key] then
		self._config[key] = nil
	end
end

--清除微信登录信息
function GameConfigMgr:clearWXCode()
	self._config["code"] = ""
	self._config["refreshToken"] = ""
end

--设置房间数据
function GameConfigMgr:setRoomData(data)
	self:setInfo("roomData",data)
end
--获取房间数据
function GameConfigMgr:getRoomData()
	return self._config["roomData"]
end

function GameConfigMgr:setLoginURL(INDEX , URL )
	self._config["loginURL"][INDEX] = URL
end

return GameConfigMgr
