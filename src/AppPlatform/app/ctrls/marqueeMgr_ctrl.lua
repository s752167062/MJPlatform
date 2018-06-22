--@跑马灯管理类
--@Author 	liangpx
--@date 	2017/6/26

local MarqueeMgr = class("MarqueeMgr")
local TAG_MARQUEEUI = 8888

function MarqueeMgr:ctor()
    self.curScene = nil
    self.marqueeNode = nil
    eventMgr:registerEventListener("addMarqueeMsg",handler(self,self.addMarqueeMsg),self)
end

function MarqueeMgr:clear()
	self.curScene = nil
    self.curState = nil
    local curScene = viewMgr:getScene()
    local node = curScene:getChildByTag(TAG_MARQUEEUI)
    if node then
        node:removeFromParent()
    end
end

--这方法不能在切换场景过程中调用，需要切完场景之后
function MarqueeMgr:changeScene()
    -- body
    local curScene = viewMgr:getScene()
    local curState = gameState:getState()
    print("MarqueeMgr changeScene", curState, self.curState)
    if curState ~= nil then
        if self.curState == nil or self.curState ~= curState then
            print("MarqueeMgr changeScene", curState, self.curState)

            local node = curScene:getChildByTag(TAG_MARQUEEUI)
            if node then
                print("node not nil")
                node:removeFromParent()
            end

            node = require("app.views.marqueeUI").new()
            curScene:addChild(node, 10000, TAG_MARQUEEUI)
            self.curState = curState
        end
    end
end

function MarqueeMgr:addMarqueeMsg(msg)
    --print("addMsg",debug.traceback())
    if not msg or msg == "" then
        return
    end

    print("MarqueeMgr addMarqueeMsg")

    local curScene = viewMgr:getScene()
    local node = curScene:getChildByTag(TAG_MARQUEEUI)
    if node ~= nil then
        print("marquee msg = "..tostring(msg))
        node:addMsg(msg)
    else
        print("marqueeNode is nil.")
    end
end

return MarqueeMgr