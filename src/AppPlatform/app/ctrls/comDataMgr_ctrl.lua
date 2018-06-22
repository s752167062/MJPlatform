--@公共数据管理类
--@Author   sunfan
--@date     2017/04/27
local ComDataMgr = class("ComDataMgr")

ComDataMgr.SHOP_TYPE = {
    FANGKA  = 0,
    GOLD = 1,
}
    
function ComDataMgr:ctor(params)
    self._writeObj = cc.UserDefault:getInstance()
    self:_init()
    self:_initWrite()
    self:_readInfo()
end

--统计所有需要序列化的字段
function ComDataMgr:_initWrite()
    self._writes = 
    {   

    }
end

function ComDataMgr:_init()
    -- body
    self._config = {}

    --@#####################实名认证部分#####################
    --是否认证成功
    self._config["shiming_success"] = false
    --实名名字
    self._config["shiming_name"] = ""
    --实名ID
    self._config["shiming_id"] = ""

    --@###################################################
    --第一次进入大厅
    self._config["isFirstEnterHall"] = true
    --进入大厅需要看看是否自动进入金币场
    self._config["isAutoEnterGoldMatch"] = false
    --测试录像用的
    self._config["oneAccountOneVideo"] = false 
    --录像数据数量(最多存放20盘大局录像)
    self._config["RECODE_MAX"] = 20 

    self._config["isAskDismissRoom"] = false 
    --第一次主动弹出邀请码界面
    self._config["isFirstOpenDelegateUI"] = true

    self._config["giftDelayTime"] = 0
    --@###################################################
    --游戏遁测试显示用
    self._config["isYXDTestMode"] = 0 --  0 不开显示模式 1开显示
    --游戏遁测试显示用
    self._config["isYXDTestSingleMode"] = 0 --  是否只用本地默认的组名 0 不开    1 只用默认组

    --录像调试---
    self._config["isVideoTestMode"] = 0 --是否开启录像调试 0关闭 1开启

    self._config["videoTestAccountID"] = 0 --录像只保存此账号录像


    singleMgr:register("app.ctrls.testConfig","testConfig",nil)

    if testConfig.TestMode == 1 then
        --调试模块
        singleMgr:register("app.ctrls.testMgr_ctrl","testMgr",nil)
        gameConfMgr:setInfo("useYXD",false)--测试服没有游戏盾
        gameConfMgr:setInfo("heartLog",false)
        gameConfMgr:setInfo("autoLogin",false) --调试时关闭自动登录 
        gameConfMgr:setInfo("isWX", false)

        local testUrl = "http://120.78.255.24:8888/Login_youruiTest"
        -- local testUrl = "http://192.168.1.251:8888/Login_youruiTest"
        -- local testUrl = "http://192.168.1.127:8888/Login_youruiTest"
        local loginURL = gameConfMgr:getInfo("loginURL")
        loginURL[0] = testUrl
        loginURL[GAME_NET_LINE.LINE_LIANTONG] = testUrl
        loginURL[GAME_NET_LINE.LINE_DIANXIN]  = testUrl
        loginURL[GAME_NET_LINE.LINE_YIDONG]   = testUrl

        local lastUserID = gameConfMgr:getInfo("lastLoginUserID")

        -- local account = math.random(0,100000)
        -- lastUserID = account
        -- gameConfMgr:setInfo("account", account)
        -- gameConfMgr:setInfo("lastLoginUserID", account)
        -- gameConfMgr:writeOne("lastLoginUserID")

        if lastUserID == 0 then
            local account = math.random(0,100000)
            gameConfMgr:setInfo("account", account)
            gameConfMgr:setInfo("lastLoginUserID", account)
            gameConfMgr:writeOne("lastLoginUserID")
        else
            gameConfMgr:setInfo("account", lastUserID)
        end

    elseif testConfig.TestMode == 2 then
        gameConfMgr:setInfo("useYXD",false)--测试服没有游戏盾
        gameConfMgr:setInfo("isWX", true)

        local testUrl = "http://120.78.255.24:8888/Login"
        local loginURL = gameConfMgr:getInfo("loginURL")
        loginURL[0] = testUrl
        loginURL[GAME_NET_LINE.LINE_LIANTONG] = testUrl
        loginURL[GAME_NET_LINE.LINE_DIANXIN]  = testUrl
        loginURL[GAME_NET_LINE.LINE_YIDONG]   = testUrl
    end
end

--设置信息
function ComDataMgr:setInfo(key,info)
    dump(info,"setInfo:"..key)
    self._config[key] = info
end

--获取信息
function ComDataMgr:getInfo(key)
    return self._config[key]
end

--
function ComDataMgr:setStringForKey(key, value)
    -- body
    self._writeObj:setStringForKey(key,value)
    dump(key.."="..value, "setStringForKey")
end

--需要本地序列化的信息(所有,游戏结束前序列化)
function ComDataMgr:writeAll()
    for loop = 1,#self._writes do
        if self._writes[loop] and self._config[self._writes[loop]] then
            if type(self._writes[loop]) == "boolean" then
                if self._config[self._writes[loop]] then
                    self:setStringForKey(self._writes[loop],"1")
                else
                    self:setStringForKey(self._writes[loop],"0")
                end
            else
                self:setStringForKey(self._writes[loop],""..self._config[self._writes[loop]])
            end
        end
    end
    self._writeObj:flush()
end

--指定序列化某个信息(立即序列化)
function ComDataMgr:writeOne(key)
    if not self._config[key] then
        return
    end
    for loop = 1,#self._writes do
        if self._writes[loop] then
            if self._writes[loop] == key then
                if type(self._writes[loop]) == "boolean" then
                    if self._config[self._writes[loop]] then
                        self:setStringForKey(self._writes[loop],"1")
                    else
                        self:setStringForKey(self._writes[loop],"0")
                    end
                else
                    self:setStringForKey(self._writes[loop],""..self._config[self._writes[loop]])
                end
            else
                self:setStringForKey(self._writes[loop],""..self._writeObj:getStringForKey(self._writes[loop]))
            end
        end
    end
    self._writeObj:flush()
end

--读取序列化过的字段
function ComDataMgr:_readInfo()
    for loop = 1,#self._writes do
        if self._writes[loop] then
            local info = self._writeObj:getStringForKey(self._writes[loop])
            if info and info ~= "" then
                printInfo(self._writes[loop].." = "..info)
                if type(self._writes[loop]) == "boolean" then
                    if tonumber(info) == 1 then
                        self._config[self._writes[loop]] = true
                    else
                        self._config[self._writes[loop]] = false
                    end
                elseif type(self._writes[loop]) == "number" then
                    self._config[self._writes[loop]] = tonumber(info)
                else
                    self._config[self._writes[loop]] = info
                end
            else
                dump("no exist info:"..self._writes[loop])
            end
        end
    end
end

function ComDataMgr:isGameAuto()
    -- body
    return false
end

return ComDataMgr
