
local UI_RoomCardStatistics = class("UI_RoomCardStatistics", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_RoomCardStatistics:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_RoomCardStatistics.csb")
    self.root:addTo(self)

	UI_RoomCardStatistics.super.ctor(self)
    _w = self._childW
    
	self:initUI()
	self:setMainUI()
end

function UI_RoomCardStatistics:initUI()
	self.btn_close    		= _w["btn_close"]
	self.btn_rc_left    	= _w["btn_rc_left"]
	self.btn_rc_right    	= _w["btn_rc_right"]
	self.fangkaList     	= _w["fangkaList"]
	self.RoomCard_panel    	= _w["RoomCard_panel"]
	self.btn_chaxun    		= _w["btn_chaxun"]

	self.txt_costCard_manager = _w["txt_costCard_manager"]
	self.txt_costCard_member = _w["txt_costCard_member"]

end

function UI_RoomCardStatistics:setMainUI()
	CCXNotifyCenter:listen(self,function(obj,key,data) self:res_onRoomCardStatistics(data) end, "res_onRoomCardStatistics")
	
	self.btn_close:addClickEventListener(function() self:closeUI() end)
	self.btn_rc_left:addClickEventListener(function() self:paging_rc(true) end)
	self.btn_rc_right:addClickEventListener(function() self:paging_rc(false) end)
	self.RoomCard_panel:addClickEventListener(function() self.RoomCard_panel:setVisible(false) end)
	self.btn_chaxun:addClickEventListener(function() self:checkRoomCard() end)

	self.RoomCard_panel:setVisible(false)
	self.fangkaList:setScrollBarWidth(0.1)	
end


function UI_RoomCardStatistics:onEnter()


	self._roomCardTb = nil
	self._roomCardShowTb = nil
	self._roomCardIndex = 0
	self._beginTime = ""
	self._endTime = ""

	self:setPage_RoomCardStatistics()

	-- self:res_onRoomCardStatistics(data)
end

function UI_RoomCardStatistics:onExit(  )
	CCXNotifyCenter:unListenByObj(self)
end

--房卡查询
function UI_RoomCardStatistics:checkRoomCard()
	local beginTime = "2017-10-08 17:20:20"
	local endTime = "2017-10-20 17:20:20"
	local t = _w["textFiled_startTime"]:getString()
	local t2 = _w["textFiled_endTime"]:getString()
	--if t ~= nil and t ~= "" then beginTime = t end
	--if t2 ~= nil and t2 ~= "" then endTime = t2 end
	beginTime = t
	endTime = t2
	--检查格式
	local function check(str)
		local data = string.split(str, "-")
		cclog("wtf check")
		print_r(data)
		-- 数据不足
		if #data ~= 3 then return false end
		
		for i = 1, 3 do
			--为空
			if data[i] == "" then return false end
			--数据合法性
			if tonumber(data[i]) == nil then return false end
		end
		--数据长度,范围合法性(例如: 2017-10-10)
		local year = tonumber(data[1])
		local month = tonumber(data[2])
		local day = tonumber(data[3])
		if year < 1000 or year > 9999 then return false end
		if month < 1 or month > 12 then return false end
		if day < 1 or day > 31 then return false end

		return true
	end
	if check(beginTime) == false or check(endTime) == false then
		GlobalFun:showToast("输入日期格式有误,格式应为xxxx-xx-xx", 3)
		return false 
	end

	--计算天数
	local data_1 = string.split(beginTime, "-")
	local data_2 = string.split(endTime, "-")

	--后者要大于等于前者
	local function check2(str_1, str_2)
		if tonumber(str_1[1]) > tonumber(str_2[1]) then return false end
		if tonumber(str_1[1]) == tonumber(str_2[1]) then
			if tonumber(str_1[2]) > tonumber(str_2[2]) then return false end
			if tonumber(str_1[2]) == tonumber(str_2[2]) then
				if tonumber(str_1[3]) > tonumber(str_2[3]) then return false end
			end
		end
		return true
	end
	if check2(data_1, data_2) == false then
		GlobalFun:showToast("结束时间应大于开始时间", 3)
		return false 
	end

	--查询跨度最大为7天
	local monthData = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
	local maxDay = 7
	local function check3(str_1, str_2)
		local year_1 = tonumber(str_1[1])
		local month_1 = tonumber(str_1[2])
		local day_1 = tonumber(str_1[3])

		local year_2 = tonumber(str_2[1])
		local month_2 = tonumber(str_2[2])
		local day_2 = tonumber(str_2[3])

		if year_2 > year_1 and (year_2 - year_1) == 1 then
			if month_2 == 1 and month_1 == 12 then
				local len = day_2 + monthData[month_1] - day_1 + 1
				if len <= maxDay then return true, len end
			end
		elseif year_2 == year_1 then
			if month_2 > month_1 and month_2 - month_1 == 1 then
				local len = day_2 + monthData[month_1] - day_1 + 1
				if len <= maxDay then return true, len end
			elseif month_2 == month_1 then
				local len = day_2 - day_1 + 1
				if len <= maxDay then return true, len end
			end
		end
		return false
	end
	local flag, day = check3(data_1, data_2)
	if flag == false then
		GlobalFun:showToast("查询跨度最大为7天", 3)
		return false 
	end

	--local day = tonumber(data_2[3] + 1) - tonumber(data_1[3])
	_w["txt_daysNum"]:setString(day)

	beginTime = beginTime .. " 00:00:00"
	endTime = endTime .. " 23:59:59"
	cclog("beginTime:"..beginTime.."   endTime:"..endTime)
	self._beginTime = beginTime
	self._endTime = endTime
	ex_clubHandler:gotoRoomCardStatistics(beginTime, endTime, 1)
end

--房卡统计
function UI_RoomCardStatistics:setPage_RoomCardStatistics()
	self.fangkaList:removeAllChildren()
	_w["txt_daysNum"]:setString("0")
	_w["txt_pageNum"]:setString(self._roomCardIndex)

	_w["txt_costCard_manager"]:setString("0")
	_w["txt_costCard_member"]:setString("0")

	local date = os.date("%Y-%m-%d");
	cclog("cur date:"..date)
	_w["textFiled_startTime"]:setString(date)
	_w["textFiled_endTime"]:setString(date)

	self:checkRoomCard()
end

function UI_RoomCardStatistics:res_onRoomCardStatistics(data)
	cclog("wtf UI_RoomCardStatistics:res_onRoomCardStatistics")
	print_r(data)
	self.fangkaList:removeAllChildren()
	


    -- local res = {}
    -- res.FKTJMaxPage = 10  --最大页数
    -- res.FKTJCurPage = 1   --当前页码
    -- res.FKTJPageObjMaxNum = 6   --每页展示的最大数量
    -- res.FKTJPageObjCurNum = 6   --该页显示的真实数量


    -- res.roomTb = {}
    -- for i = 1, res.FKTJPageObjCurNum do
    --     local item = {}
    --     item.id = 11111
    --     item.roomID = 22222
    --     item.consumeCardNum = 999
    --     item.playerMaxNum = 4
    --     item.finishedInning = 3
    --     item.sumInning = 8
    --     item.openRoomTime = "2018-10-10 12:12"
    --     item.homeownerName = "aaa"
    --     item.creatorName = "bbb"


    --     item.bigWinnerNum = 1
    --     item.bigWinnerTb = {}
    --     for j = 1, item.bigWinnerNum do
    --         local item2 = {}
    --         item2.uID = 11111
    --         item2.name = "bbb"
    --         item2.iconUrl = ""
    --         item2.score = 10
    --         table.insert(item.bigWinnerTb, item2)
    --     end

    --     item.otherPlayerNum = 3
    --     item.otherPlayerTb = {}
    --     for j = 1, item.otherPlayerNum do
    --         local item2 = {}
    --         item2.uID = 111
    --         item2.name = "eee"
    --         item2.iconUrl = ""
    --         item2.score = 100
    --         table.insert(item.bigWinnerTb, item2)
    --     end
    --     item.serveRule = '{"playerNum":4,"gameType":"hz","PLAY_LEILUO":true,"PLAY_7D":true,"PLAY_EIGHT":true,"PLAY_CONNON":true,"PLAY_AK_ONE_ALL":true,"za":0}'

    --     table.insert(res.roomTb, item)
    -- end

    -- res.qunzhuConsumeCard = 22
    -- res.chengyuanConsumeCard = 44
    -- local data = res

    cclog("ClubController:onRoomCardStatistics wtf")
    print_r(res)
    



    
    local FKTJMaxPage = tonumber(ClubManager:getInfo("FKTJMaxPage"))
    local FKTJCurPage = tonumber(ClubManager:getInfo("FKTJCurPage"))
	self._roomCardIndex = FKTJCurPage

	self._roomCardTb = copyTable(data.roomTb)
	--self:paging_rc(nil, true)
	self:insertDataToListView()

	_w["txt_pageNum"]:setString(FKTJCurPage.." / "..FKTJMaxPage)

	_w["txt_costCard_manager"]:setString(data.qunzhuConsumeCard)
	_w["txt_costCard_member"]:setString(data.chengyuanConsumeCard)

	if FKTJMaxPage <= 0 and #(self._roomCardTb) <= 0 then
		GlobalFun:showToast("暂无房卡信息", 1)
	end
end

function UI_RoomCardStatistics:insertDataToListView()
	--设置ui item
	--_w["fangkaList"]:removeAllChildren()

	-- cclog("#self._roomCardTb:"..#(self._roomCardTb))

	-- local lastLayout = nil
	-- --for i, v in ipairs(self._roomCardShowTb) do
	-- for i, v in ipairs(self._roomCardTb) do
	-- 	if i%3 == 1 then
	-- 		lastLayout = ccui.Layout:create()
	-- 	end 
        
 --        lastLayout:setContentSize(cc.size(240*2 + 5, 102))

 --        local item = display.newCSNode("club/Item_fangkatongji.csb")

 --        if i%3 == 1 then
	--         item:setPosition(cc.p(0,0))
	--     else
	--     	item:setPosition(cc.p(240 + 5,0))
	--     end

 --        item:setTag(i)
 --        item:addTo(lastLayout)

 --        local _itemW = self:loadChildrenWidget(item)

 --        _itemW["itemLayout"]:setTag(i)
	-- 	_itemW["itemLayout"]:setTouchEnabled(true)
	-- 	_itemW["itemLayout"]:addTouchEventListener(function(sender, type)
 --        	if type == 2 then
	--         	cclog("item type:"..type.. "   tag:"..sender:getTag())
	--         	self:showRoomCardDetail(sender:getTag())
	--         end
 --        end)
	-- 	_itemW["itemLayout"]:setSwallowTouches(false)

 --        _itemW["txt_roomID"]:setString(v.roomID)
 --       	_itemW["txt_fangkaNum"]:setString(v.consumeCardNum.."张")
 --       	--2017-10-19 11:16:23
 --       	_itemW["txt_openRoomTime"]:setString(v.openRoomTime)
 --       	--_itemW["txt_roomID"]:setString("123456789")
 --       	--_itemW["txt_fangkaNum"]:setString("99张")

 --       	if i%3 == 1 then
	--         _w["fangkaList"]:pushBackCustomItem(lastLayout)
	--     end
	  
	-- end







	self.fangkaList:removeAllChildren()
    local contentSize = self.fangkaList:getContentSize()
    local data = self._roomCardTb
    local num = #data
    local row = 2--排数
    local col = math.ceil(num/row)--行数
    local w, h = 380, 75
    local totalWidth = w * row--总宽度
    local totalHeight = h * col--总高度
    if totalHeight <= contentSize.height then
        totalHeight = contentSize.height
    end
    local offset_x, offset_y = w, h
    local uiIndex = 0
    local pos_x, pos_y = 0, totalHeight

    for i,v in ipairs(self._roomCardTb) do
        if uiIndex%row == 0  then
            pos_x = 8
            pos_y = pos_y - offset_y -5
        else
            pos_x = pos_x + offset_x
        end
        uiIndex = uiIndex + 1

        local layout = ccui.Layout:create()
        local size = cc.size(w +2, h +2)
        layout:setContentSize(size)
        layout:setPosition(pos_x, pos_y)

        local item = display.newCSNode("club/Item_fangkatongji.csb")
        local _itemW = self:loadChildrenWidget(item)
        item:setPosition(0, 0)
        item:addTo(layout)


        item:setTag(i)
		_itemW["itemLayout"]:setTag(i)

        _itemW["itemLayout"]:setTouchEnabled(true)
        _itemW["itemLayout"]:setSwallowTouches(false)
        _itemW["itemLayout"]:addTouchEventListener(function(sender, type)
								        	if type == 2 then
									        	cclog("item type:"..type.. "   tag:"..sender:getTag())
									        	self:showRoomCardDetail(sender:getTag())
									        end
								        end)
        _itemW["txt_roomID"]:setString(v.roomID)
        _itemW["txt_fangkaNum"]:setString(v.consumeCardNum.."张")
        _itemW["txt_openRoomTime"]:setString(v.openRoomTime)

        self.fangkaList:addChild(layout)

    end

    local innerSize = self.fangkaList:getInnerContainer():getContentSize()
    self.fangkaList:setInnerContainerSize(cc.size(innerSize.width,totalHeight))
end

--房卡统计详情
function UI_RoomCardStatistics:showRoomCardDetail(_index)
	cclog("UI_RoomCardStatistics:showRoomCardDetail index:".._index)
	local data = self._roomCardTb[_index]
	if data ~= nil then
		_w["RoomCard_panel"]:setVisible(true)
		_w["rc_roomID"]:setString(data.roomID)
		-- _w["rc_consumeCardNum"]:setString(data.consumeCardNum.."张")
		-- _w["rc_people"]:setString(data.playerMaxNum.."人")
		-- _w["rc_juNum"]:setString(data.finishedInning.."/"..data.sumInning.."局")

		
		_w["txt_useCardName"]:setString(data.homeownerName)
		_w["txt_creatorName"]:setString(data.creatorName)
		GlobalFun:uiTextCut(_w["txt_creatorName"])
		GlobalFun:uiTextCut(_w["txt_useCardName"])

		if data.serveRule ~= "" then
			cclog("data.serveRule:"..data.serveRule)
			local str = GameRule:clubGameRuleText2(data.serveRule)
		    _w["txt_rule"]:setString(str)
		else
			local game_data = ClubManager:getInfo("game_setting")
		    if game_data and game_data.playRuleTb and next(game_data.playRuleTb) then
		        local info = game_data.playRuleTb[1]
		        local str = GameRule:clubGameRuleText2(info)
		        _w["txt_rule"]:setString(str)
		    end
		end
		local function setPlayer(index, playerInfo)
			if playerInfo ~= nil then
				_w["rc_playerName_"..index]:setString(playerInfo.name)
				_w["rc_playerScore_"..index]:setString(playerInfo.score)
				_w["rc_playerID_"..index]:setString(playerInfo.uID)

				GlobalFun:uiTextCut(_w["rc_playerName_"..index]) 

				-- _w["rc_playerID_"..index]:setString("ID:"..playerInfo.uID)

				local icon = ex_fileMgr:loadLua("app.views.club.PlayerIcon").new()
				icon:setScale(0.7)
				local size = _w["my_icon"..index]:getContentSize()
				icon:setPosition(size.width/2, size.height/2)
				icon:setIcon(playerInfo.uID, playerInfo.iconUrl)
				_w["my_icon"..index]:addChild(icon)	
							
			else
				_w["rc_playerName_"..index]:setString("")
				_w["rc_playerScore_"..index]:setString("")
				_w["rc_playerID_"..index]:setString("")
			end
		end
		for i = 1, 4 do
			if i <= #data.bigWinnerTb then
				local v = data.bigWinnerTb[i]
				setPlayer(i, v)
				_w["my_icon"..i]:setVisible(true)
				_w["rc_playerName_"..i]:setVisible(true)	
				_w["rc_playerScore_"..i]:setVisible(true)
				_w["rc_playerID_"..i]:setVisible(true)				
			else
				_w["my_icon"..i]:setVisible(false)
				_w["rc_playerName_"..i]:setVisible(false)
				_w["rc_playerScore_"..i]:setVisible(false)
				_w["rc_playerID_"..i]:setVisible(false)
			end
		end
	end
end

--房卡统计翻页
function UI_RoomCardStatistics:paging_rc(_flag, _isDefault)	--true左边 false右边
	local FKTJMaxPage = tonumber(ClubManager:getInfo("FKTJMaxPage"))
	local FKTJCurPage = tonumber(ClubManager:getInfo("FKTJCurPage"))
	self._roomCardIndex = FKTJCurPage
	cclog("wtf FKTJMaxPage:"..FKTJMaxPage)
	cclog("wtf FKTJCurPage:"..FKTJCurPage)

	--[[
	local lastIndex = self._roomCardIndex
	local function updateListView()
		if self._roomCardIndex ~= lastIndex then
			self._roomCardShowTb = {}
			local beginIndex = 6 * (self._roomCardIndex - 1) + 1
			local endIndex = beginIndex + 5
			for i = beginIndex, endIndex do
				if self._roomCardTb[i] ~= nil then
					table.insert(self._roomCardShowTb, self._roomCardTb[i])
				end
			end

			_w["txt_pageNum"]:setString(self._roomCardIndex)
			self:insertDataToListView()
		end
	end
	--]]
	if _isDefault == true then
		--lastIndex = 0
		--self._roomCardIndex = 1
		--updateListView()
	else
		if _flag == true then 	--左
			if self._roomCardIndex <= 1 then cclog("return") return end
			self._roomCardIndex = self._roomCardIndex - 1
			--updateListView()
			cclog("_roomCardIndex:"..self._roomCardIndex)
			ex_clubHandler:gotoRoomCardStatistics(self._beginTime, self._endTime, self._roomCardIndex)
		else 					--右
			if self._roomCardIndex >= FKTJMaxPage then cclog("return") return end
			self._roomCardIndex = self._roomCardIndex + 1
			--updateListView()
			cclog("_roomCardIndex:"..self._roomCardIndex)
			ex_clubHandler:gotoRoomCardStatistics(self._beginTime, self._endTime, self._roomCardIndex)
		end
	end
end

-- local data = ClubManager:getInfo("game_setting")
--     if data and data.playRuleTb and next(data.playRuleTb) then
--         local info = data.playRuleTb[1]
--         local str = GameRule:clubGameRuleText2(info)

--         self.txt_rule:setString("规则:" .. str)
--     end

return UI_RoomCardStatistics
