--@协议分发管理类
--@Author 	liangpx
--@date 	2018/05/09
local HandlerManager = class("HandlerManager")

function HandlerManager:ctor(params)
	self._curHandler = nil
    self.updateHandlerFlag = false
    --默认大厅接收
    self._curHandler = ex_hallHandler
end

function HandlerManager:startConnect()
	-- body
	--开始连接
	ex_hallHandler:connectCheck()
end

--data: {serverID = serverID,isReConnect = isReConnect}
function HandlerManager:changeServerId(data)
    print_r(data, "hzmj changeServerId")
    local serverID = data.serverID
    local isReConnect = data.isReConnect or false

    self:changeHandler()
    if isReConnect then
        self._curHandler:connectCheck()
    end
end

--切换主接收对象
function HandlerManager:changeHandler()
    -- body
    print("hzmj changeHandler")
    local server_type = platformExportMgr:doGameNetMgr_getServerTypeByCurrent()
    cclog("HandlerManager:changeHandler >>>>", server_type)
    if server_type == platformExportMgr:getGlobalGameSeverType("hall")  then
        self._curHandler = ex_hallHandler
    elseif server_type == platformExportMgr:getGlobalGameSeverType("room") then
        self._curHandler = ex_roomHandler
    elseif server_type == platformExportMgr:getGlobalGameSeverType("club") then
        self._curHandler = ex_clubHandler
    end
end

--所有协议下行出口
function HandlerManager:receiveMsg(obj)
    local serverID = obj:getServerId() 
    local server_type = platformExportMgr:doGameNetMgr_getServerTypeByServerId(serverID)
    if server_type == platformExportMgr:getGlobalGameSeverType("hall")  then
        ex_hallHandler:receiveMsg(obj)
    elseif server_type == platformExportMgr:getGlobalGameSeverType("room") then
        ex_roomHandler:receiveMsg(obj)
    elseif server_type == platformExportMgr:getGlobalGameSeverType("club") then
        ex_clubHandler:receiveMsg(obj)
    end
end

return HandlerManager