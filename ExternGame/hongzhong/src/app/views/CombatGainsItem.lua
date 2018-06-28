local CombatGainsItem = class("CombatGainsItem",function() 
    return cc.Node:create()
end)

function CombatGainsItem:ctor(data)
    self.root = display.newCSNode("CombatGainsItem.csb")
    self.root:addTo(self)

    local btn_video = self.root:getChildByName("areaPanel"):getChildByName("btn_video")
    btn_video:addClickEventListener(function() self:onVideo() end)
    
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

function CombatGainsItem:onEnter()

end

function CombatGainsItem:setVideoData(data)
    self.vd = data
end

function CombatGainsItem:onVideo()

	
	-- if self.vd == nil then
 --        GlobalFun:showError("无效录像1",nil,nil,1)
	-- else
	--     local v_tb = UserScoreFile:readIndexTable(self.vd.index)
 --        if v_tb == nil or v_tb[1].roomid ~= self.vd.roomid or v_tb[1].curr ~= self.vd.curr then
 --            GlobalFun:showError("无效录像2",nil,nil,1)
	--     else
 --            CCXNotifyCenter:notify("showVideo",v_tb)
 --        end
	-- end



    if self.vd == nil then
        GlobalFun:showError("无效录像1",nil,nil,1)
    else
        local v_tb = LocalDataFile:readVideo(self.vd.originType, self.vd.originKey, self.vd.uniqueKey, self.vd.roomid, self.vd.curr)
        if not v_tb or not next(v_tb) then
            GlobalFun:showError("无效录像2",nil,nil,1)
        else
            CCXNotifyCenter:notify("showVideo",v_tb)
        end
    end

end

function CombatGainsItem:onExit()
    self:unregisterScriptHandler()--取消自身监听
end

function CombatGainsItem:onClose()

end

return CombatGainsItem