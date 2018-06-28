local CUIVideo = class("CUIVideo",function() 
    return cc.Node:create()
end)

function CUIVideo:ctor(isPlayer)
    self.root = display.newCSNode("game/CUIVideo.csb")
    self.root:addTo(self)

    self.btn_zt = self.root:getChildByName("ctn_viedo"):getChildByName("btn_zt")
    self.btn_bf = self.root:getChildByName("ctn_viedo"):getChildByName("btn_bf")
    local btn_qj = self.root:getChildByName("ctn_viedo"):getChildByName("btn_qj")
    local btn_ht = self.root:getChildByName("ctn_viedo"):getChildByName("btn_ht")
    local btn_fh = self.root:getChildByName("ctn_viedo"):getChildByName("btn_fh")
    

    self.btn_zt:setVisible(isPlayer)
    self.btn_bf:setVisible(isPlayer == false)
    
    self.btn_zt:addClickEventListener(function() self:onStop() end)
    self.btn_bf:addClickEventListener(function() self:onPlayer() end)
    btn_qj:addClickEventListener(function() self:onForward() end)
    btn_ht:addClickEventListener(function() self:onRewind() end)
    btn_fh:addClickEventListener(function() self:onBack() end)
    self.root:getChildByName("ctn_viedo"):getChildByName("btn_videoErr"):setVisible(false)
    self.root:getChildByName("ctn_viedo"):getChildByName("btn_videoErr"):addClickEventListener(function() self:onVideoErr() end)
    
    self:registerScriptHandler(function(state)
        if state == "exit" then
            self:onExit()
        end
    end)
end

function CUIVideo:onStop()
    cclog("播放")
    self.btn_zt:setVisible(false)
    self.btn_bf:setVisible(true)
    CCXNotifyCenter:notify("VideoNotify",3)
end

function CUIVideo:onPlayer()
    cclog("暂停")
    self.btn_zt:setVisible(true)
    self.btn_bf:setVisible(false)
    CCXNotifyCenter:notify("VideoNotify",2)
end

function CUIVideo:onForward()
    cclog("快进")
    self.btn_zt:setVisible(true)
    self.btn_bf:setVisible(false)
    CCXNotifyCenter:notify("VideoNotify",4)
end

function CUIVideo:onRewind()
    cclog("快退")
    self.btn_zt:setVisible(true)
    self.btn_bf:setVisible(false)
    CCXNotifyCenter:notify("VideoNotify",1)
end

function CUIVideo:onBack()
    cclog("返回")
    CCXNotifyCenter:notify("VideoNotify",5)
end

function CUIVideo:onVideoErr()
    CCXNotifyCenter:notify("upVideo",nil)
end

function CUIVideo:onExit()
end

return CUIVideo