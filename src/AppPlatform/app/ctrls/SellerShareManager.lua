--[[
	说明：
	1、
	-- require ("SellerShare.SellerShareManager")--.new()
    -- SellerShareManager:registeNetAgreement()--注册分销的大厅协议

    SellerShareMgr:registeNetAgreement()--注册分销的大厅协议

    1.1、
    local pinfo = {}
    pinfo.imgheadPath = cc.FileUtils:getInstance():getWritablePath().."/".. gameConfMgr:getInfo("playerHeadName") 
    pinfo.name      = gameConfMgr:getInfo("playerName")  --PlayerInfo.nickname
    pinfo.id        = gameConfMgr:getInfo("userId")      --PlayerInfo.account 
    pinfo.union_id  = gameConfMgr:getInfo("account")     --PlayerInfo.unionid 
    pinfo.IP        = gameConfMgr:getInfo("Ip")          --PlayerInfo.ip
    
    SellerShareMgr:init(pinfo , gameConfMgr:getInfo("appId" ,"gxmj")) -- 填写各自游戏的内容
    SellerShareMgr:setRoot(self) --根节点
    SellerShareMgr:addLobbyBottomUI() --底部按钮
    SellerShareMgr:addRewardChest()   --红包按钮

    -- SellerShareMgr:getMy_AgentCenter_Msg() --请求代理信息

	2、
	-- CCXNotifyCenter:notify("CloseUIWebView" ,nil)-- 关闭webview （在网络断开 重连不上后如果提示玩家重新登录 在提示前的代码需要加上这句）
    eventMgr:dispatchEvent("CloseUIWebView",{})

	3、
	SDKControler 的微信分享相关内容需要修改

    --注意 
]]

--@分销管理器
-- local Write = require("app.ctrls.socket.Write")
local SellerShareManager = class("SellerShareManager")
function SellerShareManager:ctor(params)

end

SellerShareManager._playerInfo_ss = nil ;
SellerShareManager._appId 		  = nil ;
SellerShareManager._GAME_TYPE     = nil ; --gxmj

function SellerShareManager:init(playerInfo , appid , gametype)
	SellerShareManager._playerInfo_ss = playerInfo
	SellerShareManager._appId		  = appid
	SellerShareManager._GAME_TYPE     = gametype
    -- 注册大厅的协议
	-- self:registeNetAgreement()
end

function SellerShareManager:setRoot(node)
    if node then 
        self.node = node
    end    
end

--二期界面
function SellerShareManager:addLobbyBottomUI()
    local bottm = require("SellerShare.UILobbBottom").new()
    bottm:setName("ui_lobbBtn")
    bottm:addTo(self.node)
end

function SellerShareManager:setLobbyBottomUIVisible(bool)
    if self.node and self.node:getChildByName("ui_lobbBtn") then
        self.node:getChildByName("ui_lobbBtn"):setVisible(bool)
    end    
end

function SellerShareManager:addRewardChest(position)
    local chest = require("SellerShare.item_chest").new()
    chest:setPosition(position or self:chestBtnPosition())
    chest:setName("ui_chestBtn")
    chest:addTo(self.node)
end  

function SellerShareManager:setRewardChestVisible(bool)
    if self.node and self.node:getChildByName("ui_chestBtn") then
        self.node:getChildByName("ui_chestBtn"):setVisible(bool)
    end  
end    

function SellerShareManager:chestBtnPosition()
    local size = cc.Director:getInstance():getVisibleSize()
    local x = size.width - 100
    local y = size.height / 2 + 100
    return cc.p(1078,350)
end

function SellerShareManager:showToast(msg,func)
    local dialog = require("SellerShare.UIDialog").new()
    dialog:showMsg(msg,func)
    dialog:addTo(self.node);
end

---------下载
function SellerShareManager:DownloadFile(url , filename , callfunc)
    if url == nil or filename == nil then
    	return 
    end
    dump(" ------- 开始下载文件 " .. url)
    if true then
        local xhr = cc.XMLHttpRequest:new()
        xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER
        xhr:open("GET", url)
        local function onReadyStateChanged()
            if xhr.readyState == 4 and xhr.status == 200 then
                local response = xhr.response
                local size     = table.getn(response)
                release_print("Http Status Code:" .. xhr.statusText .. ",size=" .. size)
                local file = io.open(writePathManager:getAppPlatformWritePath().."/"..filename,"wb")
                for i = 1, size do
                    file:write(string.char(response[i]))
                end
                file:close() 
                if callfunc then 
                    callfunc() 
                end 
            else
                release_print("xhr.readyState is:" .. xhr.readyState .. ",xhr.status is: " .. xhr.status)
            end
            xhr:unregisterScriptHandler()
        end
        xhr:registerScriptHandler(onReadyStateChanged)
        xhr:send()
    end
end

-- 字符串切分成数组
function SellerShareManager:split(s, delim)
    if type(delim) ~= "string" or string.len(delim) <= 0 then
        return
    end

    local start = 1
    local t = {}
    while true do
        local pos = string.find (s, delim, start, true) -- plain find
        if not pos then
            break
        end

        table.insert (t, string.sub (s, start, pos - 1))
        start = pos + string.len (delim)
    end
    table.insert (t, string.sub (s, start))

    return t
end

-- 字符串去除指定字符
function SellerShareManager:removeChar(s , char)
	if type(char) ~= "string" or string.len(char) <= 0  then
		return 
	end
	
	local start = 1 
	local newStr = ""
	while true do
        release_print(" ------ ", s,char,start)
        print_r(s)
		local pos = string.find(s,char,start,true) 
		if not pos then
			break
		end
		
        newStr = newStr .. string.sub(s, start, pos - 1)
        start = pos + string.len(char)
	end
    newStr = newStr .. string.sub (s, start)
    return newStr
end

function SellerShareManager:makeFileNameByURL(URL)
    dump(type(URL).. " /// SS URL " .. (URL or ""))
    -- if URL == nil or URL == "" then
    --     return "default.png"
    -- end

    -- local filename = string.sub(URL, -10)
    -- if not string.find(filename,".png",1) then 
    --     filename = os.date("%d_")..filename .. ".png"
    -- end

    -- filename = self:removeChar(filename , "/")
    -- return filename

    -- --换成MD5
    if URL == nil or URL == "" then
        return "default.png"
    end
    local url_md5 = require("Manager.md5").sumhexa(URL) or "x0000_default_md5"
    if not string.find(url_md5,".png",1) then 
        url_md5 = url_md5 .. ".png"
    end
    dump(" //// SS FILE NAME " .. url_md5)
    return url_md5
end

---------2期内容
--联系客服界面
function SellerShareManager:show_UI_Customer_service()
    
end

--成为代理界面
function SellerShareManager:show_UI_tobe_Agent()
    
end

--代理中心界面
function SellerShareManager:show_UI_Agent_center()
    
end

--新用户红包
function SellerShareManager:show_UI_newUser_red_envelopes(money)
    local uiss = require("SellerShare.UINewUserReward").new()
    uiss:initData(money)
    release_print(" new ------- user red - " , self.node)
    uiss:addTo(self.node)
end

--钱袋
function SellerShareManager:show_UI_wallet(data)
    local myreward = require("SellerShare.UImyReward").new()
    myreward:initData_NEW(data)
    myreward:addTo(self.node);
end

--我的收入中心
function SellerShareManager:show_UI_My_income()
    
end

function SellerShareManager:Pay(name , price , userData , ip , starttime, pid ,gametype ,notifyurl)
    local H5P_STATUS = gameConfMgr:getInfo("H5P_STATUS")
    if H5P_STATUS == true then
        dump("H5P _ ")
        self:payWeb( pid , gametype ,price)
        return
    end

    if gameConfMgr:getInfo("IAPPay") == true then 
        -- Appstore 支付
        platformMgr:IAP_PAY(pid)
    else
        -- 微信支付
        local data = { name =name  , price =tostring(price), userdata =tostring(userData) , server_time =tostring(starttime) , goodsid=tostring(pid) , notifyUrl=notifyurl ,extr_data=gametype }
        print_r(data)
        SDKMgr:sdkNowPay(json.encode(data) ,nil) 
    end    
end

function SellerShareManager:payWeb( GOODSID , gametype ,money ,num, protype)
    -- dump(" WEB P 5", money)
    -- local H5P_URL = gameConfMgr:getInfo("H5P_URL")
    -- if H5P_URL and H5P_URL ~= "" then
    --     local size       = cc.Director:getInstance():getVisibleSize()
    --     local action     = cc.MoveTo:create(0.3 , cc.p(0,0))

    --     local url_ = string.format("%s&gameCommodityId=%s&gameName=%s&money=%s",H5P_URL , tostring(GOODSID or "") , gametype or "" ,tostring(money))
    --     dump(" URL ", url_)
    --     local web = require("SellerShare.UIWebView").new()
    --     web:setName("uiwebview")
    --     web:reSizeForPay()
    --     web:initData(url_)
    --     web:setPosition(cc.p(0,cc.Director:getInstance():getVisibleSize().height))
    --     web:runAction(action)
    --     web:addTo(self.node)
    -- else
    --     self:showToast(" H5P ERR ");
    -- end  

    local h5ui = require("SellerShare.UIH5Pay").new()
    h5ui:setName("uiwebview")
    h5ui:initProduct({ pid = GOODSID , money = money, cards = num or 0, protype = protype or 0 })
    h5ui:addTo(self.node)
end

--3期


SellerShareManager.BASE_BOX = 2111
SellerShareManager.EXCHANGE_CARD_BOX = 2112
SellerShareManager.EXCHANGE_BILL_BOX = 2113

function SellerShareManager:showTipsBox(type,data,callfunc)
    local tipsbox = require("SellerShare.UITipsBox").new()
    tipsbox:addTo(self.node);

    if type == SellerShareManager.BASE_BOX then 
        tipsbox:showTipsBase(data,callfunc)
    elseif type == SellerShareManager.EXCHANGE_CARD_BOX then 
        tipsbox:showCardsExchange(data,callfunc)
    elseif type == SellerShareManager.EXCHANGE_BILL_BOX then
        tipsbox:showBillExchange(data,callfunc)
    end     
end

function SellerShareManager:timeOutCallfunc(time , callfunc)
    local scheduler = cc.Director:getInstance():getScheduler()  
    local schedulerID = nil  
    schedulerID = scheduler:scheduleScriptFunc(function()  
        if callfunc then callfunc() end
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)   
    end,time,false, "platform")    
end

--注册协议
function SellerShareManager:registeNetAgreement()
    if true then
        return true
    end
    dump(" 注册协议 ---****---  hallHandler " )
    hallHandler._proFuns[1009] = handler(self,self.onSendMsg2Service )
    hallHandler._proFuns[1105] = handler(self,self.onUser_acquire_account   )
    hallHandler._proFuns[1106] = handler(self,self.onUser_bind_superior_account )
    hallHandler._proFuns[1107] = handler(self,self.onUser_acquire_junior_account    )
    hallHandler._proFuns[1109] = handler(self,self.onReceive_my_newUser_red_envelopes   )
    hallHandler._proFuns[1121] = handler(self,self.onGetMy_AgentCenter_Msg  )
    hallHandler._proFuns[1123] = handler(self,self.onRequireDelegateCenter_data )
    hallHandler._proFuns[1124] = handler(self,self.onExchange_card  )
    hallHandler._proFuns[1125] = handler(self,self.onDelegaetCenter_status_update   )   --下行 收到代理状态修改

    hallHandler._proFuns[1126] = handler(self,self.onGiveCard_to_User   )
    hallHandler._proFuns[1127] = handler(self,self.onGiveCard_to_User_history_data  )

    hallHandler._proFuns[1128] = handler(self,self.onUpdate_My_wallet_NEW   )       -- 替换1108 协议
    hallHandler._proFuns[1129] = handler(self,self.onCheckMy_red_envelopes_NEW  )   -- 替换1122 协议
    hallHandler._proFuns[1130] = handler(self,self.onReceive_my_wallet_NEW  )       -- 替换1120 协议
    hallHandler._proFuns[1131] = handler(self,self.onReceive_List   )               -- 获得兑换商品列表
    hallHandler._proFuns[1132] = handler(self,self.onCheckPassword  )               -- 检查是否设置了交易密码
    hallHandler._proFuns[1133] = handler(self,self.onExchange_commodity )           -- 兑换商品
    hallHandler._proFuns[1134] = handler(self,self.onMerge_cash )                   -- 合并收益
    hallHandler._proFuns[1135] = handler(self,self.onH5PayCheck )                   -- 检查支付类型


    hallHandler._proFuns[1140] = handler(self,self.onIsAgent)  -- 检查是否代理和拿URL
    hallHandler._proFuns[1141] = handler(self,self.onAgentRedpoint) -- 请求有多少个邀请代理
    hallHandler._proFuns[1142] = handler(self,self.onDelegateIDCheck) -- 代理ID较验是否合法
    hallHandler._proFuns[1143] = handler(self,self.onCheckDelegateStatus) -- 检查是否绑定了代理或者自己是否为代理 
    hallHandler._proFuns[1144] = handler(self,self.onBindDelegate) -- 请求绑定代理
    hallHandler._proFuns[1145] = handler(self,self.onPayUrl) -- 请求获取支付的Url
end

--------------------协议 -------------------

----------获取账号信息
function SellerShareManager:User_acquire_account(appid)
	dump(" 请求获取账号信息 1105")
    local obj = Write.new({proid = 1105,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:writeString(appid)
    obj:send()
end

function SellerShareManager:onUser_acquire_account(obj)
	dump(" 获取账号信息 回调 1105")
    local res = {}
    res.inviteCode   = obj:readString()  --邀请码
    res.qrCodeUrl    = obj:readString()  --二维码地址
    res.numOfJunior  = obj:readInt()     --推荐好友数量
    res.wallet       = obj:readInt()     --收益余额 分
    res.convertUrl   = obj:readString()  --兑换URL
    res.toCashUrl    = obj:readString()  --体现URL
    res.checkInComeUrl = obj:readString()-- 查看收益情况URL

    if obj:readBoolean() then 
        res.superior_iconUrl  = obj:readString()
        res.superior_nickname = obj:readString()
        res.superior_id       = obj:readLong()
    end  
    print_r(res)
    eventMgr:dispatchEvent("onUser_acquire_account",res)
end

-----------绑定上级账号
function SellerShareManager:User_bind_superior_account(inviteCode)
	dump(" 请求绑定上级账号 1106")
    local obj = Write.new({proid = 1106,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:writeString(inviteCode)
    obj:send()
end

function SellerShareManager:onUser_bind_superior_account(obj)
	dump(" 绑定上级账号 回调 1106")
    local res = {}
    res.success             = obj:readBoolean() --是成功
    res.hasbind             = obj:readBoolean() --是否绑定了上级
    res.superior_nickname   = obj:readString()  --上级账号昵称
    res.superior_iconUrl    = obj:readString()  --绑定的上级账号ICON
    res.superior_id         = obj:readLong()    --上级账号id
    -- res.card_num            = obj:readInt(pid)     --赠送房卡数

    print_r(res)
    eventMgr:dispatchEvent("onUser_bind_superior_account",res)
end

-----------获取下级账号列表
function SellerShareManager:User_acquire_junior_account(pageno , pagesize)
	dump(" 请求 获取下级账号列表 1107 ",pageno , pagesize)
    local obj = Write.new({proid = 1107,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:writeInt(pageno)
    obj:writeInt(pagesize)
    obj:send()
end

function SellerShareManager:onUser_acquire_junior_account(obj)
	dump(" 获取下级账号列表 回调 1107 ")

    local res = {}
    local size = obj:readShort()
    for index = 1 , size do
        local data = {}
        data.junior_nickname    = obj:readString()
        data.junior_iconUrl     = obj:readString()
        data.junior_id          = obj:readLong()
        res[#res +1] = data
    end

    local result_ = {}
    result_.res      = res
    result_.max_page = obj:readInt() -- 总页数
    print_r(res)
    eventMgr:dispatchEvent("onUser_acquire_junior_account",result_)
end


---------2期内容

--领取新用户红包 1109
function SellerShareManager:receive_my_newUser_red_envelopes()
    dump(" 领取我的新用户红包 1109 ")
    local obj = Write.new({proid = 1109,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:send()
end

function SellerShareManager:onReceive_my_newUser_red_envelopes(obj)
    dump(" 领取我的新用户红包结果 1109 ")
    local status = obj:readBoolean();--成功失败
    eventMgr:dispatchEvent("Receive_my_newUser_red_envelopes",status) 
end


--代理中心基本信息 1121
function SellerShareManager:getMy_AgentCenter_Msg()
    dump(" 请求代理中心基本信息 1121 ")
    local obj = Write.new({proid = 1121,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:send()
end

function SellerShareManager:onGetMy_AgentCenter_Msg(obj)
    dump(" 我的代理中心基本信息 1121")
    local data = {}
    data.isDelegate = obj:readBoolean()

    local item = {}
    item.pid   = obj:readInt() --商品id
    item.money = obj:readInt() --价格
    item.num   = obj:readInt() --数量
    data.product   = item

    data.incomeUrl = obj:readString() --我的收入URL 地址
    -- eventMgr:dispatchEvent("upDateDelegateinfoData",data)
    print_r(data)
end

function SellerShareManager:onDelegaetCenter_status_update(obj)
    dump(" 我的代理中心状态 _修改 1122 ")
    local data = {}
    data.isDelegate = obj:readBoolean()

    eventMgr:dispatchEvent("DelegaetCenter_status_update",data)
end

--我的代理中心基本信息 1123
function SellerShareManager:requireDelegateCenter_data()
    dump(" 请求我的代理中心基本信息 1123")
    local obj = Write.new({proid = 1123,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:send()
end

function SellerShareManager:onRequireDelegateCenter_data(obj)
    dump(" 我的代理中心基本信息 1123")
    local data = {}
    data.uuid    = obj:readInt()
    data.cardNum = obj:readInt()
    data.money   = obj:readInt()

    local item = {}
    item.pid          = obj:readInt()  -- 商品id
    item.money        = obj:readInt()  -- 价格 （price * 100)
    item.exChange_pid = obj:readInt()  -- 兑换的商品ID
    item.buy_min_num  = obj:readInt()  -- 最少购买数量
    item.exchange_min_num  = obj:readInt()  -- 最少兑换数量
    data.product_delegate  = item

    eventMgr:dispatchEvent("RequireDelegateCenter_data",data)
end

--兑换 1124
function SellerShareManager:exchange_card(exChange_pid , num)
    dump(" 请求兑换房卡 1124")
    local obj = Write.new({proid = 1124,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:writeInt(exChange_pid)
    obj:writeInt(num)
    obj:send()
end

function SellerShareManager:onExchange_card(obj)
    dump(" 兑换房卡 1124 ")
    local status = obj:readBoolean(); -- 成功与否
    if status then
        local data = {}
        data.cardNum = obj:readInt() -- 剩余房卡 
        data.money   = obj:readInt() -- 剩余金额 单位分
        self:showToast("兑换成功")
        eventMgr:dispatchEvent("Exchange_card",data)
    else
        local err_msg = obj:readString() 
        self:showToast("兑换失败".. err_msg or "")
    end   
end

--赠送房卡 1126
function SellerShareManager:giveCard_to_User(uuid, num)
    dump(" 请求赠送房卡 1126 ")
    local obj = Write.new({proid = 1126,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:writeInt(uuid)
    obj:writeInt(num)
    obj:send()
end

function SellerShareManager:onGiveCard_to_User(obj)
    dump(" 赠送房卡结果 1126 ")
    local status = obj:readBoolean(); -- 成功与否
    if status then
        local data = {}
        data.cardNum = obj:readInt() -- 剩余的房卡
        self:showToast("赠送成功")
        eventMgr:dispatchEvent("GiveCard_to_User",data)
    else
        local err_msg = obj:readString() 
        self:showToast("赠送失败".. err_msg or "")
    end    
end

--赠送记录 1127
function SellerShareManager:giveCard_to_User_history_data(pageNum , starttime , endtime)
    dump(" 请求赠送记录 1127 " , pageNum , starttime , endtime)
    local obj = Write.new({proid = 1127,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:writeInt(pageNum)
    obj:writeString(starttime)
    obj:writeString(endtime)
    obj:send()
end

function SellerShareManager:onGiveCard_to_User_history_data(obj)
    dump(" 赠送记录 1127 ")
    local res = {}
    local total_pages = obj:readInt()
    -- local page_size   = obj:readInt()

    local size = obj:readShort()  
    for index = 1 , size do
        local data = {}
        data.receiver_uuid  = obj:readInt()
        data.give_num       = obj:readInt()
        data.receiver_cardNum  = obj:readInt()
        data.my_cardNum     = obj:readInt()
        data.send_time      = obj:readString()
        res[#res +1] = data
    end

    local args = {}
    args.res = res
    args.total_pages = total_pages
    -- args.page_size = page_size
    print_r(args)
    eventMgr:dispatchEvent("GiveCard_to_User_history_data",args)
end



--客服服务
function SellerShareManager:sendMsg2Service(msg)
    local obj = Write.new({proid = 1009,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:writeString(msg)
    obj:send()

    eventMgr:dispatchEvent("on_SendMsg2Service",nil) -- 反馈 不会有服务器回应直接提示结果
    self:showToast("提交成功,感谢您的反馈和支持！")
end

function SellerShareManager:onSendMsg2Service(obj)
    dump(" //// 1009 反馈成功")
    eventMgr:dispatchEvent("on_SendMsg2Service",nil)
end


--3期
-- 新的 ——钱袋更新 
function SellerShareManager:onUpdate_My_wallet_NEW(obj)
    dump(" NEW 钱袋更新")
    local data = {}
    data.totalAmount            = obj:readInt();            --总的红包金额
    data.can_be_receivedAmount  = obj:readInt();            --可领取红包金额
    
    print_r(data)
    eventMgr:dispatchEvent("UpdateMyReward_NEW",data)
end

-- 新的 ——检查红包 
function SellerShareManager:checkMy_red_envelopes_NEW()
    dump(" NEW 检查红包 1129 ")
    local obj = Write.new({proid = 1129,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:send()
end

function SellerShareManager:onCheckMy_red_envelopes_NEW(obj)
    dump(" NEW 收到检查红包 1129 ")
    local newAccountPackage  = obj:readInt();           --总的红包金额
    local totalAmount        = obj:readInt();           --总的红包金额
    local can_be_receivedAmount   = obj:readInt();      --可领取红包金额

    if newAccountPackage > 0 then
        dump("====新手红包")
        self:show_UI_newUser_red_envelopes(newAccountPackage)
    end

    local data = {}
    data.totalAmount  = totalAmount                     --总的红包金额
    data.can_be_receivedAmount = can_be_receivedAmount  --可领取红包金额
    print_r(data)

    eventMgr:dispatchEvent("UpdateMyReward_NEW",data)
end

-- 新的 --领取红包收益
function SellerShareManager:receive_my_wallet_NEW()
    dump(" NEW 领取红包收益 1130 ")
    local obj = Write.new({proid = 1130,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:send()
end

function SellerShareManager:onReceive_my_wallet_NEW(obj)
    local status = obj:readBoolean();--成功失败
    if status  == true then
        local data = {}
        data.receive_Amount  = obj:readInt();--领取的收益
        data.totalAmount     = obj:readInt();--总的金额
        
        print_r(data)
        eventMgr:dispatchEvent("Do_received",data)
    else
        self:showToast("领取失败");
    end   
end

--获得兑换商品列表 1131
function SellerShareManager:receive_List()
    dump(" 获取兑换列表 1131 ")
    local obj = Write.new({proid = 1131,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:send()
end

function SellerShareManager:onReceive_List(obj)
    dump(" 获取兑换列表 结果 1131")
    local res = {}
    local size = obj:readShort()  
    for index = 1 , size do
        local data = {}
        data.ID    = obj:readInt()
        data.DESC  = obj:readString()
        res[#res +1] = data
    end

    local result_= {}
    result_.res     = res
    result_.url_    = obj:readString() -- 提现地址
    print_r(result_)
    eventMgr:dispatchEvent("Receive_List",result_)
end


function SellerShareManager:checkPassword()
    dump(" 检查是否设置了交易密码 1132 ")
    local obj = Write.new({proid = 1132,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:send()
end
function SellerShareManager:onCheckPassword(obj)
    local data = {}
    data.status = obj:readBoolean() -- true 设置了密码
    data.url_   = obj:readString()  -- 设置密码的地址
    dump(" 检查交易密码结果 ",data.status , data.url_)
    eventMgr:dispatchEvent("CheckPassword",data)
end

function SellerShareManager:exchange_commodity(ID , password , extend_phone )
    dump(" 兑换商品 1133 " ,ID)
    local obj = Write.new({proid = 1133,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:writeInt(ID)
    obj:writeString(password or "")     -- 交易密码
    obj:writeString(extend_phone or "") -- 扩展:手机号
    obj:send()
end

function SellerShareManager:onExchange_commodity(obj)
    local data = {}
    data.status = obj:readInt() -- 值=0表示兑换成功，值=-1001密码错误 -1002红包余额不足
    data.over_  = obj:readInt()

    eventMgr:dispatchEvent("Exchange_commodity",data)
end


--合并收益
function SellerShareManager:merge_cash()
    dump(" 合并收益 1134")
    
    local obj = Write.new({proid = 1134,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:send()
end

function SellerShareManager:onMerge_cash(obj)
    -- body
    local data = {}
    data.status = obj:readInt() == 0 -- 值=0表示合并成功
    data.err_msg= obj:readString();
    
    eventMgr:dispatchEvent("Merge_cash",data)
end

--检查支付类型
function SellerShareManager:H5PayCheck()
    dump(" 检查H5P_ 1135")
    local obj = Write.new({proid = 1135,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    local platform = 1 --1安卓  2iOS  保持和登录时透传的平台的参数一致
    local targetPlatform = cc.Application:getInstance():getTargetPlatform() 
    if targetPlatform ~= cc.PLATFORM_OS_ANDROID then
        platform = 2
    end
    dump(" /// platform : ", platform)
    obj:writeInt(platform)
    obj:send()
end

function SellerShareManager:onH5PayCheck(obj)
    local PAYTYPE = obj:readString(pid) 
    local H5P_STATUS = (PAYTYPE == "H5" or PAYTYPE == "h5")
    local H5P_URL    = obj:readString()

    gameConfMgr:setInfo("H5P_STATUS",H5P_STATUS)
    gameConfMgr:setInfo("H5P_URL",   H5P_URL)

    release_print(" CHECK BACK : ",PAYTYPE , H5P_STATUS , H5P_URL)
end

-- 新代理内容
-- 检查是否代理
function SellerShareManager:isAgent()
    local obj = Write.new({proid = 1140,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:send()
end 
-- 新协议 从服务器拿是否代理 和 代理H5页面
function SellerShareManager:onIsAgent(obj)
    local res = {}
    res.isDelegate = obj:readBoolean()--是否代理
    res.hasRequire = obj:readBoolean()--是否有邀请信息
    if res.hasRequire or res.isDelegate then 
        res.URL = obj:readString()
    end 
    eventMgr:dispatchEvent("updateAgentData",res)
end 

function SellerShareManager:requestAgentRedpoint()
    local obj = Write.new({proid = 1141,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:send()
end 

function SellerShareManager:onAgentRedpoint(obj)
    -- body
    local res = {}
    res.num = obj:readInt()
    eventMgr:dispatchEvent("updateAgentRedpoint",res)
end



--检查自己是否是代理、绑定的代理信息
function SellerShareManager:checkDelegateStatus()
--    local obj = Write.new({proid = 1143,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
--    obj:send()
end

function SellerShareManager:onCheckDelegateStatus(obj)
    local isDelegate = obj:readBoolean() -- 自己是否是代理
    local delegate_id  = obj:readInt()     -- 代理ID
    local delegate_name= obj:readString()  -- 代理name
    local delegate_icon= obj:readString()  -- 代理ICON
    local delegate_time= obj:readString()  -- 绑定时间
    local delegate_tipsmsg= obj:readString()  -- 提示绑定信息

    print(" ----  isDelegate ,delegate_id ,delegate_name ,delegate_icon ,delegate_time ")
    print(" ----  ", isDelegate , delegate_id ,delegate_name ,delegate_icon ,delegate_time)
    gameConfMgr:setInfo("isDelegate_me"  , isDelegate)
    gameConfMgr:setInfo("h5pay_delegateid", delegate_id)
    gameConfMgr:setInfo("delegate_tipsmsg", delegate_tipsmsg)

    if isDelegate or delegate_id > 0 then 
        eventMgr:dispatchEvent("update_product", nil); --绑定了代理or 自己成为了代理更新商品列表数据
    end    

    eventMgr:dispatchEvent("CheckDelegateStatus",{ isDelegate = isDelegate ,delegate_id = delegate_id,delegate_name = delegate_name, delegate_icon = delegate_icon , delegate_time = delegate_time })  
end


--较验代理ID 是否合法
function SellerShareManager:delegateIDCheck(delegate_id)
    if delegate_id == nil or delegate_id == "" then
        msgMgr:showMsg("请输入代理ID")
        return 
    end 

    local obj = Write.new({proid =1142 ,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:writeInt(tonumber(delegate_id) or 0)
    obj:send()
end

function SellerShareManager:onDelegateIDCheck(obj)
    local bool = obj:readBoolean()
    if bool then 
        local delegate_id = obj:readInt()
        local delegate_name = obj:readString()
        local delegate_icon = obj:readString()

        print(" ----  onDelegateIDCheck " , delegate_id ,delegate_name ,delegate_icon )
        eventMgr:dispatchEvent("onDelegateIDCheck",{ delegate_id = delegate_id ,delegate_name = delegate_name ,delegate_icon = delegate_icon  })
    else
        msgMgr:showMsg("代理ID无效，请重新输入正确的ID")
    end    
end

--请求绑定代理
function SellerShareManager:bindDelegate(delegate_id)
    local obj = Write.new({proid =1144 ,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:writeInt(tonumber(delegate_id) or 0)
    obj:send()
end

function SellerShareManager:onBindDelegate(obj)
    local bool = obj:readBoolean()
    local msg  = obj:readString()

    if bool then 
        eventMgr:dispatchEvent("onBindDelegate",nil)
    else
        msgMgr:showMsg(msg or "绑定代理失败")
    end 
end

--请求获取支付的url
function SellerShareManager:getPayUrl(delegateid ,pid, paytype)
    local obj = Write.new({proid =1145 ,type = GAME_SOCKET_TYPE.SOCKET_TYPE_HALL})
    obj:writeInt(delegateid)
    obj:writeInt(pid)
    obj:writeString(paytype)
    obj:send()
end

function SellerShareManager:onPayUrl(obj)
    local bool= obj:readBoolean()
    print(" ------ bool pay url" , bool)
    if bool then      
        local url = obj:readString()
        print("------ onPayUrl ",url)
        if url and url ~= "" then 
            platformMgr:open_APP_WebView(url)   
        else
            msgMgr:showMsg("支付地址不存在")
        end  
    else
        local msg = obj:readString()
        msgMgr:showMsg(msg or "请求支付异常")
    end  
end

return SellerShareManager