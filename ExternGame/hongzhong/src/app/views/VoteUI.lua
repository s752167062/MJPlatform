local VoteUI = class("VoteUI", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

VoteUI.RESOURCE_FILENAME = "VoteUI.csb"
VoteUI.RESOURCE_BINDING = {
    ["btn_cancel"]       = {    ["varname"] = "btn_cancel"     ,  ["events"] = { {event = "click" ,  method ="onNotAgree"        } }     },
    ["btn_ok"]       = {    ["varname"] = "btn_ok"     ,  ["events"] = { {event = "click" ,  method ="onAgree"        } }     },


    ["title"]       = {    ["varname"] = "title"      },
    ["selected"]       = {    ["varname"] = "selected"      },
    ["noselect"]       = {    ["varname"] = "noselect"      },
    ["countdown"]       = {    ["varname"] = "txt_countdown"     },
    ["bg"]       = {    ["varname"] = "bg"     },
}

function VoteUI:onCreate()

    self.root = self:getResourceNode()
end

function VoteUI:initParams(data)

    self.is_watch = data.is_watch  --自己是否是围观者
    self.isInitiator = data.isInitiator or false --是否发起人
    self.initiatorIndex = data.initiatorIndex or 1 --发起人索引(1-4)
    if self.initiatorIndex < 1 or self.initiatorIndex > 4 then --默认第1个就是当前玩家
        self.initiatorIndex = 1
    end
    self.playerInfo = data.playerInfo
    
    self.someone_notAgree = false
    self.show_notAgree_time = 3


    
    local function handler(t)
        self:update(t)
    end
    self:scheduleUpdateWithPriorityLua(handler,0)

    
    self.time = 0
    self.countdown = data.disTime
    cclog("剩余时间  " .. data.disTime)
    self.txt_player = {}
    -- self.playerSelected = {[1]=0,[2]=0,[3]=0,[4]=0} --4个玩家选择的结果(0为没选，1为同意，2为不同意)
    --if self.isInitiator then--是发起者
    -- self.playerSelected[self.initiatorIndex] = 1
    --end

    self.player_commons = {}

    self:setCountdown()
    self:setTitle()
end

function VoteUI:onEnter()
    cclog("VoteUI:onEnter >>>>")

    if self.isInitiator == true or self.is_watch then --是发起人
        self:setShowBtn(false)
    elseif self.isInitiator == false then
        self:setShowBtn(true)
    end

    self:createPlayers()
end

function VoteUI:onExit()
    -- self:unregisterScriptHandler()--取消自身监听
    CCXNotifyCenter:unListenByObj(self)
end

function VoteUI:onClose()
    -- 自己的移除由 CUIGame 管控
    CCXNotifyCenter:notify("NotifyCloseAsk",nil)

end

function VoteUI:update(t)
    self.time = self.time + t
    if self.time > 1 then
        -- cclog("VoteUI:update >>>")

        if self.countdown >= 1 then --倒计时
            self:setCountdown()
            self.countdown = self.countdown - 1
        end

        if self.someone_notAgree then
            self.show_notAgree_time = self.show_notAgree_time -1
            if self.show_notAgree_time <= 0 then
                self:onClose()
            end
        end
        
        self.time = 0
    end
end








function VoteUI:onNotAgree()
    cclog("点击不同意按钮")
    -- self.playerSelected[1] = 2
    ex_roomHandler:askDismissRoom(false)
end

function VoteUI:onAgree()
    cclog("点击同意按钮")
    -- self.playerSelected[1] = 1
    ex_roomHandler:askDismissRoom(true)
end


function VoteUI:setShowBtn(isShow)
    self.noselect:setVisible(isShow)
    self.selected:setVisible(not isShow)
end

function VoteUI:createPlayers()

    local pinfo = ex_fileMgr:loadLua("app.views.VoteUiPlayerInfo")
    local offset_x = 108
    local y = 350
    local show_bg = 500
    local tmp_count = #self.playerInfo 
    local space = show_bg/tmp_count
    local half_space = space/2
    offset_x = offset_x +half_space
    for k,v in ipairs(self.playerInfo) do
        

        local node = pinfo.new()
        node:setPosition(cc.p(offset_x, y))
        node:initParams({ player_info = v  })
        self.bg:addChild(node)
        self.player_commons[k] = node
        offset_x = offset_x +space

        if self.initiatorIndex == k then
            node:setAgreeState(true)
        end
    end
end

function VoteUI:SetPlayerState(index,isAgree) 

    local common = self.player_commons[index]
    if not common then
        return
    end
    common:setAgreeState(isAgree)

    if not isAgree then  --有一个人不同意，就关了窗口，不投票啦
        self.someone_notAgree = true
        self:setShowBtn(false)
    end

    local info = self.playerInfo[index]
    if not info then return end

    if info.id == PlayerInfo.playerUserID then
        self:setShowBtn(false)
    end
end

function VoteUI:setTitle()
    local info = self.playerInfo[self.initiatorIndex]
    if not info then return end 

    self.title:setString(info.name .. " 玩家申请解散")
end

function VoteUI:setCountdown()
    self.txt_countdown:setString(tostring(self.countdown or 0))
end


-- function VoteUI:onEnter()
--     self.txt_title = self.root:getChildByName("bg"):getChildByName("title")
    
--     self.panel_noselect = self.root:getChildByName("bg"):getChildByName("noselect")
--     self.txt_selected = self.root:getChildByName("bg"):getChildByName("selected")
    
--     self.btn_ok = self.root:getChildByName("bg"):getChildByName("noselect"):getChildByName("btn_ok")
--     self.btn_ok:addClickEventListener(function() self:onSelect(1) end)
    
--     self.btn_cance = self.root:getChildByName("bg"):getChildByName("noselect"):getChildByName("btn_cance")
--     self.btn_cance:addClickEventListener(function() self:onSelect(2) end)
    
--     self.txt_countdown = self.root:getChildByName("bg"):getChildByName("countdown") --倒计时
--     self.txt_countdown:setText("(" .. self.countdown .. ")")
--     self.txt_countdown:setVisible(true)
    
--     self.txt_player[1] = self.root:getChildByName("bg"):getChildByName("playerState1")
--     self.txt_player[2] = self.root:getChildByName("bg"):getChildByName("playerState2")
--     self.txt_player[3] = self.root:getChildByName("bg"):getChildByName("playerState3")
--     self.txt_player[4] = self.root:getChildByName("bg"):getChildByName("playerState4")

--     self.txt_title:setText("玩家 " .. self.playerInfo[self.initiatorIndex].name .. "申请解散房间")
--     self.txt_player[self.initiatorIndex]:setText(self.playerInfo[self.initiatorIndex].name .. "选择了同意")
    
--     for i=1,#self.playerInfo,1 do
--         if i ~= self.initiatorIndex then
--             self.txt_player[i]:setText(self.playerInfo[i].name .. "正在选择..")
--         end
--     end
    
--     if self.isInitiator == true or self.is_watch then --是发起人
--         self.panel_noselect:setVisible(false)
--         self.txt_selected:setVisible(true) --显示等待其他玩家
--     elseif self.isInitiator == false then
--         self.panel_noselect:setVisible(true) --显示同意、不同意按钮
--         self.txt_selected:setVisible(false) 
--     end
-- end






-- function VoteUI:update(t)
--     self.time = self.time + t
--     if self.time > 1 then
--         if self.countdown >= 1 then --倒计时
--             if self.countdown == 1 and false then
--                 cclog("VoteUI:update 超时自动同意")
--                 self.countdown = 0
--                 self.txt_countdown:setVisible(false)
--                 self:onSelect(1)
--                 return
--             end
--             self.countdown = self.countdown - 1
--             self.txt_countdown:setText("(" .. (self.countdown) .. ")")
--         end
--         local count1,count2,count3 = self:GetPlayerSelectedCount() 
        
--         if count1 == 4 then --4个玩家都做出了选择
--             if count2 >= 4 then --同意的玩家数超过半数
--                 cclog("打开大厅界面")
--                 --self.app:enterScene("LobbyGame") 
--             elseif count2 < 3 then
--                 --关闭投票界面
--                 --self:onClose()
--                 CCXNotifyCenter:notify("NotifyCloseAsk",nil)
--             end 
--         elseif count3 >= 2 or (#self.playerInfo == 3 and count3 >= 1) then
--             CCXNotifyCenter:notify("NotifyCloseAsk",nil)
--         end
        
--         self.time = 0
--     end
-- end





-- function VoteUI:onSelect(index)
--     if index == 1 then
--         cclog("点击同意按钮")
--         self.panel_noselect:setVisible(false)
--         self.txt_selected:setVisible(ture) --显示等待其他玩家
--         self.playerSelected[1] = 1
--         ex_roomHandler:askDismissRoom(true)
--         self.txt_player[1]:setText(self.playerInfo[1].name .. "选择了同意")
--         --向服务器发送同意的标记
--     elseif index == 2 then
--         cclog("点击不同意按钮")
--         self.panel_noselect:setVisible(false)
--         self.txt_selected:setVisible(ture) --显示等待其他玩家
--         self.playerSelected[1] = 2
--         ex_roomHandler:askDismissRoom(false)
--         self.txt_player[1]:setText(self.playerInfo[1].name .. "选择了不同意")
--         --向服务器发送不同意的标记
--     end
-- end

-- --用来在接收到服务器发来的其他玩家是否同意解散房间时刷新界面
-- function VoteUI:SetPlayerState(index,isAgree) 
--     if isAgree == true then
--         self.txt_player[index]:setText(self.playerInfo[index].name .. "选择了同意")
--         self.playerSelected[index] = 1
--     elseif isAgree == false then
--         self.txt_player[index]:setText(self.playerInfo[index].name .. "选择了不同意")
--         self.playerSelected[index] = 2
--     end
-- end

-- --获得已做出选择玩家的总数
-- function VoteUI:GetPlayerSelectedCount() 
--     local count = 0
--     local agreeCount = 0
--     local disCount = 0
--     for i=1,4,1 do
--         if self.playerSelected[i] ~= 0 then
--             count = count + 1
--             if self.playerSelected[i] == 1 then
--                 agreeCount = agreeCount + 1
--             elseif self.playerSelected[i] == 2 then
--                 disCount = disCount + 1
--             end
--         end
--     end
--     return count,agreeCount,disCount
-- end

return VoteUI
