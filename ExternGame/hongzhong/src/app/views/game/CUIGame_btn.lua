local CUIGame_btn = class("CUIGame_btn",function() 
    return cc.Node:create()
end)

local BaseMahjong = ex_fileMgr:loadLua("app.views.game.CSBMahjong")
local BaseBTNHu = ex_fileMgr:loadLua("app.views.game.btn_hu")
local BaseBTNGang = ex_fileMgr:loadLua("app.views.game.btn_gang")
local BaseBTNPeng = ex_fileMgr:loadLua("app.views.game.btn_peng")
local BaseBTNPass = ex_fileMgr:loadLua("app.views.game.btn_pass")

function CUIGame_btn:ctor()
    self.root = display.newCSNode("game/CUIGame_btn.csb")
    self.root:addTo(self)

    self.win_ = self.root:getChildByName("ctn_win")
    self:registerScriptHandler(function(state)
        if state == "exit" then
            self:onExit()
        end
    end)
    self.hu = nil
    self.pass = nil
    self.gang = {}
    self.peng = {}
    self.tag = 10
    self.autoT = nil
    CCXNotifyCenter:listen(self,function() self:passNotify() end,"PassNotify")
    CCXNotifyCenter:listen(self,function() self:cleanAll() end,"BtnCleanAll")
    
    if true then
        self.updata_t = nil
        local function handler(t)
            self:update(t)
        end
        self:scheduleUpdateWithPriorityLua(handler,0)
    end
end

function CUIGame_btn:setBtn(data)
	for i =1,#data do
	   if data[i].type == 1 then -- hu
	       if self.hu then
	           local tmp_hu = self.win_:getChildByTag(self.hu)
	           if tmp_hu == nil then
	               self.hu = nil
	           end
	       end
	       if self.hu == nil then
	           self.hu = self.tag
	           local btn_hu = BaseBTNHu.new({})
	           self.win_:addChild(btn_hu)
	           btn_hu:setTag(self.hu)
	           self.tag = self.tag + 1

               self:cleanColor()
	       end
	   elseif data[i].type == 2 then--gang
	       local flag = true
	       for j=1,#self.gang do
	           if data[i].num == self.gang[j].num then
	               flag = false
	               break
	           end
	       end
	       if flag  then--创建一个新的btn
	           self.gang[#self.gang + 1] = {}
	           self.gang[#self.gang].num = data[i].num
	           self.gang[#self.gang].tag = self.tag
               self.gang[#self.gang].gt = data[i].gt
               self.gang[#self.gang].outID = data[i].outID
	           self.tag = self.tag + 1
	           local tmpdata = {outID = data[i].outID,num = data[i].num,gt = data[i].gt}
                local btn_gang = BaseBTNGang.new(tmpdata)
                btn_gang:setTag(self.gang[#self.gang].tag) 
	           self.win_:addChild(btn_gang)

               self:cleanColor()
	       end
	   elseif data[i].type == 3 then--peng
            local flag = true
            for j=1,#self.peng do
                if data[i].num == self.peng[j].num then
                    flag = false
                    break
                end
            end
            if flag  then--创建一个新的btn
                self.peng[#self.peng + 1] = {}
                self.peng[#self.peng].num = data[i].num
                self.peng[#self.peng].tag = self.tag
                self.peng[#self.peng].outID = data[i].outID
                self.tag = self.tag + 1
                local tmpdata = {outID = data[i].outID,num = data[i].num}
                local btn_peng = BaseBTNPeng.new(tmpdata)
                btn_peng:setTag(self.peng[#self.peng].tag)
                self.win_:addChild(btn_peng)

                self:cleanColor()
            end
	   else--guo
	       if self.pass then
                local tmp_pass = self.win_:getChildByTag(self.pass)
                if tmp_pass == nil then--做验证  当self.pass存在实际这个button不存在的情况
                    self.pass = nil
                end
	       end
	       if self.pass == nil then
	           self.pass = self.tag
	           local btn_pass = BaseBTNPass.new({})
	           self.win_:addChild(btn_pass)
	           btn_pass:setTag(self.pass)
	           self.tag = self.tag + 1

               self:cleanColor()
	       end
	   end
	end

    -- if self.hu and self.pass then
    --     self.win_:removeChildByTag(self.pass)
    --      self.pass = nil
    -- end
	
	self:drawBtn()
	self:setVisible(true)
	
	if Game_conf.auto then
    	self.autoT = 0
    end

    -- self:cleanColor()
end

function CUIGame_btn:update(t)
    if self.autoT and Game_conf.auto then
        self.autoT = self.autoT + t
        if self.autoT >0.5 then
            self.autoT = nil
            if self.hu then
                ex_roomHandler:confirmHu(true)
            elseif #self.gang > 0 then
                if self.gang[1].gt ~= 1 then--明杠
                    ex_roomHandler:userMingGang(self.gang[1].outID,GlobalFun:localCardToServerCard(self.gang[1].num))
                else
                    ex_roomHandler:userAnGang(GlobalFun:localCardToServerCard(self.gang[1].num))
                end
            elseif #self.peng > 0 then
                ex_roomHandler:userPeng(self.peng[1].outID,GlobalFun:localCardToServerCard(self.peng[1].num))
            else
                self:passNotify()
            end
            CCXNotifyCenter:notify("BtnCleanAll",nil)
        end
    else
        if Game_conf.auto then
            if self:isVisible() then
                self.autoT = 0
            end
        end
    end
end

function CUIGame_btn:drawBtn()
    local locationX = -230
    
    if self.pass then
        self.win_:getChildByTag(self.pass):setPosition(locationX,0)
        locationX = locationX - 200
    end
    
    for i=1,#self.peng do
        self.win_:getChildByTag(self.peng[i].tag):setPosition(locationX,0)
        locationX = locationX - 250
    end
    
    for i=1,#self.gang do
        self.win_:getChildByTag(self.gang[i].tag):setPosition(locationX,0)
        locationX = locationX - 250
    end
    
    if self.hu then
        self.win_:getChildByTag(self.hu):setPosition(locationX,0)
    end
end

function CUIGame_btn:passNotify()

    if self.hu then
        local function sure()
            ex_roomHandler:userPass()
            self:cleanAll()
        end
        -- local uiexit = ex_fileMgr:loadLua("app.views.ExitUI").new({ok = sure,txt = "确定要放弃胡牌吗?"})
        -- cc.Director:getInstance():getRunningScene():addChild(uiexit,100)
        GlobalFun:showError("确定要放弃胡牌吗?", sure, nil,2)
    else
        ex_roomHandler:userPass()--玩家过
        self:cleanAll()
    end
--[[
    if self.hu then
        ex_roomHandler:confirmHu(false)
        return 
    end
    
    if #self.gang > 0 then
        local card = self.win_:getChildByTag(self.gang[1].tag)
        if card.gt ~= 1 then--明杠
            cclog("btn outID  "  .. card.outID)
            ex_roomHandler:userMingGang(card.outID,0)
        else
            ex_roomHandler:userAnGang(0)
        end
        return
    end
    
    if #self.peng > 0 then
        local card = self.win_:getChildByTag(self.peng[1].tag)
        ex_roomHandler:userPeng(card.outID,0)
        return
    end
    ]]
end

function CUIGame_btn:cleanAll()
    cclog("移除")
    if self.hu  then
        self.win_:removeChildByTag(self.hu)
        self.hu = nil
    end
    
    if self.pass then
        self.win_:removeChildByTag(self.pass)
        self.pass = nil
    end
    
    for i=1,#self.gang do
        self.win_:removeChildByTag(self.gang[i].tag)
    end
    self.gang = {}
    
    for i=1,#self.peng do
        self.win_:removeChildByTag(self.peng[i].tag)
    end
    self.peng = {}
    self.tag = 10
    
    self:setVisible(false)
end

function CUIGame_btn:onExit()
    CCXNotifyCenter:unListenByObj(self)
end

function CUIGame_btn:cleanColor()
    if self.hu  then
        local hu = self.win_:getChildByTag(self.hu)
        hu:resetColor()
    end
    
    if self.pass then
        local pass = self.win_:getChildByTag(self.pass)
        pass:resetColor()
    end
    
    for i=1,#self.gang do
        local gang = self.win_:getChildByTag(self.gang[i].tag)
        gang:resetColor()
    end

    
    for i=1,#self.peng do
        local peng = self.win_:getChildByTag(self.peng[i].tag)
        peng:resetColor()
    end
end

return CUIGame_btn
