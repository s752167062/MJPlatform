--俱乐部房间列表逻辑模块，设置成node只是为了onExit

local Unit_RoomInfo = class("Unit_RoomInfo",ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView") )



function Unit_RoomInfo:ctor(params)
	self.root = self
	Unit_RoomInfo.super.ctor(self)



	CCXNotifyCenter:listen(self,function(obj,key,data) self:res_onOpenRoomList(data) end, "res_onOpenRoomList")
	CCXNotifyCenter:listen(self,function(obj,key,data) self:onRequestCreateRoom(data) end, "CLUB:onRequestCreateRoom")
	CCXNotifyCenter:listen(self,function(obj,key,data) self:onDeleteRoom(data.roomID) end, "CLUB:onDeleteRoom")
	CCXNotifyCenter:listen(self,function(obj,key,data) self:onUpdateRoomInfo(data) end, "CLUB:onUpdateRoomInfo")

	CCXNotifyCenter:listen(self,function(obj,key,data) self:res_onGameSetting(data) end, "res_onGameSetting")

	CCXNotifyCenter:listen(self,function(obj,key,data) self:reConnect() end, "ClubClient.onConnectCheck--reConnect")




	self.roomList1 = params.roomList1
	self.txt_page = params.txt_page
	self.txt_page:setTextHorizontalAlignment(1)
	self.btn_next = params.btn_next
	self.btn_last = params.btn_last
	-- self.txt_totalPage = params.txt_totalPage
    self.cur_pageIdx = 1
    self.max_pageIdx = 100
    self.cur_pageMember = 0
    self.deskTotalPlayer = 4


    -- self.isInitReq = false

	self.desks = {}

	self.btn_next:setVisible(false)
	self.btn_last:setVisible(false)

	ex_clubHandler:gotoOpenRoomList(0, self.cur_pageIdx) -- 获取第一页桌子信息
	self:res_onGameSetting(ClubManager:getInfo("game_setting"))



	-- self:res_onOpenRoomList()
	-- for i =0, 7 do
	-- 	self:onUpdateRoomInfo(i)
	-- end
end


function Unit_RoomInfo:onExit()
    CCXNotifyCenter:unListenByObj(self)
    -- ex_timerMgr:unRegister(self)
end



function Unit_RoomInfo:onUnitClick(_sender)
	local name = _sender:getName()
	cclog("Unit_RoomInfo:onUnitClick >>>", name)

	if name == "btn_last" then --成员列表上一页
		cclog("1")
        if self.cur_pageIdx -1 >0 then
            ex_clubHandler:gotoOpenRoomList(0, self.cur_pageIdx -1)
        end
    elseif name == "btn_next" then  --成员列表下一页
    	cclog("2")
        if self.cur_pageIdx +1 <= self.max_pageIdx then
            ex_clubHandler:gotoOpenRoomList(0,self.cur_pageIdx +1)
        end
    elseif name == "btn_go" then  --成员列表下一页
    	cclog("2")
    	local str = self.txt_page:getString()
    	local numb = tonumber(str)
    	if not numb then 
    		GlobalFun:showToast("请输入正确数字", 3)
    		self.txt_page:setString(string.format("%s/%s", self.cur_pageIdx,self.max_pageIdx))
    		return 
    	end

    	if numb > 0 and numb <= self.max_pageIdx then
    		ex_clubHandler:gotoOpenRoomList(0, numb)
    	else
    		GlobalFun:showToast("超出页数范围", 3) 
    		self.txt_page:setString(string.format("%s/%s", self.cur_pageIdx,self.max_pageIdx))
    	end

    end  
end

function Unit_RoomInfo:setDeskPage(cur, max)
    self.txt_page:setString(string.format("%s/%s", cur, max))
    -- self.txt_totalPage:setString(string.format("(共%s页)", max))
    self.cur_pageIdx = cur
    self.max_pageIdx = max
    self.btn_last:setEnabled(cur ~= 1 and true or false)
    self.btn_next:setEnabled(cur ~= max and true or false)
    self.btn_next:setVisible(true)
	self.btn_last:setVisible(true)
    cclog("Unit_RoomInfo:Unit_RoomInfo >>>", cur, max)
end




function Unit_RoomInfo:createDesks(count)
	
	if not next(self.desks) then  --没创建桌子控件就创建
		local row_numb = 4   --一行显示多少个桌子
		local width, height = 1050, 200
		local layout = ccui.Layout:create()
    	layout:setContentSize(cc.size(width,height))
    	self.roomList1:pushBackCustomItem(layout)

		local item_x = 40		--单行桌子偏移量
		for i = 1, count do      -- count 当页的桌子数
			

			if layout then
				local item = display.newCSNode("club/Item_desk.csb")
				item:addTo(layout)
				item:setPosition(item_x, 0)
				local _itemW = self:loadChildrenWidget(item)
				local size = _itemW["itemLayout"]:getContentSize()
				item_x = item_x +size.width +58

				-- local desk_stat = {
				-- 	wait = _itemW["wait_4"],
				-- 	playing = _itemW["playing_4"],
				-- 	other_wait = _itemW["wait_3"],
				-- 	other_playing = _itemW["playing_3"]
				-- }

				local icons = {}
				for m = 1, 4 do
					local icon = ex_fileMgr:loadLua("app.views.club.PlayerIcon").new()
					icon:setScale(0.4)
					icon:setClickEnable(false)
					icons[m] = icon
					_itemW["icon_" .. m]:addChild(icon)
					GlobalFun:uiTextCut(_itemW["name_" .. m])
				end

				self.desks[i] = {deskNumb = i, ui = item, _itemW = _itemW, icons = icons, desk_stat = nil, data = nil}

				cclog("self.deskTotalPlayer >>", self.deskTotalPlayer or 4)
				self:setDeskCanPlayerNumb(self.desks[i], self.deskTotalPlayer or 4)


				--本处点击等回调，要使用self.desks[i]来获取数据
				_itemW["btn_option"]:addClickEventListener(
					function()
						cclog("btn_option >>", self.desks[i].deskNumb)

						if self.desks[i].data then
							local scene = cc.Director:getInstance():getRunningScene()
					        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_DeskInfo")
					        scene:addChild(ui.new({app = nil, desk = self.desks[i]}))
					    else
					    	GlobalFun:showToast("未开房间", 3)    
					    end
					end)




				_itemW["btn_desk"]:addClickEventListener(
					function()
						cclog("btn_desk >>", self.desks[i].deskNumb)

						if self.desks[i].data == nil then
							local data = ClubManager:getInfo("game_setting")

							if data and data.playRuleTb and next(data.playRuleTb) then
								local params =json.decode(data.playRuleTb[1])
								cclog("btn_desk >>>> ju", params.ju)
								if params.ju == 0 or not params.ju then
									local scene = cc.Director:getInstance():getRunningScene()
							        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_StartDesk")
							        scene:addChild(ui.new({app = nil, deskNumb = self.desks[i].deskNumb}))
							    else
							    	local function ok()
							    		ex_clubHandler:gotoRequestCreateRoom(1, self.desks[i].deskNumb -1, params.ju) 
							    	end
							    	ClubGlobalFun:showError("您是否要创建房间", ok, nil, 2)
							    end
						    else
						    	 ClubGlobalFun:showError("会长或管理员未设置玩法规则", nil, nil, 2)
						    end
						else
							local data = self.desks[i].data
							cclog("goto <>> ", data.id, data.status)
							if data.status ~= 0 then
								local str = data.status == 1 and "已经开局，不可进入" or "已经结束，不可进入"
								GlobalFun:showToast(str, 2)
								return 
							end

							
							ex_clubHandler:gotoRoom(data.id)
						end
					end)
			end

			if i~= count and i%row_numb == 0 then
				layout = ccui.Layout:create()
	        	layout:setContentSize(cc.size(width,height -30))
	        	self.roomList1:pushBackCustomItem(layout)
	        	item_x = 40
			end
		end
	end
end




--将桌子还原到最初始状态
function Unit_RoomInfo:initDesk(idx, numb)
	cclog("Unit_RoomInfo:initDesk >>>")
	local v = self.desks[idx]
	if v then
		v.deskNumb = numb
		v._itemW["txt_numb"]:setString(numb)
		v._itemW["countDown"]:setVisible(false)
		v._itemW["btn_option"]:setVisible(false)
		self:cleanHeadAndName(v)
		self:setDeskCanPlayerNumb(v, self.deskTotalPlayer or 4)
		self:showDeskStat(v, 0)
		v.data = nil
	end
end

function Unit_RoomInfo:cleanHeadAndName(desk)
	if desk then
		for k,v in pairs(desk.icons) do
			v:removeHeadImg()
			v:setVisible(false)
			v:setPlayerStatus(-1)
			desk._itemW["name_" .. k]:setString("")
		end
	end
end

function Unit_RoomInfo:setDeskCanPlayerNumb(desk, numb)
	if not desk then return end
	cclog("Unit_RoomInfo:setDeskCanPlayerNumb >>>", numb)
	
	if numb == 3 then
		local desk_stat = {
					normal = desk._itemW["img_desk3"],
					wait = desk._itemW["img_wait"],
					playing = desk._itemW["img_playing"],

					other = desk._itemW["img_desk4"],
				}
		desk.desk_stat = desk_stat
	elseif numb == 4 then
		local desk_stat = {
					normal = desk._itemW["img_desk4"],
					wait = desk._itemW["img_wait"],
					playing = desk._itemW["img_playing"],

					other = desk._itemW["img_desk3"],
				}
		desk.desk_stat = desk_stat
	end

end

function Unit_RoomInfo:showDeskStat(desk, stat)
	if desk then
		for k,v in pairs(desk.desk_stat) do
			v:setVisible(false)
		end
		cclog("Unit_RoomInfo:showDeskStat >>>", stat)
		desk.desk_stat.normal:setVisible(true)
		if stat == 0 then	
			desk._itemW["countDown"]:setVisible(false)
		elseif stat == 1 then
			desk.desk_stat.wait:setVisible(true)
			desk._itemW["countDown"]:setVisible(true)
		elseif stat == 2 then
			desk.desk_stat.playing:setVisible(true)
			desk._itemW["countDown"]:setVisible(false)
		end
	end
end


function Unit_RoomInfo:setDeskInfo(numb, info)
	for k,v in pairs(self.desks) do
		if v.deskNumb == numb+1 then
			v.data = info
			self:showInfo(v)
			break
		end
	end
end


function Unit_RoomInfo:showInfo(desk)
	if desk and desk.data then
		cclog("Unit_RoomInfo:showInfo >>>>", desk.deskNumb)
		desk._itemW["btn_option"]:setVisible(true)
		desk._itemW["txt_numb"]:setString(desk.deskNumb)
		local data = desk.data

		self:setDeskCanPlayerNumb(desk, data.maxPeopleNum)   --设置桌子最多坐几人
		self:showDeskStat(desk, data.joinRoomPeopleNum == data.maxPeopleNum and 2 or 1) -- 如果在座的人等于桌子的人数，等于开始了


		self:cleanHeadAndName(desk)

		desk._itemW["txt_countDown"]:setString(os.date("%M:%S",data.surplusTime))

		for k,v in pairs(data.playerTb) do
			local icon = desk.icons[k]
			local name = desk._itemW["name_".. k]
			icon:setIcon(v.playerID ,v.iconUrl)
			icon:setVisible(true)
			name:setString(v.playerName )

			icon:setPlayerStatus(v.isOnline and -1 or 0)
		end
		

	end
end

function Unit_RoomInfo:onUpdateRoomInfo(data)
	cclog("Unit_RoomInfo:onUpdateRoomInfo >>")

	-- local res = {}
	-- local function parseOneRoomList(idx)
 --    	local item = {}
	--     item.id = 11111
	--     item.status = 1
	--     item.surplusTime = 111111111111/1000
	--     item.curPeopleNum = 4
	--     item.maxPeopleNum = 4
	--     item.createTime = 111111111111/1000
	--     item.endTime = 111111111111/1000
	--     item.roundNum = 1
	--     item.zhaNum = 1
	--     item.roomOwnerID = 2222222   --被扣卡的人
	--     item.roomOwnerName = "aaaaa"
	--     item.roomOwnerIcon = ""
	--     item.finishRoundNum = 3
	--     item.deskIdx = idx
	--     item.startDeskUserID = 333333333   --开这个房的人
	--     item.startDeskUserName = 333333333333333

	--     item.joinRoomPeopleNum = 4
	--     item.playerTb = {}
	--     for j = 1, item.joinRoomPeopleNum do
	--         local item2 = {}
	--         item2.playerID = 11111111111111
	--         item2.playerWXID = 1111111111
	--         item2.playerName = "aaaa"
	--         item2.iconUrl = ""
	--         item2.score = 1
	--         item2.isOnline = true

	--         table.insert(item.playerTb, item2)
	--     end  
	--     item.canDismiss = true--是否可以解散
	--     item.isNewMa =true
	--     return item
 --    end
 --    res = parseOneRoomList(data)

 --    data = res


	print_r(data)
	if data.status == 2 then
		self:onDeleteRoom(data.id)
	else
		-- if data.surplusTime >=0 then
			self:setDeskInfo(data.deskIdx, data)
		-- end
	end
end



function Unit_RoomInfo:onDeleteRoom(roomID)
	cclog("Unit_RoomInfo:onDeleteRoom >>>", roomID)
	cclog(debug.traceback())
	for k,v in pairs(self.desks) do
		if v.data then
			if v.data.id == roomID then
				cclog("Unit_RoomInfo:onDeleteRoom >>> initDesk", v.deskNumb)
				self:initDesk(k, v.deskNumb)
				break
			end
		end
	end
end

function Unit_RoomInfo:onRequestCreateRoom(data)


	if data.roomId then  --创建成功
	
		if ClubManager:isGuanliyuan() then  --刷新桌子
			-- ex_clubHandler:gotoOpenRoomList(0, self.cur_pageIdx) 

		else--直接进入房间

			ex_clubHandler:gotoRoom(data.roomId)
		end
	end
end


function Unit_RoomInfo:res_onGameSetting(data)
	cclog("Unit_RoomInfo:res_onGameSetting >>>")
	print_r(data)


	if data and data.playRuleTb and data.playRuleTb[1] then
		
		local tb = json.decode(data.playRuleTb[1])
		-- if tb.playerNum and self.deskTotalPlayer ~= tb.playerNum then  --游戏设置的一桌人数有变
			-- ex_clubHandler:gotoOpenRoomList(0, self.cur_pageIdx)
			-- self.isInitReq = true
			
		-- end
		self.deskTotalPlayer = tb.playerNum or 4
		for k,v in pairs(self.desks) do -- 刷新未创建房间的桌子能坐的人数
			if v.data == nil then
				cclog("sssss >>>", self.deskTotalPlayer)
				self:setDeskCanPlayerNumb(v, self.deskTotalPlayer)
				self:showDeskStat(v, 0)
			end
		end

	end
	
	-- if self.isInitReq == false then
	-- 	self.isInitReq = true
	-- 	ex_clubHandler:gotoOpenRoomList(0, self.cur_pageIdx)
	-- end
end


function Unit_RoomInfo:res_onOpenRoomList(data)
	-- local res = {}
 --    res.roomType = 0
 --    res.pageMax = 10
 --    res.pageIdx = 1
 --    res.deskNumb = 8

 --    data = res


	cclog ("Unit_RoomInfo:res_onOpenRoomList >>>>")
	print_r(data)

	if data.roomType ~= 0 then return end

	self:setDeskPage(data.pageIdx, data.pageMax)  --设置页数
	self:createDesks(data.deskNumb)  -- 初始化桌子控件
	-- self:cleanAllDeskInfo()  --清空桌子信息


	for i = 1, data.deskNumb do
		local showDeskNumb = data.deskNumb *(data.pageIdx -1) +i     --显示的桌子号码跟服务器的桌子索引有差别，服务器桌子索引从0开始的
		self:initDesk(i, showDeskNumb)
	end
	
	-- for k,v in pairs(data.roomTb) do
	-- 	self:setDeskInfo(v.deskIdx, v)
	-- end
end









function Unit_RoomInfo:updateReadyRoomCountdown() --未开始房间的倒计时
	for k,v in pairs(self.desks) do
		if v.data and v.data.status == 0 then
			v.data.surplusTime = v.data.surplusTime -1
			v._itemW["txt_countDown"]:setString(os.date("%M:%S",v.data.surplusTime))
			if v.data.surplusTime <= 0 then
				self:onDeleteRoom(v.data.id)
			end
		end
	end

end

function Unit_RoomInfo:reConnect()
	ex_clubHandler:gotoOpenRoomList(0, self.cur_pageIdx)
end

--快速加入
function Unit_RoomInfo:createRoomFromQuick()
	cclog("Unit_RoomInfo:createRoomFromQuick diu diu diu")
	--print_r(self.desks)

	local flag = true
	for i, v in ipairs(self.desks) do
		cclog("diu i:"..i)
		if v.data == nil then
			flag = false

			local data = ClubManager:getInfo("game_setting")
			if data ~= nil then 
				print_r(data)
			end
			
			if data and data.playRuleTb and GlobalFun:strLenForTb(data.playRuleTb) > 0 then
				
				local params =json.decode(data.playRuleTb[1])
				cclog("btn_desk >>>> ju", params.ju)
				if params.ju == 0 or not params.ju then
					local function cb()
				        --创建房间
				        cclog("创建房间 v.deskNumb："..v.deskNumb.."  params.ju:"..params.ju)
			    		ex_clubHandler:gotoRequestCreateRoom(1, -1, 8) 
				    end
				    ClubGlobalFun:showError("俱乐部暂时没有空余房间，是否创建房间",cb,nil,2)
			    else
			    	local function cb()
				        --创建房间
				        cclog("创建房间 v.deskNumb："..v.deskNumb.."  params.ju:"..params.ju)
			    		ex_clubHandler:gotoRequestCreateRoom(1, -1, params.ju) 
				    end
				    ClubGlobalFun:showError("俱乐部暂时没有空余房间，是否创建房间",cb,nil,2)
			    end
				
		    else
		    	local function callBack()
		    		if ClubManager:isGuanliyuan() then  --会长和管理员才能搞
						local scene = cc.Director:getInstance():getRunningScene()
				        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_GameSetting")
				        scene:addChild(ui.new({app = nil}))
				   	end
		    	end
		    	ClubGlobalFun:showError("会长或管理员未设置玩法规则", callBack, nil, 2)
		    	--cclog("会长或管理员未设置玩法规则")
		    end
		    
		    break
		    
		end
	end
	if flag == true then
		local data = ClubManager:getInfo("game_setting")
		if data ~= nil then 
			print_r(data)
		end
		
		if data and data.playRuleTb and GlobalFun:strLenForTb(data.playRuleTb) > 0 then
			
			local params =json.decode(data.playRuleTb[1])
			cclog("btn_desk >>>> ju", params.ju)
			if params.ju == 0 or not params.ju then
				local function cb()
			        --创建房间
			        cclog("创建房间 v.deskNumb："..v.deskNumb.."  params.ju:"..params.ju)
		    		ex_clubHandler:gotoRequestCreateRoom(1, -1, 8) 
			    end
			    ClubGlobalFun:showError("俱乐部暂时没有空余房间，是否创建房间",cb,nil,2)
		    else
		    	local function cb()
			        --创建房间
			        cclog("创建房间 ".."  params.ju:"..params.ju)
		    		ex_clubHandler:gotoRequestCreateRoom(1, -1, params.ju) 
			    end
			    ClubGlobalFun:showError("俱乐部暂时没有空余房间，是否创建房间",cb,nil,2)
		    end
			
	    else
	    	local function callBack()
	    		if ClubManager:isGuanliyuan() then  --会长和管理员才能搞
					local scene = cc.Director:getInstance():getRunningScene()
			        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_GameSetting")
			        scene:addChild(ui.new({app = nil}))
			   	end
	    	end
	    	ClubGlobalFun:showError("会长或管理员未设置玩法规则", callBack, nil, 2)
	    	--cclog("会长或管理员未设置玩法规则")
	    end
	end
	
end


return Unit_RoomInfo


