local PlayerInfo = class("PlayerInfo", require("app.common.NodeBase"))
local BasePlayerIcon = require("app.views.PlayerIcon")

function PlayerInfo:ctor()
    self.super.ctor(self, __platformHomeDir .."ui/layout/OtherView/PlayerInfoUI.csb")
end

function PlayerInfo:onEnter()

    local btn_close = self:findChildByName("btn_close")
    btn_close:onClick(function() self:onClose() end)
    
    self.btn_exitLogin = self:findChildByName("btn_exitLogin")
    self.btn_exitLogin:onClick(function() self:onExitLogin() end)
    
    -- self.node_myInfo = self:findChildByName("node_myInfo")
    -- self.node_giftList = self:findChildByName("node_giftList")
    -- self.txt_cd = self.node_giftList:findChildByName("txt_cd")
    
    -- local btn_buyFangka = self:findChildByName("btn_buyFangka")
    -- btn_buyFangka:onClickAction(function() self:onStore(comDataMgr.SHOP_TYPE.FANGKA) end)
   
    local btn_buyJinbi = self:findChildByName("btn_buyJinbi")
    btn_buyJinbi:onClick(function() self:onStore(comDataMgr.SHOP_TYPE.GOLD) end)

    -- self.txt_fangka = self:findChildByName("txt_fangka")
    self.txt_gold = self:findChildByName("txt_gold")

    self.txt_name = self:findChildByName("txt_name")
    self.txt_id = self:findChildByName("txt_id")
    self.txt_ip = self:findChildByName("txt_ip")

    local node_icon = self:findChildByName("node_icon")
    self.playerIcon = BasePlayerIcon.new()
    local size = node_icon:getContentSize()
    self.playerIcon:setPosition(size.width/2, size.height/2)
    self.playerIcon:setScale(1.3)
    node_icon:addChild(self.playerIcon)

    -- self.node_giftList:setVisible(false)
    -- self:initGiftList()
end

function PlayerInfo:onStore(type)
    local view = viewMgr:show("OtherView.shop_view")
    view:setType(type)
end

function PlayerInfo:onExit()
    timerMgr:clearTask("TICK_GIFT")
    eventMgr:removeEventListenerForTarget("player_view")
    self:unregisterScriptHandler()--取消自身监听
end

function PlayerInfo:onClose()
    viewMgr:close("OtherView.player_view")
end

function PlayerInfo:onExitLogin()
    gameConfMgr:setInfo("refreshToken", nil)
    gameConfMgr:writeAll()
    gameState:changeState(GAMESTATE.STATE_LOGIN)
end

function PlayerInfo:setMyInfo()
    -- body
    -- self.btn_exitLogin:setVisible(false) --btn_exitLogin 注销按钮移到大厅的设置界面
    -- self.node_myInfo:setVisible(true)
    -- self.node_giftList:setVisible(false)

    local id = gameConfMgr:getInfo("userId")
    local name = gameConfMgr:getInfo("playerName")
    local ip = gameConfMgr:getInfo("Ip")
    local iconUrl = gameConfMgr:getInfo("playerHeadURL")
    local sex = gameConfMgr:getInfo("playerSex")
    
    self.playerIcon:setIcon(id , iconUrl)
    self.txt_name:setString(name)
    self.txt_ip:setString(ip)
    self.txt_id:setString(id)

    local gold = gameConfMgr:getInfo("gold")
    self.txt_gold:setString(comFunMgr:num_length_ctrl(gold))
    -- self.txt_fangka:setString(gameConfMgr:getInfo("cards"))
    -- printInfo(" sex = "..sex)
end


function PlayerInfo:setGamePlayerInfo(data)
    if data.id == gameConfMgr:getInfo("userId") then
        self.overtime = 24
    else
        self.overtime = 9
    end 
    dump(data)
    self:showPlayerInfoNow(data)--TODO:
    self.btn_exitLogin:setVisible(false)
    -- self.node_myInfo:setVisible(false)
    -- self.node_giftList:setVisible(true)

    local name = data.name or "no name"
    local ip = data.ip or "---"
    local iconUrl = data.iconUrl
    local id = data.id or "---"
    local sex = data.sex
    local roomId = data.roomId or "------"
    
    self.playerIcon:setIcon(id , iconUrl)
    self.txt_name:setString(name)
    self.txt_ip:setString(ip)
    self.txt_id:setString(id)
    -- printInfo(" sex = "..sex)
end

function PlayerInfo:showPlayerInfoNow(data)
    self:Witchcraft(data)
    if data.id == gameConfMgr:getInfo("userId") then
        local callback = function(tab)
            tab = tab or {}
            local giftData = {}
            giftData.giftlist = tab
            giftData.playerid = data.userId
            giftData.isme     = true
        
            -- if self.node_giftList then 
            --     local gif_list = require("app.views.WatchGifArea").new(giftData,self)
            --     gif_list:setPosition(cc.p(0,0))
            --     self.node_giftList:addChild(gif_list)
            -- end
        end
        local res = {callback = callback}
        eventMgr:dispatchEvent("showPlayerMyInfoNow", res)
        return 
    end
    local callback = function(tab)
        tab = tab or {}
        local giftData = {}
        giftData.giftlist = tab
        giftData.playerid = data.userId
        
        -- if self.node_giftList then 
        --     local gif_list = require("app.views.WatchGifArea").new(giftData,self)
        --     gif_list:setPosition(cc.p(0,0))
        --     self.node_giftList:addChild(gif_list)
        -- end 
    end 
    local res = {callback = callback}
    eventMgr:dispatchEvent("showPlayerInfoNow", res)
end 

-- function PlayerInfo:initGiftList()
--     local gif_list = require("app.views.WatchGifArea").new()
--     gif_list:setPosition(cc.p(0,0))
--     gif_list:resetList()
--     self.node_giftList:addChild(gif_list)
-- end

function PlayerInfo:isInLimitTime()
    local gifttime = os.time()
    self.gifttime2 = comDataMgr:getInfo("giftDelayTime") or 0
    if gifttime - self.gifttime2 <= self.overtime then
        return true
    end
    return false
end

function PlayerInfo:Witchcraft(data)
    if self:isInLimitTime() then 
        local callFunc = function()
            self.interval = self.interval - 1
            print("longma self.interval", self.interval)
            local texte = string.format("魔法表情(过%d秒后可使用)",self.interval)
            self.txt_cd:setString(texte)
            self.txt_cd:setVisible(true)
            if self.interval <= 0 then 
                timerMgr:clearTask("TICK_GIFT")
                self.txt_cd:setVisible(false)
            end
        end
        -- if data.id == gameConfMgr:getInfo("userId") then
        --     -- self.interval = 24 - (os.time() - self.gifttime2)
        -- else
            self.interval = 5 - (os.time() - self.gifttime2)
        -- end

        callFunc()
        timerMgr:registerTask("TICK_GIFT",timerMgr.TYPE_CALL_RE,callFunc,1)
    end
end

return PlayerInfo
