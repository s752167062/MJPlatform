--@socket管理类
--@Author 	sunfan
--@date 	2018/03/29
local SessionManager = class("SessionManager")
local GameSession = require("app.ctrls.socket.GameSession")
--网络轮询次数
local netRetryTimes = 5
--网络轮询CD
local netRetryCD = 2
function SessionManager:ctor(params)
    --接收回调
    self._handlerMgr = require("app.ctrls.socket.HandlerManager"):new()
	self._session = nil
    --初始化网络IP状态
    self:_initNetIPState()
    --重新轮询任务
    self._retryTask = nil
	timerMgr:register(self)
    platformMgr:register_NetWork_Listener()
    platformMgr:add_NetWork_ListenerBykey(self,handler(self,self._netChangeRefresh))
end

--网络刷新
function SessionManager:_netChangeRefresh(data)
    --只关注IOS
    if gameConfMgr:getInfo("platform") == 2 then
        data = tonumber(data)
        if data == 1000 or data == 1003 then--无网络
            LOG("NO NET")
            self:reConnectSocket()
        elseif data == 1001 then--wifi
            LOG("WIFI NET")
            self:reConnectSocket()
        elseif data == 1002 then--数据网络
            LOG("MOBILE NET")
            self:reConnectSocket()
        end
    end
end

function SessionManager:isSessionOpen()
    return self._session ~= nil
end

function SessionManager:reConnectSocket()
    if self._session and self._session:getNetState() == GAME_SOCKET_STATE.SOCKET_STATE_NORMAL then
        self._session:netReconnect()
    end
end

--清空网络IP状态
function SessionManager:_initNetIPState()
    --IP状态
    self._ipState = {}
end

function SessionManager:update(dt)
    --网络检查
    self:_checkNetState(dt)
    if self._session then
        self._session:update(dt)
    end
end

--打开网络会话
--网络标识
function SessionManager:sessionStart()
    --初始化网络IP,新的IP组进入
    if self:_setNetIPInfo() then
        local ipData = self:_getNextSocketData()
        if ipData then
            self:_openSession(ipData)
        else
            LOG("error,No IP Line")
        end
    end
end

--销毁会话
function SessionManager:destorySession()
    if self._session then
        self._session:netClose("Destory session")
    end
    self._session = nil
end

--创建一个网络会话
--@data 创建网络的参数
function SessionManager:_openSession(data)
	if self._session then
		self._session:netClose("Open session and destory pre session")
		self._session = nil
	end
    self._session = GameSession.new(data)
end


--设置创建网络的参数
function SessionManager:_setNetIPInfo()
    local ipArray = self._ipArray
    if ipArray then
        self._ipState = {}
        self._ipState.line = {}
        --联通
        if ipArray[GAME_NET_LINE.LINE_LIANTONG] then
            self._ipState.line[GAME_NET_LINE.LINE_LIANTONG] = {
            data = {
            --IP
            ip = ipArray[GAME_NET_LINE.LINE_LIANTONG].ip,
            --端口
            port = ipArray[GAME_NET_LINE.LINE_LIANTONG].port,
            --重试次数
            retryTimes = 0,
            --处理器
            handler = self._handlerMgr},
            --是否已经连接过
            hasConnect = false,
            --选择优先级，-1表示暂时不使用
            lv = 1}
        end
        --电信
        if ipArray[GAME_NET_LINE.LINE_DIANXIN] then
            self._ipState.line[GAME_NET_LINE.LINE_DIANXIN] = {
            data = {
            ip = ipArray[GAME_NET_LINE.LINE_DIANXIN].ip,
            port = ipArray[GAME_NET_LINE.LINE_DIANXIN].port,
            retryTimes = 0,
            handler = self._handlerMgr},
            hasConnect = false,
            lv = 1}
        end
        --移动
        if ipArray[GAME_NET_LINE.LINE_YIDONG] then
            self._ipState.line[GAME_NET_LINE.LINE_YIDONG] = {
            data = {
            ip = ipArray[GAME_NET_LINE.LINE_YIDONG].ip,
            port = ipArray[GAME_NET_LINE.LINE_YIDONG].port,
            retryTimes = 0,
            handler = self._handlerMgr},
            hasConnect = false,
            lv = -1}
        end
        --游戏遁
        if ipArray[GAME_NET_LINE.LINE_YOUXIDUN] and gameConfMgr:getInfo("useYXD") then
            local ip,port = gameNetMgr:getYunIP(ipArray[GAME_NET_LINE.LINE_YOUXIDUN].port)
            self._ipState.line[GAME_NET_LINE.LINE_YOUXIDUN] = {
            data = {
            ip = ip,
            port = port,
            retryTimes = 0,
            handler = self._handlerMgr},
            hasConnect = false,
            lv = 3}
        end
        --当前所选线路
        self._ipState._selectLine = GAME_NET_LINE.LINE_NO
        self._ipState._checkTimes = netRetryTimes
    else
        LOG("error,invalid socket IP Array")
        return false
    end
    return true
end

--重置线路选择状态
function SessionManager:resetLineSelectState()
    for k,v in pairs(self._ipState.line) do
        if self._ipState.line and self._ipState.line[k] and self._ipState.line[k].hasConnect then
            self._ipState.line[k].hasConnect = false
        end
    end
    self._ipState._selectLine = GAME_NET_LINE.LINE_NO
end

--重置线路重试次数
function SessionManager:resetLineRetryState()
    self._ipState._checkTimes = netRetryTimes
end

--重置线路状态
function SessionManager:resetLineState()
    self:resetLineSelectState()
    self:resetLineRetryState()
end

--获取创建网络的参数(选线规则)
function SessionManager:_getNextSocketData()
    if self._ipState then
        --设置当前运营商网络优先级
        local netLine = gameConfMgr:getInfo("netLine")
        for k,v in pairs(self._ipState.line) do
            if k == netLine then
                self._ipState.line[k].lv = 2
            end
        end
        --线路选择
        local selectIndex = nil
        for k,v in pairs(self._ipState.line) do
            if v and (not v.hasConnect) and v.lv >= 0 then
                if selectIndex then
                    if self._ipState.line[selectIndex].lv < v.lv then
                        selectIndex = k
                    end
                else
                    selectIndex = k
                end
            end
        end
        if selectIndex then
            --置为已经选择状态
            self._ipState.line[selectIndex].hasConnect = true
            --设置当前已选线路
            self._ipState._selectLine = selectIndex
            LOG("选择线路:"..selectIndex)
            local data = self._ipState.line[selectIndex].data
            if data and (data.ip == nil or data.port == nil) then
                LOG("线路数据出现问题(重选或者重新获取IP):"..selectIndex)
                if selectIndex == GAME_NET_LINE.LINE_YOUXIDUN then
                    local ipArray = self._ipArray
                    if ipArray then
                        local ip,port = gameNetMgr:getYunIP(ipArray[GAME_NET_LINE.LINE_YOUXIDUN].port)
                        if ip and port then
                            self._ipState.line[selectIndex].data.ip = ip
                            self._ipState.line[selectIndex].data.port = port
                            return self._ipState.line[selectIndex].data
                        else
                            return self:_getNextSocketData()
                        end
                    else
                        return self:_getNextSocketData()
                    end
                else
                    return self:_getNextSocketData()
                end
            end
            return data
        end
    end
    return nil
end

--网络状态检查
function SessionManager:_checkNetState(dt)
    --重连任务刷新
    self:_updateNetRetryTask(dt)
    --链接断开
    if self._session and self._session:getNetState() == GAME_SOCKET_STATE.SOCKET_STATE_CLOSED then
        --获取最终错误
        local theLastError = self:getTheLastError()
        if theLastError then
            theLastError = "("..theLastError..")"
        else
            theLastError = ""
        end
        self:destorySession()
        --网络失败处理函数
        local handleNetCallBack = nil
        --各状态处理
        if gameState:getState() == GAMESTATE.STATE_LOGIN then--当前是登录状态
            handleNetCallBack = function()
                self:_initNetIPState()
                --归还登录锁，用户可点击按钮再次登录
                singleMgr:unlock("login")
                --弹出提示
                msgMgr:showMsg(msgMgr:getMsg("JUMP_TO_HALL_FAIL_MSG")..theLastError)
            end
        else
            handleNetCallBack = function()
                msgMgr:showNetMsg(msgMgr:getMsg("RE_LOGING")..theLastError,"netReloginInfo")
                self:_initNetIPState()
                gameNetMgr:gameStart(true,true)
            end
        end
        local nextIP = self:_getNextSocketData()
        if nextIP then
            msgMgr:showNetMsg(msgMgr:getMsg("GAME_CHANGE_LINE"),"GAME_CHANGE_LINE")
            self:_openSession(nextIP)
        else
            if self._ipState._checkTimes > 0 then
                local taskCallBack = function ()
                    self._ipState._checkTimes = self._ipState._checkTimes - 1
                    self:resetLineSelectState()
                    nextIP = self:_getNextSocketData()
                    if nextIP then
                        self:_openSession(nextIP)
                    else
                        handleNetCallBack()
                    end
                end
                LOG("###########  Retry connect:"..self._ipState._checkTimes.."  ###########")
                self._retryTask = {cd = netRetryCD,callBack = taskCallBack}
            else
                handleNetCallBack()
            end
        end
    end
end

--重轮询优先处理顺序
function SessionManager:_updateNetRetryTask(dt)
    --房间重轮询任务
    if self._retryTask then
        self._retryTask.cd = self._retryTask.cd - dt
        if self._retryTask.cd <= 0 then
            self._retryTask.callBack()
            self._retryTask = nil
        end
        return
    end
end

function SessionManager:sendData(obj)
	local proid = obj:getProtocolId()
	if self._session then
		self._session:sendData(obj)
	end
end

function SessionManager:getTheLastError()
	if self._session and self._session.getTheLastError then 
		return self._session:getTheLastError()
	end
    return "null"
end

function SessionManager:registReceiveHandler(handler)
    if self._handlerMgr then
        self._handlerMgr:registReceiveHandler(handler)
    end
end

function SessionManager:removeReceiveHandler()
    if self._handlerMgr then
        self._handlerMgr:removeReceiveHandler()
    end
end

--设置IP和端口
--@data       IP和端口组
function SessionManager:setHostIPAndPort(data)
    if not data then
        return
    end
    self._ipArray = {}
    local netIpArray = comFunMgr:split(data,";")
    for loop = 1,#netIpArray do
        if netIpArray[loop] then
            local ipAndPort = comFunMgr:split(netIpArray[loop],":")
            LOG("IP组:"..netIpArray[loop])
            if ipAndPort and #ipAndPort >= 2 then
                self._ipArray[loop] = {ip = ipAndPort[1],port = ipAndPort[2]}
            end
        end
    end
end

return SessionManager