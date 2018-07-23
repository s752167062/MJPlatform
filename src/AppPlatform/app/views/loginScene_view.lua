--@登录场景
--@Author   sunfan
--@date     2018/04/04
local LoginScene = class("LoginScene", cc.load("mvc").ViewBase)

function LoginScene:ctor()
    LoginScene.RESOURCE_FILENAME = __platformHomeDir .."ui/layout/LoginScene.csb"
    LoginScene.super.ctor(self)
end

function LoginScene:onCreate()

end

function LoginScene:onEnter()
    externGameMgr:exitGameByName()
    --重置登陆锁
    singleMgr:resetLock("login")
    --注册计时器
    timerMgr:register(self)
    self:_initUI()

    --初始化App跳转参数监听
    comFunMgr:initJumperLisiener()
    -- gameConfMgr:setInfo("LoginView2HallView",true)
    UrNetMgr:init()
    UrNetMgr:changeGroupKey("hhhhhhhhhhhhhhhhh")
end

function LoginScene:_initUI()
    --注册按钮事件
    self.ctn_start = self:getUIChild("btn_start")
    self.ctn_start:onClick(function () self:onGameStart() end)

    self.btn_guest = self:getUIChild("btn_guest")
    self.btn_guest:onClick(function () self:onGuestStart() end)

    --self.ctn_start:setJelly(true)
    self.txt_tips = self:getUIChild("txt_tips")
    self.bAgree = true
    self.ctn_agree = self:getUIChild("btn_agree")
    self.ctn_agree:onClick(function () self:onAgree() end)
    
    self.okFlag = self:getUIChild("checkmark")
    self.ctn_agreement = self:getUIChild("btn_agreement")
    self.ctn_agreement:onClick(function () self:onAgreement() end)

    self.ctn_proText = self:getUIChild("loadingText")
    self.ctn_proText:setVisible(false)
    
    eventMgr:registerEventListener("USER_CANCEL_WX_LOGIN",handler(self,self.userCancelWXLogin))

    self.cur_version = self:getUIChild("cur_version")
    self.cur_version:setString(updateMgr:getCurVersion())

    self.logo = self:getUIChild("logo")
    --播放动画
    local ac = cc.CSLoader:createTimeline(__platformHomeDir .."ui/layout/logoAni.csb")
    ac:play("ani0",true)
    self.logo:runAction(ac)

    --送审包不自动登录
    if gameConfMgr:getInfo("distribution") then 
        gameConfMgr:setInfo("autoLogin",false)
    end

    if gameConfMgr:getInfo("autoLogin") and gameConfMgr:getInfo("isWX") and not gameNetMgr:checkIsCallSDK() then
        --启动游戏的时候给自动登陆一次就OK
        gameConfMgr:setInfo("autoLogin",false)
        --注册一个自动登录任务
        timerMgr:registerTask("login",timerMgr.TYPE_CALL_ONE,handler(self,self.autoGameStart),0)
    end

    if gameConfMgr:getInfo("distribution") then 
        --想用微信登录的情况下 做wechat客户端检查
        if SDKMgr:isWeChatClientExit() == false then
            self.ctn_start:setVisible(false)
            self.btn_guest:setPosition(cc.p(568, 205))
        else
            self.ctn_start:setVisible(true)
            self.ctn_start:setPosition(cc.p(767, 205))
            self.btn_guest:setPosition(cc.p(329, 205))
        end 
    else
        self.btn_guest:setVisible(false)
        self.ctn_start:setPosition(cc.p(568, 205))

        --APPSTORE 审核没有微信客户端的情况下随机一个账号固定起来
        --想用微信登录的情况下 做wechat客户端检查
        if gameConfMgr:getInfo("isWX") then 
            gameConfMgr:setInfo("isWX"  ,SDKMgr:isWeChatClientExit()) -- 是否存在微信客户端 

            if not gameConfMgr:getInfo("isWX") then  -- android 默认返回true 
                dump(" ----- 无微信客户端 ----- IEMI 号登陆 同时动态处理 URL ")
                local imei = platformMgr:get_Device_IMEI() or "x0000_default"
                local imei_md5 = require("Manager.md5").sumhexa(imei) or "x0000_default_md5"
                gameConfMgr:setInfo("account" , imei_md5 )
            end 
        end
    end  
end

function LoginScene:update(dt)
    --检测登录锁是否发生变化
    if singleMgr:checkLockChange("login") then
        if singleMgr:checkLock("login") then
            --正在登录
            if gameConfMgr:getInfo("distribution") then 
                self.ctn_start:setVisible(false)
                self.btn_guest:setVisible(false)
            else
                self.ctn_start:setVisible(false)
            end

            self.ctn_proText:setVisible(true)
        else
            if gameConfMgr:getInfo("distribution") then 
                --未登录,可点击登录
                if SDKMgr:isWeChatClientExit() == false then
                    self.ctn_start:setVisible(false)
                else
                    self.ctn_start:setVisible(true)
                end
                self.btn_guest:setVisible(true)
            else
                self.ctn_start:setVisible(true)
            end
            self.ctn_proText:setVisible(false)
        end
    end
end

--用户取消微信登陆
function LoginScene:userCancelWXLogin()
    --归还登录锁，用户可点击按钮再次登录
    singleMgr:unlock("login")
    --弹出提示
    msgMgr:showMsg(msgMgr:getMsg("USER_CANCEL_WX_LOGIN_MSG"))
end

-- function LoginScene:gotoHall(data)
--     gameConfMgr:setInfo("playerName",data.nickname)
--     gameConfMgr:setInfo("cards",data.cart)
--     gameConfMgr:setInfo("gold",data.goldnum)
--     gameState:changeState(GAMESTATE.STATE_COMMHALL)
-- end 

function LoginScene:autoGameStart()
    self:onGameStart()
end

function LoginScene:onGameStart()
    if gameConfMgr:getInfo("distribution") then
        if SDKMgr:isWeChatClientExit() == false then
            platformMgr:open_APP_WebView("http://weixin.qq.com/")
            return
        end
        gameConfMgr:setInfo("isWX"  ,SDKMgr:isWeChatClientExit()) -- 是否存在微信客户端
    end

    --获取登陆锁
    if singleMgr:getlock("login") then
        timerMgr:clearTask("login")
        gameNetMgr:resetLoginPregress()
        gameNetMgr:gameStart(false,true)
    else
        msgMgr:showMsg(msgMgr:getMsg("LOGING"))
    end
end

function LoginScene:onGuestStart()
    gameConfMgr:setInfo("isWX",false)

    dump(" ----- 无微信客户端 ----- IEMI 号登陆 同时动态处理 URL ")
    local imei = platformMgr:get_Device_IMEI() or "x0000_default"
    local imei_md5 = require("Manager.md5").sumhexa(imei) or "x0000_default_md5"
    gameConfMgr:setInfo("account" , imei_md5 )

    --获取登陆锁
    if singleMgr:getlock("login") then
        timerMgr:clearTask("login")
        gameNetMgr:resetLoginPregress()
        gameNetMgr:gameStart(false,true)
    else
        msgMgr:showMsg(msgMgr:getMsg("LOGING"))
    end
end

function LoginScene:onAgree()
    self.bAgree = not self.bAgree
    self.okFlag:setVisible(self.bAgree)
    self.ctn_start:setEnabled(self.bAgree)
end

function LoginScene:onAgreement()
    viewMgr:show("provision_view")
end

function LoginScene:onExit()
    --重置登陆锁
    singleMgr:resetLock("login")
    timerMgr:unRegister(self)
    eventMgr:removeEventListenerForTarget("login_scene")
end

return LoginScene
