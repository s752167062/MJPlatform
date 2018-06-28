--
-- Author: Your Name
-- Date: 2017-01-07 15:32:39
--
local CreateRoomList = class("CreateRoomList", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

CreateRoomList.RESOURCE_FILENAME = "CreateRoom/UIRoomList.csb"

CreateRoomList.RESOURCE_BINDING = {

	["list_view"]       = {    ["varname"] = "list_view"        },
    ["page_node"]       = {    ["varname"] = "page_node"        },
    ["txt_page"]        = {    ["varname"] = "txt_page"         },
    ["tips"]        = {    ["varname"] = "tips"         },
    ["btn_page1"]       = {    ["varname"] = "btn_page1"    ,  ["events"] = { {event = "click" ,  method ="onPage1"  } }    },--上一页
    ["btn_page2"]       = {    ["varname"] = "btn_page2"    ,  ["events"] = { {event = "click" ,  method ="onPage2"  } }    },--下一页
}
-- function CreateRoomList:ctor()
-- 	self.roomList = {}
-- end

local touchCount = 0

function CreateRoomList:onCreate()
	cclog("CreateRoomList onCreate")

    self.text_noRoom = ccui.Text:create("你暂时没有创建房间哦！^_^", "Arial", 35)
    self.text_noRoom:setTextColor(cc.c3b(255,211,129))
    self:addChild(self.text_noRoom)
    self.text_noRoom:setPosition(cc.p(348, 270))
    self.text_noRoom:setVisible(false)

    --self.pic_noRoom = self:getChildByName("listNode"):getChildByName("tips")
    self.tips:setVisible(true)

    --self:setRoomList()
	CCXNotifyCenter:listen(self,function(obj,key,data) self:showCreateSuccess(data) end,"create_room_success")--创建房间成功
    CCXNotifyCenter:listen(self,function(obj,key,data) self:setRoomList(data) end,"rec_room_list")--获得房间列表
    CCXNotifyCenter:listen(self,function(obj,key,data) self:updateRoomListData(data) end,"rec_room_list_one")--获得房间列表
    CCXNotifyCenter:listen(self,function(obj,key,data) ex_hallHandler:askCreateRoomList() end,"reconnect_rec_list")--断线重连重新刷新列表
    CCXNotifyCenter:listen(self,function(obj,key,data) self:deleteRoomListItem(data) end,"dele_roomlist_item")--删除单条数据
    CCXNotifyCenter:listen(self,function(obj,key,data) self:showDimissRoomSuccess(data) end,"dimiss_room_success")--创建房间成功
    CCXNotifyCenter:listen(self,function(obj,key,data) self.subUI_dimiss:setVisible(false) GlobalFun:showToast("解散房间成功", 3) end,"onDimiss_Room")--解散结果
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onGetResult_Data(data) end,"onGetResult_Data") --结算数据
end
function CreateRoomList:onEnter()
	cclog("create room list!!!")
    self.pageindex = 1;
    self.pagestart = 1;
    self.pageend = 0;
    self.maxnum = 0; 
    self.roomListData = {} -- 存放房间数据
    self.page_node:setVisible(false) -- 切页按钮

	ex_hallHandler:askCreateRoomList()
end
function CreateRoomList:onExit()
    cclog("onExit room list!!!")
    local SHARETYPE_NODE = cc.Director:getInstance():getRunningScene():getChildByName("SHARETYPE_NODE")
    if SHARETYPE_NODE then
        SHARETYPE_NODE:removeFromParent()
    end    
    CCXNotifyCenter:unListenByObj(self)
end
------------------------代开房间-----------------------
-------------------------start------------------------
function CreateRoomList:setRoomList(info)
    --刷新列表数据
    self:reflashRoomListData(info)
    if info.roomIndexPage ~= info.roomMaxPage then 
        cclog(" page ", info.roomIndexPage)
        self.text_noRoom:setText("正在加载数据...")
        return 
    end

    --刷新当前页面
    -- cclog("页面 " , info.roomIndexPage ,"   当前页 ：", self.pageindex)
    -- if info.roomIndexPage == self.pageindex then 
    --     local data = info.res
    --     self:showPageWithData(data)
    -- end  

    --当前显示的这页被回收了 
    if self.pageindex > self.pageend then   
        if self.pageend > 0 then 
            --显示上一页
            cclog("当前页面列表被回收 显示最后一页" , self.pageindex)
            self.pageindex = self.pageend 
            self:changePage(self.pageindex)
        else 
            --全部被回收 回归原始
            cclog("列表全部被回收")
            self.pageindex = 1;
            self.pagestart = 1;
            self.pageend = 0;
            self.roomListData = {} -- 存放房间数据
        end
        return 
    end

    --正常刷新当前页
    cclog(" page ", info.roomIndexPage)
    self.text_noRoom:setText("你还没有创建房间哦！")
    self:changePage(self.pageindex)
end

--替换本地数据 10 是和服务器约定的，每页下发10 条
function CreateRoomList:reflashRoomListData(data)
    self.pageend = data.roomMaxPage or 0
    self.maxnum  = data.maxnum
    local indexpage = data.roomIndexPage
    local res = data.res -- 房间列表
    cclog("收到表数据 ：", indexpage, "   最大页数 ： " , self.pageend , "每页数量" ,self.maxnum)
    --ui修改
    self.page_node:setVisible(self.pageend > 0)
    self.txt_page:setString(self.pageindex.."/"..self.pageend)    
    --数据修改
    if res and #res > 0 then 
        local start = self.maxnum *(indexpage - 1) + 1
        -- print_r(res)
        cclog(#res, "   " , start)
        for i=start, start + #res do
            cclog("刷新列表 index ：" , i)
            local item = res[i - start + 1]
            if item then 
                cclog("当前页idnex : ", i- start + 1 , "   列表位置： ", i)
                self.roomListData[i] = item
            end    
        end
    end

    -- print_r(self.roomListData)
    --清除被回收的数据
    if indexpage == self.pageend and res then -- 最后一页 没有数据时返回 index 为0 
        local mun = self.maxnum * (self.pageend - 1)+ #res
        cclog("比较回收 ： " , mun , "   #data ", #self.roomListData)
        if  #self.roomListData  >  mun then 
            -- 有数据被回收
            for i=mun + 1 , #self.roomListData do
                cclog("回收 num ", i)
                self.roomListData[i] = nil
            end
        end
    end

    -- print_r(self.roomListData)
end

--换页
function CreateRoomList:changePage(index)
    local start = (index  -1 )* self.maxnum + 1
    local indexend = math.min( start + self.maxnum - 1 , #self.roomListData) 

    local data = {}
    for i= start, indexend do
        local item = self.roomListData[i]
        if item then 
            cclog("换页显示" , indexend)
            data[#data + 1] = item
        end    
    end
    --ui修改
    self.txt_page:setString(self.pageindex.."/"..self.pageend)   
    self:showPageWithData(data)
    self.page_node:setVisible(#self.roomListData > 0 )
end

function CreateRoomList:showPageWithData(data)
    self.list_view:removeAllItems()
    if #data > 0 then
        --self.text_noRoom:setVisible(false)
        self.tips:setVisible(false)
    else
        --self.text_noRoom:setVisible(true)
        self.tips:setVisible(true)
    end
    if data == nil then
        return 
    end
    self.roomdata = data -- 不排序了 self:sortRoomListData(data) -- 房间数据

    cclog("~~~ 设置房间数据 ")
    print_r(self.roomdata)
    cclog("~~~ 设置房间数据 end")

    local lastPLayer = nil
    for index = 1, #self.roomdata do
        local itemdata = self.roomdata[index]
        local player = nil

        if index % 2 ~= 0 then
            lastPLayer = ccui.Layout:create()
            lastPLayer:setContentSize(cc.size(695, 175))
            self.list_view:pushBackCustomItem(lastPLayer)
        end

        local layer = ccui.Layout:create()
        layer:setContentSize(cc.size(344, 175))
        layer:setTouchEnabled(false)
        --self:addLayerClick(layer,index)

        local item = self:createItem(itemdata)


        local entry_btn = item:getChildByName("Node_2"):getChildByName("btn_entry")
        entry_btn:setSwallowTouches(false)
        self:addLayerClick(entry_btn, index)

        local chakan_btn = item:getChildByName("Node_2"):getChildByName("btn_chakan")
        chakan_btn:setSwallowTouches(false)
        self:addLayerClick(chakan_btn, index)

        item:setPosition(cc.p(0,0))
        item:setName("CSNode")
        item:setTag(index)
        layer:addChild(item)
        layer.data = itemdata --数据附加到item上
        layer.i = index % 2 

        if index % 2 == 0 then
            layer:setPosition(cc.p(350,0))       --总长 695 
        end
        lastPLayer:addChild(layer)
    end

    --显示当前页同步 self.roomListData 的数据
    -- cclog(" ///// 同步 roomListData  ",math.min(#self.roomdata , self.maxnum ))
    -- for i=1,math.min(#self.roomdata , self.maxnum ) do
    --      self.roomListData[i] = self.roomdata[i]
    -- end 

    --时间倒计时
    local stime = 0
    local function handler(t)
        --1秒刷新一次
        stime = stime + t
        if stime >= 1 then
            stime = 0
            self:update(1)
        end
    end
    self:scheduleUpdateWithPriorityLua(handler,0)    
end

--更新单个数据
function CreateRoomList:updateRoomList(data)
    local items = self.list_view:getItems()
    local item = nil
    for k,v in pairs(items) do
        local cTable = v:getChildren()
        for i, w in pairs(cTable) do
            if w.data.roomId == data.roomId then
                item = w
                item.data = data
            end
        end
    end
    if item then
        local csNode = item:getChildByName("CSNode")
        local root = csNode:getChildByName("Node_2")
        local ask_btn = root:getChildByName("btn_ask")
        local chakan_btn = root:getChildByName("btn_chakan")
        local delete_btn = root:getChildByName("btn_delete")
        local roomId = root:getChildByName("text_roomID")
        local time = root:getChildByName("list_btn_invite_1"):getChildByName("text_time")
        local player = root:getChildByName("node_names")
        local entry_btn = root:getChildByName("btn_entry")

        local index = csNode:getTag()
        self.roomdata[index] = data

        roomId:setString(data.roomId)
        if data.roomState == 0 then
            -- time:setString(GlobalFun:SecToHMS(data.remainTime))
            local data = Util.split(GlobalFun:SecToHMS(data.remainTime), ":") or {}
            time:setString(self:formatTime(data.remainTime))
            --time:setString((data[2]or 0) .. "分钟")
            --self:createTimer(time, data[2])
        elseif data.roomState == 1 then
            --self:destroyTimer(time)
            time:setString(data.curRound.."/"..data.round)
        elseif data.roomState == 2 then
            --self:destroyTimer(time)
            time:setString("已结束")
            ask_btn:setVisible(false)
            delete_btn:setVisible(true)
            
            root:getChildByName("list_btn_invite_1"):setVisible(false)
            chakan_btn:setVisible(true)
            entry_btn:setVisible(false)
            --roomId:setPositionY(roomId:getPositionY() - 10)
            --player:setPositionX(player:getPositionX() + 10)

            --刷新列表
            -- self:reflushListView()
            return
        end
  
        --玩家名字
        if data.players_data then 
            for i=1,#data.players_data do
                local name = player:getChildByName("txt_player"..i)
                local data = data.players_data[i]
                if name and data then 
                    name:setString(data.p_name or "null")
                    name:setTextColor(cc.c4b(200, 18, 23, 255))
                end    
            end
        end  

        for i=#data.players_data +1, 4 do
            local name = player:getChildByName("txt_player"..i)
            if name then 
                local msg = "等待玩家进入"
                if i > data.playerMax then
                    msg = ""
                end
                name:setString(msg)
                name:setTextColor(cc.c4b(18, 89, 18, 255))
            end    
        end

    end
end

function CreateRoomList:updateRoomListData(data)
    cclog("------ 单个数据更新")
    for k,v in pairs(self.roomListData) do
        if v then 
            if v.roomId == data.roomId then 
                self.roomListData[k] = data
                cclog(" 单个更新的 页" , k / self.maxnum , "   k :", k , "   num :", self.maxnum )
                if (k < self.maxnum and self.pageindex == 1 ) or (k / self.maxnum == self.pageindex) then 
                    self:updateRoomList(data)
                end   

                --存在就忽略
                return  
            end
        end    
    end

    --新增的字段
    cclog("------新增数据")
    if #self.roomListData == 0 then
        ex_hallHandler:askCreateRoomList() -- 本地没有数据的时候 页数数据以服务器的为准
    else
        table.insert(self.roomListData , 1 , data)   
        --重新计算页数
        cclog(" 重新计算页数 ： " , #self.roomListData , self.maxnum)
        self.pageend = math.ceil(#self.roomListData/self.maxnum)
        self:changePage(self.pageindex)
    end    
end

function CreateRoomList:createItem(data)
    -- cclog("sssssssss ", string.match("123456789:\"123456\"","[:][\"]%d%d%d%d%d%d[\"]"))
    cclog("fuckfuckfuck...")
    print_r(data)
    local node = display.newCSNode("CreateRoom/itemRoomList2.csb")
    local root = node:getChildByName("Node_2")
    local ask_btn = root:getChildByName("btn_ask")
    local chakan_btn = root:getChildByName("btn_chakan")
    local delete_btn = root:getChildByName("btn_delete")
    local roomId = root:getChildByName("text_roomID")
    local time = root:getChildByName("list_btn_invite_1"):getChildByName("text_time")
    local player = root:getChildByName("node_names")
    --player:setPositionY(player:getPositionY() - 2)
    local copy_btn = root:getChildByName("list_btn_invite_1"):getChildByName("btn_copy")
    
    local btn_dimissroom = root:getChildByName("list_btn_invite_1"):getChildByName("btn_dimissroom")
    local entry_btn = root:getChildByName("btn_entry")
    local btn_fengye = root:getChildByName("btn_fengye")

    roomId:setString(data.roomId)
    if data.roomState == 0 then
        -- time:setString(GlobalFun:SecToHMS(data.remainTime))
        local data = Util.split(GlobalFun:SecToHMS(data.remainTime), ":") or {}
        time:setString(self:formatTime(data.remainTime))
        --time:setString((data[2]or 0) .. "分钟")
        --self:createTimer(time, data[2])
    elseif data.roomState == 1 then
        --self:destroyTimer(time)
        --time:setString(data.curRound.."/"..data.round)
    elseif data.roomState == 2 then
        --self:destroyTimer(time)
        time:setString("已结束")
        ask_btn:setVisible(false)
        delete_btn:setVisible(true)
        root:getChildByName("list_btn_invite_1"):setVisible(false)
        chakan_btn:setVisible(true)
        entry_btn:setVisible(false)
        --roomId:setPositionY(roomId:getPositionY() - 10)
        --player:setPositionX(player:getPositionX() + 10)
    end

    --玩家名字
    if data.players_data then 
        for i=1,#data.players_data do
            local name = player:getChildByName("txt_player"..i)
            local data = data.players_data[i]
            if name and data then 
                name:setString(data.p_name or "null")
                name:setTextColor(cc.c4b(200, 18, 23, 255))
                GlobalFun:uiTextCut(name)
            end    
        end
    end  

    for i=#data.players_data +1, 4 do
        local name = player:getChildByName("txt_player"..i)
        if name then 
            local msg = "等待玩家进入"
            if i > data.playerMax then
                msg = ""
            end
            name:setString(msg)
            name:setTextColor(cc.c4b(18, 89, 18, 255))
        end    
    end

    -- ask_btn:addClickEventListener(function()
    --     self:onClickRoomAsk(data , root)
    --     end)
    ex_fileMgr:loadLua("app.Common.BackCall_TouchEvent").new(ask_btn, function()
            self:onClickRoomAsk(data , root)
        end)
    ask_btn:setSwallowTouches(false)
    
    -- delete_btn:addClickEventListener(function()
    --     self:onClickRoomDelete(data.roomId)
    --     end)
    ex_fileMgr:loadLua("app.Common.BackCall_TouchEvent").new(delete_btn, function()
            self:onClickRoomDelete(data.roomId)
        end)
    delete_btn:setSwallowTouches(false)

    ex_fileMgr:loadLua("app.Common.BackCall_TouchEvent").new(btn_fengye, function(sender)
            self:onClickRoomShowRule(sender)
        end)
    btn_fengye:setSwallowTouches(false)

    copy_btn:setVisible(false)
    copy_btn:addClickEventListener(function()

        local rtype = json.decode(data.roomType or "")
        if type(rtype) == "table" then
            -- GameRule.isQiXiaoDui = rtype.PLAY_7D == true and 1 or 0
            -- GameRule.isMiLuoHongZhong = rtype.PLAY_LEILUO == true and 1 or 0

            GameRule:setRule(rtype)
        end

        -- string.format("房间号:\"%d\" , %d局, %d个码的%d人房间" , data.roomId or 0, data.round or 0, data.za or 0 ,data.playerMax or 0)
        local maStr = (data.za or 0) > 0 and (" " .. GameRule:getZhaMaText(data.za or 0)) or ""
        local str = string.format("房间号:\"%d\" , %d局,%s" , data.roomId or 0, data.round or 0, maStr)

        -- if GameRule.isQiXiaoDui == 1 then
        --     str = str .. " 七小对"
        -- end
        -- if GameRule.isMiLuoHongZhong == 1 then
        --     str = str .. " 汨罗红中"
        -- end

        str = GameRule:getRuleText(str)
        str = str .. string.format("%d人房间" ,data.playerMax or 0) 
        local tb = {}
        tb.msg = str
        tb.stype = "房间"
        tb.params = {data.roomId, GlobalData.game_product}
        local str = GlobalFun:makeCopyStr(tb)

        cclog(str)
        SDKController:getInstance():copy_To_Clipboard(str or "ERR")
	    GlobalFun:showToast("复制房间号成功",Game_conf.TOAST_SHORT)
    end)

    -- btn_dimissroom:addClickEventListener(function()
    --     self:showDimissRoomSuccess({ roomId = data.roomId })
    --     end)
    ex_fileMgr:loadLua("app.Common.BackCall_TouchEvent").new(btn_dimissroom, function()
            self:showDimissRoomSuccess({ roomId = data.roomId })
        end)
    btn_dimissroom:setSwallowTouches(false)

    --填充枫叶内容
    local function getRuleStr(json_str, za, ju)
        local params =json.decode(json_str)
        local str = ""
        ju = ju or 0
        local pre = GameRule:getZhaMaText(za)
        str = string.format("%s人%s%s", params.playerNum, ju == 0 and ",玩家自定义局数" or ju .. "局", pre == "" and "" or ","..pre)
        str = GameRule:clubServerRuleToText(str, params)
        str = string.gsub(str, ",", "，")
        return str
    end
    local shuipaoContent = btn_fengye:getChildByName("img_shuipao"):getChildByName("shuipaoContent")   
    local retStr = getRuleStr(data.roomType, data.za, data.round)
    cclog("retStr:"..retStr)
    shuipaoContent:setString(retStr)

    return node
end

function CreateRoomList:update(t)
    local remove = {}
    local items = self.list_view:getItems()
    for k,v in pairs(items) do
        local cTable = v:getChildren()
        for i, item in pairs(cTable) do
            item.data.remainTime = item.data.remainTime - 1
            if item.data.remainTime > 0 then
                local csNode = item:getChildByName("CSNode")
                local root = csNode:getChildByName("Node_2")
                local ask_btn = root:getChildByName("btn_ask")
                local delete_btn = root:getChildByName("btn_delete")
                local time = root:getChildByName("list_btn_invite_1"):getChildByName("text_time")
                local entry_btn = root:getChildByName("btn_entry")

                if item.data.roomState == 0 then --等待中
                    local data = Util.split(GlobalFun:SecToHMS(item.data.remainTime), ":") or {}
                    time:setString(self:formatTime(item.data.remainTime))
                    --time:setString((data[2]or 0) .. "分钟")
                    --self:createTimer(time, data[2])
                elseif item.data.roomState == 1 then
                    --self:destroyTimer(time)
                    time:setString(data.curRound.."/"..data.round)
                elseif item.data.roomState == 2 then
                    --self:destroyTimer(time)
                    time:setString("已结束")
                    ask_btn:setVisible(false)
                    delete_btn:setVisible(true)
                    entry_btn:setVisible(false)
                end
            else
                if item.data.roomState == 0 then --等待中
                    table.insert(remove, i)
                end
            end
        end
    end
    if #remove > 0 then
        self:removeItem(remove)
    end
end

function CreateRoomList:removeItem(remove)

    for k,v in pairs(remove) do
        self.list_view:removeItem(v-1)--list中item的索引 和lua中的索引不一样  需要-1
    end
end

--删除单条数据 
function CreateRoomList:deleteRoomListItem(roomId)
    for i,v in ipairs(self.roomListData) do
        cclog(" room ////  ", v.roomId , "   " ,roomId )
        if v and v.roomId == roomId then --删除这个房间
            table.remove(self.roomListData,i)
            --刷新列表
            cclog("删除后刷新当前页" , self.pageend , #self.roomListData)
            if #self.roomListData == (self.pageend -1)* self.maxnum then --最后一页只有一条数据，被删除后页数改变
                self.pageindex = math.max(1 , self.pageindex -1 )
                self.pageend = math.max(1 , self.pageend - 1)
            end    
            self:changePage(self.pageindex)
        end    
    end
end

function CreateRoomList:addLayerClick(layer,index)
    -- layer:addClickEventListener(function()
    --         print_r(self.roomdata[index])
    --         local itemdata = self.roomdata[index] 
    --         self:onClickRoomItem(itemdata)
    --     end)
    ex_fileMgr:loadLua("app.Common.BackCall_TouchEvent").new(layer, function()
            print_r(self.roomdata[index])
            local itemdata = self.roomdata[index] 
            self:onClickRoomItem(itemdata)
        end)
    layer:setTouchEnabled(true)
end

function CreateRoomList:onClickRoomItem(data)
    print_r(data)
    cclog("进入房间...",data.roomId, data.roomState)
    if data.roomState == 0 then -- 等待中 or data.roomState == 1 
        ex_hallHandler:gotoRoom(data.roomId)

    elseif data.roomState == 2 then 
        cclog("房间 牌局已结束")
        local info = {}
        info.roommainid = data.roommainid
        info.roomCreateImgUrl = data.roomCreateImgUrl
        info.roomCreateName  =data.roomCreateName
        info.roomID = data.roomId

        self.roominfo_data = info
        ex_hallHandler:getResultData(info.roomID)
    end    
    
end

function CreateRoomList:onClickRoomAsk(data ,root)
    if data.roomState == 0 then
        cclog(" **** 邀请 ")
        local btn_ask = root:getChildByName("btn_ask")
        local n_p = btn_ask:convertToWorldSpace(cc.p(0,0))

        GlobalData.roomID = data.roomId
        GameRule.MAX_GAMECNT = data.round 
        GameRule.ZhaMaCNT = data.za

        local share = ex_fileMgr:loadLua("app/Common/CUIShareType").new(0,data.playerMax)
        local rootnode = share:getShareRootNode()
        rootnode:setPosition(cc.p(n_p.x + 180  , n_p.y + 20))
        share:setName("SHARETYPE_NODE")
        cc.Director:getInstance():getRunningScene():addChild(share)

        local rtype = json.decode(data.roomType or "")
        if type(rtype) == "table" then
            -- GameRule.isQiXiaoDui = rtype.PLAY_7D == true and 1 or 0
            -- GameRule.isMiLuoHongZhong = rtype.PLAY_LEILUO == true and 1 or 0
            GameRule:setRule(rtype)
        end
    end 
    -- local roomId = data.roomId
    -- local round = data.round
    -- local cardnum = 16
    -- local res = {   "房间号【".. roomId .. "】"
    --                 ,"我在[筑志红中麻将]".."开了 "..cardnum .. "张牌,".. round .."局的房间 "..data.playerMax.."缺" .. (data.playerMax - data.playerCount)   
    --                 , Game_conf.ShareHtmlURL } 
    -- SDKController:getInstance():share(res)
end

function CreateRoomList:onClickRoomDelete(roomId)
    local function okfunc()
            ex_hallHandler:deleteRoomItem(roomId)
    end
    GlobalFun:showError(string.format("删除已结束房间:%s",roomId or ""),okfunc,nil,2)
end

function CreateRoomList:onClickRoomShowRule(sender)
    --显示枫叶2秒
    local img_shuipao = sender:getChildByName("img_shuipao")
    local txt_content = img_shuipao:getChildByName("shuipaoContent")
    -- img_shuipao:setVisible(true)
    -- local action = cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function() 
    --         img_shuipao:setVisible(false)
    --     end))
    -- img_shuipao:runAction(action)
    local x, y = img_shuipao:getPosition()
    local x, y = sender:convertToWorldSpace(cc.p(x, y))
    CCXNotifyCenter:notify("CreateRoomList_img_shuipao", {["worldPos"] = {["x"] = x, ["y"] = y}, ["content"] = txt_content:getString()})
end

function CreateRoomList:showCreateSuccess(data)
    print_r("***** 显示成功")
    print_r(data)
    if data ~= nil then 
        GameRule.canDaiKai = data.canDaiKai
        if data.canDaiKai then
            if self.subUI_success then
                self.subUI_success:setVisible(true)
                --刷新
                local root = self.subUI_success:getChildByName("node")
                local txt_msg = root:getChildByName("txt_msg")
                txt_msg:setString("创建成功,房间号:【  "..  data.roomId .. "  】" )
            else
                local node = display.newCSNode("CreateRoom/CUICreateRoomSuccess.csb")
                local root = node:getChildByName("node")
                local create_btn = root:getChildByName("create")
                local enter_btn = root:getChildByName("enter")
                local close_btn = root:getChildByName("close")
                local txt_msg = root:getChildByName("txt_msg")

                txt_msg:setString("创建成功,房间号:【  "..  data.roomId .. "  】" )
                create_btn:addClickEventListener(function()
                        self.subUI_success:setVisible(false)
                    end)
                close_btn:addClickEventListener(function()
                        self.subUI_success:setVisible(false)
                    end)
                
                self.subUI_success = node
                -- display.getRunningScene():addChild(node)
                self:getParent():getParent():addChild(node)
            end

            local node = self.subUI_success
            local root = node:getChildByName("node")
            local enter_btn = root:getChildByName("enter")
            enter_btn:addClickEventListener(function()
                        cclog("进入房间",data.roomId)
                        -- ex_hallHandler:gotoRoom(data.roomId)
                        ex_hallHandler:gotoRoom(data.roomId)
                        -- GameClient:open(GlobalData.roomIP,GlobalData.roomPort)

                    end)
        else
            ex_hallHandler:gotoRoom(data.roomId)
        end

    end
    
end

function CreateRoomList:showDimissRoomSuccess(data)
    print_r("***** 解散显示成功")
    print_r(data)
    if data ~= nil then 
        if self.subUI_dimiss then
            self.subUI_dimiss:setVisible(true)
            --刷新
            local root = self.subUI_dimiss:getChildByName("node")
            local txt_msg = root:getChildByName("txt_msg")
            root.roomid = data.roomId
            txt_msg:setString("是否确定解散房间【  "..  data.roomId .. "  】？" )
        else
            local node = display.newCSNode("CreateRoom/CUIDissmisRoom.csb")
            local root = node:getChildByName("node")
            local btn_dimissroom = root:getChildByName("btn_dimissroom")
            local btn_cancel     = root:getChildByName("btn_cancel")
            local btn_close      = root:getChildByName("btn_close")
            local btn_ok         = root:getChildByName("btn_ok")
            local txt_msg        = root:getChildByName("txt_msg")

            txt_msg:setString("是否确定解散房间【  "..  data.roomId .. "  】?" )
            btn_ok:setVisible(false);
            btn_dimissroom:setVisible(true);
            btn_cancel:setVisible(true);

            root.roomid = data.roomId
            btn_dimissroom:addClickEventListener(function()
                        self.subUI_dimiss:setVisible(false)
                        ex_hallHandler:dimissRoom(root.roomid )
                        --请求解散
                    end)
            btn_cancel:addClickEventListener(function()
                        self.subUI_dimiss:setVisible(false)
                    end)
            btn_close:addClickEventListener(function()
                        self.subUI_dimiss:setVisible(false)
                    end)
                
            self.subUI_dimiss = node
            self:getParent():getParent():addChild(node)
        end
    end
end

function CreateRoomList:onGetResult_Data(data)
    self:showAllResult(data , self.roominfo_data)
end

function CreateRoomList:showAllResult(playersdata,info)
    local scene = cc.Director:getInstance():getRunningScene()
    local BassAs = ex_fileMgr:loadLua("app.views.game.CUIGame_AllSummary").new()
    BassAs:ShowOpenRoomItemResult(playersdata,info)
    scene:addChild(BassAs)
end

function CreateRoomList:sortRoomListData(listdata)
    local data  = {}
    if listdata == nil or #listdata ==0 then 
        return data
    end    

    local enddata = {}
    for i=1, #listdata do
        local item = listdata[i]
        if item.roomState ~= 2 then 
            if #data == 0 then 
                data[#data +1] = item
            else
                for j =1,#data do
                local dataitem = data[j]
                    if item.createTime < dataitem.createTime then
                        table.insert(data , j , item)
                        break
                    end    

                    if #data == j then 
                        data[#data +1] = item
                    end
                end
            end     
        else
            enddata[#enddata +1] = item
        end    
    end

    for i=1,#enddata do
        data[#data +1 ] = enddata[i]
    end

    return data
end

function CreateRoomList:reflushListView()
    self:setRoomList(self.roomdata)
end

function CreateRoomList:onPage1()
    if self.pageindex > 1 then
        self.pageindex = self.pageindex - 1
        self:changePage(self.pageindex)
    end    
end

function CreateRoomList:onPage2()
    if self.pageindex < self.pageend then
        self.pageindex = self.pageindex + 1
        self:changePage(self.pageindex)
    end 
end

--刷新时间
function CreateRoomList:createTimer(sender, time)
    sender:setTag(time * 60)
    local action = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function() 
            local tag = sender:getTag()
            if tag > 0 then
                sender:setTag(tag - 1)
                local min = math.floor(tag / 60)
                local second = tag % 60
                sender:setString(string.format("%2d:%2d", min, second))
            else
                sender:setString("00:00")
            end
        end)))
    sender:runAction(action)
end
function CreateRoomList:destroyTimer(sender)
    sender:stopAllActions()
end

function CreateRoomList:formatTime(time)
    if time == nil then return "" end
    local min = math.floor(time / 60)
    local second = time % 60
    return string.format("%.2d:%.2d", min, second)
end
------------------------代开房间-----------------------
-------------------------end--------------------------
return CreateRoomList
