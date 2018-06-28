LogController = {}
LogController.funs = {}

function LogController.sendLog(str)
    -- if true then
    --     return
    -- end
    -- if GlobalData.roomID == 0 then
    --     return
    -- end
    -- if LogClient.server == nil then
    --     LogClient:open(GlobalData.roomIP,GlobalData.roomPort)
    -- end
    -- if LogClient.server then
    --     local obj = cpp_buff_create() 
    --     cpp_buff_writeSerialNumAndProtocol(obj,GameClient.server.sid,1038)
    --     obj:writeInt(GlobalData.roomID)
    --     obj:writeLong(PlayerInfo.playerUserID)
    --     obj:writeString(str)
    --     
    --     cpp_net_send(LogClient.server.sid,obj)
    -- end
end

function LogController.onSendLog(obj)
    -- local res = {}
    -- CCXNotifyCenter:notify("onSendLog",res)
end

function LogController.heartBeat()--心跳
    -- if true then
    --     return
    -- end
    -- if GlobalData.roomID == 0 then
    --     return
    -- end
    -- if LogClient.server == nil then
    --     LogClient:open(GlobalData.roomIP,GlobalData.roomPort)
    -- end
    -- if LogClient.server then
    --     local obj = cpp_buff_create()
    --     cpp_buff_writeSerialNumAndProtocol(obj,LogClient.server.sid,1026)
    --     
    --     cpp_net_send(LogClient.server.sid,obj)
    -- end
end

function LogController.onHeartBeat(obj)--心跳
    -- local res = {}
    -- CCXNotifyCenter:notify("onHeartBeat",res)
end
-- 绑定协议号
-- self._proFuns[1038] = handler(self,self.onSendLog)
-- self._proFuns[1026] = handler(self,self.onHeartBeat)