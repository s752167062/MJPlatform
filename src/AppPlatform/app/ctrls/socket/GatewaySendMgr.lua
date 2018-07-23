
--网关协议发送（基本是网关偏向业务类）
local jdk = require("app.helper.dkjson")
local GatewaySendMgr = class("GatewaySendMgr")

function GatewaySendMgr:ctor()
end


--获取指定服务器类型产品的服务器id     {serverType, product}
function GatewaySendMgr:changePlatformOrGame(params)
	cclog(debug.traceback())

	
	
	local json_str = jdk.encode(params)
	cclog("GatewaySendMgr:changePlatformOrGame >>>", json_str)

	local obj = Write.new(30004)
	obj:writeString(json_str)
	obj:send()

end

--给玩家发消息
function GatewaySendMgr:sendMsgToPlayer(tab)
	
	if tab.game_enent_type == "respInviteJoinGroup" then  --邀请加入俱乐部消息发送
	elseif tab.game_enent_type == "reqInvteJoinRoom" then --邀请加入房间
	end


	local json_str = jdk.encode(tab)
	cclog("GatewaySendMgr:sendMsgToPlayer >>>", json_str)

	local obj = Write.new(30005)
	obj:writeString(json_str)
	obj:send()

end

--请求获取游戏版本，协议返回决定是否更新，是否请求进入游戏
-- 0-product   1-roomId
function GatewaySendMgr:sendCheckGotoGame(gtype, value)
	platformExportMgr:getEnterParams()  --正常进入游戏清掉进入参数，如果想进入参数生效，进入参数应设置在这个请求之后
	cclog("GatewaySendMgr:sendCheckGotoGame >>", gtype, value)

	local obj = Write.new(30006)
	obj:writeByte(gtype)
	if gtype == 0 then
		obj:writeString(value)
	elseif gtype == 1 then
		obj:writeInt(tonumber(value))
	end
	
	obj:send()

	-- msgMgr:showNetMsg("正在进入游戏。。。", "netJumpInfo")
end

--仅能在30006的返回调用
function GatewaySendMgr:sendGotoGame(product, version, roomId)
	cclog("GatewaySendMgr:sendGotoGame >>", product, version, roomId)

	local obj = Write.new(30007)
	obj:writeString(product)
	obj:writeString(version)
	obj:writeInt(roomId or 0)  --如果没有房间号，该值是0
	obj:send() 

end



return GatewaySendMgr









