GameNet = {}
GameNet.isReceiving = false
GameNet.sid = -1
GameNet.isOpen = false
GameNet.TimeOut = 15
GameNet.mTimeOut = 0
GameNet.__index = GameNet


function GameNet:startReceive()
    -- if self.isReceiving == false then
    --     self.mTimeOut = 0
        
    --     self.scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(t)
                
    --             local statu = cpp_net_getStatu(self.sid)
    --             --cclog("判断状态  .. "  .. self.sid)
    --             if statu == 1 then
    --                 if self.isOpen == false then
    --                     local serial = cpp_net_serialNumber(self.sid)
    --                     if serial ~= -1 then--确保收到了序列号才进
    --                         self.isOpen = true
    --                         self:onOpen()
    --                     end
    --                 else
    --                     local obj = cpp_net_receive(self.sid)
    --                     while obj ~= -1 do
    --                         self:onReceive(obj)
    --                         obj = cpp_net_receive(self.sid)
    --                     end
    --                 end
    --             elseif statu == -1 then
                    
    --                 cclog("接收信息失败2  "  .. self.sid)

    --                 self:onClose()
                    
    --             else
    --                 if self.isOpen == false then
    --                     self.mTimeOut = self.mTimeOut + t
    --                     if self.mTimeOut > self.TimeOut then--超时
    --                         cclog("接收信息失败3")
    --                         self:onClose()
    --                     end
    --                 end
    --             end
    --     end
    --     ,0,false)
    --     self.isReceiving = true
       
    -- end
end

function GameNet:stopReceive()
    -- if self.isReceiving == true then
    --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleID)
        
    --     self.isReceiving = false
    -- end
end

function GameNet:create(delegate)
    -- local gn = {}
    -- setmetatable(gn,GameNet)
    -- gn.delegate = delegate
    -- gn.listener = {}
    -- return gn
end

function GameNet:open(url,port)
    -- MessageCache:chearCache()
    -- LineMgr:set_line_type_try_state(true)
    -- self.isOpen = false
    -- self.sid = cpp_net_open(url, port)
    -- self:startReceive()
end

function GameNet:close()
    -- MessageCache:chearCache()
    -- cpp_net_close(self.sid)
    -- cclog("接收信息失败4")
    -- self:onClose()
end

function GameNet:send(obj)
    --cpp_net_send(self.sid,obj)
end

function GameNet:onOpen()
    -- LineMgr:set_line_type_try_state(false)
    -- LineMgr:set_line_type_ok_state(true)
    -- cclog("Socket open : " .. self.sid)
    -- self:dispatch("onOpen",self)
end

function GameNet:onClose()
    -- LineMgr:set_line_type_ok_state(false)
    -- self:stopReceive()
    -- cclog("Socket Close : ".. self.sid)
    -- self:dispatch("onClose",self)
end

function GameNet:onReceive(obj)
    -- local cmd = obj:readShort()--协议号(包头)
    -- local sid = obj:readShort() --sid
    -- local serinum = obj:readInt() --序列号
    -- if cmd == nil then
    --     cclog("接收信息失败1")
    --     self:onClose()
    --     return
    -- end

    -- if cmd >= 0 then
    --     cclog(" s->c cmd " .. cmd)
    --     local reader = self.delegate.funs[cmd]
    --     if reader == nil then
    --         return
    --     end
    --     local fun,data = reader(obj)--只需要readString
    --     self:dispatch(fun,data)
    --     cpp_buff_delete(obj)
    -- else
    --     if cmd == -32768 then
    --         local dispatch_tb = {}
    --         while true do
    --             local sub_cmd = obj:readShort()
    --             local sub_sid = obj:readShort()
    --             local sub_serinum = obj:readInt() --序列号
    --             if sub_cmd > 0 then
    --                 local reader = self.delegate.funs[sub_cmd]
    --                 if reader == nil then
    --                     break
    --                 end
    --                 local fun,data = reader(obj)--只需要readString
                    
    --                 dispatch_tb[#dispatch_tb + 1] = {}
    --                 dispatch_tb[#dispatch_tb].key = fun
    --                 dispatch_tb[#dispatch_tb].value = data
    --             else
    --                 break
    --             end
    --         end
    --         for k=1,#dispatch_tb do
    --             self:dispatch(dispatch_tb[k].key,dispatch_tb[k].value)
    --         end
            
    --         cpp_buff_delete(obj)
    --     else
    --         cclog("no cpp_buff_delete")
    --     end
    -- end
end

function GameNet:dispatch(fun,data)
    -- for k, l in pairs(self.listener) do
    --     if l[fun] ~= nil then
    --         l[fun](l,data)
    --     end
    -- end
end
