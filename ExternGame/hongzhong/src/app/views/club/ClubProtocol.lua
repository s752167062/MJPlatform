--弃用

-- local Write = ex_fileMgr:loadLua("app.ctrls.socket.Write")
-- local ClubProtocol = class("ClubProtocol")

-- function ClubProtocol:ctor(_mgr)
--     self._clubMgr = _mgr
-- 	self:initProtocol()
-- end

-- function ClubProtocol:initProtocol()
-- 	self._proFuns = {}
	
-- 	-- 绑定协议号
--     self._proFuns[1405] = handler(self,self.onUserHideCards)
-- end

-- --===================================== 收 =======================================

-- --俱乐部信息 2000
-- function ClubProtocol:onClubInfo(obj)
-- 	local res = {}
	
-- 	eventMgr:dispatchEvent("onClubInfo", res)
-- end

--历史信息


--申请消息列表


--邀请消息


--邀请反馈


--申请消息反馈


--聊天


--游戏配置


--个人/群战绩


--系统消息

--===================================== 发 =======================================

--通用


--解散/退出俱乐部


--任命成员


--搜索成员


--添加/删除黑名单


--快速开房


--提交游戏设置


--查询历史消息


--操作反馈邀请消息