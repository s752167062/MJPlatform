local RoomUI = class("RoomUI",function() 
    return cc.Node:create()
end)

function RoomUI:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("RoomUI.csb")
    self.root:addTo(self)

    self:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        elseif state == "enterTransitionFinish" then
        --self:onEnterTransitionFinish_()
        elseif state == "exitTransitionStart" then
        --self:onExitTransitionStart_()
        elseif state == "cleanup" then
        --self:onCleanup_()
        end
    end)
end

function RoomUI:onEnter()
    local ctn_close = self.root:getChildByName("bg"):getChildByName("btn_close")
    ctn_close:addClickEventListener(function() self:onClose() end)
    
    self.ctn_create = self.root:getChildByName("bg"):getChildByName("btn_create")
    self.ctn_create:addClickEventListener(function() self:onCreate() end)
    
    self.ctn_join = self.root:getChildByName("bg"):getChildByName("btn_join")
    self.ctn_join:addClickEventListener(function() self:onJoin() end)

end

function RoomUI:onExit()
    self:unregisterScriptHandler()--取消自身监听
end

function RoomUI:onClose()
    self:removeFromParent()
end

function RoomUI:onCreate()
    cclog("打开创建房间界面")
    local ui = ex_fileMgr:loadLua("app.views.CreateRoomUI")
    self.root:addChild(ui.new({app = self.app}))
end

function RoomUI:onJoin()
    cclog("打开房间号界面")
    local ui = ex_fileMgr:loadLua("app.views.RoomNumberUI")
    self.root:addChild(ui.new({app = self.app}))
end

return RoomUI