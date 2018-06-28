local NEWSInfo = class("NEWSInfo",function() 
    return cc.Node:create()
end)

function NEWSInfo:ctor(data)
    self.root = display.newCSNode(data.csbfile)
    self.root:addTo(self)

    self.scene = data.scene
    self.flag = 0
    self.mTimer = 15
    self.txt_time = self.root:getChildByName("txt_time")
    self.txt_time:setString("")
    self:setScale(0.8)
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

function NEWSInfo:onEnter()
    self:changeFlag()
    ex_timerMgr:register(self)
end

function NEWSInfo:update(t)

    --cclog("NEWS")
    if self.flag ~= self.scene.light_flag then
        self:changeFlag()
    end
    
    self.mTimer = self.mTimer - t
    if self.mTimer < 0 then
    	self.mTimer = 0
    end
    
    if self.sel_img and self.flag ~= 0 then
        self.alpha = self.alpha + self.direct
        if self.alpha > 255 then
            self.alpha = 255
            self.direct = self.direct*-1
        elseif self.alpha < 0 then
            self.alpha = 0
            self.direct = self.direct*-1
        end
        --cclog("alpha = " .. self.alpha)
        self.sel_img:setOpacity(self.alpha)
        self.txt_time:setString(string.format("%d",self.mTimer))
    else
        self.txt_time:setString("")
    end
    if self.scene.offset == nil then
        self.scene.offset = 0
    end


    self.txt_time:setRotation(-(90+90*self.scene.offset))
    self:setRotation(90+90*self.scene.offset)
end

function NEWSInfo:changeFlag()
    --self.root:getChildByName("img_news1")
    self.flag = self.scene.light_flag
    if self.flag == nil then
        self.flag = 0
    end
    self.alpha = 255
    self.direct = -4
    self.mTimer = 15
    if self.scene.offset == nil then
        self.scene.offset =0
    end
    for i = 1,4 do
        local img_name = string.format("img_news%d",i)
        local img = self.root:getChildByName(img_name)
        local tmpf = (self.flag+self.scene.offset)%4 + 1
        img:setVisible(i == tmpf and self.flag ~= 0)
        if i == tmpf and self.flag ~= 0 then
            self.sel_img = img
        end
    end
    
    if self.flag == 0 then
        self.sel_img = nil
    end
    
    
end

function NEWSInfo:onExit()
    ex_timerMgr:unRegister(self)
    self:unregisterScriptHandler()--取消自身监听
end

return NEWSInfo
