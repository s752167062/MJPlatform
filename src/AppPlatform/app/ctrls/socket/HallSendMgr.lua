local HallSendMgr = class("HallSendMgr")

function HallSendMgr:ctor()
end



--我的游戏列表
function HallSendMgr:sendMyGameList()
    local obj = Write.new(1100)
    obj:send()
end

--某类游戏列表
function HallSendMgr:sendGameList(gtype, pageNumb)
    cclog("HallSendMgr:sendGameList >>>", gtype, pageNumb)
    local obj = Write.new(1101)
    obj:writeInt(gtype)
    obj:writeInt(pageNumb)
    obj:send()
end

--进入某个游戏
function HallSendMgr:sendEnterGame(product, version)
	 -- platformExportMgr:getEnterParams()  --正常进入游戏清掉进入参数，如果想进入参数生效，进入参数应设置在这个请求之后
  --   local obj = Write.new(1102)
  --   obj:writeString(product)
  --   obj:writeString(version)
  --   obj:send() 
end

--创建俱乐部
function HallSendMgr:createClub(name, id)
	cclog("HallSendMgr:createClub >>>", name, id)
    local obj = Write.new(1106)
    obj:writeString(name)
    obj:writeString(id)
    obj:send() 
end

--创建俱乐部
function HallSendMgr:sendClubList()
	cclog("HallSendMgr:sendClubList >>>")
    local obj = Write.new(1104)
    obj:send()
end

--创建俱乐部
function HallSendMgr:sendClubData(clubId)
	cclog("HallSendMgr:sendClubList >>>")
    local obj = Write.new(1105)
    obj:writeLong(clubId)
    obj:send()
end

-- function HallSendMgr:sendCheckGameVersion(product, version)
-- 	cclog("HallSendMgr:sendClubList >>>")
--     local obj = Write.new(1110)
--     obj:writeString(version)
--    	obj:writeString(product)
--     obj:send()
-- end

function HallSendMgr:sendJoinClub(clubId)
    local obj = Write.new(1108)
    obj:writeLong(clubId)
    obj:send()
end

function HallSendMgr:sendSearchClub(clubId)
    local obj = Write.new(1118)
    obj:writeLong(clubId)
    obj:send()
end

function HallSendMgr:sendAddClubGame(clubId, product)
    local obj = Write.new(1109)
	  obj:writeLong(clubId)
   	obj:writeString(product)

   	obj:writeByte(0)
   	obj:writeByte(0)
   	obj:writeByte(0)
   	obj:writeString("")
    obj:send()
end

function HallSendMgr:GetProduct(type_)
    cclog(">>>> pro")
    local obj = Write.new(1202)
    obj:writeByte(type_ or 1) -- 1：H5     2：appstore  
    obj:send()
end


-- function HallSendMgr:quickEnterRoom(roomId, state,version) 
--     cclog(">>>>> enterroom ",roomId , state)--返回 1103
--     local obj = Write.new(1200)
--     obj:writeInt(roomId)
--     obj:writeBoolean(state) -- 约定第一次state=true,返回1103处理完后如果1103下发的房间号 则第二次请求 state=false,最后返回1102 
--     if state == false then 
--         obj:writeString(version)
--     end    
--     obj:send()
-- end

function HallSendMgr:shiMing(reqType, data)
    cclog(" >>>>  HallSendMgr shiMing  >>>")
    local obj = Write.new(1201)
    --reqType  1获取数据  2 请求保存
    obj:writeByte(reqType)
    if reqType == 1 then
        
    elseif reqType == 2 then
        obj:writeString(data.name)
        obj:writeString(data.id)
    end
    obj:send()
end

------ h5支付 获取
function HallSendMgr:h5Pay(paymode , goodsid)
    local obj = Write.new(1204)
    obj:writeInt(goodsid)    -- 商品ID
    obj:writeString(paymode) -- 支付模式 "WXPAY" or "ALIPAY"
    
    obj:send()
end

--检查支付类型
function HallSendMgr:H5PayCheck()
    local obj = Write.new(1203)
    obj:send()
end

--IAP支付
function HallSendMgr:sendIAPReceipt(receipt,isCheck)
    print("IAP支付")
    local obj = Write.new(1050)
    if isCheck then 
        obj:writeByte(1) --1支付环境 ，测试还是正式
    else
        obj:writeByte(0) --1支付环境 ，测试还是正式
    end    
    obj:writeString(receipt)
    obj:send()
end

function HallSendMgr.msgData()--大厅房卡消息
    local obj = Write.new(1208)
    obj:send()
end

function HallSendMgr:gongGaoMsg(flag)--主动获取公告
    local obj = Write.new(1206)
    obj:writeBoolean(flag)
    obj:send()
end

function HallSendMgr:sendFeedBack(msg)--发送反馈
    local obj = Write.new(1209)
    obj:writeString(msg)   
    obj:send()
end

function HallSendMgr:sendRemovePlaying(clubId, clubSecndId)--主动获取公告
    cclog("HallSendMgr:sendRemovePlaying >>>", clubId, clubSecndId)
    local obj = Write.new(1127)
    obj:writeLong(clubId)
    obj:writeLong(clubSecndId)
    obj:send()
end

return HallSendMgr

