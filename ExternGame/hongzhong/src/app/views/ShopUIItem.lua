local ShopUIItem = class("ShopUIItem",function() 
    return cc.Node:create()
end)

function ShopUIItem:ctor(data)
    self.root = display.newCSNode("ShopUIItem.csb")
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

function ShopUIItem:onEnter()
    
end

function ShopUIItem:onExit()
    self:unregisterScriptHandler()--取消自身监听
end

function ShopUIItem:onClose()
    
end

return ShopUIItem