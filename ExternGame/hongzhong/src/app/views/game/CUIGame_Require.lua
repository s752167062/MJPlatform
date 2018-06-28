ex_fileMgr:loadLua("SDK.SDKController")

local CUIGame_Require = class("CUIGame_Require",function() 
    return cc.Node:create()
end) 

local BasePlayerInfo = ex_fileMgr:loadLua("app.views.game.CUIGame_playerinfo")

local INFO_TAG = 568
function CUIGame_Require:ctor(scene)
    self.root = display.newCSNode("game/CUIGame_Require.csb")
    self.root:addTo(self)
    self.scene = scene
    self.players= {}
    
    local function changeMode(mode)
        if mode == AOVMgr._2D then
            self.btn_req = self.root:getChildByName("btn_req")
            self.root:getChildByName("btn_req2"):setVisible(false)
        elseif mode == AOVMgr._2_5D then
            self.btn_req = self.root:getChildByName("btn_req2")
            self.root:getChildByName("btn_req"):setVisible(false)
        end
        self.root:getChildByName("btn_req2_bg"):setVisible(mode == AOVMgr._2_5D)

        self.btn_req:addClickEventListener(function() self:onReqFriend() end)
        self.btn_req:setVisible(scene.isMatch ~= true and not self.scene.isWatch)
    end
    
    changeMode(AOVMgr:getGameMode())
    CCXNotifyCenter:listen(self, function(self,obj,data) changeMode(data.newMode) end, "ModeHasChange")

end

function CUIGame_Require:cleanUser()
    self.players = {}
    for i=1,4 do
        self.root:getChildByName("ctn_center"):getChildByName(string.format("ctn_%d",i)):removeAllChildren()
    end
end

function CUIGame_Require:userExit(id)
    for i=1,4 do
        if self.players[i] and self.players[i].id == id then
            self.players[i] = nil
            self.root:getChildByName("ctn_center"):getChildByName(string.format("ctn_%d",i)):removeAllChildren()
        end
    end
    
    self.btn_req:setVisible(self.scene.isMatch ~= true and not self.scene.isWatch)
    
    if id == PlayerInfo.playerUserID then
        local tmp = self.players
        self:cleanUser()
        for i=1,4 do
            if tmp[i] then
                self:userEnter(tmp[i],0)
            end
        end
    end

    cclog("longma userExit")
    CCXNotifyCenter:notify("playerRemove",id)
end

function CUIGame_Require:userEnter(player,offset)
    cclog("房间等待")
    local showp = (player.pos - offset +3)%4+1
    if self.scene.playerNum == 3 and showp == 3 then
        showp = 4
    end
    local ctn = self.root:getChildByName("ctn_center"):getChildByName(string.format("ctn_%d",showp))
    
    if ctn then
        local ttp = ctn:getChildByTag(INFO_TAG)
        if ttp then
            if ctn.player == nil or ctn.player.id ~= player.id then
                ctn:removeChildByTag(INFO_TAG)
                ctn.player = nil
            end
        end
    end
    
    if ctn ~= nil and ctn:getChildByTag(INFO_TAG) == nil then  
        cclog(" ---  -------  add  ------ ---")
        self.players[showp] = player
        local p = BasePlayerInfo.new(self.scene, BasePlayerInfo.UTYPE_2)
        --player.scene = self.scene
        p:setBaseData(player)--set 基础玩家数据
        p:setHolder(player.pos,showp,0)
        p:prePotoh(player)
        p:setZhuangVisible(player.isBanker)
        p:setTag(INFO_TAG)
        p:showIPTips(player,showp,self.scene.isVideo)
        ctn:addChild(p)
        
        ctn.player = player
    end
    
    self:setHeadOnAnOff({userid = player.id,flag = player.isLine and 1 or 0})
    
    self.btn_req:setVisible(self.scene.isMatch ~= true and not self.scene.isWatch)
end

function CUIGame_Require:getRealPosition(id)
    for i=1,4 do
        if self.players[i] and self.players[i].id == id then
            return self.root:getChildByName("ctn_center"):getChildByName(string.format("ctn_%d",i)):convertToWorldSpace(cc.p(0,0))
        end
    end
    return cc.p(-60,display.height+60)
end

function CUIGame_Require:setHeadOnAnOff(res)
    for i=1,4 do
        if self.players[i] and self.players[i].id == res.userid then
            local ctn = self.root:getChildByName("ctn_center"):getChildByName(string.format("ctn_%d",i))
            if ctn ~= nil and ctn:getChildByTag(INFO_TAG) then
                local pinfo = ctn:getChildByTag(INFO_TAG)
                if res.flag == 1 then
                    pinfo.txt_offline:setVisible(false)
                else
                    pinfo.txt_offline:setVisible(true)
                end
                pinfo.txt_offline:setPositionY(-150)
            end
        end
    end
end

function CUIGame_Require:onUserReady(userid)
    for i=1,4 do
        if self.players[i] and self.players[i].id == userid then
            self.players[i].isReady = true
            self.root:getChildByName("ctn_center"):getChildByName(string.format("ctn_%d",i)):getChildByTag(INFO_TAG):prePotoh(self.players[i])
        end
    end
end

function CUIGame_Require:notifyOpenGame(res)
    self.scene:createUser({players = self.players,cards = res.cards})
    --self:removeFromParent()
end

--语音表情
function CUIGame_Require:ShowEmojiVoice(pos,index)  
    GlobalFun:ShowSpeakString(self.root:getChildByName("ctn_center"):getChildByName(string.format("ctn_%d",pos)) , cc.p(0,0) , index);
end

--表情
function CUIGame_Require:ShowEmoji(pos,index)
    GlobalFun:ShowSpeakEmoji(self.root:getChildByName("ctn_center"):getChildByName(string.format("ctn_%d",pos)) , cc.p(0,0) , index);
end

--语音
function CUIGame_Require:ShowSpeakVoice(pos,filename)
    cclog(" GUIGame_ex_fileMgr:loadLua(ShowSpeakVoice) "..filename)
    GlobalFun:PlayVoiceAndShow(self.root:getChildByName("ctn_center"):getChildByName(string.format("ctn_%d",pos)),cc.p(0,0) , filename) 
end

function CUIGame_Require:onReqFriend()--邀请好友
    local num = 0
    for i = 1, 4 do
        if self.players[i] then
            num = num + 1
        end
    end
    self.root:addChild(ex_fileMgr:loadLua("app/Common/CUIShareType").new(0,self.scene.playerNum, num))
end

function CUIGame_Require:onNewUserEnter(res)
    cclog("CUIGame_Require:onNewUserEnter >>>>")
    local offset = 0
    if self.players[1] ~= nil and self.players[1].id == PlayerInfo.playerUserID then
        offset = self.players[1].pos-1
    end
    res.isLine = true
    res.discards = {}
    res.mingpai = {}
    res.handcard = {}
    res.listencard = {}
    if res.id == PlayerInfo.playerUserID then
        --offset = res.pos-1
        local tmp_data = self.players
        self:cleanUser()
        self.players = {}
        self:userEnter(res,res.pos-1)
        for i=1,4 do
            if tmp_data[i] then
                self:userEnter(tmp_data[i],res.pos-1)
            end
        end
        return
    end
    self:userEnter(res,offset)
end

return CUIGame_Require
