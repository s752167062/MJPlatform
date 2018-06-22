--@网络管理类
--@Author   sunfan
--@date     2017/04/27

local GameNetMgr = class("GameNetMgr")

function GameNetMgr:ctor(params)
    self._serverId      = 0
    self._serverIdArray     = {}
    self._sessionMgr = require("app.ctrls.socket.SessionManager"):new()
    timerMgr:register(self)
    self:inItLineState()
    GameNetMgr.ERR_NO_LINE          = 0--没有线路可选
    GameNetMgr.ERR_RE_EMPOWER       = 1--需要重新授权
    GameNetMgr.ERR_GETDATA_FAIL     = 2--从服务器获取信息失败
    GameNetMgr.ERR_SERVER_ERROR     = 3--服务器内部错误
    GameNetMgr.SERVER_MSG_ERROR     = 4--接收大厅信息错误
    self._loginProgress = 0
    self:_initIpRequest()
end

function GameNetMgr:update(dt)
    self:_checkIsGetIpAnd(dt)
end

function GameNetMgr:isSessionOpen()
    return self._sessionMgr:isSessionOpen()
end

function GameNetMgr:_checkIsGetIpAnd(dt)
    self._requestSpace = self._requestSpace + dt
    if self._requestSpace >= 2 then
        if not self:getIsExistIPAndLine() and not self:getIsRequestIP() then
            self:getUserIPAndLine(true)
        end
        self._requestSpace = 0
    end
end

--重置登录进度
function GameNetMgr:resetLoginPregress()
    self._loginProgress = 0
end

--获取登录进度
function GameNetMgr:getLoginPregress()
    return self._loginProgress
end

--设置登录进度
function GameNetMgr:setLoginPregress(value)
    self._loginProgress = value
end

--网络连接失败弹出处理框
function GameNetMgr:_handleNetFail(msg)
    msgMgr:showConfirmMsg(msg,function()
        --清理所有信息
        --gameConfMgr:clearAll()
        --跳转登录界面
        gameState:changeState(GAMESTATE.STATE_LOGIN)
        end)
end

--@微信登录部分

--@游戏登录开始
--@reconnect  是否断线重连
--@makeParams 是否需要重新生成登录参数
function GameNetMgr:gameStart(reconnect,makeParams)
    self._loginProgress = 1--登录进度
    if gameConfMgr:getInfo("isWX") and self:checkIsCallSDK() then
        --微信登录
        if reconnect then--断线重连不需要给他自动调起微信授权
            self:handleNetError(GameNetMgr.ERR_RE_EMPOWER)
        else
            self._loginProgress = 5--登录进度
            SDKMgr:sdkStart(handler(self,self.onGameStart))
        end
    else
        --免微信登录或者不需要调起SDK登录,直接启动
        self:onGameStart(makeParams)
    end
end

--检测是否需要调起SDK
function GameNetMgr:checkIsCallSDK()
    --免微信不需要调起SDK
    print("isWX", gameConfMgr:getInfo("isWX"))
    if not gameConfMgr:getInfo("isWX") then
        return false
    end

    print("code", gameConfMgr:getInfo("code"))
    --本地有code未使用不需要调起SDK
    if gameConfMgr:getInfo("code") ~= "" then
        return false
    end

    print("refreshToken", gameConfMgr:getInfo("refreshToken"))
    --本地有refreshToken不需要调起SDK
    if gameConfMgr:getInfo("refreshToken") ~= "" then
        return false
    end
    return true
end

--请求服务器登录数据
--@makeParams 是否需要重新生成登录参数
function GameNetMgr:onGameStart(makeParams)
    self._loginProgress = 10--登录进度
    self:request(self:getLoginParams(makeParams),handler(self,self._handleRequstResult))
end

--生成登录参数并加密
--@makeParams 是否需要重新生成登录参数
function GameNetMgr:getLoginParams(makeParams)
    self._loginProgress = 15--登录进度
    if makeParams or (not self._loginParams) then
        print("===============登录参数==================")
        local params = self:_getLoginParams()
        LOG(params)
        self._loginParams = self:choseEncodeType(gameConfMgr:getInfo("encode"),1,self:getReqString(params,gameConfMgr:getInfo("encode")))
    end
    return self._loginParams
end

--请求服务器获取登录信息
function GameNetMgr:request(params,callBack)
    self._loginProgress = 20--登录进度
    local nextLine = self:getNextLine()
    --没有线路可选
    if nextLine == GAME_NET_LINE.LINE_NO then
        self:handleNetError(GameNetMgr.ERR_NO_LINE)
        return
    end
    --登录进度
    self._loginProgress = 25
    local useWX = gameConfMgr:getInfo("isWX")
    if nextLine == GAME_NET_LINE.LINE_YOUXIDUN and useWX then
        --游戏遁线路
        self._loginProgress = 30--登录进度
        self:requestYUN(callBack ,params )
    else
        --高防线路
        self._loginProgress = 35--登录进度
        self:postJSONFromUrl(gameConfMgr:getLoginURL(nextLine,useWX),params ,callBack,true)
    end
end

--登录参数
function GameNetMgr:_getLoginParams()
    local loginParams = {
    --APPID
    a = gameConfMgr:getInfo("appId"),
    --用户唯一ID
    u = gameConfMgr:getInfo("account"),
    --平台
    p = 1,--gameConfMgr:getInfo("platform"),
    --版本
    v = gameConfMgr:getVersion(),
    --用户公网IP
    i = gameConfMgr:getInfo("Ip"),
    --微信登录参数
    s = gameConfMgr:getInfo("secret"),
    --微信登录参数
    c = gameConfMgr:getInfo("code")}
    if not loginParams.c or loginParams.c == "" then
        --微信登录refreshToken
        loginParams.s = nil
        loginParams.c = gameConfMgr:getInfo("refreshToken")
    end
    --非微信登录需提供另外约定的参数
    if not gameConfMgr:getInfo("isWX") then
        if loginParams.u == "" then
            local num = math.random(12,20)  --12  20
            for i=1,num do
                local tt = math.random(1,3)
                if tt == 1 then--数字
                    loginParams.u = loginParams.u .. math.random(0,9)
                elseif tt == 2 then--大写
                    loginParams.u = loginParams.u  .. string.char(math.random(65,90))
                else--小写
                    loginParams.u = loginParams.u  .. string.char(math.random(97,122))
                end
            end
        end
        loginParams.c = "sdfsdfdsff"
    end
    return loginParams
end

--JSON转化
function GameNetMgr:getReqString(tb,encode)
    local str = "["
    for k,v in pairs(tb) do
        str = str .. "{\"" .. self:choseEncodeType(encode,1,k) .. "\":\"" .. self:choseEncodeType(encode,1,v) .. "\"}"
        str = str .. ","
    end
    if string.len(str) > 0 then
        str = string.sub(str,1,string.len(str)-1)
    end
    str = str .. "]"
    return str
end

--加密
--chose表示是否加密，type(1加密 2解密) data数据
function GameNetMgr:choseEncodeType(chose,type,data)
    local deal_data = nil
    if chose == 1 then
        deal_data = cpp_DataEnCodeType1(type,data)
    end
    return deal_data
end

--登录请求回调
function GameNetMgr:_handleRequstResult(data,state ,errspone)
    cclog("GameNetMgr:_handleRequstResult >>>", data)
    self._loginProgress = 40--登录进度
    if data ~= nil and data ~= "" then
        self._loginProgress = 60--登录进度
        local rep = self:analyzeData(data)
        cclog("rep.flag >>>", rep.flag)
        if tonumber(rep.flag) ~= 6 then
            self._loginProgress = 65--登录进度
            --登录服出错
            self:handleNetError(GameNetMgr.ERR_GETDATA_FAIL,rep.flag,rep.msg)
            return
        end
        --服务器下发的是否重启游戏(暂时留着，不知道干啥用)
        local restart = rep.restart
        gameConfMgr:setInfo("shareUrl"      ,self:dealStr(rep.share_url))
        gameConfMgr:setInfo("pay_notifyUrl" ,rep.notifyUrl or "http://47.52.26.128:9200/now-pay/notify") --后续回调地址有服务器下发
        gameConfMgr:getInfo("h5pay_delegateid" , rep.delegateid)
        -- 是否提审服
        if rep.server_type then 
           LOG("   //// 提审标识 ： " .. rep.server_type)
           gameConfMgr:setInfo("server_type" , rep.server_type)
           gameConfMgr:setInfo("appstore_check"  , (tonumber(rep.server_type) == 1)) -- 1 true 提审
        end 

        gameConfMgr:setInfo("FRISTGN",rep.cloud)
        gameConfMgr:writeOne("FRISTGN")
        --检测是否更新
        self._loginProgress = 70--登录进度

        -- rep.hotUpdate = "192.168.1.200/qupai_hunanmajiang/hotUpdate/0.1.0a"
        -- rep.version = "0.1.0"
        -- local targetPlatform = cc.Application:getInstance():getTargetPlatform() 
        -- if targetPlatform == cc.PLATFORM_OS_ANDROID then
        --     rep.download = "192.168.1.200/qupai_hunanmajiang/0.1.0a"
        -- else
        --     rep.download = "192.168.1.200"
        -- end

        cclog("GameNetMgr:_handleRequstResult 333>>")
        -- if false then
        if string.len(rep.hotUpdate) > 0 or string.len(rep.download) > 0 then
            self._loginProgress = 75--登录进度
            launcherSceneMgr:setManage(updateMgr)
            updateMgr:updateStart({down_url = rep.download,updata_url = rep.hotUpdate, server_version = rep.version},
                --更新完的回调函数
                function(params) 
                    -- self:gotoHall(rep) 
                    msgMgr:showConfirmMsg(params.desc, function () os.exit(1) end)
                end)
        else
            self:gotoHall(rep)
        end 
    else
        self._loginProgress = 45--登录进度
        --服务器内部错误导致没有任何数据下发
        if state == 200 then
            self._loginProgress = 50--登录进度
            --错误处理,清除微信code,将会重新授权
            self:handleNetError(GameNetMgr.ERR_SERVER_ERROR)
        else
            self._loginProgress = 55--登录进度
            --没有任何数据也不是服务器内部错误(超时、网络连接失败等意外情况),切换线路
            self:gameStart(true,false)
        end
    end
end

--@登录大厅
function GameNetMgr:gotoHall(data)
    dump(data)

    self._loginProgress = 80--登录进度
    if tonumber(data.flag) == 6 then
        self._loginProgress = 90--登录进度
        --成功进入大厅,重置线路选择,保留当前线路选择
        self:inItLineState(gameConfMgr:getInfo("loginUseLine"))
        --先清除微信code信息
        gameConfMgr:clearWXCode()
        if data.token then
            gameConfMgr:setInfo("refreshToken",data.token)
            gameConfMgr:writeOne("refreshToken")
        end
        gameConfMgr:setInfo("userId",tonumber(data.id))
        -- gameConfMgr:setInfo("accountId",tonumber(data.accountId))
        gameConfMgr:setInfo("account",data.act)--todo ? 服务器是字符串--tonumber(data.act)
        gameConfMgr:setInfo("playerSex",tonumber(data.sex))
        gameConfMgr:setInfo("playerHeadURL",data.ico)
        gameConfMgr:setInfo("playerHeadName",data.id.."icon.png")
        gameConfMgr:setInfo("hostKey",data.key)
        gameConfMgr:setInfo("playerName",data.name)
        
        cclog("hostKey", data.key)


        self._sessionMgr:setHostIPAndPort(data.gateway)
        self._loginProgress = 95--登录进度
        self:netStart()
    else
        self._loginProgress = 85--登录进度
        self:handleNetError(GameNetMgr.SERVER_MSG_ERROR,data.flag)
    end
end

--打开网络连接
function GameNetMgr:netStart()
    self._sessionMgr:sessionStart()
end

--关闭(销毁)网络
function GameNetMgr:destorySession()
    self._sessionMgr:destorySession()
end

--网络错误处理
function GameNetMgr:handleNetError(type,msg,errmsg)
    if type == GameNetMgr.ERR_NO_LINE then--没有线路可选
        --清除网络选择状态
        self:inItLineState()
        --归还登录锁，用户可点击按钮再次登录
        singleMgr:unlock("login")
        --检测当前游戏状态机处于什么状态
        local m_state = gameState:getState()
        --若在大厅或者房间,跳回登陆界面
        if m_state == GAMESTATE.STATE_HALL or m_state == GAMESTATE.STATE_ROOM or m_state == GAMESTATE.STATE_CLUB or m_state == GAMESTATE.STATE_COMMHALL then
            --处理连接失败
            self:_handleNetFail(msgMgr:getMsg("SELECT_LINE_FAIL").."(code:"..self._loginProgress..")")
        else
            msgMgr:showMsg(msgMgr:getMsg("SELECT_LINE_FAIL").."(code:"..self._loginProgress..")")
        end
    elseif type == GameNetMgr.ERR_RE_EMPOWER then--重连时需要微信重新授权
        --@需要重新授权登录
        --归还登录锁，用户可点击按钮再次登录
        singleMgr:unlock("login")
        --检测当前游戏状态机处于什么状态
        local m_state = gameState:getState()
        --若在大厅或者房间,跳回登陆界面
        if m_state == GAMESTATE.STATE_HALL or m_state == GAMESTATE.STATE_ROOM or m_state == GAMESTATE.STATE_CLUB or m_state == GAMESTATE.STATE_COMMHALL then
            --处理连接失败
            self:_handleNetFail(msgMgr:getMsg("RE_EMPOWER").."(code:"..self._loginProgress..")")
        else
            msgMgr:showMsg(msgMgr:getMsg("RE_EMPOWER").."(code:"..self._loginProgress..")")
        end
    elseif type == GameNetMgr.ERR_GETDATA_FAIL then--请求登陆服服务器返回逻辑错误
        --先清除微信code信息
        gameConfMgr:clearWXCode()
        --归还登录锁，用户可点击按钮再次登录
        singleMgr:unlock("login")
        --检测当前游戏状态机处于什么状态
        local m_state = gameState:getState()
        --若在大厅或者房间,跳回登陆界面
        if m_state == GAMESTATE.STATE_HALL or m_state == GAMESTATE.STATE_ROOM or m_state == GAMESTATE.STATE_CLUB or m_state == GAMESTATE.STATE_COMMHALL then
            --处理连接失败
            self:_handleNetFail(msgMgr:getMsg("RE_CONNECT_FAIL").."(code:"..self._loginProgress..")")
        else
            if tonumber(msg) == 10 then--正在进行停服更新
                msgMgr:showConfirmMsg(errmsg)
            else
                msgMgr:showMsg(msgMgr:getMsg("GET_INFO_FAIL").."(code:"..self._loginProgress..")")
            end
        end
    elseif type == GameNetMgr.SERVER_MSG_ERROR then--接收大厅数据错误
        --先清除微信code信息
        gameConfMgr:clearWXCode()
        --归还登录锁，用户可点击按钮再次登录
        singleMgr:unlock("login")
        --检测当前游戏状态机处于什么状态
        local m_state = gameState:getState()
        --若在大厅或者房间,跳回登陆界面
        if m_state == GAMESTATE.STATE_HALL or m_state == GAMESTATE.STATE_ROOM or m_state == GAMESTATE.STATE_CLUB or m_state == GAMESTATE.STATE_COMMHALL then
            --处理连接失败
            self:_handleNetFail(msgMgr:getMsg("SERVER_MSG_ERROR").."(code:"..self._loginProgress..")")
        else
            msgMgr:showMsg(msgMgr:getMsg("SERVER_MSG_ERROR").."(code:"..self._loginProgress..")")
        end
    elseif type == GameNetMgr.ERR_SERVER_ERROR then--服务器内部错误
        --归还登录锁，用户可点击按钮再次登录
        singleMgr:unlock("login")
        --先清除微信code信息
        gameConfMgr:clearWXCode()
        --检测当前游戏状态机处于什么状态
        local m_state = gameState:getState()
        --若在大厅或者房间,跳回登陆界面
        if m_state == GAMESTATE.STATE_HALL or m_state == GAMESTATE.STATE_ROOM or m_state == GAMESTATE.STATE_CLUB or m_state == GAMESTATE.STATE_COMMHALL then
            --处理连接失败
            self:_handleNetFail(msgMgr:getMsg("SERVER_ERROR").."(code:"..self._loginProgress..")")
        else
            msgMgr:showMsg(msgMgr:getMsg("SERVER_ERROR").."(code:"..self._loginProgress..")")
        end
    else
        dump("unknow error type!")
    end
end

function GameNetMgr:dealStr(str)
    if str == nil or str == "" then 
        return str
    end
    local pid = cpp_buff_create()
    cpp_buffNew_writeString(pid,str)
    str = cpp_buffNew_readString(pid)
    cpp_buff_delete(pid)
    return str
end

--解析接收数据
function GameNetMgr:analyzeData(data)
    local data = self:choseEncodeType(gameConfMgr:getInfo("encode"),2,data)
    local tb = json.decode(data)
    local tmp_data = {}
    for k,v in pairs(tb) do
        if type(v) == "table" then
            for n,m in pairs(v) do
                tmp_data[string.format("%s",self:choseEncodeType(gameConfMgr:getInfo("encode"),2,n))] = self:choseEncodeType(gameConfMgr:getInfo("encode"),2,m)
            end
        else
            tmp_data[string.format("%s",self:choseEncodeType(gameConfMgr:getInfo("encode"),2,k))] = self:choseEncodeType(gameConfMgr:getInfo("encode"),2,v)
        end
    end
    return tmp_data
end

--重置网络线路选择状态
--@selectLine 表示初始化的时候某条置为已选择,否则全部置为未选择
--@lv:为-1时表示暂时不实用此条线路
function GameNetMgr:inItLineState(selectLine)
    --记录玩家每次所选择过的线路(都选过表示连接失败)
    self._selectedLine = {}
    self._selectedLine[#self._selectedLine + 1]  = {type = 1,times = 1,isSelect = false,lv = 1,line = GAME_NET_LINE.LINE_LIANTONG}
    self._selectedLine[#self._selectedLine + 1]  = {type = 1,times = 1,isSelect = false,lv = 1,line = GAME_NET_LINE.LINE_DIANXIN}
    self._selectedLine[#self._selectedLine + 1]  = {type = 1,times = 1,isSelect = false,lv = 1,line = GAME_NET_LINE.LINE_YIDONG}
    if gameConfMgr:getInfo("useYXD") then
        self._selectedLine[#self._selectedLine + 1]  = {type = 2,times = 1,isSelect = false,lv = 1,line = GAME_NET_LINE.LINE_YOUXIDUN}
    else
        self._selectedLine[#self._selectedLine + 1]  = {type = 2,times = 1,isSelect = false,lv = -1,line = GAME_NET_LINE.LINE_YOUXIDUN}
    end
    for loop = 1,#self._selectedLine do
        if self._selectedLine[loop].line == selectLine then
            self._selectedLine[loop].isSelect = true
        end
    end
end

--@设置运营商优先级
function GameNetMgr:_setCarrieroperator()
    --玩家当前运营商
    local line = gameConfMgr:getInfo("netLine")
    for loop = 1,#self._selectedLine do
        if self._selectedLine[loop].type == 1 then
            self._selectedLine[loop].lv = 1
            if self._selectedLine[loop].line == line then
                self._selectedLine[loop].lv = 2
            end
        end
    end
end

--游戏线路选择
function GameNetMgr:getNextLine()
    --设置运营商优先级
    self:_setCarrieroperator()
    --按当前规则选择出来的线路
    local s_line = nil
    for loop = 1,#self._selectedLine do
        if self._selectedLine[loop].lv ~= -1 and self._selectedLine[loop].isSelect == false then
            if not s_line then
                s_line = self._selectedLine[loop]
            else
                if self._selectedLine[loop].lv > s_line.lv then
                    s_line = self._selectedLine[loop]
                end
            end
        end
    end
    if s_line then
        self:_showNetMsg(s_line.line)
        --选择成功,记录网络状态
        gameConfMgr:setInfo("loginUseLine",s_line.line)
    else
        self:_showNetMsg(GAME_NET_LINE.LINE_NO)
        gameConfMgr:setInfo("loginUseLine",GAME_NET_LINE.LINE_NO)
    end
    if s_line then
        s_line.times = s_line.times - 1
        --加入次数衰减,以增加某一条线路的命中率
        if s_line.times <= 0 then
            s_line.isSelect = true
        end
        return s_line.line
    else
        --选择失败
        return GAME_NET_LINE.LINE_NO
    end
end

function GameNetMgr:_showNetMsg(line)
    if line == GAME_NET_LINE.LINE_NO then
        LOG(msgMgr:getMsg("LINE_NO"))
    elseif line == GAME_NET_LINE.LINE_LIANTONG then
        LOG(msgMgr:getMsg("LINE_LIANTONG"))
    elseif line == GAME_NET_LINE.LINE_DIANXIN then
        LOG(msgMgr:getMsg("LINE_DIANXIN"))
    elseif line == GAME_NET_LINE.LINE_YIDONG then
        LOG(msgMgr:getMsg("LINE_YIDONG"))
    elseif line == GAME_NET_LINE.LINE_YOUXIDUN then
        LOG(msgMgr:getMsg("LINE_YOUXIDUN"))
    end
end

--游戏遁访问
function GameNetMgr:requestYUN(callBack ,params ) 
    local yunIp , port = self:getYunIP()
    release_print("---- yun gamenet : " , yunIp  ,port )
    if yunIp ~= nil and yunIp ~= "" and port > 0 then
        self:postJSONFromUrl("http://" .. yunIp .. ":" .. port .. "/Login", params ,callBack,true)
        return true
    end
    if callBack then
        callBack()
    end
end

--获取游戏遁IP
function GameNetMgr:getYunIP(game_port)
    local base_port = game_port 
    if base_port == nil or base_port == "" or base_port == 0 then 
        base_port = gameConfMgr:getInfo("base_gamePort")
    end  
    --优先使用 服务器下发的组名  
    local groupname = gameConfMgr:getInfo("FRISTGN")
    if groupname == nil or groupname == "" then 
        --默认组名
        release_print("--- use base group ---")
        groupname = gameConfMgr:getInfo("gameyun_groupname")
    end  
    release_print("--- use  group ---",groupname)
    local ip  , port = platformMgr:get_yunIp_by_groupName(groupname ,gameConfMgr:getInfo("userId") or "token", base_port)
    return ip , port 
end


--@网络层公共函数部分
function GameNetMgr:ChangeToYun(baseurl , yunpartment)
    if baseurl ~= nil and yunpartment ~= nil then
		if yunpartment == "" then 
            return baseurl
		end
		
        local last = string.sub(baseurl,string.find(baseurl,":",7,true) , string.len(baseurl))
        if last ~= nil and last ~= "" then 
            return "http://" .. yunpartment .. last
        end
	end
end

---------下载
function GameNetMgr:DownloadFile(url , filename , callfunc)
    if url == nil or filename == nil then
        return 
    end
    LOG("开始下载文件 " .. url)
    if true then
        local xhr = cc.XMLHttpRequest:new()
        xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER
        xhr:open("GET", url)
        local function onReadyStateChanged()
            if xhr.readyState == 4 and xhr.status == 200 then
                local response = xhr.response
                local size     = table.getn(response)
                LOG("Http Status Code:" .. xhr.statusText .. ",size=" .. size)
                local file = io.open(writePathManager:getAppPlatformWritePath().."/"..filename,"wb")
                for i = 1, size do
                    file:write(string.char(response[i]))
                end
                file:close() 
                if callfunc then 
                    callfunc() 
                end 
            else
                LOG("xhr.readyState is:" .. xhr.readyState .. ",xhr.status is: " .. xhr.status)
            end
            xhr:unregisterScriptHandler()
        end
        xhr:registerScriptHandler(onReadyStateChanged)
        xhr:send()
    end
end

-- http 请求
function GameNetMgr:getJSONFromUrlOut8(path,func,async)
    local fun = func
    local isTimeOut = false
    local function timeout()
        if isTimeOut == false then 
            if fun then
                fun(nil)
                fun = nil
            end
        end   
    end
    GameNetMgr:timeOutCallfunc(4 , timeout) 

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET",path,async)
    --    xhr.timeout = 6  // ???
    local function onReady()
        LOG("HTTP STATUS :"..xhr.status)
        if xhr.status == 200 and isTimeOut == false and fun~= nil then
            fun(xhr.response , nil)
            fun = nil
        elseif fun ~= nil then 
            fun(nil, xhr.status , xhr.response)
            fun = nil
        end
    end
    xhr:registerScriptHandler(onReady)
    xhr:setRequestHeader("Content-Type","application/x-www-form-urlencoded;charset=utf-8")
    xhr:send()
end

-- http 请求
function GameNetMgr:getJSONFromUrl(path,fun,async)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET",path,async)
    xhr.timeout = 10
    local function onReady()
        LOG("HTTP STATUS :"..xhr.status)
        if xhr.status == 200 then
            fun(xhr.response , nil)
        else
            fun(nil, xhr.status , xhr.response)
        end
    end
    xhr:registerScriptHandler(onReady)
    xhr:setRequestHeader("Content-Type","application/x-www-form-urlencoded;charset=utf-8")
    xhr:send()
end

function GameNetMgr:postJSONFromUrl(path,data,fun,async)
    LOG("Client request:"..path)
    if comDataMgr:getInfo("isYXDTestMode") == 1 then --游戏遁测试显示用
        comDataMgr:setInfo("isYXDTestMode_httpPath" , path)
    end 
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("POST",path,async)
    xhr.timeout = 5
    local function onReady()
        LOG("HTTP STATUS :"..xhr.status)
        if xhr.status == 200 then
            fun(xhr.response , nil)
        else
            fun(nil, xhr.status)
        end
    end
    xhr:registerScriptHandler(onReady)
    xhr:setRequestHeader("Content-Type","application/x-www-form-urlencoded;charset=utf-8") 
    xhr:send(data)
end

-- http 请求
function GameNetMgr:getStringFromUrl(path,fun,async,timeout)
    LOG("request:"..path)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET",path,async)
    xhr.timeout = timeout or 15
    local function onReady()
        LOG("HTTP STATUS :"..xhr.status)
        if xhr.status == 200 then
            fun(xhr.response ,nil )
        else
            fun(nil, xhr.status)
        end
    end
    xhr:registerScriptHandler(onReady)
    xhr:send()
end

function GameNetMgr:downloadFileFromUrl(url , func)

end

function GameNetMgr:HttpCharEncode(str)
    local news = ""
    if str ~= nil and string.len(str) > 0 then
        news = string.gsub(str ,"%%","%%25",nil)
        news = string.gsub(news,"%+","%%2B",nil)
        news = string.gsub(news,"% ","%%20",nil)
        news = string.gsub(news,"%/","%%2F",nil)
        news = string.gsub(news,"%#","%%23",nil)
        news = string.gsub(news,"%&","%%26",nil)
        news = string.gsub(news,"%=","%%3D",nil)
    end
    return news
end

function GameNetMgr:HttpCharDecode(str)
    local news = ""
    if str ~= nil and string.len(str) > 0 then
        news = string.gsub(str ,"%%2B","%+",nil)
        news = string.gsub(news,"%%20","% ",nil)
        news = string.gsub(news,"%%2F","%/",nil)
        news = string.gsub(news,"%%23","%#",nil)
        news = string.gsub(news,"%%26","%&",nil)
        news = string.gsub(news,"%%3D","%=",nil)
        news = string.gsub(news,"%%25","%%",nil)
    end
    return news
end

function GameNetMgr:_initIpRequest()
    --获取公网IP
    --http://1212.ip138.com/ic.asp 解析
    local function callfunc_1(respone)
        if respone ~= nil and respone ~= "" then
            local start = string.find(respone , "[" , 1 , true)
            local endp = string.find(respone , "]" , 1 , true)
            local ipstr = nil
            if start ~= nil and endp ~= nil then
                ipstr = string.sub(respone,start + 1,endp -1)
            end
            if ipstr then
                self:_setIPAndLine(ipstr,"http://2017.ip138.com/ic.asp->IP ")
            end
        else
            self:getUserIPAndLine(false)
        end
    end

    --https://ipip.yy.com/get_ip_info.php 解析
    local function callfunc_2(respone)
        if respone ~= nil and respone ~= "" then
            local start = string.find(respone , "{" , 1 , true)
            local endp = string.find(respone , "}" , 1 , true)
            local ipstr = nil
            if start ~= nil and endp ~= nil then
                local str = string.sub(respone,start + 1,endp -1)
                if str and str ~= "" then
                    local data = string.split(str,",")
                    for loop = 1,#data do
                        if data[loop] then
                            local value = string.split(data[loop],":")
                            if #value >= 2 then
                                if self:_deleteMark(value[1]) == "cip" then
                                    ipstr = self:_deleteMark(value[2])
                                    break
                                end
                            end
                        end
                    end
                end
            end
            if ipstr ~= nil then
                self:_setIPAndLine(ipstr,"https://ipip.yy.com/get_ip_info.php->IP ")
            end
        else
            self:getUserIPAndLine(false)
        end
    end
    --http://whois.pconline.com.cn/ipJson.jsp?callback={IP:255.255.255.255} 解析
    local function callfunc_3(respone)
        if respone ~= nil and respone ~= "" then
            local index = string.find(respone , "ip" , 1 , true)
            local str = string.sub(respone,index - 1,string.find(respone , "}" , index , true) - 1)
            local ipstr = nil
            if str and str ~= "" then
                local data = string.split(str,",")
                for loop = 1,#data do
                    if data[loop] then
                        local value = string.split(data[loop],":")
                        if #value >= 2 then
                            if self:_deleteMark(value[1]) == "ip" then
                                ipstr = self:_deleteMark(value[2])
                                break
                            end
                        end
                    end
                end
            end
            if ipstr ~= nil then
                self:_setIPAndLine(ipstr,"http://whois.pconline.com.cn/ipJson.jsp->IP ")
            end
        else
            self:getUserIPAndLine(false)
        end
    end
    --http://www.ip168.com/json.do?view=myipaddress 解析
    local function callfunc_4(respone)
        if respone ~= nil and respone ~= "" then
            local start = string.find(respone , "[" , string.find(respone , "IP" , 1 , true) , true)
            local endp = string.find(respone , "]" , string.find(respone , "IP" , 1 , true) , true)
            local ipstr = nil
            if start ~= nil and endp ~= nil then
                ipstr = string.sub(respone,start + 1,endp -1)
            end
            if ipstr ~= nil then
                self:_setIPAndLine(ipstr,"http://www.ip168.com/json.do?view=myipaddress->IP ")
            end
        else
            self:getUserIPAndLine(false)
        end
    end
    self._requestData = {}
    self._requestData[#self._requestData + 1] = {url = "http://2017.ip138.com/ic.asp" ,callback = callfunc_1}
    self._requestData[#self._requestData + 1] = {url = "https://ipip.yy.com/get_ip_info.php" ,callback = callfunc_2}
    self._requestData[#self._requestData + 1] = {url = "http://whois.pconline.com.cn/ipJson.jsp?callback={IP:255.255.255.255}" ,callback = callfunc_3}
    self._requestData[#self._requestData + 1] = {url = "http://www.ip168.com/json.do?view=myipaddress" ,callback = callfunc_4}
    self._searchIndex = #self._requestData + 1
    --请求间隔计数
    self._requestSpace = 2
end

function GameNetMgr:getUserIPAndLine(isFirst)
    if isFirst then
        self._searchIndex = 1
    end
    if self._searchIndex <= #self._requestData then
        self:getPublicIP(self._requestData[self._searchIndex].callback,self._requestData[self._searchIndex].url)
        self._searchIndex = self._searchIndex + 1
    end
end

--是否正在获取IP状态
function GameNetMgr:getIsRequestIP()
    return self._searchIndex <= #self._requestData
end

--是否已经获取到IP
function GameNetMgr:getIsExistIPAndLine()
    return gameConfMgr:getInfo("Ip") ~= "" and gameConfMgr:getInfo("netLine") ~= GAME_NET_LINE.LINE_NO
end

function GameNetMgr:_setIPAndLine(ipstr,log)
    print("setIPAndLine ip = "..ipstr)
    gameConfMgr:setInfo("Ip",ipstr)
    --获取网络运营商
    local function callBack(response)
        if response then
            local tb = json.decode(response)
            if tb then
                if tb["data"] then
                    if tb["data"]["isp"] == "电信" then
                        LOG("电信")
                        gameConfMgr:setInfo("netLine",GAME_NET_LINE.LINE_DIANXIN)
                    elseif tb["data"]["isp"] == "联通" then
                        LOG("联通")
                        gameConfMgr:setInfo("netLine",GAME_NET_LINE.LINE_LIANTONG)
                    end
                end
            end
        end
    end
    self:getJSONFromUrl("http://ip.taobao.com/service/getIpInfo.php?ip=".. ipstr,callBack,true,1)
end

--删除前后双引号
function GameNetMgr:_deleteMark(str)
    local data = ""
    for loop = 1,string.len(str) do
        local a = string.sub(str,loop,loop)
        if a ~= "\"" then
            data = data..a
        end
    end
    return data
end

--获取公网IP
function GameNetMgr:getPublicIP(callfunc,url)
    self:getStringFromIP(url,callfunc,true);
end

-- http 请求
function GameNetMgr:getStringFromIP(path,fun,async,timeout)
    LOG("request:"..path)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET",path,async)
    xhr.timeout = timeout or 3
    local function onReady()
        LOG("HTTP STATUS :"..xhr.status)
        if xhr.status == 200 then
            fun(xhr.response ,nil )
        else
            fun(nil, xhr.status)
        end
    end
    xhr:registerScriptHandler(onReady)
    xhr:send()
end

function GameNetMgr:sendData(obj)
    if self._sessionMgr then
        self._sessionMgr:sendData(obj)
    end
end

function GameNetMgr:registReceiveHandler(handler)
    if self._sessionMgr then
        self._sessionMgr:registReceiveHandler(handler)
    end
end

function GameNetMgr:removeReceiveHandler()
    if self._sessionMgr then
        self._sessionMgr:removeReceiveHandler()
    end
end

function GameNetMgr:resetLineState(target)
    if self._sessionMgr then 
        return self._sessionMgr:resetLineState(target)
    end
end 

function GameNetMgr:saveServerIdArray(str)
    if not str or str== "" then
        return
    end
    local dkj = require "app.helper.dkjson"
    local map_tab = dkj.decode(str)
    map_tab = map_tab.serverList
    for loop = 1,#map_tab do
        if map_tab[loop] then
            self._serverIdArray[map_tab[loop].serverId] = map_tab[loop].serverType
        end
    end
    dump(self._serverIdArray)
end

function GameNetMgr:getServerTypeByServerId(serverId)
    if self._serverIdArray and self._serverIdArray[serverId] then
        return self._serverIdArray[serverId]
    end
    return -1
end

function GameNetMgr:getServerTypeByCurrent()
    if self._serverIdArray and self._serverIdArray[self._serverId] then
        return self._serverIdArray[self._serverId]
    end
    return -1
end

function GameNetMgr:setServerId(serverId)
    self._serverId = serverId
end

function GameNetMgr:getServerId()
    return self._serverId
end

return GameNetMgr
