local UILobbBottom = class("UILobbBottom", cc.load("mvc").ViewBase)

function UILobbBottom:ctor()
    -- body
    if gameConfMgr:getInfo("chunjieOpen") then
        UILobbBottom.RESOURCE_FILENAME = "layout/chunjie/UILobbBottom.csb"
    else
        UILobbBottom.RESOURCE_FILENAME = "layout/SellerShare/UILobbBottom.csb"
    end
    UILobbBottom.super.ctor(self)
end

function UILobbBottom:onCreate()
    dump("CREATE")
    self:initUI()

    self.info_data = nil
    self.status = 0
    self.showOnce = false
end

function UILobbBottom:initUI()
    -- body
    self.btn_delegatecenter = self:findChildByName("btn_delegatecenter")
    self.btn_delegatecenter:onClick(function () self:onDelegateCenter() end)

    self.img_redpoint = self:findChildByName("img_redpoint")
    self.redpoint_num = self:findChildByName("redpoint_num")
    if self.img_redpoint then
        self.img_redpoint:setVisible(false)
    end

    self.btn_binddelegate = self:findChildByName("btn_binddelegate")
    self.btn_binddelegate:onClick(function () self:onBindDelegate() end)
    self.btn_binddelegate:setVisible(false)
end

function UILobbBottom:onEnter()
    dump("ENTER")

    -- eventMgr:registerEventListener("reCheckMy_red_envelopes"      ,handler(self,self.checkMy_red_envelopes_NEW     ),"UILobbBottom")
    -- eventMgr:registerEventListener("upDateDelegateinfoData"      ,handler(self,self.initDelegateInfo     ),"UILobbBottom")
    -- eventMgr:registerEventListener("DelegaetCenter_status_update"      ,handler(self,self.update_delegate_status     ),"UILobbBottom")
    -- eventMgr:registerEventListener("MyReward"      ,handler(self,self.showRewardWeb     ),"UILobbBottom")

    -- SellerShareMgr:checkMy_red_envelopes()  -- 检查红包
    -- SellerShareMgr:checkMy_red_envelopes_NEW() -- 新检查红包
    -- SellerShareMgr:getMy_AgentCenter_Msg()     -- 检查代理信息

    eventMgr:registerEventListener("updateAgentData", handler(self,self.showWebViewByServer),self) -- 检查是否代理
    eventMgr:registerEventListener("updateAgentRedpoint", handler(self,self.updateAgentRedpoint),self) -- 检查是否代理
    eventMgr:registerEventListener("requestAgentRedpoint", function () SellerShareMgr:requestAgentRedpoint() end,self) -- 检查是否代理

    eventMgr:registerEventListener("CheckDelegateStatus", handler(self,self.onCheckDelegateStatus),self) -- 检查代理状态
    eventMgr:registerEventListener("open_binddelegate", handler(self,self.openBindTips),self) --打开绑定界面
    --SellerShareMgr:H5PayCheck()                -- 检查支付类型
    --SellerShareMgr:requestAgentRedpoint()
    -- self:playNormal()

    SellerShareMgr:checkDelegateStatus()
end

function UILobbBottom:onExit()
    dump("EXIT")
    eventMgr:removeEventListenerForTarget(self)
end

function UILobbBottom:showWebViewByServer(data)
    if data then 
        self.info_data = data

        if data.isDelegate or data.hasRequire then 
            self:showRewardWeb(data.URL)
        else
            local tobo = require("SellerShare.UItobeDelegate").new()
            tobo:addTo(self:getParent())
        end 
    end 
    self.showOnce = false
end 

function UILobbBottom:openBindTips()
    local function func()
        self:onBindDelegate()
    end

    local bind = require("SellerShare.UIBandingTips").new()
    bind:setBtnFunc(func)
    bind:addTo(self:getParent())
end

function UILobbBottom:update_delegate_status(data)
    if data then 
        self.info_data.isDelegate = data.isDelegate
        self:initDelegateInfo(self.info_data)
    end    
end

function UILobbBottom:playTips()
    -- body
    if self.status ~= 1 then
        dump(" -- play tips ")
        self.status = 1
        --播放动画
        local ac = cc.CSLoader:createTimeline(UILobbBottom.RESOURCE_FILENAME)
        ac:play("a0",true)
        self:runAction(ac)
    end    
end

function UILobbBottom:playNormal()
    -- if self.status ~= 0 then
        self:stopAllActions()
        dump(" -- normal ")
        self.status = 0
        --播放动画
        local ac = cc.CSLoader:createTimeline(UILobbBottom.RESOURCE_FILENAME)
        ac:play("a1",false)
        self:runAction(ac)
    -- end  
end

--创建web页面
function UILobbBottom:createWebView(url_)
    local parent = self:getParent()
    if parent:getChildByName("uiwebview") then 
        dump("打开webview 重复点击 。。。")
        return 
    end    
    if url_ then
        local size       = cc.Director:getInstance():getVisibleSize()
        local action     = cc.MoveTo:create(0.3 , cc.p(0,0))

        dump(" URL ", url_)
        local web = require("SellerShare.UIWebView").new()
        web:setName("uiwebview")
        web:initData(url_)
        web:setPosition(cc.p(0,cc.Director:getInstance():getVisibleSize().height))
        web:runAction(action)
        web:addTo(self:getParent())
    end    
end

function UILobbBottom:showRewardWeb(url_)
    dump(" -- showRewardWeb" ,url_)
    if url_ then 
        self:createWebView(url_)
    end    
end

function UILobbBottom:onCheckDelegateStatus(data)
    if data then 
        self.delegateData = data

        local isDelegate = data.isDelegate
        self.btn_binddelegate:setVisible(not isDelegate)  

        local delegate_id = data.delegate_id
        -- if (not isDelegate) and  delegate_id == 0 then -- 不是代理且未绑定代理
        --     self:playTips()
        -- else
            self:playNormal()
        -- end   

        --自动打开邀请码界面
        if isDelegate == false and delegate_id == 0 then 
            if comDataMgr:getInfo("isFirstOpenDelegateUI") then
                local bindui = require("SellerShare.UIBangDingDele").new()
                bindui:setData(data)
                self:addChild(bindui,1)
                comDataMgr:setInfo("isFirstOpenDelegateUI",false)
            end
        end     
    end
end

------ 按钮 -------
-- 点击代理中心
function UILobbBottom:onDelegateCenter()
    dump("--- onDelegateCenter ")
    -- local dcenter = require("SellerShare.UIDelegateCenter").new()
    -- dcenter:addTo(self:getParent())    
    
    if self.showOnce then return end 
    SellerShareMgr:isAgent()
    self.showOnce = true

    -- timerMgr:registerTask("webview_show",timerMgr.TYPE_CALL_ONE, function()  self.showOnce = false  end , 2)
end

function UILobbBottom:onMyReward() 
    dump("--- onMyReward ")
    self:playNormal()
    if self.info_data and self.info_data.incomeUrl then
        self:createWebView(self.info_data.incomeUrl)
    end    
end

function UILobbBottom:onShareCenter() 
    dump("--- onShareCenter ",SellerShareMgr._appId)
     local uiss = require("SellerShare.UISellerShare").new()
     uiss:initPlayerInfo(SellerShareMgr._playerInfo_ss)
     uiss:setAppId(SellerShareMgr._appId)
     uiss:addTo(self:getParent())
end

function UILobbBottom:onService() 
    dump("--- onService ")
    -- local dcenter = require("SellerShare.UICallService").new()
    -- dcenter:addTo(self:getParent())

    platformMgr:jump2App("com.jumper.demo" , "this_xxxxxx")

    -- local function callfunc(data)
    --     msgMgr:showMsg("APP: ".. data or "null")
    -- end
    platformMgr:register_jumperCallback()
end

function UILobbBottom:updateAgentRedpoint(res)
    -- body
    if self.img_redpoint == nil then
        return
    end

    local num = res.num or 0
    print("updateAgentRedpoint num = ", num)
    if num > 0 then
        self.img_redpoint:setVisible(true)
        self.redpoint_num:setString(num)
    else
        self.img_redpoint:setVisible(false)
    end
end

function UILobbBottom:onBindDelegate()
    local bindui = require("SellerShare.UIBangDingDele").new()
    bindui:setData(self.delegateData)
    bindui:addTo(self:getParent())
end

return UILobbBottom